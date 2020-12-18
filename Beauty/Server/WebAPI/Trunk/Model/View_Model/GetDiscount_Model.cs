using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetDiscountList_Model
    {
        public string DiscountName { set; get; }
        public decimal Discount { set; get; }
    }

    [Serializable]
    public class GetDiscountInfo_Model
    {
        public int DiscountID { get; set; }
        public string DiscountName { get; set; }
        public decimal Discount { get; set; }
        public bool IsExist { get; set; }
    }

    [Serializable]
    public class GetDiscountListForManager_Model
    {
        public int ID { get; set; }
        public string DiscountName { get; set; }
        public decimal Discount { get; set; }
        public DateTime CreateTime { get; set; }
        public bool Available { get; set; }
    }

    [Serializable]
    public class GetDiscountDetail_Model
    {
        public int DiscountID { get; set; }
        public string DiscountName { set; get; }
        public List<GetLevelInfo_Model> LevelList { get; set; }
    }

    [Serializable]
    public class AddDiscount_Model
    {
        public int DiscountID { get; set; }
        public int CompanyID { get; set; }
        public string DiscountName { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }

        public List<GetLevelInfo_Model> List { get; set; }
    }
}
