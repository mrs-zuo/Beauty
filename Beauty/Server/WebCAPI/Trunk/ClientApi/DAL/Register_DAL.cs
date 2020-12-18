using BLToolkit.Data;
using HS.Framework.Common.Util;
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
    public class Register_DAL
    {

        #region 构造类实例
        public static Register_DAL Instance
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
            internal static readonly Register_DAL instance = new Register_DAL();
        }
        #endregion


        public int RegisterUser(RegisterOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlExist = @"SELECT  COUNT(0)
                                  FROM    [USER] T1
                                          INNER JOIN dbo.CUSTOMER T2 ON T1.ID = T2.UserID
                                  WHERE   T1.LoginMobile = @LoginMobile
                                          AND T2.Available = 1 and T1.CompanyID = @CompanyID ";

                int res = db.SetCommand(strSqlExist, db.Parameter("@LoginMobile", model.LoginMobile, DbType.String)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.String)).ExecuteScalar<int>();

                if (res > 0)
                {
                    db.RollbackTransaction();
                    return -1;
                }


                string strSql = @" INSERT INTO [USER]
                               (CompanyID,UserType,Password,LoginMobile)
                                 VALUES
                               (@CompanyID,0 ,@Password,@LoginMobile)
                                ;select @@IDENTITY ";

                string EncryptedNewPWD = WebAPI.Common.DEncrypt.DEncrypt.Encrypt(model.Password);
                int userId = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@Password", EncryptedNewPWD, DbType.String)
                        , db.Parameter("@LoginMobile", model.LoginMobile, DbType.String)).ExecuteScalar<int>();

                if (userId < 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }


                string name = "自助注册" + model.LoginMobile.Substring(model.LoginMobile.Length - 4);

                string strSqlCustomer = @" INSERT INTO [CUSTOMER]
                                        (CompanyID,BranchID,UserID,Name,Gender,LevelID,Available,CreatorID,CreateTime,RegistFrom)
                                         VALUES
                                        (@CompanyID,@BranchID,@UserID,@Name,0,0,1,@CreatorID,@CreateTime,2) ";

                int rows = db.SetCommand(strSqlCustomer, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                        , db.Parameter("@UserID", userId, DbType.Int32)
                        , db.Parameter("@Name", name, DbType.String)
                        , db.Parameter("@CreatorID", userId, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }



                string strSqlPhone = @" INSERT INTO [PHONE]
                                        (CompanyID,UserID,Type,PhoneNumber,Available,CreatorID,CreateTime)
                                         VALUES
                                        (@CompanyID,@UserID,0,@PhoneNumber,1,@CreatorID,@CreateTime) ";

                rows = db.SetCommand(strSqlPhone, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@UserID", userId, DbType.Int32)
                        , db.Parameter("@PhoneNumber", model.LoginMobile, DbType.String)
                        , db.Parameter("@CreatorID", userId, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strSqlConsultant = @"  select DefaultConsultant from [BRANCH]  with (nolock) where ID=@BranchID and CompanyID=@CompanyID ";

                int Consultant = db.SetCommand(strSqlConsultant, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                       , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();

                if (Consultant < 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strSqlRelat = @" INSERT INTO [RELATIONSHIP]
                                    (CompanyID,AccountID,CustomerID,Available,CreatorID,CreateTime,BranchID,Type)
                                     VALUES
                                    (@CompanyID,@AccountID,@CustomerID,1,@CreatorID,@CreateTime,@BranchID,1) ";

                rows = db.SetCommand(strSqlRelat, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                         , db.Parameter("@AccountID", Consultant, DbType.Int32)
                          , db.Parameter("@CustomerID", userId, DbType.Int32)
                          , db.Parameter("@CreatorID", userId, DbType.Int32)
                          , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                          , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteNonQuery();
                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strSqlPolicy = @" select T1.PolicyID,T1.ValidDays from [TBL_BENEFIT_POLICY] T1 WITH (NOLOCK) INNER JOIN [TBL_POLICY_BRANCH] T2 WITH (NOLOCK) ON T1.PolicyID = T2.PolicyID AND T2.BranchID =@BranchID  WHERE GETDATE() > T1.StartDate AND T1.Amount > 0 AND T1.CompanyID =@CompanyID and T1.RecordType =1 ";

                List<CustomerBenefit_Model> listPolicy = db.SetCommand(strSqlPolicy, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                          , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<CustomerBenefit_Model>();

                if (listPolicy != null && listPolicy.Count > 0)
                {
                    DateTime GrantDate = DateTime.Now.Date;


                    string strSqlCustomerBenefit = @" INSERT INTO [TBL_CUSTOMER_BENEFIT]
                                                    (UserID,PolicyID,BenefitID,BenefitStatus,GrantDate,ValidDate,CompanyID,CreatorID,CreateTime,RecordType)
                                                     VALUES
                                                    (@UserID,@PolicyID,@BenefitID,1,@GrantDate,@ValidDate,@CompanyID,@CreatorID,@CreateTime,1)";
                    foreach (CustomerBenefit_Model item in listPolicy)
                    {
                        string CustomerBenfitID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CustomerBenefitID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();
                        if (string.IsNullOrWhiteSpace(CustomerBenfitID))
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        DateTime ValidDate = GrantDate.AddDays(item.ValidDays + 1).AddSeconds(-1);
                        //if (item.ValidDays == 0)
                        //{
                        //    ValidDate = GrantDate.AddDays(1).AddSeconds(-1);
                        //}
                        //else
                        //{
                        //    ValidDate = GrantDate.AddDays(item.ValidDays).AddSeconds(-1);
                        //}

                        rows = db.SetCommand(strSqlCustomerBenefit,
                            db.Parameter("@UserID", userId, DbType.Int32)
                          , db.Parameter("@PolicyID", item.PolicyID, DbType.String)
                          , db.Parameter("@BenefitID", CustomerBenfitID, DbType.String)
                          , db.Parameter("@GrantDate", GrantDate, DbType.DateTime2)
                          , db.Parameter("@ValidDate", ValidDate, DbType.DateTime2)
                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                          , db.Parameter("@CreatorID", userId, DbType.Int32)
                          , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strSqlUpdateAmount = @" update TBL_BENEFIT_POLICY set Amount = Amount - 1 ,UpdaterID=@UpdaterID, UpdateTime=@UpdateTime  where PolicyID =@PolicyID and CompanyID=@CompanyID ";

                        rows = db.SetCommand(strSqlUpdateAmount
                                        , db.Parameter("@UpdaterID", userId, DbType.Int32)
                                        , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                                        , db.Parameter("@PolicyID", item.PolicyID, DbType.String)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }


                    }
                }

                #region 现金卷和积分账户
                string strSqlPoint = " select ID CardID,VaildPeriod,ValidPeriodUnit,CardCode from MST_CARD where CompanyID =@CompanyID  and CardTypeID =@CardTypeID ";


                string strSqlInsertCustomer = @" INSERT INTO [TBL_CUSTOMER_CARD]
                                                (CompanyID,BranchID,UserID,UserCardNo,CardID,Currency,Balance,CardCreatedDate,CardExpiredDate,CreatorID,CreateTime)
                                                 VALUES
                                                (@CompanyID,@BranchID,@UserID,@UserCardNo,@CardID,@Currency,@Balance,@CardCreatedDate,@CardExpiredDate,@CreatorID,@CreateTime) ";

                for (int i = 2; i <= 3; i++)
                {
                    GetMstCard_Model mCard = db.SetCommand(strSqlPoint, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                       , db.Parameter("@CardTypeID", i, DbType.Int32)).ExecuteObject<GetMstCard_Model>();

                    if (mCard == null)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    long UserCardNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "UserCardNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();

                    if (UserCardNo <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    DateTime start = DateTime.Now.ToLocalTime();
                    DateTime end;
                    switch (mCard.ValidPeriodUnit)
                    {
                        case 1:
                            end = start.AddYears(mCard.VaildPeriod);
                            break;
                        case 2:
                            end = start.AddMonths(mCard.VaildPeriod);
                            break;
                        case 3:
                            end = start.AddDays(mCard.VaildPeriod);
                            break;
                        default:
                            end = StringUtils.GetDateTime("2099/12/31");
                            break;

                    }


                    rows = db.SetCommand(strSqlInsertCustomer
                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                          , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                          , db.Parameter("@UserID", userId, DbType.Int32)
                          , db.Parameter("@UserCardNo", UserCardNo, DbType.Int64)
                          , db.Parameter("@CardID", mCard.CardID, DbType.Int32)
                          , db.Parameter("@Currency", "￥ ", DbType.String)
                          , db.Parameter("@Balance", 0, DbType.Decimal)
                          , db.Parameter("@CardCreatedDate", start, DbType.Date)
                          , db.Parameter("@CardExpiredDate", end, DbType.Date)
                          , db.Parameter("@CreatorID", userId, DbType.Int32)
                          , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                    if (rows != 1)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                #endregion

                db.CommitTransaction();
                return 1;
            }
        }

    }
}
