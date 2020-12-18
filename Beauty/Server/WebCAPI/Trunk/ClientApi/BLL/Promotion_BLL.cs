using ClientAPI.DAL;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class Promotion_BLL
    {
        #region 构造类实例
        public static Promotion_BLL Instance
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
            internal static readonly Promotion_BLL instance = new Promotion_BLL();
        }
        #endregion

        /// <summary>
        /// 获取促销图片
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="hight">图片高度</param>
        /// <param name="width">图片宽度</param>
        /// <param name="type">促销类型 0:所有展示 1:顶部展示 2:列表展示</param>
        /// <returns></returns>
        public List<PromotionList_Model> GetPromotionList(int companyID, int branchID, int width, int hight, int type)
        {
            List<PromotionList_Model> list = Promotion_DAL.Instance.GetPromotionList(companyID, branchID, width, hight, type);
            return list;
        }

        public PromotionDetail_Model GetPromotionDetail(int companyID, int width, int hight, string promotionCode)
        {
            PromotionDetail_Model model = Promotion_DAL.Instance.GetPromotionDetail(companyID, width, hight, promotionCode);
            if (model != null)
            {
                if (model.HasProduct)
                {
                    model.ProductList = Promotion_DAL.Instance.GetPromotionProductList(companyID, promotionCode, width, hight);
                }
                model.BranchList = Promotion_DAL.Instance.GetPromotionBranchList(companyID, promotionCode);
            }
            return model;
        }
    }
}
