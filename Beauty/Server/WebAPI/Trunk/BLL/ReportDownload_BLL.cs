using Aspose.Cells;
using HS.Framework.Common.Util;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class ReportDownload_BLL
    {
        #region 构造类实例
        public static ReportDownload_BLL Instance
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
            internal static readonly ReportDownload_BLL instance = new ReportDownload_BLL();
        }
        #endregion

        /// <summary>
        /// 下载顾客报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getCustomerReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getCustomerReport(companyId, branchId, beginDay, endDay);
        }
        /// <summary>
        /// 下载商品库存报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable getCommodityStockReport(int companyId, int branchId)
        {
            return ReportDownload_DAL.Instance.getCommodityStockReport(companyId, branchId);
        }
        /// <summary>
        /// 下载商品批次报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable getCommoditybatch(int companyId, int branchId)
        {
            return ReportDownload_DAL.Instance.getCommoditybatch(companyId, branchId);
        }
        /// <summary>
        /// 下载库存变动信息
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable getProductStockOperateLog(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getProductStockOperateLog(companyId, branchId, beginDay, endDay);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        //public DataTable getServiceDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        //{
        //    return ReportDownload_DAL.Instance.getServiceDeatilReport(companyId, branchId, beginDay, endDay);
        //}
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getCommodityDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getCommodityDeatilReport(companyId, branchId, beginDay, endDay);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getReChargeDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getReChargeDeatilReport(companyId, branchId, beginDay, endDay);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getBalanceDetailData(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getBalanceDetailData(companyId, branchId, beginDay, endDay);
        }

        /// <summary>
        /// 流量统计
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getPeopleCount(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getPeopleCount(companyId, branchId, beginDay, endDay);
        }

        public string ExportReport(DataSet ds, string typeName, string fileUrl)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];

                // ws.Name = dt.TableName;

                int rows = ws.Cells.MaxDataRow + 1;

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (j == 0)
                        {
                            displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                            Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                            range1.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                ws.Cells.SetRowHeight(k + rows, height);
                            }
                        }

                        displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                        Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                        range.ApplyStyle(displayStyle, styleFlag);
                        for (int k = 0; k < dt.Rows.Count; k++)
                        {
                            ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                        }

                    }
                }
            }

            wb.CalculateFormula(true);

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string fileName = typeName + DateTime.Now.Ticks + ".xls";
            wb.Save(path + fileName, SaveFormat.Excel97To2003);
            string url = Const.strFileHttp + Const.server + "/getFile.aspx?fn=temp/report/" + fileName;
            return url;
        }
        /// <summary>
        /// 门店业绩报表
        /// </summary>
        /// <param name="ds"></param>
        /// <param name="wb"></param>
        public string ExportBranchPerformanceReport(DataSet ds, string fileUrl)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];


                int rows = ws.Cells.MaxDataRow + 1;

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    if (i == 0)
                    {
                        for (int j = 0; j < dt.Columns.Count; j++)
                        {
                            if (j == 0)
                            {
                                displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                                Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                                range1.ApplyStyle(displayStyle, styleFlag);
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                    ws.Cells.SetRowHeight(k + rows, height);
                                }
                            }

                            displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                            Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count + 1, 1);
                            range.ApplyStyle(displayStyle, styleFlag);
                            if (j == 9)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "SUM(D" + currentRow.ToString() + ":J" + currentRow.ToString() + ")";
                                }
                            }
                            else if (j == 10)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "D" + currentRow.ToString() + "+ E" + currentRow.ToString() + "+ F" + currentRow.ToString();
                                }
                            }
                            else if (j == 18)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "SUM(M" + currentRow.ToString() + ":S" + currentRow.ToString() + ")";
                                }
                            }
                            else if (j == 19)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "M" + currentRow.ToString() + "+ N" + currentRow.ToString() + "+ O" + currentRow.ToString();
                                }
                            }
                            else if (j == 23)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "L" + currentRow.ToString() + "+ U" + currentRow.ToString();
                                }
                            }
                            else if (j == 24)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "V" + currentRow.ToString() + "+ W" + currentRow.ToString() + "+ X" + currentRow.ToString();
                                }
                            }
                            else if (j == 25)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "Z" + currentRow.ToString() + "+Y" + currentRow.ToString();
                                }
                            }
                            else
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                                }
                            }

                            int firstRows = rows + 1;
                            int LastRows = rows + dt.Rows.Count;

                            ws.Cells.Merge(LastRows, 0, 1, 3);

                            displayStyle = ws.Cells[rows, 0].GetDisplayStyle();
                            displayStyle.HorizontalAlignment = TextAlignmentType.Center;
                            ws.Cells[LastRows, 0].SetStyle(displayStyle);
                            ws.Cells.SetRowHeight(LastRows, 40);//设置行高
                            ws.Cells[LastRows, 0].PutValue("合计");
                            ws.Cells[LastRows, 3].Formula = "SUM(D" + firstRows + ":D" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 4].Formula = "SUM(E" + firstRows + ":E" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 5].Formula = "SUM(F" + firstRows + ":F" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 6].Formula = "SUM(G" + firstRows + ":G" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 7].Formula = "SUM(H" + firstRows + ":H" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 8].Formula = "SUM(I" + firstRows + ":I" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 9].Formula = "SUM(J" + firstRows + ":J" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 10].Formula = "SUM(K" + firstRows + ":K" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 11].Formula = "SUM(L" + firstRows + ":L" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 12].Formula = "SUM(M" + firstRows + ":M" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 13].Formula = "SUM(N" + firstRows + ":N" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 14].Formula = "SUM(O" + firstRows + ":O" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 15].Formula = "SUM(P" + firstRows + ":P" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 16].Formula = "SUM(Q" + firstRows + ":Q" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 17].Formula = "SUM(R" + firstRows + ":R" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 18].Formula = "SUM(S" + firstRows + ":S" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 19].Formula = "SUM(T" + firstRows + ":T" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 20].Formula = "SUM(U" + firstRows + ":U" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 21].Formula = "SUM(V" + firstRows + ":V" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 22].Formula = "SUM(W" + firstRows + ":W" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 23].Formula = "SUM(X" + firstRows + ":X" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 24].Formula = "SUM(Y" + firstRows + ":Y" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 25].Formula = "SUM(Z" + firstRows + ":Z" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 26].Formula = "SUM(AA" + firstRows + ":AA" + LastRows.ToString() + ")";
                        }
                    }
                    else
                    {
                        for (int j = 0; j < dt.Columns.Count; j++)
                        {
                            if (j == 0)
                            {
                                displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                                Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                                range1.ApplyStyle(displayStyle, styleFlag);
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                    ws.Cells.SetRowHeight(k + rows, height);
                                }
                            }

                            displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                            Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                            range.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                            }

                        }

                    }
                }



            }



            wb.CalculateFormula(true);

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string fileName = "BranchPerformance" + DateTime.Now.Ticks + ".xls";
            wb.Save(path + fileName, SaveFormat.Excel97To2003);
            string url = Const.strFileHttp + Const.server + "/getFile.aspx?fn=temp/report/" + fileName;
            return url;
        }

        public DataTable getServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getServicePayDetail(companyId, branchId, beginDay, endDay);
        }

        public DataTable getTreatmentDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getTreatmentDetail(companyId, branchId, beginDay, endDay);
        }

        public DataTable getIsDesignatedDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getIsDesignatedDetail(companyId, branchId, beginDay, endDay);
        }


        public DataTable getNoCompleteTreatmentDetail(int companyId, int branchId)
        {
            return ReportDownload_DAL.Instance.getNoCompleteTreatmentDetail(companyId, branchId);
        }


        public DataTable getNoDeliveryCommodity(int companyId, int branchId)
        {
            return ReportDownload_DAL.Instance.getNoDeliveryCommodity(companyId, branchId);
        }

        #region 门店报表

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getBranchPerformance(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getBranchPerformance(companyId, branchId, beginDay, endDay);
        }

        public DataTable getBranchServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getBranchServicePayDetail(companyId, branchId, beginDay, endDay);
        }

        public DataTable getBranchCommodityDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getBranchCommodityDeatilReport(companyId, branchId, beginDay, endDay);
        }

        public DataTable getBranchReChargeDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getBranchReChargeDeatilReport(companyId, branchId, beginDay, endDay);
        }

        #endregion

        public string ExportAccountPerformanceReport(DataSet ds, string typeName, string fileUrl)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];

                // ws.Name = dt.TableName;

                int rows = ws.Cells.MaxDataRow + 1;

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (j == 0)
                        {
                            displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                            Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                            range1.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                ws.Cells.SetRowHeight(k + rows, height);
                            }
                        }

                        if (i == 1 && j == 10)
                        {
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                                Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                                range.ApplyStyle(displayStyle, styleFlag);
                                int current = k + rows + 1;
                                ws.Cells[k + rows, j + 1].Formula = "=COUNTIF(I:I,I" + current + " )";
                            }
                        }
                        else
                        {

                            displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                            Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                            range.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                            }
                        }

                    }
                }
            }

            wb.CalculateFormula(true);

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string fileName = typeName + DateTime.Now.Ticks + ".xls";
            wb.Save(path + fileName, SaveFormat.Excel97To2003);
            string url = Const.strFileHttp + Const.server + "/getFile.aspx?fn=temp/report/" + fileName;
            return url;
        }

        /// <summary>
        /// 门店业绩报表
        /// </summary>
        /// <param name="ds"></param>
        /// <param name="wb"></param>
        public void ExportBranchPerformanceReport(DataSet ds, string fileUrl, string downloadFileUrl)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];


                int rows = ws.Cells.MaxDataRow + 1;

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    if (i == 0)
                    {
                        for (int j = 0; j < dt.Columns.Count; j++)
                        {
                            if (j == 0)
                            {
                                displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                                Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                                range1.ApplyStyle(displayStyle, styleFlag);
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                    ws.Cells.SetRowHeight(k + rows, height);
                                }
                            }

                            displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                            Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count + 1, 1);
                            range.ApplyStyle(displayStyle, styleFlag);
                            if (j == 12)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "SUM(D" + currentRow.ToString() + ":M" + currentRow.ToString() + ")";
                                }
                            }
                            else if (j == 13)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "D" + currentRow.ToString() + "+ E" + currentRow.ToString() + "+ F" + currentRow.ToString() + "+ G" + currentRow.ToString() + "+ K" + currentRow.ToString() + "+ L" + currentRow.ToString();
                                }
                            }
                            else if (j == 24)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "SUM(P" + currentRow.ToString() + ":Y" + currentRow.ToString() + ")";
                                }
                            }
                            else if (j == 25)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "P" + currentRow.ToString() + "+ Q" + currentRow.ToString() + "+ R" + currentRow.ToString() + "+ S" + currentRow.ToString() + "+ W" + currentRow.ToString() + "+ X" + currentRow.ToString();
                                }
                            }
                            else if (j == 30)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "O" + currentRow.ToString() + "+ AA" + currentRow.ToString();
                                }
                            }
                            else if (j == 31)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "AB" + currentRow.ToString() + "+ AC" + currentRow.ToString() + "+ AD" + currentRow.ToString() + "+ AE" + currentRow.ToString();
                                }
                            }
                            else if (j == 32)
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    int currentRow = k + rows + 1;
                                    ws.Cells[k + rows, j + 1].Formula = "AF" + currentRow.ToString() + "+AG" + currentRow.ToString();
                                }
                            }
                            else
                            {
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                                }
                            }

                            int firstRows = rows + 1;
                            int LastRows = rows + dt.Rows.Count;

                            ws.Cells.Merge(LastRows, 0, 1, 3);

                            displayStyle = ws.Cells[rows, 0].GetDisplayStyle();
                            displayStyle.HorizontalAlignment = TextAlignmentType.Center;
                            ws.Cells[LastRows, 0].SetStyle(displayStyle);
                            ws.Cells.SetRowHeight(LastRows, 40);//设置行高
                            ws.Cells[LastRows, 0].PutValue("合计");
                            ws.Cells[LastRows, 3].Formula = "SUM(D" + firstRows + ":D" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 4].Formula = "SUM(E" + firstRows + ":E" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 5].Formula = "SUM(F" + firstRows + ":F" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 6].Formula = "SUM(G" + firstRows + ":G" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 7].Formula = "SUM(H" + firstRows + ":H" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 8].Formula = "SUM(I" + firstRows + ":I" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 9].Formula = "SUM(J" + firstRows + ":J" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 10].Formula = "SUM(K" + firstRows + ":K" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 11].Formula = "SUM(L" + firstRows + ":L" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 12].Formula = "SUM(M" + firstRows + ":M" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 13].Formula = "SUM(N" + firstRows + ":N" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 14].Formula = "SUM(O" + firstRows + ":O" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 15].Formula = "SUM(P" + firstRows + ":P" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 16].Formula = "SUM(Q" + firstRows + ":Q" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 17].Formula = "SUM(R" + firstRows + ":R" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 18].Formula = "SUM(S" + firstRows + ":S" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 19].Formula = "SUM(T" + firstRows + ":T" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 20].Formula = "SUM(U" + firstRows + ":U" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 21].Formula = "SUM(V" + firstRows + ":V" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 22].Formula = "SUM(W" + firstRows + ":W" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 23].Formula = "SUM(X" + firstRows + ":X" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 24].Formula = "SUM(Y" + firstRows + ":Y" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 25].Formula = "SUM(Z" + firstRows + ":Z" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 26].Formula = "SUM(AA" + firstRows + ":AA" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 27].Formula = "SUM(AB" + firstRows + ":AB" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 28].Formula = "SUM(AC" + firstRows + ":AC" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 29].Formula = "SUM(AD" + firstRows + ":AD" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 30].Formula = "SUM(AE" + firstRows + ":AE" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 31].Formula = "SUM(AF" + firstRows + ":AF" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 32].Formula = "SUM(AG" + firstRows + ":AG" + LastRows.ToString() + ")";
                            ws.Cells[LastRows, 33].Formula = "SUM(AH" + firstRows + ":AH" + LastRows.ToString() + ")";
                        }
                    }
                    else
                    {
                        for (int j = 0; j < dt.Columns.Count; j++)
                        {
                            if (j == 0)
                            {
                                displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                                Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                                range1.ApplyStyle(displayStyle, styleFlag);
                                for (int k = 0; k < dt.Rows.Count; k++)
                                {
                                    ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                    ws.Cells.SetRowHeight(k + rows, height);
                                }
                            }

                            displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                            Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                            range.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                            }

                        }

                    }
                }
            }


            wb.CalculateFormula(true);

            wb.Save(downloadFileUrl, SaveFormat.Excel97To2003);
        }


        public void ExportReportNew(DataSet ds, string fileUrl, string downloadFileUrl)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];

                // ws.Name = dt.TableName;

                int rows = ws.Cells.MaxDataRow + 1;

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (j == 0)
                        {
                            displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                            Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                            range1.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                ws.Cells.SetRowHeight(k + rows, height);
                            }
                        }

                        displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                        Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                        range.ApplyStyle(displayStyle, styleFlag);
                        for (int k = 0; k < dt.Rows.Count; k++)
                        {
                            ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                        }

                    }
                }
            }

            wb.CalculateFormula(true);

            wb.Save(downloadFileUrl, SaveFormat.Excel97To2003);
        }


        public void ExportAccountPerformanceReportNew(DataSet ds, string fileUrl, string downloadFileUrl)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];

                // ws.Name = dt.TableName;

                int rows = ws.Cells.MaxDataRow + 1;

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (j == 0)
                        {
                            displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                            Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                            range1.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                ws.Cells.SetRowHeight(k + rows, height);
                            }
                        }

                        //if (i == 1 && j == 10)
                        //{
                        //    for (int k = 0; k < dt.Rows.Count; k++)
                        //    {
                        //        displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                        //        Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                        //        range.ApplyStyle(displayStyle, styleFlag);
                        //        int current = k + rows + 1;
                        //        ws.Cells[k + rows, j + 1].Formula = "=COUNTIF(I:I,I" + current + " )";
                        //    }
                        //}
                        //else
                        //{

                        displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                        Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                        range.ApplyStyle(displayStyle, styleFlag);
                        for (int k = 0; k < dt.Rows.Count; k++)
                        {
                            ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                        }
                        // }

                    }
                }
            }

            wb.CalculateFormula(true);
            wb.Save(downloadFileUrl, SaveFormat.Excel97To2003);
        }

        public DataTable getStatementServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getStatementServicePayDetail(companyId, branchId, beginDay, endDay);
        }

        public DataTable getStatementTreatmentDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getStatementTreatmentDetail(companyId, branchId, beginDay, endDay);
        }

        public DataTable getStatementCommodityDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getStatementCommodityDetail(companyId, branchId, beginDay, endDay);
        }


        public DataTable getBranchStatementServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getBranchStatementServicePayDetail(companyId, branchId, beginDay, endDay);
        }


        public DataTable getBranchStatementCommodityDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getBranchStatementCommodityDetail(companyId, branchId, beginDay, endDay);
        }

        public DataTable getCardInfo(int CompanyID, int BranchID)
        {
            return ReportDownload_DAL.Instance.getCardInfo(CompanyID, BranchID);
        }



        public DataTable getCardInfoDetail(int CompanyID, int BranchID)
        {
            return ReportDownload_DAL.Instance.getCardInfoDetail(CompanyID, BranchID);
        }

        public DataTable getAttendanceInfo(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getAttendanceInfo(CompanyID, BranchID, beginDay, endDay);
        }

        public void ExportReportCustomer(DataSet ds, string fileUrl, string downloadFileUrl, int branchId)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];

                // ws.Name = dt.TableName;

                int rows = ws.Cells.MaxDataRow + 1;

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (j == 19)
                        {
                            continue;
                        }

                        if (j == 0)
                        {
                            displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                            Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                            range1.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                ws.Cells.SetRowHeight(k + rows, height);
                            }
                        }

                        displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                        Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                        range.ApplyStyle(displayStyle, styleFlag);

                        for (int k = 0; k < dt.Rows.Count; k++)
                        {
                            ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                            if (j == 18 && branchId > 0)
                            {
                                if (StringUtils.GetDbInt(dt.Rows[k]["IsRed"]) == 1)
                                {
                                    displayStyle.ForegroundColor = Color.Red;
                                    ws.Cells[k + rows, j + 1].SetStyle(displayStyle);
                                }
                            }
                        }


                    }
                }
            }

            wb.CalculateFormula(true);

            wb.Save(downloadFileUrl, SaveFormat.Excel97To2003);
        }


        public DataTable getCommissionSales(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getCommissionSales(CompanyID, BranchID, beginDay, endDay);
        }


        public DataTable getCommissionOpt(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getCommissionOpt(CompanyID, BranchID, beginDay, endDay);
        }


        public DataTable getCommissionRecharge(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getCommissionRecharge(CompanyID, BranchID, beginDay, endDay);
        }


        public DataTable getSalaryInfo(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.getSalaryInfo(CompanyID, BranchID, beginDay, endDay);
        }


        public void ExportReportComm(DataSet ds, string fileUrl, string downloadFileUrl,string Title)
        {
            Aspose.Cells.Workbook wb = new Aspose.Cells.Workbook();
            wb.Open(fileUrl);
            for (int i = 0; i < ds.Tables.Count; i++)
            {
                Aspose.Cells.Worksheet ws = wb.Worksheets[i];

                // ws.Name = dt.TableName;

                int rows = 0;
                if (i == 0)
                {
                    rows = 3;
                    ws.Cells[0, 0].PutValue(Title);
                }
                else
                {
                    rows = ws.Cells.MaxDataRow + 1;
                }

                Aspose.Cells.Style displayStyle = wb.Styles[wb.Styles.Add()];
                Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
                styleFlag.All = true;

                double height = ws.Cells.Rows[rows].Height;

                DataTable dt = ds.Tables[i];
                if (dt != null && dt.Rows.Count > 0)
                {
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        if (j == 0)
                        {
                            displayStyle = ws.Cells[rows, j].GetDisplayStyle();
                            Range range1 = ws.Cells.CreateRange(rows, j, dt.Rows.Count, 1);
                            range1.ApplyStyle(displayStyle, styleFlag);
                            for (int k = 0; k < dt.Rows.Count; k++)
                            {
                                ws.Cells[k + rows, j].Formula = "ROW() -  " + rows.ToString();
                                ws.Cells.SetRowHeight(k + rows, height);
                            }
                        }

                        displayStyle = ws.Cells[rows, j + 1].GetDisplayStyle();
                        Range range = ws.Cells.CreateRange(rows, j + 1, dt.Rows.Count, 1);
                        range.ApplyStyle(displayStyle, styleFlag);
                        for (int k = 0; k < dt.Rows.Count; k++)
                        {
                            ws.Cells[k + rows, j + 1].PutValue(dt.Rows[k][j]);
                        }

                    }
                }
            }

            wb.CalculateFormula(true);

            wb.Save(downloadFileUrl, SaveFormat.Excel97To2003);
        }




        public DataTable getCustomerRelation(int CompanyID, int BranchID)
        {
            return ReportDownload_DAL.Instance.getCustomerRelation(CompanyID, BranchID);
        }

        public DataTable GetServiceRate(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.GetServiceRate(companyId, branchId, beginDay, endDay);
        }

        public DataTable GetInputOrderReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.GetInputOrderReport(companyId, branchId, beginDay, endDay);
        }

        public DataTable GetRechargeReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            return ReportDownload_DAL.Instance.GetRechargeReport(companyId, branchId, beginDay, endDay);
        }
    }
}
