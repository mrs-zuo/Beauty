using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL.Customer;

namespace WebAPI.BLL.Customer
{
    public class Promotion_CBLL
    {
        #region 构造类实例
        public static Promotion_CBLL Instance
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
            internal static readonly Promotion_CBLL instance = new Promotion_CBLL();
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
        public List<TBL_PromotionList_Model> getPromotionList(int companyID, int width, int hight, int type = 0)
        {
            List<TBL_PromotionList_Model> list = Promotion_CDAL.Instance.getPromotionList(companyID, width, hight, type = 0);
            return list;
        }

        /// <summary>
        /// 获取促销信息数量
        /// </summary>
        /// <param name="objectId"></param>
        /// <param name="objectType"> 0:按公司ID查找 1：按客户ID查找</param>
        /// <returns></returns>
        public int getPromotionCount(int objectId, int objectType, int branchId)
        {
            return Promotion_CDAL.Instance.getPromotionCount(objectId, objectType, branchId);
        }


        public List<PromotionList_Model> getCompanyPromotionInfo(UtilityOperation_Model model)
        {
            return Promotion_CDAL.Instance.getCompanyPromotionInfo(model);
        }
    }
}
