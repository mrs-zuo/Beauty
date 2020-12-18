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

namespace WebAPI.DAL.Customer
{
    public class Login_CDAL
    {
        #region 构造类实例
        public static Login_CDAL Instance
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
            internal static readonly Login_CDAL instance = new Login_CDAL();
        }
        #endregion

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

                //LOGIN表 DeviceType -- 设备类型  1:iOS、2:Android --ClientType 设备类型 1:商家 2:顾客 3：Web
                //VERSION DeviceType    设备类型。1:iOS、2:Android      -- ClientType 客户端类型。1:商家 2:顾客 3：Web
                //loginModel.ClientType 登陆类型  0:Web,1:IOS,2:Android
                //loginModel.DeviceType 登陆的手机设备类型 1:IOS,2:Android
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
                    strSql = @" select T1.ID CustomerID,T1.CompanyID,T7.Name CompanyName,T7.Abbreviation CompanyAbbreviation ,T7.CompanyCode,T7.CompanyScale,T4.BranchCount, T2.BranchID,T2.Name CustomerName, ISNULL(T5.Discount,1.00) Discount ,T7.CurrencySymbol,T7.Advanced,
                                              {0}{1}{2}{3}  + cast(T1.CompanyID as nvarchar(10)) + {4}/{5}{6}  + cast(T1.ID as nvarchar(10)) + '/'+ T2.HeadImageFile + {7} HeadImageURL 
                                              from [USER] T1 
                                              inner join [CUSTOMER] T2 
                                              on T1.ID = T2.UserID 
                                              inner join (SELECT T3.ID, T3.Name ,T3.Abbreviation  ,T3.CompanyCode,T3.CompanyScale ,T6.CurrencySymbol,T3.Advanced,T3.Available FROM COMPANY T3 LEFT JOIN [SYS_CURRENCY] T6 ON T3.SettlementCurrency = T6.ID ) T7 
                                              on T1.CompanyID = T7.ID 
                                              left join( 
                                              select COUNT(*) BranchCount, companyId CompanyID from BRANCH where Available =1 group by companyId ) T4 
                                              on T4.CompanyID = T7.ID 
                                              LEFT JOIN  LEVEL T5 
                                              on T5.ID = T2.LevelID 
                                              where T1.LoginMobile = @LoginMobile 
                                              and T1.Password = @Password 
                                              and T2.Available = 1 
                                              and T7.Available = 1 ";

                    strSql = string.Format(strSql,
                           Common.Const.strHttp,
                           Common.Const.server,
                           Common.Const.strMothod,
                           Common.Const.strSingleMark,
                           Common.Const.strSingleMark,
                           Common.Const.strImageObjectType0,
                           Common.Const.strSingleMark,
                           Common.Const.strThumb);

                    string password = Common.DEncrypt.DEncrypt.Encrypt(loginModel.Password);
                    List<CompanyListForCustomerLogin_Model> list = new List<CompanyListForCustomerLogin_Model>();
                    list = db.SetCommand(strSql
                                        , db.Parameter("@LoginMobile", loginModel.LoginMobile, DbType.String)
                                        , db.Parameter("@Password", password, DbType.String)
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

        public ObjectResult<List<CompanyListByLoginMobile_Model>> getCompanyListByLoginMobile(string LoginMobile)
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
                List<CompanyListByLoginMobile_Model> list = new List<CompanyListByLoginMobile_Model>();

                list = db.SetCommand(strSql, db.Parameter("@LoginMobile", LoginMobile, DbType.String)).ExecuteList<CompanyListByLoginMobile_Model>();

                if (list != null)
                {
                    result.Data = list;
                    result.Code = "1";
                }
            }

            return result;
        }

        /// <summary>
        /// 美容师登陆信息更新
        /// </summary>
        /// <param name="mobile"></param>
        /// <returns></returns>
        public ObjectResult<RoleForLogin_Model> updateLoginInfo(Login_Model loginModel, bool isBussiness)
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
                    if (isBussiness)
                    {
                        strSql = @"Select T1.CompanyID,T2.BranchID,T1.ID UserID 
                                      from [USER] T1 inner join 
                                      TBL_ACCOUNTBRANCH_RELATIONSHIP T2 on T1.ID = T2.UserID 
                                      where T1.CompanyID=@CompanyID and T2.BranchID =@BranchID and T1.ID =@UserID  and T1.LoginMobile =@LoginMobile and T1.Password=@Password ";

                    }
                    else
                    {
                        strSql = @"Select T1.CompanyID,T1.ID UserID 
                                      from [USER] T1 
                                      where T1.CompanyID=@CompanyID and T1.ID =@UserID and T1.LoginMobile =@LoginMobile and T1.Password=@Password ";
                    }


                    string password = Common.DEncrypt.DEncrypt.Encrypt(loginModel.Password);
                    umodel = db.SetCommand(strSql
                                        , db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                        , db.Parameter("@BranchID", loginModel.BranchID, DbType.Int32)
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
                        strSql = @"SELECT TOP 1
                        CASE WHEN @Version < (SELECT TOP 1 Version    FROM    SYS_VERSION
                        WHERE   DeviceType = @DeviceType
                                AND ClientType = @ClientType
                                AND MustUpgrade=1
                        ORDER BY ID DESC ) THEN 'true' ELSE 'false' end AS 'MustUpgrade'     
                        FROM    SYS_VERSION
                        WHERE   DeviceType = @DeviceType
                                AND ClientType = @ClientType
                        ORDER BY ID DESC";

                        //LOGIN表 DeviceType -- 设备类型  1:iOS、2:Android --ClientType 设备类型 1:商家 2:顾客 3：Web
                        //VERSION DeviceType    设备类型。1:iOS、2:Android      -- ClientType 客户端类型。1:商家 2:顾客 3：Web
                        //loginModel.ClientType 登陆类型  1:IOS,2:Android,3:Web
                        //loginModel.DeviceType 登陆的手机设备类型 1:IOS,2:Android
                        //loginModel.DeviceID   登陆的手机设备号 
                        //loginModel.UserType   0:顾客 1：商家
                        object mustUpgrade = db.SetCommand(strSql, db.Parameter("@DeviceType", loginModel.DeviceType, DbType.Int32)
                                                                 , db.Parameter("@Version", loginModel.AppVersion, DbType.String)
                                                                 , db.Parameter("@ClientType", loginModel.ClientType, DbType.Int32)).ExecuteScalar();

                        if (StringUtils.GetDbBool(mustUpgrade) && loginModel.ClientType != 3)
                        {
                            result.Code = "-3";
                        }
                        else
                        {
                            strSql = @" Insert into HISTORY_LOGIN 
                                             select * 
                                             From LOGIN 
                                             WHERE UserID =@UserID ";

                            int rows = db.SetCommand(strSql, db.Parameter("@UserID", loginModel.UserID, DbType.String)).ExecuteNonQuery();

                            StringBuilder strSqlUptLogin = new StringBuilder();
                            strSqlUptLogin.Append("update LOGIN set ");
                            strSqlUptLogin.Append(" CompanyID=@CompanyID,");
                            strSqlUptLogin.Append(" BranchID=@BranchID,");
                            strSqlUptLogin.Append(" ClientType=@ClientType,");
                            if (loginModel.ClientType != 3 && !String.IsNullOrEmpty(loginModel.DeviceID))
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

                            rows = db.SetCommand(strSqlUptLogin.ToString(), db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                                                          , db.Parameter("@BranchID", loginModel.BranchID, DbType.Int32)
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
                                strSql = @"insert into LOGIN(CompanyID,BranchID,UserID,DeviceType,DeviceID,LoginTime,LoginTimes,IPAddress,ClientType,AppVersion,OSVersion,GUID,DeviceModel)
                                                        values (
                                                        @CompanyID,@BranchID,@UserID,@DeviceType,@DeviceID,@LoginTime,@LoginTimes,@IPAddress,@ClientType,@AppVersion,@OSVersion,@GUID,@DeviceModel)";

                                rows = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", loginModel.CompanyID, DbType.Int32)
                                                                      , db.Parameter("@BranchID", loginModel.BranchID, DbType.Int32)
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

                            RoleForLogin_Model model = new RoleForLogin_Model();
                            if (isBussiness)
                            {
                                //获取当前用户的权限
                                strSql = @" select isNull(T4.IsPay,1) IsAccountPayEcard,T1.RoleID,
                                           --当RoleID =-1时 取出TBL_JURISDICTION表所有Type包含|1|权限 拼成Role ；当RoleID != -1 时 取出Role表中 Jurisdictions --
                                          case(T1.RoleID) when -1 then (SELECT '|'+CONVERT(NVARCHAR,ID) FROM dbo.SYS_JURISDICTION WHERE CHARINDEX(Type,'|1|')>0 FOR XML PATH('')) +'|' 
                                          else  T5.Jurisdictions  end Role

                                          from ACCOUNT T1 
                                          LEFT JOIN  Branch T4
                                          ON T1.BranchID = T4.ID 
                                          LEFT JOIN  TBL_ROLE T5
                                          ON T1.RoleID = T5.ID
                                          where USERID = @USERID AND (T5.Available = 1 OR T1.RoleID = -1 or T1.RoleID = 0) ";


                                model = db.SetCommand(strSql, db.Parameter("@USERID", loginModel.UserID, DbType.Int32)).ExecuteObject<RoleForLogin_Model>();
                                if (model != null)
                                {
                                    model.GUID = loginModel.GUID;
                                    model.CompanyID = loginModel.CompanyID;
                                    model.BranchID = loginModel.BranchID;
                                    model.UserID = loginModel.UserID;
                                    if (model.RoleID == -1)
                                    {
                                        string type = "";
                                        if (loginModel.ClientType == 1) //手机端权限
                                            type = "%|1|%";
                                        else if (loginModel.ClientType == 3) //web端权限
                                            type = "%|2|%";

                                        string strSqlAllRole = " select ID from SYS_JURISDICTION where Available = 1 and Type like  @Type  ";

                                        List<int> list = new List<int>();
                                        list = db.SetCommand(strSqlAllRole, db.Parameter("@Type", type, DbType.String)).ExecuteScalarList<int>();
                                        if (list != null && list.Count > 0)
                                        {
                                            foreach (int jId in list)
                                            {
                                                model.Role += jId + "|";
                                            }

                                        }
                                        model.Role = "|" + model.Role;
                                    }

                                    result.Data = model;
                                    result.Code = "1";
                                }
                            }
                            else
                            {
                                model.GUID = loginModel.GUID;
                                model.CompanyID = loginModel.CompanyID;
                                model.BranchID = loginModel.BranchID;
                                model.UserID = loginModel.UserID;

                                result.Data = model;
                                result.Code = "1";
                            }
                        }
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
                                      where T1.CompanyID=@CompanyID and T1.BranchID =@BranchID and T1.UserID =@UserID and T1.GUID=@GUID ";

                UtilityOperation_Model umodel = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                                                                    , db.Parameter("@UserID", UserID, DbType.Int32)
                                                                    , db.Parameter("@GUID", GUID, DbType.String)).ExecuteObject<UtilityOperation_Model>();
                return umodel;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="BranchID"></param>
        /// <param name="UserID"></param>
        /// <returns></returns>
        public void logOut(string GUID, int CompanyID, int BranchID, int UserID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"UPDATE dbo.LOGIN SET GUID = NULL WHERE CompanyID =@CompanyID AND BranchID =@BranchID AND UserID = @UserID and GUID=@GUID ";

                db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                                    , db.Parameter("@UserID", UserID, DbType.Int32)
                                    , db.Parameter("@GUID", GUID, DbType.String)).ExecuteNonQuery();
            }
        }

        /// <summary>
        /// 改密码
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="newPassword"></param>
        /// <returns></returns>
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

                        string EncryptedNewPWD = Common.DEncrypt.DEncrypt.Encrypt(model.Password);
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
    }
}
