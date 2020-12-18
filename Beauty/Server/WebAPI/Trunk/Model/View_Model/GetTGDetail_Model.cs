using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetTGDetail_Model
    {
        public long GroupNo { set; get; }
        public int TGStatus { set; get; }
        public string Remark { set; get; }
        public DateTime TGStartTime { set; get; }
        public DateTime TGEndTime { set; get; }
        public string BranchName { get; set; }
        public string ThumbnailURL { get; set; }
    }
}
