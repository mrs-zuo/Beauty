using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class AddAnswerOperation_Model
    {
        public int PaperID { get; set; }
        public int CustomerID { get; set; }
        public bool IsVisible { get; set; }
        public List<AnswerRes_Model> AnswerList { get; set; }

        public int CompanyID { get; set; }
        public bool Available { get; set; }
        public int AccountID { get; set; }
        public DateTime OperateTime { get; set; }
        public int BranchID { get; set; }
    }

    [Serializable]
    public class AnswerRes_Model
    {
        public int QuestionID { get; set; }
        public string AnswerContent { get; set; }
    }

    public class EditAnswerOperation_Model
    {
        public int GroupID { get; set; }
        public int QuestionID { get; set; }
        public int AnswerID { get; set; }
        public string AnswerContent { get; set; }

        public int CompanyID { get; set; }
        public int AccountID { get; set; }
        public DateTime OperateTime { get; set; }
    }
}
