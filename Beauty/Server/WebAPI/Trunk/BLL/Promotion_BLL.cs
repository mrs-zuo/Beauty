using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;
using WebAPI.DAL;

namespace WebAPI.BLL
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
        /// <param name="type">促销类型</param>
        /// <returns></returns>
        public List<string> getPromotionImg(int companyID, int width, int hight, int type = 0)
        {
            List<string> list = Promotion_DAL.Instance.getPromotionImg(companyID, width, hight, type = 0);
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
            return Promotion_DAL.Instance.getPromotionCount(objectId, objectType, branchId);
        }


        public List<PromotionList_Model> getCompanyPromotionInfo(UtilityOperation_Model model)
        {
            return Promotion_DAL.Instance.getCompanyPromotionInfo(model);
        }

        public List<Promotion_Model> getPromotionForManager(UtilityOperation_Model model)
        {
            List<Promotion_Model> list = Promotion_DAL.Instance.getPromotionForManager(model);
            return list;
        }

        public int addPromotionForManager(Promotion_Model model, int branchID)
        {
            int res = Promotion_DAL.Instance.addPromotionForManager(model, branchID);
            if (res != 0)
            {
                Image_BLL.Instance.ImageMove(model.PromotionImgUrl, 5, res, model.CompanyID);
            }
            return res;
        }

        public Promotion_Model getPromotionDetailForManager(UtilityOperation_Model model)
        {
            Promotion_Model res = Promotion_DAL.Instance.getPromotionDetailForManager(model);
            return res;
        }

        public List<BranchSelection_Model> getBranchIDListByPromotionIDForManager(int companyID, int promotionID)
        {
            List<BranchSelection_Model> list = Promotion_DAL.Instance.getBranchIDListByPromotionIDForManager(companyID, promotionID);
            return list;
        }

        public bool updatePromotionForManager(Promotion_Model model)
        {
            bool res = Promotion_DAL.Instance.updatePromotionForManager(model);
            if (res)
            {
                if (model.ImageFile != model.PromotionImgUrl)
                {
                    Image_BLL.Instance.ImageMove(model.PromotionImgUrl, 5, model.ID, model.CompanyID);
                }
            }
            return true;
        }

        public bool deletePromotionForManager(Promotion_Model model)
        {
            bool res = Promotion_DAL.Instance.deletePromotionForManager(model);
            return res;
        }


        public bool OperateBranch(BranchSelectOperation_Model model)
        {
            return Promotion_DAL.Instance.OperateBranch(model);
        }

        public List<New_Promotion_Model> getPromotionForManager_new(UtilityOperation_Model model)
        {
            return Promotion_DAL.Instance.getPromotionForManager_new(model);
        }

        public New_Promotion_Model getPromotionDetailForManager_New(UtilityOperation_Model model)
        {
            return Promotion_DAL.Instance.getPromotionDetailForManager_New(model);
        }

        public List<BranchSelection_Model> getBranchIDListByPromotionIDForManager_New(int companyID, string PromotionCode)
        {
            List<BranchSelection_Model> list = Promotion_DAL.Instance.getBranchIDListByPromotionIDForManager_New(companyID, PromotionCode);
            return list;
        }

        public string addPromotionForManager_New(New_Promotion_Model model, int branchID)
        {
            string res = Promotion_DAL.Instance.addPromotionForManager_New(model, branchID);
            if (res != "" && res != null)
            {
                Image_BLL.Instance.ImageMove(model.ImageFile, 5, res, model.CompanyID);
            }
            return res;
        }

        public bool updatePromotionForManager_New(New_Promotion_Model model)
        {
            bool res = Promotion_DAL.Instance.updatePromotionForManager_New(model);
            if (res)
            {
                if (model.ImageFile != model.PromotionImgUrl)
                {
                    Image_BLL.Instance.ImageMove(model.ImageFile, 5, model.PromotionCode, model.CompanyID);
                }
            }
            return true;
        }

        public bool deletePromotionForManager_New(New_Promotion_Model model)
        {
            bool res = Promotion_DAL.Instance.deletePromotionForManager_New(model);
            return res;
        }

        public int OperateBranch_New(BranchSelectOperation_Model model)
        {
            return Promotion_DAL.Instance.OperateBranch_New(model);
        }

        #region 新促销规则
        public List<PromotionRule_Model> getPromotionRuleList()
        {
            return Promotion_DAL.Instance.getPromotionRuleList();
        }

        public List<PromotoinProduct_Model> getPromotionProductSelect(int companyId, string promotionCode, int type)
        {
            return Promotion_DAL.Instance.getPromotionProductSelect(companyId, promotionCode, type);
        }


        public List<PromotoinProduct_Model> getPromotionProductList(string promotionCode, int companyId)
        {
            return Promotion_DAL.Instance.getPromotionProductList(promotionCode, companyId);
        }


        public int addPromotionProduct(PromotoinProduct_Model model)
        {
            return Promotion_DAL.Instance.addPromotionProduct(model);
        }


        public int updatePromotionProduct(PromotoinProduct_Model model)
        {
            return Promotion_DAL.Instance.updatePromotionProduct(model);
        }

        public PromotoinProduct_Model getPromotionProductDetailAdd(string PromotionCode, long ProductCode, int ProductType, int CompanyID)
        {
            return Promotion_DAL.Instance.getPromotionProductDetailAdd(PromotionCode, ProductCode, ProductType, CompanyID);
        }


        public PromotoinProduct_Model getPromotionProductDetailEdit(string PromotionCode, int ProductID, int ProductType, int CompanyID)
        {
            return Promotion_DAL.Instance.getPromotionProductDetailEdit(PromotionCode, ProductID, ProductType, CompanyID);
        }


        public List<PromotionSale_Model> getPromotionSaleDetail(int companyID, String promotionID) {
            return Promotion_DAL.Instance.getPromotionSaleDetail(companyID, promotionID);
        }

        public int deletePromotionProduct(PromotoinProduct_Model model)
        {
            return Promotion_DAL.Instance.deletePromotionProduct(model);
        }

        #endregion

    }
}
