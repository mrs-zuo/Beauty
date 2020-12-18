using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class PaymentList_Model
    {
        public int ID { get; set; }
        public string Describe { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime? CreateTime { get; set; }
        public string PaymentModes { get; set; }
        public bool IsRemark { get; set; }
        public DateTime? PaymentTime { get; set; }
    }
}
