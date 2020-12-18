using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Branch_BLL
    {
        #region 构造类实例
        public static Branch_BLL Instance
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
            internal static readonly Branch_BLL instance = new Branch_BLL();
        }
        #endregion

        public List<GetBranchList_Model> getBranchList(int companyID, int pageIndex, int pageSize, out int recordCount)
        {
            List<GetBranchList_Model> list = Branch_DAL.Instance.getBranchList(companyID, pageIndex, pageSize, out  recordCount);
            return list;
        }

        public GetBranchDetail_Model getBranchDetail(int companyID, int branchID)
        {
            GetBranchDetail_Model model = Branch_DAL.Instance.getBranchDetail(companyID, branchID);
            return model;
        }

        public List<string> getBranchImgList(int companyID, int branchID, int hight, int width, int count = 0)
        {
            List<string> list = Branch_DAL.Instance.getBranchImgList(companyID, branchID, hight, width);
            if (count > 0 && list != null && list.Count > 0 && list.Count > count)
            {
                list = list.Take(count).ToList();
            }
            return list;
        }
    }
}
