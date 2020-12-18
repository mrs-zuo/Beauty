using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class Paper_Model
    {
        public int PaperID { get; set; }
        public string Title { get; set; }
        public bool IsVisible { get; set; }
        public bool CanEditAnswer { get; set; }
        public DateTime CreateTime { get; set; }
    }

    [Serializable]
    public class GetAnswerPaperRes_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public int PageIndex { get; set; }
        public List<AnswerPaper_Model> PaperList { get; set; }
    }

    [Serializable]
    public class AnswerPaper_Model
    {
        public int GroupID { get; set; }
        public int PaperID { get; set; }
        public string Title { get; set; }
        public bool IsVisible { get; set; }
        public bool CanEditAnswer { get; set; }
        public string ResponsiblePersonName { get; set; }
        public string CustomerName { get; set; }
        public DateTime UpdateTime { get; set; }
    }

    [Serializable]
    public class PaperDetail
    {
        public int QuestionID { get; set; }
        public string QuestionName { get; set; }
        public int QuestionType { get; set; }
        public string QuestionContent { get; set; }
        public string QuestionDescription { get; set; }
        public int AnswerID { get; set; }
        public string AnswerContent { get; set; }
    }
}
