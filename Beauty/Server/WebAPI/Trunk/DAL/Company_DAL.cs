using BLToolkit.Data;
using HS.Framework.Common;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HS.Framework.Common.Util;
using Model.Table_Model;

namespace WebAPI.DAL
{
    public class Company_DAL
    { 
        #region 构造类实例
        public static Company_DAL Instance
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
            internal static readonly Company_DAL instance = new Company_DAL();
        }
        #endregion

        /// <summary>
        /// 获取公司详情
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <returns></returns>
        public GetCompanyDetail_Model getCompanyDetail(int companyID)
        {
            GetCompanyDetail_Model model = new GetCompanyDetail_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT T1.Name AS CompanyName,T1.Abbreviation,Summary,Contact,Phone,Fax,Web FROM [COMPANY] T1 WITH(NOLOCK) WHERE ID=@CompanyID AND Available=1 ";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<GetCompanyDetail_Model>();
                return model;
            }
        }

        /// <summary>
        /// 获取公司图片集合
        /// </summary>
        /// <param name="companyID"></param>
        /// <returns></returns>
        public List<string> getCompanyImgList(int companyID, int hight, int width)
        {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                string strImg = string.Format(WebAPI.Common.Const.getCompanyImg, hight, width);
                string strSql = " SELECT " + strImg + " FROM [IMAGE_BUSINESS] T1 WITH(NOLOCK) WHERE T1.Available=1 AND T1.CompanyID=@CompanyID AND T1.BranchID=0 ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalarList<string>();
                return list;
            }
        }


        public List<GetBranchList_Model> getBranchByCompanyId(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" Select T1.ID BranchID, T1.BranchName, T1.Address, T1.Visible 
                                    from BRANCH T1 with (NOLOCK)
                                    where T1.CompanyID = @CompanyID AND T1.Available = 1";
                List<GetBranchList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<GetBranchList_Model>();
                return list;
            }
        }

        public GetBusinessDetail_Model getBranchDetail(int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.BranchName Name, T1.Summary, T1.Contact, T1.Phone, T1.Fax, T1.Address, T1.Zip, T1.Web, T1.BusinessHours,T1.Longitude, T1.Latitude,(select count(*) from TBL_ACCOUNTBRANCH_RELATIONSHIP T2 where T2.BranchID = @BranchID And T2.Available = 1 And T2.VisibleForCustomer = 1) AccountCount
                                        from BRANCH T1
                                        Where T1.ID =@BranchID ";
                GetBusinessDetail_Model model = db.SetCommand(strSql, db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteObject<GetBusinessDetail_Model>();
                return model;

            }
        }

        public GetBusinessDetail_Model getCompanyDetailForMobile(int companyId)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = @" select T1.Name,T1.Summary,T1.Contact,T1.Phone,T1.Fax,T1.Web
                                      from COMPANY T1
                                      Where T1.ID =@CompanyID ";
                GetBusinessDetail_Model model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteObject<GetBusinessDetail_Model>();
                return model;

            }
        }

        /// <summary>
        /// 获取公司简称
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public string getCompanyAbbreviation(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select Abbreviation from COMPANY where ID =@CompanyID";
                object obj = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar();

                if (obj != null)
                {
                    return obj.ToString();
                }
                else
                {
                    return Common.Const.MESSAGE_GLAMOURPROMISE;
                }
            }
        }
        /// <summary>
        /// 获取公司短信抬头
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public string getCompanySmsheading(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select smsheading from COMPANY where ID =@CompanyID";
                object obj = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar();

                if (obj != null)
                {
                    return obj.ToString();
                }
                else
                {
                    return Common.Const.MESSAGE_GLAMOURPROMISE;
                }
            }
        }
        public string getDefaultPassword(int branchId)
        {
            using (DbManager db = new DbManager())
            {

                string strSqlCommand = @"select DefaultPassword from [BRANCH] WHERE ID =@BranchID";
                string password = db.SetCommand(strSqlCommand, db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<string>();
                return password;

            }
        }

        /// <summary>
        /// 获取公司基本功能
        /// </summary>
        /// <param name="companyId">公司ID</param>
        /// <returns></returns>
        public string getAdvancedByCompanyID(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCompany = @"SELECT Advanced FROM [COMPANY] WHERE ID=@CompanyID AND Available=1";
                string advanced = db.SetCommand(strSqlCompany, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<string>();

                return advanced;
            }
        }

        #region 后台管理方法

        public Company_Model getCompanyDetailForWeb(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select T1.ID,T1.Abbreviation,T1.SettlementCurrency, T1.Name,T1.Summary,T1.Contact,T1.Phone,T1.Fax,T1.Web,T1.Visible, T1.Remark,T1.CompanyScale,T1.BalanceRemind,T1.Style,T1.ComissionCalc,T1.AppointmentMustPaid  from COMPANY T1  Where T1.ID =@CompanyId ";
                Company_Model model = db.SetCommand(strSql, db.Parameter("@CompanyId", companyId, DbType.Int32)).ExecuteObject<Company_Model>();
                //查询公司提成率
                string strSqlCompanyRate = " SELECT Top 1 * FROM COMMISSION_RATE_COM T2 where T2.CompanyID = @CompanyId AND T2.IssuedDate <=@IssuedDate ORDER BY T2.IssuedDate DESC ";
                Company_Model modelCompanyRate = db.SetCommand(strSqlCompanyRate, 
                                           db.Parameter("@CompanyId", companyId, DbType.Int32)
                                          ,db.Parameter("@IssuedDate",DateTime.Now.ToString("yyyy-MM-dd"),DbType.String)).ExecuteObject<Company_Model>();
                if (modelCompanyRate != null)
                {
                    model.IssuedDate = modelCompanyRate.IssuedDate;
                    model.CommissionRate = modelCompanyRate.CommissionRate*100;
                }
                
                return model;
            }
        }

        public bool UpdateCompany(Company_Model model) {
            using (DbManager db = new DbManager()) {
                db.BeginTransaction();
                string strSqlHistory = " insert into HISTORY_COMPANY select * from COMPANY where ID =@ID ";
                int rows = db.SetCommand(strSqlHistory, db.Parameter("@ID",model.ID,DbType.Int32)).ExecuteNonQuery();

                if (rows == 0) {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlUpdate = @" update COMPANY set 
                                      Name=@Name,
                                      Abbreviation=@Abbreviation,
                                      Summary=@Summary,
                                      Contact=@Contact,
                                      Phone=@Phone,
                                      Fax=@Fax,
                                      Web=@Web,
                                      Visible=@Visible,
                                      UpdaterID=@UpdaterID,
                                      UpdateTime=@UpdateTime,
                                      BalanceRemind=@BalanceRemind,
                                      Style=@Style,
                                      ComissionCalc=@ComissionCalc,
                                      AppointmentMustPaid=@AppointmentMustPaid
                                      where ID=@ID ";

                rows = db.SetCommand(strSqlUpdate, db.Parameter("@Name",model.Name,DbType.String)
                    , db.Parameter("@Abbreviation", model.Abbreviation, DbType.String)
                    , db.Parameter("@Summary", model.Summary, DbType.String)
                    , db.Parameter("@Contact", model.Contact, DbType.String)
                    , db.Parameter("@Phone", model.Phone, DbType.String)
                    , db.Parameter("@Fax", model.Fax, DbType.String)
                    , db.Parameter("@Web", model.Web, DbType.String)
                    , db.Parameter("@Visible", model.Visible, DbType.Boolean)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@BalanceRemind", model.BalanceRemind, DbType.Boolean)
                    , db.Parameter("@Style", model.Style, DbType.String)
                    , db.Parameter("@ComissionCalc", model.ComissionCalc, DbType.Boolean)
                    , db.Parameter("@AppointmentMustPaid", model.AppointmentMustPaid, DbType.Boolean)
                    , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }
                if (model.ID >0 && model.IssuedDate != null) {
                    //删除大于生效日的销售顾问提成率数据 
                    string strSqlCompanyRateDelete = @"DELETE FROM COMMISSION_RATE_COM WHERE CompanyID = @CompanyID AND IssuedDate >= @IssuedDate";
                    rows = db.SetCommand(strSqlCompanyRateDelete,
                         db.Parameter("@CompanyID", model.ID, DbType.Int32)
                       , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                       ).ExecuteNonQuery();

                    //插入销售顾问默认提成率
                    string strSqlCompanyRateInsert = @"INSERT INTO COMMISSION_RATE_COM (CompanyID,IssuedDate,CommissionRate,CreatorID,CreateTime,UpdaterID,UpdateTime) VALUES (@CompanyID,@IssuedDate,@CommissionRate,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime)";
                    rows = db.SetCommand(strSqlCompanyRateInsert,
                          db.Parameter("@CompanyID", model.ID, DbType.Int32)
                        , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                        , db.Parameter("@CommissionRate", model.CommissionRate / 100, DbType.Decimal)
                        , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        ).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                db.CommitTransaction();
                return true;
            }
        }
        #endregion
    }
}
