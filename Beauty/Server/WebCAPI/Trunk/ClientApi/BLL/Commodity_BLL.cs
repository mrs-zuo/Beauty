using ClientAPI.DAL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class Commodity_BLL
    {
        #region 构造类实例
        public static Commodity_BLL Instance
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
            internal static readonly Commodity_BLL instance = new Commodity_BLL();
        }
        #endregion

        public ProductListInfo_Model GetCommodityListByCompanyId(int companyId, int customerId, int imageHeight, int imageWidth)
        {
            ProductListInfo_Model model = new ProductListInfo_Model();
            model.CategoryName = "所有商品";
            model.CategoryID = 0;

            List<ProductList_Model> list = Commodity_DAL.Instance.getCommodityListByCompanyId(companyId, customerId, imageHeight, imageWidth);
            if (list != null && list.Count > 0)
            {
                model.ProductList = new List<ProductList_Model>();
                model.ProductList = list;
            }

            return model;
        }

        public ProductListInfo_Model getCommodityListByCategoryID(int companyId, int categoryId, int customerId, bool selectAll, int imageHeight, int imageWidth)
        {
            ProductListInfo_Model model = new ProductListInfo_Model();

            CategoryInfo_Model categorymodel = Category_DAL.Instance.getCategoryInfoByID(companyId, categoryId);
            if (categorymodel != null)
            {
                model.CategoryName = categorymodel.CategoryName;
                model.CategoryID = categorymodel.CategoryID;

                List<ProductList_Model> list = Commodity_DAL.Instance.getCommodityListByCategoryID(companyId, categoryId, customerId, true, imageHeight, imageWidth);
                if (list != null && list.Count > 0)
                {
                    model.ProductList = new List<ProductList_Model>();
                    model.ProductList = list;
                }
            }
            return model;
        }

        public ObjectResult<CommodityDetail_Model> getCommodityDetailByCommodityCode(UtilityOperation_Model model)
        {
            return Commodity_DAL.Instance.getCommodityDetailByCommodityCode(model);
        }

        public PromotionProductDetail_Model GetPromotionCommodityDetailByID(int companyID, string promotionID, int commodityID, int customerId)
        {
            PromotionProductDetail_Model model = Commodity_DAL.Instance.GetPromotionCommodityDetailByID(companyID, promotionID, commodityID, customerId);
            return model;
        }

        public List<CommodityEnalbeInfoDetail> getCommodityEnalbleForCustomer(int customerId, long productCode)
        {
            return Commodity_DAL.Instance.getCommodityEnalbleForCustomer(customerId, productCode);
        }

        public List<ProductInfoList_Model> getProductInfoList(CartOperation_Model operationModel)
        {
            List<ProductInfoList_Model> list = Commodity_DAL.Instance.getProductInfoList(operationModel);
            return list;
        }

        public List<ProductInfoList_Model> getProductInfoListForWeb(CartOperation_Model operationModel)
        {
            List<ProductInfoList_Model> list = Commodity_DAL.Instance.getProductInfoListForWeb(operationModel);
            return list;
        }

        public List<ProductList_Model> getRecommendedCommodityList(int companyId, int imageHeight, int imageWidth)
        {
            List<ProductList_Model> list = Commodity_DAL.Instance.getRecommendedCommodityList(companyId, imageHeight, imageWidth);
            return list;
        }
    }
}
