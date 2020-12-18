using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class PromotionList_Model
    {
        public int PromotionID { get; set; }
        public string EndDate { get; set; }
        public string StartDate { get; set; }
        public int PromotionType { get; set; }
        public string PromotionContent { get; set; }
        public string PromotionPictureURL { get; set; }
        public List<ServiceEnalbeInfoDetail_Model> BranchList { get; set; }
    }

    [Serializable]
    public class TBL_PromotionList_Model
    {
        public string PromotionCode { get; set; }
        public DateTime EndDate { get; set; }
        public DateTime StartDate { get; set; }
        public int Type { get; set; }
        public string Title { get; set; }
        public string PromotionPictureURL { get; set; }
    }
}
