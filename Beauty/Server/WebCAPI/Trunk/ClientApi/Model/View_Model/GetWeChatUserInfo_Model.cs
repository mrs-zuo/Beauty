using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetWeChatUserInfo_Model
    {
        public int subscribe { get; set; }
        public string openid { get; set; }
        public string nickname { get; set; }
        /// <summary>
        /// 0:未知 1:男 2:女 
        /// </summary>
        public int sex { get; set; }
        public string language { get; set; }
        public string city { get; set; }
        public string province { get; set; }
        public string country { get; set; }
        public string headimgurl { get; set; }
        public string unionid { get; set; }
        public string remark { get; set; }
        public int groupid { get; set; }
    }
}
