using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class AddTGOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public string SignImg { get; set; }
        public string ImageFormat { get; set; }

        public List<TGDetailOperation_Model> TGDetailList { get; set; }
    }

    [Serializable]
    public class TGDetailOperation_Model
    {
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public long TaskID { get; set; }
        public int ProductType { get; set; }
        public int ServicePIC { get; set; }
        public bool IsDesignated { get; set; }
        public string Remark { get; set; }
        /// <summary>
        /// 商品交付的数量
        /// </summary>
        public int Count { get; set; }

        /// <summary>
        /// 是否下单并且交付
        /// </summary>
        public bool IsFinish { get; set; }
        public List<TGTreatmentOperation_Model> TreatmentList { get; set; }
    }

    [Serializable]
    public class TGTreatmentOperation_Model
    {
        public int SubServiceID { get; set; }
        public int ExecutorID { get; set; }
        public bool IsDesignated { get; set; }
    }
}
