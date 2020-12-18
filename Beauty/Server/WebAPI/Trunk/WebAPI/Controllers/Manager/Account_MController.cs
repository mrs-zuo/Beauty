using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Account_MController : BaseController
    {

        [HttpPost]
        [ActionName("GetAccountList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountList(JObject obj)
        {
            ObjectResult<List<AccountListForWeb_Model>> res = new ObjectResult<List<AccountListForWeb_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<AccountListForWeb_Model> list = new List<AccountListForWeb_Model>();
            list = Account_BLL.Instance.getAccountListForWeb(this.UserID, utilityModel.BranchID, this.CompanyID, utilityModel.Available, utilityModel.InputSearch);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCustomerListByAccountID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerListByAccountID(JObject obj)
        {
            ObjectResultSup<List<CustomerList_Model>> res = new ObjectResultSup<List<CustomerList_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;

            res = Customer_BLL.Instance.GetCustomerList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.AccountID, 50, 50, utilityModel.Type, "", -1, null, -1,0,null,0
                , utilityModel.PageFlg, utilityModel.PageIndex, utilityModel.PageSize
                , utilityModel.CustomerName, utilityModel.CustomerTel, utilityModel.SearchDateTime);
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetAccountDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountDetail(JObject obj)
        {
            ObjectResult<Account_Model> res = new ObjectResult<Account_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            Account_Model model = new Account_Model();
            model = Account_BLL.Instance.getAccountDetailForWeb(utilityModel.ID, this.CompanyID);

            if (model == null)
            {
                model = new Account_Model();
            }
            model.BranchList = new List<BranchSelection_Model>();
            model.BranchList = Account_BLL.Instance.getBranchIDListForWeb(this.CompanyID, utilityModel.ID, this.BranchID);

            model.TagsList = new List<AccountTag_Model>();
            model.TagsList = Account_BLL.Instance.getTagsIDListForWeb(this.CompanyID, utilityModel.ID, this.BranchID);

            model.RoleList = new List<Role_Model>();
            model.RoleList = RoleCheck_BLL.Instance.getRoleList(this.CompanyID);


            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("AddAccount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddAccount(JObject obj)
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
            res.Message = "";
            res.Data = 0;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Account_Model model = new Account_Model();
            model = JsonConvert.DeserializeObject<Account_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.CreatorID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();

            //Common.WriteLOG.WriteLog("Account_MController.AddAccount");

            bool isCan = Account_BLL.Instance.isCanAddAccount(this.CompanyID);
            if (!isCan)
            {
                res.Code = "0";
                res.Message = "员工数量已经达到最大允许员工数量!";
                res.Data = 0;
                return toJson(res);
            }



            int userId = Account_BLL.Instance.AddAccount(model);


            if (userId > 0)
            {
                res.Code = "1";
                res.Message = "账户添加成功!";
                res.Data = userId;
                if (model.HeadImageFile != null)
                {
                    bool result = Image_BLL.Instance.ImageMove(model.HeadImageFile, 1, userId, model.CompanyID);
                }
            }
            else
            {
                res.Code = "0";
                res.Message = "账户添加失败!";
                res.Data = 0;

            }


            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateAccount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateAccount(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Account_Model model = new Account_Model();
            model = JsonConvert.DeserializeObject<Account_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = Account_BLL.Instance.UpdateAccount(model);


            if (result)
            {
                res.Code = "1";
                res.Message = "账户修改成功!";
                res.Data = true;
                if (model.HeadImageFile != null)
                {
                    result = Image_BLL.Instance.ImageMove(model.HeadImageFile, 1, model.UserID, model.CompanyID);
                }
            }
            else
            {
                res.Code = "0";
                res.Message = "账户修改失败!";
                res.Data = false;

            }


            return toJson(res);
        }


        [HttpPost]
        [ActionName("IsExsitAccountMobileInCompany")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage IsExsitAccountMobileInCompany(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "该账号已存在!";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Account_Model model = new Account_Model();
            model = JsonConvert.DeserializeObject<Account_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;

            bool result = Account_BLL.Instance.IsExsitAccountMobileInCompany(model);


            res.Code = "1";
            res.Data = result;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("IsExsitAccountNameInCompany")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage IsExsitAccountNameInCompany(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "该用户名已存在!";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Account_Model model = new Account_Model();
            model = JsonConvert.DeserializeObject<Account_Model>(strSafeJson);

            bool result = Account_BLL.Instance.IsExsitAccountNameInCompany(model);

            res.Code = "1";
            res.Data = result;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetHierarchyList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetHierarchyList(JObject obj)
        {
            ObjectResult<List<Hierarchy_Model>> res = new ObjectResult<List<Hierarchy_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model model = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.UserID <= 0)
            {
                model.UserID = this.UserID;
            }

            List<Hierarchy_Model> list = new List<Hierarchy_Model>();
            list = Account_BLL.Instance.getHierarchyList(model.UserID, model.Type);

            Hierarchy_Model Top = new Hierarchy_Model();
            if (model.UserID == this.UserID)
            {
                Top = Account_BLL.Instance.getLoginAccount(model.UserID);
            }
            else
            {
                Top = Account_BLL.Instance.getTopAccount(model.UserID);
            }

            List<Hierarchy_Model> result = new List<Hierarchy_Model>();
            result.Add(Top);
            if (list != null && list.Count > 0)
            {
                Stack<Hierarchy_Model> stackHier = new Stack<Hierarchy_Model>();
                Stack<Hierarchy_Model> stackTemp = new Stack<Hierarchy_Model>();
                stackTemp.Push(Top);
                while (stackTemp.Count != 0)
                {
                    Hierarchy_Model temp = stackTemp.Pop();
                    if (stackHier.Count != 0)
                    {
                        result.Add(stackHier.Pop());
                    }
                    List<Hierarchy_Model> tempList = list.Where(c => c.SuperiorID == temp.SubordinateID).ToList<Hierarchy_Model>();
                    if (tempList != null && tempList.Count > 0)
                    {
                        foreach (Hierarchy_Model item in tempList)
                        {
                            stackTemp.Push(item);
                            stackHier.Push(item);
                        }

                    }
                }
            }
            res.Code = "1";
            res.Data = result;


            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetHierarchyDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetHierarchyDetail(JObject obj)
        {
            ObjectResult<Hierarchy_Model> res = new ObjectResult<Hierarchy_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            Hierarchy_Model model = new Hierarchy_Model();
            model = Account_BLL.Instance.getHierarchyDetail(operationModel.ID);


            res.Code = "1";
            res.Data = model;


            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateHierarchy")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateHierarchy(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Hierarchy_Model operationModel = JsonConvert.DeserializeObject<Hierarchy_Model>(strSafeJson);
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();
            int result = Account_BLL.Instance.UpdateHierarchy(operationModel);

            if (result == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "更新成功";
            }
            else if (result == 0)
            {
                res.Message = "更新失败";
            }
            else if (result == -1)
            {
                res.Message = "更新的上级是已属下属";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("ResetPassword")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage ResetPassword(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Account_Model operationModel = JsonConvert.DeserializeObject<Account_Model>(strSafeJson);
            bool result = Account_BLL.Instance.resetPassword(operationModel);

            if (result)
            {
                res.Code = "1";
                res.Data = result;
                res.Message = "更新成功";
            }
            else
            {
                res.Message = "更新失败";
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("CheckAccountBranchCancel")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage CheckAccountBranchCancel(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            int result = Account_BLL.Instance.checkAccountBranchCancel(operationModel.UserID, operationModel.BranchID);

            if (result == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "";
            }
            else if (result == 2)
            {
                res.Message = "该账目下存在下层员工,不能取消";
            }
            else if (result == 3)
            {
                res.Message = "该账目下存在顾客,不能取消";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetAccountListUserByGroup")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountListUserByGroup(JObject obj)
        {
            ObjectResult<List<GetAccountListByGroupFroWeb_Model>> res = new ObjectResult<List<GetAccountListByGroupFroWeb_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            //if (obj == null)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

            //string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            //if (string.IsNullOrEmpty(strSafeJson))
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

            //UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            //utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<GetAccountListByGroupFroWeb_Model> list = new List<GetAccountListByGroupFroWeb_Model>();
            list = Account_BLL.Instance.getAccountListUsedByGroupForWeb(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }




        [HttpPost]
        [ActionName("IsCanAddAccount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage IsCanAddAccount()
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;



            bool result = Account_BLL.Instance.isCanAddAccount(this.CompanyID);


            if (result)
            {

                res.Code = "1";
                res.Data = true;
            }
            else
            {
                res.Code = "1";
                res.Message = "员工数量已经达到最大允许员工数量!";
                res.Data = false;

            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("CanDeleteAccount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage CanDeleteAccount(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "系统错误!";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Account_Model model = new Account_Model();
            model = JsonConvert.DeserializeObject<Account_Model>(strSafeJson);
            int result = Account_BLL.Instance.CanDeleteAccount(model.UserID, this.CompanyID);
            if (result == 1)
            {
                res.Code = "1";
                res.Data = true;
            }
            else
            {
                if (result == -1)
                {
                    res.Message = "请移除所属下属";
                }
                else if (result == -2)
                {
                    res.Message = "请移除所属顾客";
                }
            }


            return toJson(res);
        }



        [HttpPost]
        [ActionName("BranchSelect")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage BranchSelect(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "添加失败！";

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (this.BranchID > 0)
            {
                res.Message = "必须总部操作";
                return toJson(res);
            }


            AccountBranchOperation_Model model = new AccountBranchOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<AccountBranchOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.OperatorID = this.UserID;
            model.OperatorTime = DateTime.Now.ToLocalTime();
            bool result = false;

            result = Account_BLL.Instance.OperateBranch(model);


            res.Code = "1";
            res.Data = result;
            if (result)
            {
                res.Message = "操作成功!";
            }
            else
            {
                res.Message = "操作失败!";

            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetAccountCountInfo")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountCountInfo()
        {
            ObjectResult<AccountInfo_Model> res = new ObjectResult<AccountInfo_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            AccountInfo_Model model = new AccountInfo_Model();
            model = Account_BLL.Instance.getAccountCountInfo(this.CompanyID);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

    }
}
