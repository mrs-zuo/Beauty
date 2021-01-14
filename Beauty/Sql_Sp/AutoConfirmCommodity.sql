SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('AutoConfirmCommodity', 'p') is not null
begin
  drop procedure AutoConfirmCommodity
end
go

create procedure AutoConfirmCommodity
as
begin
    declare @OrderID int
    declare @OrderCommodityID int
    declare @DeliveryID bigint
    declare @UndeliveredAmount int
    declare @DeliveredAmount int
    declare @Quantity int
    declare @count int

    declare records_Cursor cursor
    for(
        -- 取得自动确认的记录信息
        SELECT  
            T1.OrderID,
            T1.ID AS OrderCommodityID,
            T2.ID AS DeliveryID,
            T1.UndeliveredAmount,
            T1.DeliveredAmount,
            T1.Quantity
        FROM    
            [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK )
            INNER JOIN [TBL_COMMODITY_DELIVERY] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderObjectID
            INNER JOIN [COMMODITY] T3 WITH ( NOLOCK ) ON T1.CommodityID = T3.ID
            INNER JOIN [COMMODITY] T4 WITH ( NOLOCK ) ON T4.Available = 1 and T4.Code = T3.Code
        WHERE T2.Status = 5
          AND T4.AutoConfirm = 1
          AND datediff(dd, T2.CreateTime, getdate()) >= T4.AutoConfirmDays
    )
    open records_Cursor
    fetch next from records_Cursor into @OrderID, @OrderCommodityID, @DeliveryID, @UndeliveredAmount, @DeliveredAmount, @Quantity
    while @@FETCH_STATUS = 0
    begin

        -- 更新[[TBL_COMMODITY_DELIVERY]]
        INSERT INTO [HST_COMMODITY_DELIVERY] SELECT * FROM [TBL_COMMODITY_DELIVERY] WHERE ID = @DeliveryID
        UPDATE [TBL_COMMODITY_DELIVERY]
        SET     
            Status = 2,
            CDEndTime = getdate(),
            UpdaterID = null,
            UpdateTime = getdate()
        WHERE ID = @DeliveryID

        if @UndeliveredAmount = 0 AND @DeliveredAmount = @Quantity
        begin

            -- 查询订单下还有没有进行中和待确认的商品
            SELECT @count = count(0)
            FROM  [TBL_COMMODITY_DELIVERY]
            WHERE OrderObjectID = @OrderCommodityID
              AND Status IN (1, 5)

            if @count = 0
            begin
                INSERT INTO [HISTORY_ORDER] SELECT * FROM [ORDER] WHERE ID = @OrderID

                UPDATE [ORDER] SET Status = 2, UpdaterID = null, UpdateTime= getdate() WHERE ID = @OrderID

                UPDATE [TBL_ORDER_COMMODITY] SET Status = 2, UpdaterID = null, UpdateTime= getdate() WHERE ID = @OrderCommodityID
            end
        end
        fetch next from records_Cursor into @OrderID, @OrderCommodityID, @DeliveryID, @UndeliveredAmount, @DeliveredAmount, @Quantity
    end
    close records_Cursor
    deallocate records_Cursor
end
go
