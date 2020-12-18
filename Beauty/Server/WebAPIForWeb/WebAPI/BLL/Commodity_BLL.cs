using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
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

              /// <summary>
        /// 获取商品列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getCommodityList(int companyID, int pageIndex, int pageSize, out int recordCount, int height, int width,string strSearch)
        {
            List<GetProductList_Model> list = Commodity_DAL.Instance.getCommodityList(companyID, pageIndex, pageSize, out  recordCount, height, width, strSearch);
            return list;
        }


        /// <summary>
        /// 商品详细
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public GetCommodityDetail_Model getCommodityDetail(int companyID, long commodityCode, int height, int width)
        {
            GetCommodityDetail_Model model = Commodity_DAL.Instance.getCommodityDetail(companyID, commodityCode, height, width);
            return model;
        }
        /// <summary>
        /// 商品图片
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <returns></returns>
        public List<string> getCommodityImgList(int companyID, int commodityID, int height, int width, int count = 0)
        {
            List<string> list = Commodity_DAL.Instance.getCommodityImgList(companyID, commodityID, height, width);
            if (count > 0 && list != null && list.Count > 0 && list.Count > count)
            {
                list = list.Take(count).ToList();
            }
            return list;
        }
        /// <summary>
        /// 获取商浏览历史列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getCommodityBrowseHistoryList(int companyID, string strCommodityCodes, int height, int width) {
            return Commodity_DAL.Instance.getCommodityBrowseHistoryList(companyID, strCommodityCodes, height, width);
        }
        #endregion
    }
}
