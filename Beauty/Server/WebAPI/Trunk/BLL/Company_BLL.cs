using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
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
        public GetCompanyDetail_Model getCompanyDetail(int companyID)
        {
            GetCompanyDetail_Model model = Company_DAL.Instance.getCompanyDetail(companyID);
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

        public GetBusinessDetail_Model getCompanyDetailForMobile(int companyId) {
            return Company_DAL.Instance.getCompanyDetailForMobile(companyId);
        }

        /// <summary>
        /// 获取公司详细信息
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public string getCompanyAbbreviation(int companyId)
        {
            return Company_DAL.Instance.getCompanyAbbreviation(companyId);
        }
        /// <summary>
        /// 获取公司短信抬头
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public string getCompanySmsheading(int companyId)
        {
            return Company_DAL.Instance.getCompanySmsheading(companyId);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="branchId"></param>
        /// <returns></returns>
        public string getDefaultPassword(int branchId)
        {
            return Company_DAL.Instance.getDefaultPassword(branchId);
        }

        /// <summary>
        /// 获取公司基本功能
        /// </summary>
        /// <param name="companyId">公司ID</param>
        /// <returns></returns>
        public string getAdvancedByCompanyID(int companyId)
        {
            string res=Company_DAL.Instance.getAdvancedByCompanyID(companyId);
            return res;
        }

        #region 后台方法
        public Company_Model getCompanyDetailForWeb(int companyId) {
            return Company_DAL.Instance.getCompanyDetailForWeb(companyId);
        }


        public bool UpdateCompany(Company_Model model) {
            return Company_DAL.Instance.UpdateCompany(model);
        }
        #endregion
    }
}
