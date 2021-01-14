SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('AutoConfirmService', 'p') is not null
begin
  drop procedure AutoConfirmService
end
go

create procedure AutoConfirmService
as
begin
    declare @GroupNo bigint
    declare @OrderID int
    declare @OrderServiceID int
    declare @TGExecutingCount int
    declare @TGFinishedCount int
    declare @TGTotalCount int
    declare @count int

    declare records_Cursor cursor
    for(
        -- 取得自动确认的记录信息
        SELECT
            T3.GroupNo,
            T1.OrderID,
            T1.ID as OrderServiceID,
            T1.TGExecutingCount,
            T1.TGFinishedCount,
            T1.TGTotalCount
        FROM [TBL_ORDER_SERVICE] T1 WITH(NOLOCK)
             INNER JOIN [SERVICE] T2 WITH(NOLOCK) ON T1.ServiceID = T2.ID
             INNER JOIN [SERVICE] T5 WITH(NOLOCK) ON T5.Available = 1 and T5.Code = T2.Code
             INNER JOIN [TBL_TREATGROUP] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderServiceID
        WHERE T3.TGStatus = 5
          AND T3.DeleteFlag = 1
          AND T5.AutoConfirm = 1
          AND datediff(dd, t3.tgendtime, getdate()) >= T5.AutoConfirmDays
    )
    open records_Cursor
    fetch next from records_Cursor into @GroupNo, @OrderID, @OrderServiceID, @TGExecutingCount, @TGFinishedCount, @TGTotalCount
    while @@FETCH_STATUS = 0
    begin

        -- 更新[TREATMENT]
        INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE GroupNo = @GroupNo
        UPDATE [TREATMENT]
        SET
            Status = 2,
            FinishTime = getdate(),
            UpdaterID = null,
            UpdateTime = getdate()
        WHERE GroupNo = @GroupNo

        -- 更新[TBL_TREATGROUP]
        INSERT INTO [HST_TREATGROUP] SELECT * FROM [TBL_TREATGROUP] WHERE GroupNo = @GroupNo
        UPDATE [TBL_TREATGROUP]
        SET
            TGStatus = 2,
            TGEndTime = getdate(),
            UpdaterID = null,
            UpdateTime = getdate()
        WHERE GroupNo = @GroupNo

        --无限次服务不会自动完成订单
        if @TGTotalCount > 0
        begin

            --是否是最后次TG
            if @TGExecutingCount = 0 AND @TGFinishedCount = @TGTotalCount
            begin

                -- 查询订单下还有没有进行中和待确认的TG
                SELECT @count = COUNT(0)
                FROM
                    [TBL_TREATGROUP]
                WHERE OrderServiceID = @OrderServiceID
                  AND TGStatus IN (1, 5)

                if @count = 0
                begin
                  INSERT INTO [HISTORY_ORDER] SELECT * FROM [ORDER] WHERE ID = @OrderID

                  UPDATE [ORDER] SET Status = 2, UpdaterID = null, UpdateTime= getdate() WHERE ID = @OrderID

                  UPDATE [TBL_ORDER_SERVICE] SET Status = 2, UpdaterID = null, UpdateTime= getdate() WHERE ID = @OrderServiceID
                end
            end
        end
        fetch next from records_Cursor into @GroupNo, @OrderID, @OrderServiceID, @TGExecutingCount, @TGFinishedCount, @TGTotalCount
    end
    close records_Cursor
    deallocate records_Cursor
end
go
