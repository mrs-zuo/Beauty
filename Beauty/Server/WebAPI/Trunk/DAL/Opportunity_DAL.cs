using BLToolkit.Data;
using HS.Framework.Common;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Opportunity_DAL
    {
        #region 构造类实例
        public static Opportunity_DAL Instance
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
            internal static readonly Opportunity_DAL instance = new Opportunity_DAL();
        }
        #endregion

        public List<OpportunityList_Model> getOpportunityList(GetOpportunityListOperation_Model model, int pageSize, int pageIndex, out int recordCount)
        {
            List<OpportunityList_Model> list = new List<OpportunityList_Model>();
            using (DbManager db = new DbManager())
            {
                string strMainSql = "SELECT {0} FROM    ({1}) AS b";
                string strSelectSql = "";
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY CreateTime DESC ) AS rowNum ,
                                                        CustomerName ,CustomerID ,OpportunityID ,ProductName ,ProductID ,
                                                        ProductCode ,ProductType , ResponsiblePersonName ,Available ,CreateTime ,ProgressRate ,ExpirationTime ";

                string strServiceSql = @"

            ( SELECT   T1.ID ,T6.Name AS CustomerName ,T1.CustomerID ,T1.ID AS OpportunityID ,T2.ServiceName AS ProductName ,T2.ID AS ProductID ,T2.Code AS ProductCode ,T1.ProductType ,ISNULL(T1.ResponsiblePersonID,0) AS ResponsiblePersonID ,T9.NAME AS ResponsiblePersonName,case  when T2.Available =1 and T10.Available = 1 then 1 else 0 end Available,
            T1.CreateTime ,CAST(CAST(ROUND(CAST(T8.Progress * 100 AS DECIMAL(7, 2)) / CAST(T7.StepNumber AS DECIMAL(5, 2)), 2) AS DECIMAL(5,2)) AS NVARCHAR(6))+ '%' ProgressRate,
            ( CASE WHEN T2.HaveExpiration = 0 THEN '2099-12-31'ELSE ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, T2.ExpirationDate, GETDATE()), 25), '')END ) AS ExpirationTime
            FROM OPPORTUNITY T1
            LEFT JOIN ( SELECT  * FROM [Service] WHERE ID IN ( SELECT  MAX(ID) ProgressID FROM [Service] GROUP BY Code )) T2 ON T1.ProductCode = T2.Code
            LEFT JOIN [CUSTOMER] T6 ON T1.CustomerID = T6.UserID
            LEFT JOIN [STEP] T7 ON T1.StepID = T7.ID
            LEFT JOIN ( SELECT * FROM [PROGRESS] WHERE ID IN ( SELECT MAX(ID) FROM PROGRESS GROUP BY OpportunityID )) T8 ON T8.OpportunityID = T1.ID
            LEFT JOIN [Account] T9 ON T1.ResponsiblePersonID = T9.UserID
            LEFT JOIN( SELECT ID ,
                    CompanyID ,
                    BranchID ,
                    Code ,
                    Available
             FROM   dbo.TBL_MARKET_RELATIONSHIP
             WHERE  ID IN ( SELECT  MAX(ID)
                            FROM    TBL_MARKET_RELATIONSHIP T1
                            WHERE   T1.Type = 0
                            AND T1.BranchID = @BranchID
                            GROUP BY T1.Code )) T10
            ON T1.ProductCode = T10.Code
            WHERE T1.CompanyID = @CompanyID
            AND T1.Status = 0
            AND T1.ProductType = 0
            AND T1.BranchID =@BranchID {0}
 )";

                string strCommoditySql = @"( SELECT   T1.ID ,T3.Name AS CustomerName ,T1.CustomerID ,T1.ID AS OpportunityID ,T2.CommodityName +  ISNULL(' ' +T2.Specification,'') AS ProductName ,T2.ID AS ProductID,T2.Code AS ProductCode ,T1.ProductType ,ISNULL(T1.ResponsiblePersonID,0) AS ResponsiblePersonID ,T9.NAME AS ResponsiblePersonName,case  when T2.Available =1 and T10.Available = 1 and T11.Available = 1 then 1 else 0 end Available,
            T1.CreateTime ,CAST(CAST(ROUND(CAST(T8.Progress * 100 AS DECIMAL(7, 2))/ CAST(T4.StepNumber AS DECIMAL(5, 2)), 2) AS DECIMAL(5,2)) AS NVARCHAR(6))+ '%' ProgressRate,
            ExpirationTime='2099-12-31'
   FROM     [OPPORTUNITY] T1
            LEFT JOIN ( SELECT * FROM [COMMODITY] WHERE ID IN ( SELECT  MAX(ID) FROM [COMMODITY] GROUP BY Code )) T2 ON T1.ProductCode = T2.Code
            LEFT JOIN [CUSTOMER] T3 ON T1.CustomerID = T3.UserID
            LEFT JOIN [STEP] T4 ON T1.StepID = T4.ID
            LEFT JOIN ( SELECT * FROM PROGRESS WHERE ID IN ( SELECT MAX(ID) ProgressID FROM PROGRESS GROUP BY OpportunityID )) T8 ON T8.OpportunityID = T1.ID
            LEFT JOIN [Account] T9 ON T1.ResponsiblePersonID = T9.UserID
            LEFT JOIN( SELECT ID ,
                    CompanyID ,
                    BranchID ,
                    Code ,
                    Available
             FROM   dbo.TBL_MARKET_RELATIONSHIP
             WHERE  ID IN ( SELECT  MAX(ID)
                            FROM    TBL_MARKET_RELATIONSHIP T1
                            WHERE   T1.Type = 1
                            AND T1.BranchID = @BranchID
                            GROUP BY T1.Code  )) T10
            ON T1.ProductCode = T10.Code
            LEFT JOIN(
                    SELECT ProductCode Code,CASE WHEN StockCalcType = 1 AND ProductQty<=0 THEN 0 ELSE 1 END Available FROM  dbo.TBL_PRODUCT_STOCK T1
                    LEFT JOIN  dbo.ACCOUNT T2 ON T1.BranchID =  t2.BranchID
                    WHERE  ProductType = 1 AND T1.BranchID = @BranchID ) T11 on T1.ProductCode = T11.Code
            WHERE    T1.CompanyID = @CompanyID
                    AND T1.Status = 0
                    AND T1.ProductType = 1
                    AND T1.BranchID =@BranchID {0}
 )";

                string sqlWhere = "";
                if (model.ResponsiblePersonIDs != null && model.ResponsiblePersonIDs.Count > 0)
                {
                    sqlWhere += " AND T1.ResponsiblePersonID in ( ";
                    for (int i = 0; i < model.ResponsiblePersonIDs.Count; i++)
                    {
                        if (i == 0)
                        {
                            sqlWhere += model.ResponsiblePersonIDs[i].ToString();
                        }
                        else
                        {
                            sqlWhere += "," + model.ResponsiblePersonIDs[i].ToString();
                        }
                    }
                    sqlWhere += " )";
                }


                if (model.CustomerID > 0)
                {
                    sqlWhere += " AND T1.CustomerID = @CustomerID ";
                }

                if (model.FilterByTimeFlag == 1)
                {

                    sqlWhere += Common.APICommon.getSqlWhereData_1_7_2(4, model.StartTime, model.EndTime, " T1.CreateTime");
                }

                strServiceSql = string.Format(strServiceSql, sqlWhere);
                strCommoditySql = string.Format(strCommoditySql, sqlWhere);

                if (model.ProductType == 0)
                {
                    strSelectSql = strServiceSql;
                }
                else if (model.ProductType == 1)
                {
                    strSelectSql = strCommoditySql;
                }
                else
                {
                    strSelectSql = strServiceSql + " UNION " + strCommoditySql;
                }

                string strCountSql = string.Format(strMainSql, " count(0) ", strSelectSql);

                string strgetListSql = "select * from( " + string.Format(strMainSql, fileds, strSelectSql) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize + "  ";


                if (model.PageIndex > 1)
                {
                    strgetListSql += " AND CreateTime < @CreateTime";
                }



                recordCount = db.SetCommand(strCountSql, db.Parameter("@AccountID", model.AccountID, DbType.Int32)
                                             , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                             , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                             , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@AccountID", model.AccountID, DbType.Int32)
                                             , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                             , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                             , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteList<OpportunityList_Model>();

            }
            return list;
        }

        public OpportunityDetail_Model getOpportunityDetail(int opportunityId, int productType)
        {
            OpportunityDetail_Model model = new OpportunityDetail_Model();
            using (DbManager db = new DbManager())
            {
                string strsql = "";
                if (productType == 0)
                {
                    //0:服务 1：商品
                    strsql = @"SELECT TOP 1
                                            T2.ID AS OpportunityID ,
                                            T4.ID AS ProductID ,
                                            T2.ProductType ,
                                            T4.ServiceName AS ProductName ,
                                            T2.BranchID ,
                                            T1.Quantity ,
                                            T1.TotalOrigPrice ,
                                            T1.TotalCalcPrice ,
                                            T1.TotalSalePrice ,
                                            CONVERT(VARCHAR(16), T2.CreateTime, 20) CreateTime ,
                                            T1.Progress ,
                                            T3.StepContent ,
                                            T4.UnitPrice ,
                                            ISNULL(T4.PromotionPrice,0.00) AS PromotionPrice ,
                                            T4.MarketingPolicy ,
                                            T2.CustomerID ,
                                            T5.Name AS CustomerName,
                                            T4.Code AS ProductCode,
                                            ISNULL(T2.ResponsiblePersonID,0) AS ResponsiblePersonID,
                                            ( CASE WHEN T4.HaveExpiration = 0 THEN '2099-12-31' ELSE ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, T4.ExpirationDate, GETDATE()), 25), '')END ) AS ExpirationTime
                                    FROM    PROGRESS T1
                                            LEFT JOIN [OPPORTUNITY] T2 ON T2.ID = T1.OpportunityID
                                            LEFT JOIN [STEP] T3 ON T3.ID = T2.StepID
                                            LEFT JOIN ( SELECT  * FROM [Service] WHERE   ID IN ( SELECT  MAX(ID) ProgressID FROM [Service] GROUP BY Code )) T4 ON T2.ProductCode = T4.Code
                                            LEFT JOIN [CUSTOMER] T5 ON T5.UserID = T2.CustomerID
                                    WHERE   T2.ID = @OpportunityID
                                            AND T1.Available = 1
                                            AND T2.ProductType = @ProductType
                                    ORDER BY T1.ID DESC";
                }
                else
                {
                    strsql = @"SELECT TOP 1
                                            T2.ID AS OpportunityID ,
                                            T4.ID AS ProductID ,
                                            T2.ProductType ,
                                            T4.CommodityName AS ProductName ,
                                            T2.BranchID ,
                                            T1.Quantity ,
                                            T1.TotalOrigPrice ,
                                            T1.TotalCalcPrice ,
                                            T1.TotalSalePrice ,
                                            CONVERT(VARCHAR(16), T2.CreateTime, 20) CreateTime ,
                                            T1.Progress ,
                                            T3.StepContent ,
                                            T4.UnitPrice ,
                                            ISNULL(T4.PromotionPrice, 0.00) AS PromotionPrice ,
                                            T4.MarketingPolicy ,
                                            T2.CustomerID ,
                                            T5.Name AS CustomerName ,
                                            T4.Code AS ProductCode ,
                                            ISNULL(T2.ResponsiblePersonID, 0) AS ResponsiblePersonID ,
                                            ExpirationTime='2099-12-31'
                                    FROM    PROGRESS T1
                                            LEFT JOIN OPPORTUNITY T2 ON T2.ID = T1.OpportunityID
                                            LEFT JOIN STEP T3 ON T3.ID = T2.StepID
                                            LEFT JOIN ( SELECT * FROM [COMMODITY] WHERE ID IN ( SELECT  MAX(ID) FROM [COMMODITY] GROUP BY Code )) T4 ON T2.ProductCode = T4.Code
                                            LEFT JOIN CUSTOMER T5 ON T5.UserID = T2.CustomerID
                                    WHERE   T2.ID = @OpportunityID
                                            AND T1.Available = 1
                                            AND T2.ProductType = @ProductType
                                    ORDER BY T1.ID DESC";
                }
                model = db.SetCommand(strsql, db.Parameter("@OpportunityID", opportunityId, DbType.Int32),
                                     db.Parameter("@ProductType", productType, DbType.Int32)).ExecuteObject<OpportunityDetail_Model>();
                return model;
            }


        }

        public int GetMaxStepId(int companyId, Int64 stepCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select MAX(ID) from STEP where CompanyID = @CompanyID AND StepCode=@StepCode ";

                int maxID = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                , db.Parameter("@StepCode", stepCode, DbType.Int64)).ExecuteScalar<int>();
                return maxID;
            }
        }

        public bool addOpportunity(OpportunityAddOperation_Model model)
        {

            if (model == null || model.ProductList == null || model.ProductList.Count <= 0)
            {
                return false;
            }

            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    foreach (var item in model.ProductList)
                    {
                        #region 计算价格,获取proID
                        Commodity_Model com_model = new Commodity_Model();
                        if (item.ProductType == 1)
                        {
                            string strSqlSelectProId = @"SELECT ID,MarketingPolicy,UnitPrice,PromotionPrice,DiscountID FROM [COMMODITY] WHERE CompanyID=@CompanyID AND Code=@Code AND Available=1 ORDER BY CreateTime DESC";
                            com_model = db.SetCommand(strSqlSelectProId,
                                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                        db.Parameter("@Code", item.ProductCode, DbType.Int64)).ExecuteObject<Commodity_Model>();
                        }
                        else
                        {
                            string strSqlSelectProId = @"SELECT ID,MarketingPolicy,UnitPrice,PromotionPrice,DiscountID FROM [SERVICE] WHERE CompanyID=@CompanyID AND Code=@Code AND Available=1 ORDER BY CreateTime DESC";
                            com_model = db.SetCommand(strSqlSelectProId,
                                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                        db.Parameter("@Code", item.ProductCode, DbType.Int64)).ExecuteObject<Commodity_Model>();
                        }
                        if (com_model == null)
                        {
                            return false;
                        }

                        item.ProductID = com_model.ID;
                        item.TotalOrigPrice = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);

                        #region 计算价格
                        //按等级折扣
                        if (com_model.MarketingPolicy == 1)
                        {
                            //查询等级折扣
                            string strSelectDiscount = @"SELECT  ISNULL(Discount, 1.00) Discount
                                                                 FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                                         LEFT JOIN (SELECT P1.CardID,P1.Discount,P2.ID from [TBL_CARD_DISCOUNT] P1 INNER JOIN [TBL_DISCOUNT] P2 ON P1.DiscountID = P2.ID
                                                                        ) T2 ON T1.LevelID = T2.CardID
                                                                 WHERE   T1.CompanyID = @CompanyID
                                                                         AND T1.UserID = @UserID
                                                                         AND T2.ID=@DiscountID
                                                                         AND T1.Available = 1";
                            decimal dicount = db.SetCommand(strSelectDiscount,
                                           db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                           db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                           db.Parameter("@DiscountID", com_model.DiscountID, DbType.Int32)).ExecuteScalar<decimal>();

                            if (dicount > 0)
                            {
                                item.TotalCalcPrice = Math.Round(com_model.UnitPrice * dicount * (decimal)item.Quantity, 2);
                            }
                            else
                            {
                                item.TotalCalcPrice = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);
                            }
                        }
                        //促销价销售
                        else if (com_model.MarketingPolicy == 2)
                        {
                            item.TotalCalcPrice = Math.Round(com_model.PromotionPrice * (decimal)item.Quantity, 2);
                        }
                        //原价销售
                        else
                        {
                            item.TotalCalcPrice = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);
                        }

                        //实际售价赋值
                        if (item.TotalSalePrice < 0)
                        {
                            item.TotalSalePrice = item.TotalCalcPrice;
                        }
                        #endregion

                        #endregion

                        if (item.ResponsiblePersonID == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        //int stepId = Opportunity_DAL.Instance.GetMaxStepId(model.CompanyID, item.StepCode);

                        string strSqlinsertOpportunity = @"insert into OPPORTUNITY(CompanyID,BranchID,CustomerID,ProductType,ProductCode,StepID,Status,CreatorID,CreateTime,ResponsiblePersonID)
                                                                   values (@CompanyID,@BranchID,@CustomerID,@ProductType,@ProductCode,@StepID,@Status,@CreatorID,@CreateTime,@ResponsiblePersonID);select @@IDENTITY";
                        int opportunityId = db.SetCommand(strSqlinsertOpportunity, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                                                                db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                                                                db.Parameter("@ProductType", item.ProductType, DbType.Int32),
                                                                                db.Parameter("@ProductCode", item.ProductCode, DbType.Int64),
                                                                                db.Parameter("@StepID", item.StepID, DbType.Int32),
                                                                                db.Parameter("@Status", model.Status, DbType.Int32),
                                                                                db.Parameter("@CreatorID", model.AccountID, DbType.Int32),
                                                                                db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                                                                                db.Parameter("@ResponsiblePersonID", item.ResponsiblePersonID, DbType.Int32)).ExecuteScalar<int>();
                        if (opportunityId <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        string strSqlProgressAdd = @"insert into PROGRESS(CompanyID,OpportunityID,Quantity,TotalOrigPrice,TotalCalcPrice,TotalSalePrice,Progress,CreatorID,CreateTime,Available)
                                                                values (@CompanyID,@OpportunityID,@Quantity,@TotalOrigPrice,@TotalCalcPrice,@TotalSalePrice,@Progress,@CreatorID,@CreateTime,@Available)";

                        int progressAddres = db.SetCommand(strSqlProgressAdd, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                                              db.Parameter("@OpportunityID", opportunityId, DbType.Int32),
                                                                              db.Parameter("@Quantity", item.Quantity, DbType.Int32),
                                                                              db.Parameter("@TotalOrigPrice", item.TotalOrigPrice, DbType.Decimal),
                                                                              db.Parameter("@TotalCalcPrice", item.TotalCalcPrice, DbType.Decimal),
                                                                              db.Parameter("@TotalSalePrice", item.TotalSalePrice, DbType.Decimal),
                                                                              db.Parameter("@Progress", model.Progress, DbType.Int32),
                                                                              db.Parameter("@CreatorID", model.AccountID, DbType.Int32),
                                                                              db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                                                                              db.Parameter("@Available", model.Available, DbType.Boolean)).ExecuteNonQuery();

                        if (progressAddres <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }
                    db.CommitTransaction();
                    return true;
                }
                catch (Exception ex)
                {
                    db.CommitTransaction();
                    throw;
                }
            }
        }

        public bool deleteOpportunity(int AccountID, int OpportunityID)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    string strSqlAddHis = @"Insert into [HISTORY_OPPORTUNITY] select * from [OPPORTUNITY] where ID=@ID;";
                    int addHisRes = db.SetCommand(strSqlAddHis, db.Parameter("@ID", OpportunityID, DbType.Int32)).ExecuteNonQuery();

                    if (addHisRes <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSql = @"update OPPORTUNITY set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID=@ID ";

                    int res = db.SetCommand(strSql, db.Parameter("@Status", 2, DbType.Int32),
                                                    db.Parameter("@UpdaterID", AccountID, DbType.Int32),
                                                    db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                                                    db.Parameter("@ID", OpportunityID, DbType.Int32)).ExecuteNonQuery();
                    if (res <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                    db.CommitTransaction();
                    return true;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

        }

        public List<ProgressList_Model> getProgressHistory(int opportunityId)
        {
            List<ProgressList_Model> list = new List<ProgressList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.ID AS ProgressHistoryID ,T1.Progress ,T3.StepContent ,T1.Description ,CONVERT(VARCHAR(16), T1.CreateTime, 20) CreateTime
                                      FROM    PROGRESS T1
                                              LEFT JOIN OPPORTUNITY T2 ON T1.OpportunityID = T2.ID
                                              LEFT JOIN STEP T3 ON T2.StepID = T3.ID
                                      WHERE   T2.ID = @OpportunityID
                                              AND T1.Available = 1
                                      ORDER BY T1.CreateTime DESC";

                list = db.SetCommand(strSql, db.Parameter("@OpportunityID", opportunityId, DbType.Int32)).ExecuteList<ProgressList_Model>();
            }
            return list;
        }

        public ProgressDetail_Model getProgressDetail(int progressId, int productType)
        {
            ProgressDetail_Model model = new ProgressDetail_Model();
            string strSql = "";
            using (DbManager db = new DbManager())
            {
                if (productType == 0)
                {
                    strSql = @"select top 1 T1.ID AS ProgressID,T4.ID AS ProductID,T4.Code AS ProductCode,T2.ProductType,T4.ServiceName AS ProductName, T1.Quantity, T1.TotalSalePrice,T1.TotalOrigPrice, T1.TotalCalcPrice, CONVERT(varchar(16),T2.CreateTime,20) AS CreateTime , T1.Progress, T3.StepContent,
                                     T2.CustomerID, T1.Description
                                     from PROGRESS T1
                                     left join OPPORTUNITY T2 ON T2.ID = T1.OpportunityID
                                     left join STEP T3 ON T3.ID = T2.StepID
                                     LEFT JOIN ( SELECT  * FROM [Service] WHERE   ID IN ( SELECT  MAX(ID) ProgressID FROM [Service] GROUP BY Code )) T4 ON T2.ProductCode = T4.Code
                                     where T1.ID = @ProgressID and T1.Available= 1 and T2.ProductType =@ProductType order by T1.ID desc";
                }
                else
                {
                    strSql = @"select top 1 T1.ID AS ProgressID,T4.ID AS ProductID,T4.Code AS ProductCode,T2.ProductType,T4.CommodityName + ' ' + T4.Specification AS ProductName, T1.Quantity, T1.TotalSalePrice,T1.TotalOrigPrice, T1.TotalCalcPrice, CONVERT(varchar(16),T2.CreateTime,20) AS CreateTime , T1.Progress, T3.StepContent,
                                     T2.CustomerID, T1.Description
                                     from PROGRESS T1
                                     LEFT JOIN OPPORTUNITY T2 ON T2.ID = T1.OpportunityID
                                     LEFT JOIN STEP T3 ON T3.ID = T2.StepID
                                     LEFT JOIN ( SELECT * FROM [COMMODITY] WHERE ID IN ( SELECT  MAX(ID) FROM [COMMODITY] GROUP BY Code )) T4 ON T2.ProductCode = T4.Code
                                     where T1.ID = @ProgressID and T1.Available= 1 and T2.ProductType =@ProductType order by T1.ID desc";
                }

                model = db.SetCommand(strSql, db.Parameter("@ProgressID", progressId, DbType.Int32),
                                              db.Parameter("@ProductType", productType, DbType.Int32)).ExecuteObject<ProgressDetail_Model>();
            }
            return model;
        }

        public bool addProgress(ProgressOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    decimal dicount = 0;
                    #region 计算价格,获取proID
                    Commodity_Model com_model = new Commodity_Model();
                    if (model.ProductType == 1)
                    {
                        string strSqlSelectProId = @"SELECT T1.ID,T1.MarketingPolicy,T1.UnitPrice,T1.PromotionPrice
                                                    FROM [COMMODITY] T1
                                                    INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 ON T1.Code=T2.Code AND T2.Type=1 AND T2.Available=1 AND T2.BranchID=@BranchID
                                                    WHERE T1.CompanyID=@CompanyID
                                                    AND T1.Code=@Code
                                                    AND T1.Available=1
                                                    ORDER BY T1.CreateTime DESC";
                        com_model = db.SetCommand(strSqlSelectProId,
                                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@Code", model.ProductCode, DbType.Int64)
                                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<Commodity_Model>();
                    }
                    else
                    {
                        string strSqlSelectProId = @"SELECT  T1.ID ,
                                                            T1.MarketingPolicy ,
                                                            T1.UnitPrice ,
                                                            T1.PromotionPrice
                                                    FROM    [SERVICE] T1
                                                    INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 ON T1.Code=T2.Code AND T2.Type=0 AND T2.Available=1 AND T2.BranchID=@BranchID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.Code = @Code
                                                            AND T1.Available = 1
                                                    ORDER BY T1.CreateTime DESC";
                        com_model = db.SetCommand(strSqlSelectProId,
                                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@Code", model.ProductCode, DbType.Int64)
                                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<Commodity_Model>();
                    }
                    if (com_model == null)
                    {
                        return false;
                    }

                    model.ProductID = com_model.ID;
                    model.TotalOrigPrice = Math.Round(com_model.UnitPrice * (decimal)model.Quantity, 2);

                    #region 计算价格
                    //按等级折扣
                    if (com_model.MarketingPolicy == 1)
                    {
                        if (dicount <= 0)
                        {
                            //查询等级折扣
                            string strSelectDiscount = @"SELECT Discount FROM  [CUSTOMER] T1 WITH(NOLOCK)
                                                                     LEFT JOIN [LEVEL] T2 WITH(NOLOCK) ON T1.LevelID=T2.ID AND T2.Available=1
                                                                     WHERE T1.CompanyID=@CompanyID AND T1.UserID=@UserID AND T1.Available=1";
                            dicount = db.SetCommand(strSelectDiscount,
                                           db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                           db.Parameter("@UserID", model.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();
                        }

                        if (dicount > 0)
                        {
                            model.TotalCalcPrice = Math.Round(com_model.UnitPrice * dicount * (decimal)model.Quantity, 2);
                        }
                    }
                    //促销价销售
                    else if (com_model.MarketingPolicy == 2)
                    {
                        model.TotalCalcPrice = Math.Round(com_model.PromotionPrice * (decimal)model.Quantity, 2);
                    }
                    //原价销售
                    else
                    {
                        model.TotalCalcPrice = Math.Round(com_model.UnitPrice * (decimal)model.Quantity, 2);
                    }

                    //实际售价赋值
                    if (model.TotalSalePrice < 0)
                    {
                        model.TotalSalePrice = model.TotalCalcPrice;
                    }
                    #endregion

                    #endregion

                    string strSql = @"insert into PROGRESS(CompanyID,OpportunityID,Progress,Quantity,TotalOrigPrice,TotalCalcPrice,TotalSalePrice,Description,CreatorID,CreateTime,Available)
                                      values (@CompanyID,@OpportunityID,@Progress,@Quantity,@TotalOrigPrice,@TotalCalcPrice,@TotalSalePrice,@Description,@CreatorID,@CreateTime,@Available)";

                    int res = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                    db.Parameter("@OpportunityID", model.OpportunityID, DbType.Int32),
                                                    db.Parameter("@Progress", model.Progress, DbType.Int32),
                                                    db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                                                    db.Parameter("@TotalOrigPrice", model.TotalOrigPrice, DbType.Decimal),
                                                    db.Parameter("@TotalCalcPrice", model.TotalCalcPrice, DbType.Decimal),
                                                    db.Parameter("@TotalSalePrice", model.TotalSalePrice, DbType.Decimal),
                                                    db.Parameter("@Description", model.Description, DbType.String),
                                                    db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                    db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime),
                                                    db.Parameter("@Available", true, DbType.Boolean)).ExecuteNonQuery();

                    if (res <= 0)
                    {
                        return false;
                    }
                }
                catch(Exception ex)
                {
                    throw;
                }
                return true;
            }
        }

        public bool updateProgress(ProgressOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlSelectCode = @"SELECT T2.ProductCode,T2.ProductType,T2.CompanyID FROM [PROGRESS] T1 LEFT JOIN [OPPORTUNITY] T2 ON T1.OpportunityID=T2.ID WHERE T1.ID=@ID";
                ProgressOperation_Model proCodeModel = db.SetCommand(strSqlSelectCode, db.Parameter("@ID", model.ProgressID, DbType.Int32)).ExecuteObject<ProgressOperation_Model>();

                if (proCodeModel == null || proCodeModel.ProductCode <= 0)
                {
                    return false;
                }

                decimal dicount = 0;

                #region 计算价格,获取proID
                Commodity_Model com_model = new Commodity_Model();
                if (proCodeModel.ProductType == 1)
                {
                    string strSqlSelectProId = @"SELECT ID,MarketingPolicy,UnitPrice,PromotionPrice FROM [COMMODITY] WHERE CompanyID=@CompanyID AND Code=@Code AND Available=1 ORDER BY CreateTime DESC";
                    com_model = db.SetCommand(strSqlSelectProId,
                                                db.Parameter("@CompanyID", proCodeModel.CompanyID, DbType.Int32),
                                                db.Parameter("@Code", proCodeModel.ProductCode, DbType.Int64)).ExecuteObject<Commodity_Model>();
                }
                else
                {
                    string strSqlSelectProId = @"SELECT ID,MarketingPolicy,UnitPrice,PromotionPrice FROM [SERVICE] WHERE CompanyID=@CompanyID AND Code=@Code AND Available=1 ORDER BY CreateTime DESC";
                    com_model = db.SetCommand(strSqlSelectProId,
                                                db.Parameter("@CompanyID", proCodeModel.CompanyID, DbType.Int32),
                                                db.Parameter("@Code", proCodeModel.ProductCode, DbType.Int64)).ExecuteObject<Commodity_Model>();
                }
                if (com_model == null)
                {
                    return false;
                }

                proCodeModel.ProductID = com_model.ID;
                proCodeModel.TotalOrigPrice = Math.Round(com_model.UnitPrice * (decimal)model.Quantity, 2);

                #region 计算价格
                //按等级折扣
                if (com_model.MarketingPolicy == 1)
                {
                    if (dicount <= 0)
                    {
                        //查询等级折扣
                        string strSelectDiscount = @"SELECT ISNULL(Discount,1.00) Discount FROM  [CUSTOMER] T1 WITH(NOLOCK)
                                                                     LEFT JOIN [LEVEL] T2 WITH(NOLOCK) ON T1.LevelID=T2.ID AND T2.Available=1
                                                                     WHERE T1.CompanyID=@CompanyID AND T1.UserID=@UserID AND T1.Available=1";
                        dicount = db.SetCommand(strSelectDiscount,
                                       db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                       db.Parameter("@UserID", model.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();
                    }

                    if (dicount > 0)
                    {
                        proCodeModel.TotalCalcPrice = Math.Round(com_model.UnitPrice * dicount * (decimal)model.Quantity, 2);
                    }
                    else
                    {
                        proCodeModel.TotalCalcPrice = Math.Round(com_model.UnitPrice * (decimal)model.Quantity, 2);
                    }
                }
                //促销价销售
                else if (com_model.MarketingPolicy == 2)
                {
                    proCodeModel.TotalCalcPrice = Math.Round(com_model.PromotionPrice * (decimal)model.Quantity, 2);
                }
                //原价销售
                else
                {
                    proCodeModel.TotalCalcPrice = Math.Round(com_model.UnitPrice * (decimal)model.Quantity, 2);
                }

                //实际售价赋值
                if (model.TotalSalePrice < 0)
                {
                    proCodeModel.TotalSalePrice = proCodeModel.TotalCalcPrice;
                }
                else
                {
                    proCodeModel.TotalSalePrice = model.TotalSalePrice;
                }
                #endregion

                #endregion

                string strSql = @"update PROGRESS set Quantity=@Quantity,TotalOrigPrice=@TotalOrigPrice,TotalCalcPrice=@TotalCalcPrice,TotalSalePrice=@TotalSalePrice,Description=@Description,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID=@ID";
                int res = db.SetCommand(strSql, db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                                                db.Parameter("@TotalOrigPrice", proCodeModel.TotalOrigPrice, DbType.Decimal),
                                                db.Parameter("@TotalCalcPrice", proCodeModel.TotalCalcPrice, DbType.Decimal),
                                                db.Parameter("@TotalSalePrice", proCodeModel.TotalSalePrice, DbType.Decimal),
                                                db.Parameter("@Description", model.Description, DbType.String),
                                                db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                                                db.Parameter("@UpdateTime", model.Updatetime, DbType.DateTime),
                                                db.Parameter("@ID", model.ProgressID, DbType.Int32)).ExecuteNonQuery();
                if (res <= 0)
                {
                    return false;
                }
                return true;
            }
        }

        public int getStepNumber(int opportunityId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.StepNumber from STEP T1
                                       LEFT JOIN OPPORTUNITY T2 ON T1.ID = T2.StepID
                                       WHERE T2.ID =@ID ";

                int maxID = db.SetCommand(strSql, db.Parameter("@ID", opportunityId, DbType.Int32)).ExecuteScalar<int>();
                return maxID;
            }
        }

        public List<GetStepList_Model> GetStepListByCompanyID(int companyID)
        {
            List<GetStepList_Model> list = new List<GetStepList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT StepName,ID AS StepID FROM dbo.STEP WHERE id IN(
                                   SELECT MAX(ID) FROM dbo.STEP WHERE CompanyID=@CompanyID GROUP BY stepCode) ";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetStepList_Model>();
                return list;
            }
        }
    }
}
