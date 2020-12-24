using Aspose.Cells;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Commodity_BLL
    {
        #region 构造类实例
        public static Commodity_BLL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly Commodity_BLL instance = new Commodity_BLL();
        }
        #endregion
        /// <summary>
        /// 获取商品列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getCommodityList(int companyID, int pageIndex, int pageSize, out int recordCount, int height, int width, string strSearch)
        {
            List<GetProductList_Model> list = Commodity_DAL.Instance.getCommodityList(companyID, pageIndex, pageSize, out recordCount, height, width, strSearch);
            return list;
        }


        /// <summary>
        /// 商品详细
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public GetCommodityDetail_Model getCommodityDetail(int companyID, long commodityCode, int height, int width)
        {
            GetCommodityDetail_Model model = Commodity_DAL.Instance.getCommodityDetail(companyID, commodityCode, height, width);
            return model;
        }
        /// <summary>
        /// 商品图片
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <returns></returns>
        public List<string> getCommodityImgList(int companyID, int commodityID, int height, int width, int count = 0)
        {
            List<string> list = Commodity_DAL.Instance.getCommodityImgList(companyID, commodityID, height, width);
            if (count > 0 && list != null && list.Count > 0 && list.Count > count)
            {
                list = list.Take(count).ToList();
            }
            return list;
        }

        /// <summary>
        /// 获取商浏览历史列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getCommodityBrowseHistoryList(int companyID, string strCommodityCodes, int height, int width)
        {
            return Commodity_DAL.Instance.getCommodityBrowseHistoryList(companyID, strCommodityCodes, height, width);
        }

        public ObjectResult<ProductInFoByQRCode_Model> getCommodityInfoByQRCode(string companyCode, int branchId, long code, int accountId)
        {
            return Commodity_DAL.Instance.getCommodityInfoByQRCode(companyCode, branchId, code, accountId);
        }

        public List<CommodityList_Model> getCommodityListByCompanyId(int companyId, bool isBusiness, int branchId, int accountId, int customerId)
        {
            return Commodity_DAL.Instance.getCommodityListByCompanyId(companyId, isBusiness, branchId, accountId, customerId);
        }

        public List<CommodityList_Model> getCommodityListByCategoryID(UtilityOperation_Model model)
        {
            List<CommodityList_Model> list = Commodity_DAL.Instance.getCommodityListByCategoryID(model.CategoryID, model.IsBusiness, model.BranchID, model.AccountID, model.CustomerID, true);
            if (list != null && list.Count > 0)
            {
                foreach (CommodityList_Model item in list)
                {
                    List<ImageCommon_Model> listImage = Image_BLL.Instance.getCommodityImage_2_2(item.CommodityID, 0, model.ImageWidth, model.ImageHeight);
                    if (listImage != null && listImage.Count > 0)
                    {
                        item.ThumbnailURL = listImage[0].FileUrl;
                    }
                }
            }
            return list;
        }

        public ObjectResult<List<ProductInfoList_Model>> getProductInfoList(ProductInfoListOperation_Model model)
        {
            return Commodity_DAL.Instance.getProductInfoList(model);
        }

        /// <summary>
        /// 获取具体商品信息
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public ObjectResult<CommodityDetail_Model> getCommodityDetailByCommodityCode(UtilityOperation_Model model)
        {
            return Commodity_DAL.Instance.getCommodityDetailByCommodityCode(model);
        }

        public List<CommodityEnalbeInfoDetail> getCommodityEnalbleForCustomer(int customerId, long productCode)
        {
            return Commodity_DAL.Instance.getCommodityEnalbleForCustomer(customerId, productCode);
        }

        public List<Commodity_Model> getCommodityListByCompanyIdForWeb(int companyId, int imageWidth, int imageHeight)
        {
            return Commodity_DAL.Instance.getCommodityListByCompanyIdForWeb(companyId, imageWidth, imageHeight);
        }

        public List<Commodity_Model> getCommodityListForWeb(int companyId, int categoryId, int imageWidth, int imageHeight, int branchId,int supplierID)
        {
            return Commodity_DAL.Instance.getCommodityListForWeb(companyId, categoryId, imageWidth, imageHeight, branchId, supplierID);
        }

        public int addCommodity(CommodityDetailOperation_Model model, out long commodityCode)
        {
            return Commodity_DAL.Instance.addCommodity(model, out commodityCode);
        }

        public bool deleteCommodity(int accountId, long commodityCode, int companyID)
        {
            return Commodity_DAL.Instance.deleteCommodity(accountId, commodityCode, companyID);
        }

        public CommodityDetail_Model getCommodityDetailForWeb(int companyId, int branchId, long commodityCode, int imageWidth, int imageHeight)
        {
            CommodityDetail_Model detailModel = new CommodityDetail_Model();
            if (commodityCode != 0)
            {
                detailModel = Commodity_DAL.Instance.getCommodityDetailForWeb(companyId, commodityCode);

                if (detailModel != null)
                {
                    #region 缩略图
                    List<ImageCommon_Model> listImage = Image_DAL.Instance.getCommodityImage_2_2(detailModel.CommodityID, 0, imageWidth, imageHeight);
                    detailModel.Thumbnail = (listImage != null && listImage.Count > 0) ? listImage[0].FileUrl : "";

                    #endregion

                    #region 大图
                    List<ImageCommon_Model> listBigImage = Image_DAL.Instance.getCommodityImage_2_2(detailModel.CommodityID, 1, imageWidth, imageHeight);

                    detailModel.BigImageList = listBigImage;
                    #endregion

                    #region 分店关系
                    detailModel.ProductBranchRelationship = Commodity_DAL.Instance.getCommodityBranchStock(detailModel.CommodityCode, companyId, branchId);
                    #endregion

                    #region 批次
                    detailModel.BatchDetail = Commodity_DAL.Instance.getCommodityBatchStock(detailModel.CommodityCode, companyId, branchId);
                    #endregion
                }
            }
            else
            {
                detailModel.ProductBranchRelationship = Commodity_DAL.Instance.getCommodityBranchStock(detailModel.CommodityCode, companyId, branchId);
            }
            return detailModel;

        }

        public CommodityDetail_Model getCommoditySupplierDetailForWeb(int companyId, long commodityCode)
        {
            CommodityDetail_Model detailModel = new CommodityDetail_Model();
            if (commodityCode != 0)
            {
                detailModel = Commodity_DAL.Instance.getCommodityDetailForWeb(companyId, commodityCode);

                if (detailModel != null)
                {
                    #region 供应商
                    detailModel.SupplierDetail = Commodity_DAL.Instance.getCommoditySupplierDetailList(detailModel.CommodityCode);
                    #endregion

                }
            }
            return detailModel;

        }
        public bool OperateProductStock(BranchCommodityOperation_Model model)
        {
            return Commodity_DAL.Instance.OperateProductStock(model);
        }

        public int updateCommodityDetail(CommodityDetailOperation_Model model)
        {
            return Commodity_DAL.Instance.updateCommodityDetail(model);
        }

        public bool deteleMultiCommodity(DelMultiCommodity_Model model)
        {
            return Commodity_DAL.Instance.deteleMultiCommodity(model);
        }


        public bool BatchAddCommodity(BatchAddCommodity_Model model)
        {
            string errMsg;
            return Commodity_DAL.Instance.BatchAddCommodity(model.dt, model.mCommodity, out errMsg);
        }

        public string downloadCommodityList(UtilityOperation_Model model)
        {
            string strRes = "";
            DataTable dt = Commodity_DAL.Instance.getCommodityListByCategoryIdForDownload(model.CompanyID, model.CategoryID, model.BranchID);
            if (dt == null || dt.Rows.Count == 0)
                return strRes;

            dt.Columns.Add("RelativePath");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataTable dtImage = Image_DAL.Instance.getCommodityImageForExport(Convert.ToInt32(dt.Rows[i]["CommodityID"]));
                StringBuilder sb = new StringBuilder();
                if (dtImage != null && dtImage.Rows.Count > 0)
                {
                    for (int j = 0; j < dtImage.Rows.Count; j++)
                    {
                        //if (File.Exists(AppDomain.CurrentDomain.BaseDirectory + dtImage.Rows[j]["FileUrl"].ToString()))
                        sb.Append(dtImage.Rows[j]["FileUrl"].ToString() + "," + (Convert.ToBoolean(dtImage.Rows[j]["ImageType"]) ? "1" : "0") + "|");
                    }
                }

                dt.Rows[i]["RelativePath"] = sb.ToString();
            }
            //dt.Columns.Remove("CommodityID");

            dt = dtNormalizing(dt, Const.EXPORT_COMMODITYNAMEEXCHANGE);
            if (dt != null)
            {
                Aspose.Cells.Workbook workbook = new Aspose.Cells.Workbook();
                Aspose.Cells.Worksheet cellSheet = workbook.Worksheets[0];
                cellSheet.Name = dt.TableName;
                int rowIndex = 0;
                int colIndex = 0;
                int colCount = dt.Columns.Count;
                int rowCount = dt.Rows.Count;
                Aspose.Cells.Style ss = new Aspose.Cells.Style();
                ss.Font.IsBold = true;
                ss.Font.Name = "宋体";

                //列名的处理
                for (int i = 0; i < colCount; i++)
                {
                    if (dt.Columns[i].ColumnName == "CategoryName")
                    {
                        cellSheet.Cells[rowIndex, colIndex].PutValue("CategoryID");
                    }
                    else
                    {
                        cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Columns[i].ColumnName);
                    }
                    cellSheet.Cells[rowIndex, colIndex].SetStyle(ss);
                    colIndex++;
                }

                Aspose.Cells.Style style = workbook.Styles[workbook.Styles.Add()];
                style.Font.Name = "Arial";
                style.Font.Size = 10;
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                cellSheet.Cells.ApplyStyle(style, styleFlag);

                rowIndex++;
                #region 商品
                for (int i = 0; i < rowCount; i++)
                {
                    colIndex = 0;
                    for (int j = 0; j < colCount; j++)
                    {
                        if (dt.Columns[j].ColumnName == "StockQuantity")
                        {
                            if (string.IsNullOrWhiteSpace(dt.Rows[i][j].ToString()))
                            {
                                cellSheet.Cells[rowIndex, colIndex].PutValue("-1");
                            }
                            else
                            {
                                cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Rows[i][j].ToString());
                            }
                        }
                        else if (dt.Columns[j].ColumnName == "确认方式")
                        {
                            switch (StringUtils.GetDbInt(dt.Rows[i][j]))
                            {
                                case 0:
                                    cellSheet.Cells[rowIndex, colIndex].PutValue("不再需要确认");
                                    break;
                                case 1:
                                    cellSheet.Cells[rowIndex, colIndex].PutValue("需要客户端确认");
                                    break;
                                case 2:
                                    cellSheet.Cells[rowIndex, colIndex].PutValue("需要顾客签字确认");
                                    break;
                                default:
                                    cellSheet.Cells[rowIndex, colIndex].PutValue("不再需要确认");
                                    break;
                            }
                        }
                        else
                        {
                            switch (dt.Rows[i][j].ToString())
                            {
                                case "True":
                                    cellSheet.Cells[rowIndex, colIndex].PutValue("是");
                                    break;
                                case "False":
                                    cellSheet.Cells[rowIndex, colIndex].PutValue("否");
                                    break;
                                default:
                                    cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Rows[i][j].ToString());
                                    break;
                            }
                        }

                        colIndex++;
                    }
                    rowIndex++;
                }
                #endregion

                cellSheet.AutoFitColumns();

                MemoryStream ms = new MemoryStream();
                ms = workbook.SaveToStream();

                string path = Const.uploadServer + "/" + Const.strImage + "temp/product/";
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }
                string fileName = "commodity" + DateTime.Now.Ticks + ".xls";
                workbook.Save(path + fileName);
                string url = Const.strFileHttp + Const.server + "/getFile.aspx?fn=temp/product/" + fileName;
                return url;
            }

            return strRes;
        }
        /// <summary>
        /// 批量添加商品批次模板下载
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public string downloadCommodityBatchTemplateList(UtilityOperation_Model model)
        {
            string strRes = "";
            DataTable dt0 = Commodity_DAL.Instance.getBatchListForDownloadCommodityBatchTemplate();
            //商品Sheet
            //DataTable dt1 = Commodity_DAL.Instance.getCommodityListForDownloadCommodityBatchTemplate(model.CompanyID, model.CategoryID, model.BranchID);
            //供应商  
            //DataTable dt2 = Commodity_DAL.Instance.getSupplierListForDownloadCommodityBatchTemplate(model.CompanyID, model.BranchID);
            /*if (dt1 == null || dt1.Rows.Count == 0 || dt2 == null || dt2.Rows.Count == 0)
                return strRes;*/
            Aspose.Cells.Workbook workbook = new Aspose.Cells.Workbook();
            //Aspose.Cells.Worksheet cellSheet1 = workbook.Worksheets[0];
            dt0 = dtNormalizing(dt0, Const.EXPORT_COMMODITYBATCHINFO);
            Aspose.Cells.Worksheet cellSheet0 = workbook.Worksheets[0];
            cellSheet0 = returnSheet0Content(cellSheet0, dt0, workbook);
            /*dt1 = dtNormalizing(dt1, Const.EXPORT_COMMODITYNAMEBATCH); //商品sheet不显示标题
            dt2 = dtNormalizing(dt2, Const.EXPORT_SUPPLIERNAMEBATCH);  //供应商sheet不显示标题

            Aspose.Cells.Workbook workbook = new Aspose.Cells.Workbook();
            for (int i=0;i<2;i++) {
                workbook.Worksheets.Add(i+"");
            }

           
            Aspose.Cells.Worksheet cellSheet1 = workbook.Worksheets[1];
            cellSheet1.Name = "commodity";
            cellSheet1 = returnSheetContent(cellSheet1, dt1, workbook);
            Aspose.Cells.Worksheet cellSheet2 = workbook.Worksheets[2];
            cellSheet2.Name = "supplier";
            cellSheet2 = returnSheetContent(cellSheet2, dt2, workbook);


            Aspose.Cells.Worksheet cellSheet0 = workbook.Worksheets[0];
            cellSheet0 = returnSheet0Content(cellSheet0, dt0, workbook);

            workbook.CalculateFormula(true);*/

            /*Aspose.Cells.Workbook workbook = new Aspose.Cells.Workbook("E:\\export\\CommodityBatchTemplate.xlsx");
            Aspose.Cells.Worksheet cellSheet1 = workbook.Worksheets[1];
            Aspose.Cells.Worksheet cellSheet2 = workbook.Worksheets[2];
            for (int i = 0; i < dt1.Rows.Count; i++)
            {
                for (int j = 0; j < 2; j++)
                {
                    if (j == 1)
                    {
                        cellSheet1.Cells[i, j].PutValue(dt1.Rows[i][j].ToString(),true);
                    }
                    else
                    {
                        cellSheet1.Cells[i, j].PutValue(dt1.Rows[i][j].ToString());
                    }
                }

            }
            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                for (int j = 0; j < 2; j++)
                {
                    if (j == 1)
                    {
                        cellSheet2.Cells[i, j].PutValue(dt2.Rows[i][j].ToString(), true);
                    }
                    else
                    {
                        cellSheet2.Cells[i, j].PutValue(dt2.Rows[i][j].ToString());
                    }
                }
            }*/


            MemoryStream ms = new MemoryStream();
            ms = workbook.SaveToStream();

            string path = Const.uploadServer + "/" + Const.strImage + "temp/product/";
            //string path = "D:/temp/product/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string fileName = "CommodityBatchTemplate" + DateTime.Now.Ticks + ".xls";
            workbook.Save(path + fileName, SaveFormat.Excel97To2003);
            string url = Const.strFileHttp + Const.server + "/getFile.aspx?fn=temp/product/" + fileName;
            return url;

        }

        private Aspose.Cells.Worksheet returnSheetContent(Aspose.Cells.Worksheet cellSheet, DataTable dt, Aspose.Cells.Workbook workbook)
        {

            int rowIndex = 0;
            int colIndex = 0;
            int colCount = dt.Columns.Count;
            int rowCount = dt.Rows.Count;
            Aspose.Cells.Style ss = new Aspose.Cells.Style();
            ss.Font.IsBold = true;
            ss.Font.Name = "宋体";

            //列名的处理  暂时不显示列名
            /*for (int i = 0; i < colCount; i++)
            {
                cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Columns[i].ColumnName);
                cellSheet.Cells[rowIndex, colIndex].SetStyle(ss);
                colIndex++;
            }
             rowIndex++;
             */

            Aspose.Cells.Style style = workbook.Styles[workbook.Styles.Add()];
            style.Font.Name = "Arial";
            style.Font.Size = 10;
            Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
            cellSheet.Cells.ApplyStyle(style, styleFlag);


            #region 
            for (int i = 0; i < rowCount; i++)
            {
                colIndex = 0;
                for (int j = 0; j < colCount; j++)
                {
                    if (j == 1)
                    {
                        cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Rows[i][j].ToString(), true);
                        Aspose.Cells.Style styleMid = cellSheet.Cells[rowIndex, colIndex].GetStyle();
                        styleMid.Number = 1;
                        cellSheet.Cells[rowIndex, colIndex].SetStyle(styleMid);
                    }
                    else
                    {
                        cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Rows[i][j].ToString());
                    }


                    colIndex++;
                }
                rowIndex++;
            }
            #endregion

            cellSheet.AutoFitColumns();
            return cellSheet;
        }

        private Aspose.Cells.Worksheet returnSheet0Content(Aspose.Cells.Worksheet cellSheet, DataTable dt, Aspose.Cells.Workbook workbook)
        {

            int rowIndex = 0;
            int colIndex = 0;
            int colCount = dt.Columns.Count;
            int rowCount = dt.Rows.Count;
            Aspose.Cells.Style ss = new Aspose.Cells.Style();
            ss.Font.IsBold = true;
            ss.Font.Name = "宋体";
            

            //列名的处理
            for (int i = 0; i < colCount; i++)
            {
                cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Columns[i].ColumnName);
                cellSheet.Cells[rowIndex, colIndex].SetStyle(ss);
                cellSheet.Cells.SetColumnWidth(i, 30);//设置列宽
                colIndex++;
            }

            /*Aspose.Cells.Style style = workbook.Styles[workbook.Styles.Add()];
            style.Font.Name = "Arial";
            style.Font.Size = 10;
            Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
            cellSheet.Cells.ApplyStyle(style, styleFlag);


            ValidationCollection validations = cellSheet.Validations;
            Validation validation = validations[validations.Add()];
            validation.Type = Aspose.Cells.ValidationType.List;
            validation.Operator = OperatorType.None;
            validation.InCellDropDown = true;
            validation.Formula1 = "=commodity!$A:$A";
            validation.ShowError = true;
            validation.AlertStyle = ValidationAlertType.Stop;
            validation.ErrorTitle = "Error";
            validation.ErrorMessage = "Please select a commodity from the list";
            CellArea area;
            area.StartRow = 1;
            area.EndRow = 100;
            area.StartColumn = 0;
            area.EndColumn = 0;
            validation.AreaList.Add(area);

            
            for (int i=1;i<=100;i++) {
                Aspose.Cells.Style styleNum = cellSheet.Cells[i, 1].GetStyle();
                styleNum.Number = 1;
                cellSheet.Cells[i, 1].SetStyle(styleNum);
                //cellSheet.Cells[i, 1].Formula = "=IFERROR(VLOOKUP(A"+(i+1)+",commodity!$A:$B,2,FALSE),\"\")";

                //VLOOKUP(TRIM(CLEAN(A" + (i + 1) + ")),TRIM(CLEAN(commodity!$A:$B)),2,FALSE)
                cellSheet.Cells[i, 1].Formula = "=VLOOKUP(A" + (i + 1) +",commodity!$A:$B,2,FALSE)";
                //cellSheet.Cells[i, 1].Formula = "=VLOOKUP(TRIM(CLEAN(A" + (i + 1) + ")),TRIM(CLEAN(commodity!$A:$B)),2,FALSE)";
            }*/


            //cellSheet.AutoFitColumns();
            return cellSheet;
        }
        private DataTable dtNormalizing(DataTable dt, Dictionary<string, string> dc)
        {
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (dc.ContainsKey(dt.Columns[i].ColumnName))
                {
                    dt.Columns[i].ColumnName = dc[dt.Columns[i].ColumnName];
                }
            }
            return dt;
        }


        public List<Commodity_Model> getPrintList(List<long> codeList)
        {
            List<Commodity_Model> list = Commodity_DAL.Instance.getPrintList(codeList);
            if (list != null && list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    list[i].QRcodeUrl = "http://" + Const.server + "/GetQRcode.aspx?size=3&content=" + "http://" + Const.server + "/a.aspx?id=" + list[i].CompanyCode + "^" + "001" + "^" + string.Format("{0:D10}", list[i].CommodityCode);
                }
            }
            return list;
        }

        public bool UpdateCommoditySort(int companyID, string strSort)
        {
            if (!string.IsNullOrWhiteSpace(strSort))
            {
                List<CommoditySort_Model> list = new List<CommoditySort_Model>();
                string[] arr = strSort.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);

                if (arr[0] == null || arr[1] == null)
                {
                    return false;
                }

                // 获取商品code数组
                string[] arrCode = arr[0].Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                // 获取排序数组
                string[] arrSortid = arr[1].Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);

                if (arrCode.Length != arrSortid.Length)
                {
                    return false;
                }
                else
                {
                    for (int i = 0; i < arrCode.Length; i++)
                    {
                        CommoditySort_Model model = new CommoditySort_Model();
                        model.CommodityCode = HS.Framework.Common.Util.StringUtils.GetDbLong(arrCode[i]);
                        model.Sortid = HS.Framework.Common.Util.StringUtils.GetDbInt(arrSortid[i]);
                        list.Add(model);
                    }
                }

                bool res = Commodity_DAL.Instance.UpdateCommoditySort(companyID, list);
                return res;
            }
            return false;
        }

        public bool AddBatch(Product_Stock_Batch_Model model)
        {
            return Commodity_DAL.Instance.AddBatch(model);
        }
        
        public Product_Stock_Batch_Model getProductStockBatchByProductCodeAndBatchNO(Product_Stock_Batch_Model model)
        {
            return Commodity_DAL.Instance.getProductStockBatchByProductCodeAndBatchNO(model);
        }
        public bool updateBatch(List<BatchCommodityOperation_Model.BatchStockOperation_Model> model, int companyID, int UserID)
        {
            bool res = Commodity_DAL.Instance.updateBatch(model, companyID, UserID);
            return res;
        }

        public bool deleteBatch(int accountId, int ID, int Quantity, int BranchID, long ProductCode, string BatchNO, int companyID, int UserID)
        {
            return Commodity_DAL.Instance.deleteBatch(accountId, ID, Quantity, BranchID, ProductCode, BatchNO, companyID, UserID);
        }

        public List<StorageDetail_Model> getStorageDetail(UtilityOperation_Model model)
        {
            return Commodity_DAL.Instance.getStorageDetail(model);
        }

        public int getQuantity(UtilityOperation_Model model)
        {
            return Commodity_DAL.Instance.getQuantity(model);
        }

        public bool operateQuantity(StorageDetail_Model model, int CompanyID, int UserID)
        {
            return Commodity_DAL.Instance.operateQuantity(model, CompanyID, UserID);
        }
        public bool applyCommodityCode(StorageDetail_Model model, int CompanyID, int BranchID, int UserID)
        {
            return Commodity_DAL.Instance.applyCommodityCode(model, CompanyID, BranchID, UserID);
        }
        public bool agreeCommodityCode(StorageDetail_Model model, int UserID)
        {
            return Commodity_DAL.Instance.agreeCommodityCode(model, UserID);
        }
        public bool negativeCommodityCode(StorageDetail_Model model, int UserID)
        {
            return Commodity_DAL.Instance.negativeCommodityCode(model, UserID);
        }
        public bool confirmCommodityCode(StorageDetail_Model model, int UserID)
        {
            return Commodity_DAL.Instance.confirmCommodityCode(model, UserID);
        }

        /// <summary>
        /// 获取商品列表
        /// </summary>
        /// <param name="Commodity_Model"></param>
        /// <returns></returns>
        public List<Commodity_Model> GetCommodityList(Commodity_Model model)
        {
            List<Commodity_Model> list = Commodity_DAL.Instance.GetCommodityList(model);
            return list;
        }

        public CommodityDetail_Model getCommodityDetailByCommodityModel(int companyId, int branchId, string commodityName)
        {
            return Commodity_DAL.Instance.getCommodityDetailByCommodityModel(companyId, branchId, commodityName);
        }

    }
}
