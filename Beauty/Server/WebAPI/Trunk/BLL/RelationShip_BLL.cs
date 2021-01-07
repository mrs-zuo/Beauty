using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class RelationShip_BLL
    {
        #region 构造类实例
        public static RelationShip_BLL Instance
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
            internal static readonly RelationShip_BLL instance = new RelationShip_BLL();
        }
        #endregion

        public List<Customer_Model> GetCustomerList(int branchId, int companyId, int accountID, int type)
        {
            return RelationShip_DAL.Instance.GetCustomerList(branchId, companyId, accountID, type);
        }

        public List<Customer_Model> GetCustomerListByAccountName(int branchId, string inputSearch, int type)
        {
            return RelationShip_DAL.Instance.GetCustomerListByAccountName(branchId, inputSearch, type);
        }

        public List<RelationShip_Model> GetAccountList(int branchId)
        {
            return RelationShip_DAL.Instance.GetAccountList(branchId);
        }

        public List<RelationShip_Model> GetRelationShipList(int customerId, int branchId, int type)
        {
            return RelationShip_DAL.Instance.GetRelationShipList(customerId, branchId, type);
        }

        public bool changeRelationShip(RelationShip_Model model)
        {
            return RelationShip_DAL.Instance.changeRelationShip(model);
        }
    }
}
