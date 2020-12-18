using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BLToolkit.Data;
using System.Data;

namespace WebAPI.DAL
{
    public class Version_DAL
    {
        #region 构造类实例
        public static Version_DAL Instance
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
            internal static readonly Version_DAL instance = new Version_DAL();
        }
        #endregion

        public DataTable getServerVersion(int deviceType, int clientType, string CurrentVersion = "1.0")
        {
            String strSql = @"SELECT TOP 1
                                Version ,
                                CASE WHEN @Version < (SELECT TOP 1
                                Version         
                        FROM    VERSION
                        WHERE   DeviceType = @DeviceType
                                AND ClientType = @ClientType
                                AND MustUpgrade=1
                        ORDER BY ID DESC ) THEN '1' ELSE '0' end AS 'MustUpgrade'     
                        FROM    VERSION
                        WHERE   DeviceType = @DeviceType
                                AND ClientType = @ClientType
                        ORDER BY ID DESC";
            DbManager db = new DbManager();
            return db.SetCommand(strSql, db.Parameter("@DeviceType", deviceType, DbType.Int32)
                , db.Parameter("@ClientType", deviceType, DbType.Int32)
                , db.Parameter("@Version", deviceType, DbType.String)).ExecuteDataTable();
        }
    }
}
