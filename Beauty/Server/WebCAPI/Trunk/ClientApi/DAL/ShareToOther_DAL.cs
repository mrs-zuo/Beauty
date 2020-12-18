using BLToolkit.Data;
using HS.Framework.Common.Util;
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
    public class ShareToOther_DAL
    {
        #region 构造类实例
        public static ShareToOther_DAL Instance
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
            internal static readonly ShareToOther_DAL instance = new ShareToOther_DAL();
        }
        #endregion

        public bool AddTGShareStatics(int companyID, int userID, long groupNo, string url)
        {
            using (DbManager db = new DbManager())
            {
                DateTime dt = DateTime.Now.ToLocalTime();

                string strSelSql = @" select COUNT(0) from TBL_SHARE_STATICS where RecordID=@RecordID ";
                int count = db.SetCommand(strSelSql
                    , db.Parameter("@RecordID", groupNo, DbType.Int64)).ExecuteScalar<int>();

                if (count == 0)
                {
                    string strSql = @" INSERT INTO TBL_SHARE_STATICS ( CompanyID  ,RecordID ,LinkUrl ,ReviewCount ,CreatorID ,CreateTime ) 
VALUES ( @CompanyID ,@RecordID ,@LinkUrl ,@ReviewCount ,@CreatorID ,@CreateTime )";

                    int addRes = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@RecordID", groupNo, DbType.Int64)
                        , db.Parameter("@LinkUrl", url, DbType.String)
                        , db.Parameter("@ReviewCount", 0, DbType.Int32)
                        , db.Parameter("@CreatorID", userID, DbType.Int32)
                        , db.Parameter("@CreateTime", dt, DbType.DateTime2)).ExecuteNonQuery();

                    if (addRes != 1)
                    {
                        return false;
                    }
                }

                return true;
            }
        }

        public bool UpdateTGShareCount(int companyID, long groupNo)
        {
            using (DbManager db = new DbManager())
            {
                DateTime dt = DateTime.Now.ToLocalTime();
                string strSql = @" update TBL_SHARE_STATICS set ReviewCount=ReviewCount+1,UpdateTime=@UpdateTime where CompanyID=@CompanyID and RecordID=@RecordID ";
                int res = db.SetCommand(strSql
                        , db.Parameter("@UpdateTime", dt, DbType.DateTime2)
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@RecordID", groupNo, DbType.Int64)).ExecuteNonQuery();

                if (res != 1)
                {
                    return false;
                }
                return true;
            }
        }
    }
}
