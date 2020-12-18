using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public partial class PaperTable_Model
    {
        public int ID { set; get; }
        public int CompanyID { set; get; }
        public string Title { set; get; }
        public bool IsVisible { set; get; }
        public bool Available { set; get; }
        public bool CanEditAnswer { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }

        public int PaperControl { set; get; }
        public List<PaperRelationShip_Model> listRelation { set; get; }


    }

    [Serializable]
    public partial class PaperRelationShip_Model
    {
        public int QuestionID { set; get; }
        public int SortID { set; get; }
        public string QuestionName { set; get; }
    }
}
