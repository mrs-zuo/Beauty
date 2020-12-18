using HS.Framework.Common;
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

namespace WebAPI.Controllers
{
    public class AccountController : BaseController
    {
        [HttpPost]
        [ActionName("GetAccountListByCompanyID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountListByCompanyID(JObject obj)
        {            
            PageResult<GetAccountList_Model> res = new PageResult<GetAccountList_Model>();
            res.Code = "0";
            res.Data = null;
            try
            {
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

                if (this.CompanyID <= 0)
                {
                    res.Message = "不合法参数";
                    return toJson(res);
                }

                if (operationModel.ImageHeight <= 0)
                {
                    operationModel.ImageHeight = 160;
                }

                if (operationModel.ImageWidth <= 0)
                {
                    operationModel.ImageWidth = 160;
                }

                if (operationModel.PageIndex <= 0)
                {
                    operationModel.PageIndex = 1;
                }

                if (operationModel.PageSize <= 0)
                {
                    operationModel.PageSize = 10;
                }

                int recordCount = 0;
                List<GetAccountList_Model> list = Account_BLL.Instance.getAccountList(this.CompanyID, operationModel.ImageWidth, operationModel.ImageHeight, operationModel.PageIndex, operationModel.PageSize, operationModel.Type, out recordCount);

                if (operationModel.Type == 0) {
                    res.Data = list;
                }
                else if (operationModel.Type == 1)
                {
                    List<int> RandomList = new List<int>();
                    int seed = Guid.NewGuid().GetHashCode();
                    Random random = new Random(seed);

                    while (RandomList.Count < 4)
                    {
                        int intRandom = random.Next(list.Count);
                        if (!RandomList.Contains(intRandom))
                        {
                            RandomList.Add(intRandom);
                        }
                    }

                    List<GetAccountList_Model> IndexList = new List<GetAccountList_Model>();
                    foreach (int item in RandomList)
                    {
                        IndexList.Add(list[item]);
                    }

                    res.Data = IndexList;
                }

                res.Code = "1";
                res.PageSize = operationModel.PageSize;
                res.PageIndex = operationModel.PageIndex;
                res.RecordCount = recordCount;
                return toJson(res);
            }
            catch (Exception ex)
            {
                res.Code = "-1";
                res.PageSize = 0;
                res.PageIndex = 0;
                res.Data = null;
                LogUtil.Log(ex);
                return toJson(res);
            }

        }

        [HttpPost]
        [ActionName("GeAccountDetail")]
        public HttpResponseMessage GeAccountDetail(JObject obj)
        {
            ObjectResult<GetAccountList_Model> res = new ObjectResult<GetAccountList_Model>();
            res.Code = "0";
            res.Data = null;
            try
            {
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

                if (operationModel.CompanyID <= 0 )
                {
                    res.Message = "不合法参数";
                    return toJson(res);
                }

                if (operationModel.ImageHeight <= 0)
                {
                    operationModel.ImageHeight = 200;
                }

                if (operationModel.ImageWidth <= 0)
                {
                    operationModel.ImageWidth = 290;
                }

                GetAccountList_Model model = new GetAccountList_Model();
                model = Account_BLL.Instance.getAccountDetail(operationModel.CompanyID, operationModel.AccountID, operationModel.ImageHeight, operationModel.ImageWidth);

                if (model != null)
                {
                    res.Code = "1";
                    res.Data = model;
                }
                return toJson(res);
            }
            catch (Exception ex)
            {
                res.Code = "-1";
                res.Data = null;
                LogUtil.Log(ex);
                return toJson(res);
            }
        }
    }
}
