using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class DiscountController : BaseController
    {
        public ActionResult GetDiscountList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.Flag = 0;
            utilityModel.PageIndex = 1;
            utilityModel.PageSize = 999999;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<GetDiscountListForManager_Model> list = new List<GetDiscountListForManager_Model>();
            bool issuccess = GetPostResponseNoRedirect("Level_M", "GetDiscountList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                PageResult<GetDiscountListForManager_Model> res = new PageResult<GetDiscountListForManager_Model>();
                res = JsonConvert.DeserializeObject<PageResult<GetDiscountListForManager_Model>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }

            return View(list);
        }

        public ActionResult EditDiscount()
        {
            int discountID = HS.Framework.Common.Safe.QueryString.IntSafeQ("ID", 0);
            bool isAdd = true;

            GetDiscountDetail_Model model = new GetDiscountDetail_Model();
            if (discountID > 0)
            {
                isAdd = false;
            }
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.ID = discountID;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Level_M", "GetDiscountDetail", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<GetDiscountDetail_Model> res = new ObjectResult<GetDiscountDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetDiscountDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }
            }

            ViewBag.IsAdd = isAdd;
            return View(model);
        }

        public string IsExistDiscountName(string DiscountName)
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.DiscountName = DiscountName;
            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Level_M", "IsExistDiscountName", postJson, out data);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<bool> res = new ObjectResult<bool>();
                    res = JsonConvert.DeserializeObject<ObjectResult<bool>>(data);

                    if (res.Code == "1")
                    {
                        if (res.Data)
                        {
                            return "1";
                        }
                        else
                        {
                            return "0";
                        }
                    }
                }
            }
            return "-1";
        }

        public string AddDiscount(string DiscountName, string LevelDiscount)
        {
            AddDiscount_Model operationModel = new AddDiscount_Model();
            operationModel.DiscountName = DiscountName;
            List<GetLevelInfo_Model> list = new List<GetLevelInfo_Model>();

            if (!string.IsNullOrWhiteSpace(LevelDiscount))
            {
                string[] arr = LevelDiscount.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                if (arr != null && arr.Length > 0)
                {
                    for (int i = 0; i < arr.Length; i++)
                    {
                        string tempstring = StringUtils.GetDbString(arr[i]);
                        if (string.IsNullOrWhiteSpace(tempstring))
                        {
                            return "0";
                        }

                        string[] arr2 = tempstring.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                        GetLevelInfo_Model model = new GetLevelInfo_Model();
                        if (arr2 != null && arr2.Length > 1)
                        {
                            model.LevelID = StringUtils.GetDbInt(arr2[0]);
                            model.Discount = StringUtils.GetDbDecimal(arr2[1]);
                        }
                        list.Add(model);
                    }
                }
            }

            operationModel.List = list;

            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Level_M", "AddDiscount", postJson, out data);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<int> res = new ObjectResult<int>();
                    res = JsonConvert.DeserializeObject<ObjectResult<int>>(data);

                    if (res.Code == "1")
                    {
                        return res.Data.ToString();
                    }
                }
            }
            return "0";
        }

        public string UpdateDiscount(int DiscountID, string DiscountName, string LevelDiscount)
        {
            AddDiscount_Model operationModel = new AddDiscount_Model();
            operationModel.DiscountName = DiscountName;
            operationModel.DiscountID = DiscountID;
            //List<GetLevelInfo_Model> list = new List<GetLevelInfo_Model>();

            //if (!string.IsNullOrWhiteSpace(LevelDiscount))
            //{
            //    string[] arr = LevelDiscount.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
            //    if (arr != null && arr.Length > 0)
            //    {
            //        for (int i = 0; i < arr.Length; i++)
            //        {
            //            string tempstring = StringUtils.GetDbString(arr[i]);
            //            if (string.IsNullOrWhiteSpace(tempstring))
            //            {
            //                return "0";
            //            }

            //            string[] arr2 = tempstring.Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
            //            GetLevelInfo_Model model = new GetLevelInfo_Model();
            //            if (arr2 != null && arr2.Length > 1)
            //            {
            //                model.LevelID = StringUtils.GetDbInt(arr2[0]);
            //                model.Discount = StringUtils.GetDbDecimal(arr2[1]);
            //            }
            //            list.Add(model);
            //        }
            //    }
            //}

            //operationModel.List = list;

            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Level_M", "EditDiscount", postJson, out data);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<int> res = new ObjectResult<int>();
                    res = JsonConvert.DeserializeObject<ObjectResult<int>>(data);

                    if (res.Code == "1")
                    {
                        return res.Data.ToString();
                    }
                }
            }
            return "0";
        }

        public string DeleteDiscount(int DiscountID, int Available)
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.ID = DiscountID;
            operationModel.Available = Available;

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Level_M", "DeleteDiscount", postJson, out data);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<bool> res = new ObjectResult<bool>();
                    res = JsonConvert.DeserializeObject<ObjectResult<bool>>(data);

                    if (res.Code == "1" && res.Data)
                    {
                        return "1";
                    }
                }
            }

            return "0";
        }
    }
}
