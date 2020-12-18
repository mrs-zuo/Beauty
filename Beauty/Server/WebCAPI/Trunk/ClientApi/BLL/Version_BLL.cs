using ClientAPI.DAL;
using HS.Framework.Common.Caching;
using Model.Operation_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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

        public VersionCheck_Model getServerVersion(int deviceType, int clientType, string CurrentVersion = "1.0")
        {
            var current = MemcachedNew.Get("Version", "CurrentVersion");
            List<VersionCheck_Model> list = null;
            if (current != null)
                list = (List<VersionCheck_Model>)current;
            else
            {
                list = Version_DAL.Instance.getServerVersion();

                if (list == null)
                    return null;
                else
                    MemcachedNew.Set("Version", "CurrentVersion", list);
            }

            VersionCheck_Model model = list.Where(c => c.ClientType == clientType && c.DeviceType == deviceType).First();

            if (model == null)
                return null;

            if (CurrentVersion.CompareTo(model.MustUpgradeVersion) < 0)
                model.MustUpgrade = true;
            else
                model.MustUpgrade = false;

            return model;
        }

    }
}
