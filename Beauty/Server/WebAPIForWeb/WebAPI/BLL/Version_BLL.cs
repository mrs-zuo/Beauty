using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;
using HS.Framework.Common.Caching;

namespace WebAPI.BLL
{
    public class Version_BLL
    {
        #region 构造类实例
        public static Version_BLL Instance
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
            internal static readonly Version_BLL instance = new Version_BLL();
        }
        #endregion

        public string getServerVersion(int deviceType, int clientType, string CurrentVersion = "1.0")
        {
            var current=MemcachedNew.Get("Version","Current");
            if(current!=null)
            {
                return (string)current;
            }
            else{

            DataTable dt=Version_DAL.Instance.getServerVersion(deviceType,clientType,CurrentVersion);

            if(dt!=null&&dt.Rows.Count>0)
            {
                MemcachedNew.Set("Version", "Current", dt.Rows[0]["Version"].ToString());
                return dt.Rows[0]["Version"].ToString();
            }
            return null;
            }
            
        }

    }
}
