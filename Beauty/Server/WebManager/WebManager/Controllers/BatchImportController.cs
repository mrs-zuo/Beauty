using HS.Framework.Common.Util;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;
using Aspose.Cells;
using System.Data;
using Model.Operation_Model;
using HS.Framework.Common.Entity;
using WebAPI.Common;
using Model.Table_Model;
using System.Globalization;

namespace WebManager.Controllers
{
    public class BatchImportController : BaseController
    {
        //
        // GET: /BatchImport/

        public ActionResult BatchImport()
        {
            int Type = StringUtils.GetDbInt(this.Request.QueryString["Type"]);
            ViewBag.Type = Type;
            return View(Type);
        }
        public ActionResult BatchCommodityImport()
        {
            int Type = StringUtils.GetDbInt(this.Request.QueryString["Type"]);
            int BranchID = StringUtils.GetDbInt(this.Request.QueryString["BranchID"]);
            ViewBag.Type = Type;
            ViewBag.BranchID = BranchID; 
            return View(Type);
        }
        public ActionResult BatchView()
        {
            string fileName = this.Request.QueryString["fileName"];
            int Type = StringUtils.GetDbInt(this.Request.QueryString["Type"]);
            string filePath = Const.uploadServer + "/" + Const.strImage + "temp/batchImport/" + fileName;
            string errorRowNumber = this.Request.QueryString["errorRowNumber"];
            ViewBag.fileName = fileName;
            ViewBag.errorRowNumber = errorRowNumber;
            if (System.IO.File.Exists(filePath))
            {
                Workbook workbook = new Workbook(filePath);
                Worksheet worksheet = workbook.Worksheets[0];
                Cells cells = worksheet.Cells;
                DataTable dt = new DataTable();

                dt = worksheet.Cells.ExportDataTable(0, 0, worksheet.Cells.MaxRow + 1, worksheet.Cells.MaxColumn + 1);

                if (dt.Rows.Count > 0)
                {
                    ViewBag.ProductList = dt;
                }
            }
            return View(Type);
        }

        public ActionResult BatchCommodityView()
        {
            string fileName = this.Request.QueryString["fileName"];
            int Type = StringUtils.GetDbInt(this.Request.QueryString["Type"]);
            int BranchID = StringUtils.GetDbInt(this.Request.QueryString["BranchID"]);
            string filePath = Const.uploadServer + "/" + Const.strImage + "temp/batchImport/" + fileName;
            //string filePath = "D:/temp/batchImport/" + fileName;
            string errorRowNumber = this.Request.QueryString["errorRowNumber"];
            ViewBag.fileName = fileName;
            ViewBag.errorRowNumber = errorRowNumber;
            ViewBag.BranchID = BranchID;
            if (System.IO.File.Exists(filePath))
            {
                Workbook workbook = new Workbook(filePath);
                Worksheet worksheet = workbook.Worksheets[0];
                Cells cells = worksheet.Cells;
                DataTable dt = new DataTable();

                dt = worksheet.Cells.ExportDataTable(0, 0, worksheet.Cells.MaxRow + 1, worksheet.Cells.MaxColumn + 1);
                string aa = "";
                if (dt.Rows.Count > 0)
                {
                    for (int i=0;i<dt.Rows.Count;i++) {
                        aa = dt.Rows[i][0].ToString().Trim();
                        if (String.IsNullOrWhiteSpace(dt.Rows[i][0].ToString().Trim()) || String.IsNullOrEmpty(dt.Rows[i][0].ToString().Trim())) {
                            dt.Rows.RemoveAt(i);
                        }
                    }
                    ViewBag.ProductList = dt;
                }
            }
            return View(Type);
        }
        public ActionResult Import(UtilityOperation_Model model)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "上传失败";
            res.Data = null;

            UtilityOperation_Model utimodel = new UtilityOperation_Model();
            List<Commodity_Model> commodityList = new List<Commodity_Model>();
            List<Service_Model> serviceList = new List<Service_Model>();
            utimodel.Type = model.Type;
            string param = "";
            string data = "";

            try
            {
                int addType = model.Type;

                HttpFileCollection hfc = System.Web.HttpContext.Current.Request.Files;
                string bx = "";
                if (hfc.Count > 0)
                {
                    if (hfc[0].ContentLength >= 4194304)
                    {
                        res.Code = "0";
                        res.Message = "上传文件过大!";
                        return Content(JsonConvert.SerializeObject(res));
                    }
                    BinaryReader r = new BinaryReader(hfc[0].InputStream);
                    byte buffer = r.ReadByte();
                    bx = buffer.ToString();
                    buffer = r.ReadByte();
                    bx += buffer.ToString();

                    Workbook workbook = new Workbook(hfc[0].InputStream);

                    Worksheet worksheet = workbook.Worksheets[0];
                    Cells cells = worksheet.Cells;

                    // 获取第二行开始的数据
                    DataTable dt = worksheet.Cells.ExportDataTable(0, 0, worksheet.Cells.MaxDataRow + 1, worksheet.Cells.MaxDataColumn + 1);

                    if (dt == null && dt.Rows.Count < 1)
                    {
                        // 数据为空
                        res.Code = "-1";
                        res.Message = "文件内容为空";
                        return Content(JsonConvert.SerializeObject(res));
                    }
                    else
                    {
                        // 列名赋值 为了以后根据使用列名操作
                        for (int i = 0; i < dt.Columns.Count; i++)
                        {
                            dt.Columns[i].ColumnName = dt.Rows[0][i].ToString();
                        }
                        DataTable resDt = new DataTable();
                        if (addType == 0)
                        {
                            resDt = dtNormalizing(dt, Const.EXPORT_SERVICENAMEEXCHANGE);

                            //为判断重复，取得当前已登录的服务
                            UtilityOperation_Model tmpmodel = new UtilityOperation_Model();
                            string tmpparam = Newtonsoft.Json.JsonConvert.SerializeObject(tmpmodel);
                            string tmpdata = string.Empty;
                            bool issuccess = this.GetPostResponseNoRedirect("Commission_M", "getServiceList", tmpparam, out tmpdata, false);
                            serviceList = JsonConvert.DeserializeObject<ObjectResult<List<Service_Model>>>(tmpdata).Data;
                            //for (int count = 0; count < serviceList.Count; count++)
                            //{
                            //    WebAPI.Common.WriteLOG.WriteLog(serviceList[count].ID.ToString() + " " + serviceList[count].ServiceName);
                            //}
                        }
                        else
                        {
                            resDt = dtNormalizing(dt, Const.EXPORT_COMMODITYNAMEEXCHANGE);

                            //为判断重复，取得当前已登录的商品
                            UtilityOperation_Model tmpmodel = new UtilityOperation_Model();
                            string tmpparam = Newtonsoft.Json.JsonConvert.SerializeObject(tmpmodel);
                            string tmpdata = string.Empty;
                            bool issuccess = this.GetPostResponseNoRedirect("Commission_M", "getCommodityList", tmpparam, out tmpdata, false);
                            commodityList = JsonConvert.DeserializeObject<ObjectResult<List<Commodity_Model>>>(tmpdata).Data;
                            //for (int count = 0; count < commodityList.Count; count++)
                            //{
                            //    WebAPI.Common.WriteLOG.WriteLog(commodityList[count].ID.ToString() + " " + commodityList[count].CommodityName);
                            //}

                        }
                        List<int> categoryIDList = new List<int>();
                        List<long> subServiceCodeList = new List<long>();
                        List<int> discountIDList = new List<int>();

                        for (int i = 1; i < dt.Rows.Count; i++)
                        {
                            if (String.IsNullOrWhiteSpace(resDt.Rows[i]["CategoryID"].ToString()))
                            {
                                res.Code = "-3";
                                res.Message = "\"第" + i.ToString() + "行分类ID为空!\"";
                                return Content(JsonConvert.SerializeObject(res));
                            }
                            else if (resDt.Rows[i]["CategoryID"].ToString() != "-1")
                            {
                                // 插入数组
                                categoryIDList.Add(StringUtils.GetDbInt(resDt.Rows[i]["CategoryID"]));
                            }


                            if (!String.IsNullOrWhiteSpace(resDt.Rows[i]["DiscountID"].ToString().Trim()))
                            {
                                // 插入数组
                                discountIDList.Add(StringUtils.GetDbInt(resDt.Rows[i]["DiscountID"]));
                            }

                            if (addType == 0)
                            {
                                if (!String.IsNullOrWhiteSpace(resDt.Rows[i]["SubServiceCodes"].ToString()))
                                {
                                    // 插入数组
                                    string[] strSubServiceCodes = (resDt.Rows[i]["SubServiceCodes"].ToString() + "|").Split('|');

                                    for (int j = 0; j < strSubServiceCodes.Length; j++)
                                    {
                                        if (!String.IsNullOrWhiteSpace(strSubServiceCodes[j]))
                                        {
                                            subServiceCodeList.Add(StringUtils.GetDbLong(strSubServiceCodes[j]));
                                        }

                                    }
                                }

                                subServiceCodeList = subServiceCodeList.Distinct().ToList<long>();

                                #region 在数据库中查询类别ID,加入字典
                                foreach (var item in subServiceCodeList)
                                {
                                    if (item > 0)
                                    {
                                        utimodel.SubServiceCode = item;
                                        param = JsonConvert.SerializeObject(utimodel);
                                        bool result = this.GetPostResponseNoRedirect("Service_M", "exsitSubserviceCode", param, out data);

                                        if (!result || !JsonConvert.DeserializeObject<ObjectResult<bool>>(data).Data)
                                        {
                                            res.Code = "-3";
                                            res.Message = "\"子服务编号 " + item + " 不存在,请检查\"";

                                            return Content(JsonConvert.SerializeObject(res));
                                        }
                                    }
                                }
                                #endregion
                            }

                        }
                        // 获取分类去除重复项
                        discountIDList = discountIDList.Distinct().ToList<int>();


                        if (categoryIDList == null || categoryIDList.Count < 1)
                        {
                            res.Code = "-2";
                            res.Message = "所属分类编号未填写，请检查";
                            return Content(JsonConvert.SerializeObject(res));
                        }
                        else
                        {
                            #region 在数据库中查询类别ID,加入字典
                            foreach (var item in categoryIDList)
                            {
                                if (item != -1)
                                {
                                    utimodel.CategoryID = item;
                                    param = JsonConvert.SerializeObject(utimodel);
                                    bool result = this.GetPostResponseNoRedirect("Category_M", "existCategoryId", param, out data);

                                    if (!result || !JsonConvert.DeserializeObject<ObjectResult<bool>>(data).Data)
                                    {
                                        res.Code = "-3";
                                        res.Message = "\"分类编号 " + item + " 不存在,请检查\"";
                                        return Content(JsonConvert.SerializeObject(res));
                                    }
                                }
                            }
                            #endregion

                            #region 在数据库中查询类别ID,加入字典
                            foreach (var item in discountIDList)
                            {
                                if (item > 0)
                                {
                                    utimodel.DiscountID = item;
                                    param = JsonConvert.SerializeObject(utimodel);
                                    bool result = this.GetPostResponseNoRedirect("Level_M", "isExistDiscountID", param, out data);

                                    if (!result || !JsonConvert.DeserializeObject<ObjectResult<bool>>(data).Data)
                                    {
                                        res.Code = "-3";
                                        res.Message = "\"折扣编号 " + item + " 不存在,请检查\"";
                                        return Content(JsonConvert.SerializeObject(res));
                                    }
                                }
                            }
                            #endregion

                            bool isPass = true;
                            string errorRowNumber = "|";
                            resDt.Columns.Add("IsPass");
                            resDt.Rows[0]["IsPass"] = 1;

                            if (addType == 0)
                            {
                                for (int i = 1; i < resDt.Rows.Count; i++)
                                {
                                    #region SERVICE数据校验
                                    string ServiceName = resDt.Rows[i]["ServiceName"].ToString();
                                    if (string.IsNullOrWhiteSpace(ServiceName) || ServiceName.Length > 30)
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        string ServiceID = resDt.Rows[i]["ServiceID"].ToString();
                                        int found = 0;
                                        for (int count = 0; count < serviceList.Count; count++)
                                        {
                                            if (ServiceName == serviceList[count].ServiceName &&
                                               (ServiceID == "" || ServiceID != serviceList[count].ID.ToString()))
                                            {
                                                errorRowNumber += "W" + i.ToString() + "|";
                                                found = 1;
                                                break;
                                            }
                                        }
                                        if (found == 0 && ServiceID == "")
                                        {
                                            Service_Model sm = new Service_Model();
                                            sm.ID = 0;
                                            sm.ServiceName = ServiceName;
                                            serviceList.Add(sm);
                                        }
                                    }

                                    string UnitPrice = resDt.Rows[i]["UnitPrice"].ToString();
                                    if (string.IsNullOrWhiteSpace(UnitPrice) || StringUtils.GetDbDecimal(UnitPrice, -1) < 0)
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    
                                    string MarketingPolicy = resDt.Rows[i]["MarketingPolicy"].ToString().Trim();
                                    if (string.IsNullOrWhiteSpace(MarketingPolicy))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (MarketingPolicy != "无优惠" && MarketingPolicy != "按等级打折" && MarketingPolicy != "按促销价")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }
                                    
                                    string PromotionPrice = resDt.Rows[i]["PromotionPrice"].ToString().Trim();
                                    if (MarketingPolicy == "按促销价")
                                    {
                                        if (string.IsNullOrWhiteSpace(PromotionPrice) || StringUtils.GetDbDecimal(PromotionPrice) < 0)
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string Describe = resDt.Rows[i]["Describe"].ToString();
                                    if (Encoding.Default.GetByteCount(Describe) > 1000)
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }

                                    string strCourseFrequency = resDt.Rows[i]["CourseFrequency"].ToString();
                                    if (!string.IsNullOrWhiteSpace(strCourseFrequency))
                                    {
                                        int CourseFrequency = StringUtils.GetDbInt(strCourseFrequency, 0);
                                        if (CourseFrequency < 0 || CourseFrequency > 255)
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    int SpendTime = StringUtils.GetDbInt(resDt.Rows[i]["SpendTime"].ToString(), 0);
                                    {
                                        if (SpendTime < 0 || SpendTime % 5 != 0)
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string strVisitTime = resDt.Rows[i]["VisitTime"].ToString();
                                    if (!string.IsNullOrWhiteSpace(strVisitTime))
                                    {
                                        int VisitTime = StringUtils.GetDbInt(resDt.Rows[i]["VisitTime"].ToString(), 0);
                                        if (VisitTime > 255 || VisitTime < 0)
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string Available = resDt.Rows[i]["Available"].ToString();
                                    if (string.IsNullOrWhiteSpace(Available))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (Available != "是" && Available != "否")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string VisibleForCustomer = resDt.Rows[i]["VisibleForCustomer"].ToString();
                                    if (string.IsNullOrWhiteSpace(VisibleForCustomer))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (VisibleForCustomer != "是" && VisibleForCustomer != "否")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string RelativePath = resDt.Rows[i]["RelativePath"].ToString();
                                    if (!string.IsNullOrWhiteSpace(RelativePath))
                                    {
                                        string[] strContent = RelativePath.Trim().Split('|');
                                        for (int j = 0; j < strContent.Length; j++)
                                        {
                                            string[] strImageInfo = strContent[j].Split(',');
                                            if (strImageInfo[0] != "" && (strImageInfo[1] != "0" && strImageInfo[1] != "1"))
                                            {
                                                resDt.Rows[i]["IsPass"] = 0;
                                                isPass = false;
                                                errorRowNumber += i + "|";
                                                continue;
                                            }
                                        }
                                    }
                                    string strExpirationDate = resDt.Rows[i]["ExpirationDate"].ToString();
                                    if (!string.IsNullOrWhiteSpace(strExpirationDate))
                                    {
                                        int ExpirationDate = StringUtils.GetDbInt(strExpirationDate, 0);
                                        if (ExpirationDate < 0 || ExpirationDate > 32767)
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }



                                    string IsConfirmed = resDt.Rows[i]["IsConfirmed"].ToString();
                                    if (string.IsNullOrWhiteSpace(IsConfirmed))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (IsConfirmed != "不再需要确认" && IsConfirmed != "需要客户端确认" && IsConfirmed != "需要顾客签字确认")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string AutoConfirm = resDt.Rows[i]["AutoConfirm"].ToString();
                                    if (string.IsNullOrWhiteSpace(AutoConfirm) || (AutoConfirm != "是" && AutoConfirm != "否"))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }

                                    string strAutoConfirmDays = resDt.Rows[i]["AutoConfirmDays"].ToString();
                                    if (AutoConfirm == "是")
                                    {
                                        if (string.IsNullOrWhiteSpace(strAutoConfirmDays))
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                        else
                                        {
                                            int AutoConfirmDays = StringUtils.GetDbInt(strAutoConfirmDays, 0);
                                            if (AutoConfirmDays < 1 || AutoConfirmDays > 999)
                                            {
                                                resDt.Rows[i]["IsPass"] = 0;
                                                isPass = false;
                                                errorRowNumber += i + "|";
                                                continue;
                                            }
                                        }
                                    }
                                    #endregion
                                }
                            }
                            else
                            {
                                #region Commodity数据校验
                                for (int i = 1; i < dt.Rows.Count; i++)
                                {
                                    string CommodityName = resDt.Rows[i]["CommodityName"].ToString();
                                    if (string.IsNullOrWhiteSpace(CommodityName) || CommodityName.Length > 30)
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        string CommodityID = resDt.Rows[i]["CommodityID"].ToString();
                                        int found = 0;
                                        for (int count = 0; count < commodityList.Count; count++)
                                        {
                                            if (CommodityName == commodityList[count].CommodityName &&
                                               (CommodityID == "" || CommodityID != commodityList[count].ID.ToString()))
                                            {
                                                errorRowNumber += "W" + i.ToString() + "|";
                                                found = 1;
                                                break;
                                            }
                                        }
                                        if (found == 0 && CommodityID == "")
                                        {
                                            Commodity_Model cm = new Commodity_Model();
                                            cm.ID = 0;
                                            cm.CommodityName = CommodityName;
                                            commodityList.Add(cm);
                                        }
                                    }

                                    string Specification = resDt.Rows[i]["Specification"].ToString();
                                    if (Specification.Length > 20)
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }

                                    string UnitPrice = resDt.Rows[i]["UnitPrice"].ToString();
                                    if (string.IsNullOrWhiteSpace(UnitPrice) || StringUtils.GetDbDecimal(UnitPrice, -1) < 0)
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }

                                    string MarketingPolicy = resDt.Rows[i]["MarketingPolicy"].ToString().Trim();
                                    if (string.IsNullOrWhiteSpace(MarketingPolicy))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (MarketingPolicy != "无优惠" && MarketingPolicy != "按等级打折" && MarketingPolicy != "按促销价")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string PromotionPrice = resDt.Rows[i]["PromotionPrice"].ToString().Trim();
                                    if (MarketingPolicy == "按促销价")
                                    {
                                        if (string.IsNullOrWhiteSpace(PromotionPrice) || StringUtils.GetDbDecimal(PromotionPrice) < 0)
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string Describe = resDt.Rows[i]["Describe"].ToString();
                                    if (Encoding.Default.GetByteCount(Describe) > 1000)
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }

                                    string New = resDt.Rows[i]["New"].ToString();
                                    if (string.IsNullOrWhiteSpace(New))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (New != "是" && New != "否")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string Recommended = resDt.Rows[i]["Recommended"].ToString();
                                    if (string.IsNullOrWhiteSpace(Recommended))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (Recommended != "是" && Recommended != "否")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string Available = resDt.Rows[i]["Available"].ToString();
                                    if (string.IsNullOrWhiteSpace(Available))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (Available != "是" && Available != "否")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string VisibleForCustomer = resDt.Rows[i]["VisibleForCustomer"].ToString();
                                    if (string.IsNullOrWhiteSpace(VisibleForCustomer))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (VisibleForCustomer != "是" && VisibleForCustomer != "否")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string RelativePath = resDt.Rows[i]["RelativePath"].ToString();
                                    if (!string.IsNullOrWhiteSpace(RelativePath))
                                    {
                                        string[] strContent = RelativePath.Trim().Split('|');
                                        for (int j = 0; j < strContent.Length; j++)
                                        {
                                            string[] strImageInfo = strContent[j].Split(',');
                                            if (strImageInfo[0] != "" && (strImageInfo[1] != "0" && strImageInfo[1] != "1"))
                                            {
                                                resDt.Rows[i]["IsPass"] = 0;
                                                isPass = false;
                                                errorRowNumber += i + "|";
                                                continue;
                                            }
                                        }
                                    }

                                    string IsConfirmed = resDt.Rows[i]["IsConfirmed"].ToString();
                                    if (string.IsNullOrWhiteSpace(IsConfirmed))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }
                                    else
                                    {
                                        if (IsConfirmed != "不再需要确认" && IsConfirmed != "需要客户端确认" && IsConfirmed != "需要顾客签字确认")
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                    }

                                    string AutoConfirm = resDt.Rows[i]["AutoConfirm"].ToString();
                                    if (string.IsNullOrWhiteSpace(AutoConfirm) || (AutoConfirm != "是" && AutoConfirm != "否"))
                                    {
                                        resDt.Rows[i]["IsPass"] = 0;
                                        isPass = false;
                                        errorRowNumber += i + "|";
                                        continue;
                                    }

                                    string strAutoConfirmDays = resDt.Rows[i]["AutoConfirmDays"].ToString();
                                    if (AutoConfirm == "是")
                                    {
                                        if (string.IsNullOrWhiteSpace(strAutoConfirmDays))
                                        {
                                            resDt.Rows[i]["IsPass"] = 0;
                                            isPass = false;
                                            errorRowNumber += i + "|";
                                            continue;
                                        }
                                        else
                                        {
                                            int AutoConfirmDays = StringUtils.GetDbInt(strAutoConfirmDays, 0);
                                            if (AutoConfirmDays < 1 || AutoConfirmDays > 999)
                                            {
                                                resDt.Rows[i]["IsPass"] = 0;
                                                isPass = false;
                                                errorRowNumber += i + "|";
                                                continue;
                                            }
                                        }
                                    }

                                }
                                #endregion
                            }
                            //string dataJson = Newtonsoft.Json.JsonConvert.SerializeObject(resDt, new Newtonsoft.Json.Converters.DataTableConverter());

                            //if (isPass)
                            //{
                            string fileName = getFileName(".XLS");//D:/a/temp/batchImport/

                            if (!Directory.Exists(Const.uploadServer + "/" + Const.strImage + "temp/batchImport/"))
                            {
                                Directory.CreateDirectory(Const.uploadServer + "/" + Const.strImage + "temp/batchImport/");
                            }

                            string filePath = Const.uploadServer + "/" + Const.strImage + "temp/batchImport/" + fileName;
                            hfc[0].SaveAs(filePath);
                                
                                
                            res.Code = "1";
                            res.Data = fileName;
                            res.Message = errorRowNumber;
                            return Content(JsonConvert.SerializeObject(res));
                            //}
                            //else
                            //{
                            //    DataRow[] rows = resDt.Select("IsPass=0");

                            //    res.Code = "-4";
                            //    res.Data = null;
                            //    return Json(res);
                            //}
                        }
                    }
                }
                else
                {
                    return Content(JsonConvert.SerializeObject(res));
                }
            }
            catch
            {
                return Content(JsonConvert.SerializeObject(res));
            }

        }
        public ActionResult CommodityBatchImport(UtilityOperation_Model model)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "上传失败";
            res.Data = null;

            UtilityOperation_Model utimodel = new UtilityOperation_Model();
            utimodel.Type = model.Type;
            utimodel.BranchID = BranchID;
            int BranchIDOne = model.BranchID;
            string param = "";
            string data = "";

            DateTime dateTime;

            DateTimeFormatInfo dtFormat = new DateTimeFormatInfo();
            dtFormat.ShortDatePattern = "yyyy/MM/dd";
            try
            {
                int addType = model.Type;

                HttpFileCollection hfc = System.Web.HttpContext.Current.Request.Files;
                string bx = "";
                if (hfc.Count > 0)
                {
                    if (hfc[0].ContentLength >= 4194304)
                    {
                        res.Code = "0";
                        res.Message = "上传文件过大!";
                        return Content(JsonConvert.SerializeObject(res));
                    }
                    BinaryReader r = new BinaryReader(hfc[0].InputStream);
                    byte buffer = r.ReadByte();
                    bx = buffer.ToString();
                    buffer = r.ReadByte();
                    bx += buffer.ToString();


                    Workbook workbook = new Workbook(hfc[0].InputStream);

                    Worksheet worksheet = workbook.Worksheets[0];
                    Cells cells = worksheet.Cells;

                    // 获取第二行开始的数据
                    DataTable dt = worksheet.Cells.ExportDataTable(0, 0, worksheet.Cells.MaxDataRow + 1, worksheet.Cells.MaxDataColumn + 1);

                    if (dt == null || dt.Rows.Count < 1)
                    {
                        // 数据为空
                        res.Code = "-2";
                        return Content(JsonConvert.SerializeObject(res));
                    }
                    else
                    {
                        // 列名赋值 为了以后根据使用列名操作
                        for (int i = 0; i < dt.Columns.Count; i++)
                        {
                            dt.Columns[i].ColumnName = dt.Rows[0][i].ToString();
                        }
                        DataTable resDt = new DataTable();
                        resDt = dtNormalizing(dt, Const.EXPORT_COMMODITYBATCHINFO);

                        //判断excel表格里同一种商品批次相同的元素
                        List<Same_Batch_Model> sameBatchList = new List<Same_Batch_Model>();
                        List<Same_Batch_Model> sameBatchListTwo = new List<Same_Batch_Model>();
                        Same_Batch_Model sameBatchModel = null;
                        Same_Batch_Model sameBatchModelOne = null;
                        Same_Batch_Model sameBatchModelTwo = null;

                        //商品是否有多条记录的
                        List<CommodityDetail_Model> sameCommodityList = new List<CommodityDetail_Model>();
                        for (int i = 1; i < dt.Rows.Count; i++) {
                            sameBatchModel = new Same_Batch_Model();
                            sameBatchModel.CommodityName = resDt.Rows[i]["CommodityName"].ToString().Trim();
                            sameBatchModel.BatchNO = resDt.Rows[i]["BatchNO"].ToString().Trim();
                            sameBatchList.Add(sameBatchModel);
                        }
                        sameBatchListTwo = sameBatchList;
                        for (int i=0;i< sameBatchList.Count;i++) {
                            sameBatchModelOne = sameBatchList[i];
                            for (int j=0;j< sameBatchListTwo.Count;j++) {
                                sameBatchModelTwo = sameBatchListTwo[j];
                                if ((i != j) && (sameBatchModelOne.CommodityName.Equals(sameBatchModelTwo.CommodityName)) && (sameBatchModelOne.BatchNO.Equals(sameBatchModelTwo.BatchNO)))
                                {
                                    res.Code = "-3";
                                    res.Message = "\"第 " + (i + 1) +  " 行商品名称为 " + sameBatchList[i].CommodityName + " ,存在相同的批次番号 " + sameBatchList[i].BatchNO + "\"";
                                    return Content(JsonConvert.SerializeObject(res));
                                }
                            }
                        }
                        
                        for (int i = 1; i < dt.Rows.Count; i++)
                        {

                            if (String.IsNullOrWhiteSpace(resDt.Rows[i]["CommodityName"].ToString().Trim()))
                            {
                                res.Code = "-3";
                                res.Message = "\"第 " + i.ToString() + " 行商品名称为空!\"";
                                return Content(JsonConvert.SerializeObject(res));
                            }
                            if (String.IsNullOrWhiteSpace(resDt.Rows[i]["BatchNO"].ToString().Trim())) {
                                res.Code = "-3";
                                res.Message = "\"第 " + i.ToString() + " 行批次番号为空!\"";
                                return Content(JsonConvert.SerializeObject(res));
                            }
                            if (String.IsNullOrWhiteSpace(resDt.Rows[i]["Quantity"].ToString().Trim()))
                            {
                                res.Code = "-3";
                                res.Message = "\"第 " + i.ToString() + " 行数量为空!\"";
                                return Content(JsonConvert.SerializeObject(res));
                            }
                            if (String.IsNullOrWhiteSpace(resDt.Rows[i]["ExpiryDate"].ToString().Trim()))
                            {
                                res.Code = "-3";
                                res.Message = "\"第 " + i.ToString() + " 行有效期为空!\"";
                                return Content(JsonConvert.SerializeObject(res));
                            }
                            else
                            {
                                try
                                {
                                    dateTime = Convert.ToDateTime(resDt.Rows[i]["ExpiryDate"].ToString().Trim(), dtFormat);
                                }
                                catch
                                {
                                    res.Code = "-3";
                                    res.Message = "\"第 " + i + " 行有效期 " + resDt.Rows[i]["ExpiryDate"].ToString() + " 不是有效日期,请检查!\"";

                                    return Content(JsonConvert.SerializeObject(res));
                                }
                                
                            }

                            //根据商品名称验证商品ID是否存在
                            CommodityDetail_Model commodityDetail = new CommodityDetail_Model();
                            commodityDetail.CommodityName = resDt.Rows[i]["CommodityName"].ToString().Trim();
                            param = JsonConvert.SerializeObject(commodityDetail);
                            bool resultCommodity = this.GetPostResponseNoRedirect("Commodity_M", "getCommodityDetailByCommodityModel", param, out data);

                            if (!resultCommodity || (JsonConvert.DeserializeObject<ObjectResult<CommodityDetail_Model>>(data).Data == null))
                            {
                                res.Code = "-3";
                                res.Message = "\"第 " + i + " 行商品名称为 " + resDt.Rows[i]["CommodityName"].ToString() + " 对应的商品Code不存在,请检查\"";

                                return Content(JsonConvert.SerializeObject(res));

                            }
                            else {
                                ObjectResult<CommodityDetail_Model> comObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<CommodityDetail_Model>>(data);
                                commodityDetail = comObjResult.Data;
                                if (commodityDetail.SameNameNum > 1) {
                                    sameCommodityList.Add(commodityDetail);
                                }
                            }

                            //检查同一个商品的商品批次是否重复 
                            Product_Stock_Batch_Model operationModel = new Product_Stock_Batch_Model();
                            operationModel.ProductCode = commodityDetail.CommodityCode;
                            operationModel.BatchNO = resDt.Rows[i]["BatchNO"].ToString().Trim();
                            operationModel.BranchID = BranchIDOne;
                            param = JsonConvert.SerializeObject(operationModel);
                            bool resultProductStockBatch = this.GetPostResponseNoRedirect("Commodity_M", "getProductStockBatchByProductCodeAndBatchNO", param, out data);
                            if (!resultProductStockBatch || (JsonConvert.DeserializeObject<ObjectResult<Product_Stock_Batch_Model>>(data).Data != null))
                            {
                                res.Code = "-3";
                                res.Message = "\"第 " + i + " 行商品名称为 " + resDt.Rows[i]["CommodityName"].ToString() + " 对应的批次番号 " + operationModel.BatchNO + " 已经存在,请检查\"";
                                return Content(JsonConvert.SerializeObject(res));
                            }

                            //根据供应商名称验证供应商ID是否存在
                            if (!String.IsNullOrWhiteSpace(resDt.Rows[i]["SupplierName"].ToString().Trim()))
                            {
                                Supplier_Commodity_RELATION_Model supplierCommodityRelationModel = new Supplier_Commodity_RELATION_Model();
                                supplierCommodityRelationModel.SupplierName = resDt.Rows[i]["SupplierName"].ToString().Trim();
                                supplierCommodityRelationModel.CommodityCode = commodityDetail.CommodityCode;
                                param = JsonConvert.SerializeObject(supplierCommodityRelationModel);
                                bool resultSupplier = this.GetPostResponseNoRedirect("Supplier_M", "GetSupplierDetailInfo", param, out data);
                                if (!resultSupplier || (JsonConvert.DeserializeObject<ObjectResult<Supplier_Commodity_RELATION_Model>>(data).Data == null))
                                {
                                    res.Code = "-3";
                                    res.Message = "\"第 " + i + " 行供应商名称为 " + resDt.Rows[i]["SupplierName"].ToString() + " 对应的供应商ID不存在,请检查\"";
                                    return Content(JsonConvert.SerializeObject(res));
                                }

                            }


                        }
                        string fileName = getFileName(".XLS");

                        if (!Directory.Exists(Const.uploadServer + "/" + Const.strImage + "temp/batchImport/"))
                        {
                            Directory.CreateDirectory(Const.uploadServer + "/" + Const.strImage + "temp/batchImport/");
                        }

                        string filePath = Const.uploadServer + "/" + Const.strImage + "temp/batchImport/" + fileName;

                        /*if (!Directory.Exists( "D:/temp/batchImport/"))
                        {
                            Directory.CreateDirectory("D:/temp/batchImport/");
                        }

                        string filePath = "D:/temp/batchImport/" + fileName;*/
                        hfc[0].SaveAs(filePath);
                        

                        res.Code = "1";
                        res.Data = fileName;
                        res.Message = "";
                        if (sameCommodityList.Count > 0) {
                            StringBuilder sb = new StringBuilder("\" 商品名称为：");
                            for (int i = 0; i < sameCommodityList.Count ;i ++) {
                                if (i != sameCommodityList.Count - 1)
                                {
                                    sb.Append(sameCommodityList[i].CommodityName + ",");
                                }
                                else
                                {

                                    sb.Append(sameCommodityList[i].CommodityName);
                                }
                                
                            }
                            sb.Append(" 存在重复数据！是否继续？\"");
                            res.Message = sb.ToString();
                        }
                        return Content(JsonConvert.SerializeObject(res));
                    }
                }
                else
                {
                    return Content(JsonConvert.SerializeObject(res));
                }
            }
            catch (Exception e)
            {

                return Content(JsonConvert.SerializeObject(e));
            }

        }
        private string getFileName(string suffix)
        {
            DateTime dt = DateTime.Now.ToLocalTime();
            string randomNumber = "";
            int seed = Guid.NewGuid().GetHashCode();
            Random random = new Random(seed);
            for (int j = 0; j < 5; j++)
            {
                randomNumber += random.Next(10).ToString();
            }
            string fileName = "O" + string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber + suffix;
            return fileName;
        }

        private DataTable dtNormalizing(DataTable dt, Dictionary<string, string> dc)
        {
            if (dt != null)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    if (dc.ContainsValue(dt.Columns[i].ColumnName))
                    {
                        dt.Columns[i].ColumnName = dc.First(c => c.Value.Equals(dt.Columns[i].ColumnName)).Key;
                    }
                }
            }
            return dt;

        }

        public ActionResult importProduct(UtilityOperation_Model model)
        {

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "添加失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("WebUtility_M", "batchImport", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");

        }

        public ActionResult importCommodityBatchInfo(UtilityOperation_Model model)
        {

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "添加失败";
            res.Code = "0";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("WebUtility_M", "batchImportCommodityBatch", param, out data);

            if (!result)
            {
                return Json(res);
            }

            else
            {
                return Content(data, "application/json; charset=utf-8");
            }

        }
    }
}
