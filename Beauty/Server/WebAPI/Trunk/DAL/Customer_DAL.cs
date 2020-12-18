using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;

namespace WebAPI.DAL
{
    public class Customer_DAL
    {
        #region 构造类实例
        public static Customer_DAL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly Customer_DAL instance = new Customer_DAL();
        }
        #endregion

        /// <summary>
        /// 二维码显示顾客信息
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>     
        public ObjectResult<CustomerInfoByQRCode_Model> getCustomerInfoByQRCode(string companyCode, int branchId, long customerId, int accountId)
        {
            ObjectResult<CustomerInfoByQRCode_Model> result = new ObjectResult<CustomerInfoByQRCode_Model>();
            result.Code = "-3";
            result.Message = "二维码查看用户信息失败";

            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"
                                            WITH   SunRelationship ( CustomerID, IsMyCustomer )
              AS ( SELECT   a.CustomerID ,
                            CASE WHEN SUM(IsMyCustomer) > 0 THEN 1
                                 ELSE 0
                            END IsMyCustomer
                   FROM     ( SELECT    CASE WHEN ( ( T1.AccountID = @AccountID
                                                      AND BranchID = @BranchID
                                                    )
                                                    OR ( T1.AccountID IN (
                                                         SELECT
                                                              fn_CustomerNamesInRegion.SubordinateID
                                                         FROM fn_CustomerNamesInRegion(@AccountID,
                                                              @BranchID) ) )
                                                    AND BranchID = @BranchID
                                                  ) THEN 1
                                             ELSE 0
                                        END IsMyCustomer ,
                                        CustomerID
                              FROM      dbo.RELATIONSHIP T1
                              WHERE     T1.Available = 1
                            ) AS a
                   GROUP BY a.CustomerID
                 )
        SELECT  T6.IsMyCustomer ,
                T1.UserID CustomerID ,
                T1.Name CustomerName ,
                T2.Discount, 
                {0}{1}{2}{3}  + cast(T1.CompanyID as nvarchar(10)) + {4}/{5}{6}  + cast(T1.UserID as nvarchar(10)) + '/'+ T1.HeadImageFile + {7} HeadImageURL 
        FROM    CUSTOMER T1
                LEFT JOIN LEVEL T2 ON T1.LevelID = T2.ID
                INNER JOIN COMPANY T3 ON T3.ID = T1.CompanyID
                LEFT JOIN SunRelationship T6 ON T6.CustomerID = T1.UserID
        WHERE   T1.UserID = @CustomerID
                AND T3.CompanyCode = @CompanyCode
                AND T1.Available = 1 ";

                strSqlCommand = string.Format(strSqlCommand, Common.Const.strHttp,
                    Common.Const.server,
                    Common.Const.strMothod,
                    Common.Const.strSingleMark,
                    Common.Const.strSingleMark,
                    Common.Const.strImageObjectType0,
                    Common.Const.strSingleMark,
                    Common.Const.strThumb);

                CustomerInfoByQRCode_Model model = new CustomerInfoByQRCode_Model();
                db.SetCommand(strSqlCommand, db.Parameter("@AccountID", accountId, DbType.Int32),
                db.Parameter("@CustomerID", customerId, DbType.Int64),
                db.Parameter("@BranchID", branchId, DbType.Int32),
                db.Parameter("@CompanyCode", companyCode, DbType.String),
                db.Parameter("@ImageHeight", "160", DbType.String),
                db.Parameter("@ImageWidth", "160", DbType.String)).ExecuteObject(model);

                if (model.CustomerID != 0)
                {
                    result.Code = "1";
                    result.Message = "";
                    model.Discount = model.Discount == 0 ? 1 : model.Discount;
                    result.Data = model;
                }
            }

            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="accountId"></param>
        /// <param name="imageWidth"></param>
        /// <param name="imageHeight"></param>
        /// <param name="type"></param>
        /// <param name="CardCode"></param>
        /// <param name="sourceType"></param>
        /// <param name="AccountIDList"></param>
        /// <param name="RegistFrom"></param>
        /// <param name="FirstVisitType"></param>
        /// <param name="FirstVisitDateTime"></param>
        /// <param name="EffectiveCustomerType"></param>
        /// <param name="pageFlg"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="customerName"></param>
        /// <param name="customerTel"></param>
        /// <param name="searchDateTime"></param>
        /// <returns></returns>
        public ObjectResultSup<List<CustomerList_Model>> GetCustomerList(
            int companyId, int branchId, int accountId, 
            int imageWidth, int imageHeight, 
            int type, string CardCode, int sourceType, 
            List<int> AccountIDList, int RegistFrom, int FirstVisitType, 
            string FirstVisitDateTime,int EffectiveCustomerType,
            bool pageFlg, int pageIndex, int pageSize,
            string customerName, string customerTel, string searchDateTime
            )
        { 
            ObjectResultSup<List<CustomerList_Model>> result = new ObjectResultSup<List<CustomerList_Model>>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            result.DataCnt = 0;

            UserRole_Model roleModel = Account_DAL.Instance.getUserRole_2_2(accountId);

            string cardCodeSql = @" LEFT JOIN [TBL_CUSTOMER_CARD] T13 ON T13.UserID=T1.UserID 
                                    LEFT JOIN [MST_CARD] T14 ON T14.ID=T13.CardID ";

            //            //是否显示LoginMobile
            //            //与我相关的顾客  则不用查看权限
            //            //不是我相关的顾客  需要 查看顾客信息 的权限
            //            string strSqlLoginMobile = "T4.LoginMobile,";
            //            if (type != 0)
            //            {
            //                if (!roleModel.Jurisdictions.Contains("|3|") && roleModel.RoleID != -1)
            //                {
            //                    strSqlLoginMobile = @"CASE WHEN LEN(T4.LoginMobile)>4 AND ISNULL(T10.IsMyCustomer,0) = 0 THEN  
            //                          REPLICATE('*',LEN(T4.LoginMobile)-4) +RIGHT(T4.LoginMobile,4) ELSE T4.LoginMobile END LoginMobile, ";
            //                }
            //            }

            string strSqlLoginMobile = @"
                    CASE 
                        WHEN LEN(T4.LoginMobile) > 4 THEN REPLICATE('*', LEN(T4.LoginMobile) - 4) + RIGHT(T4.LoginMobile, 4) 
                        ELSE T4.LoginMobile 
                    END LoginMobile ,";

            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                StringBuilder strSqlSelectItem = new StringBuilder();
                string strSqlWith ="";
                string orderBy = " Order By CustomerName";
                if (type == 0)
                {
                    #region 查看与我相关的顾客
                    //                        strSql.Append(@" 
                    //               WITH SunRelationship(CustomerID,IsMyCustomer)  AS
                    //             (  SELECT  a.CustomerID,CASE WHEN SUM(IsMyCustomer)>0 THEN 1 ELSE 0 END   IsMyCustomer from  ( SELECT   CASE WHEN ( (T1.AccountID = @AccountID AND BranchID = @BranchID)
                    //               OR (T1.AccountID IN(
                    //								SELECT subQuery.SubordinateID
                    //								FROM   subQuery)
                    //								) AND BranchID =@BranchID) THEN 1 ELSE 0 END IsMyCustomer,CustomerID
                    //               FROM     dbo.RELATIONSHIP T1
                    //               WHERE    T1.Available = 1
                    //             AND CompanyID = @CompanyID )AS a GROUP BY a.CustomerID ) ");

                    strSqlSelectItem.Append(" select distinct  1 IsMyCustomer,T1.UserID CustomerID,T1.Name CustomerName, T4.LoginMobile,T9.Phone,T1.PinYin,T1.SourceType,T20.ComeTime,{0}");
                    strSqlSelectItem.Append(Common.Const.strHttp);
                    strSqlSelectItem.Append(Common.Const.server);
                    strSqlSelectItem.Append(Common.Const.strMothod);
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("/");
                    strSqlSelectItem.Append(Common.Const.strImageObjectType0);
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                    strSqlSelectItem.Append(Common.Const.strThumb);
                    strSqlSelectItem.Append(" HeadImageURL  ");

                    strSql.Append(" FROM CUSTOMER T1 ");
                    strSql.Append(" Inner join RELATIONSHIP T2 on T1.UserID = T2.CustomerID ");
                    strSql.Append(" {1} ");
                    strSql.Append(" left join [USER] T4 on T4.ID = T1.UserID");
                    strSql.Append(" left join [RELATIONSHIP] T5 on T5.CustomerID =  T1.UserID and T5.BranchID=@BranchID ");
                    strSql.Append(" LEFT JOIN ( select CustomerID,ID,Balance from BALANCE a where ID =(SELECT MAX(ID) FROM    BALANCE WHERE   CustomerID = a.CustomerID AND Available = 1) ) t6 ON T1.UserID=t6.CustomerID  ");
                    strSql.Append(@" left join ( SELECT CustomerPhone.userid,LEFT(StuList,LEN(StuList)-1) as Phone FROM (
                            SELECT T8.UserID,
                            (SELECT PhoneNumber+'|' FROM PHONE T7
                              WHERE T7.userid=T8.userid and T7.Available = 1
                              FOR XML PATH('')) AS StuList
                            FROM PHONE T8
                            GROUP BY T8.UserID
                            ) CustomerPhone ) T9 ON T9.UserID = T1.UserID ");

                    strSql.Append(@" LEFT JOIN (SELECT T21.CustomerID,MAX(T21.ComeTime) ComeTime
                                     FROM(select CustomerID, convert(varchar(10), max(tglasttime), 120) AS ComeTime from TBL_ORDER_SERVICE 
                                     WHERE CompanyID = @CompanyID AND BranchID = @BranchID 
                                     group by CustomerID
                                     UNION
                                     select CustomerID, convert(varchar(10), max(OrderTime), 120) as ComeTime from [order] 
                                     WHERE CompanyID = @CompanyID AND BranchID = @BranchID 
                                     group by CustomerID)  T21 GROUP BY T21.CustomerID) T20 ON T1.UserID = T20.CustomerID ");

                    if (sourceType > -1)
                    {
                        strSql.Append(" LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T10 WITH(NOLOCK) ON T1.[SourceType]=T10.ID AND T10.CompanyID=@CompanyID ");
                    }
                    if (AccountIDList == null || AccountIDList.Count <= 0)
                    {
                        strSql.Append(" Where(T2.AccountID in( select SubordinateID from fn_CustomerNamesInRegion(@AccountID,@BranchID)) OR T2.AccountID=@AccountID ) ");
                    }
                    else
                    {
                        if (AccountIDList != null && AccountIDList.Count > 0)
                        {
                            strSql.Append(" Where T2.AccountID in(");
                            for (int i = 0; i < AccountIDList.Count; i++)
                            {
                                if (i == 0)
                                {
                                    strSql.Append(AccountIDList[i].ToString());
                                }
                                else
                                {
                                    strSql.Append("," + AccountIDList[i].ToString());
                                }
                            }
                            strSql.Append(" ) ");
                        }
                        
                    }
                    strSql.Append(" and T2.Available = 1 and T1.Available = 1 and T5.Available = 1 ");

                    #endregion
                }
                else if (type == 2)
                {
                    #region 查看分店所有
                    strSqlWith = @" 
                                     WITH  SunRelationship(CustomerID,IsMyCustomer)  AS
                                     (  SELECT  a.CustomerID,CASE WHEN SUM(IsMyCustomer)>0 THEN 1 ELSE 0 END   IsMyCustomer from  ( SELECT   CASE WHEN ( (T1.AccountID = @AccountID AND BranchID = @BranchID)
                                       OR (T1.AccountID IN(
								                        SELECT fn_CustomerNamesInRegion.SubordinateID
								                        FROM   fn_CustomerNamesInRegion(@AccountID,@BranchID))
								                        ) AND BranchID =@BranchID) THEN 1 ELSE 0 END IsMyCustomer,CustomerID
                                       FROM     dbo.RELATIONSHIP T1
                                       WHERE    T1.Available = 1
                                     AND CompanyID = @CompanyID )AS a GROUP BY a.CustomerID ) ";
                    strSqlSelectItem.Append(" select distinct T1.UserID CustomerID,T1.Name CustomerName ,T4.LoginMobile Phone,T1.PinYin,T1.SourceType,T20.ComeTime,{0}");
                    strSqlSelectItem.Append("ISNULL(T10.IsMyCustomer,0) IsMyCustomer,");
                    strSqlSelectItem.Append(Common.Const.strHttp);
                    strSqlSelectItem.Append(Common.Const.server);
                    strSqlSelectItem.Append(Common.Const.strMothod);
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("/");
                    strSqlSelectItem.Append(Common.Const.strImageObjectType0);
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                    strSqlSelectItem.Append(Common.Const.strThumb);
                    strSqlSelectItem.Append(" HeadImageURL  ");
                    strSqlSelectItem.Append(" FROM CUSTOMER T1 ");

                    strSql.Append(" {1} ");
                    strSql.Append(" left join [USER] T4 on T4.ID = T1.UserID");
                    //strSql.Append(" left join [RELATIONSHIP] T5 on T5.CustomerID =  T1.UserID and T5.BranchID=@BranchID ");
                    strSql.Append(" LEFT JOIN ( select CustomerID,ID,Balance from BALANCE a where ID =(SELECT MAX(ID) FROM    BALANCE WHERE   CustomerID = a.CustomerID AND Available = 1) ) t6 ON T1.UserID=t6.CustomerID ");
//                    strSql.Append(@" left join ( SELECT CustomerPhone.userid,LEFT(StuList,LEN(StuList)-1) as Phone FROM (
//                            SELECT UserID,
//                            (SELECT PhoneNumber+'|' FROM PHONE T7
//                              WHERE T7.userid=T8.userid and T7.Available = 1
//                              FOR XML PATH('')) AS StuList
//                            FROM PHONE T8
//                            GROUP BY T8.UserID
//                            ) CustomerPhone ) T9 ON T9.UserID = T1.UserID ");
                    strSql.Append(" left join [SunRelationship] T10 on T10.CustomerID =  T1.UserID ");

                    strSql.Append(@" LEFT JOIN (SELECT T21.CustomerID,MAX(T21.ComeTime) ComeTime
                                     FROM(select CustomerID, convert(varchar(10), max(tglasttime), 120) AS ComeTime from TBL_ORDER_SERVICE 
                                     WHERE CompanyID = @CompanyID AND BranchID = @BranchID 
                                     group by CustomerID
                                     UNION
                                     select CustomerID, convert(varchar(10), max(OrderTime), 120) as ComeTime from [order] 
                                     WHERE CompanyID = @CompanyID AND BranchID = @BranchID 
                                     group by CustomerID)  T21 GROUP BY T21.CustomerID) T20 ON T1.UserID = T20.CustomerID");

                    if (sourceType > -1)
                    {
                        strSql.Append(" LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T11 WITH(NOLOCK) ON T1.[SourceType]=T11.ID AND T11.CompanyID=@CompanyID ");
                    }
                    //strSql.Append(" Where T1.BranchID = @BranchID ");
                    strSql.Append(" Where T1.CompanyID=@CompanyID");
                    strSql.Append(" and T1.Available = 1 and T1.BranchID = @BranchID");//门店从Customer表来筛选

                    #endregion
                }
                else if (type == 1)
                {
                    #region 查看公司所有
                    strSqlWith = @" 
                                  WITH SunRelationship(CustomerID,IsMyCustomer)  AS
                                 (  SELECT  a.CustomerID,CASE WHEN SUM(IsMyCustomer)>0 THEN 1 ELSE 0 END   IsMyCustomer from  ( SELECT   CASE WHEN ( (T1.AccountID = @AccountID AND BranchID = @BranchID)
                                   OR (T1.AccountID IN(
								                    SELECT fn_CustomerNamesInRegion.SubordinateID
								                    FROM   fn_CustomerNamesInRegion(@AccountID,@BranchID)) 
								                    ) AND BranchID =@BranchID) THEN 1 ELSE 0 END IsMyCustomer,CustomerID 
                                   FROM     dbo.RELATIONSHIP T1 
                                   WHERE    T1.Available = 1 
                                 AND CompanyID = @CompanyID )AS a GROUP BY a.CustomerID ) ";

                    //strSqlSelectItem.Append(" select T1.UserID CustomerID,T1.Name CustomerName ,T4.LoginMobile Phone,T4.LoginMobile,T1.PinYin,T1.SourceType,T20.ComeTime,{0}");
                    strSqlSelectItem.Append(" select T1.UserID CustomerID,T1.Name CustomerName ,T4.LoginMobile Phone,T1.PinYin,T1.SourceType,T20.ComeTime,{0}");
                    strSqlSelectItem.Append(" ISNULL(T10.IsMyCustomer,0) IsMyCustomer,");
                    strSqlSelectItem.Append(Common.Const.strHttp);
                    strSqlSelectItem.Append(Common.Const.server);
                    strSqlSelectItem.Append(Common.Const.strMothod);
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("/");
                    strSqlSelectItem.Append(Common.Const.strImageObjectType0);
                    strSqlSelectItem.Append(Common.Const.strSingleMark);
                    strSqlSelectItem.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                    strSqlSelectItem.Append(Common.Const.strThumb);
                    strSqlSelectItem.Append(" HeadImageURL  ");


                    strSql.Append(" FROM CUSTOMER T1 ");
                    strSql.Append(" {1} ");
                    strSql.Append(" left join [USER] T4 on T4.ID = T1.UserID");
                    strSql.Append(" left join [SunRelationship] T10 on T10.CustomerID =  T1.UserID ");
                    strSql.Append(" LEFT JOIN ( select CustomerID,ID,Balance from BALANCE a where ID =(SELECT MAX(ID) FROM    BALANCE WHERE   CustomerID = a.CustomerID AND Available = 1 ) ) t6 ON T1.UserID=t6.CustomerID ");
                    //                    strSql.Append(@" left join ( SELECT CustomerPhone.userid,LEFT(StuList,LEN(StuList)-1) as Phone FROM (
                    //                            SELECT UserID,
                    //                            (SELECT PhoneNumber+'|' FROM PHONE T7
                    //                              WHERE T7.userid=T8.userid and T7.Available = 1
                    //                              FOR XML PATH('')) AS StuList
                    //                            FROM PHONE T8
                    //                            GROUP BY T8.UserID
                    //                            ) CustomerPhone ) T9 ON T9.UserID = T1.UserID ");
                    strSql.Append(@" LEFT JOIN (SELECT T21.CustomerID,MAX(T21.ComeTime) ComeTime
                                     FROM(select CustomerID, convert(varchar(10), max(tglasttime), 120) AS ComeTime from TBL_ORDER_SERVICE 
                                     WHERE CompanyID = @CompanyID 
                                     group by CustomerID
                                     UNION
                                     select CustomerID, convert(varchar(10), max(OrderTime), 120) as ComeTime from [order] 
                                     WHERE CompanyID = @CompanyID 
                                     group by CustomerID)  T21 GROUP BY T21.CustomerID) T20 ON T1.UserID = T20.CustomerID");
                    if (sourceType > -1)
                    {
                        strSql.Append(" LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T11 WITH(NOLOCK) ON T1.[SourceType]=T11.ID AND T11.CompanyID=@CompanyID ");
                    }
                    strSql.Append(" Where T1.CompanyID = @CompanyID");
                    strSql.Append(" and T1.Available = 1   ");

                    // 顾客
                    if (!string.IsNullOrWhiteSpace(customerName))
                    {
                        strSql.Append(" and T1.Name like '%' + @CustomerName + '%'");
                    }

                    // 电话
                    if (!string.IsNullOrWhiteSpace(customerTel))
                    {
                        strSql.Append(" and T4.LoginMobile like '%' + @CustomerTel + '%'");
                    }


                    #endregion
                }

                if (string.IsNullOrWhiteSpace(CardCode))
                {
                    cardCodeSql = "";
                }
                else
                {
                    strSql.Append(" And T14.CardCode=@CardCode ");
                }

                if (sourceType > -1)
                {
                    strSql.Append(" And ISNULL(T1.SourceType,0)=@SourceType ");
                }

                if (RegistFrom > -1)
                {
                    strSql.Append(" AND T1.RegistFrom =@RegistFrom ");
                }
                
                //首次上门判断
                if (FirstVisitType == 1) {//系统时间当日
                    FirstVisitDateTime = DateTime.Now.ToString("yyyy-MM-dd");
                }
                if (FirstVisitType > 0)
                {//系统时间当日
                    strSql.Append(" AND CONVERT(varchar(10), T1.CreateTime, 120) =@CreateTime ");
                }

                string DateTimeCurrentValue = "";
                //有效无效上门过滤
                if (EffectiveCustomerType > 0) {
                    DateTimeCurrentValue = DateTime.Now.ToString("yyyy-MM-dd");
                }
                if (EffectiveCustomerType == 1) {//有效上门包含当日
                    strSql.Append(" AND T1.CreateTime IS NOT NULL AND T20.ComeTime IS NOT NULL AND DATEDIFF(DAY, T20.ComeTime, @ComeTime) <= 360");
                }
                if (EffectiveCustomerType == 2)//无效上门不包含当日
                {
                    strSql.Append(" AND ((T1.CreateTime IS NOT NULL AND T20.ComeTime IS NOT NULL AND DATEDIFF(DAY, T20.ComeTime,  @ComeTime) > 360) OR (T1.CreateTime IS NOT NULL AND T20.ComeTime IS  NULL))");
                }
                
                //分页时解决传统分页数据变更时查询数据差异问题
                if (pageFlg)
                {
                    if (searchDateTime != null)
                    {
                        strSql.Append(" AND T1.CreateTime <= convert(datetime2, @SearchDateTime)");
                    }
                }

                String strSqlCommand;
                //string strSqlCommand = string.Format(strSql.ToString(), strSqlLoginMobile, cardCodeSql);

                List<CustomerList_Model> list = new List<CustomerList_Model>();
                if (pageFlg)
                {
                    // 总记录数
                    StringBuilder strSqlCommandCnt = new StringBuilder();
                    strSqlCommandCnt.Append(strSqlWith);
                    strSqlCommandCnt.Append("select count({0}) ");
                    strSqlCommandCnt.Append(strSql);
                    strSqlCommand = string.Format(strSqlCommandCnt.ToString(), 1, cardCodeSql);

                    db.SetCommand(strSqlCommand,
                    db.Parameter("@AccountID", accountId, DbType.Int32),
                    db.Parameter("@ImageHeight", imageHeight, DbType.String),
                    db.Parameter("@ImageWidth", imageWidth, DbType.String),
                    db.Parameter("@CardCode", CardCode, DbType.String),
                    db.Parameter("@CompanyID", companyId, DbType.Int32),
                    db.Parameter("@BranchID", branchId, DbType.Int32),
                    db.Parameter("@RegistFrom", RegistFrom, DbType.Int16),
                    db.Parameter("@CreateTime", FirstVisitDateTime, DbType.String),
                    db.Parameter("@ComeTime", DateTimeCurrentValue, DbType.String),
                    db.Parameter("@SourceType", sourceType, DbType.Int32),
                    db.Parameter("@CustomerName", customerName, DbType.String),
                    db.Parameter("@CustomerTel", customerTel, DbType.String),
                    db.Parameter("@SearchDateTime", searchDateTime, DbType.String)
                    );
                    result.DataCnt = db.ExecuteScalar<int>();

                    // 分页数据
                    StringBuilder strSqlCommandPage = new StringBuilder();
                    strSqlCommandPage.Append(strSqlWith);
                    strSqlCommandPage.Append(" select R2.* from ");
                    strSqlCommandPage.Append(" (");
                    strSqlCommandPage.Append(" select ROW_NUMBER() over (" + orderBy + ") AS RowNumber , R1.*");
                    strSqlCommandPage.Append(" from");
                    strSqlCommandPage.Append(" (");
                    strSqlCommandPage.Append(strSqlSelectItem);
                    strSqlCommandPage.Append(strSql);
                    strSqlCommandPage.Append(" ) R1");
                    strSqlCommandPage.Append(" ) R2");
                    strSqlCommandPage.Append(" where R2.RowNumber between @StartPos and @EndPos");
                    strSqlCommandPage.Append(orderBy);
                    strSqlCommand = string.Format(strSqlCommandPage.ToString(), strSqlLoginMobile, cardCodeSql);

                    db.SetCommand(strSqlCommand,
                    db.Parameter("@AccountID", accountId, DbType.Int32),
                    db.Parameter("@ImageHeight", imageHeight, DbType.String),
                    db.Parameter("@ImageWidth", imageWidth, DbType.String),
                    db.Parameter("@CardCode", CardCode, DbType.String),
                    db.Parameter("@CompanyID", companyId, DbType.Int32),
                    db.Parameter("@BranchID", branchId, DbType.Int32),
                    db.Parameter("@RegistFrom", RegistFrom, DbType.Int16),
                    db.Parameter("@CreateTime", FirstVisitDateTime, DbType.String),
                    db.Parameter("@ComeTime", DateTimeCurrentValue, DbType.String),
                    db.Parameter("@SourceType", sourceType, DbType.Int32),
                    db.Parameter("@CustomerName", customerName, DbType.String),
                    db.Parameter("@CustomerTel", customerTel, DbType.String),
                    db.Parameter("@SearchDateTime", searchDateTime, DbType.String),
                    db.Parameter("@StartPos", (pageIndex - 1) * pageSize + 1, DbType.Int32),
                    db.Parameter("@EndPos", pageIndex * pageSize, DbType.Int32)
                    );
                    list = db.ExecuteList<CustomerList_Model>();
                }
                else
                {
                    StringBuilder strSqlCommandNoPage = new StringBuilder();
                    strSqlCommandNoPage.Append(strSqlWith);
                    strSqlCommandNoPage.Append(strSqlSelectItem);
                    strSqlCommandNoPage.Append(strSql);
                    strSqlCommandNoPage.Append(orderBy);
                    strSqlCommand = string.Format(strSqlCommandNoPage.ToString(), strSqlLoginMobile, cardCodeSql);

                    string tmp = strSqlCommand.Replace("@AccountID", accountId + "")
                        .Replace("@ImageHeight", "'" + imageHeight + "'")
                        .Replace("@ImageWidth", "'" + imageWidth + "'")
                        .Replace("@CardCode", "'" + CardCode + "'")
                        .Replace("@CompanyID", companyId + "")
                        .Replace("@BranchID", branchId + "")
                        .Replace("@RegistFrom", RegistFrom + "")
                        .Replace("@CreateTime", "'" + FirstVisitDateTime + "'")
                        .Replace("@ComeTime", "'" + DateTimeCurrentValue + "'")
                        .Replace("@SourceType", sourceType + "");

                    list = db.SetCommand(strSqlCommand,
                    db.Parameter("@AccountID", accountId, DbType.Int32),
                    db.Parameter("@ImageHeight", imageHeight, DbType.String),
                    db.Parameter("@ImageWidth", imageWidth, DbType.String),
                    db.Parameter("@CardCode", CardCode, DbType.String),
                    db.Parameter("@CompanyID", companyId, DbType.Int32),
                    db.Parameter("@BranchID", branchId, DbType.Int32),
                    db.Parameter("@RegistFrom", RegistFrom, DbType.Int16),
                    db.Parameter("@CreateTime", FirstVisitDateTime, DbType.String),
                    db.Parameter("@ComeTime", DateTimeCurrentValue, DbType.String),
                    db.Parameter("@SourceType", sourceType, DbType.Int32)
                    ).ExecuteList<CustomerList_Model>();
                    result.DataCnt = list.Count;
                }
                
                result.Code = "1";
                result.Message = "";
                result.Data = list;
            }

            

            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="customerID"></param>
        /// <param name="expirationDate"></param>
        /// <returns></returns>
        public bool UpdateExpirationDateByCustomer(int companyID, int UpdaterID, int customerID, DateTime expirationDate)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlHistoryUser = " INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE CompanyID=@CompanyID AND UserID=@UserID ";
                int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                          , db.Parameter("@UserID", customerID, DbType.Int32)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @"UPDATE [CUSTOMER] SET ExpirationDate=@ExpirationDate,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE CompanyID=@CompanyID AND UserID=@UserID";
                int res = db.SetCommand(strSql, db.Parameter("@ExpirationDate", expirationDate, DbType.Date),
                                                db.Parameter("@CompanyID", companyID, DbType.Int32),
                                                db.Parameter("@UpdaterID", UpdaterID, DbType.Int32),
                                                db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.Int32),
                                                db.Parameter("@UserID", customerID, DbType.Int32)).ExecuteNonQuery();
                if (res <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="customerID"></param>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public bool IsExistResponsiblePersonID(int customerID, int companyID, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT TOP 1 ISNULL(AccountID,0) AS ResponsiblePersonID FROM [RELATIONSHIP] WHERE CompanyID=@CompanyID AND BranchID=@BranchID AND CustomerID=@CustomerID AND Available=1";
                int res = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32),
                                                db.Parameter("@BranchID", branchID, DbType.Int32),
                                                db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteScalar<int>();
                if (res <= 0)
                {
                    return false;
                }
                return true;

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="accountID"></param>
        /// <param name="customerID"></param>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="creatorID"></param>
        /// <returns></returns>
        public bool AddResponsiblePersonID(int accountID, int customerID, int companyID, int branchID, int creatorID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"INSERT INTO [RELATIONSHIP](CompanyID,AccountID,CustomerID,Available,CreatorID,CreateTime,BranchID,Type)
                                        VALUES(@CompanyID,@AccountID,@CustomerID,@Available,@CreatorID,@CreateTime,@BranchID,1)";
                int res = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32),
                                                db.Parameter("@AccountID", accountID, DbType.Int32),
                                                db.Parameter("@CustomerID", customerID, DbType.Int32),
                                                db.Parameter("@Available", 1, DbType.Boolean),
                                                db.Parameter("@CreatorID", creatorID, DbType.Int32),
                                                db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime),
                                                db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteNonQuery();
                if (res <= 0)
                {
                    return false;
                }
                return true;

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public bool IsExistCustomerName(int companyID, string name)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT TOP 1 UserID FROM [CUSTOMER] WHERE Name=@Name AND CompanyID=@CompanyID";
                int res = db.SetCommand(strSql, db.Parameter("@Name", name, DbType.String),
                                                db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();
                if (res <= 0)
                {
                    return false;
                }
                return true;

            }
        }

        public bool IsExistCustomer(string loginMobile)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  COUNT(0)
                                  FROM    [USER] T1
                                          INNER JOIN dbo.CUSTOMER T2 ON T1.ID = T2.UserID
                                  WHERE   T1.LoginMobile = @LoginMobile
                                          AND T2.Available = 1";
                int res = db.SetCommand(strSql, db.Parameter("@LoginMobile", loginMobile, DbType.String)).ExecuteScalar<int>();
                if (res <= 0)
                {
                    return false;
                }
                return true;
            }

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="phonenumber"></param>
        /// <returns></returns>
        public string IsExistCustomerPhone(int companyID, string phonenumber)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT TOP 1 PhoneNumber FROM [PHONE] WHERE PhoneNumber=@PhoneNumber AND CompanyID=@CompanyID AND Type=0";
                string res = db.SetCommand(strSql, db.Parameter("@PhoneNumber", phonenumber, DbType.String),
                                                db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<string>();

                return res;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public CustomerAdd_Model customerAdd(CustomerAddOperation_Model model)
        {
            CustomerAdd_Model res = new CustomerAdd_Model();

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string strSqlUserAdd = @"insert into [USER](CompanyID,UserType, Password, Loginmobile ) 
                                                            Values(@CompanyID,@UserType, @password, @loginMobile);select @@IDENTITY";


                    int userID = db.SetCommand(strSqlUserAdd,
                                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                            db.Parameter("@UserType", 0, DbType.Int32),
                                            db.Parameter("@Password", model.PasswordFlag ? Common.DEncrypt.DEncrypt.Encrypt(model.Password) : (object)DBNull.Value, DbType.String),
                                            db.Parameter("@LoginMobile", model.isLoginMobileFlag ? model.LoginMobile : (object)DBNull.Value, DbType.String)).ExecuteScalar<int>();
                    if (userID <= 0)
                    {
                        db.RollbackTransaction();
                        return null;
                    }

                    string strSqlCusAdd = @"insert into CUSTOMER(CompanyID,BranchID,UserID,Name,Title,Available,CreatorID,CreateTime,LevelID,HeadImageFile,PinYin,RegistFrom,Gender,SourceType) 
                                                            values (@CompanyID,@BranchID,@UserID,@Name,@Title,@Available,@CreatorID,@CreateTime,@LevelID,@FileName,@PinYin,@RegistFrom,@Gender,@SourceType)";
                    int cusAddRes = db.SetCommand(strSqlCusAdd,
                                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                            db.Parameter("@UserID", userID, DbType.Int32),
                                            db.Parameter("@Name", model.CustomerName, DbType.String),
                                            db.Parameter("@Title", model.Title, DbType.String),
                                            db.Parameter("@Available", true, DbType.Boolean),
                                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime),
                                            db.Parameter("@LevelID", model.LevelID == 0 ? (object)DBNull.Value : model.LevelID, DbType.Int32),
                                            db.Parameter("@FileName", model.FileName, DbType.String),
                                            db.Parameter("@PinYin", model.PinYin, DbType.String),
                                            db.Parameter("@RegistFrom", model.IsPast ? 1 : 0, DbType.Int16),
                                            db.Parameter("@Gender", model.Gender, DbType.Int32),
                                            db.Parameter("@SourceType", model.SourceType, DbType.Int32)).ExecuteNonQuery();
                    if (cusAddRes <= 0)
                    {
                        db.RollbackTransaction();
                        return null;
                    }

                    #region 为客户添加卡

                    //                    string strAddMSTCard = @"INSERT INTO dbo.MST_CARD( CompanyID ,CardCode ,CardTypeID ,CardName ,VaildPeriod ,ValidPeriodUnit ,StartAmount ,BalanceNotice ,Rate ,CardBranchType ,CardProductType ,Available ,CreatorID ,CreateTime ,PresentRate) 
                    //                                                VALUES ( @CompanyID ,@CardCode ,@CardTypeID ,@CardName ,@VaildPeriod ,@ValidPeriodUnit ,@StartAmount ,@BalanceNotice ,@Rate ,@CardBranchType ,@CardProductType ,@Available ,@CreatorID ,@CreateTime ,@PresentRate);select @@IDENTITY";

                    string strAddCustomerCardSql = @" INSERT	INTO dbo.TBL_CUSTOMER_CARD ( CompanyID ,BranchID ,UserID ,UserCardNo ,CardID ,Currency ,Balance ,CardCreatedDate ,CardExpiredDate ,CreatorID ,CreateTime) 
                                                        VALUES  (@CompanyID ,@BranchID ,@UserID ,@UserCardNo ,@CardID ,@Currency ,@Balance ,@CardCreatedDate ,@CardExpiredDate ,@CreatorID ,@CreateTime)";

                    #region 添加公司默认卡
                    if (model.CardID > 0)
                    {
                        string strSelCardSql = @" SELECT TOP 1  T1.ID AS CardID ,
                                        CASE T1.ValidPeriodUnit
                                          WHEN 1 THEN DATEADD(DD, -1, DATEADD(yy, T1.VaildPeriod, GETDATE()))
                                          WHEN 2 THEN DATEADD(DD, -1, DATEADD(mm, T1.VaildPeriod, GETDATE()))
                                          WHEN 3 THEN DATEADD(DD, -1, DATEADD(dd, T1.VaildPeriod, GETDATE()))
                                          ELSE GETDATE()
                                        END AS CardExpiredDate
                                FROM    [MST_CARD] T1 WITH ( NOLOCK ) 
                                WHERE   T1.CompanyID = @CompanyID AND T1.ID = @CardID AND T1.CardTypeID = 1 AND T1.Available = 1 ";
                        GetCompanyCardList_Model cardModel = db.SetCommand(strSelCardSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@CardID", model.CardID, DbType.Int32)).ExecuteObject<GetCompanyCardList_Model>();

                        long userCardNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "UserCardNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                        if (userCardNo <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }

                        int addRes = db.SetCommand(strAddCustomerCardSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@UserID", userID, DbType.Int32)
                                                        , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                                        , db.Parameter("@CardID", model.CardID, DbType.Int32)
                                                        , db.Parameter("@Currency", "CNY", DbType.String)
                                                        , db.Parameter("@Balance", 0, DbType.Int32)
                                                        , db.Parameter("@CardCreatedDate", model.CreateTime, DbType.DateTime)
                                                        , db.Parameter("@CardExpiredDate", cardModel.CardExpiredDate, DbType.DateTime)
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();
                        if (addRes <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }

                        string updateCustomerDefaultCardNoSql = "UPDATE [CUSTOMER] SET DefaultCardNo=@DefaultCardNo WHERE UserID=@UserID";

                        int updateRes = db.SetCommand(updateCustomerDefaultCardNoSql
                                      , db.Parameter("@DefaultCardNo", userCardNo.ToString(), DbType.String)
                                      , db.Parameter("@UserID", userID, DbType.Int32)).ExecuteNonQuery();

                        if (updateRes <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }
                    }
                    #endregion

                    #region 添加积分卡关系
                    string strSelPointCardSql = @" SELECT TOP 1  T1.ID AS CardID ,
                                        CASE T1.ValidPeriodUnit
                                          WHEN 1 THEN DATEADD(DD, -1, DATEADD(yy, T1.VaildPeriod, GETDATE()))
                                          WHEN 2 THEN DATEADD(DD, -1, DATEADD(mm, T1.VaildPeriod, GETDATE()))
                                          WHEN 3 THEN DATEADD(DD, -1, DATEADD(dd, T1.VaildPeriod, GETDATE()))
                                          ELSE GETDATE()
                                        END AS CardExpiredDate
                                FROM    [MST_CARD] T1 WITH ( NOLOCK ) 
                                WHERE   T1.CompanyID = @CompanyID 
                                        AND T1.CardTypeID=2 
                                        AND T1.Available = 1 ";
                    GetCompanyCardList_Model pointCardModel = db.SetCommand(strSelPointCardSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteObject<GetCompanyCardList_Model>();
                    if (pointCardModel != null)
                    {
                        #region 给用户关联积分卡
                        long pointUserCardNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "UserCardNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                        if (pointUserCardNo <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }

                        int addCustomerPointCardRes = db.SetCommand(strAddCustomerCardSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@UserID", userID, DbType.Int32)
                                                        , db.Parameter("@UserCardNo", pointUserCardNo, DbType.String)
                                                        , db.Parameter("@CardID", pointCardModel.CardID, DbType.Int32)
                                                        , db.Parameter("@Currency", "¥", DbType.String)
                                                        , db.Parameter("@Balance", 0, DbType.Int32)
                                                        , db.Parameter("@CardCreatedDate", model.CreateTime, DbType.DateTime)
                                                        , db.Parameter("@CardExpiredDate", pointCardModel.CardExpiredDate, DbType.DateTime)
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();
                        if (addCustomerPointCardRes <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }
                        #endregion

                        #region 没有积分卡 创建积分卡
                        //long pointCardCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CardCode", DbType.String)).ExecuteScalar<long>();

                        //if (pointCardCode <= 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return null;
                        //}

                        //int pointCardID = db.SetCommand(strAddMSTCard, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        //    , db.Parameter("@CardCode", pointCardCode, DbType.String)
                        //    , db.Parameter("@CardTypeID", 2, DbType.Int32)//积分卡
                        //    , db.Parameter("@CardName", "积分卡", DbType.String)
                        //    , db.Parameter("@VaildPeriod", 99, DbType.Int32)
                        //    , db.Parameter("@ValidPeriodUnit", 1, DbType.Int32)
                        //    , db.Parameter("@StartAmount", 0, DbType.Decimal)
                        //    , db.Parameter("@BalanceNotice", 0, DbType.Decimal)
                        //    , db.Parameter("@Rate", 1, DbType.Decimal)
                        //    , db.Parameter("@CardBranchType", 1, DbType.Int32)
                        //    , db.Parameter("@CardProductType", 1, DbType.Int32)
                        //    , db.Parameter("@Available", true, DbType.Boolean)
                        //    , db.Parameter("@CreatorID", 0, DbType.Int32)
                        //    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                        //    , db.Parameter("@PresentRate", 0, DbType.Decimal)).ExecuteScalar<int>();

                        //if (pointCardID <= 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return null;
                        //}

                        //pointCardModel = new GetCompanyCardList_Model();
                        //pointCardModel.CardID = pointCardID;
                        //pointCardModel.CardExpiredDate = DateTime.Now.ToLocalTime().AddYears(99).AddDays(-1);
                        #endregion
                    }



                    #endregion

                    #region 添加现金券关系
                    string strSelCouponCardSql = @" SELECT TOP 1  T1.ID AS CardID ,
                                        CASE T1.ValidPeriodUnit
                                          WHEN 1 THEN DATEADD(DD, -1, DATEADD(yy, T1.VaildPeriod, GETDATE()))
                                          WHEN 2 THEN DATEADD(DD, -1, DATEADD(mm, T1.VaildPeriod, GETDATE()))
                                          WHEN 3 THEN DATEADD(DD, -1, DATEADD(dd, T1.VaildPeriod, GETDATE()))
                                          ELSE GETDATE()
                                        END AS CardExpiredDate
                                FROM    [MST_CARD] T1 WITH ( NOLOCK ) 
                                WHERE   T1.CompanyID = @CompanyID 
                                        AND T1.CardTypeID = 3 
                                        AND T1.Available = 1 ";
                    GetCompanyCardList_Model couponCardModel = db.SetCommand(strSelCouponCardSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteObject<GetCompanyCardList_Model>();
                    if (couponCardModel != null)
                    {
                        #region 给用户关联现金券卡
                        long couponUserCardNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "UserCardNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                        if (couponUserCardNo <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }

                        int addCustomerCounponCardRes = db.SetCommand(strAddCustomerCardSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@UserID", userID, DbType.Int32)
                                                        , db.Parameter("@UserCardNo", couponUserCardNo, DbType.String)
                                                        , db.Parameter("@CardID", couponCardModel.CardID, DbType.Int32)
                                                        , db.Parameter("@Currency", "¥", DbType.String)
                                                        , db.Parameter("@Balance", 0, DbType.Int32)
                                                        , db.Parameter("@CardCreatedDate", model.CreateTime, DbType.DateTime)
                                                        , db.Parameter("@CardExpiredDate", couponCardModel.CardExpiredDate, DbType.DateTime)
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();
                        if (addCustomerCounponCardRes <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }
                        #endregion

                        #region 没有现金券卡 创建现金券卡
                        //long CouponCardCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CardCode", DbType.String)).ExecuteScalar<long>();

                        //if (CouponCardCode <= 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return null;
                        //}

                        //int couponCardID = db.SetCommand(strAddMSTCard, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        //    , db.Parameter("@CardCode", CouponCardCode, DbType.String)
                        //    , db.Parameter("@CardTypeID", 3, DbType.Int32)//积分卡
                        //    , db.Parameter("@CardName", "现金券卡", DbType.String)
                        //    , db.Parameter("@VaildPeriod", 99, DbType.Int32)
                        //    , db.Parameter("@ValidPeriodUnit", 1, DbType.Int32)
                        //    , db.Parameter("@StartAmount", 0, DbType.Decimal)
                        //    , db.Parameter("@BalanceNotice", 0, DbType.Decimal)
                        //    , db.Parameter("@Rate", 1, DbType.Decimal)
                        //    , db.Parameter("@CardBranchType", 1, DbType.Int32)
                        //    , db.Parameter("@CardProductType", 1, DbType.Int32)
                        //    , db.Parameter("@Available", true, DbType.Boolean)
                        //    , db.Parameter("@CreatorID", 0, DbType.Int32)
                        //    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                        //    , db.Parameter("@PresentRate", 0, DbType.Decimal)).ExecuteScalar<int>();

                        //if (couponCardID <= 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return null;
                        //}

                        //couponCardModel = new GetCompanyCardList_Model();
                        //couponCardModel.CardID = couponCardID;
                        //couponCardModel.CardExpiredDate = DateTime.Now.ToLocalTime().AddYears(99).AddDays(-1);
                        #endregion
                    }



                    #endregion

                    #endregion

                    #region 添加美丽顾问/销售顾问
                    string strSqlShipAdd = @"insert into RELATIONSHIP(CompanyID,AccountId ,CustomerId, Available,CreatorID,CreateTime,BranchID,Type) 
                                                            values(@CompanyID,@AccountId,@CustomerId,@Available,@CreatorID,@CreateTime,@BranchID,@Type) ";

                    #region 美丽顾问
                    if (model.ResponsiblePersonID > 0)
                    {
                        int shipAddRes = db.SetCommand(strSqlShipAdd,
                                               db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                               db.Parameter("@AccountId", model.ResponsiblePersonID, DbType.Int32),
                                               db.Parameter("@CustomerId", userID, DbType.Int32),
                                               db.Parameter("@Available", true, DbType.Boolean),
                                               db.Parameter("@Type", 1, DbType.Int32),
                                               db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                               db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime),
                                               db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteNonQuery();


                        if (shipAddRes <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }

                    }

                    #endregion

                    if (model.SalesPersonIDList != null && model.SalesPersonIDList.Count > 0)
                    {
                        #region 销售顾问
                        string advanced = WebAPI.DAL.Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);

                        if (advanced.Contains("|4|"))
                        {
                            foreach (int item in model.SalesPersonIDList)
                            {
                                int shipAddRes = db.SetCommand(strSqlShipAdd,
                                                 db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                 db.Parameter("@AccountId", item, DbType.Int32),
                                                 db.Parameter("@CustomerId", userID, DbType.Int32),
                                                 db.Parameter("@Available", true, DbType.Boolean),
                                                 db.Parameter("@Type", 2, DbType.Int32),
                                                 db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                 db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime),
                                                 db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteNonQuery();


                                if (shipAddRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    return null;
                                }
                            }
                        }
                        #endregion
                    }

                    #endregion

                    #region 插入email
                    if (model.EmailList != null && model.EmailList.Count > 0)
                    {
                        foreach (Model.Operation_Model.Email item in model.EmailList)
                        {
                            string serSqlEmailAdd = @"insert into EMAIL(CompanyID,UserID,Type,Email,Available,CreatorID,CreateTime) 
                                                                    values (@CompanyID,@UserID,@Type,@Email,@Available,@CreatorID,@CreateTime)";
                            int emailAddRes = db.SetCommand(serSqlEmailAdd,
                                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                            db.Parameter("@UserID", userID, DbType.Int32),
                                            db.Parameter("@Type", item.EmailType, DbType.Int32),
                                            db.Parameter("@Email", item.EmailContent, DbType.String),
                                            db.Parameter("@Available", true, DbType.Boolean),
                                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (emailAddRes <= 0)
                            {
                                db.RollbackTransaction();
                                return null;
                            }
                        }
                    }
                    #endregion

                    #region 插入Phone
                    if (model.PhoneList != null && model.PhoneList.Count > 0)
                    {
                        foreach (Model.Operation_Model.Phone item in model.PhoneList)
                        {
                            string serSqlPhoneAdd = @"insert into PHONE(CompanyID,UserID,Type,PhoneNumber,Available,CreatorID,CreateTime) 
                                                                    values (@CompanyID,@UserID,@Type,@PhoneNumber,@Available,@CreatorID,@CreateTime)";
                            int phoneAddRes = db.SetCommand(serSqlPhoneAdd,
                                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                            db.Parameter("@UserID", userID, DbType.Int32),
                                            db.Parameter("@Type", item.PhoneType, DbType.Int32),
                                            db.Parameter("@PhoneNumber", item.PhoneContent, DbType.String),
                                            db.Parameter("@Available", true, DbType.Boolean),
                                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (phoneAddRes <= 0)
                            {
                                db.RollbackTransaction();
                                return null;
                            }
                        }
                    }
                    #endregion

                    #region 插入地址
                    if (model.AddressList != null && model.AddressList.Count > 0)
                    {
                        foreach (Model.Operation_Model.Address item in model.AddressList)
                        {
                            string strSqlAddrAdd = @"insert into ADDRESS(CompanyID,UserID,Type,Address,ZipCode,Available,CreatorID,CreateTime) 
                                                                    values (@CompanyID,@UserID,@Type,@Address,@ZipCode,@Available,@CreatorID,@CreateTime)";

                            int addrAddRes = db.SetCommand(strSqlAddrAdd,
                                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                            db.Parameter("@UserID", userID, DbType.Int32),
                                            db.Parameter("@Type", item.AddressType, DbType.Int32),
                                            db.Parameter("@Address", item.AddressContent, DbType.String),
                                            db.Parameter("@ZipCode", item.ZipCode, DbType.String),
                                            db.Parameter("@Available", true, DbType.Boolean),
                                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addrAddRes <= 0)
                            {
                                db.RollbackTransaction();
                                return null;
                            }
                        }
                    }
                    #endregion

                    StringBuilder strSqlUserInfo = new StringBuilder();
                    strSqlUserInfo.Append(" select CASE WHEN ( T5.AccountID = @AccountID OR T5.AccountID IN ( SELECT fn_CustomerNamesInRegion.SubordinateID FROM fn_CustomerNamesInRegion(@AccountID,@BranchID) )) THEN 1 ELSE 0 END IsMyCustomer , T1.UserID CustomerID,T1.Name CustomerName ,T4.LoginMobile, T2.Discount,T1.PinYin,");
                    strSqlUserInfo.Append(Common.Const.strHttp);
                    strSqlUserInfo.Append(Common.Const.server);
                    strSqlUserInfo.Append(Common.Const.strMothod);
                    strSqlUserInfo.Append(Common.Const.strSingleMark);
                    strSqlUserInfo.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                    strSqlUserInfo.Append(Common.Const.strSingleMark);
                    strSqlUserInfo.Append("/");
                    strSqlUserInfo.Append(Common.Const.strImageObjectType0);
                    strSqlUserInfo.Append(Common.Const.strSingleMark);
                    strSqlUserInfo.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                    strSqlUserInfo.Append(Common.Const.strThumb);
                    strSqlUserInfo.Append(" HeadImageURL  ");
                    strSqlUserInfo.Append(" FROM CUSTOMER T1 ");
                    strSqlUserInfo.Append(" left join LEVEL T2 on T2.ID = T1.LevelID ");
                    strSqlUserInfo.Append(" left join [USER] T4 on T4.ID = T1.UserID");
                    strSqlUserInfo.Append(" LEFT JOIN [RELATIONSHIP] T5 WITH(NOLOCK) ON T5.CustomerID = T1.UserID ");
                    strSqlUserInfo.Append(" Where T1.UserID = @UserID");
                    strSqlUserInfo.Append(" AND T1.Available = 1");
                    strSqlUserInfo.Append(" AND T5.Available = 1 ");


                    res = db.SetCommand(strSqlUserInfo.ToString(),
                                            db.Parameter("@AccountID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                            db.Parameter("@UserID", userID, DbType.Int32),
                                            db.Parameter("@ImageHeight", model.ImageHeight, DbType.String),
                                            db.Parameter("@ImageWidth", model.ImageWidth, DbType.String)).ExecuteObject<CustomerAdd_Model>();

                    if (res == null)
                    {
                        db.RollbackTransaction();
                        return null;
                    }
                    db.CommitTransaction();
                    return res;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strMobile"></param>
        /// <param name="userId"></param>
        /// <param name="companyId"></param>
        /// <param name="userType"></param>
        /// <returns></returns>
        public List<UserListWithMobile_Model> userListWithMobile(string strMobile, int userId, int companyId, int userType)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "select T1.ID AS UserID,T1.LoginMobile,T1.Password from [USER] T1 {0} where (T1.LoginMobile = @LoginMobile or T1.ID = @UserID) and T1.CompanyID = @CompanyID";
                string strSqljoin = "inner join (select * from ACCOUNT where Available = 1 ) T2 on T1.ID = T2.UserID";
                if (userType == 0)
                {
                    strSqljoin = "inner join (select * from CUSTOMER where Available = 1) T2 on T1.ID = T2.UserID ";
                }

                strSql = string.Format(strSql, strSqljoin);
                List<UserListWithMobile_Model> res = db.SetCommand(strSql, db.Parameter("@LoginMobile", strMobile, DbType.String),
                                                db.Parameter("@CompanyID", companyId, DbType.Int32),
                                                db.Parameter("@UserID", userId, DbType.Int32)).ExecuteList<UserListWithMobile_Model>();
                return res;

            }
        }

        /// <summary>
        /// 更新一条customer基本信息数据
        /// </summary>
        /// <param name="accountId"></param>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool customerUpdateBasic(CustomerBasicUpdateOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    string strSqlHistoryUser = " INSERT INTO [HISTORY_USER] SELECT * FROM [USER] WHERE ID =@UserID and CompanyID=@CompanyID ";
                    int rows = db.SetCommand(strSqlHistoryUser
                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    StringBuilder strSqlUpdateUser = new StringBuilder();
                    strSqlUpdateUser.Append(" update [USER] set ");
                    strSqlUpdateUser.Append(" LoginMobile = @LoginMobile ");
                    if (model.PasswordFlag != 0)
                    {
                        strSqlUpdateUser.Append(",Password = @Password ");
                    }
                    strSqlUpdateUser.Append(" where ID=@UserID AND CompanyID=@CompanyID");

                    rows = db.SetCommand(strSqlUpdateUser.ToString(), db.Parameter("@LoginMobile", model.LoginMobile != "" ? model.LoginMobile : (object)DBNull.Value, DbType.String)
                                                                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                        , db.Parameter("@Password", model.PasswordFlag == 1 ? Common.DEncrypt.DEncrypt.Encrypt(model.Password) : (object)DBNull.Value, DbType.String)
                                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlHistoryCustomer = @" INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE UserID =@UserID and CompanyID=@CompanyID ";

                    rows = db.SetCommand(strSqlHistoryCustomer
                                   , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSql =
                                   @"update CUSTOMER set 
                                           Gender=@Gender,
                                           Name=@Name,
                                           Title=@Title,
                                           SourceType=@SourceType , 
                                           UpdaterID=@UpdaterID,
                                           UpdateTime=@UpdateTime,
                                           PinYin=@PinYin ";
                    if (model.HeadFlag == 1)
                    {
                        strSql += ",HeadImageFile=@HeadImageFile ";
                    }
                    strSql += " where UserID=@UserID AND CompanyID=@CompanyID";
                    rows = db.SetCommand(strSql
                        , db.Parameter("@Gender", model.Gender, DbType.Int32)
                        , db.Parameter("@Name", model.CustomerName, DbType.String)
                        , db.Parameter("@Title", model.Title, DbType.String)
                        , db.Parameter("@HeadImageFile", model.HeadImageFile, DbType.String)
                        , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                        , db.Parameter("@PinYin", model.PinYin, DbType.String)
                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@SourceType", model.SourceType, DbType.Int32)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    #region 对邮箱进行处理
                    if (model.EmailList != null && model.EmailList.Count > 0)
                    {
                        string strSqlEmailAdd =
                        @"insert into EMAIL(
                        CompanyID,UserID,Type,Email,Available,CreatorID,CreateTime)
                         values (
                        @CompanyID,@UserID,@Type,@Email,@Available,@CreatorID,@CreateTime)";

                        string strSqlEmailUpdate = @"update EMAIL set 
                                                            Type=@Type,
                                                            Email=@Email,
                                                            Available=@Available,
                                                            UpdaterID=@UpdaterID,
                                                            UpdateTime=@UpdateTime
                                                             where ID=@ID AND CompanyID=@CompanyID";
                        string strSqlCopy = @" Insert into HISTORY_EMAIL 
                                               select * 
                                               from EMAIL 
                                               where ID = @ID ";
                        string strSqlEmailDelete = @" update EMAIL set 
                                                      Available=@Available,
                                                      UpdaterID=@UpdaterID,
                                                      UpdateTime=@UpdateTime
                                                      where ID=@ID AND CompanyID=@CompanyID";
                        for (int i = 0; i < model.EmailList.Count; i++)
                        {
                            if (model.EmailList[i].OperationFlag == 1)
                            {
                                rows = db.SetCommand(strSqlEmailAdd
                                      , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                      , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                      , db.Parameter("@Type", model.EmailList[i].EmailType, DbType.Int32)
                                      , db.Parameter("@Email", model.EmailList[i].EmailContent, DbType.String)
                                      , db.Parameter("@Available", true, DbType.Boolean)
                                      , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                      , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else if (model.EmailList[i].OperationFlag == 2)
                            {
                                rows = db.SetCommand(strSqlEmailUpdate
                                     , db.Parameter("@Type", model.EmailList[i].EmailType, DbType.Int32)
                                     , db.Parameter("@Email", model.EmailList[i].EmailContent, DbType.String)
                                     , db.Parameter("@Available", true, DbType.Boolean)
                                     , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                     , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                     , db.Parameter("@ID", model.EmailList[i].EmailID, DbType.Int32)
                                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else if (model.EmailList[i].OperationFlag == 3)
                            {

                                rows = db.SetCommand(strSqlCopy
                                    , db.Parameter("@ID", model.EmailList[i].EmailID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }

                                rows = db.SetCommand(strSqlEmailDelete
                                    , db.Parameter("@Available", false, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                    , db.Parameter("@ID", model.EmailList[i].EmailID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                        }
                    }
                    #endregion

                    #region 电话

                    if (model.PhoneList != null && model.PhoneList.Count > 0)
                    {

                        string strSqlPhoneAdd =
                        @"insert into PHONE(
                        CompanyID,UserID,Type,PhoneNumber,Available,CreatorID,CreateTime)
                         values (
                        @CompanyID,@UserID,@Type,@PhoneNumber,@Available,@CreatorID,@CreateTime)";

                        string strSqlPhoneUpdate =
                        @"update PHONE set 
                        Type=@Type,
                        PhoneNumber=@PhoneNumber,
                        Available=@Available,
                        UpdaterID=@UpdaterID,
                        UpdateTime=@UpdateTime
                         where ID=@ID AND CompanyID=@CompanyID";

                        string strSqlCopy =
                        @" Insert into HISTORY_PHONE 
                         select * 
                         from PHONE 
                         where ID = @ID ";

                        string strSqlPhoneDelete =
                        @"update PHONE set 
                        Available=@Available,
                        UpdaterID=@UpdaterID,
                         UpdateTime=@UpdateTime
                         where ID=@ID AND CompanyID=@CompanyID";

                        for (int i = 0; i < model.PhoneList.Count; i++)
                        {
                            if (model.PhoneList[i].OperationFlag == 1)
                            {
                                rows = db.SetCommand(strSqlPhoneAdd
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                        , db.Parameter("@Type", model.PhoneList[i].PhoneType, DbType.Int32)
                                        , db.Parameter("@PhoneNumber", model.PhoneList[i].PhoneContent, DbType.String)
                                        , db.Parameter("@Available", true, DbType.Boolean)
                                        , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else if (model.PhoneList[i].OperationFlag == 2)
                            {
                                rows = db.SetCommand(strSqlPhoneUpdate
                                    , db.Parameter("@Type", model.PhoneList[i].PhoneType, DbType.Int32)
                                    , db.Parameter("@PhoneNumber", model.PhoneList[i].PhoneContent, DbType.String)
                                    , db.Parameter("@Available", true, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                    , db.Parameter("@ID", model.PhoneList[i].PhoneID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else if (model.PhoneList[i].OperationFlag == 3)
                            {
                                rows = db.SetCommand(strSqlCopy
                                         , db.Parameter("@ID", model.PhoneList[i].PhoneID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }

                                rows = db.SetCommand(strSqlPhoneDelete
                                    , db.Parameter("@Available", false, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                    , db.Parameter("@ID", model.PhoneList[i].PhoneID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                        }
                    }
                    #endregion

                    #region 地址
                    if (model.AddressList != null && model.AddressList.Count > 0)
                    {
                        string strSqlAddrAdd =
                        @"insert into ADDRESS(
                        CompanyID,UserID,Type,Address,ZipCode,Available,CreatorID,CreateTime)
                         values (
                             @CompanyID,@UserID,@Type,@Address,@ZipCode,@Available,@CreatorID,@CreateTime)";

                        string strSqlAddrUpt =
                       @" update ADDRESS set 
                        Type=@Type,
                        Address=@Address,
                        ZipCode=@ZipCode,
                        Available=@Available,
                        UpdaterID=@UpdaterID,
                        UpdateTime=@UpdateTime
                         where ID=@ID AND CompanyID=@CompanyID";

                        string strSqlCopy =
                         @"Insert into HISTORY_ADDRESS 
                         select * 
                         from ADDRESS 
                         where ID = @ID ";

                        string strSqlAddrDelete =
                        @"update ADDRESS set 
                        Available=@Available,
                        UpdaterID=@UpdaterID,
                         UpdateTime=@UpdateTime
                         where ID=@ID AND CompanyID=@CompanyID";

                        for (int i = 0; i < model.AddressList.Count; i++)
                        {
                            if (model.AddressList[i].OperationFlag == 1)
                            {
                                rows = db.SetCommand(strSqlAddrAdd
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                    , db.Parameter("@Type", model.AddressList[i].AddressType, DbType.Int32)
                                    , db.Parameter("@Address", model.AddressList[i].AddressContent, DbType.String)
                                    , db.Parameter("@ZipCode", model.AddressList[i].ZipCode, DbType.String)
                                    , db.Parameter("@Available", true, DbType.Boolean)
                                    , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else if (model.AddressList[i].OperationFlag == 2)
                            {
                                rows = db.SetCommand(strSqlAddrUpt
                                    , db.Parameter("@Type", model.AddressList[i].AddressType, DbType.Int32)
                                    , db.Parameter("@Address", model.AddressList[i].AddressContent, DbType.String)
                                    , db.Parameter("@ZipCode", model.AddressList[i].ZipCode, DbType.String)
                                    , db.Parameter("@Available", true, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                    , db.Parameter("@ID", model.AddressList[i].AddressID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else if (model.AddressList[i].OperationFlag == 3)
                            {
                                rows = db.SetCommand(strSqlCopy
                                    , db.Parameter("@ID", model.AddressList[i].AddressID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }

                                rows = db.SetCommand(strSqlAddrDelete
                                    , db.Parameter("@Available", false, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                    , db.Parameter("@ID", model.AddressList[i].AddressID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                        }
                    }
                    #endregion
                    db.CommitTransaction();
                    return true;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        /// <summary>
        /// 更新一条详细信息数据
        /// </summary>
        /// <param name="accountId"></param>
        /// <param name="model"></param>
        /// <returns></returns>
        /// 2013.09.23杜洪川修改
        public bool customerUpdateDetail(Customer_Model model)
        {
            using (DbManager db = new DbManager())
            {

                db.BeginTransaction();

                string strSqlHistory = " INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE UserID =@UserID and CompanyID=@CompanyID ";

                int rows = db.SetCommand(strSqlHistory
                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }



                string strSql = @"    
                                     update CUSTOMER set 
                                     Height=@Height,
                                     Weight=@Weight,
                                     BloodType=@BloodType,
                                     BirthDay=@BirthDay,
                                     Marriage=@Marriage,
                                     Profession=@Profession,
                                     Remark=@Remark,
                                     UpdaterID=@UpdaterID,
                                     UpdateTime=@UpdateTime
                                     where UserID=@UserID";

                rows = db.SetCommand(strSql
                    //, db.Parameter("@Gender", model.Gender, DbType.Int32)
                    , db.Parameter("@Height", model.Height, DbType.Decimal)
                    , db.Parameter("@Weight", model.Weight, DbType.Decimal)
                    , db.Parameter("@BloodType", model.BloodType, DbType.String)
                    , db.Parameter("@BirthDay", model.BirthDay, DbType.Date)
                    , db.Parameter("@Marriage", model.Marriage, DbType.Int32)
                    , db.Parameter("@Profession", model.Profession, DbType.String)
                    , db.Parameter("@Remark", model.Remark, DbType.String)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                    ).ExecuteNonQuery();
                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }
                else
                {
                    db.CommitTransaction();
                    return true;
                }
            }

        }

        /// <summary>
        /// 获取customer基本信息数据
        /// </summary>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public CustomerBasic_Model getCustomerBasic(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                CustomerBasic_Model model = null;

                StringBuilder strSqlCustomer = new StringBuilder();
                strSqlCustomer.Append(" select T1.UserID CustomerID, T1.Name CustomerName, T1.Title, T4.LoginMobile ,ISNULL(T6.UserID, 0) AS ResponsiblePersonID ,ISNULL(T6.Name,'') AS ResponsiblePersonName, T1.RegistFrom ,T1.Gender ,T7.Name AS SourceTypeName ,T7.ID AS SourceTypeID ,");
                strSqlCustomer.Append(Common.Const.strHttp);
                strSqlCustomer.Append(Common.Const.server);
                strSqlCustomer.Append(Common.Const.strMothod);
                strSqlCustomer.Append(Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSqlCustomer.Append(Common.Const.strSingleMark);
                strSqlCustomer.Append("/");
                strSqlCustomer.Append(Common.Const.strImageObjectType0);
                strSqlCustomer.Append(Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSqlCustomer.Append(Common.Const.strThumb);
                strSqlCustomer.Append(" HeadImageURL  ");
                strSqlCustomer.Append(" FROM CUSTOMER T1 ");
                strSqlCustomer.Append(" LEFT JOIN [USER] T4 ON T4.ID = T1.UserID ");
                strSqlCustomer.Append(" LEFT JOIN [RELATIONSHIP] T5 ON T5.CustomerID = T1.UserID AND T5.Available = 1 AND T5.BranchID = @BranchID AND T5.Type=1");
                strSqlCustomer.Append(" Left JOIN [Account] T6 ON T6.UserID = T5.AccountID AND T6.Available = 1 ");
                strSqlCustomer.Append(" LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T7 WITH(NOLOCK) ON T1.[SourceType]=T7.ID AND T7.CompanyID=@CompanyID ");
                strSqlCustomer.Append(" Where T1.UserID = @UserID ");

                model = db.SetCommand(strSqlCustomer.ToString(), db.Parameter("@UserID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight, DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth, DbType.String)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<CustomerBasic_Model>();

                if (model == null)
                {
                    return null;
                }

                string strSql = @" select ID PhoneID, Type PhoneType, PhoneNumber PhoneContent 
                                       from PHONE 
                                       Where UserID = @UserID AND Available = 1 ";

                model.PhoneList = db.SetCommand(strSql.ToString()
                                               , db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteList<Model.Table_Model.Phone>();

                strSql = @" select	ID EmailID, Type EmailType, Email EmailContent 
                                   from EMAIL 
                                   Where UserID = @UserID AND Available = 1";

                model.EmailList = db.SetCommand(strSql.ToString()
                                               , db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteList<Model.Table_Model.Email>();

                strSql = @" select ID AddressID, Type AddressType, Address AddressContent, ZipCode 
                                    from ADDRESS 
                                    Where UserID = @UserID AND Available = 1";
                model.AddressList = db.SetCommand(strSql.ToString()
                                               , db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteList<Model.Table_Model.Address>();

                strSql = @"SELECT  COUNT(0)
                            FROM    dbo.TBL_TASK
                            WHERE   CompanyID = @CompanyID
                                    AND BranchID = @BranchID
                                    AND TaskOwnerID = @CustomerID
                                    AND ( TaskStatus = 1 OR TaskStatus = 2 )";
                model.ScheduleCount = db.SetCommand(strSql.ToString()
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();

                string advanced = Company_DAL.Instance.getAdvancedByCompanyID(companyID);
                if (advanced.Contains("|4|"))
                {
                    #region 销售顾问
                    string strSelSalesSql = @" SELECT  T1.AccountID AS SalesPersonID ,
                                                            T2.Name AS SalesName
                                                    FROM    [RELATIONSHIP] T1 WITH ( NOLOCK )
                                                            INNER JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.AccountID = T2.UserID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.BranchID = @BranchID
                                                            AND T1.CustomerID = @CustomerID
                                                            AND T1.Available = 1
                                                            AND T1.Type = 2 ";

                    model.SalesList = db.SetCommand(strSelSalesSql,
                            db.Parameter("@CompanyID", companyID, DbType.Int32),
                            db.Parameter("@BranchID", branchID, DbType.Int32),
                            db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<Sales_Model>();
                    #endregion
                }

                return model;

            }
        }

        public CustomerInfo_Model getCustomerInfo(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                CustomerInfo_Model model = null;

                StringBuilder strSqlCustomer = new StringBuilder();
                strSqlCustomer.Append(" select  T1.Name CustomerName, T4.LoginMobile ,ISNULL(T6.UserID, 0) AS ResponsiblePersonID ,T1.DefaultCardNo ,");
                strSqlCustomer.Append(Common.Const.strHttp);
                strSqlCustomer.Append(Common.Const.server);
                strSqlCustomer.Append(Common.Const.strMothod);
                strSqlCustomer.Append(Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSqlCustomer.Append(Common.Const.strSingleMark);
                strSqlCustomer.Append("/");
                strSqlCustomer.Append(Common.Const.strImageObjectType0);
                strSqlCustomer.Append(Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSqlCustomer.Append(Common.Const.strThumb);
                strSqlCustomer.Append(" HeadImageURL  ");
                strSqlCustomer.Append(" FROM CUSTOMER T1 ");
                strSqlCustomer.Append(" LEFT JOIN [USER] T4 ON T4.ID = T1.UserID ");
                strSqlCustomer.Append(" LEFT JOIN [RELATIONSHIP] T5 ON T5.CustomerID = T1.UserID AND T5.Available = 1 AND T5.BranchID = @BranchID AND T5.Type=1");
                strSqlCustomer.Append(" Left JOIN [Account] T6 ON T6.UserID = T5.AccountID AND T6.Available = 1 ");
                strSqlCustomer.Append(" Where T1.UserID = @UserID ");

                model = db.SetCommand(strSqlCustomer.ToString(), db.Parameter("@UserID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight, DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth, DbType.String)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteObject<CustomerInfo_Model>();

                if (model == null)
                {
                    return null;
                }


                string strSql = @" SELECT  COUNT(0)
                                    FROM    [TBL_TASK] T1 WITH ( NOLOCK )
                                            INNER JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID
                                                                                      AND T2.Available = 1
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.BranchID = @BranchID
                                            AND T1.TaskOwnerID = @CustomerID
                                            AND ( T1.TaskStatus = 1
                                                  OR T1.TaskStatus = 2
                                                )
                                            AND T1.TaskType = 1
                                            AND T1.CreateTime > T2.StartTime ";
                model.ScheduleCount = db.SetCommand(strSql.ToString()
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();

                strSql = @"SELECT  COUNT(0)
                            FROM    [ORDER] T1 WITH ( NOLOCK )
                                    LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T1.CustomerID = @CustomerID
                                    AND ( T1.PaymentStatus = 1
                                          OR PaymentStatus = 2
                                        )
                                    AND T1.UnPaidPrice > 0
                                    AND RecordType = 1
                                    AND T1.Status <> 3
                                    AND T1.Status <> 4
                                    AND T1.OrderTime > T2.StartTime";

                model.UnPaidCount = db.SetCommand(strSql.ToString()
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();
                return model;

            }
        }

        /// <summary>
        /// 获取customer详细信息数据
        /// </summary>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public CustomerDetail_Model getCustomerDetail(int customerId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "select UserID CustomerID, Name CustomerName, Gender,Height,Weight,BloodType,CONVERT(varchar(10),BirthDay,20) BirthDay,Marriage, Profession, Remark FROM CUSTOMER Where UserID = @UserID";

                CustomerDetail_Model model = db.SetCommand(strSql, db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteObject<CustomerDetail_Model>();
                return model;
            }
        }

        /// <summary>
        /// 删除customer数据
        /// </summary>
        /// <param name="accountId"></param>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public bool deleteCustomer(int AccountID, int CustomerID, int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    DateTime dt = DateTime.Now.ToLocalTime();

                    db.BeginTransaction();

                    string strSqlHistory = " INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE UserID =@UserID and CompanyID=@CompanyID ";

                    int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@UserID", CustomerID, DbType.Int32)
                        , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }


                    string strSql =
                   @" update CUSTOMER set 
                        Available=@Available,
                        UpdaterID=@UpdaterID,
                        UpdateTime=@UpdateTime,
						WeChatOpenID = null,
						WeChatUnionID = null
                        where UserID=@UserID and CompanyID =@CompanyID ";

                    int val = db.SetCommand(strSql, db.Parameter("@Available", false, DbType.Boolean)
                        , db.Parameter("@UpdaterID", AccountID, DbType.Int32)
                        , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                        , db.Parameter("@UserID", CustomerID, DbType.Int32)
                        , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (val == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    //删除phone
                    else
                    {
                        //判断是否有Phone记录

                        strSql = " select Count(*) PhoneCount from Phone where UserID = @UserID and Available = 1 ";
                        int count = db.SetCommand(strSql, db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteScalar<int>();

                        if (count > 0)
                        {
                            strSql = @" Insert into HISTORY_PHONE 
                                            select * 
                                            from PHONE 
                                            where UserID = @UserID ";
                            val = db.SetCommand(strSql, db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteNonQuery();

                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            strSql = @" update PHONE set 
                                            Available=@Available, 
                                            UpdaterID=@UpdaterID, 
                                            UpdateTime=@UpdateTime 
                                            where UserID=@UserID ";

                            val = db.SetCommand(strSql, db.Parameter("@Available", false, DbType.Boolean)
                                , db.Parameter("@UpdaterID", AccountID, DbType.Int32)
                                , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                                , db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteNonQuery();
                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }

                        //判断是否有Email记录
                        strSql = " select Count(*) EmailCount from Email where UserID = @UserID and Available = 1 ";
                        count = db.SetCommand(strSql, db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteScalar<int>();
                        if (count > 0)
                        {
                            strSql = @"
                                 Insert into HISTORY_EMAIL 
                                 select * 
                                 from EMAIL 
                                 where UserID = @UserID ";
                            val = db.SetCommand(strSql, db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteNonQuery();

                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            strSql = @"
                                 update EMAIL set 
                                 Available=@Available, 
                                 UpdaterID=@UpdaterID, 
                                 UpdateTime=@UpdateTime 
                                 where UserID=@UserID ";

                            val = db.SetCommand(strSql, db.Parameter("@Available", false, DbType.Boolean)
                               , db.Parameter("@UpdaterID", AccountID, DbType.Int32)
                               , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                               , db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteNonQuery();

                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                        //判断是否有Address记录
                        strSql = " select Count(*) AddressCount from Address where UserID = @UserID and Available = 1 ";
                        count = db.SetCommand(strSql, db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteScalar<int>();
                        if (count > 0)
                        {
                            strSql =
                            @"   Insert into HISTORY_ADDRESS 
                                 select * 
                                 from ADDRESS 
                                 where UserID = @UserID ";

                            val = db.SetCommand(strSql, db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteNonQuery();
                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            strSql =
                            @"   update ADDRESS set 
                                 Available=@Available, 
                                 UpdaterID=@UpdaterID, 
                                 UpdateTime=@UpdateTime 
                                 where UserID=@UserID ";
                            val = db.SetCommand(strSql, db.Parameter("@Available", false, DbType.Boolean)
                                , db.Parameter("@UpdaterID", AccountID, DbType.Int32)
                                , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                                , db.Parameter("@UserID", CustomerID, DbType.Int32)).ExecuteNonQuery();
                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }

                        strSql = "select COUNT(ID) from [RELATIONSHIP] WHERE CustomerID =@CustomerID and Available = 1 ";

                        count = db.SetCommand(strSql, db.Parameter("@CustomerID", CustomerID, DbType.Int32)).ExecuteScalar<int>();
                        if (count > 0)
                        {
                            strSql = "Insert into [HISTORY_RELATIONSHIP] select * from [RELATIONSHIP] where CustomerID  =@CustomerID and Available  =1";
                            val = db.SetCommand(strSql, db.Parameter("@CustomerID", CustomerID, DbType.Int32)).ExecuteNonQuery();

                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                            strSql = "update [RELATIONSHIP] set Available=@Available, UpdaterID=@UpdaterID, UpdateTime=@UpdateTime where CustomerID=@CustomerID and Available  =1 ";

                            val = db.SetCommand(strSql, db.Parameter("@Available", false, DbType.Boolean)
                                , db.Parameter("@UpdaterID", AccountID, DbType.Int32)
                                , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                                , db.Parameter("@CustomerID", CustomerID, DbType.Int32)).ExecuteNonQuery();

                            if (val == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }
                    db.CommitTransaction();
                    return true;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw ex;
                }
            }

        }

        /// <summary>
        /// 获取问卷和答案
        /// </summary>
        /// <param name="customerId"></param>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public List<QuestionAnswer_Model> getQuestionAnswer(int customerId, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql =
           @" select T1.ID QuestionID ,T1.QuestionName,T1.QuestionType,T1.QuestionContent,T3.AnswerID,T3.AnswerContent 
             from QUESTION T1 
             left join ( 
             SELECT T2.ID AnswerID,T2.AnswerContent,T2.QuestionID QuestionID 
             FROM ANSWER T2  
             where T2.CustomerID =@CustomerID and T2.CompanyID = @CompanyID ) T3
             ON T1.ID = T3.QuestionID 
             WHERE CompanyID =@CompanyID ";

                List<QuestionAnswer_Model> list = new List<QuestionAnswer_Model>();

                list = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)
                                            , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<QuestionAnswer_Model>();

                return list;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="accountId"></param>
        /// <param name="customerId"></param>
        /// <param name="listQuestionId"></param>
        /// <param name="listAnswerId"></param>
        /// <param name="listAnswerText"></param>
        /// <returns></returns>
        public bool updateAnswer(UpdateAnswerOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSqlInsert =
                   @" insert into Answer (
                     CompanyId, CustomerID, QuestionID, AnswerContent, CreatorID, CreateTime)
                     values ( 
                    @CompanyID, @CustomerID, @QuestionID, @AnswerContent, @CreatorID, @CreateTime)";

                    string strSqlInset_His = @"INSERT INTO HISTORY_ANSWER SELECT * FROM dbo.ANSWER WHERE ID =@AnswerID ";

                    string strSqlUpdate =
                    @"update ANSWER set 
                    AnswerContent=@AnswerContent,
                    UpdaterID=@UpdaterID,
                    UpdateTime=@UpdateTime
                     where ID=@AnswerID ";

                    for (int i = 0; i < model.AnswerList.Count; i++)
                    {
                        //插入新的answer
                        if (model.AnswerList[i].AnswerID == 0)
                        {
                            int valInsertNew = db.SetCommand(strSqlInsert
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                , db.Parameter("@QuestionID", model.AnswerList[i].QuestionID, DbType.Int32)
                                , db.Parameter("@AnswerContent", model.AnswerList[i].AnswerContent, DbType.String)
                                , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime)).ExecuteNonQuery();
                            if (valInsertNew == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                        //更新answer
                        else
                        {
                            int valHistory = db.SetCommand(strSqlInset_His, db.Parameter("@AnswerID", model.AnswerList[i].AnswerID, DbType.Int32)).ExecuteNonQuery();
                            if (valHistory == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                            else
                            {
                                //更新数据
                                int valUpdate = db.SetCommand(strSqlUpdate
                                    , db.Parameter("@AnswerContent", model.AnswerList[i].AnswerContent, DbType.String)
                                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime)
                                    , db.Parameter("@AnswerID", model.AnswerList[i].AnswerID, DbType.Int32)).ExecuteNonQuery();
                                if (valUpdate == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                        }
                    }
                    db.CommitTransaction();
                    return true;

                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public bool CustomerExistOrderOrRechargeHistory(int customerId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  ( SELECT    COUNT(0)
                           FROM      dbo.[ORDER]
                           WHERE     CustomerID = @CustomerID
                                     AND Status <> 3
                         ) | ( SELECT    COUNT(0)
                               FROM      dbo.TBL_CUSTOMER_CARD
                               WHERE     UserID = @CustomerID and Balance > 0
                             ) |( select COUNT(0) from CUSTOMER where UserID =@CustomerID and BranchID <> @BranchID ) balanceCount";

                int count = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<int>();

                return count > 0;
            }
        }

        public bool updateSalesPersonID(int CompanyID, int BranchID, List<int> AccountIDList, int CustomerID, int CreatorID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSql = @"DELETE  FROM [RELATIONSHIP]
                                    WHERE   companyID = @CompanyID
                                            AND BranchID = @BranchID
                                            AND CustomerID = @CustomerID 
                                            AND Type = 2";

                int rows = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", CustomerID, DbType.Int32)).ExecuteNonQuery();

                if (rows < 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                strSql = @"INSERT  INTO [RELATIONSHIP]( CompanyID ,AccountID ,CustomerID ,Available ,CreatorID ,CreateTime ,BranchID ,Type)
                                    VALUES  ( @CompanyID ,@AccountID ,@CustomerID ,1 ,@CreatorID ,@CreateTime ,@BranchID,2 )";

                foreach (int item in AccountIDList)
                {
                    rows = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                   , db.Parameter("@BranchID", BranchID, DbType.Int32)
                   , db.Parameter("@CustomerID", CustomerID, DbType.Int32)
                   , db.Parameter("@AccountID", item, DbType.Int32)
                   , db.Parameter("@CreatorID", CreatorID, DbType.Int32)
                   , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();


                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }


                db.CommitTransaction();
                return true;
            }
        }

        public List<CustomerSourceType_Model> GetCustomerSourceTypeList(int companyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "SELECT ID,Name FROM TBL_CUSTOMER_SOURCE_TYPE WHERE CompanyID=@CompanyID AND RecordType=1";
                List<CustomerSourceType_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<CustomerSourceType_Model>();

                return list;
            }
        }

    }
}
