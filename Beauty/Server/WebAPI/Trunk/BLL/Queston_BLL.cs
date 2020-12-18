using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Queston_BLL
    {
        #region 构造类实例
        public static Queston_BLL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly Queston_BLL instance = new Queston_BLL();
        }
        #endregion

        public List<Question_Model> GetQuestionList(int CompanyID, int QuestionType)
        {
            return Question_DAL.Instance.GetQuestionList(CompanyID, QuestionType);
        }

        public bool AddQuerstion(Question_Model model)
        {
            return Question_DAL.Instance.AddQuerstion(model);
        }

        public bool UpdateQuestion(Question_Model model)
        {
            return Question_DAL.Instance.UpdateQuestion(model);
        }

        public Question_Model GetQuestionDetail(int CompanyID, int ID)
        {
            return Question_DAL.Instance.GetQuestionDetail(CompanyID,ID);
        }

        public bool CheckQuestionHaveANSWER(int CompanyID, int ID)
        {
            return Question_DAL.Instance.CheckQuestionHaveANSWER(CompanyID, ID);
        }

        public int DelQuestion(int CompanyID, int ID)
        {
            return Question_DAL.Instance.DelQuestion(CompanyID, ID);
        }
    }
}
