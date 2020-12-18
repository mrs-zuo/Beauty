using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
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
using System.Threading.Tasks;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Message_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetMessageForMarket")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetMessageForMarket(JObject obj)
        {
            PageResult<GetMessageList_Model> res = new PageResult<GetMessageList_Model>();
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
            if (utilityModel.AccountID <= 0)
            {
                utilityModel.AccountID = this.UserID;
            }
            utilityModel.Time = DateTime.Now.ToLocalTime();
            if (utilityModel.PageIndex <= 0)
            {
                utilityModel.PageIndex = 1;
            }

            if (utilityModel.PageSize <= 0)
            {
                utilityModel.PageSize = 9999;
            }
            int recordCount = 0;

            List<GetMessageList_Model> list = new List<GetMessageList_Model>();
            list = Message_BLL.Instance.getMessageForMarketingForManager(utilityModel.CompanyID, utilityModel.AccountID, utilityModel.Time, utilityModel.PageSize, utilityModel.PageIndex, out recordCount);

            res.Code = "1";
            res.Message = "";
            res.Data = list;
            res.RecordCount = recordCount;
            res.PageIndex = utilityModel.PageIndex;
            res.PageSize = utilityModel.PageSize;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddMarketMessage")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage AddMarketMessage(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败!";

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

            Message_Model operationModel = new Message_Model();
            operationModel = JsonConvert.DeserializeObject<Message_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.FromUserID = this.UserID;
            operationModel.SendTime = DateTime.Now.ToLocalTime();
            operationModel.GroupFlag = true;
            operationModel.MessageType = 1;

            if (operationModel.FromUserID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.listToUserID == null || operationModel.listToUserID.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            else
            {
                //string[] arrayToUserId = operationModel.ToUserIDs.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                //operationModel.listToUserID = new List<int>();
                foreach (int strUserId in operationModel.listToUserID)
                {
                    int toUserId = StringUtils.GetDbInt(strUserId);
                    if (toUserId <= 0)
                    {
                        res.Message = "不合法参数";
                        return toJson(res);
                    }
                }
            }
            if (operationModel.MessageContent == "" || operationModel.MessageContent == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<AddMessage_Model> list = new List<AddMessage_Model>();
            list = Message_BLL.Instance.addMessage(operationModel);

            if (list != null)
            {
                GetCompanyDetail_Model mCompany = Company_BLL.Instance.getCompanyDetail(operationModel.CompanyID);
                string companyAbbreviation = "";
                if (mCompany == null)
                {
                    companyAbbreviation = Common.Const.MESSAGE_GLAMOURPROMISE;
                }
                else
                {
                    companyAbbreviation = mCompany.Abbreviation;
                }

                Task.Factory.StartNew(
                    () => Message_BLL.Instance.pushMsg(operationModel.listToUserID, string.Format(Resources.sysMsg.newMsg, companyAbbreviation)));
                res.Data = true;
            }
            res.Code = "1";
            res.Message = "操作成功!";
            return toJson(res);

        }
    }
}
