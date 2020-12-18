using BLToolkit.Data;
using HS.Framework.Common;
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
                string strImg = string.Format(WebAPI.Common.Const.getCommodityImg, "T1.CommodityCode", "T1.FileName", height, width);
                string strSql = " SELECT " + strImg + " FROM [IMAGE_COMMODITY] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.CommodityID=@CommodityID AND T1.ImageType = 1 ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@CommodityID", commodityID, DbType.Int32)).ExecuteScalarList<string>();
                return list;
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
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyCode"></param>
        /// <param name="branchId"></param>
        /// <param name="code"></param>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public ObjectResult<ProductInFoByQRCode_Model> getCommodityInfoByQRCode(string companyCode, int branchId, long code, int accountId)
        {
            ObjectResult<ProductInFoByQRCode_Model> result = new ObjectResult<ProductInFoByQRCode_Model>();
            result.Code = "-2";
            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"SELECT T1.Code,T1.ID,1 Type,t1.CommodityName Name
                                             ,T1.UnitPrice,t1.PromotionPrice,t1.MarketingPolicy
                                             FROM Commodity T1
                                             INNER JOIN dbo.TBL_MARKET_RELATIONSHIP t4 ON t4.Type=1 AND t4.Code=t1.Code 
                                             INNER JOIN COMPANY T2
                                             ON T1.CompanyID = T2.ID
                                             INNER JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T3 ON  T3.CompanyID = T2.ID and T3.UserID = @AccountID
                                             WHERE T1.Code =@CommodityCode
                                             AND T1.Available = 1
                                             AND T2.CompanyCode = @CompanyCode 
                                             --总店的美容师 或 与服务同在一分店下的美容师可以看到
                                             AND T3.BranchID = @BranchID
                                             AND T2.Available = 1";

                ProductInFoByQRCode_Model model = new ProductInFoByQRCode_Model();
                db.SetCommand(strSqlCommand, db.Parameter("@CommodityCode", code, DbType.Int64),
                db.Parameter("@BranchID", branchId, DbType.Int32),
                db.Parameter("@CompanyCode", companyCode, DbType.String),
                db.Parameter("@AccountID", accountId, DbType.Int32)).ExecuteObject(model);

                if (model.ID != 0)
                {
                    result.Code = "1";
                    result.Data = model;
                }
                else
                {
                    result.Message = "二维码查看商品失败";
                }
            }
            return result;
        }

        /// <summary>
        /// 获取所有商品
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        // 2014.06.04 Aaron修改排序功能
        public List<CommodityList_Model> getCommodityListByCompanyId(int companyId, bool isBusiness, int branchId, int accountId, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                int levelId = 0;
                if (customerId > 0)
                {
                    string strSqlLevelId = @" select  T2.CardID from [CUSTOMER] T1 with (nolock)
                                       INNER JOIN [TBL_CUSTOMER_CARD] T2 with (nolock) ON T1.DefaultCardNo=T2.UserCardNo 
									   INNER JOIN [MST_CARD_BRANCH] T3 ON T2.CardID = T3.CardID AND T3.BranchID = @BranchID
                                        where T1.UserID =@UserID and T1.Available = 1  ";

                    Object obj = db.SetCommand(strSqlLevelId, db.Parameter("@UserID", customerId, DbType.Int32)
                           , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<Object>();

                    if (obj != null)
                    {
                        levelId = StringUtils.GetDbInt(obj);
                    }
                }

                StringBuilder strSql = new StringBuilder();
                strSql.Append(" SELECT DISTINCT  T1.Code CommodityCode,T1.ID CommodityID, T1.CommodityName, T1.MarketingPolicy ,T1.UnitPrice, CASE WHEN T1.MarketingPolicy = 2 THEN CASE WHEN @CardID = 0 THEN T1.UnitPrice ELSE T1.PromotionPrice END WHEN T1.MarketingPolicy = 1 THEN T1.UnitPrice * ISNULL( T8.Discount,1) END PromotionPrice, T1.New, T1.Recommended, T1.Specification,ISNULL(T4.ID,0) AS FavoriteID,ISNULL(T1.CommodityName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField ");

                strSql.Append(" ,T1.New,T1.Recommended,T3.Sortid ");
                strSql.Append(" FROM [COMMODITY] T1 WITH(NOLOCK) ");

                //顾客端 抽出所有与顾客相关的分店下的商品
                if (!isBusiness)
                {
                    strSql.Append(@" INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T5 ON T1.Code = T5.Code
                                                     AND T5.Available = 1
                                                     AND T5.Type = 1 ");
                }
                else
                {
                    //商家端 获取美丽顾问当前分店的商品(branchid>0)或公司所有服务(branchid=0)
                    if (branchId > 0)
                    {
                        strSql.Append(" INNER JOIN [TBL_MARKET_RELATIONSHIP] T5 WITH(NOLOCK) ");
                        strSql.Append(" on T1.Code = T5.Code ");
                        strSql.Append(" and T5.Type = 1");
                        strSql.Append(" and T5.Available = 1 ");
                        strSql.Append(" and T5.BranchID =@BranchID ");
                    }
                }
                strSql.Append(" LEFT JOIN [CATEGORY] T2 WITH(NOLOCK) ON T1.CategoryID = T2.ID ");
                strSql.Append(" LEFT JOIN [TBL_COMMODITYSORT] T3 WITH(NOLOCK) ON T1.Code = T3.CommodityCode");
                strSql.Append(" LEFT JOIN [TBL_FAVORITE] T4 WITH(NOLOCK) ON T1.Code=T4.Code AND T4.ProductType=1 AND T4.AccountID=@AccountID AND T4.BranchID=@BranchID ");
                strSql.Append("  LEFT JOIN  (select CardID,DiscountID,Discount from [TBL_CARD_DISCOUNT] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.CardID=@CardID AND T1.DiscountID = T8.DiscountID ");
                strSql.Append(" WHERE T1.CompanyID = @CompanyID and T1.Available = 1  and T1.ID in (SELECT MAX(ID) FROM COMMODITY GROUP BY code) AND (T2.Available = 1 OR ( T1.CategoryID IS NULL OR T1.CategoryID = -1 )) ");
                //strSql.Append(" WHERE T1.CompanyID = @CompanyID and T1.Available = 1 ");
                if (!isBusiness)
                {
                    //客户端
                    strSql.Append(" AND T1.VisibleForCustomer=1 ");
                    strSql.Append(" AND (T2.Available = 1 or T1.CategoryID is NULL)");
                    strSql.Append(@" AND T5.BranchID IN(SELECT BranchID FROM dbo.RELATIONSHIP
                                  WHERE CustomerID = @CustomerID AND Available = 1) ");
                }
                strSql.Append(" ORDER BY T1.New DESC ,T1.Recommended DESC ,T3.Sortid ");


                db.SetCommand(strSql.ToString(), db.Parameter("@AccountID", isBusiness ? accountId : 0, DbType.Int32)
                                               , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                               , db.Parameter("@BranchID", isBusiness ? branchId : 0, DbType.Int32)
                                               , db.Parameter("@CardID", levelId, DbType.Int32)
                                               , db.Parameter("@CustomerID", customerId, DbType.Int32));
                List<CommodityList_Model> list = db.ExecuteList<CommodityList_Model>();
                return list;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ObjectResult<List<ProductInfoList_Model>> getProductInfoList(ProductInfoListOperation_Model model)
        {
            ObjectResult<List<ProductInfoList_Model>> result = new ObjectResult<List<ProductInfoList_Model>>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            using (DbManager db = new DbManager())
            {

                List<ProductInfoList_Model> list = new List<ProductInfoList_Model>();

                //                string strCommodity = @"SELECT  T1.ID ,
                //                                                T1.Code ,
                //                                                1 AS ProductType ,
                //                                                1 AS CourseFrequency ,
                //                                                CommodityName Name ,
                //                                                CASE  WHEN T1.MarketingPolicy = 0 THEN UnitPrice
                //                                                     WHEN T1.MarketingPolicy = 1 AND ISNULL(T8.CardID,0) != 0  THEN CONVERT(DECIMAL(18, 2), ISNULL(T5.Discount, 1) * T1.UnitPrice, 2) 
                //                                                     WHEN T1.MarketingPolicy = 2 AND ISNULL(T8.CardID, 0) != 0 THEN T1.PromotionPrice
                //                                                     WHEN T1.MarketingPolicy = 2 AND ISNULL(T8.CardID, 0) = 0 THEN T1.UnitPrice
                //                                                     ELSE T1.UnitPrice
                //                                                END PromotionPrice ,
                //                                                UnitPrice ,
                //                                                MarketingPolicy ,
                //                                                '2099-12-31 23:59:59' AS ExpirationDate   ,T8.CardID,T8.CardName
                //                                        FROM    Commodity T1 WITH (NOLOCK)
                //										LEFT JOIN 
                //										( SELECT T4.Discount,T4.DiscountID FROM [CUSTOMER] T2 WITH(NOLOCK) 
                //                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) 
                //                                            ON T2.DefaultCardNo = T3.UserCardNo AND T2.UserID = T3.UserID	
                //											INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID AND T7.BranchID=@BranchID
                //                                            INNER JOIN [TBL_CARD_DISCOUNT] T4
                //                                            ON T3.CardID = T4.CardID
                //                                            WHERE T2.UserID =@CustomerID ) T5 ON T1.DiscountID = T5.DiscountID
                //                                                 LEFT JOIN (SELECT T1.ID AS CardID, T1.CardName,T2.UserID FROM [CUSTOMER] T2 WITH(NOLOCK) 
                //                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) 
                //                                            ON T2.DefaultCardNo = T3.UserCardNo AND T2.UserID = T3.UserID	
                //											INNER JOIN [MST_CARD] T1 ON T3.CardID = T1.ID
                //											INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID AND T7.BranchID=@BranchID
                //											  ) T8 ON T8.UserID = @CustomerID
                //                                            WHERE T1.Code IN ({0}) AND T1.Available=1 ";

                string strCommodity = @"SELECT  T1.ID ,
                                        T1.Code ,
                                        1 AS ProductType ,
                                        1 AS CourseFrequency ,
                                        CommodityName Name ,
                                        CASE WHEN T1.MarketingPolicy = 0 THEN UnitPrice
                                             WHEN T1.MarketingPolicy = 1 AND ISNULL(T5.CardID, 0) != 0 THEN CONVERT(DECIMAL(18, 2), dbo.sslr(ISNULL(T5.Discount, 1) * T1.UnitPrice, 2))
                                             WHEN T1.MarketingPolicy = 2 THEN T1.PromotionPrice
                                             ELSE T1.UnitPrice
                                        END PromotionPrice ,
                                        UnitPrice ,
                                        MarketingPolicy ,
                                        '2099-12-31 23:59:59' AS ExpirationDate ,
                                        T8.CardID ,
                                        T8.CardName ,ISNULL(T5.Discount, 1) Discount
                                FROM    Commodity T1 WITH ( NOLOCK )
                                        LEFT JOIN ( SELECT  T4.Discount ,T4.DiscountID ,T7.CardID ,T9.CardName
                                                    FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON T2.DefaultCardNo = T3.UserCardNo AND T2.UserID = T3.UserID
                                                            INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID AND T7.BranchID = @BranchID
                                                            INNER JOIN [TBL_CARD_DISCOUNT] T4 ON T3.CardID = T4.CardID
                                                            INNER JOIN [MST_CARD] T9 ON T3.CardID = T9.ID
                                                    WHERE   T2.UserID = @CustomerID
                                                  ) T5 ON T1.DiscountID = T5.DiscountID
                                        LEFT JOIN ( SELECT TOP 1 T1.ID AS CardID , T1.CardName , T2.UserID
                                                    FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON  T2.DefaultCardNo = T3.UserCardNo
                                                            INNER JOIN [MST_CARD] T1 ON T3.CardID = T1.ID
                                                            INNER JOIN [MST_CARD_BRANCH] T7 ON T1.ID = T7.CardID AND T7.BranchID = @BranchID
                                                    WHERE   T2.UserID = @CustomerID
                                                  ) T8 ON T8.UserID = @CustomerID
                                WHERE   T1.Code IN ({0}) AND T1.Available=1 ";


                //                string strService = @"SELECT T1.ID ,
                //                                                T1.Code ,
                //                                                0 AS ProductType ,
                //                                                ISNULL(T1.CourseFrequency,0) AS CourseFrequency ,
                //                                                ServiceName Name ,
                //                                                CASE  WHEN T1.MarketingPolicy = 0 THEN UnitPrice
                //                                                     WHEN T1.MarketingPolicy = 1 AND ISNULL(T8.CardID,0) != 0 THEN CONVERT(DECIMAL(18, 2), ISNULL(T5.Discount, 1) * T1.UnitPrice, 2)
                //                                                     WHEN T1.MarketingPolicy = 2 AND ISNULL(T8.CardID, 0) != 0 THEN T1.PromotionPrice
                //                                                     WHEN T1.MarketingPolicy = 2 AND ISNULL(T8.CardID, 0) = 0 THEN T1.UnitPrice
                //                                                     ELSE T1.UnitPrice
                //                                                END PromotionPrice ,
                //                                                UnitPrice ,
                //                                                MarketingPolicy ,
                //												CASE T1.HaveExpiration WHEN 0 THEN	 '2099-12-31'
                //ELSE
                //                                                DATEADD(d,ISNULL(T1.ExpirationDate,0),GETDATE()) END AS ExpirationDate  ,T8.CardID,T8.CardName 
                //                                        FROM    [SERVICE] T1 WITH (NOLOCK)
                //										LEFT JOIN 
                //										( SELECT T4.Discount,T4.DiscountID FROM [CUSTOMER] T2 WITH(NOLOCK) 
                //                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) 
                //                                            ON T2.DefaultCardNo = T3.UserCardNo AND T2.UserID = T3.UserID	
                //											INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID AND T7.BranchID=@BranchID
                //                                            INNER JOIN [TBL_CARD_DISCOUNT] T4
                //                                            ON T3.CardID = T4.CardID 
                //                                             WHERE T2.UserID =@CustomerID
                //                                            ) T5 ON T1.DiscountID = T5.DiscountID
                //                                               LEFT JOIN (SELECT T1.ID AS CardID, T1.CardName,T2.UserID FROM [CUSTOMER] T2 WITH(NOLOCK) 
                //                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) 
                //                                            ON T2.DefaultCardNo = T3.UserCardNo AND T2.UserID = T3.UserID	
                //											INNER JOIN [MST_CARD] T1 ON T3.CardID = T1.ID
                //											INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID AND T7.BranchID=@BranchID
                //											  ) T8 ON T8.UserID = @CustomerID
                //                                       WHERE T1.Code IN ({0}) AND T1.Available=1 ";

                string strService = @"SELECT  T1.ID ,
                                        T1.Code ,
                                        0 AS ProductType ,
                                        ISNULL(T1.CourseFrequency, 0) AS CourseFrequency ,
                                        ServiceName Name ,
                                        CASE WHEN T1.MarketingPolicy = 0 THEN UnitPrice
                                             WHEN T1.MarketingPolicy = 1 AND ISNULL(T5.CardID, 0) != 0 THEN CONVERT(DECIMAL(18, 2), dbo.sslr(ISNULL(T5.Discount, 1) * T1.UnitPrice, 2))
                                             WHEN T1.MarketingPolicy = 2 THEN T1.PromotionPrice
                                             ELSE T1.UnitPrice
                                        END PromotionPrice ,
                                        UnitPrice ,
                                        MarketingPolicy ,
                                        CASE T1.HaveExpiration
                                          WHEN 0 THEN '2099-12-31'
                                          ELSE DATEADD(d, ISNULL(T1.ExpirationDate, 0), GETDATE())
                                        END AS ExpirationDate ,
                                        T8.CardID ,
                                        T8.CardName 
                                FROM    [SERVICE] T1 WITH ( NOLOCK )
                                        LEFT JOIN ( SELECT  T4.Discount ,
                                                            T4.DiscountID ,
                                                            T7.CardID ,
                                                            T9.CardName
                                                    FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON T2.DefaultCardNo = T3.UserCardNo AND T2.UserID = T3.UserID 
                                                            INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID AND T7.BranchID = @BranchID 
                                                            INNER JOIN [TBL_CARD_DISCOUNT] T4 ON T3.CardID = T4.CardID 
                                                            INNER JOIN [MST_CARD] T9 ON T3.CardID = T9.ID 
                                                    WHERE   T2.UserID = @CustomerID 
                                                  ) T5 ON T1.DiscountID = T5.DiscountID 
                                        LEFT JOIN ( SELECT TOP 1
                                                            T1.ID AS CardID ,
                                                            T1.CardName ,
                                                            T2.UserID
                                                    FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON  T2.DefaultCardNo = T3.UserCardNo 
                                                            INNER JOIN [MST_CARD] T1 ON T3.CardID = T1.ID 
                                                            INNER JOIN [MST_CARD_BRANCH] T7 ON T1.ID = T7.CardID  AND T7.BranchID = @BranchID 
                                                    WHERE   T2.UserID = @CustomerID 
                                                  ) T8 ON T8.UserID = @CustomerID 
                                WHERE   T1.Code IN ( {0} ) AND T1.Available = 1 ";
                string sqlCommodityIds = "";
                string sqlServiceIds = "";


                #region 拼接Code
                for (int i = 0; i < model.ProductCode.Count; i++)
                {
                    if (model.ProductCode[i].ProductType == 0)
                    {
                        if (sqlServiceIds != "")
                        {
                            sqlServiceIds += "," + model.ProductCode[i].Code;
                        }
                        else
                        {
                            sqlServiceIds += model.ProductCode[i].Code;
                        }
                    }
                    else
                    {
                        if (sqlCommodityIds != "")
                        {
                            sqlCommodityIds += "," + model.ProductCode[i].Code;
                        }
                        else
                        {
                            sqlCommodityIds += model.ProductCode[i].Code;
                        }
                    }
                }
                #endregion
                if (sqlCommodityIds != "")
                {
                    strCommodity = string.Format(strCommodity, sqlCommodityIds, sqlCommodityIds);
                    list.AddRange(db.SetCommand(strCommodity, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<ProductInfoList_Model>());
                }

                if (sqlServiceIds != "")
                {
                    strService = string.Format(strService, sqlServiceIds, sqlServiceIds);
                    list.AddRange(db.SetCommand(strService, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                         , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<ProductInfoList_Model>());
                }

                result.Code = "1";
                result.Data = list;
            }
            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ObjectResult<CommodityDetail_Model> getCommodityDetailByCommodityCode(UtilityOperation_Model model)
        {
            ObjectResult<CommodityDetail_Model> res = new ObjectResult<CommodityDetail_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;
            using (DbManager db = new BLToolkit.Data.DbManager())
            {
                string strSql = "";
                CommodityDetail_Model resModel = new CommodityDetail_Model();
                if (!model.IsBusiness)
                {
                    strSql = @"SELECT TOP 1 a.ID CommodityID ,a.Code CommodityCode ,a.CommodityName ,a.Describe ,a.Specification ,a.MarketingPolicy ,a.UnitPrice ,SUM(b.ProductQty) StockQuantity ,a.PromotionPrice ,0 StockCalcType
                            FROM    [COMMODITY] a WITH ( NOLOCK )
                            LEFT JOIN [TBL_PRODUCT_STOCK] b WITH ( NOLOCK ) ON a.Code = b.ProductCode AND b.CompanyID = @CompanyID AND b.ProductType = 1
                            WHERE   a.Code = @Code AND a.Available = 1
                            GROUP BY a.ID, a.Code ,a.CommodityName ,a.Describe ,a.Specification ,a.MarketingPolicy ,a.UnitPrice ,a.PromotionPrice ,b.StockCalcType
                            ORDER BY a.ID DESC";

                    resModel = db.SetCommand(strSql, db.Parameter("@Code", model.ProductCode, DbType.Int64)
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteObject<CommodityDetail_Model>();

                    res.Code = "1";
                    res.Data = resModel;
                }
                else
                {
                    strSql = @"SELECT top 1  a.ID CommodityID,a.Code CommodityCode,a.CommodityName, a.Describe, a.Specification, a.MarketingPolicy ,a.UnitPrice,isnull(b.ProductQty,0) StockQuantity, a.PromotionPrice,b.StockCalcType 
                            FROM [COMMODITY] a with(nolock) 
                            Inner JOIN [TBL_PRODUCT_STOCK] b WITH(NOLOCK) ON a.Code=b.ProductCode AND b.CompanyID=@CompanyID AND b.BranchID=@BranchID AND b.ProductType=1 
                            INNER JOIN [TBL_MARKET_RELATIONSHIP] c WITH(NOLOCK) ON c.Code = a.Code AND c.CompanyID = @CompanyID AND c.BranchID = @BranchID AND c.[Type]=1 AND c.Available=1
                            WHERE a.Code =@Code and a.Available = 1
                            order by a.ID desc";

                    resModel = db.SetCommand(strSql, db.Parameter("@Code", model.ProductCode, DbType.Int64)
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<CommodityDetail_Model>();
                    res.Code = "1";
                    res.Data = resModel;
                }
            }
            return res;
        }

        public List<CommodityList_Model> getCommodityListByCategoryID(int categoryId, bool isBusiness, int branchId, int accountId, int customerId, bool selectAll)
        {
            using (DbManager db = new DbManager())
            {
                int levelId = 0;
                if (customerId > 0)
                {
                    string strSqlLevelId = @"  select  T2.CardID from [CUSTOMER] T1 with (nolock)
                                       INNER JOIN [TBL_CUSTOMER_CARD] T2 with (nolock) ON T1.DefaultCardNo=T2.UserCardNo
									   INNER JOIN [MST_CARD_BRANCH] T3 ON T2.CardID = T3.CardID AND T3.BranchID=@BranchID
                                        where T1.UserID =@UserID and T1.Available = 1   ";


                    Object obj = db.SetCommand(strSqlLevelId, db.Parameter("UserID", customerId, DbType.Int32)
                                                      , db.Parameter("@BranchID", isBusiness ? branchId : 0, DbType.Int32)).ExecuteScalar<object>();

                    if (obj != null)
                    {
                        levelId = StringUtils.GetDbInt(obj);
                    }
                }
                StringBuilder strSql = new StringBuilder();

                if (selectAll)
                {
                    strSql.Append(
                                 @" WITH subQuery(ParentID,ID) AS  
                                                        (SELECT ParentID,ID FROM dbo.CATEGORY WHERE ParentID=@CategoryID 
                                                        UNION ALL 
                                                        SELECT A.ParentID,A.ID FROM dbo.CATEGORY A,subQuery B WHERE 
                                                            A.ParentID=B.ID) ");
                }

                strSql.Append(" SELECT distinct T1.Code AS CommodityCode,T1.ID AS CommodityID,T1.CommodityName, T1.MarketingPolicy , T1.UnitPrice, CASE WHEN T1.MarketingPolicy = 2 THEN CASE WHEN @CardID = 0 THEN T1.UnitPrice ELSE T1.PromotionPrice END WHEN T1.MarketingPolicy = 1 THEN T1.UnitPrice * ISNULL(T8.Discount,1) END PromotionPrice, T1.New, T1.Recommended,T1.Specification,ISNULL(T4.ID,0) AS FavoriteID, ISNULL(T1.CommodityName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField ");
                strSql.Append(" ,T1.New,T1.Recommended,T2.Sortid ");
                strSql.Append(" FROM COMMODITY T1 ");

                //顾客端 抽出所有与顾客相关的分店下的商品
                if (!isBusiness)
                {
                    strSql.Append(@" INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T5 WITH(NOLOCK) ON T1.Code = T5.Code
                                                     AND T5.Available = 1
                                                     AND T5.Type = 1 ");
                }
                else
                {
                    //商家端 获取美丽顾问当前分店的商品(branchid>0)或公司所有服务(branchid=0)
                    if (branchId > 0)
                    {
                        strSql.Append(" Inner join [TBL_MARKET_RELATIONSHIP] T5 WITH(NOLOCK) ");
                        strSql.Append(" on T1.Code = T5.Code ");
                        strSql.Append(" AND T5.Available = 1");
                        strSql.Append(" AND T5.Type = 1 ");
                        strSql.Append(" AND T5.BranchID = ");
                        strSql.Append(branchId.ToString());
                    }
                }
                strSql.Append(" LEFT JOIN [TBL_COMMODITYSORT] T2 WITH(NOLOCK) ON T1.Code=T2.CommodityCode ");
                strSql.Append(" LEFT JOIN [TBL_FAVORITE] T4 WITH(NOLOCK) ON T1.Code=T4.Code AND T4.ProductType=1 AND T4.AccountID=@AccountID  AND T4.BranchID=@BranchID");
                strSql.Append("  LEFT JOIN  (select CardID,DiscountID,Discount from [TBL_CARD_DISCOUNT] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.CardID=@CardID AND T1.DiscountID = T8.DiscountID ");
                if (!selectAll)
                {
                    strSql.Append(" WHERE T1.CategoryID = @CategoryID and T1.Available = 1  and T1.ID in (SELECT MAX(ID) FROM COMMODITY GROUP BY code) ");
                }
                else
                {
                    strSql.Append(" WHERE (T1.CategoryID = @CategoryID or T1.CategoryID in(Select ID from subQuery))  and T1.Available = 1  and T1.ID in (SELECT MAX(ID) FROM COMMODITY GROUP BY code) ");
                }
                //strSql.Append(" WHERE CategoryID = @CategoryID  and Available = 1 ");
                if (!isBusiness)
                {
                    strSql.Append(" AND VisibleForCustomer=1 ");
                    strSql.Append(@" AND T5.BranchID IN(SELECT BranchID FROM dbo.RELATIONSHIP
                                  WHERE CustomerID = @CustomerID AND Available = 1) ");
                }

                strSql.Append(" ORDER BY T1.New DESC ,T1.Recommended DESC ,T2.Sortid ");

                List<CommodityList_Model> list = new List<CommodityList_Model>();
                list = db.SetCommand(strSql.ToString(), db.Parameter("@AccountID", isBusiness ? accountId : 0, DbType.Int32)
                                                      , db.Parameter("@BranchID", isBusiness ? branchId : 0, DbType.Int32)
                                                      , db.Parameter("@CategoryID", categoryId, DbType.Int32)
                                                      , db.Parameter("@CardID", levelId, DbType.Int32)
                                                      , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<CommodityList_Model>();
                return list;
            }

        }

        public List<CommodityEnalbeInfoDetail> getCommodityEnalbleForCustomer(int customerId, long productCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                List<CommodityEnalbeInfoDetail> list = new List<CommodityEnalbeInfoDetail>();

                strSql = @"SELECT distinct T1.BranchID ,
                                ProductQty quantity,StockCalcType,T3.BranchName 
                                FROM   dbo.TBL_PRODUCT_STOCK T1 
                                    INNER JOIN dbo.BRANCH T3 ON T3.Available = 1 AND T3.ID = T1.BranchID 
                                    INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 ON T2.Available =1 AND T2.Code = T1.ProductCode AND T2.Type = 1  AND T3.ID = T2.BranchID
                                WHERE  ProductCode = @ProductCode
                                AND T1.ID IN ( 
                                SELECT  MAX(ID) 
                                FROM    dbo.TBL_PRODUCT_STOCK 
                                WHERE   BranchID IN ( SELECT    BranchID  
                                                      FROM      dbo.RELATIONSHIP 
                                                      WHERE     CustomerID = @CustomerID
                                                      And       Available = 1 ) 
                                And ProductType = 1 
                                GROUP BY dbo.TBL_PRODUCT_STOCK.BranchID ,
                                        ProductCode )";

                list = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)
                                , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteList<CommodityEnalbeInfoDetail>();

                return list;

            }
        }

        public List<CommodityList_Model> getCommodityListCategoryIDNULL(int companyId, bool isBusiness, int branchId, int accountId, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();

                strSql.Append(" Select * ");
                strSql.Append(" FROM COMMODITY T1 ");

                //顾客端 抽出所有与顾客相关的分店下的商品
                if (!isBusiness)
                {
                    strSql.Append(@" INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T5 WITH(NOLOCK) ON T1.Code = T5.Code
                                                     AND T5.Available = 1
                                                     AND T5.Type = 1 ");
                }
                else
                {
                    //商家端 获取美丽顾问当前分店的商品(branchid>0)或公司所有服务(branchid=0)
                    if (branchId > 0)
                    {
                        strSql.Append(" Inner join [TBL_MARKET_RELATIONSHIP] T5 WITH(NOLOCK) ");
                        strSql.Append(" on T1.Code = T5.Code ");
                        strSql.Append(" AND T5.Available = 1");
                        strSql.Append(" AND T5.Type = 1 ");
                        strSql.Append(" AND T5.BranchID = ");
                        strSql.Append(branchId.ToString());
                    }
                }
                strSql.Append(" LEFT JOIN [TBL_COMMODITYSORT] T2 WITH(NOLOCK) ON T1.Code=T2.CommodityCode ");
                strSql.Append(" LEFT JOIN [TBL_FAVORITE] T4 WITH(NOLOCK) ON T1.Code=T4.Code AND T4.ProductType=1 AND T4.AccountID=@AccountID  AND T4.BranchID=@BranchID");
                //strSql.Append("  LEFT JOIN  (select LevelID,DiscountID,Discount from [TBL_LEVEL_DISCOUNT_RELATIONSHIP] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.LevelID=@LevelID AND T1.DiscountID = T8.DiscountID ");
                strSql.Append(" WHERE T1.CompanyID = @CompanyID and T1.CategoryID is null  and T1.Available = 1  and T1.ID in (SELECT MAX(ID) FROM COMMODITY GROUP BY code) ");
                //strSql.Append(" WHERE CategoryID = @CategoryID  and Available = 1 ");
                if (!isBusiness)
                {
                    strSql.Append(" AND VisibleForCustomer=1 ");
                    strSql.Append(@" AND T5.BranchID IN(SELECT BranchID FROM dbo.RELATIONSHIP
                                  WHERE CustomerID = @CustomerID AND Available = 1) ");
                }

                strSql.Append(" ORDER BY T1.New DESC ,T1.Recommended DESC ,T2.Sortid ");

                List<CommodityList_Model> list = new List<CommodityList_Model>();
                list = db.SetCommand(strSql.ToString(), db.Parameter("@AccountID", isBusiness ? accountId : 0, DbType.Int32)
                                                      , db.Parameter("@BranchID", isBusiness ? branchId : 0, DbType.Int32)
                                                      , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                      , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<CommodityList_Model>();
                return list;
            }

        }

        #region

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="imageWidth"></param>
        /// <param name="imageHeight"></param>
        /// <returns></returns>
        public List<Commodity_Model> getCommodityListByCompanyIdForWeb(int companyId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT distinct T1.ID,T1.CommodityName, T1.StockQuantity,T1.Describe,T1.Specification,T1.Code CommodityCode, T1.UnitPrice, ISNULL( T1.PromotionPrice,T1.UnitPrice) PromotionPrice,T1.VisibleForCustomer, T1.New, T1.Recommended,T1.Available,T1.MarketingPolicy, T4.CategoryName,T1.CategoryID,[T5].[Sortid],"
                + Common.Const.strHttp
                + Common.Const.server
                + Common.Const.strMothod
                + Common.Const.strSingleMark
                + "  + cast(T3.CompanyID as nvarchar(10)) + "
                + Common.Const.strSingleMark
                + "/"
                + Common.Const.strImageObjectType6
                + Common.Const.strSingleMark
                + "  + cast(T3.CommodityCode as nvarchar(16))+ '/' + T3.FileName + "
                + Common.Const.strThumb
                + " ThumbnailUrl"
                + " FROM COMMODITY T1 WITH(NOLOCK) "
                + " LEFT JOIN  "
                + " IMAGE_COMMODITY T3 WITH(NOLOCK) "
                + " ON T1.ID = T3.CommodityID  "
                + " AND T3.ImageType = 0  "
                + " LEFT JOIN  "
                + " CATEGORY T4  WITH(NOLOCK) "
                + " ON T1.CategoryID = T4.ID  "
                + " LEFT JOIN  "
                + " [TBL_COMMODITYSORT] T5  WITH(NOLOCK) "
                + " ON [T1].[CODE] = [T5].[COMMODITYCODE]  "
                + " WHERE T1.Available = 1 "
                + " AND T1.CompanyID =@CompanyID "
                + " AND T4.type = 1 "
                + " AND T4.Available = 1 "
                + " Order by [T1].[New] DESC,[T1].[Recommended] DESC,[T5].[Sortid] ";

                List<Commodity_Model> list = db.SetCommand(strSql,
                    db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                    db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String),
                    db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<Commodity_Model>();
                return list;

            }
        }

        /// <summary>
        ///获取某一目录下所有商品信息（前提为目录是最后一层）
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public List<Commodity_Model> getCommodityListForWeb(int companyId, int categoryId, int imageWidth, int imageHeight, int branchId, int supplierID)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(@" SELECT distinct T1.ID , T1.New, T1.Recommended, T4.CategoryName,T1.CommodityName,T1.Specification, T1.UnitPrice,T1.MarketingPolicy, ISNULL( T1.PromotionPrice,T1.UnitPrice) PromotionPrice,T1.VisibleForCustomer,T1.Describe,T1.Code CommodityCode,T1.Available,T1.CategoryID,[T5].[Sortid], 
                                ( SELECT DiscountName FROM dbo.TBL_DISCOUNT WHERE ID = T1.DiscountID AND available = 1 ) DiscountName ,
                                 (select max(ExpiryRemind) from 
                                 (select case when ( datediff(day,current_timestamp,TPSB.ExpiryDate) > isnull(TB.ExpiryRemind,-9999) ) then 0 else 1 end as ExpiryRemind
				                 from BRANCH TB ,TBL_PRODUCT_STOCK_BATCH TPSB
				                where TB.ID = TPSB.BranchID
				                and TPSB.CompanyID = T1.CompanyID");
                if (branchId > 0)
                {
                    strSql.Append(@" and TPSB.BranchID = @BranchID");
                }
                strSql.Append(@" and TPSB.ProductCode = T1.Code) TPSB1) ExpiryRemind ,"
                + Common.Const.strHttp
                + Common.Const.server
                + Common.Const.strMothod
                + "/"
                + Common.Const.strSingleMark
                + "  + cast(T3.CompanyID as nvarchar(10)) + "
                + Common.Const.strSingleMark
                + "/"
                + Common.Const.strImageObjectType6
                + Common.Const.strSingleMark
                + @" + cast(T3.CommodityCode as nvarchar(16))+ '/' + T3.FileName + "
                + Common.Const.strThumb
                + @" ThumbnailUrl FROM COMMODITY T1 WITH(NOLOCK) ");

                if (branchId > 0)
                {
                    strSql.Append(@" INNER JOIN [TBL_MARKET_RELATIONSHIP] T6 
                                     on T1.Code = T6.Code 
                                     AND T6.Type = 1 
                                     AND T6.Available = 1 
                                     AND T6.BranchID =@BranchID ");
                }

                strSql.Append(@" LEFT JOIN 
                                 SUPPLIER_COMMODITY_RELATIONSHIP T7 WITH(NOLOCK)
                                 ON T7.CommodityID = T1.ID ");

                strSql.Append(@" LEFT JOIN  
                                 IMAGE_COMMODITY T3 WITH(NOLOCK) 
                                 ON T1.ID = T3.CommodityID  
                                 AND T3.ImageType = 0  
                                 LEFT JOIN  
                                 CATEGORY T4  WITH(NOLOCK) 
                                 ON T1.CategoryID = T4.ID  
                                 LEFT JOIN  
                                 [TBL_COMMODITYSORT] T5  WITH(NOLOCK) 
                                 ON [T1].[CODE] = [T5].[COMMODITYCODE]  
                                 WHERE T1.Available = 1  and T1.CompanyID =@CompanyID");

                switch (categoryId)
                {
                    //获取所有
                    case -1:
                        strSql.Append(@" AND( 
                                                (T4.type = 1  AND T4.Available = 1) OR ( T1.CategoryID IS NULL OR T1.CategoryID = -1 ) 
                                            ) ");
                        break;
                    //获取无所属
                    case 0:
                        strSql.Append(@" AND (T1.CategoryID IS NULL OR T1.CategoryID = -1)");
                        break;
                    //获取当前分类下的项目
                    default:
                        strSql.Append(" AND T1.CategoryID =@CategoryID  ");
                        break;
                }

                switch (supplierID)
                {
                    //获取所有
                    case -1:
                        ;
                        break;
                    //获取无所属
                    case 0:
                        strSql.Append(@" AND (T7.SupplierID IS NULL OR T7.SupplierID = 0)");
                        break;
                    //获取当前分类下的项目
                    default:
                        strSql.Append(" AND T7.SupplierID = @SupplierID  ");
                        break;
                }


                //获取没有分配分店的项目
                if (branchId == 0)
                {
                    strSql.Append("  AND T1.Code  NOT IN (SELECT Code FROM [TBL_MARKET_RELATIONSHIP] WITH ( NOLOCK ) WHERE CompanyID = @CompanyID and TYPE = 1 and Available = 1 group by Code )");
                }
                strSql.Append(" AND T1.Available = 1 ");
                strSql.Append(" Order by [T5].[Sortid] ");

                List<Commodity_Model> list = db.SetCommand(strSql.ToString(),
                                                          db.Parameter("@CompanyID", companyId, DbType.Int32),
                                                          db.Parameter("@BranchID", branchId, DbType.Int32),
                                                          db.Parameter("@CategoryID", categoryId, DbType.Int32),
                                                          db.Parameter("@SupplierID", supplierID, DbType.Int32),
                                                          db.Parameter("@ImageHeight", imageHeight.ToString()),
                                                          db.Parameter("@ImageWidth", imageWidth.ToString())).ExecuteList<Commodity_Model>();

                return list;
            }
        }

        /// <summary>
        /// 删除商品信息
        /// </summary>
        /// <param name="accountId"></param>
        /// <param name="commodityId"></param>
        /// <returns></returns>
        public bool deleteCommodity(int accountId, long commodityCode, int companyID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string strSqlSelect = "select max(ID) from Commodity where code =@Code ";
                    int commodityID = db.SetCommand(strSqlSelect, db.Parameter("@Code", commodityCode, DbType.Int64)).ExecuteScalar<Int32>();

                    if (commodityID <= 0)
                    {
                        return false;
                    }

                    string strSqlHistory = @" INSERT INTO [TBL_HISTORY_COMMODITY] SELECT * FROM [COMMODITY] WHERE ID=@ID ";

                    int rows = db.SetCommand(strSqlHistory,
                                                  db.Parameter("@ID", commodityID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }


                    //删除某个商品的所有商品供应商关系
                    string strSqlSupplierCommoditydel = @" delete from  [SUPPLIER_COMMODITY_RELATIONSHIP] where CommodityID=@CommodityID  ";
                    int checkCount = db.SetCommand(strSqlSupplierCommoditydel, db.Parameter("@CommodityID", commodityID, DbType.Int32)).ExecuteScalar<int>();

                    string strSql = @"
                                    update COMMODITY set 
                                    Available = 0,
                                    UpdaterID=@UpdaterID,
                                    UpdateTime =@UpdateTime
                                    where id =@ID";

                    rows = db.SetCommand(strSql,
                                                    db.Parameter("@UpdaterID", accountId, DbType.Int32),
                                                    db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                                                    db.Parameter("@ID", commodityID, DbType.Int32)).ExecuteNonQuery();
                    if (rows > 0)
                    {
                        db.CommitTransaction();
                        return true;
                    }
                    else
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="company"></param>
        /// <returns></returns>
        public CommodityDetail_Model getCommodityDetailForWeb(int companyId, long commodityCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT TOP 1
                                          a.VisibleForCustomer,
                                          a.New,
                                          a.DiscountID,
                                          a.SerialNumber,
                                          a.Recommended,
                                          a.CategoryID,
                                          a.ID CommodityID ,
                                          a.Code CommodityCode ,
                                          a.CommodityName ,
                                          a.Describe ,
                                          a.Specification ,
                                          a.MarketingPolicy ,
                                          a.UnitPrice ,
                                          a.PromotionPrice,
                                          a.IsConfirmed,
                                          a.AutoConfirm,
                                          a.AutoConfirmDays,
                                          a.Manufacturer,
                                          a.ApprovalNumber
                                  FROM    [COMMODITY] a WITH ( NOLOCK )
                                  WHERE   a.CompanyID = @CompanyID 
                                          AND a.Code = @CommodityCode
                                          AND a.Available = 1
                                  ORDER BY a.ID DESC";


                CommodityDetail_Model detailModel = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                                        , db.Parameter("@CommodityCode", commodityCode, DbType.Int64)).ExecuteObject<CommodityDetail_Model>();


                return detailModel;

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="commodityCode"></param>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <returns></returns>
        public List<ProductBranchRelationship_Model> getCommodityBranchStock(long commodityCode, int companyId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select BRANCH.ID BranchID,BRANCH.BranchName,QueryProductRelationShip.ID ProductRelationShipID,QueryProductRelationShip.Available BranchAvailable,QueryProductStock.ProductQty ProductQty ,QueryProductStock.ID ProductStockID ,ISNULL(QueryProductStock.StockCalcType,2) StockCalcType,QueryProductStock.BuyingPrice,QueryProductStock.InsuranceQty
                                    from BRANCH  with(nolock)
                                    left join (
                                    select TBL_MARKET_RELATIONSHIP.BranchID,TBL_MARKET_RELATIONSHIP.ID,TBL_MARKET_RELATIONSHIP.Available
                                    from TBL_MARKET_RELATIONSHIP with(nolock)
                                    where TBL_MARKET_RELATIONSHIP.Type = 1
                                    and TBL_MARKET_RELATIONSHIP.Code =@CommodityCode) QueryProductRelationShip
                                    on  BRANCH.ID = QueryProductRelationShip.BranchID
                                    left join (
                                    select TBL_PRODUCT_STOCK.BranchID,TBL_PRODUCT_STOCK.ProductQty,TBL_PRODUCT_STOCK.ID,ISNULL(TBL_PRODUCT_STOCK.StockCalcType,2) StockCalcType,ISNULL(TBL_PRODUCT_STOCK.BuyingPrice , 0) AS BuyingPrice ,ISNULL(TBL_PRODUCT_STOCK.InsuranceQty,0) AS InsuranceQty  from TBL_PRODUCT_STOCK with(nolock)
                                    where TBL_PRODUCT_STOCK.ProductCode =@CommodityCode ) QueryProductStock
                                    on BRANCH.ID = QueryProductStock.BranchID 
                                    where BRANCH.CompanyID = @CompanyID
                                    and BRANCH.Available = 1";
                if (branchId > 0)
                {
                    strSql += "and BRANCH.ID = " + branchId.ToString();
                }
                List<ProductBranchRelationship_Model> list = db.SetCommand(strSql,
                                             db.Parameter("@CommodityCode", commodityCode, DbType.Int64),
                                             db.Parameter("@CompanyID", companyId, DbType.Int32))
                                             .ExecuteList<ProductBranchRelationship_Model>();
                return list;
            }

        }

        public List<CommoditySupplierDetail_Model> getCommoditySupplierDetailList(long CommodityCode){
            using (DbManager db = new DbManager())
            {
                String supplierListSql = @" SELECT supplierid AS SupplierID,suppliername AS SupplierName FROM fGetSupplier (@comoditycode) ";
                List<CommoditySupplierDetail_Model> list = db.SetCommand(supplierListSql,
                             db.Parameter("@comoditycode", CommodityCode, DbType.Int64))
                             .ExecuteList<CommoditySupplierDetail_Model>();
                if (list == null && list.Count == 0) {
                    list = new List<CommoditySupplierDetail_Model>();
                }
                CommoditySupplierDetail_Model model = new CommoditySupplierDetail_Model();
                model.SupplierID = 0;
                model.SupplierName = null;
                list.Insert(0,model);
                return list;
            }
        }
        public int addCommodity(CommodityDetailOperation_Model mCommodity, out long commodityCode)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    long CommodityCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CommodityCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                    if (CommodityCode == 0)
                    {
                        db.RollbackTransaction();
                        commodityCode = 0;
                        return 0;
                    }

                    string strSqlAdd = @"  insert into COMMODITY ( 
                                        CompanyID, BranchID, CategoryID, Code, CommodityName, UnitPrice,MarketingPolicy,PromotionPrice, Specification, Describe, New, Recommended,  Available, CreatorID, CreateTime,VisibleForCustomer,SerialNumber,DiscountID,IsConfirmed, AutoConfirm, AutoConfirmDays, Manufacturer,ApprovalNumber)
                                        values(
                                        @CompanyID, @BranchID, @CategoryID, @Code, @CommodityName, @UnitPrice,@MarketingPolicy,@PromotionPrice, @Specification, @Describe, @New, @Recommended,  @Available, @CreatorID, @CreateTime,@VisibleForCustomer,@SerialNumber,@DiscountID,@IsConfirmed, @AutoConfirm, @AutoConfirmDays, @Manufacturer,@ApprovalNumber) 
                                        ;select @@IDENTITY ";

                    int commodityId = db.SetCommand(strSqlAdd, db.Parameter("@CompanyID", mCommodity.CompanyID, DbType.Int32)
                       , db.Parameter("@BranchID", 0, DbType.Int32)
                       , db.Parameter("@CategoryID", mCommodity.CategoryID == 0 ? (object)DBNull.Value : mCommodity.CategoryID, DbType.Int32)
                       , db.Parameter("@Code", CommodityCode, DbType.Int64)
                       , db.Parameter("@CommodityName", mCommodity.CommodityName, DbType.String)
                       , db.Parameter("@UnitPrice", mCommodity.UnitPrice, DbType.Decimal)
                       , db.Parameter("@MarketingPolicy", mCommodity.MarketingPolicy, DbType.Int16)
                       , db.Parameter("@PromotionPrice", mCommodity.MarketingPolicy == 2 ? mCommodity.PromotionPrice : (object)DBNull.Value, DbType.Decimal)
                       , db.Parameter("@Specification", mCommodity.Specification, DbType.String)
                       , db.Parameter("@Describe", mCommodity.Describe, DbType.String)
                       , db.Parameter("@New", mCommodity.New, DbType.Boolean)
                       , db.Parameter("@Recommended", mCommodity.Recommended, DbType.Boolean)
                       , db.Parameter("@Available", true, DbType.Boolean)
                       , db.Parameter("@CreatorID", mCommodity.UpdaterID, DbType.Int32)
                       , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                       , db.Parameter("@VisibleForCustomer", mCommodity.VisibleForCustomer, DbType.Boolean)
                       , db.Parameter("@SerialNumber", mCommodity.SerialNumber, DbType.String)
                       , db.Parameter("@DiscountID", mCommodity.MarketingPolicy == 1 ? (mCommodity.DiscountID == -1 ? (object)DBNull.Value : mCommodity.DiscountID) : (object)DBNull.Value, DbType.Int32)
                       , db.Parameter("@IsConfirmed", mCommodity.IsConfirmed, DbType.Int32)
                       , db.Parameter("@AutoConfirm", mCommodity.AutoConfirm, DbType.Int32)
                       , db.Parameter("@AutoConfirmDays", mCommodity.AutoConfirmDays, DbType.Int32)
                       , db.Parameter("@Manufacturer", mCommodity.Manufacturer, DbType.String)
                       , db.Parameter("@ApprovalNumber", mCommodity.ApprovalNumber, DbType.String)
                       ).ExecuteScalar<int>();

                    if (commodityId == 0)
                    {
                        db.RollbackTransaction();
                        commodityCode = 0;
                        return 0;
                    }

                    string strSqlInsertSort = @" insert into TBL_COMMODITYSORT ( 
                                                Companyid, CommodityCode, Sortid)
                                                values(
                                                @Companyid, @CommodityCode, (SELECT ISNULL(MAX(Sortid),0) + 1 FROM TBL_COMMODITYSORT where CompanyId=@Companyid)) ";


                    int rows = db.SetCommand(strSqlInsertSort, db.Parameter("@Companyid", mCommodity.CompanyID, DbType.Int32)
                        , db.Parameter("@CommodityCode", CommodityCode, DbType.Int64)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        commodityCode = 0;
                        return 0;
                    }

                    if (mCommodity.BranchID > 0)
                    {
                        string strSqlRelationShipAdd = @"  INSERT INTO [TBL_MARKET_RELATIONSHIP] 
                                                    (CompanyID,BranchID,Type,Code,Available,OperatorID,OperateTime)
                                                    VALUES
                                                    (@relatCompanyID,@relatBranchID,@relatType,@relatCode,@relatAvailable,@relatOperatorID,@relatOperateTime)";

                        rows = db.SetCommand(strSqlRelationShipAdd, db.Parameter("@relatCompanyID", mCommodity.CompanyID, DbType.Int32)
                            , db.Parameter("@relatBranchID", mCommodity.BranchID, DbType.Int32)
                            , db.Parameter("@relatType", 1, DbType.Int32)
                            , db.Parameter("@relatCode", CommodityCode, DbType.Int64)
                            , db.Parameter("@relatAvailable", true, DbType.Boolean)
                            , db.Parameter("@relatOperatorID", mCommodity.UpdaterID, DbType.Int32)
                            , db.Parameter("@relatOperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            commodityCode = 0;
                            return 0;
                        }

                        string strSqlStockAdd = @"  INSERT INTO [TBL_PRODUCT_STOCK] 
                                                (CompanyID,BranchID,ProductType,ProductCode,ProductQty,OperatorID,OperateTime,StockCalcType)
                                                VALUES
                                                (@stockCompanyID,@stockBranchID,@stockProductType,@stockProductCode,@stockProductQty,@stockOperatorID,@stockOperateTime,@StockCalcType) ";

                        rows = db.SetCommand(strSqlStockAdd, db.Parameter("@stockCompanyID", mCommodity.CompanyID, DbType.Int32)
                               , db.Parameter("@stockBranchID", mCommodity.BranchID, DbType.Int32)
                               , db.Parameter("@stockProductType", 1, DbType.Int32)
                               , db.Parameter("@stockProductCode", CommodityCode, DbType.Int64)
                               , db.Parameter("@stockProductQty", 0, DbType.Int32)
                               , db.Parameter("@stockOperatorID", mCommodity.UpdaterID, DbType.Int32)
                               , db.Parameter("@stockOperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                               , db.Parameter("@StockCalcType", 2, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            commodityCode = 0;
                            return 0;
                        }
                    }

                    db.CommitTransaction();
                    commodityCode = CommodityCode;
                    return commodityId;

                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }
        
        public Product_Stock_Batch_Model getProductStockBatchByProductCodeAndBatchNO(Product_Stock_Batch_Model model)
        {
            using (DbManager db = new DbManager())
            {
                Product_Stock_Batch_Model resultModel = null;
                string strSql = @"SELECT T1.ID,T1.CompanyID,T1.BranchID,T1.ProductCode,T1.BatchNO,T1.ExpiryDate,T1.Quantity
                                  FROM [dbo].[TBL_PRODUCT_STOCK_BATCH] T1
                                  WHERE T1.ProductCode = @ProductCode
                                       AND T1.BatchNO = @BatchNO
                                       AND T1.CompanyID = @CompanyID
                                       AND T1.BranchID = @BranchID ";
                resultModel = db.SetCommand(strSql, db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                                                  , db.Parameter("@BatchNO", model.BatchNO, DbType.String)
                                                  , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                  , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<Product_Stock_Batch_Model>();
                return resultModel;
            }
                
        }
        public bool AddBatch(Product_Stock_Batch_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    //添加批次表
                    string strSql = @"INSERT  INTO TBL_PRODUCT_STOCK_BATCH (";
                    strSql += @" CompanyID, ";
                    strSql += @" BranchID, ";
                    strSql += @" ProductCode, ";
                    strSql += @" BatchNO, ";
                    strSql += @" Quantity, ";
                    strSql += @" ExpiryDate, ";
                    strSql += @" OperatorID, ";
                    strSql += @" OperateTime, ";
                    strSql += @" SupplierID ";
                    strSql += @" ) values (";
                    strSql += @" @CompanyID, ";
                    strSql += @" @BranchID, ";
                    strSql += @" @ProductCode, ";
                    strSql += @" @BatchNO, ";
                    strSql += @" @Quantity, ";
                    strSql += @" @ExpiryDate, ";
                    strSql += @" @OperatorID, ";
                    strSql += @" getdate(), ";
                    strSql += @" @SupplierID ";
                    strSql += @" )";
                    db.SetCommand(strSql,
                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                        db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
                        db.Parameter("@BatchNO", model.BatchNO, DbType.String),
                        db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                        db.Parameter("@ExpiryDate", model.ExpiryDate, DbType.Date),
                        db.Parameter("@OperatorID", model.OperatorID, DbType.Int32),
                        db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)
                        ).ExecuteNonQuery();

                    //获取商品库存记录条数
                    strSql = @"select max(ID) from TBL_PRODUCT_STOCK ";
                    strSql += @" where CompanyID = @CompanyID ";
                    strSql += @" and BranchID = @BranchID ";
                    strSql += @" and ProductCode = @ProductCode ";
                    string strStockID = db.SetCommand(strSql,
                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                        db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                        ).ExecuteScalar<string>();

                    if (string.IsNullOrWhiteSpace(strStockID))
                    { //添加库存
                        strSql = @"INSERT INTO TBL_PRODUCT_STOCK (";
                        strSql += @" CompanyID, ";
                        strSql += @" BranchID, ";
                        strSql += @" ProductType, ";
                        strSql += @" ProductCode, ";
                        strSql += @" ProductQty, ";
                        strSql += @" OperatorID, ";
                        strSql += @" OperateTime, ";
                        strSql += @" StockCalcType, ";
                        strSql += @" BuyingPrice, ";
                        strSql += @" InsuranceQty ";
                        strSql += @" ) values (";
                        strSql += @" @CompanyID, ";
                        strSql += @" @BranchID, ";
                        strSql += @" 1, ";
                        strSql += @" @ProductCode, ";
                        strSql += @" @ProductQty, ";
                        strSql += @" @OperatorID, ";
                        strSql += @" getdate(), ";
                        strSql += @" 1, ";
                        strSql += @" null, ";
                        strSql += @" null ";
                        strSql += @" )";
                        db.SetCommand(strSql,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
                            db.Parameter("@ProductQty", model.Quantity, DbType.Int32),
                            db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                            ).ExecuteNonQuery();

                    }
                    else
                    {
                        //更新库存
                        strSql = @"update TBL_PRODUCT_STOCK set ";
                        strSql += @" ProductQty = isnull(ProductQty + @ProductQty,@ProductQty), ";
                        strSql += @" OperatorID = @OperatorID, ";
                        strSql += @" OperateTime = getdate() ";
                        strSql += @" where ID = @ID";

                        db.SetCommand(strSql,
                            db.Parameter("@ID", int.Parse(strStockID), DbType.Int32),
                            db.Parameter("@ProductQty", model.Quantity, DbType.Int32),
                            db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                            ).ExecuteNonQuery();
                    }


                    //添加库log存表
                    strSql = @"INSERT  INTO TBL_PRODUCT_STOCK_OPERATELOG ( ";
                    strSql += @" CompanyID, ";
                    strSql += @" BranchID, ";
                    strSql += @" ProductType, ";
                    strSql += @" ProductCode, ";
                    strSql += @" OperateType, ";
                    strSql += @" OperateQty, ";
                    strSql += @" OperateSign, ";
                    strSql += @" OrderID, ";
                    strSql += @" OperatorID, ";
                    strSql += @" OperateTime, ";
                    strSql += @" Remark, ";
                    strSql += @" ProductQty, ";
                    strSql += @" BatchNO,  ";
                    strSql += @" SupplierID ) ";
                    strSql += @" select ";
                    strSql += @" @CompanyID, ";
                    strSql += @" @BranchID, ";
                    strSql += @" 1, ";
                    strSql += @" @ProductCode, ";
                    strSql += @" 1, ";
                    strSql += @" @OperateQty, ";
                    strSql += @" '+', ";
                    strSql += @" null, ";
                    strSql += @" @OperatorID, ";
                    strSql += @" getdate(), ";
                    strSql += @" null, ";
                    strSql += @" ProductQty, ";
                    strSql += @" @BatchNO, ";
                    strSql += @" @SupplierID ";
                    strSql += @" from TBL_PRODUCT_STOCK ";
                    strSql += @" where ID = @ID ";
                    db.SetCommand(strSql,
                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                        db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
                        db.Parameter("@OperateQty", model.Quantity, DbType.Int32),
                        db.Parameter("@OperatorID", model.OperatorID, DbType.Int32),
                        db.Parameter("@BatchNO", model.BatchNO, DbType.String),
                        db.Parameter("@ID", int.Parse(strStockID), DbType.Int32),
                        db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)
                    ).ExecuteNonQuery();

                    db.CommitTransaction();
                    return true;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public int updateCommodityDetail(CommodityDetailOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string strSql = "select Count(*) from [COMMODITY] WITH(NOLOCK) where Available = 1 and ID=@CommodityID";
                    int count = db.SetCommand(strSql, db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                                             ).ExecuteScalar<int>();

                    string strSqlGetCreatInfo = @" select CreatorID,CreateTime from [COMMODITY] where CompanyID=@CompanyID and ID=@CommodityID  ";
                    CommodityDetailOperation_Model temp = db.SetCommand(strSqlGetCreatInfo, db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteObject<CommodityDetailOperation_Model>();

                    model.CreatorID = temp.CreatorID;
                    model.CreateTime = temp.CreateTime;
                    if (temp == null)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    if (count <= 0)
                        return 0;

                    strSql = @"SELECT count(0) FROM [TBL_ORDER_COMMODITY] WHERE CommodityID=@CommodityID ";

                    count = db.SetCommand(strSql, db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                                             ).ExecuteScalar<int>();
                    int Id = 0;
                    if (count <= 0)
                    {
                        #region
                        strSql = @" INSERT  INTO [TBL_HISTORY_COMMODITY] SELECT * FROM [COMMODITY] WHERE ID=@CommodityID";

                        int rows = db.SetCommand(strSql, db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                                             ).ExecuteNonQuery();

                        if (rows <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        strSql = @"update [COMMODITY] set  CategoryID=@CategoryID
                                ,CommodityName=@CommodityName
                                ,UnitPrice=@UnitPrice
                                ,MarketingPolicy=@MarketingPolicy
                                ,PromotionPrice=@PromotionPrice
                                ,Specification=@Specification
                                ,Describe=@Describe
                                ,New=@New
                                ,Recommended=@Recommended
                                ,VisibleForCustomer=@VisibleForCustomer
                                ,SerialNumber=@SerialNumber
                                ,DiscountID=@DiscountID
                                ,IsConfirmed=@IsConfirmed
                                ,AutoConfirm = @AutoConfirm
                                ,AutoConfirmDays = @AutoConfirmDays
                                ,UpdaterID=@UpdaterID
                                ,UpdateTime=@UpdateTime
                                ,Manufacturer=@Manufacturer
                                ,ApprovalNumber=@ApprovalNumber
                                Where ID=@CommodityID and CompanyID=@CompanyID ";

                        rows = db.SetCommand(strSql
                             , db.Parameter("@CategoryID", model.CategoryID != 0 ? model.CategoryID : (object)DBNull.Value, DbType.Int32)
                             , db.Parameter("@CommodityName", model.CommodityName, DbType.String)
                             , db.Parameter("@UnitPrice", model.UnitPrice, DbType.Decimal)
                             , db.Parameter("@MarketingPolicy", model.MarketingPolicy, DbType.Int32)
                             , db.Parameter("@PromotionPrice", model.MarketingPolicy == 2 ? model.PromotionPrice : (object)DBNull.Value, DbType.Decimal)
                             , db.Parameter("@Specification", model.Specification, DbType.String)
                             , db.Parameter("@Describe", model.Describe, DbType.String)
                             , db.Parameter("@New", model.New, DbType.Boolean)
                             , db.Parameter("@Recommended", model.Recommended, DbType.Boolean)
                             , db.Parameter("@VisibleForCustomer", model.VisibleForCustomer, DbType.Boolean)
                             , db.Parameter("@SerialNumber", model.SerialNumber, DbType.String)
                             , db.Parameter("@DiscountID", (model.MarketingPolicy == 1 && model.DiscountID != -1) ? model.DiscountID : (object)DBNull.Value, DbType.Int32)
                             , db.Parameter("@IsConfirmed", model.IsConfirmed, DbType.Int32)
                             , db.Parameter("@AutoConfirm", model.AutoConfirm, DbType.Int32)
                             , db.Parameter("@AutoConfirmDays", model.AutoConfirmDays, DbType.Int32)
                             , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                             , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                             , db.Parameter("@Manufacturer", model.Manufacturer, DbType.String)
                             , db.Parameter("@ApprovalNumber", model.ApprovalNumber, DbType.String)
                             , db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        Id = model.CommodityID;
                        #endregion
                    }
                    else
                    {
                        #region

                        strSql = @"update COMMODITY set
                                Available=@Available,
                                UpdaterID=@UpdaterID, 
                                UpdateTime=@UpdateTime
                                where ID=@CommodityID";

                        int rows = db.SetCommand(strSql, db.Parameter("@Available", false, DbType.Boolean)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                            , db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        strSql = @" insert into COMMODITY ( 
                     CompanyID, BranchID, CategoryID, Code, CommodityName, UnitPrice,MarketingPolicy,PromotionPrice, Specification, Describe, New, Recommended, Available, CreatorID, CreateTime,VisibleForCustomer,SerialNumber,DiscountID,IsConfirmed, AutoConfirm, AutoConfirmDays, UpdaterID,UpdateTime,Manufacturer,ApprovalNumber) 
                     values( 
                     @CompanyID, @BranchID, @CategoryID, @Code, @CommodityName, @UnitPrice,@MarketingPolicy,@PromotionPrice, @Specification, @Describe, @New, @Recommended, @Available, @CreatorID, @CreateTime,@VisibleForCustomer,@SerialNumber,@DiscountID,@IsConfirmed, @AutoConfirm, @AutoConfirmDays, @UpdaterID,@UpdateTime,@Manufacturer,@ApprovalNumber) 
                    ;select @@IDENTITY";

                        Id = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@BranchID", 0, DbType.Int32)
                             , db.Parameter("@CategoryID", model.CategoryID != 0 ? model.CategoryID : (object)DBNull.Value, DbType.Int32)
                             , db.Parameter("@Code", model.CommodityCode, DbType.Int64)
                             , db.Parameter("@CommodityName", model.CommodityName, DbType.String)
                             , db.Parameter("@UnitPrice", model.UnitPrice, DbType.Decimal)
                             , db.Parameter("@MarketingPolicy", model.MarketingPolicy, DbType.Int32)
                             , db.Parameter("@PromotionPrice", model.MarketingPolicy == 2 ? model.PromotionPrice : (object)DBNull.Value, DbType.Decimal)
                             , db.Parameter("@Specification", model.Specification, DbType.String)
                             , db.Parameter("@Describe", model.Describe, DbType.String)
                             , db.Parameter("@New", model.New, DbType.Boolean)
                             , db.Parameter("@Recommended", model.Recommended, DbType.Boolean)
                             , db.Parameter("@Available", true, DbType.Boolean)
                             , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                             , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                             , db.Parameter("@VisibleForCustomer", model.VisibleForCustomer, DbType.Boolean)
                             , db.Parameter("@SerialNumber", model.SerialNumber, DbType.String)
                             , db.Parameter("@DiscountID", (model.MarketingPolicy == 1 && model.DiscountID != -1) ? model.DiscountID : (object)DBNull.Value, DbType.Int32)
                             , db.Parameter("@IsConfirmed", model.IsConfirmed, DbType.Int32)
                             , db.Parameter("@AutoConfirm", model.AutoConfirm, DbType.Int32)
                             , db.Parameter("@AutoConfirmDays", model.AutoConfirmDays, DbType.Int32)
                             , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                             , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                             , db.Parameter("@Manufacturer", model.Manufacturer, DbType.String)
                             , db.Parameter("@ApprovalNumber", model.ApprovalNumber, DbType.String)
                             ).ExecuteScalar<int>();

                        if (Id <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion
                    }
                    db.CommitTransaction();
                    return Id;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public bool OperateProductStock(BranchCommodityOperation_Model operationModel)
        {
            try
            {
                using (DbManager db = new DbManager())
                {
                    db.BeginTransaction();
                    int rows = 0;
                    if (operationModel == null || operationModel.operationList == null || operationModel.operationList.Count <= 0)
                        return false;
                    foreach (var model in operationModel.operationList)
                    {
                        if (model.ProductRelationShipID > -1)
                        {
                            string strSqlRelationShipCheck = @" select ID from [TBL_MARKET_RELATIONSHIP] WITH (ROWLOCK,HOLDLOCK) where BranchID=@BranchID and Code=@Code and Type = 1";
                            object obj = db.SetCommand(strSqlRelationShipCheck,
                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                           db.Parameter("@Code", operationModel.Code, DbType.Int64)).ExecuteScalar();

                            if ((Object.Equals(obj, null)) || (Object.Equals(obj, System.DBNull.Value)))
                            {
                                model.ProductRelationShipID = 0;
                            }
                            else
                            {
                                model.ProductRelationShipID = StringUtils.GetDbInt(obj);
                            }

                            if (model.ProductRelationShipID == 0 && model.BranchAvailable)
                            {
                                string strSqlRelationShipAdd = @"INSERT INTO [TBL_MARKET_RELATIONSHIP]
                                                (CompanyID,BranchID,Type,Code,Available,OperatorID,OperateTime)
                                                 VALUES
                                                (@CompanyID,@BranchID,@Type,@Code,@Available,@OperatorID,@OperateTime)";

                                rows = db.SetCommand(strSqlRelationShipAdd,
                                    db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@Type", operationModel.Type, DbType.Int32),
                                    db.Parameter("@Code", operationModel.Code, DbType.Int64),
                                    db.Parameter("@Available", model.BranchAvailable, DbType.Boolean),
                                    db.Parameter("@OperatorID", operationModel.OperatorID, DbType.Int32),
                                    db.Parameter("@OperateTime", operationModel.OperateTime, DbType.DateTime2)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else if (model.ProductRelationShipID > 0)
                            {
                                string strSqlRelationShipCopy = "Insert Into [TBL_HISTORY_MARKET_RELATIONSHIP] select * from [TBL_MARKET_RELATIONSHIP] where ID = " + model.ProductRelationShipID;
                                rows = db.SetCommand(strSqlRelationShipCopy).ExecuteNonQuery();
                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                                string strSqlRelationShipUpdate = @" UPDATE [TBL_MARKET_RELATIONSHIP] SET
                                                   Available = @Available,
                                                   OperatorID = @OperatorID,
                                                   OperateTime = @OperateTime
                                                   where ID =@ProductRelationShipID";

                                rows = db.SetCommand(strSqlRelationShipUpdate,
                                    db.Parameter("@Available", model.BranchAvailable, DbType.Boolean),
                                    db.Parameter("@OperatorID", operationModel.OperatorID, DbType.Int32),
                                    db.Parameter("@OperateTime", operationModel.OperateTime, DbType.DateTime2),
                                    db.Parameter("@ProductRelationShipID", model.ProductRelationShipID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                        }


                        string strProductStockCheck = @" select ID from [TBL_PRODUCT_STOCK] WITH (ROWLOCK,HOLDLOCK) where BranchID=@BranchID and ProductCode=@ProductCode";
                        object objStock = db.SetCommand(strProductStockCheck,
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                       db.Parameter("@ProductCode", operationModel.Code, DbType.Int64)).ExecuteScalar();

                        if ((Object.Equals(objStock, null)) || (Object.Equals(objStock, System.DBNull.Value)))
                        {
                            model.ProductStockID = 0;
                        }
                        else
                        {
                            model.ProductStockID = StringUtils.GetDbInt(objStock);
                        }


                        if (model.ProductStockID == 0)
                        {
                            string strSqlStockAdd = @"INSERT INTO [TBL_PRODUCT_STOCK]
                                        (CompanyID,BranchID,ProductType,ProductCode,ProductQty,OperatorID,OperateTime,StockCalcType,BuyingPrice,InsuranceQty)
                                        VALUES
                                        (@CompanyID,@BranchID,@ProductType,@ProductCode,@ProductQty,@OperatorID,@OperateTime,@StockCalcType,@BuyingPrice,@InsuranceQty) 
                                        ;select @@IDENTITY ";

                            int productQty = 0;
                            switch (model.OperateType)
                            {
                                case 1:
                                    productQty = productQty + model.OperateQty;
                                    break;
                                case 2:
                                    productQty = productQty - model.OperateQty;
                                    break;
                                case 3:
                                    productQty = model.OperateQty;
                                    break;
                            }

                            int stockId = db.SetCommand(strSqlStockAdd
                                   , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                   , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                   , db.Parameter("@ProductType", operationModel.Type, DbType.Int32)
                                   , db.Parameter("@ProductCode", operationModel.Code, DbType.Int64)
                                   , db.Parameter("@ProductQty", productQty, DbType.Int32)
                                   , db.Parameter("@OperatorID", operationModel.OperatorID, DbType.Int32)
                                   , db.Parameter("@OperateTime", operationModel.OperateTime, DbType.DateTime2)
                                   , db.Parameter("@StockCalcType", model.StockCalcType, DbType.Int32)
                                   , db.Parameter("@BuyingPrice", model.BuyingPrice, DbType.Decimal)
                                   , db.Parameter("@InsuranceQty", model.InsuranceQty, DbType.Int32)).ExecuteScalar<int>();

                            if (stockId == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            model.ProductStockID = stockId;
                        }
                        else if (model.ProductStockID > 0)
                        {
                            string strSqlStockUpdate = @"UPDATE [TBL_PRODUCT_STOCK] SET 
                                            {0}
                                            OperatorID = @OperatorID,
                                            OperateTime = @OperateTime,
                                            StockCalcType = @StockCalcType,
                                            BuyingPrice=@BuyingPrice,
                                            InsuranceQty=@InsuranceQty
                                            where ID =@ProductStockID";
                            switch (model.OperateType)
                            {
                                case 1:
                                    //                                    strSqlStockUpdate = @"UPDATE [TBL_PRODUCT_STOCK] SET 
                                    //                                            ProductQty = ProductQty + @ProductQty,
                                    //                                            OperatorID = @OperatorID,
                                    //                                            OperateTime = @OperateTime,
                                    //                                            StockCalcType = @StockCalcType
                                    //                                            where ID =@ProductStockID";
                                    strSqlStockUpdate = string.Format(strSqlStockUpdate, "ProductQty = ProductQty + @ProductQty,");
                                    break;
                                case 2:
                                    //                                    strSqlStockUpdate = @"UPDATE [TBL_PRODUCT_STOCK] SET 
                                    //                                            ProductQty = ProductQty - @ProductQty,
                                    //                                            OperatorID = @OperatorID,
                                    //                                            OperateTime = @OperateTime,
                                    //                                            StockCalcType = @StockCalcType
                                    //                                            where ID =@ProductStockID";
                                    strSqlStockUpdate = string.Format(strSqlStockUpdate, "ProductQty = ProductQty - @ProductQty,");
                                    break;
                                case 3:
                                    //                                    strSqlStockUpdate = @"UPDATE [TBL_PRODUCT_STOCK] SET 
                                    //                                            ProductQty = @ProductQty,
                                    //                                            OperatorID = @OperatorID,
                                    //                                            OperateTime = @OperateTime,
                                    //                                            StockCalcType = @StockCalcType
                                    //                                            where ID =@ProductStockID";
                                    strSqlStockUpdate = string.Format(strSqlStockUpdate, "ProductQty = @ProductQty,");
                                    break;
                                case 0:
                                    //                                    strSqlStockUpdate = @"UPDATE [TBL_PRODUCT_STOCK] SET 
                                    //                                            OperatorID = @OperatorID,
                                    //                                            OperateTime = @OperateTime,
                                    //                                            StockCalcType = @StockCalcType
                                    //                                            where ID =@ProductStockID";
                                    strSqlStockUpdate = string.Format(strSqlStockUpdate, "");
                                    break;
                            }

                            rows = db.SetCommand(strSqlStockUpdate
                                   , db.Parameter("@ProductQty", model.OperateQty, DbType.Int32)
                                   , db.Parameter("@ProductStockID", model.ProductStockID, DbType.Int32)
                                   , db.Parameter("@OperatorID", operationModel.OperatorID, DbType.Int32)
                                   , db.Parameter("@OperateTime", operationModel.OperateTime, DbType.DateTime2)
                                   , db.Parameter("@StockCalcType", model.StockCalcType, DbType.Int32)
                                   , db.Parameter("@BuyingPrice", model.BuyingPrice, DbType.Decimal)
                                   , db.Parameter("@InsuranceQty", model.InsuranceQty, DbType.Int32)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }

                        if (model.ProductStockID == 0 && model.OperateQty == 0)
                        {
                        }
                        else
                        {
                            if (model.OperateType > 0)
                            {
                                string OperateSign = "";
                                switch (model.OperateType)
                                {
                                    case 1:
                                        OperateSign = "+";
                                        break;
                                    case 2:
                                        OperateSign = "-";
                                        break;
                                    case 3:
                                        OperateSign = "=";
                                        break;
                                }

                                string strSqlStockOperateLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG]
                                               (CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OperatorID,OperateTime,Remark,ProductQty)
                                                VALUES
                                               (@CompanyID,@BranchID,@ProductType,@ProductCode,@OperateType,@OperateQty,@OperateSign,@OperatorID,@OperateTime,@Remark,(select ProductQty from [TBL_PRODUCT_STOCK] where  [TBL_PRODUCT_STOCK].ID =@ProductStockID))";



                                rows = db.SetCommand(strSqlStockOperateLog,
                                       db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32),
                                       db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                       db.Parameter("@ProductType", operationModel.Type, DbType.Int32),
                                       db.Parameter("@ProductCode", operationModel.Code, DbType.Int64),
                                       db.Parameter("@OperateType", model.OperateType, DbType.Int32),
                                       db.Parameter("@OperateQty", model.OperateQty, DbType.Int32),
                                       db.Parameter("@OperateSign", OperateSign, DbType.String),
                                       db.Parameter("@OperatorID", operationModel.OperatorID, DbType.Int32),
                                       db.Parameter("@OperateTime", operationModel.OperateTime, DbType.DateTime2),
                                       db.Parameter("@Remark", model.OperateRemark, DbType.String),
                                       db.Parameter("@ProductStockID", model.ProductStockID, DbType.Int32))
                                       .ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                        }
                    }
                    db.CommitTransaction();
                    return true;
                }
            }
            catch (Exception ex)
            {
                LogUtil.Error(ex);
                return false;
            }
        }

        public bool deteleMultiCommodity(DelMultiCommodity_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                if (model == null || model.CodeList == null || model.CodeList.Count == 0)
                {
                    return false;
                }

                foreach (long i in model.CodeList)
                {
                    string strSqlSelect = "select max(ID) from Commodity where code =@Code ";
                    object obj = db.SetCommand(strSqlSelect, db.Parameter("@Code", i, DbType.Int64)).ExecuteScalar();
                    if ((Object.Equals(obj, null)) || (Object.Equals(obj, System.DBNull.Value)) || StringUtils.GetDbInt(obj) == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    int commodityId = StringUtils.GetDbInt(obj);


                    string strSqlHistory = @" INSERT INTO [TBL_HISTORY_COMMODITY] SELECT * FROM [COMMODITY] WHERE ID=@ID ";

                    int rows = db.SetCommand(strSqlHistory,
                                                  db.Parameter("@ID", commodityId, DbType.Int32)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    //删除某个商品的所有商品供应商关系
                    string strSqlSupplierCommoditydel = @" delete from  [SUPPLIER_COMMODITY_RELATIONSHIP] where CommodityID=@CommodityID  ";
                    int checkCount = db.SetCommand(strSqlSupplierCommoditydel, db.Parameter("@CommodityID", commodityId, DbType.Int32)).ExecuteScalar<int>();

                    DateTime dt = DateTime.Now.ToLocalTime();
                    string strSqlupdate = @"update COMMODITY set 
                                            Available = 0,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime =@UpdateTime
                                            where id =@ID";
                    rows = db.SetCommand(strSqlupdate, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                               db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                               db.Parameter("@ID", commodityId, DbType.Int32)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                db.CommitTransaction();
                return true;
            }
        }

        public bool BatchAddCommodity(DataTable dt, Commodity_Model mCommodity)
        {
            List<long> listCommodityCode = new List<long>();
            string destFolder = Const.uploadServer + "/" + Const.strImage + mCommodity.CompanyID.ToString() + "/Commodity/";
            string tempFolder = Const.uploadServer + "/" + Const.strImage + "temp/CommodityImage/";
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSqlInsert = @"
                         insert into COMMODITY ( 
                         CompanyID, BranchID, CategoryID, Code, CommodityName, UnitPrice,MarketingPolicy,PromotionPrice, Specification, Describe, New, Recommended, Available, CreatorID, CreateTime,VisibleForCustomer,DiscountID,IsConfirmed, AutoConfirm, AutoConfirmDays, Manufacturer,ApprovalNumber) 
                         values( 
                         @CompanyID, @BranchID, @CategoryID, @Code, @CommodityName, @UnitPrice,@MarketingPolicy,@PromotionPrice, @Specification, @Describe, @New, @Recommended, @Available, @CreatorID, @CreateTime,@VisibleForCustomer,@DiscountID,@IsConfirmed, @AutoConfirm, @AutoConfirmDays, @Manufacturer,@ApprovalNumber) 
                        ;select @@IDENTITY";

                    string strSqlInsertSort =
                                            @" insert into TBL_COMMODITYSORT ( 
                                                 Companyid, CommodityCode, Sortid) 
                                                 values( 
                                                 @Companyid, @CommodityCode, (SELECT ISNULL(MAX(Sortid),0) + 1 FROM TBL_COMMODITYSORT where CompanyId=@Companyid)) ";

                    string strSqlSel = @"
                                            select Code
                                            from COMMODITY
                                            where ID=@CommodityID";
                    if (dt != null && dt.Rows.Count > 0)
                    {
                        for (int i = 1; i < dt.Rows.Count; i++)
                        {

                            string CommodictCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CommodityCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                            if (string.IsNullOrEmpty(CommodictCode))
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            int MarketingPolicy = 0;
                            switch (dt.Rows[i]["MarketingPolicy"].ToString())
                            {
                                case ("无优惠"):
                                    MarketingPolicy = 0;
                                    break;
                                case ("按等级打折"):
                                    MarketingPolicy = 1;
                                    break;
                                case ("按促销价"):
                                    MarketingPolicy = 2;
                                    break;
                                default:
                                    MarketingPolicy = 0;
                                    break;
                            }
                            //int categoryId = dcCategoryName.First(x => x.Value.Equals(dt.Rows[i]["CategoryName"])).Key;


                            //int discountId = MarketingPolicy == 1 ? dcDiscountName.First(x => x.Value.Equals(dt.Rows[i]["DiscountName"])).Key : 0;

                            decimal promotionPrice = 0;
                            if (MarketingPolicy == 2)
                            {
                                promotionPrice = Convert.ToDecimal(dt.Rows[i]["PromotionPrice"]);
                            }


                            int IsConfirmed = 0;
                            switch (dt.Rows[i]["IsConfirmed"].ToString())
                            {
                                case ("不再需要确认"):
                                    IsConfirmed = 0;
                                    break;
                                case ("需要客户端确认"):
                                    IsConfirmed = 1;
                                    break;
                                case ("需要顾客签字确认"):
                                    IsConfirmed = 2;
                                    break;
                                default:
                                    IsConfirmed = 0;
                                    break;
                            }

                            int AutoConfirm = 0;
                            switch (dt.Rows[i]["AutoConfirm"].ToString())
                            {
                                case ("是"):
                                    AutoConfirm = 1;
                                    break;
                                default:
                                    AutoConfirm = 0;
                                    break;
                            }
                            int commodityId = db.SetCommand(strSqlInsert, db.Parameter("@CompanyID", mCommodity.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", mCommodity.BranchID == -1 ? 0 : mCommodity.BranchID, DbType.Int32)
                                , db.Parameter("@CategoryID", dt.Rows[i]["CategoryID"].ToString() == "-1" ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["CategoryID"]), DbType.Int32)
                                , db.Parameter("@CommodityName", dt.Rows[i]["CommodityName"].ToString(), DbType.String)
                                , db.Parameter("@UnitPrice", Convert.ToDecimal(dt.Rows[i]["UnitPrice"]), DbType.Decimal)
                                , db.Parameter("@MarketingPolicy", MarketingPolicy, DbType.Int32)
                                , db.Parameter("@PromotionPrice", promotionPrice == 0 ? (object)DBNull.Value : promotionPrice, DbType.Decimal)
                                , db.Parameter("@Specification", dt.Rows[i]["Specification"].ToString(), DbType.String)
                                , db.Parameter("@Describe", dt.Rows[i]["Describe"].ToString(), DbType.String)
                                , db.Parameter("@New", dt.Rows[i]["New"].ToString() == "是" ? true : false, DbType.Boolean)
                                , db.Parameter("@Recommended", dt.Rows[i]["Recommended"].ToString() == "是" ? true : false, DbType.Boolean)
                                , db.Parameter("@Available", dt.Rows[i]["Available"].ToString() == "是" ? true : false, DbType.Boolean)
                                , db.Parameter("@CreatorID", mCommodity.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", mCommodity.CreateTime, DbType.DateTime2)
                                , db.Parameter("@VisibleForCustomer", dt.Rows[i]["VisibleForCustomer"].ToString() == "是" ? true : false, DbType.Int32)
                                , db.Parameter("@DiscountID", dt.Rows[i]["DiscountID"].ToString() == "" ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["DiscountID"]), DbType.Int32)
                                , db.Parameter("@Code", StringUtils.GetDbLong(CommodictCode), DbType.Int64)
                                , db.Parameter("@IsConfirmed", IsConfirmed, DbType.Int32)
                                , db.Parameter("@AutoConfirm", AutoConfirm, DbType.Int16)
                                , db.Parameter("@AutoConfirmDays", dt.Rows[i]["AutoConfirmDays"].ToString(), DbType.Int32)
                                , db.Parameter("@Manufacturer", dt.Rows[i]["Manufacturer"].ToString(), DbType.String)
                                , db.Parameter("@ApprovalNumber", dt.Rows[i]["ApprovalNumber"].ToString(), DbType.String)).ExecuteScalar<Int32>();


                            if (commodityId <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                            else
                            {
                                long commodityCode = db.SetCommand(strSqlSel, db.Parameter("@CommodityID", commodityId, DbType.Int32)
                                                        ).ExecuteScalar<Int64>();

                                if (commodityCode <= 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                                else
                                {
                                    int val = db.SetCommand(strSqlInsertSort, db.Parameter("@Companyid", mCommodity.CompanyID, DbType.Int32)
                                                                            , db.Parameter("@CommodityCode", commodityCode, DbType.Int64)).ExecuteNonQuery();

                                    if (val == 0)
                                    {
                                        db.RollbackTransaction();
                                        return false;
                                    }
                                    else
                                    {
                                        if (!string.IsNullOrEmpty(dt.Rows[i]["RelativePath"].ToString().Trim()))
                                        {
                                            string[] strImagesInfo = dt.Rows[i]["RelativePath"].ToString().Split('|');
                                            if (strImagesInfo.Length > 0)
                                            {
                                                string tempedFolder = tempFolder + commodityCode + "/";
                                                if (!Directory.Exists(tempedFolder))
                                                {
                                                    Directory.CreateDirectory(tempedFolder);
                                                }
                                                for (int j = 0; j < strImagesInfo.Length; j++)
                                                {
                                                    if (strImagesInfo[j] != "")
                                                    {
                                                        string[] strImageInfo = strImagesInfo[j].Split(',');
                                                        string orignalFile = Const.uploadServer + strImageInfo[0];
                                                        if (File.Exists(orignalFile))
                                                        {
                                                            Random rd = new Random(new Guid().GetHashCode());
                                                            string filename = string.Format("{0:yyyyMMddHHmmssffff}", DateTime.Now.ToLocalTime()) + (rd.Next(100000) + j).ToString("d5") + Path.GetExtension(strImageInfo[0]);
                                                            if (Convert.ToInt32(strImageInfo[1]) == 0)
                                                            {
                                                                filename = "TC" + filename;
                                                            }
                                                            else
                                                            {
                                                                filename = "T" + filename;
                                                            }

                                                            string strCommand = @"INSERT INTO [IMAGE_COMMODITY]
                                                             ([CompanyID]
                                                             ,[CommodityCode]
                                                             ,[CommodityID]
                                                             ,[ImageType]
                                                             ,[FileName]
                                                             ,[CreatorID]
                                                             ,[CreateTime])
                                                        VALUES
                                                            (@CompanyID
                                                            ,@CommodityCode
                                                            ,@CommodityID
                                                            ,@ImageType
                                                            ,@FileName
                                                            ,@CreatorID
                                                            ,@CreateTime)";

                                                            val = db.SetCommand(strCommand, db.Parameter("@Companyid", mCommodity.CompanyID, DbType.Int32)
                                                                            , db.Parameter("@CommodityCode", commodityCode, DbType.Int64)
                                                                            , db.Parameter("@CommodityID", commodityId, DbType.Int32)
                                                                            , db.Parameter("@ImageType", Convert.ToInt32(strImageInfo[1]), DbType.Int32)
                                                                            , db.Parameter("@FileName", filename, DbType.String)
                                                                            , db.Parameter("@CreatorID", mCommodity.CreatorID, DbType.Int32)
                                                                            , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();


                                                            if (val == 0)
                                                            {
                                                                db.RollbackTransaction();
                                                                return false;
                                                            }
                                                            else
                                                            {
                                                                string tempFile = tempedFolder + filename;
                                                                FileInfo fi = new FileInfo(orignalFile);
                                                                fi.CopyTo(tempFile);
                                                            }
                                                        }
                                                    }
                                                }
                                                listCommodityCode.Add(commodityCode);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        for (int i = 0; i < listCommodityCode.Count; i++)
                        {
                            Common.CommonUtility.CopyFolder(tempFolder + listCommodityCode[i].ToString() + "\\", destFolder + listCommodityCode[i].ToString() + "\\");
                        }
                        db.CommitTransaction();
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public bool BatchAddCommodityBatch(DataTable dt, Product_Stock_Batch_Model mProductStockBatchModel)
        {
            using (DbManager db = new DbManager())
            {
                //获取商品Code
                CommodityDetail_Model commodityDetailModel = null;
                //获取供应商ID
                Supplier_Commodity_RELATION_Model supplierModel = null;
                int? SupplierId = null;
                string BatchNO = null;
                string ExpiryDate = null;
                string Quantity = null;
                string CommodityName = null;
                string SupplierName = null;
                //添加批次表
                string strSqlTblProductStockBatch = @"
                                INSERT  INTO TBL_PRODUCT_STOCK_BATCH 
                                        (CompanyID,BranchID,ProductCode,BatchNO,Quantity,ExpiryDate,OperatorID,OperateTime,SupplierID) 
                                        values (@CompanyID,@BranchID,@ProductCode,@BatchNO,@Quantity,@ExpiryDate,@OperatorID,@OperateTime,@SupplierID) ";
                //获取商品库存记录条数
                string strSqlTblProductStock = @" 
                                select max(ID) from TBL_PRODUCT_STOCK where CompanyID = @CompanyID and BranchID = @BranchID and ProductCode = @ProductCode  ";
                string strSqlTblProductStockInsert = @"
                                INSERT INTO TBL_PRODUCT_STOCK (
                                       CompanyID, BranchID,ProductType,ProductCode,ProductQty,OperatorID,OperateTime,StockCalcType,BuyingPrice,InsuranceQty) 
                                       values (@CompanyID,@BranchID,1,@ProductCode,@ProductQty,@OperatorID,@OperateTime,1,null,null )";
                string strSqlTblProductStockUpdate = @" 
                                update TBL_PRODUCT_STOCK set ProductQty = isnull(ProductQty + @ProductQty,@ProductQty),OperatorID = @OperatorID,OperateTime = @OperateTime where ID = @ID ";
                //添加库log存表
                string strSqlTblProductStockOperatelogInsert = @"
                                INSERT  INTO TBL_PRODUCT_STOCK_OPERATELOG (CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OrderID,
                                      OperatorID,OperateTime,Remark,ProductQty,BatchNO,SupplierID ) select 
                                      @CompanyID,@BranchID,1,@ProductCode,1,@OperateQty,'+',null,@OperatorID,@OperateTime,null,ProductQty,@BatchNO,@SupplierID 
                                      from TBL_PRODUCT_STOCK where ID = @ID ";
                try
                {
                    if (dt != null && dt.Rows.Count > 0)
                    {
                        db.BeginTransaction();
                        for (int i = 1; i < dt.Rows.Count; i++)
                        {
                            SupplierName = dt.Rows[i]["SupplierName"].ToString().Trim();
                            BatchNO = dt.Rows[i]["BatchNO"].ToString().Trim();
                            Quantity = dt.Rows[i]["Quantity"].ToString().Trim();
                            ExpiryDate = dt.Rows[i]["ExpiryDate"].ToString().Trim();
                            CommodityName = dt.Rows[i]["CommodityName"].ToString().Trim();
                            commodityDetailModel = Commodity_DAL.Instance.getCommodityDetailByCommodityModel(mProductStockBatchModel.CompanyID, mProductStockBatchModel.BranchID, CommodityName);
                            if (commodityDetailModel == null) {
                                db.RollbackTransaction();
                                return false;
                            }
                            if (!String.IsNullOrWhiteSpace(SupplierName)) {
                                Supplier_Commodity_RELATION_Model supplierModelMid = new Supplier_Commodity_RELATION_Model();
                                supplierModelMid.CompanyID = mProductStockBatchModel.CompanyID;
                                supplierModelMid.BranchID = mProductStockBatchModel.BranchID;
                                supplierModelMid.SupplierName = SupplierName;
                                supplierModelMid.CommodityCode = commodityDetailModel.CommodityCode;
                                supplierModel = Supplier_DAL.Instance.GetSupplierDetail(supplierModelMid);
                                if (supplierModel == null) {
                                    db.RollbackTransaction();
                                    return false;
                                }
                                SupplierId = supplierModel.SupplierID;
                            }
                            //添加批次表
                            db.SetCommand(strSqlTblProductStockBatch,
                                        db.Parameter("@CompanyID", mProductStockBatchModel.CompanyID, DbType.Int32),
                                        db.Parameter("@BranchID", mProductStockBatchModel.BranchID, DbType.Int32),
                                        db.Parameter("@ProductCode",commodityDetailModel.CommodityCode, DbType.Int64),
                                        db.Parameter("@BatchNO", BatchNO, DbType.String),
                                        db.Parameter("@Quantity", Quantity, DbType.Int32),
                                        db.Parameter("@ExpiryDate", ExpiryDate, DbType.Date),
                                        db.Parameter("@OperatorID", mProductStockBatchModel.OperatorID, DbType.Int32),
                                        db.Parameter("@OperateTime", mProductStockBatchModel.OperateTime, DbType.DateTime2),
                                        db.Parameter("@SupplierID", SupplierId, DbType.Int32)
                                        ).ExecuteNonQuery();
                            //获取商品库存记录条数
                            string strStockID = db.SetCommand(strSqlTblProductStock,
                                                   db.Parameter("@CompanyID", mProductStockBatchModel.CompanyID, DbType.Int32),
                                                   db.Parameter("@BranchID", mProductStockBatchModel.BranchID, DbType.Int32),
                                                   db.Parameter("@ProductCode", commodityDetailModel.CommodityCode, DbType.Int64)
                                                   ).ExecuteScalar<string>();

                            if (string.IsNullOrWhiteSpace(strStockID))
                            { //添加库存

                                db.SetCommand(strSqlTblProductStockInsert,
                                    db.Parameter("@CompanyID", mProductStockBatchModel.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", mProductStockBatchModel.BranchID, DbType.Int32),
                                    db.Parameter("@ProductCode", commodityDetailModel.CommodityCode, DbType.Int64),
                                    db.Parameter("@ProductQty", Quantity, DbType.Int32),
                                    db.Parameter("@OperatorID", mProductStockBatchModel.OperatorID, DbType.Int32),
                                    db.Parameter("@OperateTime", mProductStockBatchModel.OperateTime, DbType.DateTime2)
                                    ).ExecuteNonQuery();

                            }
                            else
                            {
                                //更新库存
                                db.SetCommand(strSqlTblProductStockUpdate,
                                    db.Parameter("@ID", int.Parse(strStockID), DbType.Int32),
                                    db.Parameter("@ProductQty", Quantity, DbType.Int32),
                                    db.Parameter("@OperatorID", mProductStockBatchModel.OperatorID, DbType.Int32),
                                    db.Parameter("@OperateTime", mProductStockBatchModel.OperateTime, DbType.DateTime2)
                                    ).ExecuteNonQuery();
                            }
                            //添加库log存表
                            db.SetCommand(strSqlTblProductStockOperatelogInsert,
                                   db.Parameter("@CompanyID", mProductStockBatchModel.CompanyID, DbType.Int32),
                                   db.Parameter("@BranchID", mProductStockBatchModel.BranchID, DbType.Int32),
                                   db.Parameter("@ProductCode", commodityDetailModel.CommodityCode, DbType.Int64),
                                   db.Parameter("@OperateQty", Quantity, DbType.Int32),
                                   db.Parameter("@OperatorID", mProductStockBatchModel.OperatorID, DbType.Int32),
                                   db.Parameter("@OperateTime", mProductStockBatchModel.OperateTime, DbType.DateTime2),
                                   db.Parameter("@BatchNO", BatchNO, DbType.String),
                                   db.Parameter("@ID", int.Parse(strStockID), DbType.Int32),
                                   db.Parameter("@SupplierID", SupplierId, DbType.Int32)
                               ).ExecuteNonQuery();
                        }
                        db.CommitTransaction();
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }
        public DataTable getCommodityListByCategoryIdForDownload(int companyId, int categoryId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                if (branchId < -1)
                {
                    return null;
                }

                StringBuilder strSql = new StringBuilder();
                strSql.Append(" SELECT  T1.ID CommodityID,T1.New, T1.Recommended, case when ISNULL(T1.CategoryID,'')='' then '无所属' else T4.CategoryName END CategoryName,ISNULL(T1.CategoryID,'-1') CategoryID,T1.CommodityName,T1.Specification, T1.UnitPrice,case(T1.MarketingPolicy) when 0 then '无优惠' when 1 then '按等级打折' else '按促销价' END MarketingPolicy, ISNULL( T1.PromotionPrice,T1.UnitPrice) PromotionPrice,T1.Manufacturer,T1.ApprovalNumber,T1.VisibleForCustomer,T1.Describe,T1.Available, ");

                strSql.Append("( SELECT DiscountName FROM dbo.TBL_DISCOUNT WHERE ID = T1.DiscountID AND available = 1 ) DiscountName,T1.DiscountID,T1.IsConfirmed, case T1.AutoConfirm when 1 then '是' else '否' end as AutoConfirm, case T1.AutoConfirm when 1 then T1.AutoConfirmDays else 0 end as AutoConfirmDays");
                strSql.Append(" FROM COMMODITY T1 WITH(NOLOCK) ");

                if (branchId > 0)
                {
                    strSql.Append(" INNER JOIN [TBL_MARKET_RELATIONSHIP] T6 ");
                    strSql.Append(" on T1.Code = T6.Code ");
                    strSql.Append(" AND T6.Type = 1 ");
                    strSql.Append(" AND T6.Available = 1 ");
                    strSql.Append(" AND T6.BranchID = ");
                    strSql.Append(branchId.ToString());
                }

                strSql.Append(" LEFT JOIN  ");
                strSql.Append(" IMAGE_COMMODITY T3 WITH(NOLOCK) ");
                strSql.Append(" ON T1.ID = T3.CommodityID  ");
                strSql.Append(" AND T3.ImageType = 0  ");
                strSql.Append(" LEFT JOIN  ");
                strSql.Append(" CATEGORY T4  WITH(NOLOCK) ");
                strSql.Append(" ON T1.CategoryID = T4.ID  ");

                strSql.Append(" LEFT JOIN  ");
                strSql.Append(" [TBL_COMMODITYSORT] T5  WITH(NOLOCK) ");
                strSql.Append(" ON [T1].[CODE] = [T5].[COMMODITYCODE]  ");

                strSql.Append(" WHERE T1.Available = 1 ");
                if (categoryId == -1)
                {
                    strSql.Append(" AND T1.CompanyID = ");
                    strSql.Append(companyId.ToString());
                    strSql.Append(" AND( (T4.type = 1 ");
                    strSql.Append(" AND T4.Available = 1) ");
                    strSql.Append(" OR ( T1.CategoryID IS NULL OR T1.CategoryID = -1 ) ) ");

                }
                else if (categoryId == 0)
                {
                    strSql.Append(" AND (T1.CategoryID IS NULL OR T1.CategoryID = -1)");
                    strSql.Append(" AND T1.CompanyID = ");
                    strSql.Append(companyId.ToString());
                }
                else
                {
                    strSql.Append(" AND T1.CategoryID = ");
                    strSql.Append(categoryId.ToString());
                }
                if (branchId == 0)
                {
                    strSql.Append("  AND T1.Code  NOT IN (SELECT Code FROM [TBL_MARKET_RELATIONSHIP] WITH ( NOLOCK ) WHERE CompanyID =" + companyId.ToString() + " and TYPE = 1 and Available = 1 group by Code )");
                }
                strSql.Append(" Order by [T5].[Sortid] ");

                DataTable dt = db.SetCommand(strSql.ToString()).ExecuteDataTable();
                return dt;
            }
        }
        /// <summary>
        /// 批量下载模板中的商品信息  
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="categoryId"></param>
        /// <param name="branchId"></param>
        /// <returns></returns>
        public DataTable getCommodityListForDownloadCommodityBatchTemplate(int companyId, int categoryId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                if (branchId < -1)
                {
                    return null;
                }
                 StringBuilder strSql = new StringBuilder();
                strSql.Append("  SELECT  T1.CommodityName,T1.Code ProductCode FROM COMMODITY T1 WITH(NOLOCK) ");

                if (branchId > 0)
                {
                    strSql.Append(@" INNER JOIN [TBL_MARKET_RELATIONSHIP] T6 
                                        on T1.Code = T6.Code 
                                        AND T6.Type = 1 
                                        AND T6.Available = 1 
                                        AND T6.BranchID = "+ branchId.ToString());
                }

                strSql.Append(@" LEFT JOIN  CATEGORY T4  WITH(NOLOCK)  ON T1.CategoryID = T4.ID 
                                WHERE T1.Available = 1 ");


                if (categoryId == -1)
                {
                    strSql.Append(" AND T1.CompanyID = "+ companyId.ToString()+ " AND( (T4.type = 1 AND T4.Available = 1) OR ( T1.CategoryID IS NULL OR T1.CategoryID = -1 ) ) ");

                }
                else if (categoryId == 0)
                {
                    strSql.Append(" AND (T1.CategoryID IS NULL OR T1.CategoryID = -1) AND T1.CompanyID = "+ companyId.ToString());
                }
                else
                {
                    strSql.Append(" AND T1.CategoryID = " + categoryId.ToString());
                }
                if (branchId == 0)
                {
                    strSql.Append("  AND T1.Code  NOT IN (SELECT Code FROM [TBL_MARKET_RELATIONSHIP] WITH ( NOLOCK ) WHERE CompanyID =" + companyId.ToString() + " and TYPE = 1 and Available = 1 group by Code )");
                }
                strSql.Append(" Order by [T1].[ID] ");

                //StringBuilder strSql = new StringBuilder();
                //strSql.Append("  SELECT  T1.CommodityName,T1.CommodityID FROM Commodity_Test T1  ");
                DataTable dt = db.SetCommand(strSql.ToString()).ExecuteDataTable();
              
                return dt;
            }
        }
        /// <summary>
        /// 批量下载模板中的供应商信息  getBatchListForDownloadCommodityBatchTemplate
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <returns></returns>
        public DataTable getSupplierListForDownloadCommodityBatchTemplate(int companyId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                if (branchId < -1)
                {
                    return null;
                }
                StringBuilder strSql = new StringBuilder();
                strSql.Append(@"  SELECT T1.SupplierName,
                                         T1.SupplierID
                                         FROM SUPPLIER T1 WHERE T1.CompanyID = " + companyId.ToString());
                strSql.Append(" AND Available = 1 ");

                if (branchId > 0)
                {
                    strSql.Append(@" AND T1.BranchID = " + branchId.ToString());
                }
                strSql.Append(" Order by [T1].[SupplierID] ");
                DataTable dt = db.SetCommand(strSql.ToString()).ExecuteDataTable();
                return dt;
            }
        }

        /// <summary>
        /// 批量下载模板中的批次信息  
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <returns></returns>
        public DataTable getBatchListForDownloadCommodityBatchTemplate()
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append("  SELECT '' CommodityName,'' BatchNO,'' Quantity,'' ExpiryDate,'' SupplierName");
                DataTable dt = db.SetCommand(strSql.ToString()).ExecuteDataTable();
                return dt;
            }
        }

        public CommodityDetail_Model getCommodityDetailByCommodityModel(int companyId, int branchId,string commodityName)
        {
            using (DbManager db = new DbManager())
            {
               
                string strSql = @"SELECT 
                                          T1.ID CommodityID ,
                                          T1.CommodityName,
                                          T1.Code CommodityCode 
                                  FROM    [COMMODITY] T1 WITH ( NOLOCK )
                                          INNER JOIN [TBL_MARKET_RELATIONSHIP] T6 
                                          on T1.Code = T6.Code 
                                  WHERE   T1.CompanyID = @CompanyID 
                                          AND T1.CommodityName = @CommodityName
                                          AND T6.Type = 1 
                                          AND T6.Available = 1 
                                          AND T1.Available = 1
                                  ORDER BY T1.ID DESC";

                List<CommodityDetail_Model> detailModelList = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                                        , db.Parameter("@CommodityName", commodityName, DbType.String)).ExecuteList<CommodityDetail_Model>();

                if (detailModelList !=null && detailModelList.Count > 0) {
                    CommodityDetail_Model model = detailModelList[0];
                    model.SameNameNum = detailModelList.Count;
                   return model;
                }
                return null;
            }
        }
        public List<Commodity_Model> getPrintList(List<long> codeList)
        {
            using (DbManager db = new DbManager())
            {
                List<Commodity_Model> list = new List<Commodity_Model>();
                string strWhere = "";
                if (codeList != null && codeList.Count > 0)
                {
                    int index = 0;
                    foreach (long item in codeList)
                    {
                        if (index == 0)
                        {
                            strWhere += item.ToString();
                        }
                        else
                        {
                            strWhere += "," + item;
                        }
                        index++;
                    }
                    string strSql = @" select T1.CommodityName ,T1.ID,T1.Code CommodityCode,T1.Specification,T1.UnitPrice ,T2.CompanyCode
                                from COMMODITY T1
                                INNER JOIN dbo.COMPANY T2 ON T1.CompanyID = T2.ID
                            where T1.ID IN (  
                            select MAX(ID) from  COMMODITY where Available = 1 and Code In ( " + strWhere + ") group by Code)";

                    list = db.SetCommand(strSql).ExecuteList<Commodity_Model>();
                }
                return list;
            }
        }

        #endregion

        public bool UpdateCommoditySort(int companyID, List<CommoditySort_Model> list)
        {
            int count = 0;// 总影响行数
            StringBuilder sb = new StringBuilder();
            if (list != null)
            {
                using (DbManager db = new DbManager())
                {
                    db.BeginTransaction();
                    foreach (var item in list)
                    {
                        string strSql = @"update TBL_COMMODITYSORT set [Sortid]=@Sortid WHERE  [CommodityCode]=@CommodityCode AND CompanyID=@CompanyID;";
                        int res = db.SetCommand(strSql, db.Parameter("@Sortid", item.Sortid, DbType.Int32)
                                    , db.Parameter("@CommodityCode", item.CommodityCode, DbType.Int64)
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();
                        if (res <= 0)
                        {
                            // 没有执行成功,事务回滚
                            db.RollbackTransaction();
                            return false;
                        }
                        else
                        {
                            // 执行成功,总影响行数+1
                            count++;
                        }
                    }
                    // 当总影响行数与List数相同,表示全部执行完成,事务提交.
                    if (count == list.Count)
                    {
                        db.CommitTransaction();
                        return true;
                    }
                    else
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// 更新批次处理
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool updateBatch(List<BatchCommodityOperation_Model.BatchStockOperation_Model> model, int companyID, int UserID)
        {
            using (DbManager db = new DbManager())
            {

                db.BeginTransaction();
                int updateRes = 0;
                DateTime OperateTime = DateTime.Now.ToLocalTime();
                try
                {
                    foreach (var item in model)
                    {
                        string addordecrease = "";
                        int oldQuantity;
                        int difQuantity = 0;
                        string oldQuantitySql = @" select A.Quantity
                                    from TBL_PRODUCT_STOCK_BATCH A
                                    left join BRANCH B on B.ID = A.BranchID
                                    where A.ProductCode = @CommodityCode
                                    and A.ID = @ID";
                        oldQuantity = db.SetCommand(oldQuantitySql,
                                                 db.Parameter("@CommodityCode", item.ProductCode, DbType.Int64),
                                                 db.Parameter("@ID", item.ID, DbType.Int32)
                                                 )
                                                 .ExecuteScalar<Int32>();

                        string oldExpiryDateSupplierSql = @" select A.ExpiryDate,A.SupplierID
                                    from TBL_PRODUCT_STOCK_BATCH A
                                    left join BRANCH B on B.ID = A.BranchID
                                    where A.ProductCode = @CommodityCode
                                    and A.ID = @ID";
                        DateTime oldExpiryDate;
                       string oldSupplierID = null;
                        DataTable dt = db.SetCommand(oldExpiryDateSupplierSql,
                             db.Parameter("@CommodityCode", item.ProductCode, DbType.Int64),
                             db.Parameter("@ID", item.ID, DbType.Int32)
                             )
                             .ExecuteDataTable();
                        oldExpiryDate = StringUtils.GetDbDateTime(dt.Rows[0]["ExpiryDate"]);
                        oldSupplierID = StringUtils.GetDbString(dt.Rows[0]["SupplierID"]);
                        if (oldQuantity > item.Quantity)
                        {
                            addordecrease = "-";
                            difQuantity = oldQuantity - item.Quantity;
                        }
                        else
                        {
                            if (oldQuantity < item.Quantity)
                            {
                                addordecrease = "+";
                                difQuantity = item.Quantity - oldQuantity;
                            }
                        }
                        if (!string.IsNullOrEmpty(addordecrease) || oldExpiryDate != item.ExpiryDate || !oldSupplierID.Equals(item.SupplierID))
                        //if (!string.IsNullOrEmpty(addordecrease) || oldExpiryDate != item.ExpiryDate)
                        {
                            string strSql = @" UPDATE TBL_PRODUCT_STOCK_BATCH SET Quantity=@Quantity
                                                    ,ExpiryDate=@ExpiryDate
                                                    ,OperatorID=@OperatorID
                                                    ,OperateTime=@OperateTime
                                                    ,SupplierID=@SupplierID
                                                    WHERE ID =@ID";

                            updateRes = db.SetCommand(strSql, db.Parameter("@Quantity", item.Quantity, DbType.Int32)
                                                               , db.Parameter("@ExpiryDate", item.ExpiryDate, DbType.DateTime)
                                                               , db.Parameter("@OperatorID", UserID, DbType.Int32)
                                                               , db.Parameter("@OperateTime", OperateTime, DbType.DateTime2)
                                                               , db.Parameter("@SupplierID", item.SupplierID, DbType.String)
                                                               , db.Parameter("@ID", item.ID, DbType.Int32)).ExecuteNonQuery();

                            if (updateRes <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            int ProductQty;
                            string strSqlSelect = @"select ProductQty from TBL_PRODUCT_STOCK
                                            where ProductCode =@CommodityCode
                                              and BranchID = @BranchID";
                            ProductQty = db.SetCommand(strSqlSelect,
                                                           db.Parameter("@CommodityCode", item.ProductCode, DbType.Int64),
                                                           db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteScalar<int>();

                            switch (addordecrease)
                            {
                                case "+":
                                    ProductQty += difQuantity;
                                    break;
                                case "-":
                                    ProductQty -= difQuantity;
                                    break;
                                default:
                                    break;
                            }

                            string updSql = @" UPDATE TBL_PRODUCT_STOCK SET ProductQty=@ProductQty
                                                    ,OperatorID=@OperatorID
                                                    ,OperateTime=@OperateTime
                                                    where ProductCode =@CommodityCode
                                                    and BranchID = @BranchID";

                            updateRes = db.SetCommand(updSql, db.Parameter("@ProductQty", ProductQty)
                                                               , db.Parameter("@CommodityCode", item.ProductCode, DbType.Int64)
                                                               , db.Parameter("@OperatorID", UserID, DbType.Int32)
                                                               , db.Parameter("@OperateTime", OperateTime, DbType.DateTime2)
                                                               , db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteNonQuery();
                            if (updateRes <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            if (!string.IsNullOrEmpty(addordecrease))
                            {
                                string strSqlStockOperateLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG]
                                               (CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OperatorID,OperateTime,Remark,ProductQty,BatchNo,SupplierID)
                                                VALUES
                                               (@CompanyID,@BranchID,@ProductType,@ProductCode,@OperateType,@OperateQty,@OperateSign,@OperatorID,@OperateTime,@Remark,@ProductQty,@BatchNo,@SupplierID)";

                                updateRes = db.SetCommand(strSqlStockOperateLog,
                                       db.Parameter("@CompanyID", companyID, DbType.Int32),
                                       db.Parameter("@BranchID", item.BranchID, DbType.Int32),
                                       db.Parameter("@ProductType", 1),
                                       db.Parameter("@ProductCode", item.ProductCode, DbType.Int64),
                                       db.Parameter("@OperateType", 3),
                                       db.Parameter("@OperateQty", difQuantity, DbType.Int32),
                                       db.Parameter("@OperateSign", addordecrease, DbType.String),
                                       db.Parameter("@OperatorID", UserID, DbType.Int32),
                                       db.Parameter("@OperateTime", OperateTime, DbType.DateTime2),
                                       db.Parameter("@Remark", null),
                                       db.Parameter("@ProductQty", ProductQty, DbType.Int32),
                                       db.Parameter("@BatchNo", item.BatchNO, DbType.String),
                                       db.Parameter("@SupplierID", item.SupplierID , DbType.String))
                                       .ExecuteNonQuery();
                            }

                            if (updateRes <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    if (updateRes > 0)
                    {
                        db.CommitTransaction();
                        return true;
                    }
                    else {
                        return true;
                    }
                }
                catch (Exception ex) {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }

        /// <summary>
        /// 取得批次一览
        /// </summary>
        /// <param name="commodityCode"></param>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <returns></returns>
        public List<BatchDetail_Model> getCommodityBatchStock(long commodityCode, int companyId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select B.BranchName, A.CompanyID, A.BranchID, A.ID, A.BatchNO, A.Quantity, A.ExpiryDate, A.OperatorID, A.OperateTime, A.ProductCode ,
                                          A.SupplierID,C.SupplierName,DATEDIFF(DAY, GETDATE(), A.ExpiryDate) AS dayDiffNum  
                                    from TBL_PRODUCT_STOCK_BATCH A
                                    left join BRANCH B on B.ID = A.BranchID
                                    left join Supplier C ON C.SupplierID = A.SupplierID
                                    where A.ProductCode = @CommodityCode";
                if (branchId > 0)
                {
                    strSql += " AND A.BranchId=@BranchId";
                }
                strSql += " ORDER BY A.ID DESC";

                List<BatchDetail_Model> list = db.SetCommand(strSql,
                                             db.Parameter("@BranchId", branchId, DbType.Int32),
                                             db.Parameter("@CommodityCode", commodityCode, DbType.Int64)
                                             )
                                             .ExecuteList<BatchDetail_Model>();
                return list;
            }

        }

        /// <summary>
        /// 删除批次处理
        /// </summary>
        /// <param name="accountId"></param>
        /// <param name="commodityId"></param>
        /// <returns></returns>
        public bool deleteBatch(int accountId, int ID, int Quantity, int BranchID, long ProductCode, string BatchNO, int companyID, int UserID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    int ProductQty;
                    string strSqlSelect = @"select ProductQty from TBL_PRODUCT_STOCK
                                            where ProductCode =@CommodityCode
                                              and BranchID = @BranchID";
                    ProductQty = db.SetCommand(strSqlSelect,
                                                   db.Parameter("@CommodityCode", ProductCode, DbType.Int64),
                                                   db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteScalar<int>();

                    int rows = 0;

                    if (Quantity < 0)
                    {
                        return false;
                    }

                    string strSql = @"
                                delete from TBL_PRODUCT_STOCK_BATCH
                                where ID = @ID";

                    rows = db.SetCommand(strSql, db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery();

                    if (Quantity > 0)
                    {
                        ProductQty -= Quantity;

                        string updSql = @" UPDATE TBL_PRODUCT_STOCK SET ProductQty=@ProductQty
                                                    ,OperatorID=@OperatorID
                                                    ,OperateTime=@OperateTime
                                                    where ProductCode =@CommodityCode
                                                    and BranchID = @BranchID";

                        rows = db.SetCommand(updSql, db.Parameter("@ProductQty", ProductQty)
                                                           , db.Parameter("@CommodityCode", ProductCode, DbType.Int64)
                                                           , db.Parameter("@OperatorID", UserID, DbType.Int32)
                                                           , db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                           , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteNonQuery();
                        if (rows <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        string OperateSign = "-";
                        string strSqlStockOperateLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG]
                                               (CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OperatorID,OperateTime,Remark,ProductQty,BatchNo)
                                                VALUES
                                               (@CompanyID,@BranchID,@ProductType,@ProductCode,@OperateType,@OperateQty,@OperateSign,@OperatorID,@OperateTime,@Remark,@ProductQty,@BatchNo)";



                        rows = db.SetCommand(strSqlStockOperateLog,
                               db.Parameter("@CompanyID", companyID, DbType.Int32),
                               db.Parameter("@BranchID", BranchID, DbType.Int32),
                               db.Parameter("@ProductType", 1),
                               db.Parameter("@ProductCode", ProductCode, DbType.Int64),
                               db.Parameter("@OperateType", 3),
                               db.Parameter("@OperateQty", Quantity, DbType.Int32),
                               db.Parameter("@OperateSign", OperateSign, DbType.String),
                               db.Parameter("@OperatorID", UserID, DbType.Int32),
                               db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                               db.Parameter("@Remark", null),
                               db.Parameter("@ProductQty", ProductQty, DbType.Int32),
                               db.Parameter("@BatchNo", BatchNO, DbType.String))
                               .ExecuteNonQuery();
                    }

                    if (rows > 0)
                    {
                        db.CommitTransaction();
                        return true;
                    }
                    else
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }

        public List<StorageDetail_Model> getStorageDetail(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select B.BranchName,L.BatchNO,L.BranchID,L.Quantity,L.ExpiryDate,L.ID,L.Status from TBL_PRODUCT_HQ_STOCK_LOG L,BRANCH B
                                  where B.ID=L.BranchID and ProductCode=@ProductCode";
                if (model.BranchID > 0)
                {
                    strSql += " and L.BranchID=@BranchID";
                }
                List<StorageDetail_Model> list = db.SetCommand(strSql,
                    db.Parameter("@ProductCode", model.CommodityCode, DbType.String),
                    db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<StorageDetail_Model>();
                return list;
            }
        }

        public int getQuantity(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "select Quantity from TBL_PRODUCT_HQ_STOCK where ProductCode=@ProductCode";
                int quantity = db.SetCommand(strSql,
                      db.Parameter("@ProductCode", model.CommodityCode, DbType.String)).ExecuteScalar<int>();
                return quantity;
            }
        }

        public bool operateQuantity(StorageDetail_Model model, int CompanyID, int UserID)
        {
            using (DbManager db = new DbManager())
            {

                int row = 0;
                string getProCdSql = "select * from TBL_PRODUCT_HQ_STOCK where ProductCode=@ProductCode";
                StorageDetail_Model result = db.SetCommand(getProCdSql
                    , db.Parameter("@ProductCode", model.ProductCode, DbType.String)).ExecuteObject<StorageDetail_Model>();
                if (result == null)
                {
                    string strSql = @"insert into TBL_PRODUCT_HQ_STOCK (CompanyID,ProductCode,Quantity,OperatorID,OperateTime)
                                                         values(@CompanyID,@ProductCode,@Quantity,@OperatorID,@OperateTime)";
                    row = db.SetCommand(strSql,
                      db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                      db.Parameter("@ProductCode", model.ProductCode, DbType.String),
                      db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                      db.Parameter("@OperatorID", UserID, DbType.Int32),
                      db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                }
                else
                {
                    string strSql = @"update TBL_PRODUCT_HQ_STOCK set Quantity=Quantity+@Quantity,
                                                                      OperatorID=@OperatorID,
                                                                      OperateTime=@OperateTime
                                                                where ProductCode=@ProductCode";
                    row = db.SetCommand(strSql,
                      db.Parameter("@ProductCode", model.ProductCode, DbType.String),
                      db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                      db.Parameter("@OperatorID", UserID, DbType.Int32),
                      db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                }
                if (row > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        public bool applyCommodityCode(StorageDetail_Model model, int CompanyID, int BranchID, int UserID)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = @"insert into TBL_PRODUCT_HQ_STOCK_LOG (CompanyID,BranchID,ProductCode,Quantity,Status,OperatorID,OperateTime)
                                                         values(@CompanyID,@BranchID,@ProductCode,@Quantity,1,@OperatorID,@OperateTime)";
                int row = db.SetCommand(strSql,
                      db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                       db.Parameter("@BranchID", BranchID, DbType.Int32),
                      db.Parameter("@ProductCode", model.ProductCode, DbType.String),
                      db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                      db.Parameter("@OperatorID", UserID, DbType.Int32),
                      db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();

                if (row > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        public bool agreeCommodityCode(StorageDetail_Model model, int UserID)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = @"update  TBL_PRODUCT_HQ_STOCK_LOG set Status=2,
                                                                       BatchNO=@BatchNO,
                                                                       ExpiryDate=@ExpiryDate,
                                                                       OperatorID=@OperatorID,
                                                                       OperateTime=@OperateTime
                                                                 where ID=@ID";
                int row = db.SetCommand(strSql,
                       db.Parameter("@ID", model.ID, DbType.Int32),
                       db.Parameter("@BatchNO", model.BatchNO, DbType.String),
                       db.Parameter("@ExpiryDate", model.ExpiryDate, DbType.DateTime2),
                      db.Parameter("@OperatorID", UserID, DbType.Int32),
                      db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                if (row != 1)
                {
                    return false;
                }
                string getResultSql = "select ProductCode,Quantity from TBL_PRODUCT_HQ_STOCK_LOG where ID=@ID";
                StorageDetail_Model result = db.SetCommand(getResultSql,
                       db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteObject<StorageDetail_Model>();
                string minusQuaSql = "update TBL_PRODUCT_HQ_STOCK set Quantity=Quantity-@Quantity where ProductCode=@ProductCode";
                row = db.SetCommand(minusQuaSql,
                       db.Parameter("@Quantity", result.Quantity, DbType.Int32),
                       db.Parameter("@ProductCode", result.ProductCode, DbType.String)).ExecuteNonQuery();

                if (row == 1)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        public bool negativeCommodityCode(StorageDetail_Model model, int UserID)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = @"update  TBL_PRODUCT_HQ_STOCK_LOG set Status=3,
                                                                       OperatorID=@OperatorID,
                                                                       OperateTime=@OperateTime
                                                                 where ID=@ID";
                int row = db.SetCommand(strSql,
                       db.Parameter("@ID", model.ID, DbType.Int32),
                      db.Parameter("@OperatorID", UserID, DbType.Int32),
                      db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();

                if (row > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
        public bool confirmCommodityCode(StorageDetail_Model model, int UserID)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = @"update  TBL_PRODUCT_HQ_STOCK_LOG set Status=4,
                                                                       OperatorID=@OperatorID,
                                                                       OperateTime=@OperateTime
                                                                 where ID=@ID";
                int row = db.SetCommand(strSql,
                       db.Parameter("@ID", model.ID, DbType.Int32),
                      db.Parameter("@OperatorID", UserID, DbType.Int32),
                      db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                if (row != 1)
                {
                    return false;
                }
                string getResultSql = "select CompanyID,BranchID,ProductCode,BatchNO,Quantity,ExpiryDate from TBL_PRODUCT_HQ_STOCK_LOG where ID=@ID";
                StorageDetail_Model result = db.SetCommand(getResultSql,
                       db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteObject<StorageDetail_Model>();
                string updSql = @" UPDATE TBL_PRODUCT_STOCK SET ProductQty=ProductQty+@ProductQty
                                                    ,OperatorID=@OperatorID
                                                    ,OperateTime=@OperateTime
                                                    where ProductCode =@ProductCode
                                                    and BranchID = @BranchID";

                row = db.SetCommand(updSql, db.Parameter("@ProductQty", result.Quantity)
                                                   , db.Parameter("@ProductCode", result.ProductCode, DbType.Int64)
                                                   , db.Parameter("@OperatorID", UserID, DbType.Int32)
                                                   , db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                   , db.Parameter("@BranchID", result.BranchID, DbType.Int32)).ExecuteNonQuery();
                if (row != 1)
                {
                    return false;
                }
                string addBatchNo = @"INSERT INTO TBL_PRODUCT_STOCK_BATCH 
                                               (CompanyID,BranchID,ProductCode,BatchNO,Quantity,ExpiryDate,OperatorID,OperateTime)
                                                VALUES
                                               (@CompanyID,@BranchID,@ProductCode,@BatchNO,@Quantity,@ExpiryDate,@OperatorID,@OperateTime)";
                row = db.SetCommand(addBatchNo,
                      db.Parameter("@CompanyID", result.CompanyID, DbType.Int32),
                      db.Parameter("@BranchID", result.BranchID, DbType.Int32),
                      db.Parameter("@ProductCode", result.ProductCode, DbType.String),
                      db.Parameter("@BatchNO", result.BatchNO, DbType.String),
                      db.Parameter("@Quantity", result.Quantity, DbType.Int32),
                      db.Parameter("@ExpiryDate", result.ExpiryDate, DbType.DateTime2),
                      db.Parameter("@OperatorID", UserID, DbType.Int32),
                      db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                if (row != 1)
                {
                    return false;
                }
                string strSqlStockOperateLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG]
                                               (CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OperatorID,OperateTime,Remark,ProductQty)
                                                VALUES
                                               (@CompanyID,@BranchID,@ProductType,@ProductCode,@OperateType,@OperateQty,@OperateSign,@OperatorID,@OperateTime,@Remark,@ProductQty)";

                row = db.SetCommand(strSqlStockOperateLog,
                       db.Parameter("@CompanyID", result.CompanyID, DbType.Int32),
                       db.Parameter("@BranchID", result.BranchID, DbType.Int32),
                       db.Parameter("@ProductType", 1),
                       db.Parameter("@ProductCode", result.ProductCode, DbType.Int64),
                       db.Parameter("@OperateType", 3),
                       db.Parameter("@OperateQty", result.Quantity, DbType.Int32),
                       db.Parameter("@OperateSign", "+", DbType.String),
                       db.Parameter("@OperatorID", UserID, DbType.Int32),
                       db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                       db.Parameter("@Remark", null),
                       db.Parameter("@ProductQty", result.Quantity, DbType.Int32)).ExecuteNonQuery();
                if (row == 1)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 获取商品列表
        /// </summary>
        /// <param name="Commodity_Model"></param>
        /// <returns></returns>
        public List<Commodity_Model> GetCommodityList(Commodity_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT ID,CommodityName,CompanyID,BranchID,CategoryID,Code,ID AS CommodityID,
                                            '|' + ISNULL(CommodityName,'')
                                           +'|' + ISNULL(convert(varchar(32),Code),'') 
                                           +'|' + ISNULL(Manufacturer,'') 
                                           +'|' + ISNULL(ApprovalNumber,'') AS SearchOut 
                                          FROM COMMODITY WHERE Available = 1 AND CompanyID = @CompanyID ORDER BY CommodityName";

                List<Commodity_Model> list = new List<Commodity_Model>();
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteList<Commodity_Model>();
                return list;
            }
        }
    }
}
