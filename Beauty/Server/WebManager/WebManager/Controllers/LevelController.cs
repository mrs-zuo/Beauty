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
    public class LevelController : BaseController
    {
        public ActionResult GetLevelList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.Flag = 0;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<GetLevelList_Model> list = new List<GetLevelList_Model>();
            bool issuccess = GetPostResponseNoRedirect("Level_M", "GetLevelList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<GetLevelList_Model>> res = new ObjectResult<List<GetLevelList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<GetLevelList_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }

            return View(list);
        }

        public ActionResult EditLevel()
        {
            int levelID = HS.Framework.Common.Safe.QueryString.IntSafeQ("ID", 0);
            bool isAdd = true;

            GetLevelDetail_Model model = new GetLevelDetail_Model();
            if (levelID > 0)
            {
                isAdd = false;
            }
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.ID = levelID;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Level_M", "GetLevelDetail", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<GetLevelDetail_Model> res = new ObjectResult<GetLevelDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetLevelDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }
            }

            ViewBag.IsAdd = isAdd;
            return View(model);
        }

        public string AddLevel(string LevelName, decimal Threshold, string LevelDiscount)
        {
            AddLevel_Model operationModel = new AddLevel_Model();
            operationModel.LevelName = LevelName;
            operationModel.Threshold = Threshold;
            List<GetDiscountInfo_Model> list = new List<GetDiscountInfo_Model>();

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
                        GetDiscountInfo_Model model = new GetDiscountInfo_Model();
                        if (arr2 != null && arr2.Length > 1)
                        {
                            model.DiscountID = StringUtils.GetDbInt(arr2[0]);
                            model.Discount = StringUtils.GetDbDecimal(arr2[1]);
                        }
                        list.Add(model);
                    }
                }
            }

            operationModel.List = list;

            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Level_M", "AddLevel", postJson, out data);

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

        public string UpdateLevel(int LevelID, decimal Threshold, string LevelName, string LevelDiscount)
        {
            AddLevel_Model operationModel = new AddLevel_Model();
            operationModel.LevelName = LevelName;
            operationModel.LevelID = LevelID;
            operationModel.Threshold = Threshold;
            List<GetDiscountInfo_Model> list = new List<GetDiscountInfo_Model>();

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
                        GetDiscountInfo_Model model = new GetDiscountInfo_Model();
                        if (arr2 != null && arr2.Length > 1)
                        {
                            model.DiscountID = StringUtils.GetDbInt(arr2[0]);
                            model.Discount = StringUtils.GetDbDecimal(arr2[1]);
                        }
                        list.Add(model);
                    }
                }
            }

            operationModel.List = list;

            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Level_M", "EditLevel", postJson, out data);

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

        public string DeleteLevel(int LevelID, int Available)
        {
            AddLevel_Model operationModel = new AddLevel_Model();
            operationModel.LevelID = LevelID;
            operationModel.Available = Available;

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Level_M", "DeleteLevel", postJson, out data);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<bool> res = new ObjectResult<bool>();
                    res = JsonConvert.DeserializeObject<ObjectResult<bool>>(data);

                    if (res.Code == "1")
                    {
                        return "1";
                    }
                }
            }

            return "0";
        }

        public string ChangDefaultLevel(int LevelID)
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.ID = LevelID;
            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Level_M", "ChangDefaultLevel", postJson, out data);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<bool> res = new ObjectResult<bool>();
                    res = JsonConvert.DeserializeObject<ObjectResult<bool>>(data);

                    if (res.Code == "1")
                    {
                        return "1";
                    }
                }
            }

            return "0";
        }
    }
}
