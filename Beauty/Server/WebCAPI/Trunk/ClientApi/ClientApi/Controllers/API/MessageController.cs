using ClientApi.Authorize;
using ClientAPI.BLL;
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

namespace ClientApi.Controllers.API
{
    public class MessageController : BaseController
    {

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"ImageHeight":100,"ImageWidth":102}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetContactListForCustomer")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetContactListForCustomer(JObject obj)
        {
            ObjectResult<List<GetContactList_Model>> res = new ObjectResult<List<GetContactList_Model>>();
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

            MessageOperation_Model operationModel = new MessageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<MessageOperation_Model>(strSafeJson);

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 80;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 80;
            }

            List<GetContactList_Model> list = new List<GetContactList_Model>();
            list = Message_BLL.Instance.getContactListForCustomer(this.CompanyID, this.UserID, operationModel.ImageWidth, operationModel.ImageHeight);


            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"HereUserID":2282,"ThereUserID":27,"NewThanMessageID":0}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetNewMessage")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetNewMessage(JObject obj)
        {
            ObjectResult<List<GetMessageList_Model>> res = new ObjectResult<List<GetMessageList_Model>>();
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

            MessageOperation_Model operationModel = new MessageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<MessageOperation_Model>(strSafeJson);

            if (operationModel.HereUserID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ThereUserID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<GetMessageList_Model> list = new List<GetMessageList_Model>();
            list = Message_BLL.Instance.getRealTimeMsg(operationModel.ThereUserID, operationModel.HereUserID, operationModel.MessageID);



            if (list != null)
            {
                bool result = Message_BLL.Instance.receiveMsg(operationModel.ThereUserID, operationModel.HereUserID);

            }
            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"HereUserID":27,"ThereUserID":2282,"MessageID":0}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetHistoryMessage")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetHistoryMessage(JObject obj)
        {
            ObjectResult<List<GetMessageList_Model>> res = new ObjectResult<List<GetMessageList_Model>>();
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

            MessageOperation_Model operationModel = new MessageOperation_Model();
            operationModel = JsonConvert.DeserializeObject<MessageOperation_Model>(strSafeJson);

            if (operationModel.ThereUserID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.HereUserID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<GetMessageList_Model> list = new List<GetMessageList_Model>();
            if (operationModel.MessageID == 0)
            {
                List<int> listNoReceive = Message_BLL.Instance.getMsgWithNoReceive(operationModel.ThereUserID, operationModel.HereUserID);
                if (listNoReceive.Count == 0)
                {
                    list = Message_BLL.Instance.getMsgByLastTen(operationModel.ThereUserID, operationModel.HereUserID);
                }
                else
                {
                    list = Message_BLL.Instance.getMsgByLastId(operationModel.ThereUserID, operationModel.HereUserID, listNoReceive[0]);
                    if (list.Count >= 10)
                    {
                        bool result = Message_BLL.Instance.receiveMsg(operationModel.ThereUserID, operationModel.HereUserID);
                        if (!result)
                        {
                            res.Code = "1";
                            res.Data = null;
                            return toJson(res);
                        }
                    }
                    else
                    {
                        list = Message_BLL.Instance.getMsgByLastTen(operationModel.ThereUserID, operationModel.HereUserID);
                        if (list.Count > 0)
                        {
                            bool result = Message_BLL.Instance.receiveMsg(operationModel.ThereUserID, operationModel.HereUserID);
                            if (!result)
                            {
                                res.Code = "1";
                                res.Data = null;
                                return toJson(res);
                            }
                        }
                    }
                }
            }
            else
            {
                list = Message_BLL.Instance.getHistoryMsg(operationModel.ThereUserID, operationModel.HereUserID, operationModel.MessageID);
            }

            if (list != null)
            {
                foreach (GetMessageList_Model item in list)
                {
                    if (item.FromUserID == operationModel.ThereUserID)
                    {
                        item.SendOrReceiveFlag = 0;//表示该信息由FromUserID接受
                    }
                    else if (item.FromUserID == operationModel.HereUserID)
                    {
                        item.SendOrReceiveFlag = 1;//表示该信息由FromUserID发送d
                    }
                }
            }
            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"FromUserID":"27","ToUserIDs":"2282,33","MessageContent":"test001","MessageType":0,"GroupFlag":0}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("AddMessage")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage AddMessage(JObject obj)
        {
            ObjectResult<List<AddMessage_Model>> res = new ObjectResult<List<AddMessage_Model>>();
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

            Message_Model operationModel = new Message_Model();
            operationModel = JsonConvert.DeserializeObject<Message_Model>(strSafeJson);

            if (operationModel.MessageType < 0 || operationModel.MessageType > 1)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.FromUserID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ToUserIDs == "" || operationModel.ToUserIDs == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            else
            {
                string[] arrayToUserId = operationModel.ToUserIDs.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                operationModel.listToUserID = new List<int>();
                foreach (string strUserId in arrayToUserId)
                {
                    int toUserId = StringUtils.GetDbInt(strUserId);
                    if (toUserId <= 0)
                    {
                        res.Message = "不合法参数";
                        return toJson(res);
                    }
                    else
                    {
                        operationModel.listToUserID.Add(toUserId);
                    }
                }
            }
            if (operationModel.MessageContent == "" || operationModel.MessageContent == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.SendTime = DateTime.Now.ToLocalTime();

            List<AddMessage_Model> list = new List<AddMessage_Model>();

            list = Message_BLL.Instance.addMessage(operationModel);

            if (list != null)
            {
                GetCompanyDetail_Model mCompany = Company_BLL.Instance.getCompanyDetail(operationModel.CompanyID);
                string companyAbbreviation = "";
                if (mCompany == null)
                {
                    companyAbbreviation = WebAPI.Common.Const.MESSAGE_GLAMOURPROMISE;
                }
                else
                {
                    companyAbbreviation = mCompany.Abbreviation;
                }

                Task.Factory.StartNew(
                    () => Message_BLL.Instance.pushMsg(operationModel.listToUserID, string.Format("您有一条来自{0}的新消息！请注意查收！", companyAbbreviation)));

            }
            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }



    }
}
