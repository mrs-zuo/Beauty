using BLToolkit.Data;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
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

        public List<ProductList_Model> getCommodityListByCompanyId(int companyId, int customerId, int imageHeight, int imageWidth)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT DISTINCT T1.Code AS ProductCode ,T1.ID AS ProductID ,T1.CommodityName AS ProductName ,T1.UnitPrice ,T1.New ,T1.Recommended ,T1.Specification ,T3.Sortid,ISNULL(T1.CommodityName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField, ";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType6
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CommodityCode as nvarchar(16))+ '/' + T4.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ThumbnailURL ";
                //顾客端 抽取顾客相关分店下的服务

                strSql += @" FROM    [COMMODITY] T1 WITH ( NOLOCK )
                                    INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 ON T1.Code = T2.Code AND T2.Available = 1 AND T2.Type = 1 
                                    LEFT JOIN [TBL_COMMODITYSORT] T3 WITH ( NOLOCK ) ON T1.Code = T3.CommodityCode
                                    LEFT JOIN [IMAGE_COMMODITY] T4 ON T1.ID = T4.CommodityID AND T4.ImageType = 0 
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T1.Available = 1
                                    AND T1.VisibleForCustomer = 1
                                    AND T2.BranchID IN ( SELECT BranchID
                                                         FROM   dbo.RELATIONSHIP
                                                         WHERE  CustomerID = @CustomerID
                                                                AND Available = 1 )
                            ORDER BY T1.New DESC ,
                                    T1.Recommended DESC ,
                                    T3.Sortid ";

                List<ProductList_Model> list = new List<ProductList_Model>();

                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ProductList_Model>();

                return list;
            }
        }

        public List<ProductList_Model> getCommodityListByCategoryID(int companyId, int categoryId, int customerId, bool selectAll, int imageHeight, int imageWidth)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                if (selectAll)
                {
                    strSql += @" WITH subQuery(ParentID,ID) AS  
                                (SELECT ParentID,ID FROM dbo.CATEGORY WHERE ParentID=@CategoryID 
                                UNION ALL 
                                SELECT A.ParentID,A.ID FROM dbo.CATEGORY A,subQuery B WHERE 
                                    A.ParentID=B.ID) ";
                }
                strSql += " SELECT DISTINCT T1.Code AS ProductCode ,T1.ID AS ProductID ,T1.CommodityName AS ProductName ,T1.UnitPrice ,T1.New ,T1.Recommended ,T1.Specification ,T3.Sortid,ISNULL(T1.CommodityName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField, ";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType6
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CommodityCode as nvarchar(16))+ '/' + T4.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ThumbnailURL ";

                strSql += @" FROM    [COMMODITY] T1 WITH ( NOLOCK )
                                    INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 ON T1.Code = T2.Code AND T2.Available = 1 AND T2.Type = 1 
                                    LEFT JOIN [TBL_COMMODITYSORT] T3 WITH ( NOLOCK ) ON T1.Code = T3.CommodityCode
                                    LEFT JOIN [IMAGE_COMMODITY] T4 ON T1.ID = T4.CommodityID AND T4.ImageType = 0 
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T1.Available = 1
                                    AND T1.VisibleForCustomer = 1
                                    AND T2.BranchID IN ( SELECT BranchID
                                                         FROM   dbo.RELATIONSHIP
                                                         WHERE  CustomerID = @CustomerID
                                                                AND Available = 1 )";

                if (!selectAll)
                {
                    strSql += " AND T1.CategoryID = @CategoryID and T1.Available = 1 ";
                }
                else
                {
                    strSql += " AND (T1.CategoryID = @CategoryID or T1.CategoryID in(Select ID from subQuery)) and T1.Available = 1 ";
                }

                strSql += " ORDER BY T1.New DESC , T1.Recommended DESC ,T3.Sortid ";

                List<ProductList_Model> list = new List<ProductList_Model>();
                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CategoryID", categoryId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ProductList_Model>();

                return list;
            }
        }

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

        public PromotionProductDetail_Model GetPromotionCommodityDetailByID(int companyID, string promotionID, int commodityID,int customerId)
        {
            using (DbManager db = new DbManager())
            {
                PromotionProductDetail_Model model = new PromotionProductDetail_Model();
                string strSql = @" SELECT  T1.ProductPromotionName ,
                                            T2.UnitPrice ,
                                            T1.DiscountPrice ,
                                            T1.ProductID ,
                                            T2.Code AS ProductCode ,
                                            T1.SoldQuantity ,
                                            T1.Notice,T1.ProductType,T1.PromotionID,ISNULL(T3.PRValue,-1) PRValue
                                    FROM    [TBL_PROMOTION_PRODUCT] T1 WITH ( NOLOCK )
                                            INNER JOIN [COMMODITY] T2 WITH ( NOLOCK ) ON T1.ProductID = T2.ID
											LEFT JOIN [TBL_PROMOTION_RULE] T3 WITH ( NOLOCK ) 
											ON T1.ProductID = T3.ProductID AND T3.ProductType = 1 AND T1.PromotionID = T3.PromotionID AND T3.PRCode = 1
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.ProductID = @ProductID
                                            AND T1.PromotionID = @PromotionID ";

                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                      , db.Parameter("@ProductID", commodityID, DbType.Int32)
                      , db.Parameter("@PromotionID", promotionID, DbType.String)).ExecuteObject<PromotionProductDetail_Model>();

                if (model != null)
                {
                    strSql = @" SELECT distinct  T1.BranchID ,
                                        T2.BranchName
                                FROM    [TBL_PROMOTION_BRANCH] T1 WITH ( NOLOCK )
                                        INNER JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T2.ID = T1.BranchID
										INNER JOIN [RELATIONSHIP] T3 ON T1.BranchID = T3.BranchID AND T3.Available = 1 AND T3.CustomerID=@CustomerID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.PromotionCode = @PromotionID
                                        AND T2.Available = 1 ";

                    model.BranchList = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)
                                     , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                     , db.Parameter("@PromotionID", promotionID, DbType.String)).ExecuteList<Model.Table_Model.SimpleBranch_Model>();
                }

                return model;
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

        public List<ProductInfoList_Model> getProductInfoList(CartOperation_Model operationModel)
        {
            using (DbManager db = new DbManager())
            {
                List<ProductInfoList_Model> list = new List<ProductInfoList_Model>();

                if (operationModel != null && operationModel.CartIDList != null && operationModel.CartIDList.Count > 0)
                {
                    foreach (string item in operationModel.CartIDList)
                    {
                        string strcartSql = @" SELECT  BranchID,ProductCode,ProductType,Quantity 
                                                FROM    TBL_CART
                                                WHERE   CartID = @CartID
                                                        AND CustomerID = @CustomerID
                                                        AND CompanyID=@CompanyID
                                                        AND Status = 1 ";
                        DataTable dt = db.SetCommand(strcartSql
                            , db.Parameter("@CartID", item, DbType.String)
                            , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                            , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)).ExecuteDataTable();

                        if (dt == null || dt.Rows.Count != 1)
                        {
                            return null;
                        }

                        int branchID = StringUtils.GetDbInt(dt.Rows[0]["BranchID"]);
                        long productCode = StringUtils.GetDbLong(dt.Rows[0]["ProductCode"]);
                        int productType = StringUtils.GetDbInt(dt.Rows[0]["ProductType"]);
                        int quantity = StringUtils.GetDbInt(dt.Rows[0]["Quantity"]);
                        string sql = "";
                        if (productType == 1)
                        {
                            #region 商品
                            sql = @" SELECT  T1.ID ,
                                            T1.Code ,
                                            1 AS ProductType ,
                                            CommodityName Name ,
                                            CASE WHEN T1.MarketingPolicy = 0 THEN UnitPrice
                                                 WHEN T1.MarketingPolicy = 1
                                                      AND ISNULL(T5.CardID, 0) != 0
                                                 THEN CONVERT(DECIMAL(18, 2), dbo.sslr(ISNULL(T5.Discount, 1) * T1.UnitPrice, 2))
                                                 WHEN T1.MarketingPolicy = 2 THEN T1.PromotionPrice
                                                 ELSE T1.UnitPrice
                                            END PromotionPrice ,
                                            UnitPrice ,
                                            MarketingPolicy ,
                                            '2099-12-31 23:59:59' AS ExpirationDate ,
                                            T8.CardID ,
                                            T8.CardName,
                                            T6.ID AS BranchID,
                                            T6.BranchName ,
                                            @Quantity AS Quantity ,ISNULL(T5.Discount, 1)  Discount
                                    FROM    Commodity T1 WITH ( NOLOCK )
                                            LEFT JOIN ( SELECT  T4.Discount ,
                                                                T4.DiscountID ,
                                                                T7.CardID ,
                                                                T9.CardName
                                                        FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                                INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON T2.DefaultCardNo = T3.UserCardNo
                                                                                                  AND T2.UserID = T3.UserID
                                                                INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID
                                                                                                  AND T7.BranchID = @BranchID
                                                                INNER JOIN [TBL_CARD_DISCOUNT] T4 ON T3.CardID = T4.CardID
                                                                INNER JOIN [MST_CARD] T9 ON T3.CardID = T9.ID
                                                        WHERE   T2.UserID = @CustomerID
                                                      ) T5 ON T1.DiscountID = T5.DiscountID
                                            LEFT JOIN ( SELECT TOP 1
                                                                T1.ID AS CardID ,
                                                                T1.CardName ,
                                                                T2.UserID
                                                        FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                                INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON T2.DefaultCardNo = T3.UserCardNo
                                                                INNER JOIN [MST_CARD] T1 ON T3.CardID = T1.ID
                                                                INNER JOIN [MST_CARD_BRANCH] T7 ON T1.ID = T7.CardID
                                                                                                  AND T7.BranchID = @BranchID
                                                        WHERE   T2.UserID = @CustomerID
                                                      ) T8 ON T8.UserID = @CustomerID
                                            LEFT JOIN [Branch] T6 WITH ( NOLOCK ) ON T6.ID = @BranchID
                                    WHERE   T1.Code = @ProductCode
                                            AND T1.Available = 1 ";
                            #endregion
                        }
                        else
                        {
                            #region 服务
                            sql = @" SELECT  T1.ID ,
                                            T1.Code ,
                                            0 AS ProductType ,
                                            ServiceName Name ,
                                            CASE WHEN T1.MarketingPolicy = 0 THEN UnitPrice
                                                 WHEN T1.MarketingPolicy = 1
                                                      AND ISNULL(T5.CardID, 0) != 0
                                                 THEN CONVERT(DECIMAL(18, 2), dbo.sslr(ISNULL(T5.Discount, 1) * T1.UnitPrice, 2))
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
                                            T8.CardName,
                                            T6.ID AS BranchID ,
                                            T6.BranchName ,
                                            @Quantity AS Quantity  ,ISNULL(T5.Discount, 1) Discount
                                    FROM    [SERVICE] T1 WITH ( NOLOCK )
                                            LEFT JOIN ( SELECT  T4.Discount ,
                                                                T4.DiscountID ,
                                                                T7.CardID ,
                                                                T9.CardName
                                                        FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                                INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON T2.DefaultCardNo = T3.UserCardNo
                                                                                                  AND T2.UserID = T3.UserID
                                                                INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID
                                                                                                  AND T7.BranchID = @BranchID
                                                                INNER JOIN [TBL_CARD_DISCOUNT] T4 ON T3.CardID = T4.CardID
                                                                INNER JOIN [MST_CARD] T9 ON T3.CardID = T9.ID
                                                        WHERE   T2.UserID = @CustomerID
                                                      ) T5 ON T1.DiscountID = T5.DiscountID
                                            LEFT JOIN ( SELECT TOP 1
                                                                T1.ID AS CardID ,
                                                                T1.CardName ,
                                                                T2.UserID
                                                        FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                                LEFT JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON T2.DefaultCardNo = T3.UserCardNo
                                                                LEFT JOIN [MST_CARD] T1 ON T3.CardID = T1.ID
                                                                LEFT JOIN [MST_CARD_BRANCH] T7 ON T1.ID = T7.CardID
                                                                                                  AND T7.BranchID = @BranchID
                                                        WHERE   T2.UserID = @CustomerID
                                                      ) T8 ON T8.UserID = @CustomerID
                                            LEFT JOIN [Branch] T6 WITH ( NOLOCK ) ON T6.ID = @BranchID
                                    WHERE   T1.Code = @ProductCode
                                            AND T1.Available = 1  ";
                            #endregion
                        }

                        ProductInfoList_Model model = db.SetCommand(sql
                            , db.Parameter("@BranchID", branchID, DbType.Int32)
                            , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                            , db.Parameter("@ProductCode", productCode, DbType.Int64)
                            , db.Parameter("@Quantity", quantity, DbType.Int32)).ExecuteObject<ProductInfoList_Model>();

                        if (model == null)
                        {
                            return null;
                        }
                        model.CartID = item;
                        list.Add(model);
                    }
                }

                return list;

            }
        }

        public List<ProductInfoList_Model> getProductInfoListForWeb(CartOperation_Model operationModel)
        {
            using (DbManager db = new DbManager())
            {
                List<ProductInfoList_Model> list = new List<ProductInfoList_Model>();

                if (operationModel != null && operationModel.CartIDList != null && operationModel.CartIDList.Count > 0)
                {
                    foreach (string item in operationModel.CartIDList)
                    {
                        string strcartSql = @" SELECT  BranchID,ProductCode,ProductType,Quantity 
                                                FROM    TBL_CART
                                                WHERE   CartID = @CartID
                                                        AND CustomerID = @CustomerID
                                                        AND CompanyID=@CompanyID
                                                        AND Status = 1 ";
                        DataTable dt = db.SetCommand(strcartSql
                            , db.Parameter("@CartID", item, DbType.String)
                            , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                            , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)).ExecuteDataTable();

                        if (dt == null || dt.Rows.Count != 1)
                        {
                            return null;
                        }

                        int branchID = StringUtils.GetDbInt(dt.Rows[0]["BranchID"]);
                        long productCode = StringUtils.GetDbLong(dt.Rows[0]["ProductCode"]);
                        int productType = StringUtils.GetDbInt(dt.Rows[0]["ProductType"]);
                        int quantity = StringUtils.GetDbInt(dt.Rows[0]["Quantity"]);
                        string sql = "";
                        if (productType == 1)
                        {
                            #region 商品
                            sql = @" SELECT  T1.ID ,
                                            T1.Code ,
                                            1 AS ProductType ,
                                            T1.CommodityName Name ,
                                            T1.PromotionPrice ,
                                            T1.UnitPrice ,
                                            T1.MarketingPolicy ,
                                            '2099-12-31 23:59:59' AS ExpirationDate ,
                                            T6.ID AS BranchID,
                                            T6.BranchName ,
                                            @Quantity AS Quantity ,T1.DiscountID
                                    FROM    Commodity T1 WITH ( NOLOCK )
                                            LEFT JOIN [Branch] T6 WITH ( NOLOCK ) ON T6.ID = @BranchID
                                    WHERE   T1.Code = @ProductCode
                                            AND T1.Available = 1 ";
                            #endregion
                        }
                        else
                        {
                            #region 服务
                            sql = @" SELECT  T1.ID ,
                                            T1.Code ,
                                            0 AS ProductType ,
                                            ServiceName Name ,
                                            T1.PromotionPrice ,
                                            T1.UnitPrice ,
                                            T1.MarketingPolicy ,
                                            CASE T1.HaveExpiration
                                              WHEN 0 THEN '2099-12-31'
                                              ELSE DATEADD(d, ISNULL(T1.ExpirationDate, 0), GETDATE())
                                            END AS ExpirationDate ,
                                            T6.ID AS BranchID ,
                                            T6.BranchName ,
                                            @Quantity AS Quantity ,T1.DiscountID
                                    FROM    [SERVICE] T1 WITH ( NOLOCK )
                                            LEFT JOIN [Branch] T6 WITH ( NOLOCK ) ON T6.ID = @BranchID
                                    WHERE   T1.Code = @ProductCode
                                            AND T1.Available = 1  ";
                            #endregion
                        }

                        ProductInfoList_Model model = db.SetCommand(sql
                            , db.Parameter("@BranchID", branchID, DbType.Int32)
                            , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                            , db.Parameter("@ProductCode", productCode, DbType.Int64)
                            , db.Parameter("@Quantity", quantity, DbType.Int32)).ExecuteObject<ProductInfoList_Model>();

                        if (model == null)
                        {
                            return null;
                        }

                        if (model.MarketingPolicy == 0)
                        {
                            model.PromotionPrice = model.UnitPrice;
                            model.CardID = 0;
                            model.CardName = "不使用e账户";
                        }
                        else if (model.MarketingPolicy == 1)
                        {
                            string strSqlCard = @"  SELECT  T4.Discount ,
                                                                T7.CardID ,
                                                                T9.CardName
                                                        FROM    [CUSTOMER] T2 WITH ( NOLOCK )
                                                                INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH ( NOLOCK ) ON T2.DefaultCardNo = T3.UserCardNo
                                                                                                  AND T2.UserID = T3.UserID
                                                                INNER JOIN [MST_CARD_BRANCH] T7 ON T3.CardID = T7.CardID
                                                                                                  AND T7.BranchID = @BranchID
                                                                INNER JOIN [TBL_CARD_DISCOUNT] T4 ON T3.CardID = T4.CardID
                                                                INNER JOIN [MST_CARD] T9 ON T3.CardID = T9.ID
                                                        WHERE   T2.UserID = @CustomerID and T4.DiscountID=@DiscountID ";

                            ProductCardInfo_Model mCard = db.SetCommand(strSqlCard
                            , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                            , db.Parameter("@DiscountID", model.DiscountID, DbType.Int32)
                            , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteObject<ProductCardInfo_Model>();

                            if (mCard == null)
                            {
                                model.PromotionPrice = model.UnitPrice;
                                model.CardID = 0;
                                model.CardName = "不使用e账户";
                                model.Discount = 1;
                            }
                            else
                            {
                                model.PromotionPrice = Math.Round(model.UnitPrice * mCard.Discount, 2);
                                model.CardName = mCard.CardName;
                                model.CardID = mCard.CardID;
                                model.Discount = mCard.Discount;
                            }
                        }
                        else
                        {
                            string strSqlCard = @"  SELECT TOP 1  T1.ID AS CardID ,
                                    T1.CardName 
                            FROM    [MST_CARD] T1 WITH ( NOLOCK )
                                    INNER JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T1.ID = T2.CardID
                                    INNER JOIN [MST_CARD_BRANCH] T3 WITH ( NOLOCK ) ON T1.ID = T3.CardID
                            WHERE   T2.UserID = @CustomerID
                                    AND T1.CardTypeID = 1
                                    AND T3.BranchID = @BranchID";

                            ProductCardInfo_Model mCard = db.SetCommand(strSqlCard
                            , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                            , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteObject<ProductCardInfo_Model>();

                            if (mCard == null)
                            {
                                model.PromotionPrice = model.UnitPrice;
                                model.CardID = 0;
                                model.CardName = "不使用e账户";
                            }
                            else
                            {
                                model.CardName = mCard.CardName;
                                model.CardID = mCard.CardID;
                            }

                        }

                        model.CartID = item;
                        list.Add(model);
                    }
                }

                return list;

            }
        }

        public List<ProductList_Model> getRecommendedCommodityList(int companyId, int imageHeight, int imageWidth)
        {
            using (DbManager db = new DbManager())
            {
                List<ProductList_Model> list = new List<ProductList_Model>();
                string strSql = @" SELECT  DISTINCT TOP 10
                                        T1.CommodityName AS ProductName ,
                                        1 AS ProductType ,
                                        T1.Code AS ProductCode ,
                                        T3.SortID ,";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                             + WebAPI.Common.Const.strSingleMark
                             + "  + cast(T4.CompanyID as nvarchar(10)) + "
                             + WebAPI.Common.Const.strSingleMark
                             + "/"
                             + WebAPI.Common.Const.strImageObjectType6
                             + WebAPI.Common.Const.strSingleMark
                             + "  + cast(T4.CommodityCode as nvarchar(16))+ '/' + T4.FileName + "
                             + WebAPI.Common.Const.strThumb
                             + " ThumbnailURL ";
                strSql += @" FROM    [COMMODITY] T1 WITH ( NOLOCK )
                                        INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 ON T1.Code = T2.Code
                                                                                   AND T2.Available = 1
                                                                                   AND T2.Type = 1
                                        LEFT JOIN [TBL_COMMODITYSORT] T3 WITH ( NOLOCK ) ON T1.Code = T3.CommodityCode
                                        LEFT JOIN [IMAGE_COMMODITY] T4 ON T1.ID = T4.CommodityID
                                                                          AND T4.ImageType = 0
                                WHERE   T1.Recommended = 1
                                        AND T1.CompanyID = @CompanyID
                                        AND T1.Available = 1
                                        AND T1.VisibleForCustomer = 1
                                ORDER BY T3.SortID ";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ProductList_Model>();
                return list;
            }
        }

    }
}
