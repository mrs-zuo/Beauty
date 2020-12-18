using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;
using Model.Table_Model;

namespace WebAPI.BLL
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

        public List<Paper_Model> GetPaperList(int companyID)
        {
            List<Paper_Model> list = Paper_DAL.Instance.GetPaperList(companyID);
            return list;
        }

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

        public bool AddAnswer(AddAnswerOperation_Model model)
        {
            bool res = Paper_DAL.Instance.AddAnswer(model);
            return res;
        }

        // 专业删除
        public bool DelAnswer(DelAnswerOperation_Model model)
        {
            bool res = Paper_DAL.Instance.DelAnswer(model);
            return res;
        }

        public bool UpdateAnswer(EditAnswerOperation_Model model)
        {
            bool res = Paper_DAL.Instance.UpdateAnswer(model);
            return res;
        }
		
		 #region 后台方法
        public List<PaperTable_Model> getPaperListForWeb(int companyId)
        {
            return Paper_DAL.Instance.getPaperListForWeb(companyId);
        }



        public bool deletePaper(PaperTable_Model model)
        {
            return Paper_DAL.Instance.deletePaper(model);
        }


        public int addPaper(PaperTable_Model model)
        {
            return Paper_DAL.Instance.addPaper(model);
        }


        public bool updatePaper(PaperTable_Model model)
        {
            return Paper_DAL.Instance.updatePaper(model);
        }

        public PaperTable_Model getPaperDetail(int paperId)
        {
            return Paper_DAL.Instance.getPaperDetail(paperId);
        }

        #endregion
    }
}
