using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;

namespace WebAPI.DAL
{
    public class Branch_DAL
    {
        #region 构造类实例
        public static Branch_DAL Instance
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
            internal static readonly Branch_DAL instance = new Branch_DAL();
        }
        #endregion

        public List<GetBranchList_Model> getBranchList(int companyID, int pageIndex, int pageSize, out int recordCount)
        {
            recordCount = 0;
            List<GetBranchList_Model> list = new List<GetBranchList_Model>();
            using (DbManager db = new DbManager())
            {
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.ID ) AS rowNum ,
                                                  T1.ID AS BranchID, T1.BranchName,T1.Phone,T1.Fax,T1.Address ";

                string strSql = " SELECT {0} FROM  [BRANCH] T1 WHERE T1.Available=1 AND T1.CompanyID=@CompanyID ";

                string strCountSql = string.Format(strSql, " count(0) ");
                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetBranchList_Model>();
                return list;
            }
        }

        public GetBranchDetail_Model getBranchDetail(int companyID, int branchID)
        {
            GetBranchDetail_Model model = new GetBranchDetail_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T1.ID AS BranchID ,T1.BranchName ,T1.Contact,T1.Phone ,T1.Fax ,T1.Address,T1.Zip,T1.Web,T1.BusinessHours,T1.Remark,T1.Longitude,T1.Latitude 
                                       FROM [BRANCH] T1 WHERE   T1.Available = 1 AND T1.CompanyID=@CompanyID AND T1.ID=@BranchID ";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteObject<GetBranchDetail_Model>();
                return model;
            }
        }

        public List<string> getBranchImgList(int companyID, int branchID, int hight, int width)
        {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                string strImg = string.Format(WebAPI.Common.Const.getBranchImg, hight, width);
                string strSql = " SELECT " + strImg + " FROM [IMAGE_BUSINESS] T1 WITH(NOLOCK) WHERE T1.Available=1 AND T1.CompanyID=@CompanyID AND T1.BranchID=@BranchID ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteScalarList<string>();
                return list;
            }
        }

        #region 后台方法
        public List<Branch_Model> getBranchListForWeb(int companyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  Select T1.ID, T1.BranchName, T1.Address, T1.Available from BRANCH T1 where T1.CompanyID = @CompanyID   order by T1.Available desc ";
                List<Branch_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<Branch_Model>();
                return list;
            }
        }

        public List<Branch_Model> getBranchAvailableList(int companyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  Select T1.ID, T1.BranchName, T1.Address, T1.Available from BRANCH T1 where T1.CompanyID = @CompanyID  AND T1.Available = 1  order by T1.Available desc ";
                List<Branch_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<Branch_Model>();
                return list;
            }
        }

        public int deleteBranch(int branchId, int accountId, bool Available,int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    if (Available)
                    {
                        string strSqlBranchCnt = "SELECT COUNT(0) FROM [BRANCH] WHERE CompanyID=@CompanyID AND Available = 1";
                        int BranchCount = db.SetCommand(strSqlBranchCnt, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteScalar<int>();

                        string strSqlBranchNumber = " select BranchNumber from COMPANY where id =@CompanyID ";
                        int MaxBranchNumber = db.SetCommand(strSqlBranchNumber, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteScalar<int>();

                        if (BranchCount >= MaxBranchNumber)
                        {
                            db.RollbackTransaction();
                            return -1;
                        }
                    }
                    string strSqlCopy = " INSERT INTO HISTORY_BRANCH SELECT * FROM BRANCH WHERE ID =@ID ";
                    int rows = db.SetCommand(strSqlCopy, db.Parameter("@ID", branchId, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlUpdate = @" update BRANCH set 
                                        Available=@Available,
                                        UpdaterID=@UpdaterID,
                                        UpdateTime=@UpdateTime
                                        where ID=@ID";

                    rows = db.SetCommand(strSqlUpdate, db.Parameter("@Available", Available, DbType.Boolean)
                        , db.Parameter("@UpdaterID", accountId, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        , db.Parameter("@ID", branchId, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }

                    db.CommitTransaction();
                    return 1;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

        }

        public Branch_Model getBranchDetailForWeb(int branchID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.ID,T1.BranchName, T1.Summary, T1.Contact, T1.Phone, T1.Fax, T1.Address, T1.Zip, T1.Web, T1.BusinessHours,T1.Remark,T1.Visible,T1.Longitude, T1.Latitude,case when T1.StartTime =@StartTime then null else CONVERT(varchar(16),T1.StartTime, 20) end StartTime ,T1.RemindTime,T1.IsShowECardHis,T1.IsConfirmed,T1.IsPay,T1.DefaultPassword,T1.BirthdayRemindTime,T1.IsPartPay,T1.IsUseRate,T1.DefaultConsultant,T1.LostRemind,T1.ExpiryRemind
                                from BRANCH T1
                                Where T1.ID =@BranchID ";
                Branch_Model model = db.SetCommand(strSql, db.Parameter("@BranchID", branchID, DbType.Int32)
                    , db.Parameter("@StartTime", Const.DefaultBranchStartTime, DbType.DateTime2)).ExecuteObject<Branch_Model>();
                //查询门店提成率
                string strSqlBranchRate = " SELECT Top 1 * FROM COMMISSION_RATE_BRANCH T2 where T2.BranchID = @BranchID AND T2.IssuedDate <=@IssuedDate ORDER BY T2.IssuedDate DESC ";
                Company_Model modelBranchRate = db.SetCommand(strSqlBranchRate,
                                           db.Parameter("@BranchID", branchID, DbType.Int32)
                                          , db.Parameter("@IssuedDate", DateTime.Now.ToString("yyyy-MM-dd"), DbType.String)).ExecuteObject<Company_Model>();
                if (modelBranchRate != null)
                {
                    model.IssuedDate = modelBranchRate.IssuedDate;
                    model.CommissionRate = modelBranchRate.CommissionRate*100;
                }
                return model;
            }

        }

        public int addBranch(Branch_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" insert into BRANCH(
                                CompanyID,BranchName,Summary,Contact,Phone,Fax,Web,Address,Zip,Longitude,Latitude,BusinessHours,Remark,Available,Visible,CreatorID,CreateTime,StartTime,RemindTime,IsShowECardHis,IsConfirmed,IsPay,DefaultPassword,BirthdayRemindTime,IsPartPay,IsUseRate,DefaultConsultant,LostRemind,ExpiryRemind)
                                 values (
                                @CompanyID,@BranchName,@Summary,@Contact,@Phone,@Fax,@Web,@Address,@Zip,@Longitude,@Latitude,@BusinessHours,@Remark,@Available,@Visible,@CreatorID,@CreateTime,@StartTime,@RemindTime,@IsShowECardHis,@IsConfirmed,@IsPay,@DefaultPassword,@BirthdayRemindTime,@IsPartPay,@IsUseRate,(select UserID from ACCOUNT where CompanyID =@CompanyID and RoleID = -1 and Available = 1),@LostRemind,@ExpiryRemind)
                                ;select @@IDENTITY ";

                int branchId = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchName", model.BranchName, DbType.String)
                    , db.Parameter("@Summary", model.Summary, DbType.String)
                    , db.Parameter("@Contact", model.Contact, DbType.String)
                    , db.Parameter("@Phone", model.Phone, DbType.String)
                    , db.Parameter("@Fax", model.Fax, DbType.String)
                    , db.Parameter("@Web", model.Web, DbType.String)
                    , db.Parameter("@Address", model.Address, DbType.String)
                    , db.Parameter("@Zip", model.Zip, DbType.Int32)
                    , db.Parameter("@Longitude", model.Longitude == 0 ? (object)DBNull.Value : model.Longitude, DbType.Decimal)
                    , db.Parameter("@Latitude", model.Latitude == 0 ? (object)DBNull.Value : model.Latitude, DbType.Decimal)
                    , db.Parameter("@BusinessHours", model.BusinessHours, DbType.String)
                    , db.Parameter("@Remark", model.Remark, DbType.String)
                    , db.Parameter("@Available", true, DbType.Boolean)
                    , db.Parameter("@Visible", model.Visible, DbType.Boolean)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                    , db.Parameter("@StartTime", model.StartTime == "" || model.StartTime == null ? Const.DefaultBranchStartTime.ToString() : model.StartTime, DbType.DateTime)
                    , db.Parameter("@RemindTime", StringUtils.GetDbDecimal(model.RemindTime), DbType.Decimal)
                    , db.Parameter("@IsShowECardHis", model.IsShowECardHis, DbType.Boolean)
                    , db.Parameter("@IsConfirmed", model.IsConfirmed, DbType.Boolean)
                    , db.Parameter("@IsPay", model.IsPay, DbType.Boolean)
                    , db.Parameter("@DefaultPassword", model.DefaultPassword == "" ? (object)DBNull.Value : model.DefaultPassword, DbType.String)
                    , db.Parameter("@BirthdayRemindTime", model.BirthdayRemindTime, DbType.Int32)
                    , db.Parameter("@IsPartPay", model.IsPartPay, DbType.Boolean)
                    , db.Parameter("@IsUseRate", model.IsUseRate, DbType.Int32)
                    , db.Parameter("@LostRemind", model.LostRemind == 0 ? (object)DBNull.Value : model.LostRemind, DbType.Int32)
                    , db.Parameter("@ExpiryRemind", model.ExpiryRemind == 0 ? (object)DBNull.Value : model.ExpiryRemind, DbType.Int32)).ExecuteScalar<int>();

                return branchId;

            }

        }



        public bool updateBranch(Branch_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlHistoryUser = " INSERT INTO [HISTORY_BRANCH] SELECT * FROM [BRANCH] WHERE ID=@ID ";
                int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @" update BRANCH set
                            BranchName=@BranchName,
                            Summary=@Summary,
                            Contact=@Contact,
                            Phone=@Phone,
                            Fax=@Fax,
                            Web=@Web,
                            Address=@Address,
                            Zip=@Zip,
                            Longitude=@Longitude,
                            Latitude=@Latitude,
                            BusinessHours=@BusinessHours,
                            Remark=@Remark,
                            Visible=@Visible,
                            UpdaterID=@UpdaterID,
                            UpdateTime=@UpdateTime,
                            {0}
                            RemindTime=@RemindTime,
                            IsShowECardHis=@IsShowECardHis,
                            IsConfirmed=@IsConfirmed,
                            IsPay=@IsPay,
                            DefaultPassword = @DefaultPassword ,
                            BirthdayRemindTime = @BirthdayRemindTime,
                            IsPartPay = @IsPartPay,
                            IsUseRate = @IsUseRate,
                            DefaultConsultant=@DefaultConsultant,
                            LostRemind=@LostRemind,
                            ExpiryRemind=@ExpiryRemind
                            where ID=@ID";

                string strStartTime = "";
                if (model.StartTime != "" && model.StartTime != null)
                {
                    strStartTime = " StartTime=@StartTime ,";
                }
                string strSqlFinal = string.Format(strSql, strStartTime);

                int rows = db.SetCommand(strSqlFinal
                     , db.Parameter("@BranchName", model.BranchName, DbType.String)
                     , db.Parameter("@Summary", model.Summary, DbType.String)
                     , db.Parameter("@Contact", model.Contact, DbType.String)
                     , db.Parameter("@Phone", model.Phone, DbType.String)
                     , db.Parameter("@Fax", model.Fax, DbType.String)
                     , db.Parameter("@Web", model.Web, DbType.String)
                     , db.Parameter("@Address", model.Address, DbType.String)
                     , db.Parameter("@Zip", model.Zip, DbType.Int32)
                     , db.Parameter("@Longitude", model.Longitude == 0 ? (object)DBNull.Value : model.Longitude, DbType.Decimal)
                     , db.Parameter("@Latitude", model.Latitude == 0 ? (object)DBNull.Value : model.Latitude, DbType.Decimal)
                     , db.Parameter("@BusinessHours", model.BusinessHours, DbType.String)
                     , db.Parameter("@Remark", model.Remark, DbType.String)
                     , db.Parameter("@Visible", model.Visible, DbType.Boolean)
                     , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                     , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                     , db.Parameter("@StartTime", model.StartTime == "" || model.StartTime == null ? Const.DefaultBranchStartTime.ToString() : model.StartTime, DbType.DateTime)
                     , db.Parameter("@RemindTime", StringUtils.GetDbDecimal(model.RemindTime), DbType.Decimal)
                     , db.Parameter("@IsShowECardHis", model.IsShowECardHis, DbType.Boolean)
                     , db.Parameter("@IsConfirmed", model.IsConfirmed, DbType.Boolean)
                     , db.Parameter("@IsPay", model.IsPay, DbType.Boolean)
                     , db.Parameter("@DefaultPassword", model.DefaultPassword == "" ? (object)DBNull.Value : model.DefaultPassword, DbType.String)
                     , db.Parameter("@BirthdayRemindTime", model.BirthdayRemindTime, DbType.Int32)
                     , db.Parameter("@IsPartPay", model.IsPartPay, DbType.Boolean)
                    , db.Parameter("@IsUseRate", model.IsUseRate, DbType.Int32)
                    , db.Parameter("@DefaultConsultant", model.DefaultConsultant, DbType.Int32)
                    , db.Parameter("@LostRemind", model.LostRemind == 0 ? (object)DBNull.Value : model.LostRemind, DbType.Int32)
                    , db.Parameter("@ExpiryRemind", model.ExpiryRemind == 0 ? (object)DBNull.Value : model.ExpiryRemind, DbType.Int32)
                     , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }
                if (model.ID >0 && model.IssuedDate !=null) {

                    //删除大于生效日的销售顾问提成率数据
                    string strSqlCompanyRateDelete = @"DELETE FROM COMMISSION_RATE_BRANCH WHERE BranchID = @BranchID AND IssuedDate >= @IssuedDate";
                    rows = db.SetCommand(strSqlCompanyRateDelete,
                         db.Parameter("@BranchID", model.ID, DbType.Int32)
                       , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                       ).ExecuteNonQuery();

                    //插入销售顾问默认提成率
                    string strSqlCompanyRateInsert = @"INSERT INTO COMMISSION_RATE_BRANCH (BranchID,IssuedDate,CommissionRate,CreatorID,CreateTime,UpdaterID,UpdateTime) VALUES (@BranchID,@IssuedDate,@CommissionRate,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime)";
                    rows = db.SetCommand(strSqlCompanyRateInsert,
                          db.Parameter("@BranchID", model.ID, DbType.Int32)
                        , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                        , db.Parameter("@CommissionRate", model.CommissionRate / 100, DbType.Decimal)
                        , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        ).ExecuteNonQuery();
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


        public bool isCanAddBranch(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select CASE WHEN T1.BranchNumber > ISNULL(T2.BranchCount,0) THEN 1 ELSE 0 END isCan 
                                    from [COMPANY] T1 
                                    LEFT JOIN (
                                    select Count(T3.ID) BranchCount,T3.CompanyID 
                                    from [BRANCH] T3 
                                    WHERE T3.CompanyID=@CompanyID AND T3.Available = 1 
                                    group by T3.CompanyID) T2 
                                    on T1.ID = T2.CompanyID 
                                    where T1.ID =@CompanyID";


                int isCan = db.SetCommand(strSql
                     , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                if (isCan == 1)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        #region 门店页面编辑其他相关内容的方法
        public List<GetBranchMarketRelationShip_Model> getCommodityList(int branchId, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.Code ObjectID, T1.CommodityName ObjectName,ISNULL(T2.Available,0) BranchAvailable, T3.StockCalcType,T3.ProductQty,ISNULL(T3.ID,0) AS StockID,ISNULL(T3.BuyingPrice,0) AS BuyingPrice,ISNULL(T3.InsuranceQty,0) AS InsuranceQty from [COMMODITY] T1 
                                    LEFT JOIN [TBL_MARKET_RELATIONSHIP] T2 
                                    ON T1.Code = T2.Code AND T2.Available = 1 AND T2.Type = 1 AND T2.BranchID=@BranchID 
                                    LEFT JOIN [TBL_PRODUCT_STOCK] T3
                                    ON T1.Code = T3.ProductCode AND T3.ProductType = 1 AND T3.BranchID=@BranchID
                                    where T1.CompanyID =@CompanyID AND T1.Available = 1 ";

                List<GetBranchMarketRelationShip_Model> list = db.SetCommand(strSql
                     , db.Parameter("@BranchID", branchId, DbType.Int32)
                     , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<GetBranchMarketRelationShip_Model>();
                return list;

            }
        }



        public List<StockCalcType_Model> getStockCalcTypeList()
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select ID AS StockCalcTypeID ,TypeName AS StockCalcTypeName from [SYS_PRODUCT_STOCK_OPERATETYPE] where Available = 1 ";

                List<StockCalcType_Model> list = db.SetCommand(strSql).ExecuteList<StockCalcType_Model>();
                return list;

            }
        }


        public bool OperateCommodityBranch(EditMarketRelationShipForBranchOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSqlRelationCount = " SELECT Count(0) FROM [TBL_MARKET_RELATIONSHIP] WHERE BranchID = @BranchID and CompanyID=@CompanyID and Type = 1 ";

                    int cnt = db.SetCommand(strSqlRelationCount
                     , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    string strSqlRelationHistory = " INSERT INTO TBL_HISTORY_MARKET_RELATIONSHIP SELECT *  FROM [TBL_MARKET_RELATIONSHIP] WHERE  BranchID = @BranchID and CompanyID=@CompanyID and Type = 1 ";

                    int rows = db.SetCommand(strSqlRelationHistory
                     , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (cnt != rows)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlRelationDelete = " delete [TBL_MARKET_RELATIONSHIP] where BranchID=@BranchID and CompanyID=@CompanyID and Type = 1";

                    rows = db.SetCommand(strSqlRelationDelete
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (cnt != rows)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    if (model.EditList != null && model.EditList.Count > 0)
                    {
                        foreach (EditMarketRelationShipForBranchDetail_Model item in model.EditList)
                        {
                            if (item.Available)
                            {
                                string strSqlRelationInsert = @" INSERT INTO [TBL_MARKET_RELATIONSHIP]
                                                                (CompanyID ,BranchID  ,Type ,Code ,Available ,OperatorID,OperateTime)
                                                                VALUES
                                                                (@CompanyID,@BranchID, 1,@Code,1 ,@OperatorID,@OperateTime) ";

                                rows = db.SetCommand(strSqlRelationInsert
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@Code", item.ObjectID, DbType.Int64)
                                            , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                            , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }


                            string strSqlgetStock = " select ID as StockID, ISNULL(ProductQty,0) ProductQty from [TBL_PRODUCT_STOCK] where ProductCode=@ProductCode AND BranchID=@BranchID";
                            ProductStock_Model StockInfo = db.SetCommand(strSqlgetStock
                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                        , db.Parameter("@ProductCode", item.ObjectID, DbType.Int64)).ExecuteObject<ProductStock_Model>();

                            if (StockInfo == null)
                            {
                                StockInfo = new ProductStock_Model();
                                StockInfo.StockID = 0;
                                StockInfo.ProductQty = 0;
                            }

                            int afterQty = 0;
                            switch (item.OperateType)
                            {
                                case 1:
                                    afterQty = StockInfo.ProductQty + item.OperateQty;
                                    break;
                                case 2:
                                    afterQty = StockInfo.ProductQty - item.OperateQty;
                                    break;
                                case 3:
                                    afterQty = item.OperateQty;
                                    break;
                                default:
                                    afterQty = StockInfo.ProductQty;
                                    break;
                            }

                            if (item.OperateType > 0)
                            {

                                string strSqlOperateLog = @" INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG]
                                                        (CompanyID ,BranchID ,ProductType,ProductCode ,OperateType,OperateQty ,OperateSign  ,OrderID ,OperatorID  ,OperateTime ,Remark,ProductQty)
                                                        VALUES
                                                        (@CompanyID, @BranchID, 1,  @ProductCode,  @OperateType, @OperateQty,  @OperateSign, null,@OperatorID, @OperateTime,  @Remark, @ProductQty) ";

                                rows = db.SetCommand(strSqlOperateLog
                                  , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                  , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                  , db.Parameter("@ProductCode", item.ObjectID, DbType.Int64)
                                  , db.Parameter("@OperateType", item.OperateType, DbType.Int32)
                                  , db.Parameter("@OperateQty", item.OperateQty, DbType.Int32)
                                  , db.Parameter("@OperateSign", item.OperateSign, DbType.String)
                                  , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                  , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)
                                  , db.Parameter("@Remark", item.Remark, DbType.String)
                                  , db.Parameter("@ProductQty", afterQty, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }


                            if (StockInfo.StockID == 0)
                            {
                                string strSqlStockInsert = @" INSERT INTO [TBL_PRODUCT_STOCK]         
                                                        (CompanyID ,BranchID ,ProductType,ProductCode ,ProductQty ,OperatorID ,OperateTime,StockCalcType,BuyingPrice,InsuranceQty)
                                                             VALUES       
                                                        (@CompanyID,@BranchID ,1,@ProductCode  ,@ProductQty ,@OperatorID,@OperateTime,@StockCalcType,@BuyingPrice,@InsuranceQty) ";

                                rows = db.SetCommand(strSqlStockInsert
                                                      , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                      , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                      , db.Parameter("@ProductCode", item.ObjectID, DbType.Int64)
                                                      , db.Parameter("@ProductQty", afterQty, DbType.Int32)
                                                      , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                                      , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)
                                                      , db.Parameter("@StockCalcType", item.StockCalcType, DbType.Int32)
                                                      , db.Parameter("@BuyingPrice", item.BuyingPrice, DbType.Decimal)
                                                      , db.Parameter("@InsuranceQty", item.InsuranceQty, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            else
                            {
                                string strSqlStockUpdate = @" UPDATE [TBL_PRODUCT_STOCK]
                                                               SET ProductQty = @ProductQty
                                                                  ,OperatorID = @OperatorID
                                                                  ,OperateTime = @OperateTime
                                                                  ,StockCalcType = @StockCalcType
                                                                  ,BuyingPrice = @BuyingPrice
                                                                  ,InsuranceQty = @InsuranceQty
                                                             WHERE ID=@StockID and CompanyID=@CompanyID and BranchID = @BranchID and ProductCode = @ProductCode ";

                                rows = db.SetCommand(strSqlStockUpdate
                                                   , db.Parameter("@ProductQty", afterQty, DbType.Int32)
                                                   , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                                   , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)
                                                   , db.Parameter("@StockCalcType", item.StockCalcType, DbType.Int32)
                                                   , db.Parameter("@StockID", StockInfo.StockID, DbType.Int32)
                                                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                   , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                   , db.Parameter("@ProductCode", item.ObjectID, DbType.Int64)
                                                      , db.Parameter("@BuyingPrice", item.BuyingPrice, DbType.Decimal)
                                                      , db.Parameter("@InsuranceQty", item.InsuranceQty, DbType.Int32)).ExecuteNonQuery();

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
                catch(Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public List<GetBranchMarketRelationShip_Model> getServiceList(int branchId, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.Code ObjectID, T1.ServiceName ObjectName,ISNULL(T2.Available,0) BranchAvailable from [SERVICE] T1 
                                    LEFT JOIN [TBL_MARKET_RELATIONSHIP] T2 
                                    ON T1.Code = T2.Code AND T2.Available = 1 AND T2.Type = 0 AND T2.BranchID=@BranchID 
                                
                                    where T1.CompanyID =@CompanyID AND T1.Available = 1 ";

                List<GetBranchMarketRelationShip_Model> list = db.SetCommand(strSql
                     , db.Parameter("@BranchID", branchId, DbType.Int32)
                     , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<GetBranchMarketRelationShip_Model>();
                return list;

            }
        }


        public bool OperateServiceBranch(EditMarketRelationShipForBranchOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSqlRelationCount = " SELECT Count(0) FROM [TBL_MARKET_RELATIONSHIP] WHERE BranchID = @BranchID and CompanyID=@CompanyID and Type = 0 ";

                    int cnt = db.SetCommand(strSqlRelationCount
                     , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    string strSqlRelationHistory = " INSERT INTO TBL_HISTORY_MARKET_RELATIONSHIP SELECT *  FROM [TBL_MARKET_RELATIONSHIP] WHERE  BranchID = @BranchID and CompanyID=@CompanyID and Type = 0 ";

                    int rows = db.SetCommand(strSqlRelationHistory
                     , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (cnt != rows)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlRelationDelete = " delete [TBL_MARKET_RELATIONSHIP] where BranchID=@BranchID and CompanyID=@CompanyID and Type = 0";

                    rows = db.SetCommand(strSqlRelationDelete
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (cnt != rows)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    if (model.EditList != null && model.EditList.Count > 0)
                    {
                        foreach (EditMarketRelationShipForBranchDetail_Model item in model.EditList)
                        {
                            if (item.Available)
                            {
                                string strSqlRelationInsert = @" INSERT INTO [TBL_MARKET_RELATIONSHIP]
                                                                (CompanyID ,BranchID  ,Type ,Code ,Available ,OperatorID,OperateTime)
                                                                VALUES
                                                                (@CompanyID,@BranchID,0,@Code,1 ,@OperatorID,@OperateTime) ";

                                rows = db.SetCommand(strSqlRelationInsert
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@Code", item.ObjectID, DbType.Int64)
                                            , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                            , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();

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
                catch(Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public PriceRange_Model getPriceRange(int BranchID, int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select PriceRangeNo,PriceRangeName,ISNULL(PriceRangeValue,'|0|100|500|1000|3000|5000|') PriceRangeValue,BranchID,CompanyID from TBL_A_PRICERANGE where BranchID =@BranchID and CompanyID =@CompanyID ";
                PriceRange_Model model = db.SetCommand(strSql, db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteObject<PriceRange_Model>();
                return model;
            }
        }

        public bool EditPriceRange(PriceRange_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select PriceRangeNo from TBL_A_PRICERANGE where BranchID =@BranchID  and CompanyID =@CompanyID  ";
                int id = db.SetCommand(strSql, db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                if (id == 0)
                {
                    strSql = @" INSERT INTO [TBL_A_PRICERANGE]
                            (PriceRangeName,PriceRangeValue,BranchID,CompanyID,CreatorID,CreateTime,RecordType)
                            VALUES		
                            (@PriceRangeName,@PriceRangeValue,@BranchID,@CompanyID,@CreatorID,@CreateTime,@RecordType) ";

                    int rows = db.SetCommand(strSql, db.Parameter("@PriceRangeName", model.PriceRangeName, DbType.String)
                        , db.Parameter("@PriceRangeValue", model.PriceRangeValue, DbType.String)
                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                        , db.Parameter("@RecordType", 1, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 1)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    strSql = @" UPDATE [TBL_A_PRICERANGE]
                            SET PriceRangeName = @PriceRangeName
                            ,PriceRangeValue = @PriceRangeValue
                            ,UpdaterID = @UpdaterID
                            ,UpdateTime = @UpdateTime
                            WHERE  PriceRangeNo =@PriceRangeNo and BranchID = @BranchID and CompanyID=@CompanyID ";

                    int rows = db.SetCommand(strSql, db.Parameter("@PriceRangeName", model.PriceRangeName, DbType.String)
                       , db.Parameter("@PriceRangeValue", model.PriceRangeValue, DbType.String)
                       , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                       , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                       , db.Parameter("@PriceRangeNo", id, DbType.Int32)
                       , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 1)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }

                }

            }

        }
        #endregion



        public List<Account_Model> getAccountListForBranchEdit(int BranchID, int CompanyID) {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.UserID,T1.Name,ISNULL(T3.SortID,10000) SortID 
                                    from [ACCOUNT] T1 WITH (NOLOCK) 
                                    INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 WITH (NOLOCK) 
                                    ON T1.UserID = T2.UserID 
                                    LEFT JOIN [TBL_ACCOUNTSORT] T3 WITH (NOLOCK) 
                                    ON T2.UserID = T3.UserID AND T2.BranchID = T3.BranchID 
                                    WHERE T1.CompanyID =@CompanyID AND T2.BranchID=@BranchID AND T1.Available = 1 ORDER BY T3.SortID  ";


                List<Account_Model> list = db.SetCommand(strSql
                     , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                     , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteList<Account_Model>();

                return list;


            }
        }


        public List<Account_Model> getAccountListForDefaultConsultant(int BranchID, int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select distinct T5.UserID,T5.Name  from (
select T1.UserID,T1.Name
                                    from [ACCOUNT] T1 WITH (NOLOCK) 
                                    INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 WITH (NOLOCK) 
                                    ON T1.UserID = T2.UserID 
                                    WHERE T1.CompanyID =@CompanyID AND T2.BranchID=@BranchID AND T1.Available = 1 union all SELECT T4.UserID,T4.Name FROM [BRANCH] T3 INNER JOIN [ACCOUNT] T4 ON T3.DefaultConsultant = T4.UserID AND T3.CompanyID =@CompanyID AND T3.ID=@BranchID) T5  ";


                List<Account_Model> list = db.SetCommand(strSql
                     , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                     , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteList<Account_Model>();

                return list;


            }
        }

        #endregion

    }
}
