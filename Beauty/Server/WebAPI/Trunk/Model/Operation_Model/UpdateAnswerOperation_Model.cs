using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class UpdateAnswerOperation_Model
    {
        public int CompanyID{set;get;}
        public int AccountID{get;set;}
        public int CustomerID{get;set;}

        public List<Answer> AnswerList { get; set; }
    }

    [Serializable]
    public class Answer
    {
        public int OperationFlag { get; set; }
        public  int QuestionID {get;set;}
        public string AnswerContent { get; set; }
        public  int AnswerID {get;set;}
    }
}
