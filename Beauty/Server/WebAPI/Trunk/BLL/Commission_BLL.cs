using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Commission_BLL
    {
        #region 构造类实例
        public static Commission_BLL Instance
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
            internal static readonly Commission_BLL instance = new Commission_BLL();
        }
        #endregion

        public List<Commission_Account_Model> GetAccountList(int companyID, string strInput)
        {
            return Commission_DAL.Instance.GetAccountList(companyID, strInput);
        }


        public Commission_Account_Model GetAccountDetail(int companyID, int accountID) {
            return Commission_DAL.Instance.GetAccountDetail(companyID, accountID);
        }


        public bool EditAccount(Commission_Account_Model model) {
            return Commission_DAL.Instance.EditAccount(model);
        }

        public List<Service_Model> getServiceList(int companyId, int imageWidth, int imageHeight, string strInput) {
            return Commission_DAL.Instance.getServiceList(companyId,  imageWidth,  imageHeight,  strInput);
        }
        
        public Commission_Product_Model GetServiceDetail(int CompanyID, long ServiceCode) {
            return Commission_DAL.Instance.GetServiceDetail(CompanyID, ServiceCode);
        }


        public List<Commodity_Model> getCommodityList(int companyId, int imageWidth, int imageHeight, string strInput) {
            return Commission_DAL.Instance.getCommodityList(companyId, imageWidth,  imageHeight,  strInput);
        }

        public Commission_Product_Model GetCommodityDetail(int CompanyID, long CommodityCode) {
            return Commission_DAL.Instance.GetCommodityDetail(CompanyID, CommodityCode);
        }

        public bool EditProduct(Commission_Product_Model model) {
            return Commission_DAL.Instance.EditProduct(model);
        }

        public List<Commission_Card_Model> GetCardList(int CompanyID) {
            return Commission_DAL.Instance.GetCardList(CompanyID);
        }

        public Commission_Card_Model GetCardDetail(int CompanyID, long CardCode) {
            return Commission_DAL.Instance.GetCardDetail(CompanyID, CardCode);
        }


        public bool EditCard(Commission_Card_Model model) {
            return Commission_DAL.Instance.EditCard(model);
        }
    }
}
