using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetWeChatPayInfo_Model
    {
        public string NetTradeNo { get; set; }
        public string CompanyName { get; set; }
        public string ProductName { get; set; }
        public decimal NetTradeAmount { get; set; }
        public string Currency { get; set; }
        public int CompanyID { get; set; }
    }
}
