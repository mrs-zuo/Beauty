using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Service_BLL
    {
        #region 构造类实例
        public static Service_BLL Instance
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
            internal static readonly Service_BLL instance = new Service_BLL();
        }
        #endregion

        /// <summary>
        /// 服务列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getServiceList(int companyID, int pageIndex, int pageSize, out int recordCount, int height, int width,string strSearch)
        {
            List<GetProductList_Model> list = Service_DAL.Instance.getServiceList(companyID, pageIndex, pageSize, out  recordCount, height, width,strSearch);
            return list;
        }

        /// <summary>
        /// 服务详细
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public GetServiceDetail_Model getServiceDetail(int companyID, long ServiceCode, int height, int width) {
            GetServiceDetail_Model model = Service_DAL.Instance.getServiceDetail(companyID, ServiceCode, height, width);
            return model;
        }


        /// <summary>
        /// 服务图片
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        public List<string> getServiceImgList(int companyID, int serviceID, int height, int width, int count = 0)
        {
            List<string> list = Service_DAL.Instance.getServiceImgList(companyID, serviceID, height, width);
            if (count > 0 && list != null && list.Count > 0 && list.Count > count)
            {
                list = list.Take(count).ToList();
            }
            return list;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="serviceID"></param>
        /// <returns></returns>
        public List<string> getSubServiceName(int companyID, int serviceID) {
            return Service_DAL.Instance.getSubServiceName(companyID, serviceID);
        }
        /// <summary>
        /// 获取服务浏览历史列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getServiceBrowseHistoryList(int companyID, string strServiceCodes, int height, int width) {
            return Service_DAL.Instance.getServiceBrowseHistoryList(companyID, strServiceCodes, height, width);
        }
    }
}
