using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Appointment_Model
    {
        public string ReserveTime { get; set; }
        public string CustomerName { get; set; }
        public string ServiceName { get; set; }
        public string StaffName { get; set; }
        public string Remark { get; set; }
        public int TaskStatus { get; set; }
    }
    [Serializable]
    public class Appointment_Search_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string ReserveDate { get; set; }

        public string inCustomerName { get; set; }

        public string inServiceName { get; set; }
        public string inStaffName { get; set; }
        public int inTaskStatus_1 { get; set; }
        public int inTaskStatus_2 { get; set; }
        public int inTaskStatus_3 { get; set; }
    }
}
