using BLToolkit.Data;
using HS.Framework.Common;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Commodity_DAL
    {
        #region 构造类实例
        public static Commodity_DAL Instance
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
            internal static readonly Commodity_DAL instance = new Commodity_DAL();
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
            recordCount = 0;
            List<GetProductList_Model> list = new List<GetProductList_Model>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.ID ) AS rowNum , T1.Code AS ProductCode, T1.CommodityName as ProductName , " + string.Format(WebAPI.Common.Const.getCommodityImg, "T3.CommodityCode", "T3.FileName", height, width);
                    string strSql = " SELECT {0} FROM [COMMODITY] T1 {1} WHERE  T1.ID IN (SELECT MAX(T2.ID) FROM [COMMODITY] T2 WHERE T2.Available = 1 AND T2.CompanyID =@CompanyID {2} GROUP BY T2.Code ) ";
                    string strLike = "";
                    if (strSearch != "" && strSearch != null)
                    {
                        strLike = " and T2.CommodityName like '%" + strSearch + "%' ";
                    }
                    string strJoin = " LEFT JOIN [IMAGE_COMMODITY] T3 ON T3.CommodityID = T1.ID AND T3.ImageType = 0 ";

                    string strCountSql = string.Format(strSql, " count(0) ", "", strLike);
                    string strgetListSql = "select * from( " + string.Format(strSql, fileds, strJoin, strLike) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

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
        /// 商品详细
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public GetCommodityDetail_Model getCommodityDetail(int companyID, long commodityCode, int height, int width)
        {
            GetCommodityDetail_Model model = new GetCommodityDetail_Model();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = @" select T1.ID AS CommodityID,T1.Code as CommodityCode ,T1.CommodityName,T1.UnitPrice,T1.PromotionPrice,T1.Describe,T1.SerialNumber,T1.Specification,T1.New,T1.Recommended,{0}
                                    from [COMMODITY] T1 
                                    LEFT JOIN [IMAGE_COMMODITY] T3 ON T3.CommodityID = T1.ID AND T3.ImageType = 0 
                                    WHERE T1.ID = (
                                    SELECT MAX(T2.ID) 
                                    FROM [COMMODITY] T2 
                                    WHERE T2.CompanyID = @CompanyID and T2.Code =@CommodityCode and T2.Available = 1 ) ";

                    string strSqlFinal = string.Format(strSql, string.Format(WebAPI.Common.Const.getCommodityImg, "T3.CommodityCode", "T3.FileName", height, width));
                    model = db.SetCommand(strSqlFinal, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@CommodityCode", commodityCode, DbType.Int64)).ExecuteObject<GetCommodityDetail_Model>();
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
        /// 商品图片
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="hight"></param>
        /// <param name="width"></param>
        /// <returns></returns>
        public List<string> getCommodityImgList(int companyID, int commodityID, int height, int width)
        {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strImg = string.Format(WebAPI.Common.Const.getCommodityImg, "T1.CommodityCode", "T1.FileName", height, width);
                    string strSql = " SELECT " + strImg + " FROM [IMAGE_COMMODITY] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.CommodityID=@CommodityID AND T1.ImageType = 1 ";
                    list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@CommodityID", commodityID, DbType.Int32)).ExecuteScalarList<string>();
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
        /// 获取商浏览历史列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<GetProductList_Model> getCommodityBrowseHistoryList(int companyID, string strCommodityCodes, int height, int width)
        {
            List<GetProductList_Model> list = new List<GetProductList_Model>();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = " SELECT T1.Code AS ProductCode, T1.CommodityName AS ProductName ,";
                    strSql += string.Format(WebAPI.Common.Const.getCommodityImg, "T3.CommodityCode", "T3.FileName", height, width);
                    strSql += @" FROM [COMMODITY] T1 
                                LEFT JOIN [IMAGE_COMMODITY] T3 
                                ON T3.CommodityID = T1.ID AND T3.ImageType = 0 
                                WHERE  T1.ID IN (
                                SELECT MAX(T2.ID) FROM [COMMODITY] T2 WHERE T2.Available = 1 AND T2.CompanyID =@CompanyID AND T2.Code in (";
                    strSql += strCommodityCodes;
                    strSql += " ) GROUP BY T2.Code )  ";

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
