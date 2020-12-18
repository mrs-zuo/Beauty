using ClientAPI.DAL;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class Company_BLL
    {       
        #region 构造类实例
        public static Company_BLL Instance
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
            internal static readonly Company_BLL instance = new Company_BLL();
        }
        #endregion


        /// <summary>
        /// 获取公司详情
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <returns></returns>
        public GetCompanyDetail_Model getCompanyDetail(int companyID, bool needBranchCount = true)
        {
            GetCompanyDetail_Model model = Company_DAL.Instance.getCompanyDetail(companyID, needBranchCount);
            return model;
        }



        /// <summary>
        /// 获取公司图片集合
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        public List<string> getCompanyImgList(int companyID, int hight, int width, int count = 0)
        {
            List<string> list = Company_DAL.Instance.getCompanyImgList(companyID, hight, width);
            if (count > 0 && list != null && list.Count > 0 && list.Count > count)
            {
                list = list.Take(count).ToList();
            }
            return list;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public List<GetBranchList_Model> getBranchByCompanyId(int companyId)
        {
            return Company_DAL.Instance.getBranchByCompanyId(companyId);
        }


        public GetBusinessDetail_Model getBranchDetail(int branchId)
        {
            return Company_DAL.Instance.getBranchDetail(branchId);
        }

        public GetBusinessDetail_Model getCompanyDetailForMobile(int companyId)
        {
            return Company_DAL.Instance.getCompanyDetailForMobile(companyId);
        }
    }
}
