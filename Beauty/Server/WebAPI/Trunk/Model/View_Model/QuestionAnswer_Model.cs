using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class QuestionAnswer_Model
    {
        public int QuestionID { get; set; }
        public string QuestionName { get; set; }
        public int QuestionType { get; set; }
        public string QuestionContent { get; set; }
        public string AnswerContent { get; set; }
        public int AnswerID { get; set; }
    }
}
