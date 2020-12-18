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
using HS.Framework.Common.Util;
using WebAPI.Common;
using System.IO;

namespace WebAPI.Controllers.API
{
    public class ImageController : BaseController
    {

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"TreatmentID":143}</param>
        /// <returns></returns>
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

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("UpdateServiceEffectImage")]
        [HTTPBasicAuthorizeAttribute]
        //{"TreatmentID":153933,"GroupNo":1539330054584518,"CustomerID":123456,"AddImage":[{"ImageFormat":".JPEG","ImageType":0,"ImageString":""}],"DeleteImage":[{"ImageID":2}]}
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

            if (operationModel.TreatmentID <= 0 && operationModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.AddImage == null && operationModel.DeleteImage == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            bool result = Image_BLL.Instance.updateServiceEffectImage(this.UserID, this.CompanyID, operationModel.CustomerID, operationModel.TreatmentID, operationModel.GroupNo, operationModel.AddImage, operationModel.DeleteImage);
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

            if (operationModel.CustomerID <= 0 )
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

            List<AllServiceEffect_Model> list = Image_BLL.Instance.GetAllServiceEffectByCustomerID(operationModel.CustomerID, this.CompanyID, origionImageSize, operationModel.ImageThumbWidth, operationModel.ImageThumbHeight);
            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }
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

            ServiceEffectImageOperation_Model operationModel = new ServiceEffectImageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ServiceEffectImageOperation_Model>(strSafeJson);

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


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
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
                    string temp = Common.Const.strHttp + Common.Const.server + Common.Const.strMothod + CompanyID + "/" + (this.IsBusiness ? Common.Const.strImageObjectType1 : Common.Const.strImageObjectType0) + UserID + "/" + fileName + "'&th='" + operationModel.ImageHeight.ToString() + "'&tw='" + operationModel.ImageWidth.ToString() + "'&bg=FFFFFF'";
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
    }
}
