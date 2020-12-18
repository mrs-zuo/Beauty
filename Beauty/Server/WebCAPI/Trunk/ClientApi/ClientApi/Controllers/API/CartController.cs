using ClientApi.Authorize;
using ClientAPI.BLL;
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

namespace ClientApi.Controllers.API
{
    public class CartController : BaseController
    {
        [HttpPost]
        [ActionName("AddCart")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddCart(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CartOperation_Model utilityModel = new CartOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.ProductCode <= 0 || utilityModel.BranchID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            utilityModel.Status = 1;
            utilityModel.CreatorID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();

            int addRes = Cart_BLL.Instance.addCart(utilityModel);

            if (addRes == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "添加购物车成功!";
            }
            else if (addRes == 3)
            {
                res.Code = "2";
                res.Data = false;
                res.Message = "库存不足!";
            }
            else
            {
                res.Code = "0";
                res.Data = false;
                res.Message = "添加购物车失败!";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateCart")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateCart(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CartOperation_Model utilityModel = new CartOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.CartID) || utilityModel.Quantity <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();

            int addRes = Cart_BLL.Instance.updateCart(utilityModel);

            if (addRes == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "修改购物车成功!";
            }
            else if (addRes == 3)
            {
                res.Code = "2";
                res.Data = false;
                res.Message = "库存不足!";
            }
            else
            {
                res.Code = "0";
                res.Data = false;
                res.Message = "修改购物车失败!";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteCart")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteCart(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CartOperation_Model utilityModel = new CartOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CartIDList == null || utilityModel.CartIDList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool addRes = Cart_BLL.Instance.deleteCart(utilityModel);

            if (addRes)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "删除购物车成功!";
            }
            else
            {
                res.Code = "0";
                res.Data = false;
                res.Message = "删除购物车失败!";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCartList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCartList(JObject obj)
        {
            ObjectResult<List<GetCartList_Model>> res = new ObjectResult<List<GetCartList_Model>>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            if (obj == null)
            {
                utilityModel.ImageHeight = 160;
                utilityModel.ImageWidth = 160;
            }
            else
            {
                string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
                if (string.IsNullOrEmpty(strSafeJson))
                {
                    res.Message = "不合法参数";
                    return toJson(res);
                }
                utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

                if (utilityModel.ImageHeight <= 0)
                {
                    utilityModel.ImageHeight = 160;
                }

                if (utilityModel.ImageWidth <= 0)
                {
                    utilityModel.ImageWidth = 160;
                }
            }

            List<GetCartList_Model> list = Cart_BLL.Instance.getCartList(this.UserID, this.CompanyID, utilityModel.ImageWidth, utilityModel.ImageHeight);
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }
    }
}
