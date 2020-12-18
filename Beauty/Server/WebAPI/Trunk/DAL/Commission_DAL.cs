using BLToolkit.Data;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;

namespace WebAPI.DAL
{
    public class Commission_DAL
    {
        #region 构造类实例
        public static Commission_DAL Instance
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
            internal static readonly Commission_DAL instance = new Commission_DAL();
        }
        #endregion


        public List<Commission_Account_Model> GetAccountList(int companyID, string strInput)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @"  select T1.UserID AS AccountID, T1.Name as AccountName,T2.CommPattern AS CommPatternSales,T3.CommPattern As CommPatternOperate , {0}
                                     from [ACCOUNT] T1 WITH (NOLOCK) 
                                    LEFT JOIN (select distinct T4.CompanyID,T4.AccountID,T4.CommPattern from [TBL_ACCOUNT_COMMISSION_RULE] T4 WITH (NOLOCK) WHERE T4.CommType = 1) T2   ON T1.UserID = T2.AccountID AND T1.CompanyID = T2.CompanyID 
                                    LEFT JOIN (select distinct T5.CompanyID,T5.AccountID,T5.CommPattern from [TBL_ACCOUNT_COMMISSION_RULE] T5 WITH (NOLOCK) WHERE T5.CommType = 2) T3 ON T1.UserID = T3.AccountID AND T1.CompanyID = T3.CompanyID
                                     Where T1.CompanyID=@CompanyID and T1.Available =1 ";

                if (strInput != "")
                {
                    strSql += " AND '|' + ISNULL(T1.Name,'') +'|' + ISNULL(T1.Mobile,'') +'|' + ISNULL(T1.Code,'') + '|' LIKE '%" + strInput + "%'";
                }
                string strSqlFin = string.Format(strSql, Const.getAccountImgForManagerList);
                List<Commission_Account_Model> list = db.SetCommand(strSqlFin, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<Commission_Account_Model>();

                return list;
            }
        }

        public Commission_Account_Model GetAccountDetail(int companyID, int accountID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.UserID AS AccountID, T1.Name as AccountName,ISNULL(T2.BaseSalary,-1) BaseSalary from [ACCOUNT] T1 WITH (NOLOCK) 
                                    LEFT JOIN   [TBL_ACCOUNT_COMMISSION_RULE] T2 WITH (NOLOCK) ON T1.UserID = T2.AccountID AND T1.CompanyID = T2.CompanyID 
                                    Where T1.CompanyID=@CompanyID and T1.UserID=@AccountID ";
                Commission_Account_Model model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@AccountID", accountID, DbType.Int32)).ExecuteObject<Commission_Account_Model>();

                if (model != null && model.BaseSalary >= 0)
                {
                    string strSqlSales = @" select  T1.CommPattern,T1.ProfitRangeUnit,T1.ProfitMinRange,T1.ProfitMaxRange,T1.ProfitPct from [TBL_ACCOUNT_COMMISSION_RULE] T1 WITH (NOLOCK) where T1.CompanyID = @CompanyID AND T1.AccountID =@AccountID AND T1.CommType = 1 ";
                    model.ListCommSales = db.SetCommand(strSqlSales, db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@AccountID", accountID, DbType.Int32)).ExecuteList<CommissionDetail_Account>();

                    string strSqlOperate = @" select  T1.CommPattern,T1.ProfitRangeUnit,T1.ProfitMinRange,T1.ProfitMaxRange,T1.ProfitPct from [TBL_ACCOUNT_COMMISSION_RULE] T1 WITH (NOLOCK) where T1.CompanyID = @CompanyID AND T1.AccountID =@AccountID AND T1.CommType = 2 ";
                    model.ListCommOperate = db.SetCommand(strSqlOperate, db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@AccountID", accountID, DbType.Int32)).ExecuteList<CommissionDetail_Account>();

                    string strSqlRecharge = @" select  T1.CommPattern,T1.ProfitRangeUnit,T1.ProfitMinRange,T1.ProfitMaxRange,T1.ProfitPct from [TBL_ACCOUNT_COMMISSION_RULE] T1 WITH (NOLOCK) where T1.CompanyID = @CompanyID AND T1.AccountID =@AccountID AND T1.CommType = 3 ";
                    model.ListCommRecharge = db.SetCommand(strSqlRecharge, db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@AccountID", accountID, DbType.Int32)).ExecuteList<CommissionDetail_Account>();

                }
                else
                {
                    CommissionDetail_Account mCA = new CommissionDetail_Account();
                    model.ListCommSales = new List<CommissionDetail_Account>();
                    model.ListCommSales.Add(mCA);
                   // model.ListCommSales.Add(mCA);
                    model.ListCommOperate = new List<CommissionDetail_Account>();
                    model.ListCommOperate.Add(mCA);
                  //  model.ListCommOperate.Add(mCA);
                    model.ListCommRecharge = new List<CommissionDetail_Account>();
                    model.ListCommRecharge.Add(mCA);
                   // model.ListCommRecharge.Add(mCA);
                }


                return model;
            }
        }

        public bool EditAccount(Commission_Account_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCheck = @" select Count(0) from TBL_ACCOUNT_COMMISSION_RULE WITH (NOLOCK) WHERE CompanyID=@CompanyID AND AccountID =@AccountID  ";
                int checkRows = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteScalar<int>();

                string strSqlDelete = @" delete TBL_ACCOUNT_COMMISSION_RULE  WHERE CompanyID=@CompanyID AND AccountID =@AccountID ";
                int rows = db.SetCommand(strSqlDelete, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteNonQuery();

                if (checkRows != rows)
                {
                    db.RollbackTransaction();
                    return false;
                }

                if (model.ListComm != null && model.ListComm.Count >= 0)
                {
                    DateTime now = DateTime.Now.ToLocalTime();
                    string strSqlInsert = @" INSERT INTO [TBL_ACCOUNT_COMMISSION_RULE]
                                            (AccountID,BaseSalary,CommType,CommPattern,ProfitRangeUnit,ProfitMinRange,ProfitMaxRange,ProfitPct,CompanyID,CreatorID,CreateTime,RecordType)
                                             VALUES
                                            (@AccountID,@BaseSalary,@CommType,@CommPattern,@ProfitRangeUnit,@ProfitMinRange,@ProfitMaxRange,@ProfitPct,@CompanyID,@CreatorID,@CreateTime,1)";

                    foreach (CommissionDetail_Account item in model.ListComm)
                    {
                        rows = db.SetCommand(strSqlInsert
                                                , db.Parameter("@AccountID", model.AccountID, DbType.Int32)
                                                , db.Parameter("@BaseSalary", model.BaseSalary, DbType.Decimal)
                                                , db.Parameter("@CommType", item.CommType, DbType.Int32)
                                                , db.Parameter("@CommPattern", item.CommPattern, DbType.Int32)
                                                , db.Parameter("@ProfitRangeUnit", item.ProfitRangeUnit, DbType.Int32)
                                                , db.Parameter("@ProfitMinRange", item.ProfitMinRange == -1 ? (object)DBNull.Value : item.ProfitMinRange, DbType.Decimal)
                                                , db.Parameter("@ProfitMaxRange", item.ProfitMaxRange == -1 ? (object)DBNull.Value : item.ProfitMaxRange, DbType.Decimal)
                                                , db.Parameter("@ProfitPct", item.ProfitPct == -1 ? (object)DBNull.Value : item.ProfitPct / 100, DbType.Decimal)
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                , db.Parameter("@CreateTime", now, DbType.DateTime2)).ExecuteNonQuery();

                        if (rows != 1)
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




        public List<Service_Model> getServiceList(int companyId, int imageWidth, int imageHeight, string strInput)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT distinct T1.ID , T4.CategoryName,T1.ServiceName, T1.UnitPrice,T1.MarketingPolicy, ISNULL( T1.PromotionPrice,T1.UnitPrice) PromotionPrice,T1.VisibleForCustomer,T1.Describe,T1.Code ServiceCode,T1.Available,T1.CategoryID,[T5].[Sortid],ISNULL(T1.SubServiceCodes,'') AS SubServiceCodes, T1.Recommended,
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
                + @" ThumbnailUrl FROM Service T1 WITH(NOLOCK) 
                    LEFT JOIN  
                    IMAGE_SERVICE T3 WITH(NOLOCK) 
                    ON T1.ID = T3.ServiceID  
                    AND T3.ImageType = 0  
                    LEFT JOIN  
                    CATEGORY T4  WITH(NOLOCK) 
                    ON T1.CategoryID = T4.ID  
                    LEFT JOIN  
                    [TBL_SERVICESORT] T5  WITH(NOLOCK) 
                    ON [T1].[CODE] = [T5].[SERVICECODE]  
                    WHERE T1.Available = 1  and T1.CompanyID =@CompanyID";
                if (strInput != "")
                {
                    strSql += " AND  ISNULL(T1.ServiceName,'')  LIKE '%" + strInput + "%'";
                }

                strSql += " Order by T1.Recommended, [T5].[Sortid] ";

                List<Service_Model> list = db.SetCommand(strSql.ToString(),
                                                          db.Parameter("@CompanyID", companyId, DbType.Int32),
                                                          db.Parameter("@ImageHeight", imageHeight.ToString()),
                                                          db.Parameter("@ImageWidth", imageWidth.ToString())).ExecuteList<Service_Model>();

                return list;
            }
        }

        public Commission_Product_Model GetServiceDetail(int CompanyID, long ServiceCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select  T1.ServiceName AS ProductName,T1.Code AS ProductCode,T1.UnitPrice,ISNULL(T2.ProfitPct,-1) AS ProfitPct, ISNULL(T2.ECardSACommType,1) ECardSACommType,ISNULL(T2.ECardSACommValue,-1) ECardSACommValue,ISNULL(T2.NECardSACommType,1) NECardSACommType,ISNULL(T2.NECardSACommValue,-1) NECardSACommValue,ISNULL(T3.ID,0) as COperateID,CASE WHEN ISNULL(T1.SubServiceCodes,'') = ''  THEN 0 ELSE  1 END AS HaveSubService ,
                                ISNULL(T3.DesOPCommType,1) DesOPCommType,ISNULL(T3.DesOPCommValue,-1) DesOPCommValue,ISNULL(T3.OPCommType,1) OPCommType,ISNULL(T3.OPCommValue,-1) OPCommValue,T1.SubServiceCodes
                                from [SERVICE] T1 WITH (NOLOCK) 
                                LEFT JOIN [TBL_PRODUCT_COMMISSION_RULE] T2 WITH (NOLOCK) 
                                ON T1.Code = T2.ProductCode and T2.ProductType = 0
                                LEFT JOIN [TBL_OPERATE_COMMISSION_RULE] T3 WITH (NOLOCK) 
                                ON T1.Code = T3.ServiceCode
                                where T1.CompanyID=@CompanyID AND T1.Code=@ProductCode AND T1.Available = 1 ";

                Commission_Product_Model model = db.SetCommand(strSql
                                                , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                , db.Parameter("@ProductCode", ServiceCode, DbType.Int64)).ExecuteObject<Commission_Product_Model>();

                if (model.HaveSubService)
                {

                    if (string.IsNullOrWhiteSpace(model.SubServiceCodes))
                    {
                        return null;
                    }

                    string[] codes = model.SubServiceCodes.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                    string strWhere = "";
                    if (codes != null && codes.Length > 0)
                    {
                        foreach (string item in codes)
                        {
                            if (strWhere != "")
                            {
                                strWhere += " , ";
                            }
                            strWhere += item;
                        }
                    }

                    if (strWhere == "")
                    {
                        return null;
                    }
                    else
                    {
                        strWhere = " ( " + strWhere + " ) ";
                    }

                    string strSqlSub = @" select T1.SubServiceName,T1.SubServiceCode
                                            ,ISNULL(T2.DesSubServiceProfitPct,-1) DesSubServiceProfitPct
                                            ,ISNULL(T2.DesSubOPCommType,1) DesSubOPCommType
                                            ,ISNULL(T2.DesSubOPCommValue,-1) DesSubOPCommValue
                                            ,ISNULL(T2.SubServiceProfitPct,-1) SubServiceProfitPct
                                            ,ISNULL(T2.SubOPCommType,1) SubOPCommType
                                            ,ISNULL(T2.SubOPCommValue,-1) SubOPCommValue
                                             from [TBL_SUBSERVICE] T1 WITH (NOLOCK) LEFT JOIN[TBL_SUBSERVICE_COMMISSION_RULE] T2 WITH (NOLOCK)   ON T2.SubServiceCode = T1.SubServiceCode and T2.ServiceCode = @ServiceCode WHERE  T1.CompanyID=@CompanyID and T1.SubServiceCode IN " + strWhere;

                    model.listSubService = new List<Commission_SubService_Model>();
                    model.listSubService = db.SetCommand(strSqlSub
                                                , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                , db.Parameter("@ServiceCode", ServiceCode, DbType.Int64)).ExecuteList<Commission_SubService_Model>();


                }
                return model;
            }
        }

        public List<Commodity_Model> getCommodityList(int companyId, int imageWidth, int imageHeight, string strInput)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT distinct T1.ID , T1.New, T1.Recommended, T4.CategoryName,T1.CommodityName,T1.Specification, T1.UnitPrice,T1.MarketingPolicy, ISNULL( T1.PromotionPrice,T1.UnitPrice) PromotionPrice,T1.VisibleForCustomer,T1.Describe,T1.Code CommodityCode,T1.Available,T1.CategoryID,[T5].[Sortid], 
                                ( SELECT DiscountName FROM dbo.TBL_DISCOUNT WHERE ID = T1.DiscountID AND available = 1 ) DiscountName ,"
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
                + @" ThumbnailUrl FROM COMMODITY T1 WITH(NOLOCK)
                                LEFT JOIN  
                                 IMAGE_COMMODITY T3 WITH(NOLOCK) 
                                 ON T1.ID = T3.CommodityID  
                                 AND T3.ImageType = 0  
                                 LEFT JOIN  
                                 CATEGORY T4  WITH(NOLOCK) 
                                 ON T1.CategoryID = T4.ID  
                                 LEFT JOIN  
                                 [TBL_COMMODITYSORT] T5  WITH(NOLOCK) 
                                 ON [T1].[CODE] = [T5].[COMMODITYCODE]  
                                 WHERE T1.Available = 1  and T1.CompanyID =@CompanyID";

                if (strInput != "")
                {
                    strSql += " AND  ISNULL(T1.CommodityName,'')  LIKE '%" + strInput + "%'";
                }
                strSql += @" AND T1.Available = 1  Order by [T5].[Sortid] ";

                List<Commodity_Model> list = db.SetCommand(strSql.ToString(),
                                                          db.Parameter("@CompanyID", companyId, DbType.Int32),
                                                          db.Parameter("@ImageHeight", imageHeight.ToString()),
                                                          db.Parameter("@ImageWidth", imageWidth.ToString())).ExecuteList<Commodity_Model>();

                return list;
            }
        }

        public Commission_Product_Model GetCommodityDetail(int CompanyID, long CommodityCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select  T1.CommodityName AS ProductName,T1.Code AS ProductCode,T1.UnitPrice,ISNULL(T2.ID,0) AS CProductID,ISNULL(T2.ProfitPct,-1) ProfitPct, ISNULL(T2.ECardSACommType,1) ECardSACommType,ISNULL(T2.ECardSACommValue,-1) ECardSACommValue,ISNULL(T2.NECardSACommType,1) NECardSACommType,ISNULL(T2.NECardSACommValue,-1) NECardSACommValue
                                    from [COMMODITY] T1 WITH (NOLOCK) 
                                    LEFT JOIN [TBL_PRODUCT_COMMISSION_RULE] T2 WITH (NOLOCK) 
                                    ON T1.Code = T2.ProductCode and T2.ProductType = 1
                                where T1.CompanyID=@CompanyID AND T1.Code=@ProductCode AND T1.Available = 1 ";

                Commission_Product_Model model = db.SetCommand(strSql
                                                , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                , db.Parameter("@ProductCode", CommodityCode, DbType.Int64)).ExecuteObject<Commission_Product_Model>();

                return model;
            }
        }

        public bool EditProduct(Commission_Product_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlCheck = @" select ISNULL(ID,0) from  [TBL_PRODUCT_COMMISSION_RULE]
                                  WHERE ProductCode = @ProductCode
                                  AND CompanyID = @CompanyID
                                  AND ProductType =@ProductType ";

                int ID = db.SetCommand(strSqlCheck
                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                   , db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                   , db.Parameter("@ProductType", model.ProductType, DbType.Int32)).ExecuteScalar<int>();


                if (ID == 0)
                {
                    string strSql = @" INSERT INTO [TBL_PRODUCT_COMMISSION_RULE]           
                                    (ProductType,ProductCode,ProfitPct,ECardSACommType,ECardSACommValue,NECardSACommType,NECardSACommValue,CompanyID,CreatorID,CreateTime,RecordType)
                                    VALUES
                                    (@ProductType,@ProductCode,@ProfitPct,@ECardSACommType,@ECardSACommValue,@NECardSACommType,@NECardSACommValue,@CompanyID,@CreatorID,@CreateTime,1) ";

                    int rows = db.SetCommand(strSql
                                , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                                , db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                                , db.Parameter("@ProfitPct", model.ProfitPct / 100, DbType.Decimal)
                                , db.Parameter("@ECardSACommType", model.ECardSACommType, DbType.Int32)
                                , db.Parameter("@ECardSACommValue", model.ECardSACommType == 1 ? model.ECardSACommValue / 100 : model.ECardSACommValue, DbType.Decimal)
                                , db.Parameter("@NECardSACommType", model.NECardSACommType, DbType.Int32)
                                , db.Parameter("@NECardSACommValue", model.NECardSACommType == 1 ? model.NECardSACommValue / 100 : model.NECardSACommValue, DbType.Decimal)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                    if (rows != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                else
                {
                    string strSql = @" UPDATE [TBL_PRODUCT_COMMISSION_RULE]
                                  SET ProfitPct = @ProfitPct
                                  ,ECardSACommType = @ECardSACommType
                                  ,ECardSACommValue = @ECardSACommValue
                                  ,NECardSACommType = @NECardSACommType
                                  ,NECardSACommValue = @NECardSACommValue
                                  ,UpdaterID = @UpdaterID
                                  ,UpdateTime = @UpdateTime
                                  WHERE ProductCode = @ProductCode
                                  AND CompanyID = @CompanyID
                                  AND ID = @ID ";
                    int rows = db.SetCommand(strSql
                             , db.Parameter("@ProfitPct", model.ProfitPct / 100, DbType.Decimal)
                             , db.Parameter("@ECardSACommType", model.ECardSACommType, DbType.Int32)
                             , db.Parameter("@ECardSACommValue", model.ECardSACommType == 1 ? model.ECardSACommValue / 100 : model.ECardSACommValue, DbType.Decimal)
                             , db.Parameter("@NECardSACommType", model.NECardSACommType, DbType.Int32)
                             , db.Parameter("@NECardSACommValue", model.NECardSACommType == 1 ? model.NECardSACommValue / 100 : model.NECardSACommValue, DbType.Decimal)
                             , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                             , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                             , db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                             , db.Parameter("@ID", ID, DbType.Int32)
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                if (model.ProductType == 0)
                {
                    string strSqlCheckOp = @" select ISNULL(ID,0) from TBL_OPERATE_COMMISSION_RULE where CompanyID=@CompanyID and ServiceCode =@ProductCode ";


                    int opId = db.SetCommand(strSqlCheckOp
                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                       , db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)).ExecuteScalar<int>();

                    if (opId == 0)
                    {
                        string strSql = @" INSERT INTO [TBL_OPERATE_COMMISSION_RULE]
                                        (ServiceCode,ProfitPct,HaveSubService,DesOPCommType,DesOPCommValue,OPCommType,OPCommValue,CompanyID,CreatorID,CreateTime,RecordType)
                                             VALUES
                                        (@ServiceCode,@ProfitPct,@HaveSubService,@DesOPCommType,@DesOPCommValue,@OPCommType,@OPCommValue,@CompanyID,@CreatorID,@CreateTime,1) ";

                        int rows = db.SetCommand(strSql
                                , db.Parameter("@ServiceCode", model.ProductCode, DbType.Int64)
                                , db.Parameter("@ProfitPct", model.ProfitPct / 100, DbType.Decimal)
                                , db.Parameter("@HaveSubService", model.HaveSubService, DbType.Boolean)
                                , db.Parameter("@DesOPCommType", !model.HaveSubService ? model.DesOPCommType : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@DesOPCommValue", !model.HaveSubService ? model.DesOPCommType == 1 ? model.DesOPCommValue / 100 : model.DesOPCommValue : (object)DBNull.Value, DbType.Decimal)
                                , db.Parameter("@OPCommType", !model.HaveSubService ? model.OPCommType : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@OPCommValue", !model.HaveSubService ? model.OPCommType == 1 ? model.OPCommValue / 100 : model.OPCommValue : (object)DBNull.Value, DbType.Decimal)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }
                    else
                    {
                        string strSql = @" UPDATE [TBL_OPERATE_COMMISSION_RULE]
                                           SET ProfitPct = @ProfitPct
                                              ,DesOPCommType = @DesOPCommType
                                              ,DesOPCommValue = @DesOPCommValue
                                              ,OPCommType = @OPCommType
                                              ,OPCommValue = @OPCommValue
                                              ,UpdaterID = @UpdaterID
                                              ,UpdateTime = @UpdateTime
                                         WHERE ServiceCode = @ServiceCode and CompanyID =@CompanyID and ID=@ID ";
                        int rows = db.SetCommand(strSql
                                , db.Parameter("@ProfitPct", model.ProfitPct / 100, DbType.Decimal)
                                , db.Parameter("@DesOPCommType", !model.HaveSubService ? model.DesOPCommType : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@DesOPCommValue", !model.HaveSubService ? model.DesOPCommType == 1 ? model.DesOPCommValue / 100 : model.DesOPCommValue : (object)DBNull.Value, DbType.Decimal)
                                , db.Parameter("@OPCommType", !model.HaveSubService ? model.OPCommType : (object)DBNull.Value, DbType.Int32)
                                , db.Parameter("@OPCommValue", !model.HaveSubService ? model.OPCommType == 1 ? model.OPCommValue / 100 : model.OPCommValue : (object)DBNull.Value, DbType.Decimal)
                                , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@ServiceCode", model.ProductCode, DbType.Int64)
                                , db.Parameter("@ID", opId, DbType.Int32)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }

                    if (model.HaveSubService && model.listSubService != null && model.listSubService.Count > 0)
                    {
                        string strSqlDelete = @" delete TBL_SUBSERVICE_COMMISSION_RULE where ServiceCode=@ServiceCode and CompanyID=@CompanyID ";

                        int rows = db.SetCommand(strSqlDelete
                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                       , db.Parameter("@ServiceCode", model.ProductCode, DbType.Int64)).ExecuteNonQuery();

                        string strSqlSub = @"INSERT INTO [TBL_SUBSERVICE_COMMISSION_RULE]
                                            (ServiceCode,SubServiceCode,DesSubServiceProfitPct,DesSubOPCommType,DesSubOPCommValue,SubServiceProfitPct,SubOPCommType,SubOPCommValue,CompanyID,CreatorID,CreateTime,RecordType)
                                             VALUES
                                            (@ServiceCode,@SubServiceCode,@DesSubServiceProfitPct,@DesSubOPCommType,@DesSubOPCommValue,@SubServiceProfitPct,@SubOPCommType,@SubOPCommValue,@CompanyID,@CreatorID,@CreateTime,1) ";
                        foreach (Commission_SubService_Model item in model.listSubService)
                        {

                            rows = db.SetCommand(strSqlSub
                               , db.Parameter("@ServiceCode", model.ProductCode, DbType.Int64)
                               , db.Parameter("@SubServiceCode", item.SubServiceCode, DbType.Int64)
                               , db.Parameter("@DesSubServiceProfitPct", item.DesSubServiceProfitPct / 100, DbType.Decimal)
                               , db.Parameter("@DesSubOPCommType", item.DesSubOPCommType, DbType.Int32)
                               , db.Parameter("@DesSubOPCommValue", item.DesSubOPCommType == 1 ? item.DesSubOPCommValue / 100 : item.DesSubOPCommValue, DbType.Decimal)
                               , db.Parameter("@SubServiceProfitPct", item.SubServiceProfitPct / 100, DbType.Decimal)
                               , db.Parameter("@SubOPCommType", item.SubOPCommType, DbType.Int32)
                               , db.Parameter("@SubOPCommValue", item.SubOPCommType == 1 ? item.SubOPCommValue / 100 : item.SubOPCommValue, DbType.Decimal)
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                               , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (rows != 1)
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

        public List<Commission_Card_Model> GetCardList(int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.CardCode,T1.CardName,ISNULL(T2.ID,0) AS ComECardID,ISNULL(T2.ProfitPct,-1) AS ProfitPct,
                                    ISNULL(T2.FstChargeCommType,1) AS FstChargeCommType ,ISNULL(T2.FstChargeCommValue, -1) AS FstChargeCommValue,ISNULL(T2.ChargeCommType,1) AS ChargeCommType,ISNULL(T2.ChargeCommValue, -1) AS ChargeCommValue from [MST_CARD] T1 WITH (NOLOCK)
                                    LEFT JOIN [TBL_ECARD_COMMISSION_RULE] T2 WITH (NOLOCK) ON T1.CardCode = T2.CardCode
                                    WHERE  T1.CompanyID =@CompanyID  and T1.CardTypeID = 1 ";

                List<Commission_Card_Model> list = db.SetCommand(strSql
                             , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteList<Commission_Card_Model>();

                return list;

            }
        }

        public Commission_Card_Model GetCardDetail(int CompanyID, long CardCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.CardCode,T1.CardName,ISNULL(T2.ID,0) AS ComECardID,ISNULL(T2.ProfitPct,-1) AS ProfitPct,
                                    ISNULL(T2.FstChargeCommType,1) AS FstChargeCommType ,ISNULL(T2.FstChargeCommValue, -1) AS FstChargeCommValue,ISNULL(T2.ChargeCommType,1) AS ChargeCommType,ISNULL(T2.ChargeCommValue, -1) AS ChargeCommValue from [MST_CARD] T1 WITH (NOLOCK)
                                    LEFT JOIN [TBL_ECARD_COMMISSION_RULE] T2 WITH (NOLOCK) ON T1.CardCode = T2.CardCode
                                    WHERE  T1.CompanyID =@CompanyID and T1.CardCode=@CardCode ";

                Commission_Card_Model model = db.SetCommand(strSql
                             , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                             , db.Parameter("@CardCode", CardCode, DbType.Int64)).ExecuteObject<Commission_Card_Model>();

                return model;

            }
        }

        public bool EditCard(Commission_Card_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlCheck = @" select ISNULL(T1.ID,0) from [TBL_ECARD_COMMISSION_RULE] T1 WHERE  T1.CompanyID =@CompanyID and T1.CardCode=@CardCode ";
                int ID = db.SetCommand(strSqlCheck
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@CardCode", model.CardCode, DbType.Int64)).ExecuteScalar<int>();

                if (ID == 0)
                {
                    string strSql = @" INSERT INTO [TBL_ECARD_COMMISSION_RULE]
                            (CardCode,ProfitPct,FstChargeCommType,FstChargeCommValue,ChargeCommType,ChargeCommValue,CompanyID,CreatorID,CreateTime,RecordType)
                                 VALUES
                            (@CardCode,@ProfitPct,@FstChargeCommType,@FstChargeCommValue,@ChargeCommType,@ChargeCommValue,@CompanyID,@CreatorID,@CreateTime,1) ";

                    int rows = db.SetCommand(strSql
                                , db.Parameter("@CardCode", model.CardCode, DbType.Int64)
                                , db.Parameter("@ProfitPct", model.ProfitPct / 100, DbType.Decimal)
                                , db.Parameter("@FstChargeCommType", model.FstChargeCommType, DbType.Int32)
                                , db.Parameter("@FstChargeCommValue", model.FstChargeCommType == 1 ? model.FstChargeCommValue / 100 : model.FstChargeCommValue, DbType.Decimal)
                                , db.Parameter("@ChargeCommType", model.ChargeCommType, DbType.Int32)
                                , db.Parameter("@ChargeCommValue", model.ChargeCommType == 1 ? model.ChargeCommValue / 100 : model.ChargeCommValue, DbType.Decimal)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                    if (rows != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                else
                {
                    string strSql = @" UPDATE [TBL_ECARD_COMMISSION_RULE]
                                    SET ProfitPct = @ProfitPct
                                      ,FstChargeCommType = @FstChargeCommType
                                      ,FstChargeCommValue = @FstChargeCommValue
                                      ,ChargeCommType = @ChargeCommType
                                      ,ChargeCommValue = @ChargeCommValue
                                      ,UpdaterID = @UpdaterID
                                      ,UpdateTime = @UpdateTime
                                    WHERE CardCode = @CardCode AND CompanyID = @CompanyID AND ID =@ID ";

                    int rows = db.SetCommand(strSql
                                , db.Parameter("@ProfitPct", model.ProfitPct / 100, DbType.Decimal)
                                , db.Parameter("@FstChargeCommType", model.FstChargeCommType, DbType.Int32)
                                , db.Parameter("@FstChargeCommValue", model.FstChargeCommType == 1 ? model.FstChargeCommValue / 100 : model.FstChargeCommValue, DbType.Decimal)
                                , db.Parameter("@ChargeCommType", model.ChargeCommType, DbType.Int32)
                                , db.Parameter("@ChargeCommValue", model.ChargeCommType == 1 ? model.ChargeCommValue / 100 : model.ChargeCommValue, DbType.Decimal)
                                , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                                , db.Parameter("@CardCode", model.CardCode, DbType.Int64)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery();

                    if (rows != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                db.CommitTransaction();
                return true;
            }
        }



    }
}
