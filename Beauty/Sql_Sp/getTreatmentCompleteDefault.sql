SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getTreatmentCompleteDefault', 'p') is not null
begin
  drop procedure getTreatmentCompleteDefault
end
go

create procedure getTreatmentCompleteDefault
  @BranchID integer,        --�ŵ�ID
  @cycleType integer,       --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),  --��ʼ����
  @endtime nvarchar(30)     --��������
AS
begin

   begin try

   --����������� ָ������ ��ָ������������ͳ�Ʊ���
   select 
     Count(T3.GroupNo) Amount,
     T3.IsDesignated Type
   from
   (
     SELECT distinct
         T1.GroupNo, --TreatGroup ID
         T2.IsDesignated, --ָ��
         T2.OrderID
     FROM
         --TM��
         [TREATMENT] T1
         --��������
         INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo
         --״̬��1:δ��ɡ�2������� ��3����ȡ����4:����ֹ
         inner join vorder T3 on T3.OrderID = T2.OrderID
     WHERE
           T1.BranchID= @BranchID
       --״̬��1�������� 2:����� 3����ȡ�� 4������ֹ 5����ɴ�ȷ��
       AND T1.Status = 2
       --״̬��1�������� 2:����� 3����ȡ�� 4������ֹ 5����ɴ�ȷ��
       AND T2.TGStatus = 2
       AND T3.OrderTime > T3.StartTime
       AND T3.RecordType = 1
       AND T3.Status <> 3
	   and T3.flag = 0
       --ʱ������
       AND ((@cycleType = 0 and (DATEDIFF(dd, T2.TGEndTime, GETDATE()) = 0))
        or (@cycleType = 1 and (DATEPART(yy, T2.TGEndTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T2.TGEndTime) = DATEPART(MM,GETDATE())))
        or (@cycleType = 2 and (DATEPART(qq, T2.TGEndTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T2.TGEndTime) = DATEPART(yy,GETDATE())))
        or (@cycleType = 3 and (DATEPART(yy, T2.TGEndTime) =DATEPART(YY,GETDATE())))
        or (@cycleType = 4 and (T2.TGEndTime BETWEEN @startTime and @endtime)))
   ) T3 GROUP BY T3.IsDesignated

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end