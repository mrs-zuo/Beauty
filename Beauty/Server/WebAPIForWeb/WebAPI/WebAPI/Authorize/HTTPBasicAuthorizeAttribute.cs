using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HS.Framework.Common.Caching;
using WebAPI.BLL;
using HS.Framework.Common.Util;

namespace WebAPI.Authorize
{
    public class HTTPBasicAuthorizeAttribute : System.Web.Http.AuthorizeAttribute
    {
        public override void OnAuthorization(System.Web.Http.Controllers.HttpActionContext actionContext)
        {
            var CO = actionContext.Request.Headers.GetValues("CO").First();
            var BR = actionContext.Request.Headers.GetValues("BR").First();
            var US = actionContext.Request.Headers.GetValues("US").First();
            var CT = actionContext.Request.Headers.GetValues("CT").First();
            var AV = actionContext.Request.Headers.GetValues("AV").First();
            var ME = actionContext.Request.Headers.GetValues("ME").First();
            var TI = actionContext.Request.Headers.GetValues("TI").First();
            var GU = actionContext.Request.Headers.GetValues("GU").First();
            int deviceType, clientType;
            switch (HS.Framework.Common.Util.StringUtils.GetDbInt(CT, 0))
            {
                case 1:
                    deviceType = 0; clientType = 0; break;
                case 2:
                    deviceType = 0; clientType = 1; break;
                case 3:
                    deviceType = 1; clientType = 0; break;
                case 4:
                    deviceType = 1; clientType = 1; break;
                default:
                    deviceType = int.MaxValue; clientType = int.MaxValue;
                    break;
            }

            if (actionContext.Request.Headers.Authorization != null)
            {
                #region 验证参数是否合法
                if (string.IsNullOrWhiteSpace(ME))
                {
                    // 没有Methord
                    actionContext.Request.Headers.Add("errorMessage", "10003:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }

                if (StringUtils.GetDbInt(CO) <= 0)
                {
                    // 没有CompanyID
                    actionContext.Request.Headers.Add("errorMessage", "10004:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }

                if (StringUtils.GetDbInt(BR) <= 0)
                {
                    // 没有BranchID
                    actionContext.Request.Headers.Add("errorMessage", "10005:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }

                if (StringUtils.GetDbInt(US) <= 0)
                {
                    // 没有UserID
                    actionContext.Request.Headers.Add("errorMessage", "10006:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }

                if (StringUtils.GetDbInt(CT) <= 0)
                {
                    // 没有ClientType
                    actionContext.Request.Headers.Add("errorMessage", "10007:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }

                if (string.IsNullOrWhiteSpace(StringUtils.GetDbString(AV)))
                {
                    // 没有APPVersion
                    actionContext.Request.Headers.Add("errorMessage", "10008:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }

                if (string.IsNullOrWhiteSpace(StringUtils.GetDbString(GU)))
                {
                    // 没有GUID
                    actionContext.Request.Headers.Add("errorMessage", "10009:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }


                string MinUpGreadVersion = Version_BLL.Instance.getServerVersion(deviceType, clientType, (string)AV);
                if (AV.CompareTo(MinUpGreadVersion) < 0)
                {
                    // 版本过低
                    actionContext.Request.Headers.Add("errorMessage", "10010:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }
                #endregion
               
                string pars = actionContext.ActionDescriptor.ActionName + actionContext.Request.Content.ReadAsStringAsync().Result + "HS";
                string token = actionContext.Request.Headers.Authorization.Scheme;
                string tokenNew = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pars, "MD5");

                if (token.ToLower().Equals(tokenNew.ToLower()))
                {
                    bool jjjj = IsAuthorized(actionContext);
                }
                else
                {
                    // 验证参数失败
                    actionContext.Request.Headers.Add("errorMessage", "10002:非法请求!");
                    HandleUnauthorizedRequest(actionContext);
                }
            }
            else
            {
                // 没有验证参数
                actionContext.Request.Headers.Add("errorMessage", "10001:非法请求!");
                HandleUnauthorizedRequest(actionContext);
            }

        }

        protected override void HandleUnauthorizedRequest(System.Web.Http.Controllers.HttpActionContext actionContext)
        {
            var challengeMessage = new System.Net.Http.HttpResponseMessage(System.Net.HttpStatusCode.Unauthorized);         
            challengeMessage.Headers.Add("errorMessage", actionContext.Request.Headers.GetValues("errorMessage").First());
            throw new System.Web.Http.HttpResponseException(challengeMessage);
        }
    }
}
