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
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Table_Model;
using WebAPI.Common;
using System.IO;

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
        public List<GetProductList_Model> getServiceList(int companyID, int pageIndex, int pageSize, out int recordCount, int height, int width, string strSearch)
        {
            recordCount = 0;
            List<GetProductList_Model> list = new List<GetProductList_Model>();
            using (DbManager db = new DbManager())
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
                string strImg = string.Format(WebAPI.Common.Const.getServiceImg, "T1.ServiceCode", "T1.FileName", height, width);
                string strSql = " SELECT " + strImg + " FROM [IMAGE_SERVICE] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.ServiceID=@ServiceID AND T1.ImageType = 1 ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@ServiceID", serviceID, DbType.Int32)).ExecuteScalarList<string>();
                return list;

            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="serviceID"></param>
        /// <returns></returns>
        public List<string> getSubServiceName(int companyID, int serviceID)
        {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                string strSql = " select SubServiceCodes from [SERVICE] where CompanyID =@CompanyID and ID=@ServiceID ";
                string subServiceCodes = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@ServiceID", serviceID, DbType.Int32)).ExecuteScalar<string>();
                if (subServiceCodes == null || subServiceCodes == "")
                {
                    return list;
                }

                string[] temp = subServiceCodes.Split(new[] { "|" }, StringSplitOptions.RemoveEmptyEntries);

                string strWhere = "";
                foreach (string item in temp)
                {
                    if (strWhere != "")
                    {
                        strWhere += " , ";
                    }
                    strWhere += item;
                }

                if (strWhere == "")
                {
                    return list;
                }
                string strSqlSubserviceName = @" select SubServiceName 
                                                    from [TBL_SUBSERVICE] 
                                                    where ID in (
                                                    select MAX(ID) 
                                                    from TBL_SUBSERVICE 
                                                    where SubServiceCode in ({0}) group by SubServiceCode )";
                string strSqlFinal = string.Format(strSqlSubserviceName, strWhere);

                list = db.SetCommand(strSqlFinal).ExecuteScalarList<string>();

                return list;
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
                string strSql = " SELECT T1.Code AS ProductCode, T1.ServiceName AS ProductName ,";
                strSql += string.Format(WebAPI.Common.Const.getServiceImg, "T3.ServiceCode", "T3.FileName", height, width);
                strSql += @" FROM [SERVICE] T1 
                                LEFT JOIN [IMAGE_SERVICE] T3 
                                ON T3.ServiceID = T1.ID AND T3.ImageType = 0 
                                WHERE  T1.ID IN (
                                SELECT MAX(T2.ID) FROM [SERVICE] T2 WHERE T2.Available = 1 AND T2.CompanyID =@CompanyID AND T2.Code in (";
                strSql += strServiceCodes;
                strSql += " ) GROUP BY T2.Code )  ";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetProductList_Model>();
                return list;
            }
        }

        /// <summary>
        /// 二维码查看服务信息
        /// </summary>
        /// <param name="companyCode"></param>
        /// <param name="branchId"></param>
        /// <param name="code"></param>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public ObjectResult<ProductInFoByQRCode_Model> getServiceInfoByQRCode(string companyCode, int branchId, long code, int accountId)
        {
            ObjectResult<ProductInFoByQRCode_Model> result = new ObjectResult<ProductInFoByQRCode_Model>();
            result.Code = "-2";
            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"SELECT T1.Code,T1.ID,0 Type,t1.ServiceName Name
                                             ,T1.UnitPrice,t1.PromotionPrice,t1.MarketingPolicy,
                                             (CASE when T1.ExpirationDate=0 THEN '2099-12-31' when T1.ExpirationDate IS NULL THEN '2099-12-31' ELSE  ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, T1.ExpirationDate, GETDATE()),25),'') END) AS ExpirationTime
                                             FROM dbo.SERVICE T1
                                             INNER JOIN dbo.TBL_MARKET_RELATIONSHIP t4 ON t4.Type=0 AND t4.Code=t1.Code
                                             INNER JOIN dbo.COMPANY T2
                                             ON T1.CompanyID = T2.ID
                                             INNER JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T3 ON  T3.CompanyID = T2.ID AND T3.UserID = @AccountID 
                                             WHERE T1.Code =@ServiceCode
                                             AND T1.Available = 1
                                             AND T2.CompanyCode = @CompanyCode 
                                             --总店的美容师 或 与服务同在一分店下的美容师可以看到
                                             AND T3.BranchID = @BranchID 
                                             AND T2.Available = 1";

                ProductInFoByQRCode_Model model = new ProductInFoByQRCode_Model();
                db.SetCommand(strSqlCommand, db.Parameter("@ServiceCode", code, DbType.Int64),
                    db.Parameter("@CompanyCode", companyCode, DbType.String),
                    db.Parameter("@BranchID", branchId, DbType.Int32),
                    db.Parameter("@AccountID", accountId, DbType.Int32)).ExecuteObject(model);

                if (model.ID != 0)
                {
                    result.Code = "1";
                    result.Data = model;
                }
                else
                {
                    result.Message = "二维码查看服务失败";
                }
            }
            return result;
        }

        #region 手机端方法
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
                                            T1.SubServiceCodes
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
        public List<GetSeriviceList_Model> getServiceListByCompanyId(int companyId, bool isBusiness, int branchId, int accountId, int customerId, int imageHeight, int imageWidth)
        {
            using (DbManager db = new DbManager())
            {
                int levelId = 0;
                if (customerId > 0)
                {
                    string strSqlLevelId = @"  select  T2.CardID from [CUSTOMER] T1 with (nolock)
                                       INNER JOIN [TBL_CUSTOMER_CARD] T2 with (nolock) ON T1.DefaultCardNo=T2.UserCardNo 
									   INNER JOIN [MST_CARD_BRANCH] T3 ON T2.CardID = T3.CardID AND T3.BranchID = @BranchID
                                        where T1.UserID =@UserID and T1.Available = 1  ";

                    levelId = db.SetCommand(strSqlLevelId, db.Parameter("@UserID", customerId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<int>();
                }

                string strSql = @" SELECT distinct T1.Code ServiceCode,T1.ID ServiceID, T1.ServiceName, T1.MarketingPolicy,T1.UnitPrice,CASE WHEN T1.MarketingPolicy = 2 THEN CASE WHEN @CardID = 0 THEN T1.UnitPrice ELSE T1.PromotionPrice END WHEN T1.MarketingPolicy = 1 THEN T1.UnitPrice * ISNULL( T8.Discount,1) END PromotionPrice,ISNULL(T4.ID,0) AS FavoriteID ,( CASE WHEN T1.HaveExpiration = 0 THEN '2099-12-31' ELSE ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, T1.ExpirationDate, GETDATE()), 25), '')END ) AS ExpirationTime,ISNULL(T1.ServiceName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField,T3.SortID ,T1.CategoryID, ";
                strSql += Common.Const.strHttp + Common.Const.server + Common.Const.strMothod
                        + Common.Const.strSingleMark
                        + "  + cast(T11.CompanyID as nvarchar(10)) + "
                        + Common.Const.strSingleMark
                        + "/"
                        + Common.Const.strImageObjectType8
                        + Common.Const.strSingleMark
                        + "  + cast(T11.ServiceCode as nvarchar(16))+ '/' + T11.FileName + "
                        + Common.Const.strThumb
                        + " ThumbnailURL FROM SERVICE T1";
                //顾客端 抽取顾客相关分店下的服务
                if (!isBusiness)
                {
                    strSql += @" INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T5 WITH(NOLOCK) 
                                ON T1.Code = T5.Code AND T5.Available = 1 AND T5.Type = 0 ";
                }
                else
                {
                    strSql += @" Inner join [TBL_MARKET_RELATIONSHIP] T5  WITH(NOLOCK) 
                            on T1.Code = T5.Code  AND T5.Available = 1 AND T5.Type = 0  AND T5.BranchID =@BranchID ";
                }
                strSql += @" LEFT JOIN [CATEGORY] T2 WITH(NOLOCK) 
                                ON T1.CategoryID =T2.ID 
                                LEFT JOIN [TBL_SERVICESORT] T3 WITH(NOLOCK) 
                                ON T1.Code = T3.ServiceCode 
                                LEFT JOIN [TBL_FAVORITE] T4 WITH(NOLOCK) 
                                ON T1.Code=T4.Code AND T4.ProductType=0 AND T4.AccountID=@AccountID  AND T4.BranchID=@BranchID
                                LEFT JOIN  (
                                select CardID,DiscountID,Discount 
                                from [TBL_CARD_DISCOUNT] T9 WITH(NOLOCK) 
                                INNER JOIN [TBL_DISCOUNT] T10 
                                ON T9.DiscountID = T10.ID ) T8  
                                ON T8.CardID=@CardID AND T1.DiscountID = T8.DiscountID 
                                left join [IMAGE_SERVICE] T11 
                                ON T1.ID = T11.ServiceID AND T11.ImageType=0
                                WHERE T1.CompanyID = @CompanyID and T1.Available = 1 
                                and T1.ID in (SELECT MAX(ID) FROM SERVICE GROUP BY code)";

                if (!isBusiness)
                {
                    //客户端
                    strSql += @" AND T1.VisibleForCustomer=1 AND (T2.Available = 1 or T1.CategoryID IS NULL)
                                    AND T5.BranchID IN(SELECT BranchID FROM dbo.RELATIONSHIP WHERE CustomerID = @CustomerID AND Available = 1) ";
                }

                strSql += " Order by T3.Sortid  ";
                List<GetSeriviceList_Model> list = new List<GetSeriviceList_Model>();
                if (!isBusiness)
                {
                    list = db.SetCommand(strSql, db.Parameter("@AccountID", 0, DbType.Int32)
                        , db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", 0, DbType.Int32)
                        , db.Parameter("@CardID", levelId, DbType.Int32)
                        , db.Parameter("@CustomerID", customerId, DbType.Int32)
                        , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                        , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<GetSeriviceList_Model>();
                }
                else
                {

                    list = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                        , db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@CardID", levelId, DbType.Int32)
                        , db.Parameter("@CustomerID", customerId, DbType.Int32)
                        , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                        , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<GetSeriviceList_Model>();
                }

                return list;
            }
        }

        #endregion

        /// <summary>
        ///获取某一目录下所有服务信息（前提为目录是最后一层）
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public List<GetSeriviceList_Model> getServiceListByCategoryId(int categoryId, bool isBusiness, int branchId, int accountId, int customerId, bool selectAll)
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

                    object obj = db.SetCommand(strSqlLevelId, db.Parameter("@UserID", customerId, DbType.Int32)
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
                strSql.Append(" SELECT distinct T1.Code as ServiceCode,T1.ID AS ServiceID, T1.ServiceName,T1.MarketingPolicy, T1.UnitPrice,CASE WHEN T1.MarketingPolicy = 2 THEN CASE WHEN @CardID = 0 THEN T1.UnitPrice ELSE T1.PromotionPrice END WHEN T1.MarketingPolicy = 1 THEN T1.UnitPrice * ISNULL( T8.Discount,1) END PromotionPrice,ISNULL(T4.ID,0) AS FavoriteID, ( CASE WHEN T1.HaveExpiration = 0 THEN '2099-12-31' ELSE ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, T1.ExpirationDate, GETDATE()), 25), '')END ) AS ExpirationTime,ISNULL(T1.ServiceName,'') + '|' + ISNULL(T1.SerialNumber,'') SearchField ");
                strSql.Append(" ,T2.Sortid ");
                strSql.Append(" FROM [SERVICE] T1 WITH(NOLOCK) ");
                //顾客端 抽取顾客相关分店下的服务
                if (!isBusiness)
                {
                    strSql.Append(@" INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T5 WITH(NOLOCK) ON T1.Code = T5.Code
                                                     AND T5.Available = 1
                                                     AND T5.Type = 0 ");
                }
                else
                {
                    //商家端 抽取美容师所在分店下的服务(branchid>0)或公司所有服务(branchid=0)
                    if (branchId > 0)
                    {
                        strSql.Append(" Inner join [TBL_MARKET_RELATIONSHIP] T5 WITH(NOLOCK) ");
                        strSql.Append(" on T1.Code = T5.Code ");
                        strSql.Append(" AND T5.Available = 1");
                        strSql.Append(" AND T5.Type = 0 ");
                        strSql.Append(" AND T5.BranchID = ");
                        strSql.Append(branchId.ToString());
                    }
                }
                strSql.Append(" LEFT JOIN [TBL_SERVICESORT] T2 WITH(NOLOCK) ON T1.Code=T2.ServiceCode ");
                strSql.Append(" LEFT JOIN [TBL_FAVORITE] T4 WITH(NOLOCK) ON T1.Code=T4.Code AND T4.ProductType=0 AND T4.AccountID=@AccountID  AND T4.BranchID=@BranchID ");
                strSql.Append("  LEFT JOIN  (select CardID,DiscountID,Discount from [TBL_CARD_DISCOUNT] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.CardID=@CardID AND T1.DiscountID = T8.DiscountID ");
                if (!selectAll)
                {
                    strSql.Append(" WHERE T1.CategoryID = @CategoryID and T1.Available = 1 and T1.ID in (SELECT MAX(ID) FROM [SERVICE] GROUP BY code)");
                }
                else
                {
                    strSql.Append(" WHERE (T1.CategoryID = @CategoryID or T1.CategoryID in(Select ID from subQuery)) and T1.Available = 1 and T1.ID in (SELECT MAX(ID) FROM [SERVICE] GROUP BY code)");
                }
                //strSql.Append(" WHERE CategoryID = @CategoryID and Available = 1 ");
                if (!isBusiness)
                {
                    strSql.Append(" AND T1.VisibleForCustomer=1 ");
                    strSql.Append(@" AND T5.BranchID IN(SELECT BranchID FROM dbo.RELATIONSHIP
                                  WHERE CustomerID = @CustomerID AND Available = 1) ");
                }
                strSql.Append(" ORDER BY T2.Sortid ");

                List<GetSeriviceList_Model> list = new List<GetSeriviceList_Model>();
                list = db.SetCommand(strSql.ToString()
                 , db.Parameter("@AccountID", isBusiness ? accountId : 0, DbType.Int32)
                 , db.Parameter("@BranchID", isBusiness ? branchId : 0, DbType.Int32)
                 , db.Parameter("@CategoryID", categoryId, DbType.Int32)
                 , db.Parameter("@CardID", levelId, DbType.Int32)
                 , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<GetSeriviceList_Model>();

                return list;
            }
        }

        /// <summary>
        ///获取某一目录下所有服务信息（前提为目录是最后一层）
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public List<GetSeriviceList_Model> getServiceListCategoryNull(int companyId, bool isBusiness, int branchId, int accountId, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();

                strSql.Append(" SELECT * ");
                strSql.Append(" FROM [SERVICE] T1 WITH(NOLOCK) ");
                //顾客端 抽取顾客相关分店下的服务
                if (!isBusiness)
                {
                    strSql.Append(@" INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T5 WITH(NOLOCK) ON T1.Code = T5.Code
                                                     AND T5.Available = 1
                                                     AND T5.Type = 0 ");
                }
                else
                {
                    //商家端 抽取美容师所在分店下的服务(branchid>0)或公司所有服务(branchid=0)
                    if (branchId > 0)
                    {
                        strSql.Append(" Inner join [TBL_MARKET_RELATIONSHIP] T5 WITH(NOLOCK) ");
                        strSql.Append(" on T1.Code = T5.Code ");
                        strSql.Append(" AND T5.Available = 1");
                        strSql.Append(" AND T5.Type = 0 ");
                        strSql.Append(" AND T5.BranchID = ");
                        strSql.Append(branchId.ToString());
                    }
                }
                strSql.Append(" LEFT JOIN [TBL_SERVICESORT] T2 WITH(NOLOCK) ON T1.Code=T2.ServiceCode ");
                strSql.Append(" LEFT JOIN [TBL_FAVORITE] T4 WITH(NOLOCK) ON T1.Code=T4.Code AND T4.ProductType=0 AND T4.AccountID=@AccountID  AND T4.BranchID=@BranchID ");
                //strSql.Append("  LEFT JOIN  (select LevelID,DiscountID,Discount from [TBL_LEVEL_DISCOUNT_RELATIONSHIP] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.LevelID=@LevelID AND T1.DiscountID = T8.DiscountID ");
                strSql.Append(" WHERE T1.CompanyID = @CompanyID and T1.CategoryID is null and T1.Available = 1 and T1.ID in (SELECT MAX(ID) FROM [SERVICE] GROUP BY code)");
                //strSql.Append(" WHERE CategoryID = @CategoryID and Available = 1 ");
                if (!isBusiness)
                {
                    strSql.Append(" AND T1.VisibleForCustomer=1 ");
                    strSql.Append(@" AND T5.BranchID IN(SELECT BranchID FROM dbo.RELATIONSHIP
                                  WHERE CustomerID = @CustomerID AND Available = 1) ");
                }
                //strSql.Append(" ORDER BY T2.Sortid ");

                List<GetSeriviceList_Model> list = new List<GetSeriviceList_Model>();
                list = db.SetCommand(strSql.ToString()
                 , db.Parameter("@AccountID", isBusiness ? accountId : 0, DbType.Int32)
                 , db.Parameter("@BranchID", isBusiness ? branchId : 0, DbType.Int32)
                 , db.Parameter("@CompanyID", companyId, DbType.Int32)
                 , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<GetSeriviceList_Model>();

                return list;
            }
        }

        public List<Service_Model> getServiceListForWeb(int companyId, int categoryId, int imageWidth, int imageHeight, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(@" SELECT distinct T1.ID , T4.CategoryName,T1.ServiceName, T1.UnitPrice,T1.MarketingPolicy, ISNULL( T1.PromotionPrice,T1.UnitPrice) PromotionPrice,T1.VisibleForCustomer,T1.Describe,T1.Code ServiceCode,T1.Available,T1.CategoryID,[T5].[Sortid],ISNULL(T1.SubServiceCodes,'') AS SubServiceCodes, T1.Recommended,
                                ( SELECT DiscountName FROM dbo.TBL_DISCOUNT WHERE ID = T1.DiscountID AND available = 1 ) DiscountName ,"
                + Common.Const.strHttp
                + Common.Const.server
                + Common.Const.strMothod
                + "/"
                + Common.Const.strSingleMark
                + "  + cast(T3.CompanyID as nvarchar(10)) + "
                + Common.Const.strSingleMark
                + "/"
                + Common.Const.strImageObjectType8
                + Common.Const.strSingleMark
                + @" + cast(T3.ServiceCode as nvarchar(16))+ '/' + T3.FileName  + "
                + Common.Const.strThumb
                + @" ThumbnailUrl FROM Service T1 WITH(NOLOCK) ");

                if (branchId > 0)
                {
                    strSql.Append(@" INNER JOIN [TBL_MARKET_RELATIONSHIP] T6 
                                     on T1.Code = T6.Code 
                                     AND T6.Type = 0 
                                     AND T6.Available = 1 
                                     AND T6.BranchID =@BranchID ");
                }

                strSql.Append(@" LEFT JOIN  
                                 IMAGE_SERVICE T3 WITH(NOLOCK) 
                                 ON T1.ID = T3.ServiceID  
                                 AND T3.ImageType = 0  
                                 LEFT JOIN  
                                 CATEGORY T4  WITH(NOLOCK) 
                                 ON T1.CategoryID = T4.ID  
                                 LEFT JOIN  
                                 [TBL_SERVICESORT] T5  WITH(NOLOCK) 
                                 ON [T1].[CODE] = [T5].[SERVICECODE]  
                                 WHERE T1.Available = 1  and T1.CompanyID =@CompanyID");

                switch (categoryId)
                {
                    //获取所有
                    case -1:
                        strSql.Append(@" AND( 
                                                (T4.type = 0  AND T4.Available = 1) OR ( T1.CategoryID IS NULL OR T1.CategoryID = -1 ) 
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
                //获取没有分配分店的项目
                if (branchId == 0)
                {
                    strSql.Append("  AND T1.Code  NOT IN (SELECT Code FROM [TBL_MARKET_RELATIONSHIP] WITH ( NOLOCK ) WHERE CompanyID = @CompanyID and TYPE = 0 and Available = 1 group by Code )");
                }
                strSql.Append(" Order by T1.Recommended, [T5].[Sortid] ");

                List<Service_Model> list = db.SetCommand(strSql.ToString(),
                                                          db.Parameter("@CompanyID", companyId, DbType.Int32),
                                                          db.Parameter("@BranchID", branchId, DbType.Int32),
                                                          db.Parameter("@CategoryID", categoryId, DbType.Int32),
                                                          db.Parameter("@ImageHeight", imageHeight.ToString()),
                                                          db.Parameter("@ImageWidth", imageWidth.ToString())).ExecuteList<Service_Model>();

                return list;
            }
        }

        public Service_Model getServiceDetailForWeb(int companyID, long serviceCode, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                Service_Model model = new Service_Model();
                if (serviceCode != 0)
                {
                    string strSql = @"SELECT Top 1 T1.ID,T1.CategoryID,T1.Code AS ServiceCode,T1.ServiceName,T1.UnitPrice,T1.MarketingPolicy,T1.PromotionPrice,T1.Describe,T1.CourseFrequency,T1.SpendTime,T1.VisitTime,T1.VisibleForCustomer, T1.ExpirationDate, T1.NeedVisit, T1.HaveExpiration,T1.SubServiceCodes,ISNULL(T1.SerialNumber,'')AS SerialNumber ,T1.DiscountID ,T1.IsConfirmed,T1.Recommended, T1.AutoConfirm, T1.AutoConfirmDays
                                     FROM [SERVICE] T1  WITH(NOLOCK) 
                                     where T1.Available = 1 
                                     and T1.Code =@ServiceCode and T1.CompanyID=@CompanyID order by T1.ID desc ";

                    model = db.SetCommand(strSql
                                                , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)
                                                , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<Service_Model>();
                }
                model.BranchList = new List<ServiceBranch>();
                string strSqlBranchList = @" SELECT DISTINCT T1.ID AS BranchID, T1.BranchName,
                                CASE WHEN T2.BranchID=T1.ID THEN 1 ELSE 0 END AS IsExist
                                FROM    BRANCH T1
                                        LEFT JOIN TBL_MARKET_RELATIONSHIP T2 ON T1.ID = T2.BranchID AND T2.Code=@Code AND T2.Type = 0 AND T2.Available=1 
                                WHERE   T1.CompanyID =@CompanyID  AND T1.Available= 1 ";
                if (branchID > 0)
                {
                    strSqlBranchList += " AND T1.ID =@BranchID ";
                }
                model.BranchList = db.SetCommand(strSqlBranchList
                                            , db.Parameter("@Code", serviceCode, DbType.Int64)
                                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                            , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<ServiceBranch>();

                return model;
            }
        }

        public List<ServiceBranch> getServiceBranchListForWeb(int companyID, long serviceCode, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                List<ServiceBranch> list = new List<ServiceBranch>();

                string strSql = @"SELECT  DISTINCT T1.ID AS BranchID ,T1.BranchName ,
                                    CASE WHEN T2.BranchID = T1.ID THEN 1 ELSE 0 END AS IsExist
                            FROM    [BRANCH] T1
                                    LEFT JOIN dbo.TBL_MARKET_RELATIONSHIP T2 ON T2.BranchID = T1.ID
                                                                                AND T2.Available = 1
                                                                                AND T2.Type = 0
                                                                                AND T2.Code = @ServiceCode
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T1.Available = 1 ";
                if (branchID > 0)
                {
                    strSql += " AND T1.ID= @BranchID";
                }


                list = db.SetCommand(strSql
                                            , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)
                                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                            , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<ServiceBranch>();
                return list;
            }
        }

        public List<ImageCommon_Model> getImgList(int companyID, int serviceID)
        {
            using (DbManager db = new DbManager())
            {
                List<ImageCommon_Model> list = new List<ImageCommon_Model>();

                string strSql = @"SELECT FileName,ImageType AS ObjectType," + Const.getServiceImgForManager + " FROM  dbo.IMAGE_SERVICE T1 WHERE CompanyID=@CompanyID AND ServiceID=@ServiceID ";

                list = db.SetCommand(strSql
                                            , db.Parameter("@ServiceID", serviceID, DbType.Int64)
                                            , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<ImageCommon_Model>();
                return list;
            }
        }

        public int getSubserviceCodeByName(int companyId, string subserviceName)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"
                            SELECT  SubServiceCode
                            FROM    dbo.TBL_SubService
                            WHERE   SubServiceName = @SubServiceName
                                    AND Available = 1
                                    AND CompanyID = @CompanyID
                            ";
                int code = db.SetCommand(strSql, db.Parameter("@SubServiceName", subserviceName, DbType.String)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                return code;
            }
        }


        public bool exsitSubserviceCode(int companyId, long subserviceCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"
                            SELECT  count(0)
                            FROM    dbo.TBL_SubService
                            WHERE   SubServiceCode = @SubServiceCode
                                    AND Available = 1
                                    AND CompanyID = @CompanyID
                            ";
                int count = db.SetCommand(strSql, db.Parameter("@SubServiceCode", subserviceCode, DbType.Int64)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                return count > 0;
            }
        }


        /// <summary>
        /// WEB页面获取ServiceList
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="categoryId"></param>
        /// <returns></returns>
        public DataTable getServiceListForDownload(int companyId, int categoryId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                if (branchId <= -2)
                {
                    return null;
                }
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" SELECT T1.ID ServiceID,case when ISNULL(T1.CategoryID,'')='' then '无所属' else T3.CategoryName END CategoryName,ISNULL(T1.CategoryID,'-1') CategoryID ,T1.ServiceName, T1.UnitPrice,case(T1.MarketingPolicy) when 0 then '无优惠' when 1 then '按等级打折' else '按促销价' END MarketingPolicy,ISNULL( T1.PromotionPrice,0) PromotionPrice,T1.CourseFrequency,T1.SpendTime,T1.NeedVisit,T1.VisitTime,T1.HaveExpiration,T1.ExpirationDate,T1.VisibleForCustomer,T1.Describe,T1.Available,");
                strSql.Append("  ISNULL(( SELECT  DiscountName FROM dbo.TBL_DISCOUNT WHERE ID = T1.DiscountID AND available = 1 ),'无') DiscountName,T1.DiscountID,Left(T5.SubServiceNames,LEN(T5.SubServiceNames)-1) SubServiceName,t1.SubServiceCodes,T1.IsConfirmed, case T1.AutoConfirm when 1 then '是' else '否' end as AutoConfirm, case T1.AutoConfirm when 1 then T1.AutoConfirmDays else 0 end as AutoConfirmDays");
                strSql.Append(" FROM SERVICE T1 WITH(NOLOCK) ");

                if (branchId > 0)
                {
                    strSql.Append(" INNER JOIN [TBL_MARKET_RELATIONSHIP] T6 ");
                    strSql.Append(" on T1.Code = T6.Code ");
                    strSql.Append(" AND T6.Type = 0 ");
                    strSql.Append(" AND T6.Available = 1 ");
                    strSql.Append(" AND T6.BranchID = ");
                    strSql.Append(branchId);
                }

                strSql.Append(" left join  ");
                strSql.Append(" IMAGE_SERVICE T2 WITH(NOLOCK) ");
                strSql.Append(" ON T1.ID = T2.ServiceID  ");
                strSql.Append(" AND T2.ImageType = 0  ");
                strSql.Append(" left join  ");
                strSql.Append(" CATEGORY T3 WITH(NOLOCK) ON ");
                strSql.Append(" T1.CategoryID = T3.ID  ");

                strSql.Append(" LEFT JOIN  ");
                strSql.Append(" [TBL_SERVICESORT] T4  WITH(NOLOCK) ");
                strSql.Append(" ON [T1].[CODE] = [T4].[SERVICECODE]  ");
                strSql.Append(@"INNER JOIN (SELECT  T1.ID ,
                                    ( SELECT    SubServiceName+'|'
                                      FROM      dbo.TBL_SubService T2 
                                      WHERE     CHARINDEX('|'+CONVERT(NVARCHAR, SubServiceCode)+'|',
                                                          t1.SubServiceCodes) > 0 AND T2.Available = 1  FOR XML PATH('')
                                    ) SubServiceNames
                            FROM    dbo.SERVICE T1) T5 ON T5.ID = T1.ID ");

                strSql.Append(" WHERE T1.Available = 1 ");
                if (categoryId == -1)
                {
                    strSql.Append(" AND T1.CompanyID = ");
                    strSql.Append(companyId.ToString());
                    strSql.Append(" AND (( T3.type = 0 ");
                    strSql.Append(" AND T3.Available = 1) ");

                    strSql.Append(" OR  ( T1.CategoryID IS NULL OR T1.CategoryID = -1 )) ");
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
                    strSql.Append(" AND T1.Code NOT IN (SELECT Code FROM [TBL_MARKET_RELATIONSHIP] WITH ( NOLOCK ) WHERE CompanyID =" + companyId.ToString() + " and TYPE = 0 and Available = 1 group by Code ) ");
                }
                strSql.Append(" Order by [T4].[Sortid]  ");

                return db.SetCommand(strSql.ToString()).ExecuteDataTable();
            }
        }

        public bool BatchAddService(DataTable dt, Service_Model mService, out string errMsg)
        {
            List<long> listServiceCode = new List<long>();
            string destFolder = Const.uploadServer + "/" + Const.strImage + mService.CompanyID.ToString() + "/Service/";
            string tempFolder = Const.uploadServer + "/" + Const.strImage + "temp/ServiceImage/";
            errMsg = "";

            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSqlAdd = @"
                                        insert into SERVICE(
                                        CompanyID,BranchID,CategoryID,Code,ServiceName,UnitPrice,MarketingPolicy,PromotionPrice,Describe,CourseFrequency,SpendTime,VisitTime,Available,CreatorID,CreateTime,VisibleForCustomer,ExpirationDate,NeedVisit,HaveExpiration,DiscountID,SubServiceCodes,IsConfirmed, AutoConfirm, AutoConfirmDays)
                                         values (
                                        @CompanyID,@BranchID,@CategoryID,@Code,@ServiceName,@UnitPrice,@MarketingPolicy,@PromotionPrice,@Describe,@CourseFrequency,@SpendTime,@VisitTime,@Available,@CreatorID,@CreateTime,@VisibleForCustomer,@ExpirationDate,@NeedVisit,@HaveExpiration,@DiscountID,@SubServiceCodes,@IsConfirmed, @AutoConfirm, @AutoConfirmDays)
                                        ;select @@IDENTITY";

                    string strSqlUpdate = @"
                        update [SERVICE]
                        set
                            CategoryID = @CategoryID,
                            ServiceName = @ServiceName,
                            UnitPrice = @UnitPrice,
                            MarketingPolicy = @MarketingPolicy,
                            PromotionPrice = @PromotionPrice,
                            Describe = @Describe,
                            CourseFrequency = @CourseFrequency,
                            SpendTime = @SpendTime,
                            VisitTime = @VisitTime,
                            Available = @Available,
                            UpdaterID = @UpdaterID,
                            UpdateTime = @UpdateTime,
                            VisibleForCustomer = @VisibleForCustomer,
                            ExpirationDate = @ExpirationDate,
                            NeedVisit = @NeedVisit,
                            HaveExpiration = @HaveExpiration,
                            DiscountID = @DiscountID,
                            SubServiceCodes = @SubServiceCodes,
                            IsConfirmed = @IsConfirmed,
                            AutoConfirm = @AutoConfirm,
                            AutoConfirmDays = @AutoConfirmDays
                        Where CompanyID = @CompanyID and ID = @ServiceID";

                    //string strSqlSelect = " select ID,Code from SERVICE where ID =@ID ";

                    string strSqlInsertSort = @"
                                                insert into TBL_SERVICESORT ( 
                                                Companyid, ServiceCode, Sortid) 
                                                values( 
                                                @Companyid, @ServiceCode, (SELECT ISNULL(MAX(Sortid),0) + 1 FROM TBL_SERVICESORT where CompanyId=@Companyid)) ";

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        for (int i = 1; i < dt.Rows.Count; i++)
                        {
                            string Code = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "ServiceCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                            if (string.IsNullOrEmpty(Code))
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

                            int ExpirationDate = 0;
                            if (dt.Rows[i]["ExpirationDate"].ToString().Trim() != "0")
                            {
                                ExpirationDate = StringUtils.GetDbInt(dt.Rows[i]["ExpirationDate"].ToString(), 0);
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
                            //Common.WriteLOG.WriteLog("ServiceID = " + dt.Rows[i]["ServiceID"].ToString());
                            if (dt.Rows[i]["ServiceID"].ToString() != @"")
                            {
                                //Common.WriteLOG.WriteLog("@CompanyID int = " +  mService.CompanyID.ToString());
                                //Common.WriteLOG.WriteLog("@CategoryID int = " + (dt.Rows[i]["CategoryID"].ToString() == "-1" ? "null" : dt.Rows[i]["CategoryID"].ToString()));
                                //Common.WriteLOG.WriteLog("@ServiceName varchar(max) = " + "'" + dt.Rows[i]["ServiceName"].ToString() + "'");
                                //Common.WriteLOG.WriteLog("@UnitPrice decimal = " + dt.Rows[i]["UnitPrice"].ToString());
                                //Common.WriteLOG.WriteLog("@MarketingPolicy int = " + MarketingPolicy.ToString());
                                //Common.WriteLOG.WriteLog("@PromotionPrice decimal = " + (promotionPrice == 0 ? "null" : promotionPrice.ToString()));
                                //Common.WriteLOG.WriteLog("@Describe varchar(max) = " + "'" + dt.Rows[i]["Describe"].ToString() + "'");
                                //Common.WriteLOG.WriteLog("@CourseFrequency int = " + (Object.Equals(dt.Rows[i]["CourseFrequency"], string.Empty) ? "null" : dt.Rows[i]["CourseFrequency"].ToString()));
                                //Common.WriteLOG.WriteLog("@SpendTime int = " + (Object.Equals(dt.Rows[i]["SpendTime"], string.Empty) ? "null" : dt.Rows[i]["SpendTime"].ToString()));
                                //Common.WriteLOG.WriteLog("@VisitTime int = " + (Object.Equals(dt.Rows[i]["VisitTime"], string.Empty) ? "0" : dt.Rows[i]["VisitTime"].ToString()));
                                //Common.WriteLOG.WriteLog("@NeedVisit bit = " + (dt.Rows[i]["NeedVisit"].ToString() == "是" ? "1" : "0"));
                                //Common.WriteLOG.WriteLog("@ExpirationDate int = " + ExpirationDate.ToString());
                                //Common.WriteLOG.WriteLog("@HaveExpiration bit = " + (dt.Rows[i]["HaveExpiration"].ToString() == "是" ? "1" : "0"));
                                //Common.WriteLOG.WriteLog("@SubServiceCodes varchar(max) = " + (Object.Equals(dt.Rows[i]["SubServiceCodes"], string.Empty) ? "null" : "'" + (dt.Rows[i]["SubServiceCodes"]).ToString() + "'"));
                                //Common.WriteLOG.WriteLog("@Available bit = " + (dt.Rows[i]["Available"].ToString() == "是" ? "1" : "0"));
                                //Common.WriteLOG.WriteLog("@UpdaterID int = " + mService.CreatorID.ToString());
                                //Common.WriteLOG.WriteLog("@UpdateTime Datetime = " + "'" + mService.CreateTime + "'");
                                //Common.WriteLOG.WriteLog("@VisibleForCustomer int = " + (dt.Rows[i]["VisibleForCustomer"].ToString() == "是" ? "1" : "0"));
                                //Common.WriteLOG.WriteLog("@DiscountID int = " + (dt.Rows[i]["DiscountID"].ToString() == "" ? "null" : dt.Rows[i]["DiscountID"].ToString()));
                                //Common.WriteLOG.WriteLog("@IsConfirmed int = " + IsConfirmed.ToString());
                                //Common.WriteLOG.WriteLog("@AutoConfirm tinyint = " + AutoConfirm.ToString());
                                //Common.WriteLOG.WriteLog("@AutoConfirmDays int = " + dt.Rows[i]["AutoConfirmDays"].ToString());
                                //Common.WriteLOG.WriteLog("@ServiceID int = " + dt.Rows[i]["ServiceID"].ToString());
                                //Common.WriteLOG.WriteLog(strSqlUpdate);

                                int result = db.SetCommand(strSqlUpdate, db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)
                                    , db.Parameter("@CategoryID", dt.Rows[i]["CategoryID"].ToString() == "-1" ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["CategoryID"]), DbType.Int32)
                                    , db.Parameter("@ServiceName", dt.Rows[i]["ServiceName"].ToString(), DbType.String)
                                    , db.Parameter("@UnitPrice", Convert.ToDecimal(dt.Rows[i]["UnitPrice"]), DbType.Decimal)
                                    , db.Parameter("@MarketingPolicy", MarketingPolicy, DbType.Int32)
                                    , db.Parameter("@PromotionPrice", promotionPrice == 0 ? (object)DBNull.Value : promotionPrice, DbType.Decimal)
                                    , db.Parameter("@Describe", dt.Rows[i]["Describe"].ToString(), DbType.String)
                                    , db.Parameter("@CourseFrequency", Object.Equals(dt.Rows[i]["CourseFrequency"], string.Empty) ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["CourseFrequency"]), DbType.Int32)
                                    , db.Parameter("@SpendTime", Object.Equals(dt.Rows[i]["SpendTime"], string.Empty) ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["SpendTime"]), DbType.Int32)
                                    , db.Parameter("@VisitTime", Object.Equals(dt.Rows[i]["VisitTime"], string.Empty) ? 0 : StringUtils.GetDbInt(dt.Rows[i]["VisitTime"]), DbType.Int32)
                                    , db.Parameter("@NeedVisit", dt.Rows[i]["NeedVisit"].ToString() == "是" ? true : false, DbType.Boolean)
                                    , db.Parameter("@ExpirationDate", ExpirationDate, DbType.Int32)
                                    , db.Parameter("@HaveExpiration", dt.Rows[i]["HaveExpiration"].ToString() == "是" ? true : false, DbType.Boolean)
                                    , db.Parameter("@SubServiceCodes", Object.Equals(dt.Rows[i]["SubServiceCodes"], string.Empty) ? (object)DBNull.Value : (dt.Rows[i]["SubServiceCodes"]).ToString(), DbType.String)
                                    , db.Parameter("@Available", dt.Rows[i]["Available"].ToString() == "是" ? true : false, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", mService.CreatorID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", mService.CreateTime, DbType.DateTime2)
                                    , db.Parameter("@VisibleForCustomer", dt.Rows[i]["VisibleForCustomer"].ToString() == "是" ? true : false, DbType.Int32)
                                    , db.Parameter("@DiscountID", dt.Rows[i]["DiscountID"].ToString() == "" ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["DiscountID"]), DbType.Int32)
                                    , db.Parameter("@IsConfirmed", IsConfirmed, DbType.Int32)
                                    , db.Parameter("@AutoConfirm", AutoConfirm, DbType.Int16)
                                    , db.Parameter("@AutoConfirmDays", dt.Rows[i]["AutoConfirmDays"].ToString(), DbType.Int32)
                                    , db.Parameter("@ServiceID", dt.Rows[i]["ServiceID"].ToString(), DbType.Int32)).ExecuteNonQuery();
                                //Common.WriteLOG.WriteLog("Service_DAL.Instance.BatchAddService result = " + result.ToString());
                                if (result <= 0)
                                {
                                    errMsg = "服务ID不存在：" + dt.Rows[i]["ServiceID"].ToString();
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else{
                                int serviceId = db.SetCommand(strSqlAdd
                                    , db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", mService.BranchID == -1 ? 0 : mService.BranchID, DbType.Int32)
                                    , db.Parameter("@CategoryID", dt.Rows[i]["CategoryID"].ToString() == "-1" ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["CategoryID"]), DbType.Int32)
                                    , db.Parameter("@ServiceName", dt.Rows[i]["ServiceName"].ToString(), DbType.String)
                                    , db.Parameter("@UnitPrice", Convert.ToDecimal(dt.Rows[i]["UnitPrice"]), DbType.Decimal)
                                    , db.Parameter("@MarketingPolicy", MarketingPolicy, DbType.Int32)
                                    , db.Parameter("@PromotionPrice", promotionPrice == 0 ? (object)DBNull.Value : promotionPrice, DbType.Decimal)
                                    , db.Parameter("@Describe", dt.Rows[i]["Describe"].ToString(), DbType.String)
                                    , db.Parameter("@CourseFrequency", Object.Equals(dt.Rows[i]["CourseFrequency"], string.Empty) ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["CourseFrequency"]), DbType.Int32)
                                    , db.Parameter("@SpendTime", Object.Equals(dt.Rows[i]["SpendTime"], string.Empty) ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["SpendTime"]), DbType.Int32)
                                    , db.Parameter("@VisitTime", Object.Equals(dt.Rows[i]["VisitTime"], string.Empty) ? 0 : StringUtils.GetDbInt(dt.Rows[i]["VisitTime"]), DbType.Int32)
                                    , db.Parameter("@NeedVisit", dt.Rows[i]["NeedVisit"].ToString() == "是" ? true : false, DbType.Boolean)
                                    , db.Parameter("@ExpirationDate", ExpirationDate, DbType.Int32)
                                    , db.Parameter("@HaveExpiration", dt.Rows[i]["HaveExpiration"].ToString() == "是" ? true : false, DbType.Boolean)
                                    , db.Parameter("@SubServiceCodes", Object.Equals(dt.Rows[i]["SubServiceCodes"], string.Empty) ? (object)DBNull.Value : (dt.Rows[i]["SubServiceCodes"]).ToString(), DbType.String)
                                    , db.Parameter("@Available", dt.Rows[i]["Available"].ToString() == "是" ? true : false, DbType.Boolean)
                                    , db.Parameter("@CreatorID", mService.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", mService.CreateTime, DbType.DateTime2)
                                    , db.Parameter("@VisibleForCustomer", dt.Rows[i]["VisibleForCustomer"].ToString() == "是" ? true : false, DbType.Int32)
                                    , db.Parameter("@DiscountID", dt.Rows[i]["DiscountID"].ToString() == "" ? (object)DBNull.Value : StringUtils.GetDbInt(dt.Rows[i]["DiscountID"]), DbType.Int32)
                                    , db.Parameter("@Code", StringUtils.GetDbLong(Code), DbType.Int64)
                                    , db.Parameter("@IsConfirmed", IsConfirmed, DbType.Int32)
                                    , db.Parameter("@AutoConfirm", AutoConfirm, DbType.Int16)
                                    , db.Parameter("@AutoConfirmDays", dt.Rows[i]["AutoConfirmDays"].ToString(), DbType.Int32)).ExecuteScalar<Int32>();

                                if (serviceId <= 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                                else
                                {
                                    long serviceCode = StringUtils.GetDbLong(Code);

                                    if (serviceCode <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return false;
                                    }
                                    else
                                    {
                                        int val = db.SetCommand(strSqlInsertSort, db.Parameter("@Companyid", mService.CompanyID, DbType.Int32)
                                                                                , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)).ExecuteNonQuery();

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
                                                    string tempedFolder = tempFolder + serviceCode + "/";
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
                                                                string filename = string.Format("{0:yyyyMMddHHmmssffff}", DateTime.Now.ToLocalTime()) + (new Random().Next(100000) + j).ToString("d5") + Path.GetExtension(strImageInfo[0]);
                                                                if (Convert.ToInt32(strImageInfo[1]) == 0)
                                                                {
                                                                    filename = "TC" + filename;
                                                                }
                                                                else
                                                                {
                                                                    filename = "C" + filename;
                                                                }

                                                                string strCommand = @"INSERT INTO [IMAGE_SERVICE]
                                                                 ([CompanyID]
                                                                 ,[ServiceCode]
                                                                 ,[ServiceID]
                                                                 ,[ImageType]
                                                                 ,[FileName]
                                                                 ,[CreatorID]
                                                                 ,[CreateTime])
                                                            VALUES
                                                                (@CompanyID
                                                                ,@ServiceCode
                                                                ,@ServiceID
                                                                ,@ImageType
                                                                ,@FileName
                                                                ,@CreatorID
                                                                ,@CreateTime)";

                                                                val = db.SetCommand(strCommand, db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)
                                                                                , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)
                                                                                , db.Parameter("@ServiceID", serviceId, DbType.Int32)
                                                                                , db.Parameter("@ImageType", Convert.ToInt32(strImageInfo[1]), DbType.Int32)
                                                                                , db.Parameter("@FileName", filename, DbType.String)
                                                                                , db.Parameter("@CreatorID", mService.CreatorID, DbType.Int32)
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
                                                    listServiceCode.Add(serviceCode);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        for (int i = 0; i < listServiceCode.Count; i++)
                        {
                            Common.CommonUtility.CopyFolder(tempFolder + listServiceCode[i].ToString() + "\\", destFolder + listServiceCode[i].ToString() + "\\");
                        }
                        db.CommitTransaction();
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public bool deteleMultiService(DelMultiCommodity_Model model)
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
                    string strSqlSelect = "select max(ID) from Service where code =@Code ";
                    object obj = db.SetCommand(strSqlSelect, db.Parameter("@Code", i, DbType.Int64)).ExecuteScalar();
                    if ((Object.Equals(obj, null)) || (Object.Equals(obj, System.DBNull.Value)) || StringUtils.GetDbInt(obj) == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    int serviceId = StringUtils.GetDbInt(obj);

                    string strSqlHistory = @" INSERT INTO [TBL_HISTORY_SERVICE] SELECT * FROM [SERVICE] WHERE ID=@ID ";

                    int rows = db.SetCommand(strSqlHistory,
                                                  db.Parameter("@ID", serviceId, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    DateTime dt = DateTime.Now.ToLocalTime();
                    string strSqlupdate = @"update Service set 
                                            Available = 0,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime =@UpdateTime
                                            where id =@ID";
                    rows = db.SetCommand(strSqlupdate, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                               db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                               db.Parameter("@ID", serviceId, DbType.Int32)).ExecuteNonQuery();
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

        public List<Service_Model> getPrintList(List<long> codeList)
        {
            using (DbManager db = new DbManager())
            {
                List<Service_Model> list = new List<Service_Model>();
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
                    string strSql = @" select T1.ServiceName ,T1.ID,T1.Code ServiceCode,T1.CourseFrequency,T1.UnitPrice ,T2.CompanyCode
                                from Service T1
                                INNER JOIN dbo.COMPANY T2 ON T1.CompanyID = T2.ID
                                where T1.ID IN (  
                                select MAX(ID) from Service where Available = 1 and Code In ( " + strWhere + ") group by Code)";

                    list = db.SetCommand(strSql).ExecuteList<Service_Model>();
                }
                return list;
            }
        }

        public int addService(ServiceDetailOperation_Model mService, out long serviceCode)
        {
            using (DbManager db = new DbManager())
            {
                try
                {

                    db.BeginTransaction();
                    long ServiceCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "ServiceCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                    if (ServiceCode == 0)
                    {
                        db.RollbackTransaction();
                        serviceCode = 0;
                        return 0;
                    }

                    string strSqlAdd = @" insert into SERVICE( 
                                        CompanyID,BranchID,CategoryID,Code,ServiceName,UnitPrice,MarketingPolicy,PromotionPrice,Describe,CourseFrequency,SpendTime,VisitTime,Available,CreatorID,CreateTime,VisibleForCustomer,ExpirationDate,NeedVisit,HaveExpiration,SubServiceCodes,SerialNumber,DiscountID,IsConfirmed,Recommended, AutoConfirm, AutoConfirmDays, UpdaterID, UpdateTime)
                                        values (
                                        @CompanyID,@BranchID,@CategoryID,@Code,@ServiceName,@UnitPrice,@MarketingPolicy,@PromotionPrice,@Describe,@CourseFrequency,@SpendTime,@VisitTime,@Available,@CreatorID,@CreateTime,@VisibleForCustomer,@ExpirationDate,@NeedVisit,@HaveExpiration,@SubServiceCodes,@SerialNumber,@DiscountID,@IsConfirmed,@Recommended, @AutoConfirm, @AutoConfirmDays,@CreatorID,@CreateTime)
                                        ;select @@IDENTITY";

                    int serviceId = db.SetCommand(strSqlAdd, db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", 0, DbType.Int32)
                        , db.Parameter("@CategoryID", mService.CategoryID == 0 ? (object)DBNull.Value : mService.CategoryID, DbType.Int32)
                        , db.Parameter("@Code", ServiceCode, DbType.Int64)
                        , db.Parameter("@ServiceName", mService.ServiceName, DbType.String)
                        , db.Parameter("@UnitPrice", mService.UnitPrice, DbType.Decimal)
                        , db.Parameter("@MarketingPolicy", mService.MarketingPolicy, DbType.Int16)
                        , db.Parameter("@PromotionPrice", mService.MarketingPolicy == 2 ? mService.PromotionPrice : (object)DBNull.Value, DbType.Decimal)
                        , db.Parameter("@Describe", mService.Describe, DbType.String)
                        , db.Parameter("@CourseFrequency", mService.CourseFrequency == -1 ? (object)DBNull.Value : mService.CourseFrequency, DbType.Int16)
                        , db.Parameter("@SpendTime", mService.SpendTime == -1 ? (object)DBNull.Value : mService.SpendTime, DbType.Int32)
                        , db.Parameter("@VisitTime", mService.VisitTime == -1 ? (object)DBNull.Value : mService.VisitTime, DbType.Int32)
                        , db.Parameter("@Available", mService.Available, DbType.Boolean)
                        , db.Parameter("@CreatorID", mService.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        , db.Parameter("@VisibleForCustomer", mService.VisibleForCustomer, DbType.Boolean)
                        , db.Parameter("@ExpirationDate", mService.ExpirationDate, DbType.Int16)
                        , db.Parameter("@NeedVisit", mService.NeedVisit, DbType.Boolean)
                        , db.Parameter("@HaveExpiration", mService.HaveExpiration, DbType.Boolean)
                        , db.Parameter("@SubServiceCodes", mService.SubServiceCodes, DbType.String)
                        , db.Parameter("@SerialNumber", mService.SerialNumber, DbType.String)
                        , db.Parameter("@DiscountID", mService.MarketingPolicy == 1 ? (mService.DiscountID == -1 ? (object)DBNull.Value : mService.DiscountID) : (object)DBNull.Value, DbType.Int32)
                        , db.Parameter("@IsConfirmed", mService.IsConfirmed, DbType.Int16)
                        , db.Parameter("@Recommended", mService.Recommended, DbType.Boolean)
                        , db.Parameter("@AutoConfirm", mService.AutoConfirm, DbType.Int16)
                        , db.Parameter("@AutoConfirmDays", mService.AutoConfirmDays, DbType.Int32)).ExecuteScalar<int>();

                    if (serviceId == 0)
                    {
                        db.RollbackTransaction();
                        serviceCode = 0;
                        return 0;
                    }

                    string strSqlAddSort = @" insert into TBL_SERVICESORT ( 
                                            Companyid, ServiceCode, Sortid)
                                            values( 
                                            @Companyid, @ServiceCode, (SELECT ISNULL(MAX(Sortid),0) + 1 
                                            FROM TBL_SERVICESORT 
                                            where CompanyId=@Companyid)) ";

                    int rows = db.SetCommand(strSqlAddSort, db.Parameter("@Companyid", mService.CompanyID, DbType.Int32)
                        , db.Parameter("@ServiceCode", ServiceCode, DbType.Int64)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        serviceCode = 0;
                        return 0;
                    }

                    if (mService.BranchID > 0)
                    {
                        string strSqlRelationShipAdd = @"INSERT INTO [TBL_MARKET_RELATIONSHIP]                                               
                                                      (CompanyID,BranchID,Type,Code,Available,OperatorID,OperateTime)
                                                      VALUES
                                                      (@stockCompanyID,@stockBranchID,@stockType,@stockCode,@stockAvailable,@stockOperatorID,@stockOperateTime)";

                        rows = db.SetCommand(strSqlRelationShipAdd, db.Parameter("@stockCompanyID", mService.CompanyID, DbType.Int32)
                            , db.Parameter("@stockBranchID", mService.BranchID, DbType.Int32)
                            , db.Parameter("@stockType", 0, DbType.Int32)
                            , db.Parameter("@stockCode", ServiceCode, DbType.Int64)
                            , db.Parameter("@stockAvailable", true, DbType.Boolean)
                            , db.Parameter("@stockOperatorID", mService.CreatorID, DbType.Int32)
                            , db.Parameter("@stockOperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            serviceCode = 0;
                            return 0;
                        }
                    }
                    db.CommitTransaction();
                    serviceCode = ServiceCode;
                    return serviceId;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public int updateService(ServiceDetailOperation_Model mService)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = "select Count(*) from [SERVICE] WITH(NOLOCK) where Available = 1 and ID=@ServiceID";

                    int serviceCount = db.SetCommand(strSql, db.Parameter("@ServiceID", mService.ServiceID, DbType.Int32)).ExecuteScalar<int>();

                    if (serviceCount <= 0)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    else
                    {
                        strSql = @"SELECT count(0) FROM [TBL_ORDER_SERVICE] WHERE ServiceID=@ServiceID";

                        int ordercount = db.SetCommand(strSql, db.Parameter("@ServiceID", mService.ServiceID, DbType.Int32)).ExecuteScalar<int>();

                        string strSqlGetCreatInfo = @" select CreatorID,CreateTime from [SERVICE] where CompanyID=@CompanyID and ID=@ServiceID  ";
                        ServiceDetailOperation_Model temp = db.SetCommand(strSqlGetCreatInfo, db.Parameter("@ServiceID", mService.ServiceID, DbType.Int32)
                                , db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)).ExecuteObject<ServiceDetailOperation_Model>();

                        if (temp == null)
                        {
                            db.RollbackTransaction();
                            return -1;
                        }

                        mService.CreatorID = temp.CreatorID;
                        mService.CreateTime = temp.CreateTime;
                        int serviceID = 0;
                        // 2014-07-30 Aaron修改 如果没有被Order使用过就直接删除插入历史表
                        int val = 0;
                        if (ordercount > 0)
                        {
                            #region Order表中已经有数据,修改状态
                            strSql = @"
                                       update SERVICE set 
                                       Available=0,
                                       UpdaterID=@UpdaterID, 
                                       UpdateTime=@UpdateTime
                                        where ID=@ServiceID";

                            val = db.SetCommand(strSql
                                , db.Parameter("@UpdaterID", mService.UpdaterID, DbType.Int32)
                                , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                , db.Parameter("@ServiceID", mService.ServiceID, DbType.Int32)).ExecuteNonQuery();

                            if (val < 1)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }


                            strSql = @"
                                         insert into SERVICE ( 
                                         CompanyID,BranchID,CategoryID,Code,ServiceName,UnitPrice,MarketingPolicy,PromotionPrice,Describe,CourseFrequency,SpendTime,VisitTime,Available,CreatorID,CreateTime,VisibleForCustomer,ExpirationDate,NeedVisit,HaveExpiration,SubServiceCodes,SerialNumber,DiscountID,IsConfirmed, UpdaterID,UpdateTime,Recommended) 
                                         values( 
                                         @CompanyID,@BranchID,@CategoryID,@Code,@ServiceName,@UnitPrice,@MarketingPolicy,@PromotionPrice,@Describe,@CourseFrequency,@SpendTime,@VisitTime,@Available,@CreatorID,@CreateTime,@VisibleForCustomer,@ExpirationDate,@NeedVisit,@HaveExpiration,@SubServiceCodes,@SerialNumber,@DiscountID,@IsConfirmed, @UpdaterID,@UpdateTime,@Recommended) 
                                        ;select @@IDENTITY";

                            serviceID = db.SetCommand(strSql
                                , db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", mService.BranchID, DbType.Int32)
                                , db.Parameter("@CategoryID", (mService.CategoryID != 0) ? mService.CategoryID : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@Code", mService.ServiceCode, DbType.Int64)
                                , db.Parameter("@ServiceName", mService.ServiceName, DbType.String)
                                , db.Parameter("@UnitPrice", mService.UnitPrice, DbType.Decimal)
                                , db.Parameter("@MarketingPolicy", mService.MarketingPolicy, DbType.Int32)
                                , db.Parameter("@PromotionPrice", mService.MarketingPolicy == 2 ? mService.PromotionPrice : (object)DBNull.Value, DbType.Decimal)
                                , db.Parameter("@Describe", mService.Describe, DbType.String)
                                , db.Parameter("@CourseFrequency", mService.CourseFrequency, DbType.Int32)
                                , db.Parameter("@SpendTime", (mService.SpendTime != -1) ? mService.SpendTime : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@VisitTime", mService.VisitTime != -1 ? mService.VisitTime : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@Available", mService.Available, DbType.Boolean)
                                , db.Parameter("@CreatorID", mService.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", mService.CreateTime, DbType.DateTime2)
                                , db.Parameter("@VisibleForCustomer", mService.VisibleForCustomer, DbType.Boolean)
                                , db.Parameter("@ExpirationDate", mService.ExpirationDate, DbType.Int32)
                                , db.Parameter("@NeedVisit", mService.NeedVisit, DbType.Int32)
                                , db.Parameter("@HaveExpiration", mService.HaveExpiration, DbType.Boolean)
                                , db.Parameter("@SubServiceCodes", mService.SubServiceCodes, DbType.String)
                                , db.Parameter("@SerialNumber", mService.SerialNumber, DbType.String)
                                , db.Parameter("@DiscountID", (mService.MarketingPolicy == 1 && mService.DiscountID != -1) ? mService.DiscountID : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@IsConfirmed", mService.IsConfirmed, DbType.Int16)
                                , db.Parameter("@UpdaterID", mService.UpdaterID, DbType.Int32)
                                , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                , db.Parameter("@Recommended", mService.Recommended, DbType.Boolean)
                                ).ExecuteScalar<int>();
                            if (serviceID <= 0)
                            {
                                db.RollbackTransaction();
                                return serviceID;
                            }


                            #endregion
                        }
                        else
                        {
                            // Order表中没有数据,加入历史表
                            strSql = @" INSERT  INTO [TBL_HISTORY_SERVICE] SELECT * FROM [SERVICE] WHERE ID=@ServiceID";

                            val = db.SetCommand(strSql, db.Parameter("@ServiceID", mService.ServiceID, DbType.Int32)).ExecuteNonQuery();

                            if (val < 1)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            else
                            {
                                // 记录修改人
                                strSql = @" update SERVICE set CategoryID=@CategoryID
                                            ,ServiceName=@ServiceName
                                            ,UnitPrice=@UnitPrice
                                            ,MarketingPolicy=@MarketingPolicy
                                            ,PromotionPrice=@PromotionPrice
                                            ,Describe=@Describe
                                            ,CourseFrequency=@CourseFrequency
                                            ,SpendTime=@SpendTime
                                            ,VisitTime=@VisitTime
                                            ,VisibleForCustomer=@VisibleForCustomer
                                            ,ExpirationDate=@ExpirationDate
                                            ,NeedVisit=@NeedVisit
                                            ,HaveExpiration=@HaveExpiration
                                            ,SubServiceCodes=@SubServiceCodes
                                            ,SerialNumber=@SerialNumber
                                            ,DiscountID=@DiscountID
                                            ,IsConfirmed=@IsConfirmed
                                            ,Recommended=@Recommended
                                            ,AutoConfirm=@AutoConfirm
                                            ,AutoConfirmDays=@AutoConfirmDays
                                            ,UpdaterID=@UpdaterID
                                            ,UpdateTime=@UpdateTime
                                            WHERE ID=@ServiceID AND CompanyID =@CompanyID";

                                val = db.SetCommand(strSql
                                , db.Parameter("@CategoryID", (mService.CategoryID != 0) ? mService.CategoryID : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@ServiceName", mService.ServiceName, DbType.String)
                                , db.Parameter("@UnitPrice", mService.UnitPrice, DbType.Decimal)
                                , db.Parameter("@MarketingPolicy", mService.MarketingPolicy, DbType.Int32)
                                , db.Parameter("@PromotionPrice", mService.MarketingPolicy == 2 ? mService.PromotionPrice : (object)DBNull.Value, DbType.Decimal)
                                , db.Parameter("@Describe", mService.Describe, DbType.String)
                                , db.Parameter("@CourseFrequency", mService.CourseFrequency, DbType.Int32)
                                , db.Parameter("@SpendTime", (mService.SpendTime != -1) ? mService.SpendTime : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@VisitTime", mService.VisitTime != -1 ? mService.VisitTime : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@VisibleForCustomer", mService.VisibleForCustomer, DbType.Boolean)
                                , db.Parameter("@ExpirationDate", mService.ExpirationDate, DbType.Int32)
                                , db.Parameter("@NeedVisit", mService.NeedVisit, DbType.Int32)
                                , db.Parameter("@HaveExpiration", mService.HaveExpiration, DbType.Boolean)
                                , db.Parameter("@SubServiceCodes", mService.SubServiceCodes, DbType.String)
                                , db.Parameter("@SerialNumber", mService.SerialNumber, DbType.String)
                                , db.Parameter("@DiscountID", (mService.MarketingPolicy == 1 && mService.DiscountID != -1) ? mService.DiscountID : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@IsConfirmed", mService.IsConfirmed, DbType.Int16)
                                , db.Parameter("@Recommended", mService.Recommended, DbType.Boolean)
                                , db.Parameter("@AutoConfirm", mService.AutoConfirm, DbType.Int16)
                                , db.Parameter("@AutoConfirmDays", mService.AutoConfirmDays, DbType.Int32)
                                , db.Parameter("@UpdaterID", mService.UpdaterID, DbType.Int32)
                                , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                , db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)
                                , db.Parameter("@ServiceID", mService.ServiceID, DbType.Int32)).ExecuteNonQuery();

                                if (val < 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                serviceID = mService.ServiceID;

                            }
                        }

                        db.CommitTransaction();
                        return serviceID;
                    }
                }
                catch
                {
                    db.RollbackTransaction();
                    return 0;
                }
            }
        }

        private int SelectOrderByServiceId(int serviceId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT count(0) FROM [Order] WHERE ProductID=@ServiceID  AND ProductType=0";

                return db.SetCommand(strSql, db.Parameter("@ServiceID", serviceId, DbType.Int32)).ExecuteScalar<int>();
            }
        }

        public bool UpdateServiceSort(int companyID, List<ServiceSort_Model> list)
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
                        string strSql = @"update TBL_SERVICESORT set [Sortid]=@Sortid WHERE  [ServiceCode]=@ServiceCode AND CompanyID=@CompanyID;";
                        int res = db.SetCommand(strSql, db.Parameter("@Sortid", item.Sortid, DbType.Int32)
                                    , db.Parameter("@ServiceCode", item.ServiceCode, DbType.Int64)
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
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public List<SubService_Model> getSubServiceList(int companyId)
        {
            List<SubService_Model> list = new List<SubService_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"select [TBL_SubService].SubServiceCode,  [TBL_SubService].CompanyID, [TBL_SubService].ID, [TBL_SubService].SubServiceName, [TBL_SubService].VisitTime, [TBL_SubService].NeedVisit, [TBL_SubService].SpendTime  from [TBL_SubService] with (Nolock)  Where [TBL_SubService].ID in (select MAX(ID) FROM [TBL_SubService] where Available = 1 group by [TBL_SubService].SubServiceCode ) and [TBL_SubService].CompanyID =@CompanyID ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<SubService_Model>();
                return list;
            }
        }

        public bool OperationServiceBranch(ServiceDetailOperation_Model mService)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlMarketUpdate = @"update  [TBL_MARKET_RELATIONSHIP] 
                                                        set Available=@Available, 
                                                        OperatorID = @OperatorID,
                                                        OperateTime = @OperateTime 
                                                        where Code=@Code AND Type = 0 ";

                int val = db.SetCommand(strSqlMarketUpdate
                    , db.Parameter("@Available", false, DbType.Boolean)
                    , db.Parameter("@OperatorID", mService.UpdaterID, DbType.Int32)
                    , db.Parameter("@OperateTime", mService.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@Code", mService.ServiceCode, DbType.Int64)
                    ).ExecuteNonQuery();

                //if (val < 1)
                //{
                //    db.RollbackTransaction();
                //    return false;
                //}

                string strSqlMarketHistory = @" INSERT INTO [TBL_HISTORY_MARKET_RELATIONSHIP] 
                                                            SELECT * FROM [TBL_MARKET_RELATIONSHIP] WHERE CODE =@CODE AND Type = 0 ";



                int marketRows = db.SetCommand(strSqlMarketHistory
                    , db.Parameter("@Code", mService.ServiceCode, DbType.Int64)
                    ).ExecuteNonQuery();

                if (val != marketRows)
                {
                    db.RollbackTransaction();
                    return false;
                }



                string strSqlMarketDelete = @" delete [TBL_MARKET_RELATIONSHIP]  WHERE CODE =@CODE AND Type = 0 ";



                marketRows = db.SetCommand(strSqlMarketDelete
                    , db.Parameter("@Code", mService.ServiceCode, DbType.Int64)
                    ).ExecuteNonQuery();

                if (val != marketRows)
                {
                    db.RollbackTransaction();
                    return false;
                }

                if (mService.BranchList != null && mService.BranchList.Count > 0)
                {
                    string strSqlRelationShipAdd = @"INSERT INTO [TBL_MARKET_RELATIONSHIP]                                               
                                                      (CompanyID,BranchID,Type,Code,Available,OperatorID,OperateTime)
                                                      VALUES
                                                      (@CompanyID,@BranchID,@Type,@Code,@Available,@OperatorID,@OperateTime)";



                    foreach (ServiceBranch item in mService.BranchList)
                    {
                        val = db.SetCommand(strSqlRelationShipAdd, db.Parameter("@CompanyID", mService.CompanyID, DbType.Int32)
                                                                , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                                                                , db.Parameter("@Type", 0, DbType.Int32)
                                                                , db.Parameter("@Code", mService.ServiceCode, DbType.Int64)
                                                                , db.Parameter("@Available", true, DbType.Boolean)
                                                                , db.Parameter("@OperatorID", mService.UpdaterID, DbType.Int32)
                                                                , db.Parameter("@OperateTime", mService.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();
                        if (val < 1)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                    }
                }

                db.CommitTransaction();
                return true;
            }
        }

    }
}
