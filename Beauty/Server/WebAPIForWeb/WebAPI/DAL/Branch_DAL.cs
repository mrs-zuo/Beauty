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
    public class Branch_DAL
    {
        #region 构造类实例
        public static Branch_DAL Instance
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
            internal static readonly Branch_DAL instance = new Branch_DAL();
        }
        #endregion

        public List<GetBranchList_Model> getBranchList(int companyID, int pageIndex, int pageSize, out int recordCount)
        {
            recordCount = 0;
            List<GetBranchList_Model> list = new List<GetBranchList_Model>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.ID ) AS rowNum ,
                                                  T1.ID AS BranchID, T1.BranchName,T1.Phone,T1.Fax,T1.Address ";

                    string strSql = " SELECT {0} FROM  [BRANCH] T1 WHERE T1.Available=1 AND T1.CompanyID=@CompanyID ";

                    string strCountSql = string.Format(strSql, " count(0) ");
                    string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                    recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetBranchList_Model>();
                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }

        public GetBranchDetail_Model getBranchDetail(int companyID,int branchID)
        {
            GetBranchDetail_Model model = new GetBranchDetail_Model();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = @" SELECT  T1.ID AS BranchID ,T1.BranchName ,T1.Contact,T1.Phone ,T1.Fax ,T1.Address,T1.Zip,T1.Web,T1.BusinessHours,T1.Remark,T1.Longitude,T1.Latitude 
                                       FROM [BRANCH] T1 WHERE   T1.Available = 1 AND T1.CompanyID=@CompanyID AND T1.ID=@BranchID ";
                    model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteObject<GetBranchDetail_Model>();
                    return model;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }

        public List<string> getBranchImgList(int companyID,int branchID,int hight,int width)
        {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strImg = string.Format(WebAPI.Common.Const.getBranchImg, hight, width);
                    string strSql = " SELECT " + strImg + " FROM [IMAGE_BUSINESS] T1 WITH(NOLOCK) WHERE T1.Available=1 AND T1.CompanyID=@CompanyID AND T1.BranchID=@BranchID ";
                    list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteScalarList<string>();
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
