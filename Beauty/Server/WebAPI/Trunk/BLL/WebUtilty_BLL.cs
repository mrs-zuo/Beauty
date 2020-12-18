using Aspose.Cells;
using HS.Framework.Common.Util;
using Model.Table_Model;
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
    public class WebUtilty_BLL
    {
        #region 构造类实例
        public static WebUtilty_BLL Instance
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
            internal static readonly WebUtilty_BLL instance = new WebUtilty_BLL();
        }
        #endregion

        public bool batchImport(string filename, int addType, int branchID, int userID, int companyId)
        {
            string filePath = Const.uploadServer + "/" + Const.strImage + "temp/batchImport/" + filename;
            if (File.Exists(filePath))
            {
                Workbook workbook = new Workbook(filePath);
                Worksheet worksheet = workbook.Worksheets[0];
                Cells cells = worksheet.Cells;
                DataTable dt = new DataTable();

                dt = worksheet.Cells.ExportDataTable(0, 0, worksheet.Cells.MaxDataRow + 1, worksheet.Cells.MaxDataColumn + 1);

                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    dt.Columns[i].ColumnName = dt.Rows[0][i].ToString();
                }

                if (addType == 1)
                {
                    dt = dtNormalizing(dt, Const.EXPORT_COMMODITYNAMEEXCHANGE);
                }
                else
                {
                    dt = dtNormalizing(dt, Const.EXPORT_SERVICENAMEEXCHANGE);
                    dt.Columns.Add("SubserviceCodes");
                }

                //Dictionary<int, string> dcCategoryName = new Dictionary<int, string>();
                //Dictionary<int, string> dcDiscountName = new Dictionary<int, string>();
                //List<string> nameList = new List<string>();
                //List<string> discountNameList = new List<string>();
                //List<string> subServiceNameList = new List<string>();

                //Service_BLL serviBll = new Service_BLL();
                //for (int i = 1; i < dt.Rows.Count; i++)
                //{
                //    if (String.IsNullOrWhiteSpace(dt.Rows[i]["CategoryName"].ToString()))
                //    {
                //        return false;
                //    }
                //    else
                //    {
                //        // 插入数组
                //        nameList.Add(dt.Rows[i]["CategoryName"].ToString());
                //    }

                //    if (!String.IsNullOrWhiteSpace(dt.Rows[i]["DiscountName"].ToString()) && dt.Rows[i]["DiscountName"].ToString() != "无")
                //    {
                //        // 插入数组
                //        discountNameList.Add(dt.Rows[i]["DiscountName"].ToString());
                //    }

                //    if (addType == 0)
                //    {
                //        if (!String.IsNullOrWhiteSpace(dt.Rows[i]["SubserviceName"].ToString()))
                //        {
                //            // 插入数组
                //            string[] subServiceNames = (dt.Rows[i]["SubserviceName"].ToString() + "|").Split('|');
                //            string strSubserviceCodes = "|";
                //            for (int j = 0; j < subServiceNames.Length; j++)
                //            {
                //                if (!String.IsNullOrEmpty(subServiceNames[j]))
                //                {
                //                    int res = serviBll.getSubserviceCodeByName(companyId, subServiceNames[j]);
                //                    if (res > 0)
                //                    {
                //                        strSubserviceCodes += res + "|";
                //                    }
                //                }
                //            }

                //            if (strSubserviceCodes != "|")
                //            {
                //                dt.Rows[i]["SubServiceCodes"] = strSubserviceCodes;
                //            }

                //        }

                //    }

                //}
                //// 获取分类去除重复项
                //nameList = nameList.Distinct().ToList<string>();
                //discountNameList = discountNameList.Distinct().ToList<string>();
                ////subServiceNameList = subServiceNameList.Distinct().ToList<string>();

                //if (nameList == null || nameList.Count < 1)
                //{
                //    return false;
                //}
                //else
                //{
                //    #region 在数据库中查询类别ID,加入字典
                //    Category_BLL cateBll = new Category_BLL();

                //    foreach (var item in nameList)
                //    {
                //        if (item != "无所属")
                //        {
                //            int res = cateBll.getCategoryIdByName(companyId, item, Convert.ToInt32(addType));
                //            if (res < 1)
                //            {
                //                // 数据库中查不到该类名
                //                return false;
                //            }
                //            else
                //            {
                //                // 查询成功加入字典
                //                dcCategoryName.Add(res, item);
                //            }
                //        }
                //    }
                //    dcCategoryName.Add(0, "无所属");
                //    #endregion
                //}


                //Level_BLL levelBll = new Level_BLL();
                //foreach (var item in discountNameList)
                //{
                //    if (item != "无")
                //    {
                //        int res = levelBll.getDiscountIDByName(companyId, item);
                //        if (res < 1)
                //        {
                //            // 数据库中查不到该类名
                //            return false;
                //        }
                //        else
                //        {
                //            // 查询成功加入字典
                //            dcDiscountName.Add(res, item);
                //        }
                //    }
                //}
                //dcDiscountName.Add(0, "无");

                if (addType == 1)
                {
                    Commodity_Model mCommodity = new Commodity_Model();
                    mCommodity.CompanyID = companyId;
                    mCommodity.BranchID = branchID;
                    mCommodity.CreatorID = userID;
                    mCommodity.CreateTime = DateTime.Now.ToLocalTime();

                    bool res = Commodity_DAL.Instance.BatchAddCommodity(dt, mCommodity);

                    return res;
                }
                else
                {

                    Service_Model mService = new Service_Model();
                    mService.CompanyID = companyId;
                    mService.BranchID = branchID;
                    mService.CreatorID = userID;
                    mService.CreateTime = DateTime.Now.ToLocalTime();

                    bool res = Service_DAL.Instance.BatchAddService(dt, mService);

                    return res;
                }
            }
            else
            {
                return false;
            }
        }

        public bool batchImportCommodityBatch(string filename, int addType, int branchID, int userID, int companyId)
        {
            string filePath = Const.uploadServer + "/" + Const.strImage + "temp/batchImport/" + filename;
            //string filePath = "D:/temp/batchImport/" + filename;
            if (File.Exists(filePath))
            {
                Workbook workbook = new Workbook(filePath);
                Worksheet worksheet = workbook.Worksheets[0];
                Cells cells = worksheet.Cells;
                DataTable dt = new DataTable();

                dt = worksheet.Cells.ExportDataTable(0, 0, worksheet.Cells.MaxDataRow + 1, worksheet.Cells.MaxDataColumn + 1);

                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    dt.Columns[i].ColumnName = dt.Rows[0][i].ToString();
                }

                dt = dtNormalizing(dt, Const.EXPORT_COMMODITYBATCHINFO);

                Product_Stock_Batch_Model mProductStockBatch = new Product_Stock_Batch_Model();
                mProductStockBatch.CompanyID = companyId;
                mProductStockBatch.BranchID = branchID;
                mProductStockBatch.OperatorID = userID;
                mProductStockBatch.OperateTime = DateTime.Now.ToLocalTime();

                bool res = Commodity_DAL.Instance.BatchAddCommodityBatch(dt, mProductStockBatch);

                return res;
            }
            else
            {
                return false;
            }
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


    }
}
