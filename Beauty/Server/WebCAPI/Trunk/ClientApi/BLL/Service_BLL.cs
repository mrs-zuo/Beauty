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

        public ProductListInfo_Model GetServiceListByCompanyId(int companyId, int customerId, int imageHeight, int imageWidth)
        {
            ProductListInfo_Model model = new ProductListInfo_Model();
            model.CategoryName = "所有服务";
            model.CategoryID = 0;

            List<ProductList_Model> list = Service_DAL.Instance.getServiceListByCompanyId(companyId, customerId, imageHeight, imageWidth);
            if (list != null && list.Count > 0)
            {
                model.ProductList = new List<ProductList_Model>();
                model.ProductList = list;
            }

            return model;
        }

        public List<ProductList_Model> getRecommendedServiceListByBranchID(int companyId, int imageHeight, int imageWidth, int branchID)
        {
            List<ProductList_Model> list = Service_DAL.Instance.getRecommendedServiceListByBranchID(companyId, imageHeight, imageWidth, branchID);
            return list;
        }

        public ProductListInfo_Model getServiceListByCategoryId(int companyId, int categoryId, int customerId, bool selectAll, int imageHeight, int imageWidth)
        {
            ProductListInfo_Model model = new ProductListInfo_Model();

            CategoryInfo_Model categorymodel = Category_DAL.Instance.getCategoryInfoByID(companyId, categoryId);
            if (categorymodel != null)
            {
                model.CategoryName = categorymodel.CategoryName;
                model.CategoryID = categorymodel.CategoryID;

                List<ProductList_Model> list = Service_DAL.Instance.getServiceListByCategoryId(companyId, categoryId, customerId, true, imageHeight, imageWidth);
                if (list != null && list.Count > 0)
                {
                    model.ProductList = new List<ProductList_Model>();
                    model.ProductList = list;
                }
            }
            return model;
        }

        public ServiceDetail_Model getServiceDetailByServiceCode(UtilityOperation_Model utilityModel)
        {
            return Service_DAL.Instance.getServiceDetailByServiceCode(utilityModel);
        }

        public PromotionProductDetail_Model GetPromotionServiceDetailByID(int companyID, string promotionID, int commodityID,int customerId)
        {
            PromotionProductDetail_Model model = Service_DAL.Instance.GetPromotionServiceDetailByID(companyID, promotionID, commodityID, customerId);
            return model;
        }

        public List<SubServiceInServiceDetail_Model> getSubServiceByCodes(string subServiceCodes)
        {
            string[] arr = subServiceCodes.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
            List<long> subServiceList = new List<long>();
            for (int i = 0; i < arr.Length; i++)
            {
                long templong = HS.Framework.Common.Util.StringUtils.GetDbLong(arr[i]);
                if (templong <= 0)
                {
                    return null;
                }
                subServiceList.Add(templong);
            }

            return Service_DAL.Instance.getSubServiceByCodes(subServiceList);
        }

        public List<ServiceEnalbeInfoDetail_Model> getServiceEnalbleForCustomer(int customerId, long productCode)
        {
            return Service_DAL.Instance.getServiceEnalbleForCustomer(customerId, productCode);
        }

        public List<ProductList_Model> getRecommendedServiceList(int companyId, int imageHeight, int imageWidth)
        {
            List<ProductList_Model> list = Service_DAL.Instance.getRecommendedServiceList(companyId, imageHeight, imageWidth);
            return list;
        }

        public List<ProductList_Model> getBoughtServiceList(int companyId, int branchID, int customerId, int imageHeight, int imageWidth)
        {
            List<ProductList_Model> list = Service_DAL.Instance.getBoughtServiceList(companyId, branchID, customerId, imageHeight, imageWidth);
            return list;
        }
    }
}
