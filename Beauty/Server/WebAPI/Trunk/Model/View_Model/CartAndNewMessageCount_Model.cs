using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CartAndNewMessageCount_Model
    {
        public int CartCount { get; set; }
        public int NewMessageCount { get; set; }
        public int RemindCount { get; set; }
        public int PromotionCount { get; set; }
        public int UnpaidOrderCount { get; set; }
        public int UnconfirmedOrderCount { get; set; }
    }
}
