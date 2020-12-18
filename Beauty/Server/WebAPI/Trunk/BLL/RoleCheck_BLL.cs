using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class RoleCheck_BLL
    {
        #region 构造类实例
        public static RoleCheck_BLL Instance
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
            internal static readonly RoleCheck_BLL instance = new RoleCheck_BLL();
        }
        #endregion

        /// <summary>
        /// checkAccount 是否有编辑订单的权限
        /// 有编辑所有订单的权限
        /// 有编辑我的订单的权限且订单与我有关系（我是责任人，创建者，我的下属与订单有关系）
        /// </summary>
        /// <param name="orderID"></param>
        /// <param name="accountID"></param>
        /// <returns></returns>
        public bool checkOrderUpdaterRole(UtilityOperation_Model utilityModel)
        {
            //暂时后台不判断权限所以全部返回true
            return true;

            GetOrderDetail_Model model = new GetOrderDetail_Model();
            model = RoleCheck_DAL.Instance.getOrderBasic(utilityModel.OrderID);

            bool result = false;
            if (model != null)
            {
                if (utilityModel.BranchID == model.BranchID)
                {
                    #region 权限判断
                    UserRole_Model userRole = Account_DAL.Instance.getUserRole_2_2(utilityModel.AccountID);
                    if (userRole != null)
                    {
                        //超级用户可以更改订单权限
                        if (userRole.RoleID == -1)
                        {
                            result = true;
                        }
                        //有更改所有订单的权限 '|45|'
                        else if (userRole.Jurisdictions.Contains(Const.ROLE_ALLORDER_WRITE))
                        {
                            result = true;
                        }
                        //有更改我的订单权限 '|6|'
                        else if (userRole.Jurisdictions.Contains(Const.ROLE_MYORDER_WRITE))
                        {
                            //当前UserID有更改订单权限
                            if (model.CreatorID == utilityModel.AccountID)
                            {
                                //订单的CreatorID = AccountID 时
                                result = true;
                            }
                            else if (model.ResponsiblePersonID != 0 && model.ResponsiblePersonID == utilityModel.AccountID)
                            {
                                //订单的责任人ID = AccountID 时
                                result = true;
                            }
                            else
                            {
                                //是登陆ACCOUNT的同店下级时
                                List<SubQuery_Model> hierarchy = Account_DAL.Instance.GetHierarchySubQuery_2_2(utilityModel.AccountID, utilityModel.BranchID);
                                if (hierarchy != null && hierarchy.Count > 0)
                                {
                                    foreach (SubQuery_Model item in hierarchy)
                                    {
                                        if (item.SubordinateID == model.ResponsiblePersonID)
                                        {
                                            result = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    #endregion
                }
            }
            return result;
        }


        /// <summary>
        /// 检查订单与顾客ID是否匹配
        /// </summary>
        /// <param name="CustomerID"></param>
        /// <param name="OrderID"></param>
        /// <returns></returns>
        public bool checkIsCustomerOrder(int CustomerID, int OrderID)
        {
            bool res = RoleCheck_DAL.Instance.checkIsCustomerOrder(CustomerID, OrderID);
            return res;
        }

        public List<Role_Model> getRoleList(int companyId)
        {
            List<Role_Model> list = RoleCheck_DAL.Instance.getRoleList(companyId);
            return list;
        }

        public Role_Model getRoleDetail(int companyID, int ID)
        {
            Role_Model model = RoleCheck_DAL.Instance.getRoleDetail(companyID, ID);
            return model;
        }

        public List<Jurisdiction_Model> getJurisdictionList(int companyID, string advanced, int roleID)
        {
            List<Jurisdiction_Model> list = RoleCheck_DAL.Instance.getJurisdictionList(companyID, advanced, roleID);
            return list;
        }

        public bool addRole(Role_Model model)
        {
            bool res = RoleCheck_DAL.Instance.addRole(model);
            return res;
        }

        public bool updateRole(Role_Model model)
        {
            bool res = RoleCheck_DAL.Instance.updateRole(model);
            return res;
        }

        public bool deleteRole(int roleId, int accountId)
        {
            bool res = RoleCheck_DAL.Instance.deleteRole(roleId, accountId);
            return res;
        }

        public bool IsAccountHasTheRole(int companyID, int accountID, string strRole)
        {
            if (string.IsNullOrWhiteSpace(strRole) || !strRole.Contains("|"))
            {
                return false;
            }

            bool res = RoleCheck_DAL.Instance.IsAccountHasTheRole(companyID, accountID, strRole);
            return res;
        }
    }
}
