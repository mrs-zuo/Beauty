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
    public class Commodity_MController : BaseController
    {

        [HttpPost]
        [ActionName("getCommodityList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCommodityList(JObject obj)
        {
            ObjectResult<List<Commodity_Model>> res = new ObjectResult<List<Commodity_Model>>();
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

            List<Commodity_Model> list = new List<Commodity_Model>();
            list = Commodity_BLL.Instance.getCommodityListForWeb(this.CompanyID, operationModel.CategoryID, operationModel.ImageWidth, operationModel.ImageHeight, operationModel.BranchID, operationModel.SupplierID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("deleteCommodity")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deleteCommodity(JObject obj)
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<Commodity_Model> list = new List<Commodity_Model>();
            bool result = Commodity_BLL.Instance.deleteCommodity(this.UserID, operationModel.CommodityCode, this.CompanyID);
            //list = Commodity_BLL.Instance.deleteCommodity(this.UserID, operationModel, operationModel.ImageWidth, operationModel.ImageHeight, operationModel.BranchID);

            res.Code = "1";
            res.Data = true;
            //res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getCommodityDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCommodityDetail(JObject obj)
        {
            ObjectResult<CommodityDetail_Model> res = new ObjectResult<CommodityDetail_Model>();
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

            CommodityDetail_Model model = new CommodityDetail_Model();
            model = Commodity_BLL.Instance.getCommodityDetailForWeb(this.CompanyID, this.BranchID, operationModel.CommodityCode, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getCommoditySupplierDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCommoditySupplierDetail(JObject obj)
        {
            ObjectResult<CommodityDetail_Model> res = new ObjectResult<CommodityDetail_Model>();
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

            CommodityDetail_Model model = new CommodityDetail_Model();
            model = Commodity_BLL.Instance.getCommoditySupplierDetailForWeb(this.CompanyID, operationModel.CommodityCode);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("updateCommodityDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateCommodityDetail(JObject obj)
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

            CommodityDetailOperation_Model model = new CommodityDetailOperation_Model();
            model = JsonConvert.DeserializeObject<CommodityDetailOperation_Model>(strSafeJson);

            model.BranchID = this.BranchID;
            model.UpdaterID = this.UserID;
            model.CompanyID = this.CompanyID;
            int commodityID = Commodity_BLL.Instance.updateCommodityDetail(model);
            if (commodityID > 0)
            {
                ProductImageOperation_Model mImage = new ProductImageOperation_Model();
                mImage.DeleteImage = null;
                mImage.CompanyID = model.CompanyID;
                mImage.BranchID = model.BranchID;
                mImage.UserID = this.UserID;
                mImage.OperationTime = DateTime.Now.ToLocalTime();
                mImage.OriginalCommodityID = model.CommodityID;
                bool idChange = false;
                if (model.CommodityID != commodityID)
                {
                    idChange = true;
                }
                mImage.CommodityID = commodityID;
                mImage.CommodityCode = model.CommodityCode;

                if ((model.deleteImageUrl != null && model.deleteImageUrl.Count > 0) || (model.BigImageUrl != null && model.BigImageUrl.Count > 0) || (!string.IsNullOrEmpty(model.Thumbnail)))
                {
                    mImage.AddBigImage = model.BigImageUrl;
                    mImage.AddThumbnail = model.Thumbnail;
                    mImage.DeleteImage = model.deleteImageUrl;
                }
                Image_BLL.Instance.updateCommodityImage(mImage, idChange);

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
        [ActionName("addCommodity")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addCommodity(JObject obj)
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

            CommodityDetailOperation_Model model = new CommodityDetailOperation_Model();
            model = JsonConvert.DeserializeObject<CommodityDetailOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.UpdaterID = this.UserID;
            long commodityCode = 0;

            int commodityID = Commodity_BLL.Instance.addCommodity(model, out commodityCode);
            if (commodityID == 0)
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
                mImage.CommodityID = commodityID;
                mImage.AddBigImage = model.BigImageUrl;
                mImage.AddThumbnail = model.Thumbnail;
                mImage.CommodityCode = commodityCode;

                Image_BLL.Instance.updateCommodityImage(mImage, false);

            }

            addProductResult_Model resModel = new addProductResult_Model();
            resModel.ProductID = commodityID;
            resModel.ProductCode = commodityCode;

            res.Code = "1";
            res.Data = resModel;
            res.Message = "添加成功!";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("deteleMultiCommodity")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deteleMultiCommodity(JObject obj)
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

            bool result = Commodity_BLL.Instance.deteleMultiCommodity(model);
            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "删除成功！";
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("BatchAddCommodity")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage BatchAddCommodity(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "添加失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            BatchAddCommodity_Model model = new BatchAddCommodity_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<BatchAddCommodity_Model>(strSafeJson);
            model.mCommodity.CompanyID = this.CompanyID;
            model.mCommodity.CreatorID = this.UserID;
            model.mCommodity.CreateTime = DateTime.Now.ToLocalTime();
            model.mCommodity.BranchID = this.BranchID;

            bool result = Commodity_BLL.Instance.BatchAddCommodity(model);
            //Common.WriteLOG.WriteLog("Commodity_BLL.Instance.BatchAddCommodity result = " + result.ToString());
            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "添加成功！";
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("downloadCommodityList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage downloadCommodityList(JObject obj)
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

            string data = Commodity_BLL.Instance.downloadCommodityList(model);
            if (string.IsNullOrEmpty(data))
                return toJson(res);
            res.Code = "1";
            res.Data = data;
            return toJson(res);
        }

        /// <summary>
        /// 批量添加商品批次模板下载
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("downloadCommodityBatchTemplateList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage downloadCommodityBatchTemplateList(JObject obj)
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

            string data = Commodity_BLL.Instance.downloadCommodityBatchTemplateList(model);
            if (string.IsNullOrEmpty(data))
                return toJson(res);
            res.Code = "1";
            res.Data = data;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getPrintList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getPrintList(JObject obj)
        {
            ObjectResult<List<Commodity_Model>> res = new ObjectResult<List<Commodity_Model>>();
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

            List<Commodity_Model> list = Commodity_BLL.Instance.getPrintList(model.CodeList);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateCommoditySort")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateCommoditySort(JObject obj)
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


            bool isSuccess = Commodity_BLL.Instance.UpdateCommoditySort(this.CompanyID, model.Prama);
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
        [ActionName("DoAddBatch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DoAddBatch(JObject obj)
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

            Product_Stock_Batch_Model model = new Product_Stock_Batch_Model();
            model = JsonConvert.DeserializeObject<Product_Stock_Batch_Model>(strSafeJson);

            model.OperatorID = this.UserID;
            model.CompanyID = this.CompanyID;

            bool result = false;

            //判断同一个商品是否有相同的商品批次番号
            Product_Stock_Batch_Model resultSame = null;

            resultSame = Commodity_BLL.Instance.getProductStockBatchByProductCodeAndBatchNO(model);
            if (resultSame !=null )
            {
                res.Message = "批次番号 " + model.BatchNO + "  已经存在！";
                res.Code = "0";
                res.Data = false;
                return toJson(res);
            }
            else
            {
                result = Commodity_BLL.Instance.AddBatch(model);

                if (result)
                {
                    res.Message = "添加成功！";
                    res.Code = "1";
                    res.Data = true;
                    return toJson(res);
                }
                else
                {
                    return toJson(res);
                }
            }

            
                
        }

        [HttpPost]
        [ActionName("updateBatchStocks")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateBatchStocks(JObject obj)
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

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj["batchList"]);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<BatchCommodityOperation_Model.BatchStockOperation_Model> BatchOperationModel = new List<BatchCommodityOperation_Model.BatchStockOperation_Model>();
            BatchOperationModel = JsonConvert.DeserializeObject<List<BatchCommodityOperation_Model.BatchStockOperation_Model>>(strSafeJson);
            
            if (BatchOperationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            for (int i = 0; i < BatchOperationModel.Count; i++)
            {
                if (string.IsNullOrEmpty(BatchOperationModel[i].Quantity.ToString()) || string.IsNullOrEmpty(BatchOperationModel[i].ExpiryDate.ToString()))
                {
                    res.Message = "不合法参数";
                    return toJson(res);
                }
            }

            bool issuccess = Commodity_BLL.Instance.updateBatch(BatchOperationModel, this.CompanyID, this.UserID);

            if (issuccess)
            {
                res.Code = "1";
                res.Data = issuccess;
                res.Message = "操作成功";
            }
            else
            {
                res.Code = "0";
                res.Data = issuccess;
                res.Message = "操作失败";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("deleteBatch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deleteBatch(JObject obj)
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

            BatchCommodityOperation_Model.DelBatchOperation_Model operationModel = new BatchCommodityOperation_Model.DelBatchOperation_Model();
            operationModel = JsonConvert.DeserializeObject<BatchCommodityOperation_Model.DelBatchOperation_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.deleteBatch(this.UserID, operationModel.ID, operationModel.Quantity, operationModel.BranchID, operationModel.ProductCode, operationModel.BatchNO, this.CompanyID, this.UserID);

            if (result)
            {
                res.Code = "1";
                res.Data = result;
                res.Message = "删除成功";
            }
            else
            {
                res.Code = "0";
                res.Data = result;
                res.Message = "删除失败";
            }

            return toJson(res);
        }
        [HttpPost]
        [ActionName("getStorageDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getStorageDetail(JObject obj)
        {
            ObjectResult<List<StorageDetail_Model>> res = new ObjectResult<List<StorageDetail_Model>>();
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

            UtilityOperation_Model getStorageDetail = new UtilityOperation_Model();
            getStorageDetail = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<StorageDetail_Model> list = Commodity_BLL.Instance.getStorageDetail(getStorageDetail);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }
        [HttpPost]
        [ActionName("operateQuantity")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage operateQuantity(JObject obj)
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

            StorageDetail_Model operateQuantity = new StorageDetail_Model();
            operateQuantity = JsonConvert.DeserializeObject<StorageDetail_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.operateQuantity(operateQuantity,this.CompanyID,this.UserID);

            if (result)
            {
                res.Code = "1";
                res.Data = result;
                res.Message = "入库成功";
            }
            else
            {
                res.Code = "0";
                res.Data = result;
                res.Message = "入库失败";
            }

            return toJson(res);
        }
        [HttpPost]
        [ActionName("getQuantity")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getQuantity(JObject obj)
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
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

            UtilityOperation_Model getQuantity = new UtilityOperation_Model();
            getQuantity = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            int quantity = Commodity_BLL.Instance.getQuantity(getQuantity);

            res.Code = "1";
            res.Data = quantity;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("applyCommodityCode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage applyCommodityCode(JObject obj)
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

            StorageDetail_Model applyCommodityCode = new StorageDetail_Model();
            applyCommodityCode = JsonConvert.DeserializeObject<StorageDetail_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.applyCommodityCode(applyCommodityCode, this.CompanyID,this.BranchID, this.UserID);

            if (result)
            {
                res.Code = "1";
                res.Data = result;
                res.Message = "申请成功";
            }
            else
            {
                res.Code = "0";
                res.Data = result;
                res.Message = "申请失败";
            }

            return toJson(res);
        }
        [HttpPost]
        [ActionName("agreeCommodityCode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage agreeCommodityCode(JObject obj)
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

            StorageDetail_Model agreeCommodityCode = new StorageDetail_Model();
            agreeCommodityCode = JsonConvert.DeserializeObject<StorageDetail_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.agreeCommodityCode(agreeCommodityCode,this.UserID);

            if (result)
            {
                res.Code = "1";
                res.Data = result;
                res.Message = "申请成功";
            }
            else
            {
                res.Code = "0";
                res.Data = result;
                res.Message = "申请失败";
            }

            return toJson(res);
        }
        [HttpPost]
        [ActionName("negativeCommodityCode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage negativeCommodityCode(JObject obj)
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

            StorageDetail_Model negativeCommodityCode = new StorageDetail_Model();
            negativeCommodityCode = JsonConvert.DeserializeObject<StorageDetail_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.negativeCommodityCode(negativeCommodityCode, this.UserID);

            if (result)
            {
                res.Code = "1";
                res.Data = result;
                res.Message = "申请成功";
            }
            else
            {
                res.Code = "0";
                res.Data = result;
                res.Message = "申请失败";
            }

            return toJson(res);
        }
        [HttpPost]
        [ActionName("confirmCommodityCode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage confirmCommodityCode(JObject obj)
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

            StorageDetail_Model confirmCommodityCode = new StorageDetail_Model();
            confirmCommodityCode = JsonConvert.DeserializeObject<StorageDetail_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.confirmCommodityCode(confirmCommodityCode, this.UserID);

            if (result)
            {
                res.Code = "1";
                res.Data = result;
                res.Message = "申请成功";
            }
            else
            {
                res.Code = "0";
                res.Data = result;
                res.Message = "申请失败";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("getCommodityDetailByCommodityModel")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCommodityDetailByCommodityModel(JObject obj)
        {
            ObjectResult<CommodityDetail_Model> res = new ObjectResult<CommodityDetail_Model>();
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
            CommodityDetail_Model operationModel = new CommodityDetail_Model();
            operationModel = JsonConvert.DeserializeObject<CommodityDetail_Model>(strSafeJson);

            CommodityDetail_Model model = new CommodityDetail_Model();
            model = Commodity_BLL.Instance.getCommodityDetailByCommodityModel(this.CompanyID, this.BranchID, operationModel.CommodityName);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getProductStockBatchByProductCodeAndBatchNO")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getProductStockBatchByProductCodeAndBatchNO(JObject obj)
        {
            ObjectResult<Product_Stock_Batch_Model> res = new ObjectResult<Product_Stock_Batch_Model>();
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

            Product_Stock_Batch_Model operationModel = new Product_Stock_Batch_Model();
            operationModel = JsonConvert.DeserializeObject<Product_Stock_Batch_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            Product_Stock_Batch_Model model = Commodity_BLL.Instance.getProductStockBatchByProductCodeAndBatchNO(operationModel);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }
    }
}
