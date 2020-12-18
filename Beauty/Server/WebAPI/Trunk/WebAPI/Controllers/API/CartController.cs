using HS.Framework.Common;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
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

namespace WebAPI.Controllers.API
{
    public class CartController : BaseController
    {

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns>{"CommodityCode":1501150000000005,"Quantity":2}</returns>
        [HttpPost]
        [ActionName("AddCart")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage AddCart(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
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

            CartOperation_Model operationModel = new CartOperation_Model();
            operationModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (operationModel.CommodityCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Quantity <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.BranchID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.CustomerID = this.UserID;
            operationModel.Status = 0;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = operationModel.CreateTime;

            int result = Cart_BLL.Instance.addCart(operationModel);
            switch (result)
            {
                case 3:
                    res.Code = "0";
                    res.Message = Resources.sysMsg.errQuantityNotSufficient;
                    break;
                case 1:
                    res.Code = "1";
                    res.Data = true;
                    res.Message = Resources.sysMsg.sucCartAdd;
                    break;
                default:
                    res.Code = "0";
                    res.Message = Resources.sysMsg.errCartAdd;
                    break;
            }
            return toJson(res);

        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns>{"CommodityCode":1501150000000005,"Quantity":5,"CartID":190}</returns>
        [HttpPost]
        [ActionName("UpdateCart")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage UpdateCart(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
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

            CartOperation_Model operationModel = new CartOperation_Model();
            operationModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (operationModel.CommodityCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Quantity <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.CartID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.BranchID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.CustomerID = this.UserID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = operationModel.CreateTime;

            int result = Cart_BLL.Instance.updateCart(operationModel);
            switch (result)
            {
                case 3:
                    res.Code = "0";
                    res.Message = Resources.sysMsg.errQuantityNotSufficient;
                    break;
                case 1:
                    res.Code = "1";
                    res.Data = true;
                    res.Message = Resources.sysMsg.sucCartUpdate;
                    break;
                default:
                    res.Code = "0";
                    res.Message = Resources.sysMsg.errCartUpdate;
                    break;
            }
            return toJson(res);

        }




        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns>{"CartIDList":[{"CartID":192}]}</returns>
        [HttpPost]
        [ActionName("DeleteCart")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage DeleteCart(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
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

            CartOperation_Model operationModel = new CartOperation_Model();
            operationModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (operationModel.CartIDList == null || operationModel.CartIDList.Count == 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            bool result = Cart_BLL.Instance.deleteCart(operationModel.CartIDList, this.UserID);
            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = Resources.sysMsg.sucCartDel;
            }
            else
            {
                res.Code = "0";
                res.Message = Resources.sysMsg.errCartDel;
            }
            return toJson(res);

        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns>{"ImageHeight":20,"ImageWidth":20}</returns>
        [HttpPost]
        [ActionName("GetCartList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetCartList(JObject obj)
        {
            ObjectResult<List<GetCartList_Model>> res = new ObjectResult<List<GetCartList_Model>>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            if (obj == null)
            {
                operationModel.ImageHeight = 160;
                operationModel.ImageWidth = 160;
            }
            else
            {
                string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
                if (string.IsNullOrEmpty(strSafeJson))
                {
                    res.Message = "不合法参数";
                    return toJson(res);
                }
                operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

                if (operationModel.ImageHeight <= 0)
                {
                    operationModel.ImageHeight = 160;
                }

                if (operationModel.ImageWidth <= 0)
                {
                    operationModel.ImageWidth = 160;
                }
            }

            List<GetCartList_Model> list = new List<GetCartList_Model>();
            list = Cart_BLL.Instance.getCartList(this.UserID, this.CompanyID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }




        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetCartCount")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetCartCount()
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
            res.Data = 0;

            int result = Cart_BLL.Instance.getCartCount(this.UserID);

            res.Code = "1";
            res.Data = result;
            return toJson(res);

        }
    }
}
