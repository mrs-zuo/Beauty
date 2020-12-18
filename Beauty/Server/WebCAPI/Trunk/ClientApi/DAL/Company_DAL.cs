using BLToolkit.Data;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
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

        /// <summary>
        /// 获取公司详情
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <returns></returns>
        public GetCompanyDetail_Model getCompanyDetail(int companyID, bool needBranchCount = true)
        {
            GetCompanyDetail_Model model = new GetCompanyDetail_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT T1.Name AS CompanyName,T1.Abbreviation,Summary,Contact,Phone,Fax,Web,Style FROM [COMPANY] T1 WITH(NOLOCK) WHERE ID=@CompanyID AND Available=1 ";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<GetCompanyDetail_Model>();

                if (model != null && needBranchCount)
                {
                    string strSqlBranchCount = " select count(0) from [Branch] with (nolock) where CompanyID =@CompanyID";
                    model.BranchCount = db.SetCommand(strSqlBranchCount, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();
                }
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


                string strSql = " Select "
                   + WebAPI.Common.Const.strHttp
                   + WebAPI.Common.Const.server
                   + WebAPI.Common.Const.strMothod
                   + WebAPI.Common.Const.strSingleMark
                   + "  + cast(IMAGE_BUSINESS.CompanyID as nvarchar(10)) + "
                   + WebAPI.Common.Const.strSingleMark
                   + "/";

                strSql += WebAPI.Common.Const.strImageObjectType2 + WebAPI.Common.Const.strSingleMark + " + IMAGE_BUSINESS.FileName  ";


                strSql += @"+'&tw=" + width + "&th=" + hight +
                    @"&bg=FFFFFF' FileUrl from IMAGE_BUSINESS 
                                where CompanyID=@CompanyID
                                AND BranchID=0
                                AND Available = 1 ";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
              ).ExecuteScalarList<string>();
                return list;
            }
        }

        public List<GetBranchList_Model> getBranchByCompanyId(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" Select T1.ID BranchID, T1.BranchName, T1.Address, T1.Visible ,T1.Longitude,T1.Latitude
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
                string strSql = @" select T1.BranchName Name, T1.Summary, T1.Contact, T1.Phone, T1.Fax, T1.Address, T1.Zip, T1.Web, T1.BusinessHours,T1.Longitude, T1.Latitude,(select count(*) from TBL_ACCOUNTBRANCH_RELATIONSHIP T2 where T2.BranchID = @BranchID And T2.Available = 1 ) AccountCount
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

                string strSql = @" select T1.Name,T1.Summary,T1.Contact,T1.Phone,T1.Fax,T1.Web,T1.Abbreviation 
                                      from COMPANY T1
                                      Where T1.ID =@CompanyID ";
                GetBusinessDetail_Model model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteObject<GetBusinessDetail_Model>();
                return model;

            }
        }

        public List<GetBranchList_Model> getBranchByForProduct(int companyId)
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

        /// <summary>
        /// 获取公司短信抬头详情
        /// </summary>
        /// <param name="CustomerMobile">公司顾客手机号</param>
        /// <param name="CompanyID">公司ID</param>
        /// <returns></returns>
        public PushOperation_Model getCompanyInfo(string CustomerMobile,int CompanyID)
        {
            GetCompanyDetail_Model model = new GetCompanyDetail_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT TOP 1 T1.Name AS CustomerName ,T2.smsheading AS CompanyName,T4.LoginMobile
                                         FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                 LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                 LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                 LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                 WHERE    T1.Available = 1 AND T2.Available =1 ";
                string strSqlWx = @"SELECT TOP 1 T1.Name AS CustomerName ,T2.smsheading AS CompanyName,T4.LoginMobile
                                         FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                 LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                 LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                 LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                 WHERE    T1.Available = 1 AND T2.Available =1 ";
                if (CustomerMobile !=null && CustomerMobile !="") {
                    strSql = strSql + "  AND T4.LoginMobile = @LoginMobile ";

                }
                if (CompanyID > 0) {
                    strSql = strSql + " AND T1.CompanyID = @CompanyID  ";
                }
                PushOperation_Model pushmodel = db.SetCommand(strSql, db.Parameter("@LoginMobile", CustomerMobile, DbType.String)
                                                                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                              ).ExecuteObject<PushOperation_Model>();
                if (pushmodel == null)
                {
                    if (CompanyID > 0)
                    {
                        strSqlWx = strSqlWx + " AND T1.CompanyID = @CompanyID  ";
                        pushmodel = db.SetCommand(strSqlWx, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                              ).ExecuteObject<PushOperation_Model>();
                    }
                    
                }
                return pushmodel;
            }
        }
    }
}
