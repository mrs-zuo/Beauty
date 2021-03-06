SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getCustomerReport', 'p') is not null
begin
  drop procedure getCustomerReport
end
go


create procedure getCustomerReport
  @BranchID integer,        --门店ID
  @CompanyId integer,       --用户ID
  @BeginDay DateTime2,  --开始日期
  @EndDay DateTime2     --截至日期
  
AS
begin

	begin try
	if @BranchID > 0
	begin
		select 
			DISTINCT T2.UserID,    --NO
			T2.Name,           --姓名
			T2.Title,          --称谓
			T5.PhoneNumber ,   --电话
			T8.Address,        --地址
			T1.LoginMobile,    --会员登录手机号
			[dbo].[FN_getGender](T2.Gender) Gender,  ----性别
			CONVERT(varchar(10), T2.BirthDay, 111) BirthDay,   --出生年月
			[dbo].[FN_getHeightOrWeight](T2.Height) Height,  ----身高
			[dbo].[FN_getHeightOrWeight](T2.Weight) Weight,  ----体重
			T2.BloodType,              --血型
			[dbo].[FN_getMarriage](T2.Marriage) Marriage ,   ----婚姻状态
			T2.Profession,             --职业
			T9.BranchName,             --入会门店
			CONVERT(varchar(10), T2.CreateTime, 111) CreateTime,   --入会日期
			T2.Remark,                 --备注
			[dbo].[FN_getRegistFrom](T2.RegistFrom) RegistFrom,    -----顾客来源
			T12.Name AS SourceTypeName,--注册端口
			'' AS LastVisit,           --最后访问时间
			ISNULL(T13.TotalSale,0) AS TotalSale,     --消费总额
			0 as IsRed,
			ISNULL(T11.LostRemind,0) LostRemind
                                    
		from 
			[USER] T1 
			INNER JOIN [CUSTOMER] T2 ON T1.ID = T2.UserID 
			LEFT JOIN (
			select 
				T3.UserID,T3.PhoneNumber 
			from 
				[PHONE] T3  
			WHERE 
				T3.ID IN (
					select
						MIN(T4.ID) 
					FROM 
						[PHONE] T4 
					WHERE 
						T4.Available = 1 
					GROUP BY 
						T4.UserID)) T5 ON T2.UserID = T5.UserID 
		LEFT JOIN (
			select 
				T6.UserID,
				T6.Address 
			from 
				[ADDRESS] T6  
			WHERE 
				T6.ID IN (
					select 
						MIN(T7.ID)
					FROM 
						[ADDRESS] T7 
					WHERE 
						T7.Available = 1 
					GROUP BY T7.UserID)) T8 ON T2.UserID = T8.UserID 
		LEFT JOIN [BRANCH] T9 ON T2.BranchID = T9.ID 
		LEFT JOIN [BRANCH] T11 ON T11.ID = @BranchID
		LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T12 ON T2.SourceType = T12.ID 
		LEFT JOIN (
			select 
				sum(TotalSalePrice - UnPaidPrice - RefundSumAmount) TotalSale,
				CustomerID 
			from 
			[ORDER] 
			where 
				(@BeginDay is null or [ORDER].OrderTime >= @BeginDay) and (@EndDay is null or [ORDER].OrderTime <= @EndDay) 
			group by 
				CustomerID) T13 ON T13.CustomerID = T2.USERID   
		INNER JOIN [RELATIONSHIP] T10 ON T2.UserID = T10.CustomerID AND T10.Available = 1 AND T10.BranchID = @BranchID
		WHERE 
			T1.UserType = 0 AND T1.CompanyID =@CompanyID AND T2.Available = 1 
		ORDER BY 
			T2.USERID
		end
	else
		begin
			select 
				DISTINCT T2.UserID,    --NO
				T2.Name,           --姓名
				T2.Title,          --称谓
				T5.PhoneNumber ,   --电话
				T8.Address,        --地址
				T1.LoginMobile,    --会员登录手机号
				[dbo].[FN_getGender](T2.Gender) Gender,  ----性别
			CONVERT(varchar(10), T2.BirthDay, 111) BirthDay,   --出生年月
			[dbo].[FN_getHeightOrWeight](T2.Height) Height,  ----身高
			[dbo].[FN_getHeightOrWeight](T2.Weight) Weight,  ----体重
			T2.BloodType,              --血型
			[dbo].[FN_getMarriage](T2.Marriage) Marriage ,   ----婚姻状态
			T2.Profession,             --职业
			T9.BranchName,             --入会门店
			CONVERT(varchar(10), T2.CreateTime, 111) CreateTime,   --入会日期
			T2.Remark,                 --备注
			[dbo].[FN_getRegistFrom](T2.RegistFrom) RegistFrom,    -----顾客来源
			T12.Name AS SourceTypeName,--注册端口
			'' AS LastVisit,           --最后访问时间
			ISNULL(T13.TotalSale,0) AS TotalSale,     --消费总额
			0 as IsRed,
			ISNULL(T11.LostRemind,0) LostRemind
                                    
			from 
				[USER] T1 
				INNER JOIN [CUSTOMER] T2 ON T1.ID = T2.UserID 
				LEFT JOIN (
				select 
					T3.UserID,T3.PhoneNumber 
				from 
					[PHONE] T3  
				WHERE 
					T3.ID IN (
						select
							MIN(T4.ID) 
						FROM 
							[PHONE] T4 
						WHERE 
							T4.Available = 1 
						GROUP BY 
							T4.UserID)) T5 ON T2.UserID = T5.UserID 
			LEFT JOIN (
				select 
					T6.UserID,
					T6.Address 
				from 
					[ADDRESS] T6  
				WHERE 
					T6.ID IN (
						select 
							MIN(T7.ID)
						FROM 
							[ADDRESS] T7 
						WHERE 
							T7.Available = 1 
						GROUP BY T7.UserID)) T8 ON T2.UserID = T8.UserID 
			LEFT JOIN [BRANCH] T9 ON T2.BranchID = T9.ID 
			LEFT JOIN [BRANCH] T11 ON T11.ID = @BranchID
			LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T12 ON T2.SourceType = T12.ID 
			LEFT JOIN (
				select 
					sum(TotalSalePrice - UnPaidPrice - RefundSumAmount) TotalSale,
					CustomerID from [ORDER] 
				where 
					(@BeginDay is null or [ORDER].OrderTime >= @BeginDay) and (@EndDay is null or [ORDER].OrderTime <= @EndDay) 
				group by CustomerID) T13 ON T13.CustomerID = T2.USERID

		end
END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end