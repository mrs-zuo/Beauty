using BLToolkit.Data;
using HS.Framework.Common.Entity;
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
    public class Login_DAL
    {
        #region 构造类实例
        public static Login_DAL Instance
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
            internal static readonly Login_DAL instance = new Login_DAL();
        }
        #endregion

        /// <summary>
        /// 美容师登陆信息更新
        /// </summary>
        /// <param name="mobile"></param>
        /// <returns></returns>
        public UtilityOperation_Model getUserInfo(int CompanyID, int BranchID, int UserID, string GUID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.CompanyID ,
                                                T1.BranchID ,
                                                T1.UserID ,
                                                T1.GUID,
                                                CASE T2.UserType WHEN 0 THEN 2 ELSE 1 END AS UserType        
                                        FROM    LOGIN T1 INNER JOIN dbo.[USER] T2 ON T1.UserID=T2.ID
                                      where T1.CompanyID=@CompanyID and T1.UserID =@UserID and T1.GUID=@GUID ";
                if (BranchID > 0)
                {
                    strSql += " and T1.BranchID =@BranchID ";
                }

                UtilityOperation_Model umodel = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                                                                    , db.Parameter("@UserID", UserID, DbType.Int32)
                                                                    , db.Parameter("@GUID", GUID, DbType.String)).ExecuteObject<UtilityOperation_Model>();
                return umodel;
            }
        }

        /// <summary>
        /// 客户登陆信息更新
        /// </summary>
        /// <param name="mobile"></param>
        /// <returns></returns>
        public ObjectResult<RoleForLogin_Model> updateLoginInfo(Login_Model loginModel)
        {
            using (DbManager db = new DbManager())
            {
                ObjectResult<RoleForLogin_Model> result = new ObjectResult<RoleForLogin_Model>();
                result.Code = "0";
                result.Message = "";
                result.Data = null;
                try
                {
                    //开始事务
                    db.BeginTransaction();
                    UtilityOperation_Model umodel = new UtilityOperation_Model();
                    string strSql = "";
                    #region 登陆

                    strSql = @" SELECT  T1.CompanyID ,
                                        T1.ID UserID
                                FROM    [USER] T1
                                        INNER JOIN [CUSTOMER] T2 WITH ( NOLOCK ) ON T1.ID = T2.UserID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.ID = @UserID
                                        AND T1.LoginMobile = @LoginMobile
                                        AND T1.Password = @Password
                                        AND T2.Available = 1 ";

                    string password = WebAPI.Common.DEncrypt.DEncrypt.Encrypt(loginModel.Password);
                    umodel = db.SetCommand(strSql
                                        , db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                        , db.Parameter("@UserID", loginModel.UserID, DbType.Int32)
                                        , db.Parameter("@LoginMobile", loginModel.LoginMobile, DbType.String)
                                        , db.Parameter("@Password", password, DbType.String)).ExecuteObject<UtilityOperation_Model>();
                    #endregion

                    if (umodel == null || umodel.CompanyID == 0 || umodel.UserID == 0)
                    {
                        result.Code = "-2";
                    }
                    else
                    {


                        //LOGIN表 DeviceType -- 设备类型  1:iOS、2:Android --ClientType 设备类型 1:商家 2:顾客 3：Web 4:Touch
                        //VERSION DeviceType    设备类型。1:iOS、2:Android      -- ClientType 客户端类型。1:商家 2:顾客 3：Web 4:Touch
                        //loginModel.ClientType 登陆类型  1:IOS,2:Android,3:Web 4:Touch
                        //loginModel.DeviceType 登陆的手机设备类型 1:IOS,2:Android
                        //loginModel.DeviceID   登陆的手机设备号 
                        //loginModel.UserType   0:顾客 1：商家

                        strSql = @" Insert into HISTORY_LOGIN 
                                             select * 
                                             From LOGIN 
                                             WHERE UserID =@UserID ";

                        int rows = db.SetCommand(strSql, db.Parameter("@UserID", loginModel.UserID, DbType.String)).ExecuteNonQuery();

                        StringBuilder strSqlUptLogin = new StringBuilder();
                        strSqlUptLogin.Append("update LOGIN set ");
                        strSqlUptLogin.Append(" CompanyID=@CompanyID,");
                        strSqlUptLogin.Append(" ClientType=@ClientType,");
                        if (loginModel.ClientType != 3 && loginModel.ClientType != 4 && !String.IsNullOrEmpty(loginModel.DeviceID))
                        {
                            strSqlUptLogin.Append(" DeviceID=@DeviceID,");
                            strSqlUptLogin.Append(" DeviceType=@DeviceType,");
                            strSqlUptLogin.Append(" OSVersion=@OSVersion, ");
                            strSqlUptLogin.Append(" DeviceModel=@DeviceModel, ");
                        }
                        if (!String.IsNullOrEmpty(loginModel.AppVersion))
                        {
                            strSqlUptLogin.Append(" AppVersion=@AppVersion,");
                        }
                        strSqlUptLogin.Append(" LoginTime=@LoginTime, ");
                        strSqlUptLogin.Append(" LoginTimes= LoginTimes + 1, ");
                        strSqlUptLogin.Append(" IPAddress=@IPAddress, ");
                        strSqlUptLogin.Append(" GUID=@GUID  ");
                        strSqlUptLogin.Append(" where UserID=@UserID ");
                        strSqlUptLogin.Append(" AND ClientType = @ClientType ");

                        rows = db.SetCommand(strSqlUptLogin.ToString(), db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                                                      , db.Parameter("@DeviceID", loginModel.DeviceID, DbType.String)
                                                                      , db.Parameter("@DeviceType", loginModel.DeviceType, DbType.Int32)
                                                                      , db.Parameter("@ClientType", loginModel.ClientType, DbType.Int32)
                                                                      , db.Parameter("@LoginTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                                      , db.Parameter("@LoginTimes", loginModel.LoginTimes, DbType.Int32)
                                                                      , db.Parameter("@IPAddress", loginModel.IPAddress, DbType.String)
                                                                      , db.Parameter("@UserID", loginModel.UserID, DbType.Int32)
                                                                      , db.Parameter("@AppVersion", loginModel.AppVersion, DbType.String)
                                                                      , db.Parameter("@OSVersion", loginModel.OSVersion, DbType.String)
                                                                      , db.Parameter("@DeviceModel", loginModel.DeviceModel, DbType.String)
                                                                      , db.Parameter("@GUID", loginModel.GUID, DbType.String)).ExecuteNonQuery();
                        if (rows == 0)
                        {
                            strSql = @"insert into LOGIN(CompanyID,UserID,DeviceType,DeviceID,LoginTime,LoginTimes,IPAddress,ClientType,AppVersion,OSVersion,GUID,DeviceModel)
                                                        values (
                                                        @CompanyID,@UserID,@DeviceType,@DeviceID,@LoginTime,@LoginTimes,@IPAddress,@ClientType,@AppVersion,@OSVersion,@GUID,@DeviceModel)";

                            rows = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                                                  , db.Parameter("@UserID", loginModel.UserID, DbType.Int32)
                                                                  , db.Parameter("@DeviceType", loginModel.DeviceType, DbType.Int32)
                                                                  , db.Parameter("@DeviceID", loginModel.DeviceID, DbType.String)
                                                                  , db.Parameter("@LoginTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                                  , db.Parameter("@LoginTimes", 1, DbType.Int32)
                                                                  , db.Parameter("@IPAddress", loginModel.IPAddress, DbType.String)
                                                                  , db.Parameter("@ClientType", loginModel.ClientType, DbType.Int32)
                                                                  , db.Parameter("@AppVersion", loginModel.AppVersion, DbType.String)
                                                                  , db.Parameter("@OSVersion", loginModel.OSVersion, DbType.String)
                                                                  , db.Parameter("@GUID", loginModel.GUID, DbType.String)
                                                                  , db.Parameter("@DeviceModel", loginModel.DeviceModel, DbType.String)).ExecuteNonQuery();
                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return result;
                            }
                        }

                        string strSqlCurrencySymbol = @"Select T2.CurrencySymbol
                                      FROM [COMPANY] T1 
									  LEFT JOIN [SYS_CURRENCY] T2 ON T1.SettlementCurrency = T2.ID
                                      WHERE T1.ID=@CompanyID    ";

                        string CurrencySymbol = db.SetCommand(strSqlCurrencySymbol, db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)).ExecuteScalar<string>();




                        RoleForLogin_Model model = new RoleForLogin_Model();
                        model.GUID = loginModel.GUID;
                        model.CompanyID = loginModel.CompanyID;
                        model.BranchID = loginModel.BranchID;
                        model.UserID = loginModel.UserID;
                        model.CurrencySymbol = CurrencySymbol;
                        result.Data = model;
                        result.Code = "1";
                    }


                    db.CommitTransaction();
                    return result;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="BranchID"></param>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public void logOut(string GUID, int CompanyID, int UserID, int ClientType)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"UPDATE dbo.LOGIN SET GUID = NULL WHERE CompanyID =@CompanyID  AND UserID = @UserID and GUID=@GUID AND ClientType=@ClientType ";

                db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                    , db.Parameter("@UserID", UserID, DbType.Int32)
                                    , db.Parameter("@GUID", GUID, DbType.String)
                                    , db.Parameter("@ClientType", ClientType, DbType.Int32)).ExecuteNonQuery();
            }
        }

        /// <summary>
        /// 客户登陆信息更新
        /// </summary>
        /// <param name="mobile"></param>
        /// <returns></returns>
        public ObjectResult<object> getCompanyListForCustomer(Login_Model loginModel)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Data = null;
            result.Message = "";
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT TOP 1 Version,
                        CASE WHEN @Version < (SELECT TOP 1 Version    FROM    SYS_VERSION
                        WHERE   DeviceType = @DeviceType
                                AND ClientType = @ClientType
                                AND MustUpgrade=1
                        ORDER BY ID DESC ) THEN 'true' ELSE 'false' end AS 'MustUpgrade'     
                        FROM    SYS_VERSION
                        WHERE   DeviceType = @DeviceType
                                AND ClientType = @ClientType
                        ORDER BY ID DESC";

                //LOGIN表 DeviceType -- 设备类型  1:iOS、2:Android --ClientType 设备类型 1:商家 2:顾客 3：Web 4:Touch
                //VERSION DeviceType    设备类型。1:iOS、2:Android      -- ClientType 客户端类型。1:商家 2:顾客 3：Web 4:Touch
                //loginModel.ClientType 登陆类型  0:Web,1:IOS,2:Android  3：Web 4:Touch
                //loginModel.DeviceType 登陆的手机设备类型 1:IOS,2:Android  3：Web 4:Touch
                //loginModel.DeviceID   登陆的手机设备号 
                //loginModel.UserType   0:顾客 1：商家
                VersionCheck_Model mustUpgradeModel = db.SetCommand(strSql, db.Parameter("@DeviceType", loginModel.DeviceType, DbType.Int32)
                                                         , db.Parameter("@Version", loginModel.AppVersion, DbType.String)
                                                         , db.Parameter("@ClientType", loginModel.ClientType, DbType.Int32)).ExecuteObject<VersionCheck_Model>();

                if (mustUpgradeModel != null && StringUtils.GetDbBool(mustUpgradeModel.MustUpgrade) && loginModel.ClientType != 3)
                {
                    result.Code = "-3";
                    result.Data = mustUpgradeModel;
                }
                else
                {
                    strSql = @" SELECT T1.ID CustomerID,T1.CompanyID,T7.Name CompanyName,T7.Abbreviation CompanyAbbreviation ,T7.CompanyCode,T7.CompanyScale,T4.BranchCount, T2.BranchID,T2.Name CustomerName, ISNULL(T5.Discount,1.00) Discount ,T7.CurrencySymbol,T7.Advanced,
                                              {0}{1}{2}{3}  + cast(T1.CompanyID as nvarchar(10)) + {4}/{5}{6}  + cast(T1.ID as nvarchar(10)) + '/'+ T2.HeadImageFile + {7} HeadImageURL 
                                              FROM [USER] T1 
                                              INNER JOIN [CUSTOMER] T2  on T1.ID = T2.UserID 
                                              INNER JOIN (SELECT T3.ID, T3.Name ,T3.Abbreviation  ,T3.CompanyCode,T3.CompanyScale ,T6.CurrencySymbol,T3.Advanced,T3.Available FROM COMPANY T3 LEFT JOIN [SYS_CURRENCY] T6 ON T3.SettlementCurrency = T6.ID ) T7  on T1.CompanyID = T7.ID 
                                              LEFT JOIN(select COUNT(*) BranchCount, companyId CompanyID from BRANCH where Available =1 group by companyId ) T4  on T4.CompanyID = T7.ID 
                                              LEFT JOIN  LEVEL T5  on T5.ID = T2.LevelID 
                                              WHERE T1.LoginMobile = @LoginMobile 
                                              AND T1.Password = @Password 
                                              AND T2.Available = 1 
                                              AND T7.Available = 1 ";

                    if (loginModel.CompanyID > 0)
                    {
                        strSql += " AND T1.CompanyID = @CompanyID ";
                    }


                    strSql = string.Format(strSql,
                           WebAPI.Common.Const.strHttp,
                           WebAPI.Common.Const.server,
                           WebAPI.Common.Const.strMothod,
                           WebAPI.Common.Const.strSingleMark,
                           WebAPI.Common.Const.strSingleMark,
                           WebAPI.Common.Const.strImageObjectType0,
                           WebAPI.Common.Const.strSingleMark,
                           WebAPI.Common.Const.strThumb);

                    string password = WebAPI.Common.DEncrypt.DEncrypt.Encrypt(loginModel.Password);
                    List<CompanyListForCustomerLogin_Model> list = new List<CompanyListForCustomerLogin_Model>();
                    list = db.SetCommand(strSql
                                        , db.Parameter("@LoginMobile", loginModel.LoginMobile, DbType.String)
                                        , db.Parameter("@Password", password, DbType.String)
                                        , db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                        , db.Parameter("@ImageHeight", loginModel.ImageHeight.ToString(), DbType.String)
                                        , db.Parameter("@ImageWidth", loginModel.ImageWidth.ToString(), DbType.String)).ExecuteList<CompanyListForCustomerLogin_Model>();

                    if (list.Count > 0)
                    {
                        result.Data = list;
                        result.Code = "1";
                    }
                    else
                    {
                        result.Code = "-1";
                    }
                }
            }
            return result;
        }

        public Login_Model getUserByWeChatOpenID(int companyID, string weChatOpenID)
        {
            using (DbManager db = new DbManager())
            {
                Login_Model model = new Login_Model();
                string strSql = @" SELECT  T1.CompanyID ,T1.UserID ,T2.Name AS CompanyName
                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                    INNER JOIN Company T2 WITH (NOLOCK) ON T2.ID=T1.CompanyID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND WeChatOpenID = @WeChatOpenID and T1.Available = 1 ";

                model = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@WeChatOpenID", weChatOpenID, DbType.String)).ExecuteObject<Login_Model>();

                return model;
            }
        }

        public ObjectResult<RoleForLogin_Model> updateLoginInfoForWeChat(Login_Model loginModel)
        {
            using (DbManager db = new DbManager())
            {
                ObjectResult<RoleForLogin_Model> result = new ObjectResult<RoleForLogin_Model>();
                result.Code = "0";
                result.Message = "";
                result.Data = null;
                try
                {
                    //开始事务
                    db.BeginTransaction();
                    string strSql = "";

                    UtilityOperation_Model umodel = new UtilityOperation_Model(); ;
                    #region 登陆

                    strSql = @"SELECT  T1.CompanyID ,
                                        T1.ID UserID
                                FROM    [USER] T1 WITH ( NOLOCK )
                                        INNER JOIN [CUSTOMER] T2 WITH ( NOLOCK ) ON T1.ID = T2.UserID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.ID = @UserID
                                        AND T2.WeChatOpenID = @WeChatOpenID
                                        AND T1.UserType = 0 
                                        AND T2.Available = 1 ";

                    umodel = db.SetCommand(strSql
                                        , db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                        , db.Parameter("@UserID", loginModel.UserID, DbType.Int32)
                                        , db.Parameter("@WeChatOpenID", loginModel.WXOpenID, DbType.String)
                                        , db.Parameter("@ClientType", loginModel.ClientType, DbType.Int32)).ExecuteObject<UtilityOperation_Model>();
                    #endregion

                    if (umodel == null || umodel.CompanyID == 0 || umodel.UserID == 0)
                    {
                        result.Code = "-2";
                    }
                    else
                    {
                        //LOGIN表 DeviceType -- 设备类型  1:iOS、2:Android --ClientType 设备类型 1:商家 2:顾客 3：Web 4:Touch
                        //VERSION DeviceType    设备类型。1:iOS、2:Android      -- ClientType 客户端类型。1:商家 2:顾客 3：Web 4:Touch
                        //loginModel.ClientType 登陆类型  1:IOS,2:Android,3:Web 4:Touch
                        //loginModel.DeviceType 登陆的手机设备类型 1:IOS,2:Android
                        //loginModel.DeviceID   登陆的手机设备号 
                        //loginModel.UserType   0:顾客 1：商家

                        strSql = @" Insert into HISTORY_LOGIN 
                                             select * 
                                             From LOGIN 
                                             WHERE UserID =@UserID ";

                        int rows = db.SetCommand(strSql, db.Parameter("@UserID", loginModel.UserID, DbType.String)).ExecuteNonQuery();

                        StringBuilder strSqlUptLogin = new StringBuilder();
                        strSqlUptLogin.Append("update LOGIN set ");
                        strSqlUptLogin.Append(" CompanyID=@CompanyID,");
                        strSqlUptLogin.Append(" ClientType=@ClientType,");
                        if (loginModel.ClientType != 3 && loginModel.ClientType != 4 && !String.IsNullOrEmpty(loginModel.DeviceID))
                        {
                            strSqlUptLogin.Append(" DeviceID=@DeviceID,");
                            strSqlUptLogin.Append(" DeviceType=@DeviceType,");
                            strSqlUptLogin.Append(" OSVersion=@OSVersion, ");
                            strSqlUptLogin.Append(" DeviceModel=@DeviceModel, ");
                        }
                        if (!String.IsNullOrEmpty(loginModel.AppVersion))
                        {
                            strSqlUptLogin.Append(" AppVersion=@AppVersion,");
                        }
                        strSqlUptLogin.Append(" LoginTime=@LoginTime, ");
                        strSqlUptLogin.Append(" LoginTimes= LoginTimes + 1, ");
                        strSqlUptLogin.Append(" IPAddress=@IPAddress, ");
                        strSqlUptLogin.Append(" GUID=@GUID  ");
                        strSqlUptLogin.Append(" where UserID=@UserID ");
                        strSqlUptLogin.Append(" AND ClientType = @ClientType ");

                        rows = db.SetCommand(strSqlUptLogin.ToString(), db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                                                      , db.Parameter("@DeviceID", loginModel.DeviceID, DbType.String)
                                                                      , db.Parameter("@DeviceType", loginModel.DeviceType, DbType.Int32)
                                                                      , db.Parameter("@ClientType", loginModel.ClientType, DbType.Int32)
                                                                      , db.Parameter("@LoginTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                                      , db.Parameter("@LoginTimes", loginModel.LoginTimes, DbType.Int32)
                                                                      , db.Parameter("@IPAddress", loginModel.IPAddress, DbType.String)
                                                                      , db.Parameter("@UserID", loginModel.UserID, DbType.Int32)
                                                                      , db.Parameter("@AppVersion", loginModel.AppVersion, DbType.String)
                                                                      , db.Parameter("@OSVersion", loginModel.OSVersion, DbType.String)
                                                                      , db.Parameter("@DeviceModel", loginModel.DeviceModel, DbType.String)
                                                                      , db.Parameter("@GUID", loginModel.GUID, DbType.String)).ExecuteNonQuery();
                        if (rows == 0)
                        {
                            strSql = @"insert into LOGIN(CompanyID,UserID,DeviceType,DeviceID,LoginTime,LoginTimes,IPAddress,ClientType,AppVersion,OSVersion,GUID,DeviceModel)
                                                        values (
                                                        @CompanyID,@UserID,@DeviceType,@DeviceID,@LoginTime,@LoginTimes,@IPAddress,@ClientType,@AppVersion,@OSVersion,@GUID,@DeviceModel)";

                            rows = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                                                  , db.Parameter("@UserID", loginModel.UserID, DbType.Int32)
                                                                  , db.Parameter("@DeviceType", loginModel.DeviceType, DbType.Int32)
                                                                  , db.Parameter("@DeviceID", loginModel.DeviceID, DbType.String)
                                                                  , db.Parameter("@LoginTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                                  , db.Parameter("@LoginTimes", 1, DbType.Int32)
                                                                  , db.Parameter("@IPAddress", loginModel.IPAddress, DbType.String)
                                                                  , db.Parameter("@ClientType", loginModel.ClientType, DbType.Int32)
                                                                  , db.Parameter("@AppVersion", loginModel.AppVersion, DbType.String)
                                                                  , db.Parameter("@OSVersion", loginModel.OSVersion, DbType.String)
                                                                  , db.Parameter("@GUID", loginModel.GUID, DbType.String)
                                                                  , db.Parameter("@DeviceModel", loginModel.DeviceModel, DbType.String)).ExecuteNonQuery();
                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return result;
                            }
                        }

                        string strSqlCurrencySymbol = @"Select T2.CurrencySymbol
                                      FROM [COMPANY] T1 
									  LEFT JOIN [SYS_CURRENCY] T2 ON T1.SettlementCurrency = T2.ID
                                      WHERE T1.ID=@CompanyID    ";

                        string CurrencySymbol = db.SetCommand(strSqlCurrencySymbol, db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)).ExecuteScalar<string>();



                        RoleForLogin_Model model = new RoleForLogin_Model();
                        model.GUID = loginModel.GUID;
                        model.CompanyID = loginModel.CompanyID;
                        model.BranchID = loginModel.BranchID;
                        model.UserID = loginModel.UserID;
                        model.CurrencySymbol = CurrencySymbol;
                        result.Data = model;
                        result.Code = "1";
                        db.CommitTransaction();
                    }
                    return result;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public ObjectResult<CompanyListForCustomerLogin_Model> bindWeChatOpenID(Login_Model loginModel, string fileName, int sex)
        {
            ObjectResult<CompanyListForCustomerLogin_Model> result = new ObjectResult<CompanyListForCustomerLogin_Model>();
            result.Code = "0";
            result.Data = null;
            CompanyListForCustomerLogin_Model model = new CompanyListForCustomerLogin_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.CompanyID ,
                                            T1.ID UserID ,
                                            T2.WeChatOpenID ,
                                            T2.HeadImageFile AS FileName ,
                                            ISNULL(T2.Gender, 3) as Gender
                                    FROM    [USER] T1 WITH(NOLOCK)
                                    INNER JOIN [CUSTOMER] T2 WITH(NOLOCK) ON T1.ID=T2.UserID
                                    WHERE   T1.CompanyID = @CompanyID 
                                            AND T1.LoginMobile = @LoginMobile
                                            AND T1.Password = @Password
											AND T2.Available = 1";
                string password = WebAPI.Common.DEncrypt.DEncrypt.Encrypt(loginModel.Password);

                UtilityOperation_Model umodel = db.SetCommand(strSql
                                        , db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                        , db.Parameter("@UserID", loginModel.UserID, DbType.Int32)
                                        , db.Parameter("@LoginMobile", loginModel.LoginMobile, DbType.String)
                                        , db.Parameter("@Password", password, DbType.String)).ExecuteObject<UtilityOperation_Model>();

                if (umodel == null || umodel.CompanyID == 0 || umodel.UserID == 0)
                {
                    result.Message = "账户名密码错误";
                    return result;
                }

                if (string.IsNullOrWhiteSpace(umodel.WeChatOpenID) && !string.IsNullOrWhiteSpace(loginModel.WXOpenID))
                {
                    string strUpdateOpenID = @"UPDATE  [CUSTOMER]
                                                    SET     WeChatOpenID = @WeChatOpenID 
                                                            ,WeChatUnionID = @WeChatUnionID";
                    if (umodel.Gender == 3 && sex > 0)
                    {
                        if (sex == 2)
                        {
                            sex = 0;
                        }
                        strUpdateOpenID += " ,Gender = @Gender  ";
                    }

                    if (string.IsNullOrWhiteSpace(umodel.FileName) && !string.IsNullOrWhiteSpace(fileName))
                    {
                        strUpdateOpenID += " ,HeadImageFile = @HeadImageFile ";
                    }

                    strUpdateOpenID += @" WHERE   CompanyID = @CompanyID
                                                            AND UserID = @UserID";
                    int updateRes = db.SetCommand(strUpdateOpenID
                                    , db.Parameter("@WeChatOpenID", loginModel.WXOpenID, DbType.String)
                                    , db.Parameter("@WeChatUnionID", loginModel.WXUnionID, DbType.String)
                                    , db.Parameter("@CompanyID", umodel.CompanyID, DbType.Int32)
                                    , db.Parameter("@UserID", umodel.UserID, DbType.Int32)
                                    , db.Parameter("@Gender", sex, DbType.Int32)
                                    , db.Parameter("@HeadImageFile", fileName, DbType.String)).ExecuteNonQuery();

                    if (updateRes <= 0)
                    {
                        result.Message = "登录异常";
                        return result;
                    }
                }
                else
                {
                    result.Message = "该账号已绑定其他账号,请先解绑再进行登录";
                    return result;
                }

                strSql = @" SELECT T1.ID CustomerID,T1.CompanyID,T7.Name CompanyName,T7.Abbreviation CompanyAbbreviation ,T7.CompanyCode,T7.CompanyScale,T4.BranchCount, T2.BranchID,T2.Name CustomerName, ISNULL(T5.Discount,1.00) Discount ,T7.CurrencySymbol,T7.Advanced,
                                              {0}{1}{2}{3}  + cast(T1.CompanyID as nvarchar(10)) + {4}/{5}{6}  + cast(T1.ID as nvarchar(10)) + '/'+ T2.HeadImageFile + {7} HeadImageURL 
                                              FROM [USER] T1 
                                              INNER JOIN [CUSTOMER] T2  on T1.ID = T2.UserID 
                                              INNER JOIN (SELECT T3.ID, T3.Name ,T3.Abbreviation  ,T3.CompanyCode,T3.CompanyScale ,T6.CurrencySymbol,T3.Advanced,T3.Available FROM COMPANY T3 LEFT JOIN [SYS_CURRENCY] T6 ON T3.SettlementCurrency = T6.ID ) T7  on T1.CompanyID = T7.ID 
                                              LEFT JOIN(select COUNT(*) BranchCount, companyId CompanyID from BRANCH where Available =1 group by companyId ) T4  on T4.CompanyID = T7.ID 
                                              LEFT JOIN  LEVEL T5  on T5.ID = T2.LevelID 
                                              WHERE T1.LoginMobile = @LoginMobile 
                                              AND T1.Password = @Password 
                                              AND T2.Available = 1 
                                              AND T7.Available = 1 
                                              AND T1.CompanyID = @CompanyID ";

                strSql = string.Format(strSql,
                       WebAPI.Common.Const.strHttp,
                       WebAPI.Common.Const.server,
                       WebAPI.Common.Const.strMothod,
                       WebAPI.Common.Const.strSingleMark,
                       WebAPI.Common.Const.strSingleMark,
                       WebAPI.Common.Const.strImageObjectType0,
                       WebAPI.Common.Const.strSingleMark,
                       WebAPI.Common.Const.strThumb);

                model = db.SetCommand(strSql
                                    , db.Parameter("@LoginMobile", loginModel.LoginMobile, DbType.String)
                                    , db.Parameter("@Password", password, DbType.String)
                                    , db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@ImageHeight", loginModel.ImageHeight.ToString(), DbType.String)
                                    , db.Parameter("@ImageWidth", loginModel.ImageWidth.ToString(), DbType.String)).ExecuteObject<CompanyListForCustomerLogin_Model>();


            }

            if (model != null)
            {
                result.Code = "1";
                result.Data = model;
            }
            return result;
        }


        public bool updateUserPassword(int userId, string oldPassword, string newPassword)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSql = @"select count(0)
                                      from [USER] WITH (ROWLOCK,HOLDLOCK) 
                                      where ID=@userId and Password = @Password";
                    int count = db.SetCommand(strSql, db.Parameter("@userId", userId, DbType.Int32)
                                                , db.Parameter("@Password", WebAPI.Common.DEncrypt.DEncrypt.Encrypt(oldPassword), DbType.String)).ExecuteScalar<int>();
                    if (count != 1)
                    {
                        return false;
                    }
                    else
                    {
                        string strSqlHistoryUser = " INSERT INTO [HISTORY_USER] SELECT * FROM [USER] WHERE ID=@userId ";
                        int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@userId", userId, DbType.Int32)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        strSql = @" update [USER] set 
                                    Password=@newPassword
                                    where ID=@userId";

                        string EncryptedNewPWD = WebAPI.Common.DEncrypt.DEncrypt.Encrypt(newPassword);

                        int rows = db.SetCommand(strSql, db.Parameter("@newPassword", EncryptedNewPWD, DbType.String)
                                                       , db.Parameter("@userId", userId)).ExecuteNonQuery();
                        if (rows > 0)
                        {
                            db.CommitTransaction();
                            return true;
                        }
                        else
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public ObjectResult<List<CompanyListByLoginMobile_Model>> getCompanyListByLoginMobile(string LoginMobile, int CompanyID)
        {
            ObjectResult<List<CompanyListByLoginMobile_Model>> result = new ObjectResult<List<CompanyListByLoginMobile_Model>>();
            result.Code = "0";
            result.Data = null;
            result.Message = "";

            using (DbManager db = new DbManager())
            {
                string strSql = @"
                                    select T1.ID UserID,T2.Name,T2.ID CompanyID,T2.Abbreviation CompanyAbbreviation from [USER] T1 
                                    inner join [COMPANY] T2 on T1.CompanyID = T2.ID 
                                    inner join [CUSTOMER] T3 on T3.UserID = T1.ID 
                                    where T1.LoginMobile = @LoginMobile 
                                    and T2.Available = 1 
                                    and T3.Available = 1 ";
                if (CompanyID > 0)
                {
                    strSql += " and T2.ID =@CompanyID";
                }
                List<CompanyListByLoginMobile_Model> list = new List<CompanyListByLoginMobile_Model>();

                list = db.SetCommand(strSql, db.Parameter("@LoginMobile", LoginMobile, DbType.String)
                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteList<CompanyListByLoginMobile_Model>();

                if (list != null)
                {
                    result.Data = list;
                    result.Code = "1";
                }
            }

            return result;
        }


        public bool updateUserPassword(Login_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlCommand = @"SELECT  COUNT(*)
                                            FROM    dbo.[USER] T1
                                                    INNER JOIN dbo.CUSTOMER T2 ON T1.ID = T2.UserID
                                                                                  AND T2.Available = 1
                                            WHERE   LoginMobile = @LoginMobile
                                                    AND ID IN ({0}) ";
                    string strCustomerID = "";
                    if (model.CustomerIDList != null && model.CustomerIDList.Count > 0)
                    {
                        for (int i = 0; i < model.CustomerIDList.Count; i++)
                        {
                            if (i != 0)
                            {
                                strCustomerID += ",";
                            }
                            strCustomerID += model.CustomerIDList[i];
                        }
                    }
                    strSqlCommand = string.Format(strSqlCommand, strCustomerID);

                    int count = db.SetCommand(strSqlCommand, db.Parameter("@LoginMobile", model.LoginMobile, DbType.String)).ExecuteScalar<int>();
                    if (count != model.CustomerIDList.Count)
                    {
                        return false;
                    }
                    else
                    {
                        string strSqlHistoryUser = " INSERT INTO [HISTORY_USER] SELECT * FROM [USER] WHERE ID in({0}) ";
                        strSqlHistoryUser = string.Format(strSqlHistoryUser, strCustomerID);
                        int hisRows = db.SetCommand(strSqlHistoryUser).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        strSqlCommand = @"update [USER] set 
                                          Password=@newPassword
                                          where ID in({0})";
                        strSqlCommand = string.Format(strSqlCommand, strCustomerID);

                        string EncryptedNewPWD = WebAPI.Common.DEncrypt.DEncrypt.Encrypt(model.Password);
                        int rows = db.SetCommand(strSqlCommand, db.Parameter("@newPassword", EncryptedNewPWD, DbType.String)).ExecuteNonQuery();
                        if (rows > 0 && rows == model.CustomerIDList.Count)
                        {
                            db.CommitTransaction();
                            return true;
                        }
                        else
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public bool unBindWeChat(string GUID, int CompanyID, int UserID, int ClientType)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSql = @"UPDATE dbo.LOGIN SET GUID = NULL WHERE CompanyID =@CompanyID  AND UserID = @UserID and GUID=@GUID AND ClientType=@ClientType ";

                int rows = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                     , db.Parameter("@UserID", UserID, DbType.Int32)
                                     , db.Parameter("@GUID", GUID, DbType.String)
                                     , db.Parameter("@ClientType", ClientType, DbType.Int32)).ExecuteNonQuery();
                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlCustom = @"UPDATE  [CUSTOMER]
                              SET WeChatOpenID = null 
                              ,WeChatUnionID = null
                               WHERE   CompanyID = @CompanyID
                               AND UserID = @UserID";

                rows = db.SetCommand(strSqlCustom, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                   , db.Parameter("@UserID", UserID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;
            }

        }


    }
}
