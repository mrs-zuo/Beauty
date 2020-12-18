using BLToolkit.Data;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
{
    public class Notice_DAL
    {
        #region 构造类实例
        public static Notice_DAL Instance
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
            internal static readonly Notice_DAL instance = new Notice_DAL();
        }
        #endregion

        public List<Notice_Model> getNoticeList(int companyId, int flag, int type, int pageIndex, int pageSize, out int recordCount)
        {
            using (DbManager db = new DbManager())
            {
                List<Notice_Model> list = new List<Notice_Model>();


                string fileds = @" ROW_NUMBER() OVER ( ORDER BY ID ASC ) AS rowNum ,
                                                  ID, NoticeTitle, NoticeContent, CONVERT(varchar(19),StartDate,20) StartDate, CONVERT(varchar(19),EndDate,20) EndDate, CONVERT(varchar(19),CreateTime,20) CreateTime ";

                string strSql = "";

                strSql = @"SELECT  {0} from NOTICE where Available = 1  and CompanyID = @CompanyID and Type = @Type ";

                //strSql += @" WHERE  T5.Available = 1 AND T1.CreateTime >= T6.StartTime ";

                //                string strSql = @" select ID, NoticeTitle, NoticeContent, CONVERT(varchar(19),StartDate,20) StartDate, CONVERT(varchar(19),EndDate,20) EndDate, CONVERT(varchar(19),CreateTime,20) CreateTime 
                //                                        from NOTICE where Available = 1  and CompanyID = @CompanyID and Type = @Type";

                if (type == 0)
                {
                    switch (flag)
                    {
                        case 0:
                            strSql += " and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),EndDate) < 0 ";
                            break;
                        case 1:
                            strSql += " and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),StartDate) <=0  and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),EndDate) >= 0 ";
                            break;
                        case 2:
                            strSql += " and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),StartDate) > 0 ";
                            break;
                    }
                }

                string strCountSql = string.Format(strSql, " count(0) ");

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                , db.Parameter("@DateNow", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                , db.Parameter("@Type", type, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@DateNow", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                    , db.Parameter("@Type", type, DbType.Int32)).ExecuteList<Notice_Model>();

                return list;

            }
        }

        public Notice_Model getNoticeDetail(int companyId, int noticeID)
        {
            using (DbManager db = new DbManager())
            {
                Notice_Model model = new Notice_Model();
                string strSql = @" SELECT ID, NoticeTitle, NoticeContent, CONVERT(varchar(19),StartDate,20) StartDate, CONVERT(varchar(19),EndDate,20) EndDate, CONVERT(varchar(19),CreateTime,20) CreateTime FROM  NOTICE where Available = 1  and CompanyID = @CompanyID and ID = @ID";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                   , db.Parameter("@DateNow", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                   , db.Parameter("@ID", noticeID, DbType.Int32)).ExecuteObject<Notice_Model>();
                return model;
            }
        }
    }
}
