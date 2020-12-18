using ClientApi.Authorize;
using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Common;

namespace ClientApi.Controllers.API
{
    public class ImageController : BaseController
    {
        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"CustomerID":33,"ImageHeight":"80","ImageWidth":"80"}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetPhotoAlbumList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetPhotoAlbumList(JObject obj)
        {
            ObjectResult<List<PhotoAlbumList_Model>> res = new ObjectResult<List<PhotoAlbumList_Model>>();
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

            TreatmentImageOperation_Model operationModel = new TreatmentImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<TreatmentImageOperation_Model>(strSafeJson);

            if (operationModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }




            List<PhotoAlbumList_Model> list = new List<PhotoAlbumList_Model>();

            list = Image_BLL.Instance.getPhotoAlbumList(operationModel.CustomerID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = list;
            return toJson(res, "yyyy-MM-dd");

        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"CustomerID":33,"CreateDate":"2014-06-04","ImageHeight":"80","ImageWidth":"80"}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetPhotoAlbumDetail")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetPhotoAlbumDetail(JObject obj)
        {
            ObjectResult<List<PhotoAlbumDetail_Model>> res = new ObjectResult<List<PhotoAlbumDetail_Model>>();
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

            TreatmentImageOperation_Model operationModel = new TreatmentImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<TreatmentImageOperation_Model>(strSafeJson);

            if (operationModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.CreateDate == "")
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 270;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 560;
            }




            string thumbnailSize = "'&th=" + operationModel.ImageHeight.ToString() + "&tw=" + operationModel.ImageWidth.ToString() + "&bg=FFFFFF'";


            if (operationModel.ImageThumbWidth <= 0)
            {
                operationModel.ImageThumbWidth = 270;
            }


            if (operationModel.ImageThumbHeight <= 0)
            {
                operationModel.ImageThumbHeight = 560;
            }

            List<PhotoAlbumDetail_Model> list = new List<PhotoAlbumDetail_Model>();

            list = Image_BLL.Instance.getPhotoAlbumDetail(operationModel.CustomerID, operationModel.CreateDate, thumbnailSize, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }


        [HttpPost]
        [ActionName("UpdateUserHeadImage")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage UpdateUserHeadImage(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Data = "";

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

            UserHeadImageOperation_Model operationModel = new UserHeadImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UserHeadImageOperation_Model>(strSafeJson);

            if (operationModel.ImageString == "")
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageType == "")
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            //检查文件夹是否存在 不存在则新建文件夹
            string folderPath = CommonUtility.updateUrlSpell(this.CompanyID, this.IsBusiness ? 1 : 0, this.UserID);
            if (folderPath == null)
            {
                folderPath = CommonUtility.updateUrlSpell(this.CompanyID, 0, this.UserID);
            }
            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }
            //生成图片名称
            string fileName = string.Format("{0:yyyyMMddHHmmssffff}", DateTime.Now.ToLocalTime()) + new Random().Next(100000).ToString("d5") + operationModel.ImageType;
            if (Image_BLL.Instance.addUserHeadImage(this.CompanyID, this.UserID, this.ClientType, operationModel.ImageString, folderPath + "/" + fileName))
            {
                bool result = Image_BLL.Instance.updateUserHeadImage(this.UserID, this.ClientType, fileName);
                if (result)
                {
                    res.Code = "1";
                    res.Message = Resources.sysMsg.sucHeadImageUpdate;
                    //返回成功后的图片路径
                    string temp = WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod + CompanyID + "/" + (this.IsBusiness ? WebAPI.Common.Const.strImageObjectType1 : WebAPI.Common.Const.strImageObjectType0) + UserID + "/" + fileName + "'&th='" + operationModel.ImageHeight.ToString() + "'&tw='" + operationModel.ImageWidth.ToString() + "'&bg=FFFFFF'";
                    res.Data = temp.Replace("'", "");
                }
                else
                {
                    res.Code = "0";
                    res.Message = Resources.sysMsg.errHeadImageUpdate;
                }
            }
            else
            {
                res.Code = "0";
                res.Message = Resources.sysMsg.errHeadImageUpdate;
            }
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetTreatmentImage")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetTreatmentImage(JObject obj)
        {
            ObjectResult<GetTreatmentImage_Model> res = new ObjectResult<GetTreatmentImage_Model>();
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

            TreatmentImageOperation_Model operationModel = new TreatmentImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<TreatmentImageOperation_Model>(strSafeJson);

            if (operationModel.TreatmentID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }


            string origionImageSize = "'&th=" + operationModel.ImageHeight.ToString() + "&tw=" + operationModel.ImageWidth.ToString() + "&bg=FFFFFF'";


            if (operationModel.ImageThumbWidth <= 0)
            {
                operationModel.ImageThumbWidth = 160;
            }


            if (operationModel.ImageThumbHeight <= 0)
            {
                operationModel.ImageThumbHeight = 160;
            }

            GetTreatmentImage_Model model = new GetTreatmentImage_Model();

            model = Image_BLL.Instance.getTreatmentImage(this.CompanyID, operationModel.TreatmentID, origionImageSize, operationModel.ImageThumbWidth, operationModel.ImageThumbHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }


        [HttpPost]
        [ActionName("getServiceEffectImage")]
        [HTTPBasicAuthorizeAttribute]
        //{"ImageThumbWidth":150,"TreatmentID":"154352","ImageThumbHeight":150,ImageWidth":150,"ImageHeight":150,"GroupNo":123123456897}
        public HttpResponseMessage getServiceEffectImage(JObject obj)
        {
            ObjectResult<GetServiceEffectImage_Model> res = new ObjectResult<GetServiceEffectImage_Model>();
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

            ServiceEffectImageOperation_Model operationModel = new ServiceEffectImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ServiceEffectImageOperation_Model>(strSafeJson);

            if (operationModel.TreatmentID <= 0 && operationModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }


            string origionImageSize = "''";// "'&th=" + operationModel.ImageHeight.ToString() + "&tw=" + operationModel.ImageWidth.ToString() + "&bg=FFFFFF&biFlg=1'";


            if (operationModel.ImageThumbWidth <= 0)
            {
                operationModel.ImageThumbWidth = 160;
            }


            if (operationModel.ImageThumbHeight <= 0)
            {
                operationModel.ImageThumbHeight = 160;
            }

            GetServiceEffectImage_Model model = new GetServiceEffectImage_Model();

            model = Image_BLL.Instance.getServiceEffectImage(this.CompanyID, operationModel.TreatmentID, operationModel.GroupNo, origionImageSize, operationModel.ImageThumbWidth, operationModel.ImageThumbHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetAllServiceEffectByCustomerID")]
        [HTTPBasicAuthorizeAttribute]
        //{"ImageThumbWidth":150,"ImageThumbHeight":150,ImageWidth":150,"ImageHeight":150,"CustomerID":1234}
        public HttpResponseMessage GetAllServiceEffectByCustomerID(JObject obj)
        {
            ObjectResult<List<AllServiceEffect_Model>> res = new ObjectResult<List<AllServiceEffect_Model>>();
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

            ServiceEffectImageOperation_Model operationModel = new ServiceEffectImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ServiceEffectImageOperation_Model>(strSafeJson);

            if (operationModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }


            string origionImageSize = "'&th=" + operationModel.ImageHeight.ToString() + "&tw=" + operationModel.ImageWidth.ToString() + "&bg=FFFFFF&biFlg=1'";


            if (operationModel.ImageThumbWidth <= 0)
            {
                operationModel.ImageThumbWidth = 160;
            }


            if (operationModel.ImageThumbHeight <= 0)
            {
                operationModel.ImageThumbHeight = 160;
            }

            List<AllServiceEffect_Model> list = Image_BLL.Instance.GetAllServiceEffectByCustomerID(operationModel.CustomerID, this.CompanyID, origionImageSize, operationModel.ImageThumbWidth, operationModel.ImageThumbHeight);
            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }


        [HttpPost]
        [ActionName("UpdateServiceEffectImage")]
        [HTTPBasicAuthorizeAttribute]
        //{"GroupNo":1539330054584518,"Comment":"dasadsadsdasads","AddImage":[{"ImageFormat":".JPEG","ImageType":0,"ImageString":""}],"DeleteImage":[{"ImageID":2}]}
        public HttpResponseMessage UpdateServiceEffectImage(JObject obj)
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

            ServiceEffectImageOperation_Model operationModel = new ServiceEffectImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ServiceEffectImageOperation_Model>(strSafeJson);

            if (operationModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            //if (operationModel.CustomerID <= 0)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

            //if (operationModel.AddImage == null && operationModel.DeleteImage == null)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}


            bool result = Image_BLL.Instance.updateServiceEffectImage(this.UserID, this.CompanyID, this.UserID, operationModel.TreatmentID, operationModel.GroupNo, operationModel.Comment, operationModel.AddImage, operationModel.DeleteImage);
            if (result)
            {
                res.Code = "1";
                res.Message = Resources.sysMsg.sucImageUpload;
            }
            else
            {
                res.Code = "0";
                res.Message = Resources.sysMsg.errImageUpload;
            }

            res.Data = result;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("getCustomerRecPic")]
        [HTTPBasicAuthorizeAttribute]
        //{"ServiceYear":2015,"ImageWidth":160,"ImageHeight":160}
        public HttpResponseMessage getCustomerRecPic(JObject obj)
        {
            ObjectResult<List<AllCustomerRecPic>> res = new ObjectResult<List<AllCustomerRecPic>>();
            res.Code = "0";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            

            UtilityOperation_Model operationModel = new UtilityOperation_Model();

            if (!string.IsNullOrEmpty(strSafeJson)) 
            {
                operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            }

            if (operationModel.ServiceYear <= 0)
            {
                operationModel.ServiceYear = DateTime.Now.Year;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            List<AllCustomerRecPic> list = Image_BLL.Instance.getCustomerRecPic(this.CompanyID, this.UserID, operationModel.ServiceYear, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("getCustomerServicePic")]
        [HTTPBasicAuthorizeAttribute]
        //{"ServiceCode":2012568547854,"ServiceYear":2015,"ImageWidth":160,"ImageHeight":160}
        public HttpResponseMessage getCustomerServicePic(JObject obj)
        {
            ObjectResult<CustomerRecPicDetail> res = new ObjectResult<CustomerRecPicDetail>();
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

            if (operationModel == null || operationModel.ServiceCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ServiceYear <= 0)
            {
                operationModel.ServiceYear = DateTime.Now.Year;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            CustomerRecPicDetail model = Image_BLL.Instance.getCustomerServicePic(this.CompanyID, this.UserID, operationModel.ServiceCode,operationModel.ServiceYear, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("getCustomerTGPic")]
        [HTTPBasicAuthorizeAttribute]
        //{"GroupNo":2012568547854,"ImageWidth":160,"ImageHeight":160}
        public HttpResponseMessage getCustomerTGPic(JObject obj)
        {
            ObjectResult<CustomerTGPic> res = new ObjectResult<CustomerTGPic>();
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

            if (operationModel == null || operationModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            CustomerTGPic model = Image_BLL.Instance.getCustomerTGPic(this.CompanyID, this.UserID, operationModel.GroupNo, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("getCustomerPicDetail")]
        [HTTPBasicAuthorizeAttribute]
        //{"RecordImgID":"2012568547854","ImageWidth":160,"ImageHeight":160}
        public HttpResponseMessage getCustomerPicDetail(JObject obj)
        {
            ObjectResult<CustomerTGPicList> res = new ObjectResult<CustomerTGPicList>();
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

            if (operationModel == null || string.IsNullOrWhiteSpace(operationModel.RecordImgID))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            CustomerTGPicList model = Image_BLL.Instance.getCustomerPicDetail(this.CompanyID, this.UserID, operationModel.RecordImgID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("editCustomerPic")]
        [HTTPBasicAuthorizeAttribute]
        //{"RecordImgID":"2012568547854","GroupNo":160,"ImageTag":"160","Type":1}
        public HttpResponseMessage editCustomerPic(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败";

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

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Type < 1 || operationModel.Type > 3)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Type == 1 && operationModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Type == 2 && string.IsNullOrWhiteSpace(operationModel.RecordImgID))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Type == 3 && string.IsNullOrWhiteSpace(operationModel.RecordImgID))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            bool isSuccess = Image_BLL.Instance.editCustomerPic(this.CompanyID, this.UserID, operationModel.RecordImgID, operationModel.GroupNo, operationModel.ImageTag, operationModel.Type);

            if (isSuccess)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "操作成功";
            }

            return toJson(res);

        }
    }
}
