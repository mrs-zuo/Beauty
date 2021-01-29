using HS.Framework.Common.Entity;
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
using HS.Framework.Common.Util;

namespace WebAPI.BLL
{
    public class Service_BLL
    {
        #region 构造类实例
        public static Service_BLL Instance
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
            internal static readonly Service_BLL instance = new Service_BLL();
        }
        #endregion

        /// <summary>
        /// 服务列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param> 
        /// <param name="recordCount"></param> 
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getServiceList(int companyID, int pageIndex, int pageSize, out int recordCount, int height, int width, string strSearch)
        {
            List<GetProductList_Model> list = Service_DAL.Instance.getServiceList(companyID, pageIndex, pageSize, out  recordCount, height, width, strSearch);
            return list;
        }

        /// <summary>
        /// 服务详细
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public GetServiceDetail_Model getServiceDetail(int companyID, long ServiceCode, int height, int width)
        {
            GetServiceDetail_Model model = Service_DAL.Instance.getServiceDetail(companyID, ServiceCode, height, width);
            return model;
        }


        /// <summary>
        /// 服务图片
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <param name="count"></param>
        /// <returns></returns>
        public List<string> getServiceImgList(int companyID, int serviceID, int height, int width, int count = 0)
        {
            List<string> list = Service_DAL.Instance.getServiceImgList(companyID, serviceID, height, width);
            if (count > 0 && list != null && list.Count > 0 && list.Count > count)
            {
                list = list.Take(count).ToList();
            }
            return list;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="serviceID"></param>
        /// <returns></returns>
        public List<string> getSubServiceName(int companyID, int serviceID)
        {
            return Service_DAL.Instance.getSubServiceName(companyID, serviceID);
        }
        /// <summary>
        /// 获取服务浏览历史列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getServiceBrowseHistoryList(int companyID, string strServiceCodes, int height, int width)
        {
            return Service_DAL.Instance.getServiceBrowseHistoryList(companyID, strServiceCodes, height, width);
        }

        /// <summary>
        /// 二维码获取服务信息
        /// </summary>
        /// <param name="companyCode"></param>
        /// <param name="code"></param>
        /// <returns></returns>
        public ObjectResult<ProductInFoByQRCode_Model> getServiceInfoByQRCode(string companyCode, int branchId, long code, int accountId)
        {
            return Service_DAL.Instance.getServiceInfoByQRCode(companyCode, branchId, code, accountId);
        }


        #region 手机端方法
        public ServiceDetail_Model getServiceDetailByServiceCode(UtilityOperation_Model utilityModel)
        {
            return Service_DAL.Instance.getServiceDetailByServiceCode(utilityModel);
        }

        public List<SubServiceInServiceDetail_Model> getSubServiceByCodes(string subServiceCodes)
        {
            string[] arr = subServiceCodes.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
            List<long> subServiceList = new List<long>();
            for (int i = 0; i < arr.Length; i++)
            {
                long templong = HS.Framework.Common.Util.StringUtils.GetDbLong(arr[i]);
                if (templong <= 0)
                {
                    return null;
                }
                subServiceList.Add(templong);
            }

            return Service_DAL.Instance.getSubServiceByCodes(subServiceList);
        }


        public List<ServiceEnalbeInfoDetail_Model> getServiceEnalbleForCustomer(int customerId, long productCode)
        {
            return Service_DAL.Instance.getServiceEnalbleForCustomer(customerId, productCode);
        }

        public List<GetSeriviceList_Model> getServiceListByCompanyId(int companyId, bool isBusiness, int branchId, int accountId, int customerId, int imageHeight, int imageWidth)
        {
            return Service_DAL.Instance.getServiceListByCompanyId(companyId, isBusiness, branchId, accountId, customerId, imageHeight, imageWidth);
        }

        public List<GetSeriviceList_Model> getServiceListByCategoryId(UtilityOperation_Model model)
        {
            List<GetSeriviceList_Model> list = Service_DAL.Instance.getServiceListByCategoryId(model.CategoryID, model.IsBusiness, model.BranchID, model.AccountID, model.CustomerID, true);
            if (list != null && list.Count > 0)
            {
                foreach (GetSeriviceList_Model item in list)
                {
                    List<string> listImage = Image_BLL.Instance.getServiceImage(item.ServiceID, 0, model.ImageWidth, model.ImageHeight);
                    if (listImage != null && listImage.Count > 0)
                    {
                        item.ThumbnailURL = listImage[0];
                    }
                }
            }
            return list;


        }
        #endregion

        public List<Service_Model> getServiceListForWeb(int companyId, int categoryId, int imageWidth, int imageHeight, int branchId)
        {
            List<Service_Model> list = Service_DAL.Instance.getServiceListForWeb(companyId, categoryId, imageWidth, imageHeight, branchId);
            return list;
        }

        public Service_Model getServiceDetailForWeb(int companyID, long serviceCode,int branchId)
        {
            Service_Model model = Service_DAL.Instance.getServiceDetailForWeb(companyID, serviceCode,branchId);
            return model;
        }

        public List<ServiceBranch> getServiceBranchListForWeb(int companyID, long serviceCode,int branchID)
        {
            List<ServiceBranch> list = Service_DAL.Instance.getServiceBranchListForWeb(companyID, serviceCode, branchID);
            return list;
        }

        public List<ImageCommon_Model> getImgList(int companyID, int serviceID)
        {
            List<ImageCommon_Model> list = Service_DAL.Instance.getImgList(companyID, serviceID);
            return list;
        }

        public int getSubserviceCodeByName(int companyId, string subserviceName)
        {
            return Service_DAL.Instance.getSubserviceCodeByName(companyId, subserviceName);
        }

        public string downloadServiceList(UtilityOperation_Model model)
        {
            string strRes = "";
            DataTable dt = Service_DAL.Instance.getServiceListForDownload(model.CompanyID, model.CategoryID, model.BranchID);
            if (dt == null && dt.Rows.Count == 0)
                return strRes;

            dt.Columns.Add("RelativePath");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataTable dtImage = Image_DAL.Instance.getServiceImageForExport(Convert.ToInt32(dt.Rows[i]["ServiceID"]));
                StringBuilder sb = new StringBuilder();
                if (dtImage != null)
                {
                    for (int j = 0; j < dtImage.Rows.Count; j++)
                    {
                         // if (File.Exists(AppDomain.CurrentDomain.BaseDirectory + dtImage.Rows[j]["FileUrl"].ToString()))
                            sb.Append(dtImage.Rows[j]["FileUrl"].ToString() + "," + (Convert.ToBoolean(dtImage.Rows[j]["ImageType"]) ? "1" : "0") + "|");
                    }
                }
                dt.Rows[i]["RelativePath"] = sb.ToString();
            }
            //dt.Columns.Remove("ServiceID");

            dt = dtNormalizing(dt, Const.EXPORT_SERVICENAMEEXCHANGE);


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
                cellSheet.Cells[rowIndex, colIndex].PutValue(dt.Columns[i].ColumnName);
                cellSheet.Cells[rowIndex, colIndex].SetStyle(ss);
                colIndex++;
            }

            Aspose.Cells.Style style = workbook.Styles[workbook.Styles.Add()];
            style.Font.Name = "Arial";
            style.Font.Size = 10;
            Aspose.Cells.StyleFlag styleFlag = new Aspose.Cells.StyleFlag();
            cellSheet.Cells.ApplyStyle(style, styleFlag);

            rowIndex++;
            #region 服务
            for (int i = 0; i < rowCount; i++)
            {
                colIndex = 0;
                for (int j = 0; j < colCount; j++)
                {
                    if (dt.Columns[j].ColumnName == "确认方式")
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

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string fileName = "服务_" + DateTime.Now.ToString("yyyyMMdd") + "_" + DateTime.Now.Ticks + ".xls";
            workbook.Save(path + fileName);
            //string url = Const.strFileHttp + Const.server + "/getFile.aspx?fn=temp/product/" + fileName;
            string url = Const.strFileHttp + Const.server + "/report/" + fileName;
            return url;
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

        public bool deteleMultiService(DelMultiCommodity_Model model)
        {
            return Service_DAL.Instance.deteleMultiService(model);
        }
        public int getCountbyServiceName(int companyID, int serviceID, string serviceName)
        {
            return Service_DAL.Instance.getCountbyServiceName(companyID, serviceID, serviceName);
        }
        public List<Service_Model> getPrintList(List<long> codeList)
        {
            List<Service_Model> list = Service_DAL.Instance.getPrintList(codeList);
            if (list != null && list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    list[i].QRcodeUrl = "http://" + Const.server + "/GetQRcode.aspx?size=3&content=" + "http://" + Const.server + "/a.aspx?id=" + list[i].CompanyCode + "^" + "002" + "^" + string.Format("{0:D10}",list[i].ServiceCode);
                }
            }
            return list;
        }

        public int addService(ServiceDetailOperation_Model mService,out long serviceCode)
        {
            return Service_DAL.Instance.addService(mService,out serviceCode);
        }

        public int updateService(ServiceDetailOperation_Model mService)
        {
            return Service_DAL.Instance.updateService(mService);
        }

        public bool UpdateServiceSort(int companyID, string strSort)
        {
            if (!string.IsNullOrWhiteSpace(strSort))
            {
                List<ServiceSort_Model> list = new List<ServiceSort_Model>();
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
                        ServiceSort_Model model = new ServiceSort_Model();
                        model.ServiceCode = HS.Framework.Common.Util.StringUtils.GetDbLong(arrCode[i]);
                        model.Sortid = HS.Framework.Common.Util.StringUtils.GetDbInt(arrSortid[i]);
                        list.Add(model);
                    }
                }

                bool res = Service_DAL.Instance.UpdateServiceSort(companyID, list);
                return res;
            }
            return false;
        }


        public List<SubService_Model> getSubServiceList(int companyId)
        {
            return Service_DAL.Instance.getSubServiceList(companyId);
        }

        public bool OperationServiceBranch(ServiceDetailOperation_Model mService) {
            return Service_DAL.Instance.OperationServiceBranch(mService);
        }

        public bool exsitSubserviceCode(int companyId, long subserviceCode)
        {
            return Service_DAL.Instance.exsitSubserviceCode(companyId, subserviceCode);
        }
    }
}
