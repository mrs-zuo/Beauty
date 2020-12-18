using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Commission_Product_Model
    {
        public int CProductID { set; get; }
        public int ProductType { set; get; }
        public long ProductCode { set; get; }
        public decimal ProfitPct { set; get; }
        public int ECardSACommType { set; get; }
        public decimal ECardSACommValue { set; get; }
        public int NECardSACommType { set; get; }
        public decimal NECardSACommValue { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }


        public int COperateID { set; get; }
        public bool HaveSubService { set; get; }
        public int DesOPCommType { set; get; }
        public decimal DesOPCommValue { set; get; }
        public int OPCommType { set; get; }
        public decimal OPCommValue { set; get; }


        public string ProductName { set; get; }
        public decimal UnitPrice { set; get; }
        public string SubServiceCodes { set; get; }

        public List<Commission_SubService_Model> listSubService { set; get; }

    }

    public class Commission_SubService_Model
    {
        public long ProductCode { set; get; }
        public long SubServiceCode { set; get; }
        public string SubServiceName { set; get; }
        public decimal DesSubServiceProfitPct { set; get; }
        public int DesSubOPCommType { set; get; }
        public decimal DesSubOPCommValue { set; get; }
        public decimal SubServiceProfitPct { set; get; }
        public long SubOPCommType { set; get; }
        public decimal SubOPCommValue { set; get; }
    }

}
