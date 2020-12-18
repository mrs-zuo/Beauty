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
    public class News_DAL
    {
        #region 构造类实例
        public static News_DAL Instance
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
            internal static readonly News_DAL instance = new News_DAL();
        }
        #endregion

        /// <summary>
        /// 获取新闻公告列表
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="pageIndex">当前页数</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="type">0:公告 1:新闻</param>
        /// <param name="recordCount">总共数量</param>
        /// <returns></returns>
        public List<GetNewsList_Model> getNewsList(int companyID, int pageIndex, int pageSize, int type, out int recordCount)
        {
            recordCount = 0;
            List<GetNewsList_Model> list = new List<GetNewsList_Model>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.CreateTime DESC ) AS rowNum ,
                                                  T1.ID AS NoticeID ,T1.NoticeTitle,T1.NoticeContent,T1.CreateTime ";

                    string strSql = " SELECT {0} FROM [NOTICE] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.Available=1 ";

                    if (type == 1)
                    {
                        strSql += " AND T1.[TYPE] = 1 ";
                    }
                    else
                    {
                        strSql += " AND T1.[TYPE] = 0 AND  GETDATE() BETWEEN T1.StartDate AND T1.EndDate ";
                    }

                    string strCountSql = string.Format(strSql, " count(0) ");
                    string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                    recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetNewsList_Model>();
                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Error(ex);
                    return null;
                }
            }

        }

        public GetNewsDetail_Model getNewsDetail(int companyID, int id)
        {
            GetNewsDetail_Model model = new GetNewsDetail_Model();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = " SELECT T1.ID AS NoticeID ,T1.NoticeTitle,T1.NoticeContent,T1.CreateTime FROM [NOTICE] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND ID=@ID AND T1.Available=1 ";
                    model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                , db.Parameter("@ID", id, DbType.Int32)).ExecuteObject<GetNewsDetail_Model>();

                    return model;
                }
                catch(Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }
    }
}
