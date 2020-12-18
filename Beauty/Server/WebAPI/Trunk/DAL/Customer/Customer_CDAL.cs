using BLToolkit.Data;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL.Customer
{
    public class Customer_CDAL
    {
        #region 构造类实例
        public static Customer_CDAL Instance
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
            internal static readonly Customer_CDAL instance = new Customer_CDAL();
        }
        #endregion

        public CustomerBasic_Model GetCustomerBasic(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                CustomerBasic_Model model = null;

                StringBuilder strSqlCustomer = new StringBuilder();
                strSqlCustomer.Append(" select T1.UserID CustomerID, T1.Name CustomerName, T1.Title, T4.LoginMobile ,ISNULL(T6.UserID, 0) AS ResponsiblePersonID ,ISNULL(T6.Name,'') AS ResponsiblePersonName, ISNULL(T8.UserID, 0) AS SalesID ,ISNULL(T8.Name,'') AS SalesName,T1.IsPast ,T1.Gender ,");
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
                strSqlCustomer.Append(" LEFT JOIN [RELATIONSHIP] T7 ON T7.CustomerID = T1.UserID AND T7.Available = 1 AND T7.BranchID = @BranchID AND T7.Type=2");
                strSqlCustomer.Append(" Left JOIN [Account] T8 ON T8.UserID = T7.AccountID AND T8.Available = 1 ");
                strSqlCustomer.Append(" Where T1.UserID = @UserID ");

                model = db.SetCommand(strSqlCustomer.ToString(), db.Parameter("@UserID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight, DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth, DbType.String)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteObject<CustomerBasic_Model>();

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
                return model;

            }
        }

        public CustomerInfo_Model GetCustomerInfo(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                CustomerInfo_Model model = null;

                StringBuilder strSqlCustomer = new StringBuilder();
                strSqlCustomer.Append(" select  T1.Name CustomerName, T4.LoginMobile ,ISNULL(T6.UserID, 0) AS ResponsiblePersonID ,");
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


                string strSql = @"SELECT  COUNT(0)
                            FROM    dbo.TBL_TASK
                            WHERE   CompanyID = @CompanyID
                                    AND BranchID = @BranchID
                                    AND TaskOwnerID = @CustomerID
                                    AND ( TaskStatus = 1 OR TaskStatus = 2 )";
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
    }
}
