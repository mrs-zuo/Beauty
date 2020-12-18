using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class VersionCheck_Model
    {
        public int ClientType { get; set; }
        public int DeviceType { get; set; }
        public bool MustUpgrade { get; set; }
        public string Version { get; set; }
        public string MustUpgradeVersion { get; set; }
    }
}
