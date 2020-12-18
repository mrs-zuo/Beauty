using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class InOutItem_MController : BaseController
    {
        /// <summary>
        /// 获取公司下面所有大项目
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetInOutItemAList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetInOutItemAList(JObject obj)
        {
            ObjectResult<List<InOutItemA_Model>> res = new ObjectResult<List<InOutItemA_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;
            List<InOutItemA_Model> list = new List<InOutItemA_Model>();
            list = InOutItem_BLL.Instance.GetInOutItemAList(this.CompanyID);
            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }
        /// <summary>
        /// 获取大项目下面所有中项目
        /// </summary>
        /// <param name="ItemAID">大项目ID</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetInOutItemBList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetInOutItemBList(JObject obj)
        {
            ObjectResult<List<InOutItemB_Model>> res = new ObjectResult<List<InOutItemB_Model>>();
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
            InOutItemB_Model model = JsonConvert.DeserializeObject<InOutItemB_Model>(strSafeJson);
            List<InOutItemB_Model> list = new List<InOutItemB_Model>();
            list = InOutItem_BLL.Instance.GetInOutItemBList(model.ItemAID);
            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }
        /// <summary>
        /// 获取中项目下面所有小项目
        /// </summary>
        /// <param name="ItemBID">中项目ID</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetInOutItemCList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetInOutItemCList(JObject obj)
        {
            ObjectResult<List<InOutItemC_Model>> res = new ObjectResult<List<InOutItemC_Model>>();
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
            InOutItemC_Model model = JsonConvert.DeserializeObject<InOutItemC_Model>(strSafeJson);
            List<InOutItemC_Model> list = new List<InOutItemC_Model>();
            list = InOutItem_BLL.Instance.GetInOutItemCList(model.ItemBID);
            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }
        /// <summary>
        /// 添加大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("AddInOutItemA")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddInOutItemA(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "添加失败";
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

            InOutItemAOperation_Model model = JsonConvert.DeserializeObject<InOutItemAOperation_Model>(strSafeJson);
            if (string.IsNullOrEmpty(model.ItemAName)) {
                res.Message = "项目名称不能为空";
                return toJson(res);
            }
            InOutItemA_Model ioModel = new InOutItemA_Model();
            ioModel.ItemAID = model.ItemAID;
            ioModel.ItemAName = model.ItemAName;
            ioModel.CompanyID = this.CompanyID;
            bool isExist = InOutItem_BLL.Instance.FindInOutItemASameItemAName(ioModel);
            if (isExist)
            {
                res.Code = "0";
                res.Message = "名称为  "+ model.ItemAName+"  大项目已经存在";
                res.Data = false;
            }
            else {
                model.COMPANYID = this.CompanyID;
                model.CreatorID = this.UserID;
                model.UpdaterID = this.UserID;
                bool rs = InOutItem_BLL.Instance.AddInOutItemA(model);
                res.Code = "1";
                res.Message = "添加成功";
                res.Data = rs;
            }
            return toJson(res);
        }
        /// <summary>
        /// 更新大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("UpdateInOutItemA")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateInOutItemA(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "修改失败";
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

            InOutItemAOperation_Model model = JsonConvert.DeserializeObject<InOutItemAOperation_Model>(strSafeJson);
            if (string.IsNullOrEmpty(model.ItemAName))
            {
                res.Message = "项目名称不能为空";
                return toJson(res);
            }
            InOutItemA_Model ioModel = new InOutItemA_Model();
            ioModel.ItemAID = model.ItemAID;
            ioModel.ItemAName = model.ItemAName;
            ioModel.CompanyID = this.CompanyID;
            bool isExist = InOutItem_BLL.Instance.FindInOutItemASameItemAName(ioModel);
            if (isExist)
            {
                res.Code = "0";
                res.Message = "名称为  " + model.ItemAName + "  大项目已经存在";
                res.Data = false;
            }
            else {
                model.COMPANYID = this.CompanyID;
                model.CreatorID = this.UserID;
                model.UpdaterID = this.UserID;
                bool rs = InOutItem_BLL.Instance.UpdateInOutItemA(model);
                res.Code = "1";
                res.Message = "修改成功";
                res.Data = rs;
            }
            return toJson(res);
        }
        /// <summary>
        /// 添加中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("AddInOutItemB")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddInOutItemB(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "添加失败";
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

            InOutItemBOperation_Model model = JsonConvert.DeserializeObject<InOutItemBOperation_Model>(strSafeJson);
            if (string.IsNullOrEmpty(model.ItemBName))
            {
                res.Message = "项目名称不能为空";
                return toJson(res);
            }
            if (model.ItemAID <= 0) {
                res.Message = "请选择大项目";
                return toJson(res);
            }
            InOutItemB_Model ioModel = new InOutItemB_Model();
            ioModel.ItemAID = model.ItemAID;
            ioModel.ItemBID = model.ItemBID;
            ioModel.ItemBName = model.ItemBName;
            bool isExist = InOutItem_BLL.Instance.FindInOutItemBSameItemBName(ioModel);
            if (isExist)
            {
                res.Code = "0";
                res.Message = "名称为  " + model.ItemBName + "  中项目已经存在";
                res.Data = false;
            }
            else {
                model.CreatorID = this.UserID;
                model.UpdaterID = this.UserID;
                bool rs = InOutItem_BLL.Instance.AddInOutItemB(model);
                res.Code = "1";
                res.Message = "添加成功";
                res.Data = rs;
            }
            return toJson(res);
        }
        /// <summary>
        /// 更新中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("UpdateInOutItemB")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateInOutItemB(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "修改失败";
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

            InOutItemBOperation_Model model = JsonConvert.DeserializeObject<InOutItemBOperation_Model>(strSafeJson);
            if (string.IsNullOrEmpty(model.ItemBName))
            {
                res.Message = "项目名称不能为空";
                return toJson(res);
            }
            InOutItemB_Model ioModel = new InOutItemB_Model();
            ioModel.ItemAID = model.ItemAID;
            ioModel.ItemBID = model.ItemBID;
            ioModel.ItemBName = model.ItemBName;
            bool isExist = InOutItem_BLL.Instance.FindInOutItemBSameItemBName(ioModel);
            if (isExist)
            {
                res.Code = "0";
                res.Message = "名称为  " + model.ItemBName + "  中项目已经存在";
                res.Data = false;
            }
            else {
                model.CreatorID = this.UserID;
                model.UpdaterID = this.UserID;
                bool rs = InOutItem_BLL.Instance.UpdateInOutItemB(model);
                res.Code = "1";
                res.Message = "修改成功";
                res.Data = rs;
            }
            return toJson(res);
        }
        /// <summary>
        /// 添加小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("AddInOutItemC")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddInOutItemC(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "添加失败";
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

            InOutItemCOperation_Model model = JsonConvert.DeserializeObject<InOutItemCOperation_Model>(strSafeJson);
            if (string.IsNullOrEmpty(model.ItemCName))
            {
                res.Message = "项目名称不能为空";
                return toJson(res);
            }
            if (model.ItemBID <= 0)
            {
                res.Message = "请选择中项目";
                return toJson(res);
            }
            InOutItemC_Model ioModel = new InOutItemC_Model();
            ioModel.ItemBID = model.ItemBID;
            ioModel.ItemCID = model.ItemCID;
            ioModel.ItemCName = model.ItemCName;
            bool isExist = InOutItem_BLL.Instance.FindInOutItemCSameItemCName(ioModel);
            if (isExist)
            {
                res.Code = "0";
                res.Message = "名称为  " + model.ItemCName + "  小项目已经存在";
                res.Data = false;
            }
            else {
                model.CreatorID = this.UserID;
                model.UpdaterID = this.UserID;
                bool rs = InOutItem_BLL.Instance.AddInOutItemC(model);
                res.Code = "1";
                res.Message = "添加成功";
                res.Data = rs;
            }
            return toJson(res);
        }
        /// <summary>
        /// 更新小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("UpdateInOutItemC")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateInOutItemC(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "修改失败";
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

            InOutItemCOperation_Model model = JsonConvert.DeserializeObject<InOutItemCOperation_Model>(strSafeJson);
            if (string.IsNullOrEmpty(model.ItemCName))
            {
                res.Message = "项目名称不能为空";
                return toJson(res);
            }
            InOutItemC_Model ioModel = new InOutItemC_Model();
            ioModel.ItemBID = model.ItemBID;
            ioModel.ItemCID = model.ItemCID;
            ioModel.ItemCName = model.ItemCName;
            bool isExist = InOutItem_BLL.Instance.FindInOutItemCSameItemCName(ioModel);
            if (isExist)
            {
                res.Code = "0";
                res.Message = "名称为  " + model.ItemCName + "  小项目已经存在";
                res.Data = false;
            }
            else {
                model.CreatorID = this.UserID;
                model.UpdaterID = this.UserID;
                bool rs = InOutItem_BLL.Instance.UpdateInOutItemC(model);
                res.Code = "1";
                res.Message = "修改成功";
                res.Data = rs;
            }
            return toJson(res);
        }
        /// <summary>
        /// 删除大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("DeleteInOutItemA")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteInOutItemA(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "删除失败";
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

            InOutItemAOperation_Model model = JsonConvert.DeserializeObject<InOutItemAOperation_Model>(strSafeJson);
            bool rs = InOutItem_BLL.Instance.DeleteInOutItemA(model.ItemAID);
            res.Code = "1";
            res.Message = "删除成功";
            res.Data = rs;
            return toJson(res);
        }
        /// <summary>
        /// 删除中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("DeleteInOutItemB")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteInOutItemB(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "删除失败";
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

            InOutItemBOperation_Model model = JsonConvert.DeserializeObject<InOutItemBOperation_Model>(strSafeJson);
            bool rs = InOutItem_BLL.Instance.DeleteInOutItemB(model.ItemBID);
            res.Code = "1";
            res.Message = "删除成功";
            res.Data = rs;
            return toJson(res);
        }
        /// <summary>
        /// 删除小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("DeleteInOutItemC")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteInOutItemC(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "删除失败";
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

            InOutItemCOperation_Model model = JsonConvert.DeserializeObject<InOutItemCOperation_Model>(strSafeJson);
            bool rs = InOutItem_BLL.Instance.DeleteInOutItemC(model.ItemCID);
            res.Code = "1";
            res.Message = "删除成功";
            res.Data = rs;
            return toJson(res);
        }
    }
}