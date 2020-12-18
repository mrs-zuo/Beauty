using ClientAPI.DAL;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class Paper_BLL
    {
        #region 构造类实例
        public static Paper_BLL Instance
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
            internal static readonly Paper_BLL instance = new Paper_BLL();
        }
        #endregion

        public List<AnswerPaper_Model> GetAnswerPaperList(GetAnswerPaperListOperation_Model operationModel, out int recordCount)
        {
            List<AnswerPaper_Model> list = Paper_DAL.Instance.GetAnswerPaperList(operationModel, out recordCount);
            return list;
        }

        public List<PaperDetail> GetPaperDetail(GetAnswerDetailOperation_Model model)
        {
            List<PaperDetail> list = Paper_DAL.Instance.GetPaperDetail(model);
            return list;
        }

    }
}
