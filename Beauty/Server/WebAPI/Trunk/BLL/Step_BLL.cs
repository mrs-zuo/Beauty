using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Step_BLL
    {
        #region 构造类实例
        public static Step_BLL Instance
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
            internal static readonly Step_BLL instance = new Step_BLL();
        }
        #endregion

        public bool AddStep(Step_Model model)
        {
            return Step_DAL.Instance.AddStep(model);
        }

        public bool UpdateStep(Step_Model model)
        {
            return Step_DAL.Instance.UpdateStep(model);
        }

        public List<Step_Model> GetStepList(int CompanyID)
        {
            return Step_DAL.Instance.GetStepList(CompanyID);
        }

        public Step_Model GetStepByID(int CompanyID, int ID)
        {
            return Step_DAL.Instance.GetStepByID(CompanyID,ID);
        }
    }
}
