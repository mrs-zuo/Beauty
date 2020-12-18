using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class SubService_BLL
    {
        #region 构造类实例
        public static SubService_BLL Instance
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
            internal static readonly SubService_BLL instance = new SubService_BLL();
        }
        #endregion

        public List<SubService_Model> GetSubServiceList(int CompanyID)
        {
            return SubService_DAL.Instance.GetSubServiceList(CompanyID);
        }

        public SubService_Model GetSubServiceDetail(int CompanyID, long SubServiceCode)
        {
            return SubService_DAL.Instance.GetSubServiceDetail(CompanyID,SubServiceCode);
        }

        public bool UpdateSubService(SubService_Model model)
        {
            return SubService_DAL.Instance.UpdateSubService(model);
        }

        public bool AddSubService(SubService_Model model)
        {
            return SubService_DAL.Instance.AddSubService(model);
        }
    }
}
