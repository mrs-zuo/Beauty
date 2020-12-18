using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BLToolkit.Data;
using System.Data;
using Model.Operation_Model;

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

        public List<VersionCheck_Model> getServerVersion()
        {
//            String strSql = @"SELECT TOP 1
//                                Version ,(SELECT TOP 1
//                                Version         
//                        FROM    VERSION
//                        WHERE   DeviceType = @DeviceType
//                                AND ClientType = @ClientType
//                                AND MustUpgrade=1
//                        ORDER BY ID DESC ) as MustUpgradeVersion,
//                                CASE WHEN @Version < (SELECT TOP 1
//                                Version         
//                        FROM    VERSION
//                        WHERE   DeviceType = @DeviceType
//                                AND ClientType = @ClientType
//                                AND MustUpgrade=1
//                        ORDER BY ID DESC ) THEN '1' ELSE '0' end AS 'MustUpgrade'     
//                        FROM    VERSION
//                        WHERE   DeviceType = @DeviceType
//                                AND ClientType = @ClientType
//                        ORDER BY ID DESC";

            string strSql = @"SELECT  T1.* ,
                                      T2.MustUpgradeVersion
                              FROM    dbo.SYS_VERSION T1
                                      LEFT JOIN ( SELECT  MAX(Version) MustUpgradeVersion ,
                                                          DeviceType ,
                                                          ClientType ,
                                                          MustUpgrade
                                                  FROM    dbo.SYS_VERSION
                                                  WHERE   MustUpgrade = 1
                                                  GROUP BY DeviceType ,
                                                          ClientType ,
                                                          MustUpgrade
                                                ) T2 ON T1.ClientType = T2.ClientType
                                                        AND T1.DeviceType = T2.DeviceType
                              WHERE   T1.ID IN ( SELECT   MAX(ID)
                                                 FROM     dbo.SYS_VERSION
                                                 GROUP BY DeviceType ,
                                                          ClientType )";

            DbManager db = new DbManager();
            return db.SetCommand(strSql).ExecuteList<VersionCheck_Model>();
        }
    }
}
