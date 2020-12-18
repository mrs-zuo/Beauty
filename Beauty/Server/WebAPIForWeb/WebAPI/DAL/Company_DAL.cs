using BLToolkit.Data;
using HS.Framework.Common;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
                try
                {
                    string strSql = " SELECT T1.Name AS CompanyName,T1.Abbreviation,Summary,Contact,Phone,Fax,Web FROM [COMPANY] T1 WITH(NOLOCK) WHERE ID=@CompanyID AND Available=1 ";
                    model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<GetCompanyDetail_Model>();
                    return model;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
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
                try
                {
                    string strImg = string.Format(WebAPI.Common.Const.getCompanyImg, hight, width);
                    string strSql = " SELECT " + strImg + " FROM [IMAGE_BUSINESS] T1 WITH(NOLOCK) WHERE T1.Available=1 AND T1.CompanyID=@CompanyID AND T1.BranchID=0 ";
                    list=db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalarList<string>();
                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }
    }
}
