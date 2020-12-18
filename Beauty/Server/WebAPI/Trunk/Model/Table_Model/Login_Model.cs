using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Login_Model
    {
        public int UserID { get; set; }
        public int BranchID { get; set; }
        /// <summary>
        /// 变化类型。0:充值、1:消费。
        /// </summary>
        public int CompanyID { get; set; }
        public string LoginMobile { get; set; }
        public int ClientType { get; set; }
        public string AppVersion { get; set; }
        public string Password { get; set; }
        public int LoginTimes { get; set; }
        public DateTime? LoginTime { get; set; }
        public string DeviceID { get; set; }
        public int DeviceType { get; set; }
        //0 web端权限
        //1 手机端权限
        public int RoleType { get; set; }
        public int ImageWidth { get; set; }
        public int ImageHeight { get; set; }
        public string IPAddress { get; set; }
        public int UserType { get; set; }
        public List<int> CustomerIDList { get; set; }
        public string CustomerIDs { get; set; }
        public string OSVersion { get; set; }
        public string GUID { get; set; }
        public int ChangeCompany { get; set; }
        public string DeviceModel { get; set; }
        public string ValidateCode { get; set; }
        public string WXOpenID { get; set; }

        /// <summary>
        /// 0:切换门店 1:正常登陆
        /// </summary>
        public bool IsNormalLogin { get; set; }
        
    }
}
