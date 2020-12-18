SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getServiceRevenueGroup', 'p') is not null
begin
  drop procedure getServiceRevenueGroup
end
go

create procedure getServiceRevenueGroup
  @CompanyID integer,       --��˾ID
  @BranchID integer,        --�ŵ�ID
  @SlaveID integer,         --�û�ID
  @cycleType integer,       --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),  --��ʼ����
  @endtime nvarchar(30)     --��������
AS
begin

   begin try

   --����-�������۶���鱨��
   select
     --IsUseRate �Ƿ�ʹ��ҵ�������ʼ���ҵ��1��ʹ�� 2����ʹ�� 3��δ���ã�Ĭ�ϣ� ProfitRate ҵ��������
     --Type 1��֧�� 2���˿� 3��δ֧��(������֧������)
     sum(B.PaymentAmount * B.ProfitRate * B.typeflag) as SalesAmount,
     --֧����ʽ��0:�ֽ�1:��ֵ����2:���п���3:���� 4:��֧�� 5����ȥ֧�� 6:���� 7���ֽ�ȯ 8��΢�ŵ�����֧�� 9��֧����������֧�� 100�����Ѵ��� 101���������տ�
     B.PaymentMode,
     SUM(sum(B.PaymentAmount * B.ProfitRate * B.typeflag))over() as TotalAmount
   from
     VORDER A 
     left join VPAYMENT B on B.OrderID = A.OrderID
     --0:���� 1���ֵ� 2����˾ 3:���� object = 3      MasterID ������ĿID     Type �Ƿ����
       INNER JOIN (
           select
               distinct P1.MasterID,
               P2.TagID
           from
               [TBL_PROFIT] P1
               INNER JOIN [TBL_USER_TAGS] P2 ON P1.SlaveID = P2.UserID
           where
               P1.Available = 1
           AND P1.Type = 2
           AND P2.Available = 1
           and P2.CompanyID = @CompanyID) P3 ON B.PaymentID = P3.MasterID
   WHERE
       --�����������Ʒ/����ɸѡ����û���õ�����ɾ����
       B.PaymentTime >= A.StartTime
   and B.BranchID = @BranchID
   --Status 1����Ч 2��֧��ִ�� 3��֧������ 4:��ȥ֧��ִ�� 5:��ȥ֧������ 6��֧�������˿� 7��������ֹ�˿�  Type 1��֧�� 2���˿� 3��δ֧��(������֧������)
   AND ((B.Type = 1 AND (B.Status in (2, 3))) OR (B.Type = 2 AND (B.Status in (6, 7))))
   AND A.PaymentStatus > 0
   AND A.ProductType = 0
   --��Ʒ/����flag ����0
   and A.flag = 0
   AND P3.TagID = @SlaveID
   --ʱ������
   AND ((@cycleType = 0 and (DATEDIFF(dd, B.PaymentTime, GETDATE()) = 0))
    or (@cycleType = 1 and (DATEPART(yy, B.PaymentTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, B.PaymentTime) = DATEPART(MM,GETDATE())))
    or (@cycleType = 2 and (DATEPART(qq, B.PaymentTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, B.PaymentTime) = DATEPART(yy,GETDATE())))
    or (@cycleType = 3 and (DATEPART(yy, B.PaymentTime) =DATEPART(YY,GETDATE())))
    or (@cycleType = 4 and (B.PaymentTime BETWEEN @startTime and @endtime)))
   GROUP BY B.PaymentMode
   order by B.PaymentMode

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end