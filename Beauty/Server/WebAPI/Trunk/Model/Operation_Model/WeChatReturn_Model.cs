using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class WeChatReturn_Model
    {
        public string appid { get; set; }
        public string attach { get; set; }
        public string bank_type { get; set; }
        public decimal cash_fee { get; set; }
        public string cid { get; set; }
        public string fee_type { get; set; }
        public string is_subscribe { get; set; }
        public string mch_id { get; set; }
        public string nonce_str { get; set; }
        public string openid { get; set; }
        public string out_trade_no { get; set; }
        public string result_code { get; set; }
        public string return_code { get; set; }
        public string sign { get; set; }
        public string time_end { get; set; }
        public decimal total_fee { get; set; }
        public string trade_type { get; set; }
        public string transaction_id { get; set; }
        public string err_code { get; set; }
        public string err_code_des { get; set; }
        public string trade_state { get; set; }
        public string trade_state_desc { get; set; }
    }
}
