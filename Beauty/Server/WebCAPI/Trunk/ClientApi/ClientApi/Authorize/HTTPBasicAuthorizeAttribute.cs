using ClientAPI.BLL;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ClientApi.Authorize
{
    public class HTTPBasicAuthorizeAttribute : System.Web.Http.AuthorizeAttribute
    {
        public override void OnAuthorization(System.Web.Http.Controllers.HttpActionContext actionContext)
        {
            if (!StringUtils.GetDbBool(System.Configuration.ConfigurationManager.AppSettings["IsAuthorize"]))
            {
                IsAuthorized(actionContext);
            }
            else
            {
                try
                {
                    var CO = StringUtils.GetDbInt(actionContext.Request.Headers.GetValues("CO").First());
                    var BR = StringUtils.GetDbInt(actionContext.Request.Headers.GetValues("BR").First());
                    var US = StringUtils.GetDbInt(actionContext.Request.Headers.GetValues("US").First());
                    var CT = StringUtils.GetDbInt(actionContext.Request.Headers.GetValues("CT").First());
                    var DT = StringUtils.GetDbInt(actionContext.Request.Headers.GetValues("DT").First());
                    var AV = StringUtils.GetDbString(actionContext.Request.Headers.GetValues("AV").First());
                    var ME = StringUtils.GetDbString(actionContext.Request.Headers.GetValues("ME").First());
                    var TI = StringUtils.GetDbDateTime(actionContext.Request.Headers.GetValues("TI").First());
                    var GU = StringUtils.GetDbString(actionContext.Request.Headers.GetValues("GU").First());

                    int RealUserType;

                    List<string> businessMethod = new List<string>() { "CARDRECHARGE", "ADDNEWORDER", "ADDTREATGROUP", "ADDPAYMENT" };
                    string actionName = actionContext.ActionDescriptor.ActionName;



                    if (!Login_BLL.Instance.CheckIdentity(GU, CO, BR, US, CT, out RealUserType))
                    {
                        // 验证参数失败
                        actionContext.Request.Headers.Add("errorMessage", "10013");
                        HandleUnauthorizedRequest(actionContext);
                    }

                    //RealUserType 1:account 2：customer
                    //CT 1:business 2:customer 3:manager 4:touch
                    if ((RealUserType == 1 && (CT == 2 || CT == 4)) || (RealUserType == 2 && (CT == 1 || CT == 3)))
                    {
                        actionContext.Request.Headers.Add("errorMessage", "10014");
                        HandleUnauthorizedRequest(actionContext);
                    }

                    if (RealUserType == 2 && businessMethod.Contains("actionName"))
                    {
                        actionContext.Request.Headers.Add("errorMessage", "10015");
                        HandleUnauthorizedRequest(actionContext);
                    }

                    if (actionContext.Request.Headers.Authorization != null)
                    {
                        #region 验证参数是否合法
                        if (string.IsNullOrWhiteSpace(ME))
                        {
                            // 没有Methord
                            actionContext.Request.Headers.Add("errorMessage", "10003");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        if (StringUtils.GetDbInt(CO) <= 0)
                        {
                            // 没有CompanyID
                            actionContext.Request.Headers.Add("errorMessage", "10004");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        if (StringUtils.GetDbInt(BR) < 0)
                        {
                            // 没有BranchID
                            actionContext.Request.Headers.Add("errorMessage", "10005");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        if (StringUtils.GetDbInt(US) <= 0)
                        {
                            // 没有UserID
                            actionContext.Request.Headers.Add("errorMessage", "10006");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        if (StringUtils.GetDbInt(CT) <= 0)
                        {
                            // 没有ClientType
                            actionContext.Request.Headers.Add("errorMessage", "10007");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        if (StringUtils.GetDbInt(DT) <= 0)
                        {
                            // 没有UserType
                            actionContext.Request.Headers.Add("errorMessage", "10012");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        if (string.IsNullOrWhiteSpace(StringUtils.GetDbString(AV)))
                        {
                            // 没有APPVersion
                            actionContext.Request.Headers.Add("errorMessage", "10008");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        if (string.IsNullOrWhiteSpace(StringUtils.GetDbString(GU)))
                        {
                            // 没有GUID
                            actionContext.Request.Headers.Add("errorMessage", "10009");
                            HandleUnauthorizedRequest(actionContext);
                        }

                        // WEB端登陆不需要版本验证
                        if ((DT != 3 && CT != 3) && (DT != 4 && CT != 4))
                        {
                            VersionCheck_Model CurrentVersion = Version_BLL.Instance.getServerVersion(DT, CT, AV);
                            if (AV.CompareTo(CurrentVersion.MustUpgradeVersion) < 0)
                            {
                                // 版本过低
                                actionContext.Request.Headers.Add("errorMessage", "10010");
                                HandleUnauthorizedRequest(actionContext);
                            }
                        }
                        #endregion

                        string pars = actionContext.ActionDescriptor.ActionName + actionContext.Request.Content.ReadAsStringAsync().Result + CO + GU + "HS";
                        string token = actionContext.Request.Headers.Authorization.Scheme;
                        string tokenNew = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pars.ToUpper(), "MD5");

                        if (token.ToLower().Equals(tokenNew.ToLower()))
                        {
                            IsAuthorized(actionContext);
                        }
                        else
                        {
                            // 验证参数失败
                            actionContext.Request.Headers.Add("errorMessage", "10002");
                            HandleUnauthorizedRequest(actionContext);
                        }
                    }
                    else
                    {
                        // 没有验证参数
                        actionContext.Request.Headers.Add("errorMessage", "10001");
                        HandleUnauthorizedRequest(actionContext);
                    }
                }
                catch (Exception ex)
                {
                    if (ex is System.Web.Http.HttpResponseException)
                    {
                        throw;
                    }
                    else
                    {
                        actionContext.Request.Headers.Add("errorMessage", "10011");
                        HandleUnauthorizedRequest(actionContext);
                    }
                }
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
