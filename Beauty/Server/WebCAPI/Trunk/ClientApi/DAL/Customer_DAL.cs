using BLToolkit.Data;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
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

        public CustomerInfo_Model getCustomerInfo(int companyID, int customerId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                CustomerInfo_Model model = null;

                StringBuilder strSqlCustomer = new StringBuilder();
                strSqlCustomer.Append(" select  T1.Name CustomerName, T4.LoginMobile ,T1.DefaultCardNo ,T3.CompanyCode ,");
                strSqlCustomer.Append(WebAPI.Common.Const.strHttp);
                strSqlCustomer.Append(WebAPI.Common.Const.server);
                strSqlCustomer.Append(WebAPI.Common.Const.strMothod);
                strSqlCustomer.Append(WebAPI.Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSqlCustomer.Append(WebAPI.Common.Const.strSingleMark);
                strSqlCustomer.Append("/");
                strSqlCustomer.Append(WebAPI.Common.Const.strImageObjectType0);
                strSqlCustomer.Append(WebAPI.Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSqlCustomer.Append(WebAPI.Common.Const.strThumb);
                strSqlCustomer.Append(" HeadImageURL  ");
                strSqlCustomer.Append(" FROM CUSTOMER T1 ");
                strSqlCustomer.Append(" LEFT JOIN [USER] T4 ON T4.ID = T1.UserID ");
                strSqlCustomer.Append(" LEFT JOIN [COMPANY] T3 ON T1.CompanyID=T3.ID ");
                strSqlCustomer.Append(" Where T1.UserID = @UserID ");
                strSqlCustomer.Append(" AND T1.CompanyID=@CompanyID ");

                model = db.SetCommand(strSqlCustomer.ToString()
                    , db.Parameter("@UserID", customerId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight, DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth, DbType.String)).ExecuteObject<CustomerInfo_Model>();

                if (model == null)
                {
                    return null;
                }

                string strSql = "";
                //                strSql = @"SELECT  COUNT(0)
                //                            FROM    dbo.TBL_TASK
                //                            WHERE   CompanyID = @CompanyID
                //                                    AND BranchID = @BranchID
                //                                    AND TaskOwnerID = @CustomerID
                //                                    AND ( TaskStatus = 1 OR TaskStatus = 2 ) 
                //                                    AND TaskType=1 ";
                //                model.ScheduleCount = db.SetCommand(strSql.ToString()
                //                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                //                                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                //                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();
                strSql = @" SELECT  COUNT(0)
                            FROM    [ORDER] T1 WITH ( NOLOCK )
                                    LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID
                            WHERE   T1.OrderTime > T2.StartTime
                                    AND T1.CompanyID = @CompanyID
                                    AND T1.CustomerID = @CustomerID
                                    AND ISNULL(RecordType, 1) = 1";

                model.AllOrderCount = db.SetCommand(strSql
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();


                strSql = @" SELECT  COUNT(0)
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

                model.UnPaidCount = db.SetCommand(strSql
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();


                strSql = @" SELECT  COUNT(0)
                            FROM    ( SELECT    T1.GroupNo
                                      FROM      TBL_TREATGROUP T1 WITH ( NOLOCK )
                                                INNER JOIN [Order] T2 WITH ( NOLOCK ) ON T1.OrderID = T2.ID
                                                INNER JOIN [BRANCH] T3 WITH ( NOLOCK ) ON T2.BranchID = T3.ID
                                      WHERE     T1.TGStatus = 5
                                                AND T2.OrderTime > T3.StartTime
                                                AND T2.RecordType = 1
                                                AND T1.CompanyID = @CompanyID
                                                AND T2.CustomerID = @CustomerID
                                      UNION ALL
                                      SELECT    T1.ID AS GroupNo
                                      FROM      [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                INNER JOIN [Order] T2 WITH ( NOLOCK ) ON T1.OrderID = T2.ID
                                                INNER JOIN [BRANCH] T3 WITH ( NOLOCK ) ON T2.BranchID = T3.ID
                                      WHERE     T1.Status = 5
                                                AND T2.OrderTime > T3.StartTime
                                                AND T2.RecordType = 1
                                                AND T1.CompanyID = @CompanyID
                                                AND T2.CustomerID = @CustomerID
                                    ) a";

                model.NeedConfirmTGCount = db.SetCommand(strSql
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();


                strSql = @" SELECT  COUNT(0)
                            FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                    INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID AND T2.Status <> 3 
                                    INNER JOIN [ORDER] T3 WITH ( NOLOCK ) ON T1.OrderID = T3.ID
                                    INNER JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T2.BranchID = T4.ID
                            WHERE   T2.CompanyID = @CompanyID
                                    AND T2.CustomerID = @CustomerID
                                    AND T1.TGStatus = 2 
                                    AND T3.RecordType = 1
                                    AND T1.IsReviewed = 0 
                                    AND T3.OrderTime > T4.StartTime ";

                model.NeedReviewTGCount = db.SetCommand(strSql
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();

                return model;

            }
        }

        public CustomerBasic_Model getCustomerBasic(int companyID, int customerId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                CustomerBasic_Model model = new CustomerBasic_Model();

                StringBuilder strSqlCustomer = new StringBuilder();
                strSqlCustomer.Append(" select T1.UserID AS CustomerID, T1.Name AS CustomerName, T2.LoginMobile ,T1.Gender ,");
                strSqlCustomer.Append(WebAPI.Common.Const.strHttp);
                strSqlCustomer.Append(WebAPI.Common.Const.server);
                strSqlCustomer.Append(WebAPI.Common.Const.strMothod);
                strSqlCustomer.Append(WebAPI.Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSqlCustomer.Append(WebAPI.Common.Const.strSingleMark);
                strSqlCustomer.Append("/");
                strSqlCustomer.Append(WebAPI.Common.Const.strImageObjectType0);
                strSqlCustomer.Append(WebAPI.Common.Const.strSingleMark);
                strSqlCustomer.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSqlCustomer.Append(WebAPI.Common.Const.strThumb);
                strSqlCustomer.Append(" HeadImageURL  ");
                strSqlCustomer.Append(" FROM CUSTOMER T1 ");
                strSqlCustomer.Append(" LEFT JOIN [USER] T2 ON T2.ID = T1.UserID ");
                strSqlCustomer.Append(" Where T1.UserID = @UserID ");

                model = db.SetCommand(strSqlCustomer.ToString()
                    , db.Parameter("@UserID", customerId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight, DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth, DbType.String)).ExecuteObject<CustomerBasic_Model>();

                if (model == null)
                {
                    return null;
                }

                string strBranchList = @" SELECT  T2.ID AS BranchID ,
                                                    T2.BranchName ,
                                                    T3.UserID AS ResponsiblePersonID ,
                                                    T3.Name AS ResponsiblePersonName
                                            FROM    [RELATIONSHIP] T1 WITH ( NOLOCK )
                                                    INNER JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID
                                                                                              AND T2.Available = 1
                                                    LEFT JOIN [ACCOUNT] T3 WITH ( NOLOCK ) ON T1.AccountID = T3.UserID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerID = @CustomerID
                                                    AND T1.Type = 1 ";

                List<CustomerBasicBranch_Model> branchList = db.SetCommand(strBranchList
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<CustomerBasicBranch_Model>();

                if (branchList != null && branchList.Count > 0)
                {
                    model.BranchList = branchList;
                }

                return model;
            }
        }

        public bool customerUpdateBasic(CustomerBasicUpdateOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlHistoryCustomer = @" INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE UserID =@UserID and CompanyID=@CompanyID ";

                int rows = db.SetCommand(strSqlHistoryCustomer
                               , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql =
                               @"update CUSTOMER set 
                                           Gender = @Gender ,
                                           Name = @Name ,
                                           UpdaterID = @UpdaterID,
                                           UpdateTime = @UpdateTime";
                if (model.HeadFlag == 1)
                {
                    strSql += ",HeadImageFile=@HeadImageFile ";
                }
                strSql += " where UserID=@UserID AND CompanyID=@CompanyID";
                rows = db.SetCommand(strSql
                    , db.Parameter("@Name", model.CustomerName, DbType.String)
                    , db.Parameter("@Gender", model.Gender, DbType.Int32)
                    , db.Parameter("@HeadImageFile", model.HeadImageFile, DbType.String)
                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;
            }
        }

        public bool IsExistCustomer(string loginMobile,int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  COUNT(0)
                                  FROM    [USER] T1
                                          INNER JOIN dbo.CUSTOMER T2 ON T1.ID = T2.UserID
                                  WHERE   T1.LoginMobile = @LoginMobile
                                          AND T2.Available = 1";
                if (companyId > 0) {
                    strSql += " and T1.CompanyID = @CompanyID ";
                }
                int res = db.SetCommand(strSql, db.Parameter("@LoginMobile", loginMobile, DbType.String)
                    , db.Parameter("@CompanyID", companyId, DbType.String)).ExecuteScalar<int>();
                if (res <= 0)
                {
                    return false;
                }
                return true;
            }
        }

        public bool IsExistFavorite(int companyID, int customerID, long productCode, int productType, out string userFavoriteID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  UserFavoriteID
                                    FROM    TBL_CUSTOMER_FAVORITE
                                    WHERE   CompanyID = @CompanyID
                                            AND UserID = @CustomerID
                                            AND ProductCode = @ProductCode
                                            AND ProductType = @ProductType ";
                userFavoriteID = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)
                    , db.Parameter("@ProductCode", productCode, DbType.Int64)
                    , db.Parameter("@ProductType", productType, DbType.Int32)
                    ).ExecuteScalar<string>();

                if (string.IsNullOrWhiteSpace(userFavoriteID))
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
        }

        public List<FavoriteList_Model> getFavorteList(int companyID, int customerID, int productType, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                List<FavoriteList_Model> list = new List<FavoriteList_Model>();

                string strSql = "";

                string strSqlCommodity = @" SELECT  T1.UserFavoriteID ,
                                                    T1.ProductType ,
                                                    T1.SortID ,
                                                    T1.CreateTime ,
                                                    T2.CommodityName AS ProductName ,
                                                    T1.ProductCode ,
                                                    T2.Available ,
                                                    T2.UnitPrice , 
                                                    T2.Specification ,";
                strSqlCommodity += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T1.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType6
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T1.ProductCode as nvarchar(16))+ '/' + T3.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ImgUrl ";
                strSqlCommodity += @" FROM    [TBL_CUSTOMER_FAVORITE] T1 WITH ( NOLOCK )
                                               LEFT JOIN [COMMODITY] T2 WITH ( NOLOCK ) ON T1.ProductCode = T2.Code --AND T2.ID =(SELECT MAX(ID) FROM [SERVICE] T4 WHERE T4.Code=T2.Code) 
                                               LEFT JOIN [IMAGE_COMMODITY] T3 WITH ( NOLOCK ) ON T2.ID = T3.CommodityID AND T3.ImageType = 0
                                       WHERE   T1.CompanyID = @CompanyID
                                                AND T1.UserID = @CustomerID 
                                                AND T1.ProductType = 1 
                                                AND T2.Available = 1 ";



                string strSqlService = @" SELECT  T1.UserFavoriteID ,
                                                    T1.ProductType ,
                                                    T1.SortID ,
                                                    T1.CreateTime ,
                                                    T2.ServiceName AS ProductName ,
                                                    T1.ProductCode ,
                                                    T2.Available ,
                                                    T2.UnitPrice , 
                                                    '' AS Specification ,";
                strSqlService += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T1.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType8
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T1.ProductCode as nvarchar(16))+ '/' + T3.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ImgUrl ";
                strSqlService += @" FROM    [TBL_CUSTOMER_FAVORITE] T1 WITH ( NOLOCK )
                                            LEFT JOIN [SERVICE] T2 WITH ( NOLOCK ) ON T1.ProductCode = T2.Code --AND T2.ID =(SELECT MAX(ID) FROM [SERVICE] T4 WHERE T4.Code=T2.Code) 
                                            LEFT JOIN [IMAGE_SERVICE] T3 WITH ( NOLOCK ) ON T2.ID = T3.ServiceID AND T3.ImageType = 0
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.UserID = @CustomerID
                                            AND T1.ProductType = 0 
                                            AND T2.Available = 1 ";

                if (productType == 0)
                {
                    strSql = strSqlService;
                }
                else if (productType == 1)
                {
                    strSql = strSqlCommodity;
                }
                else
                {
                    strSql = strSqlCommodity + " UNION ALL " + strSqlService;
                }

                list = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@CustomerID", customerID, DbType.Int32)
                        , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                        , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<FavoriteList_Model>();

                return list;
            }
        }

        public int addFavorite(CustomerFavorite_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string userFavoriteID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "UserFavoriteID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                string strSql = @" INSERT INTO TBL_CUSTOMER_FAVORITE( CompanyID ,BranchID ,UserFavoriteID ,UserID ,ProductType ,ProductCode ,SortID ,CreatorID ,CreateTime )
                VALUES ( @CompanyID ,@BranchID ,@UserFavoriteID ,@UserID ,@ProductType ,@ProductCode ,@SortID ,@CreatorID ,@CreateTime ) ";

                int addRes = db.SetCommand(strSql
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BranchID", 0, DbType.Int32)
                            , db.Parameter("@UserFavoriteID", userFavoriteID, DbType.String)
                            , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                            , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                            , db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                            , db.Parameter("@SortID", 0, DbType.Int32)
                            , db.Parameter("@CreatorID", model.CustomerID, DbType.Int32)
                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                if (addRes <= 0)
                {
                    return 0;
                }

                return 1;
            }
        }

        public bool delFavorite(CustomerFavorite_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" DELETE  FROM TBL_CUSTOMER_FAVORITE
                                    WHERE   CompanyID = @CompanyID
                                            AND UserID = @CustomerID
                                            AND UserFavoriteID = @UserFavoriteID ";

                int addRes = db.SetCommand(strSql
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@UserFavoriteID", model.UserFavoriteID, DbType.String)
                            , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();

                if (addRes <= 0)
                {
                    return false;
                }

                return true;
            }
        }

        public UtilityOperation_Model getCustomerInfo(string loginMobile, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  TOP 1 T1.LoginMobile,T1.CompanyID,0 CreatorID
                                  FROM    [USER] T1
                                          INNER JOIN dbo.CUSTOMER T2 ON T1.ID = T2.UserID
                                  WHERE   T1.LoginMobile = @LoginMobile
                                          AND T2.Available = 1";
                if (companyId > 0)
                {
                    strSql += " and T1.CompanyID = @CompanyID ";
                }
                UtilityOperation_Model res = db.SetCommand(strSql, db.Parameter("@LoginMobile", loginMobile, DbType.String)
                    , db.Parameter("@CompanyID", companyId, DbType.String)).ExecuteObject<UtilityOperation_Model>();
                
                return res;
            }
        }
    }
}
