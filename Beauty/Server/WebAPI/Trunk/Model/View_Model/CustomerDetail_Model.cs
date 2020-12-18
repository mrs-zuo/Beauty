using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerDetail_Model
    {
        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public int? Gender { get; set; }
        public DateTime? BirthDay { get; set; }
        public int? Marriage { get; set; }
        public string Profession { get; set; }
        public string Remark { get; set; }
        public decimal? Weight { get; set; }
        public decimal? Height { get; set; }
        public string BloodType { get; set; }
    }
}
