using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    public class ShareJSParam_Model
    {
        public string appid { get; set; }
        public string timestamp { get; set; }
        public string noncestr { get; set; }
        public string signature { get; set; }
        public string ticket { get; set; }
    }
}
