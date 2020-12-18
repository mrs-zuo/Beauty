using BLToolkit.Data;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Journal_DAL
    {
        #region 构造类实例
        public static Journal_DAL Instance
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
            internal static readonly Journal_DAL instance = new Journal_DAL();
        }
        #endregion

        public List<Journal_Item_Model> GetItemList()
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select ID, Name from [SYS_JOURNAL_ITEM] with (NOLOCK) ";
                List<Journal_Item_Model> list = db.SetCommand(strSql).ExecuteList<Journal_Item_Model>();
                return list;
            }
        }

        public List<Journal_Account_New_Model> GetJournalList(Journal_Account_Search_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlTable = @" from [TBL_JOURNAL_ACCOUNT] T1 WITH (NOLOCK) 
                                LEFT JOIN [InOutItemA] T2 WITH (NOLOCK) ON T1.ItemAID = T2.ItemAID 
                                LEFT JOIN [InOutItemB] T3 WITH (NOLOCK) ON T1.ItemBID = T3.ItemBID 
                                LEFT JOIN [InOutItemC] T4 WITH (NOLOCK) ON T1.ItemCID = T4.ItemCID 
                                LEFT JOIN [ACCOUNT] T5 ON T1.OperatorID = T5.UserID
                                LEFT JOIN [BRANCH] T7 ON T1.BranchID = T7.ID
                                WHERE T1.CompanyID=@CompanyID";
                string strSqlAmountTotal = @" SELECT  Convert(decimal(18,2),SUM(T1.Amount)) AS Amount,T1.InOutType ";
                strSqlAmountTotal += strSqlTable;
                string strSql = @" SELECT T1.JournalAccountID ID,T1.InOutType,T7.BranchName,T2.ItemAName,
                                          T3.ItemBName,T4.ItemCName,CONVERT(VARCHAR(10),InOutDate,120) AS InOutDate,
                                          T1.OperatorID, T5.Name OperatorName,
                                          T1.Remark,T1.CheckResult,
                                          CASE T1.CheckResult WHEN 1 THEN '通过' WHEN 2 THEN '退回' ELSE '未审核' END AS CheckResultName,
                                          CASE T1.InOutType WHEN 1 THEN '支出' WHEN 2 THEN '收入' END AS InOutTypeName,
                                          Convert(decimal(18,2),T1.Amount) AS Amount, T1.OperatorID ";
                strSql += strSqlTable;
                if (model.BranchID >= 0)
                {
                    strSql += " and T1.BranchID=@BranchID ";
                    strSqlAmountTotal += " and T1.BranchID=@BranchID ";
                }
                if (model.InOutType > 0) {
                    strSql += " and T1.InOutType=@InOutType ";
                    strSqlAmountTotal += " and T1.InOutType=@InOutType ";
                }
                if (!string.IsNullOrWhiteSpace(model.StartDate))
                {
                    strSql += " AND T1.InOutDate >= @StartDate ";
                    strSqlAmountTotal += " AND T1.InOutDate >= @StartDate ";
                }
                if (!string.IsNullOrWhiteSpace(model.EndDate)) {
                    
                    strSql += " AND T1.InOutDate <= @EndDate ";
                    strSqlAmountTotal += " AND T1.InOutDate <= @EndDate ";
                }
                if (string.IsNullOrWhiteSpace(model.StartDate) && string.IsNullOrWhiteSpace(model.EndDate))
                {
                    string dateMonth = DateTime.Now.ToLocalTime().ToString("yyyy-MM");
                    strSql += " AND CONVERT(VARCHAR(10),InOutDate,120) LIKE '"+ dateMonth + "%'  ";
                    strSqlAmountTotal += " AND CONVERT(VARCHAR(10),InOutDate,120) LIKE '" + dateMonth + "%'  ";
                }
                if (!string.IsNullOrWhiteSpace(model.ItemName))
                {
                    strSql += " AND (T2.ItemAName LIKE '%"+ model.ItemName + "%' OR T3.ItemBName LIKE '%"+ model.ItemName + "%' OR T4.ItemCName LIKE '%"+ model.ItemName + "%')  ";
                    strSqlAmountTotal += " AND (T2.ItemAName LIKE '%" + model.ItemName + "%' OR T3.ItemBName LIKE '%" + model.ItemName + "%' OR T4.ItemCName LIKE '%" + model.ItemName + "%')  ";
                }
                strSqlAmountTotal += " GROUP BY T1.InOutType";
                strSql += " ORDER BY T1.BranchID ASC,T1.ItemAID ASC,T1.ItemBID ASC,T1.ItemCID ASC,T1.InOutDate DESC ";
                List<Journal_Account_New_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                          , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                                          , db.Parameter("@InOutType", model.InOutType, DbType.Int32)
                                                                          , db.Parameter("@StartDate", model.StartDate, DbType.String)
                                                                          , db.Parameter("@EndDate", model.EndDate, DbType.String)
                                                                          , db.Parameter("@ItemName", model.ItemName, DbType.String)).ExecuteList<Journal_Account_New_Model>();
                List<Journal_Account_Amount_Total_Model> totalList = db.SetCommand(strSqlAmountTotal, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                          , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                                          , db.Parameter("@InOutType", model.InOutType, DbType.Int32)
                                                                          , db.Parameter("@StartDate", model.StartDate, DbType.String)
                                                                          , db.Parameter("@EndDate", model.EndDate, DbType.String)
                                                                          , db.Parameter("@ItemName", model.ItemName, DbType.String)).ExecuteList<Journal_Account_Amount_Total_Model>();
                if (list !=null && list.Count > 0) {
                    for (int i = 0;i < totalList.Count;i ++) {
                        Journal_Account_New_Model detailModel = new Journal_Account_New_Model();
                        if (totalList[i].InOutType == 1) {
                            detailModel.InOutTypeName = "总支出";
                        }
                        if (totalList[i].InOutType == 2)
                        {
                            detailModel.InOutTypeName = "总收入";
                        }
                        detailModel.Amount = totalList[i].Amount;
                        list.Add(detailModel);
                    }
                }
                return list;
            }
        }

        public JournalAccountOperation_Model GetJournalDetail(Journal_Account_Search_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.CompanyID,T1.BranchID,T1.JournalAccountID AS ID,T1.InOutType,T1.CheckResult,
                                          T1.ItemAID,T1.ItemBID,T1.ItemCID,
                                          T1.InOutDate,T1.Amount,T1.OperatorID,T1.Remark
                                   from [TBL_JOURNAL_ACCOUNT] T1 WITH (NOLOCK) 
                                        WHERE T1.JournalAccountID=@ID ";
                JournalAccountOperation_Model Result = db.SetCommand(strSql, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteObject<JournalAccountOperation_Model>();
                return Result;
            }
        }

        public Journal_Account_Defult_Amount_Model GetDefaultAMount(Journal_Account_Defult_Amount_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT TOP 1 T1.BranchID, T1.ItemAID,T1.ItemBID,T1.ItemCID,Convert(decimal(18,2),T1.Amount) AS Amount
                                   from [TBL_JOURNAL_ACCOUNT] T1 WITH (NOLOCK) 
                                        WHERE T1.CompanyID=@CompanyID ";
                if (model.BranchID  > 0) {
                    strSql += " AND T1.BranchID =@BranchID ";
                }
                if (model.ItemAID > 0)
                {
                    strSql += " AND T1.ItemAID =@ItemAID ";
                }
                if (model.ItemBID > 0)
                {
                    strSql += " AND T1.ItemBID =@ItemBID ";
                }
                if (model.ItemCID > 0)
                {
                    strSql += " AND T1.ItemCID =@ItemCID ";
                }
                if (model.InOutType > 0)
                {
                    strSql += " AND T1.InOutType =@InOutType ";
                }
                strSql += " ORDER BY T1.InOutDate DESC, T1.JournalAccountID DESC";
                Journal_Account_Defult_Amount_Model Result = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@ItemAID", model.ItemAID, DbType.Int32)
                    , db.Parameter("@ItemBID", model.ItemBID, DbType.Int32)
                    , db.Parameter("@ItemCID", model.ItemCID, DbType.Int32)
                    , db.Parameter("@InOutType", model.InOutType, DbType.Int32)
                    ).ExecuteObject<Journal_Account_Defult_Amount_Model>();
                return Result;
            }
        }

        public List<Account_Model> GetOperatorList(Journal_Account_Search_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT distinct T5.UserID,T5.Name  from (
                                    select T1.OperatorID AS UserID,T2.Name from 
                                    [TBL_JOURNAL_ACCOUNT] T1 with (nolock) 
                                    INNER JOIN [ACCOUNT] T2 ON T1.OperatorID = T2.UserID 
                                    WHERE T1.JournalAccountID=@ID AND T1.CompanyID=@CompanyID
                                    UNION ALL 
                                    SELECT T3.UserID,T3.Name FROM [ACCOUNT] T3 WITH (NOLOCK) 
                                    INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T4 
                                    ON T3.UserID = T4.UserID AND T4.Available = 1 AND T4.BranchID =@BranchID 
                                    WHERE T3.CompanyID=@CompanyID AND T3.Available = 1) T5 ";


                List<Account_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                  , db.Parameter("@ID", model.ID, DbType.Int32)
                                                                  , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<Account_Model>();
                return list;
            }
        }

        public List<Branch_Model> GetBranchList(int CompanyID, int BranchID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.ID,CASE T1.Available WHEN 1 THEN T1.BranchName ELSE T1.BranchName + ' (已关闭)' END as BranchName 
                                    from [BRANCH] T1 WITH (NOLOCK) 
                                    WHERE T1.CompanyID=@CompanyID ";

                if (BranchID > 0)
                {
                    strSql += "  AND T1.ID=@BranchID  ";
                }
                strSql += @" ORDER by T1.Available DESC ";


                List<Branch_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                              , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteList<Branch_Model>();
                return list;
            }
        }

        public bool AddJournal(JournalAccountOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" INSERT INTO [TBL_JOURNAL_ACCOUNT]
                                (CompanyID,BranchID,ItemAID,ItemBID,ItemCID,InOutType,InOutDate,Amount,OperatorID,Remark,CheckResult,CreatorID,CreateTime, UpdaterID, UpdateTime)
                                VALUES
                                (@CompanyID,@BranchID,@ItemAID,@ItemBID,@ItemCID,@InOutType,@InOutDate ,@Amount ,@OperatorID,@Remark,@CheckResult, @CreatorID,@CreateTime,@CreatorID,@CreateTime) ";


                int rows = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@ItemAID", model.ItemAID, DbType.Int32)
                    , db.Parameter("@ItemBID", model.ItemBID, DbType.Int32)
                    , db.Parameter("@ItemCID", model.ItemCID, DbType.Int32)
                    , db.Parameter("@InOutType", model.InOutType, DbType.Int16)
                    , db.Parameter("@InOutDate", model.InOutDate, DbType.Date)
                    , db.Parameter("@Amount", model.Amount, DbType.Decimal)
                   // , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                    , db.Parameter("@OperatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@Remark", model.Remark, DbType.String)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                    , db.Parameter("@CheckResult",0, DbType.Int16)).ExecuteNonQuery();

                if (rows != 1)
                {
                    return false;
                }

                return true;
            }
        }

        public bool UpdateJournal(JournalAccountOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" UPDATE [TBL_JOURNAL_ACCOUNT]
                                    SET BranchID = @BranchID
                                       ,InOutType = @InOutType
                                       ,InOutDate=@InOutDate
                                       ,ItemAID = @ItemAID
                                       ,ItemBID=@ItemBID
                                       ,ItemCID=@ItemCID
                                       ,Amount = @Amount
                                       ,OperatorID = @OperatorID
                                       ,Remark = @Remark
                                       ,UpdaterID = @UpdaterID
                                       ,UpdateTime = @UpdateTime
                                       ,CheckResult=@CheckResult
                                        WHERE JournalAccountID=@JournalAccountID and CompanyID=@CompanyID ";


                int rows = db.SetCommand(strSql, db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@InOutType", model.InOutType, DbType.Int16)
                    , db.Parameter("@InOutDate", model.InOutDate, DbType.Date)
                    , db.Parameter("@ItemAID", model.ItemAID, DbType.Int32)
                    , db.Parameter("@ItemBID", model.ItemBID, DbType.Int32)
                    , db.Parameter("@ItemCID", model.ItemCID, DbType.Int32)
                    , db.Parameter("@Amount", model.Amount, DbType.Decimal)
                    //, db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                    , db.Parameter("@OperatorID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@Remark", model.Remark, DbType.String)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@CheckResult", 0, DbType.Int16)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@JournalAccountID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    return false;
                }

                return true;
            }
        }



        public bool DeleteJournal(JournalAccountOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                /*string strSql = @" UPDATE [TBL_JOURNAL_ACCOUNT]
                                    SET RecordType  = 2
                                       ,UpdaterID = @UpdaterID
                                       ,UpdateTime = @UpdateTime
                                        WHERE ID=@ID and CompanyID=@CompanyID ";
                */
                string strSql = @" DELETE [TBL_JOURNAL_ACCOUNT] WHERE JournalAccountID=@JournalAccountID and CompanyID=@CompanyID ";

                int rows = db.SetCommand(strSql
                    , db.Parameter("@JournalAccountID", model.ID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    return false;
                }

                return true;
            }
        }

    }
}
