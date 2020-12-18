using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Question_Model
    {
        public bool HaveAnswer { get; set; }
        public int CompanyID { get; set; }
        public DateTime CreateTime { get; set; }
        public int? CreatorID { get; set; }
        public int ID { get; set; }
        public string QuestionContent { get; set; }
        public string QuestionName { get; set; }
        public int QuestionType { get; set; }
        public string QuestionDescription { get; set; }
    }
}
