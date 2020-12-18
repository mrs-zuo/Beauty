using Model.Operation_Model;
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
    public class Level_BLL
    {
        #region 构造类实例
        public static Level_BLL Instance
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
            internal static readonly Level_BLL instance = new Level_BLL();
        }
        #endregion


        public List<GetLevelList_Model> getLevelList(int companyId, int flag)
        {
            return Level_DAL.Instance.getLevelList(companyId, flag);
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public List<GetDiscountList_Model> getDiscountListForWebService(int levelId, int customerId)
        {
            return Level_DAL.Instance.getDiscountListForWebService(levelId, customerId);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool changeLevel(int levelId, int customerId)
        {
            return Level_DAL.Instance.changeLevel(levelId, customerId);
        }

        public List<GetDiscountListForManager_Model> getDiscountListForManager(int companyId,int flag, int pageIndex, int pageSize ,out int recordCount)
        {
            List<GetDiscountListForManager_Model> list = Level_DAL.Instance.getDiscountListForManager(companyId,flag, pageIndex, pageSize, out recordCount);
            return list;
        }

        public bool isExistDiscountName(int companyID, string DiscountName)
        {
            bool res = Level_DAL.Instance.isExistDiscountName(companyID, DiscountName);
            return res;
        }

        public bool deleteDiscount(Discount_Model model)
        {
            bool res = Level_DAL.Instance.deleteDiscount(model);
            return res;
        }

        public GetDiscountDetail_Model getDiscountDetailForManager(int companyID, int discountID)
        {
            GetDiscountDetail_Model model = new GetDiscountDetail_Model ();
            if (discountID > 0)
            {
                model = Level_DAL.Instance.getDiscountDetailForManager(companyID, discountID);
            }
            else
            {
                model.DiscountName = "";
                model.DiscountID = 0;
            }
            return model;
        }

        public List<GetLevelInfo_Model> getLevelListByDiscountID(int companyID, int discountID)
        {
            List<GetLevelInfo_Model> list = Level_DAL.Instance.getLevelListByDiscountID(companyID, discountID);
            return list;
        }

        public bool addDiscount(AddDiscount_Model model)
        {
            bool res = Level_DAL.Instance.addDiscount(model);
            return res;
        }

        public bool editDiscount(AddDiscount_Model model)
        {
            bool res = Level_DAL.Instance.editDiscount(model);
            return res;
        }

        public GetLevelDetail_Model getLevelDetailForManager(int companyID, int levelID)
        {
            GetLevelDetail_Model model = new GetLevelDetail_Model();
            if (levelID > 0)
            {
                model = Level_DAL.Instance.getLevelDetailForManager(companyID, levelID);
            }
            else
            {
                model.LevelName = "";
                model.LevelID = 0;
            }
            return model;
        }

        public List<GetDiscountInfo_Model> getDiscountListByLevelID(int companyID, int levelID)
        {
            List<GetDiscountInfo_Model> list = Level_DAL.Instance.getDiscountListByLevelID(companyID, levelID);
            return list;
        }

        public bool addLevel(AddLevel_Model model)
        {
            bool res = Level_DAL.Instance.addLevel(model);
            return res;
        }

        public bool editDiscount(AddLevel_Model model)
        {
            bool res = Level_DAL.Instance.editDiscount(model);
            return res;
        }

        public bool deleteLevel(AddLevel_Model model)
        {
            bool res = Level_DAL.Instance.deleteLevel(model);
            return res;
        }

        public bool updateDefaultLevelID(UtilityOperation_Model model)
        {
            bool res = Level_DAL.Instance.updateDefaultLevelID(model);
            return res;
        }


        public int getDiscountIDByName(int companyId, string discountName)
        {
            int levelID = Level_DAL.Instance.getDiscountIDByName(companyId, discountName);
            return levelID;
        }

        public bool isExistDiscountID(int companyID, int discountID)
        {
            return Level_DAL.Instance.isExistDiscountID(companyID, discountID);
        }


    }
}
