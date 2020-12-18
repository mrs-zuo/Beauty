using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HS.Framework.Common;
using Model.View_Model;
using BLToolkit.Data;
using System.Data;
using Model.Operation_Model;

namespace WebAPI.DAL
{
    public class Service_DAL
    {
        #region 构造类实例
        public static Service_DAL Instance
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
            internal static readonly Service_DAL instance = new Service_DAL();
        }
        #endregion



        /// <summary>
        /// 获取服务列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getServiceList(int companyID, int pageIndex, int pageSize, out int recordCount, int height, int width,string strSearch)
        {
            recordCount = 0;
            List<GetProductList_Model> list = new List<GetProductList_Model>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.ID ) AS rowNum , T1.Code AS ProductCode, T1.ServiceName AS ProductName , " + string.Format(WebAPI.Common.Const.getServiceImg, "T3.ServiceCode", "T3.FileName", height, width);
                    string strSql = " SELECT {0} FROM [SERVICE] T1 {1} WHERE  T1.ID IN (SELECT MAX(T2.ID) FROM [SERVICE] T2 WHERE T2.Available = 1 AND T2.CompanyID =@CompanyID {2} GROUP BY T2.Code ) ";
                    string strJoin = " LEFT JOIN [IMAGE_SERVICE] T3 ON T3.ServiceID = T1.ID AND T3.ImageType = 0 ";
                    string strLike = "";
                    if (strSearch != "" && strSearch != null)
                    {
                        strLike = " and T2.ServiceName like '%" + strSearch + "%' ";
                    }
                    string strCountSql = string.Format(strSql, " count(0) ", "", strLike);
                   
                    string strgetListSql = "select * from( " + string.Format(strSql, fileds, strJoin,strLike) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                    recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetProductList_Model>();
                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }

        /// <summary>
        /// 服务详细
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public GetServiceDetail_Model getServiceDetail(int companyID, long ServiceCode, int height, int width)
        {
            GetServiceDetail_Model model = new GetServiceDetail_Model();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = @" select T1.ID AS ServiceID,T1.Code as ServiceCode ,T1.ServiceName,T1.UnitPrice,T1.PromotionPrice,T1.Describe,T1.SerialNumber,T1.CourseFrequency,T1.SpendTime,{0}
                                    from [SERVICE] T1 
                                    LEFT JOIN [IMAGE_SERVICE] T3 ON T3.ServiceID = T1.ID AND T3.ImageType = 0 
                                    WHERE T1.ID = (
                                    SELECT MAX(T2.ID) 
                                    FROM [SERVICE] T2 
                                    WHERE T2.CompanyID = @CompanyID and T2.Code =@ServiceCode and T2.Available = 1 ) ";

                    string strSqlFinal = string.Format(strSql, string.Format(WebAPI.Common.Const.getServiceImg, "T3.ServiceCode", "T3.FileName", height, width));
                    model = db.SetCommand(strSqlFinal, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@ServiceCode", ServiceCode, DbType.Int64)).ExecuteObject<GetServiceDetail_Model>();
                    return model;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }
        /// <summary>
        /// 服务图片
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <returns></returns>
        public List<string> getServiceImgList(int companyID, int serviceID, int height, int width)
        {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strImg = string.Format(WebAPI.Common.Const.getServiceImg, "T1.ServiceCode", "T1.FileName", height, width);
                    string strSql = " SELECT " + strImg + " FROM [IMAGE_SERVICE] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.ServiceID=@ServiceID AND T1.ImageType = 1 ";
                    list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@ServiceID", serviceID, DbType.Int32)).ExecuteScalarList<string>();
                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="serviceID"></param>
        /// <returns></returns>
        public List<string> getSubServiceName(int companyID, int serviceID) {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = " select SubServiceCodes from [SERVICE] where CompanyID =@CompanyID and ID=@ServiceID ";
                    string subServiceCodes = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@ServiceID", serviceID, DbType.Int32)).ExecuteScalar<string>();
                    if (subServiceCodes == null || subServiceCodes == "") {
                        return list;
                    }

                    string[] temp = subServiceCodes.Split(new[] { "|" }, StringSplitOptions.RemoveEmptyEntries);

                    string strWhere = "";
                    foreach (string item in temp)
                    {
                        if (strWhere != "") {
                            strWhere += " , ";
                        }
                        strWhere += item;
                    }

                    if (strWhere == "") {
                        return list;
                    }
                    string strSqlSubserviceName = @" select SubServiceName 
                                                    from [TBL_SUBSERVICE] 
                                                    where ID in (
                                                    select MAX(ID) 
                                                    from TBL_SUBSERVICE 
                                                    where SubServiceCode in ({0}) group by SubServiceCode )";
                    string strSqlFinal = string.Format(strSqlSubserviceName,strWhere);

                    list = db.SetCommand(strSqlFinal).ExecuteScalarList<string>();

                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
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
            List<GetProductList_Model> list = new List<GetProductList_Model>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = " SELECT T1.Code AS ProductCode, T1.ServiceName AS ProductName ,";
                    strSql += string.Format(WebAPI.Common.Const.getServiceImg, "T3.ServiceCode", "T3.FileName", height , width);
                    strSql += @" FROM [SERVICE] T1 
                                LEFT JOIN [IMAGE_SERVICE] T3 
                                ON T3.ServiceID = T1.ID AND T3.ImageType = 0 
                                WHERE  T1.ID IN (
                                SELECT MAX(T2.ID) FROM [SERVICE] T2 WHERE T2.Available = 1 AND T2.CompanyID =@CompanyID AND T2.Code in (";
                    strSql += strServiceCodes;
                    strSql +=  " ) GROUP BY T2.Code )  ";

                    list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetProductList_Model>();
                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }
    }
}
