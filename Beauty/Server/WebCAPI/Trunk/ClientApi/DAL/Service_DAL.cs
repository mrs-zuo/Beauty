using BLToolkit.Data;
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

        public List<ProductList_Model> getServiceListByCompanyId(int companyId, int customerId, int imageHeight, int imageWidth)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  DISTINCT T1.Code AS ProductCode ,T1.ID AS ProductID ,T1.ServiceName AS ProductName ,T1.UnitPrice ,T3.SortID,ISNULL(T1.ServiceName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField, ";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType8
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.ServiceCode as nvarchar(16))+ '/' + T4.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ThumbnailURL ";
                //顾客端 抽取顾客相关分店下的服务

                strSql += @" FROM    [SERVICE] T1
                                    INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 WITH ( NOLOCK ) ON T1.Code = T2.Code
                                                                                          AND T2.Available = 1
                                                                                          AND T2.Type = 0
                                    LEFT JOIN [TBL_SERVICESORT] T3 WITH ( NOLOCK ) ON T1.Code = T3.ServiceCode
                                    LEFT JOIN [IMAGE_SERVICE] T4 ON T1.ID = T4.ServiceID
                                                                    AND T4.ImageType = 0
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T1.Available = 1
                                    AND T1.VisibleForCustomer = 1  
                                    AND T2.BranchID IN ( SELECT BranchID FROM   dbo.RELATIONSHIP WHERE  CustomerID = @CustomerID AND Available = 1 ) 
                            ORDER BY T3.SortID ";

                List<ProductList_Model> list = new List<ProductList_Model>();

                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ProductList_Model>();

                return list;
            }
        }

        public List<ProductList_Model> getRecommendedServiceListByBranchID(int companyId, int imageHeight, int imageWidth, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  DISTINCT T1.Code AS ProductCode ,T1.ID AS ProductID ,T1.ServiceName AS ProductName ,T1.UnitPrice ,T3.SortID,ISNULL(T1.ServiceName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField, ";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType8
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.ServiceCode as nvarchar(16))+ '/' + T4.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ThumbnailURL ";
                //顾客端 抽取顾客相关分店下的服务

                strSql += @" FROM    [SERVICE] T1
                                    INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 WITH ( NOLOCK ) ON T1.Code = T2.Code
                                                                                          AND T2.Available = 1
                                                                                          AND T2.Type = 0
                                    LEFT JOIN [TBL_SERVICESORT] T3 WITH ( NOLOCK ) ON T1.Code = T3.ServiceCode
                                    LEFT JOIN [IMAGE_SERVICE] T4 ON T1.ID = T4.ServiceID
                                                                    AND T4.ImageType = 0
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T1.Available = 1
                                    AND T1.VisibleForCustomer = 1 
                                    AND T2.BranchID = @BranchID 
                                    AND T1.Recommended = 1  
                            ORDER BY T3.SortID ";

                List<ProductList_Model> list = new List<ProductList_Model>();

                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ProductList_Model>();

                return list;
            }
        }

        public List<ProductList_Model> getServiceListByCategoryId(int companyId, int categoryId, int customerId, bool selectAll, int imageHeight, int imageWidth)
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
                strSql += " SELECT DISTINCT T1.Code AS ProductCode ,T1.ID AS ProductID ,T1.ServiceName AS ProductName ,T1.UnitPrice ,T3.SortID,ISNULL(T1.ServiceName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField, ";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType8
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.ServiceCode as nvarchar(16))+ '/' + T4.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ThumbnailURL ";

                strSql += @" FROM    [SERVICE] T1 WITH ( NOLOCK )
                                        INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 WITH ( NOLOCK ) ON T1.Code = T2.Code
                                                                                          AND T2.Available = 1
                                                                                          AND T2.Type = 0
                                        LEFT JOIN [TBL_SERVICESORT] T3 WITH ( NOLOCK ) ON T1.Code = T3.ServiceCode
                                        LEFT JOIN [IMAGE_SERVICE] T4 ON T1.ID = T4.ServiceID AND T4.ImageType = 0 
                               WHERE   T1.CompanyID = @CompanyID AND T1.Available = 1
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

                strSql += " ORDER BY T3.Sortid ";

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

        public ServiceDetail_Model getServiceDetailByServiceCode(UtilityOperation_Model utilityModel)
        {
            using (DbManager db = new DbManager())
            {
                ServiceDetail_Model model = new ServiceDetail_Model();
                string strSql = "";
                if (utilityModel.BranchID == 0)
                {
                    strSql = @" SELECT TOP 1
                                            T1.ID ServiceID ,
                                            T1.Code ServiceCode ,
                                            T1.ServiceName ,
                                            T1.CourseFrequency ,
                                            ISNULL(T1.SpendTime, 0) AS SpendTime ,
                                            T1.Describe ,
                                            T1.MarketingPolicy ,
                                            T1.PromotionPrice ,
                                            T1.UnitPrice ,
                                            T1.SubServiceCodes,
                                            T1.ExpirationDate,
                                            T1.HaveExpiration
                                     FROM   [SERVICE] T1 WITH ( NOLOCK )
                                     WHERE  T1.Code = @Code
                                            AND T1.CompanyID = @CompanyID
                                            AND T1.Available = 1
                                     ORDER BY T1.ID DESC  ";

                    model = db.SetCommand(strSql.ToString(), db.Parameter("@Code", utilityModel.ProductCode, DbType.Int64)
                                             , db.Parameter("@CompanyID", utilityModel.CompanyID, DbType.Int32)).ExecuteObject<ServiceDetail_Model>();
                }
                else
                {
                    strSql =
                    @" select top 1 T1.ID ServiceID,T1.Code ServiceCode,T1.ServiceName,T1.CourseFrequency,ISNULL(T1.SpendTime,0) AS SpendTime ,T1.Describe,T1.MarketingPolicy,T1.PromotionPrice,T1.UnitPrice,T1.SubServiceCodes  
                         from [SERVICE]  T1 with(nolock)  
                         INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 WITH ( NOLOCK ) ON T2.Code = T1.Code AND T2.CompanyID = T1.CompanyID AND T2.[Type] = 0 AND T2.Available = 1 AND T2.BranchID=@BranchID 
                         WHERE T1.Code =@Code and T1.Available = 1  order by T1.ID desc ";

                    model = db.SetCommand(strSql.ToString(), db.Parameter("@Code", utilityModel.ProductCode, DbType.Int64)
                                            , db.Parameter("@BranchID", utilityModel.BranchID, DbType.Int32)).ExecuteObject<ServiceDetail_Model>();

                }


                return model;
            }
        }

        public PromotionProductDetail_Model GetPromotionServiceDetailByID(int companyID, string promotionID, int commodityID,int CusteromID)
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
                                            INNER JOIN [SERVICE] T2 WITH ( NOLOCK ) ON T1.ProductID = T2.ID
											LEFT JOIN [TBL_PROMOTION_RULE] T3 WITH ( NOLOCK ) 
											ON T1.ProductID = T3.ProductID AND T3.ProductType = 0 AND T1.PromotionID = T3.PromotionID AND T3.PRCode = 1
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

                    model.BranchList = db.SetCommand(strSql, db.Parameter("@CustomerID", CusteromID, DbType.Int32)
                                     , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                     , db.Parameter("@PromotionID", promotionID, DbType.String)).ExecuteList<Model.Table_Model.SimpleBranch_Model>();
                }

                return model;
            }
        }

        public List<SubServiceInServiceDetail_Model> getSubServiceByCodes(List<long> subServiceCode)
        {
            using (DbManager db = new DbManager())
            {
                if (subServiceCode == null || subServiceCode.Count <= 0)
                {
                    return null;
                }

                List<SubServiceInServiceDetail_Model> list = new List<SubServiceInServiceDetail_Model>();

                string strWhere = "";
                foreach (long SubServiceCode in subServiceCode)
                {
                    string strSql = @"SELECT   T1.SpendTime ,T1.SubServiceName ,T1.SubServiceCode 
                                               FROM [TBL_SubService] T1 
                                               WHERE T1.SubServiceCode=@SubServiceCode and T1.Available = 1";

                    SubServiceInServiceDetail_Model model = db.SetCommand(strSql, db.Parameter("@SubServiceCode", SubServiceCode, DbType.Int64)).ExecuteObject<SubServiceInServiceDetail_Model>();
                    list.Add(model);
                }
                return list;
            }
        }

        public List<ServiceEnalbeInfoDetail_Model> getServiceEnalbleForCustomer(int customerId, long productCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                List<ServiceEnalbeInfoDetail_Model> list = new List<ServiceEnalbeInfoDetail_Model>();

                strSql = @"SELECT DISTINCT  T1.ID BranchID , 
                                            T1.BranchName 
                                    FROM    dbo.BRANCH T1 
                                            INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 ON T2.Available = 1 
                                                                                         AND T1.ID = T2.BranchID 
                                                                                         AND T2.Type = 0 
                                            INNER JOIN dbo.SERVICE T3 ON T1.Available = 1 
                                                                         AND T2.Code = T3.Code 
                                            INNER JOIN dbo.RELATIONSHIP T4 ON T4.BranchID = T1.ID 
                                                                              AND CustomerID = @CustomerID 
                                                                              AND T4.Available = 1 
                                    WHERE   T3.Code = @ProductCode And T1.Available = 1 ";

                list = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)
                                , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteList<ServiceEnalbeInfoDetail_Model>();

                return list;

            }
        }

        public List<ProductList_Model> getRecommendedServiceList(int companyId, int imageHeight, int imageWidth)
        {
            using (DbManager db = new DbManager())
            {
                List<ProductList_Model> list = new List<ProductList_Model>();
                string strSql = @" SELECT  DISTINCT TOP 10
                                        T1.ServiceName AS ProductName ,
                                        0 AS ProductType ,
                                        T1.Code AS ProductCode , 
                                        T3.SortID , ";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                                       + WebAPI.Common.Const.strSingleMark
                                       + "  + cast(T4.CompanyID as nvarchar(10)) + "
                                       + WebAPI.Common.Const.strSingleMark
                                       + "/"
                                       + WebAPI.Common.Const.strImageObjectType8
                                       + WebAPI.Common.Const.strSingleMark
                                       + "  + cast(T4.ServiceCode as nvarchar(16))+ '/' + T4.FileName + "
                                       + WebAPI.Common.Const.strThumb
                                       + " ThumbnailURL ";
                strSql += @" FROM    [SERVICE] T1 WITH ( NOLOCK )
                                        INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 WITH ( NOLOCK ) ON T1.Code = T2.Code
                                                                                              AND T2.Available = 1
                                                                                              AND T2.Type = 0
                                        LEFT JOIN [TBL_SERVICESORT] T3 WITH ( NOLOCK ) ON T1.Code = T3.ServiceCode
                                        LEFT JOIN [IMAGE_SERVICE] T4 ON T1.ID = T4.ServiceID
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

        public List<ProductList_Model> getBoughtServiceList(int companyId, int branchID, int customerId, int imageHeight, int imageWidth)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T3.Code AS ProductCode ,T3.ID AS ProductID ,T3.ServiceName AS ProductName ,T3.UnitPrice ,T1.OrderTime , ";
                strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                        + "/"
                        + WebAPI.Common.Const.strImageObjectType8
                        + WebAPI.Common.Const.strSingleMark
                        + "  + cast(T4.ServiceCode as nvarchar(16))+ '/' + T4.FileName + "
                        + WebAPI.Common.Const.strThumb
                        + " ThumbnailURL ";

                strSql += @" FROM    [ORDER] T1 WITH ( NOLOCK )
                                    INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                    INNER JOIN [SERVICE] T3 WITH ( NOLOCK ) ON T3.ID = T2.ServiceID
                                    LEFT JOIN [IMAGE_SERVICE] T4 ON T3.ID = T4.ServiceID
                                                                    AND T4.ImageType = 0
                            WHERE   T1.CustomerID = @CustomerID
                                    AND T1.BranchID = @BranchID
                                    AND T1.CompanyID = @CompanyID
                                    AND T3.Available = 1
                                    AND ( T1.Status = 1
                                          OR T1.Status = 2
                                          OR T1.Status = 4
                                        )
                            ORDER BY T1.OrderTime DESC ";

                List<ProductList_Model> list = new List<ProductList_Model>();

                
                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ProductList_Model>();

                list = list.Where((x, i) => list.FindIndex(z => z.ProductCode == x.ProductCode) == i).ToList();

                if (list != null && list.Count > 10)
                {
                    list = list.Take(10).ToList();
                }

                return list;
            }
        }
    }
}
