using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetLevelList_Model
    {
        public int LevelID { get; set; }
        public string LevelName { get; set; }
        public bool IsDefault { get; set; }
        public bool Available { get; set; }
    }

    [Serializable]
    public class GetLevelInfo_Model
    {
        public int LevelID { get; set; }
        public string LevelName { get; set; }
        public decimal Discount { get; set; }
        public decimal Balance { get; set; }
        public bool IsExist { get; set; }
    }

    [Serializable]
    public class GetLevelDetail_Model
    {
        public int LevelID { get; set; }
        public string LevelName { get; set; }
        public decimal Threshold { get; set; }
        public List<GetDiscountInfo_Model> DiscountlList { get; set; }
    }

    [Serializable]
    public class AddLevel_Model
    {
        public int LevelID { get; set; }
        public int CompanyID { get; set; }
        public string LevelName { get; set; }
        public decimal Threshold { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int Available { get; set; }

        public List<GetDiscountInfo_Model> List { get; set; }
    }
}
