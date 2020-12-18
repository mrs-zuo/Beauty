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
    public class Service_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetServiceList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetServiceList(JObject obj)
        {
            ObjectResult<List<Service_Model>> res = new ObjectResult<List<Service_Model>>();
            res.Code = "0";
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            operationModel.CompanyID = this.CompanyID;
            //operationModel.BranchID = this.BranchID;
            operationModel.AccountID = this.UserID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 70;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 70;
            }

            List<Service_Model> list = new List<Service_Model>();
            list = Service_BLL.Instance.getServiceListForWeb(this.CompanyID, operationModel.CategoryID, operationModel.ImageWidth, operationModel.ImageHeight, operationModel.BranchID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetServiceDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetServiceDetail(JObject obj)
        {
            ObjectResult<Service_Model> res = new ObjectResult<Service_Model>();
            res.Code = "0";
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

            BrowseHistoryOperation_Model operationModel = new BrowseHistoryOperation_Model();
            operationModel = JsonConvert.DeserializeObject<BrowseHistoryOperation_Model>(strSafeJson);

            Service_Model model = new Service_Model();
            model = Service_BLL.Instance.getServiceDetailForWeb(this.CompanyID, operationModel.ServiceCode,this.BranchID);

            if (model == null)
            {
                model = new Service_Model();
            }
            else
            {
                List<ImageCommon_Model> allImgList = Service_BLL.Instance.getImgList(this.CompanyID, model.ID);
                if (allImgList != null && allImgList.Count > 0)
                {
                    List<ImageCommon_Model> imgmodel = allImgList.Where(c => c.ObjectType == 0).ToList();
                    if(imgmodel!=null && imgmodel.Count>0)
                    {
                        model.thumbImage = imgmodel[0];
                    }
                    model.BigImageList = allImgList.Where(c => c.ObjectType == 1).ToList();
                }
            }

            List<ServiceBranch> branchList = Service_BLL.Instance.getServiceBranchListForWeb(this.CompanyID, operationModel.ServiceCode,this.BranchID);
            model.BranchList = branchList;

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getSubserviceCodeByName")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getSubserviceCodeByName(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;

            int subserviceCode = Service_BLL.Instance.getSubserviceCodeByName(utilityModel.CompanyID, utilityModel.SubserviceName);

            if (subserviceCode > 0)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = subserviceCode;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("downloadServiceList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage downloadServiceList(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Data = null;
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.IsBusiness = this.IsBusiness;
            model.AccountID = this.UserID;

            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }

            string data = Service_BLL.Instance.downloadServiceList(model);
            if (string.IsNullOrEmpty(data))
                return toJson(res);
            res.Code = "1";
            res.Data = data;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("deteleMultiService")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deteleMultiService(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "删除失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            DelMultiCommodity_Model model = new DelMultiCommodity_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<DelMultiCommodity_Model>(strSafeJson);
            model.UpdaterID = this.UserID;

            bool result = Service_BLL.Instance.deteleMultiService(model);
            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "删除成功！";
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getPrintList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getPrintList(JObject obj)
        {
            ObjectResult<List<Service_Model>> res = new ObjectResult<List<Service_Model>>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            DelMultiCommodity_Model model = new DelMultiCommodity_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<DelMultiCommodity_Model>(strSafeJson);
            model.UpdaterID = this.UserID;

            List<Service_Model> list = Service_BLL.Instance.getPrintList(model.CodeList);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("updateServiceDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateServiceDetail(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "更新失败！";

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

            ServiceDetailOperation_Model model = new ServiceDetailOperation_Model();
            model = JsonConvert.DeserializeObject<ServiceDetailOperation_Model>(strSafeJson);

            model.BranchID = this.BranchID;
            model.UpdaterID = this.UserID;
            model.CompanyID = this.CompanyID;
            int serviceID = Service_BLL.Instance.updateService(model);
            if (serviceID > 0)
            {
                ProductImageOperation_Model mImage = new ProductImageOperation_Model();
                mImage.DeleteImage = null;
                mImage.CompanyID = model.CompanyID;
                mImage.BranchID = model.BranchID;
                mImage.UserID = this.UserID;
                mImage.OperationTime = DateTime.Now.ToLocalTime();
                mImage.OriginalServiceID = model.ServiceID;
                bool idChange = false;
                if (model.ServiceID != serviceID) {
                    idChange = true;
                }
                mImage.ServiceID = serviceID;
                mImage.ServiceCode = model.ServiceCode;

                if ((model.deleteImageUrl != null && model.deleteImageUrl.Count > 0) || (model.BigImageUrl != null && model.BigImageUrl.Count > 0) || (!string.IsNullOrEmpty(model.Thumbnail)))
                {
                    mImage.AddBigImage = model.BigImageUrl;
                    mImage.AddThumbnail = model.Thumbnail;
                    mImage.DeleteImage = model.deleteImageUrl;
                }
                Image_BLL.Instance.updateServiceImage(mImage, idChange);

                res.Message = "更新成功！";
                res.Code = "1";
                res.Data = true;
                return toJson(res);
            }
            else
                return toJson(res);
        }

        [HttpPost]
        [ActionName("updateProductStocks")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateProductStocks(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "更新失败！";

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

            BranchCommodityOperation_Model model = new BranchCommodityOperation_Model();
            model = JsonConvert.DeserializeObject<BranchCommodityOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.OperatorID = this.UserID;
            model.OperateTime = DateTime.Now.ToLocalTime();
            model.Type = 1;

            bool resu = Commodity_BLL.Instance.OperateProductStock(model);
            if (resu)
            {
                res.Message = "更新成功！";
                res.Code = "1";
                res.Data = true;
                return toJson(res);
            }
            else
                return toJson(res);
        }

        [HttpPost]
        [ActionName("addService")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addService(JObject obj)
        {
            ObjectResult<addProductResult_Model> res = new ObjectResult<addProductResult_Model>();
            res.Code = "0";
            res.Data = null;
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

            ServiceDetailOperation_Model model = new ServiceDetailOperation_Model();
            model = JsonConvert.DeserializeObject<ServiceDetailOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            long serviceCode = 0;

            int serviceID = Service_BLL.Instance.addService(model,out serviceCode);
            if (serviceID == 0)
            {
                return toJson(res);
            }

            if ((model.BigImageUrl != null && model.BigImageUrl.Count > 0) || !string.IsNullOrEmpty(model.Thumbnail))
            {
                ProductImageOperation_Model mImage = new ProductImageOperation_Model();
                mImage.DeleteImage = null;
                mImage.CompanyID = model.CompanyID;
                mImage.BranchID = this.BranchID;
                mImage.UserID = this.UserID;
                mImage.OperationTime = DateTime.Now.ToLocalTime();
                mImage.ServiceID = serviceID;
                mImage.AddBigImage = model.BigImageUrl;
                mImage.AddThumbnail = model.Thumbnail;
                mImage.ServiceCode = serviceCode;

                Image_BLL.Instance.updateServiceImage(mImage,false);
            }
            addProductResult_Model resModel = new addProductResult_Model();
            resModel.ProductID = serviceID;
            resModel.ProductCode = serviceCode;

            res.Code = "1";
            res.Data = resModel;
            res.Message = "添加成功!";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateServiceSort")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateServiceSort(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


            bool isSuccess = Service_BLL.Instance.UpdateServiceSort(this.CompanyID, model.Prama);
            if (isSuccess)
            {
                res.Code = "1";
                res.Data = isSuccess;
                res.Message = "操作成功";
            }
            else
            {
                res.Code = "0";
                res.Data = isSuccess;
                res.Message = "操作失败";
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getSubServiceList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getSubServiceList(JObject obj)
        {
            ObjectResult<List<SubService_Model>> res = new ObjectResult<List<SubService_Model>>();
            res.Code = "0";
            res.Data = null;
            List<SubService_Model> list = new List<SubService_Model>();

            list = Service_BLL.Instance.getSubServiceList(this.CompanyID);
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("OperationServiceBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage OperationServiceBranch(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            ServiceDetailOperation_Model model = new ServiceDetailOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<ServiceDetailOperation_Model>(strSafeJson);

            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();

            bool isSuccess = Service_BLL.Instance.OperationServiceBranch(model);
            if (isSuccess)
            {
                res.Code = "1";
                res.Data = isSuccess;
                res.Message = "操作成功";
            }
            else
            {
                res.Code = "0";
                res.Data = isSuccess;
                res.Message = "操作失败";
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("exsitSubserviceCode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage exsitSubserviceCode(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;

            bool existServiceCode = Service_BLL.Instance.exsitSubserviceCode(utilityModel.CompanyID, utilityModel.SubServiceCode);

            if (existServiceCode)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = existServiceCode;
            }

            return toJson(res);
        }
    }
}
