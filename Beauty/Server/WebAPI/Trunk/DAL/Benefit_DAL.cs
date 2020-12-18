using BLToolkit.Data;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Benefit_DAL
    {

        #region 构造类实例
        public static Benefit_DAL Instance
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
            internal static readonly Benefit_DAL instance = new Benefit_DAL();
        }
        #endregion

        public List<BenefitPolicy_Model> getBenefitList(int companyId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select T1.PolicyID, T1.PolicyName, T1.PolicyActPosition, T1.PolicyType, T1.Amount,T1.RecordType,T1.StartDate from [TBL_BENEFIT_POLICY] T1 with (nolock)  ";
                if (branchId > 0)
                {
                    strSql += " INNER JOIN [TBL_POLICY_BRANCH] T2 WITH (NOLOCK) ON T1.PolicyID = T2.PolicyID AND T2.BranchID=@BranchID ";
                }
                strSql += "  where  T1.CompanyID =@CompanyID and  T1.PolicyType = 1  ";

                List<BenefitPolicy_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteList<BenefitPolicy_Model>();

                return list;
            }
        }




        public BenefitPolicy_Model getBenefitDetail(int companyId, string policyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT PolicyID,PolicyName,PolicyType,PolicyActType,PolicyActPosition,PolicyDescription,PolicyComments,Amount,StartDate,PRCode,PRValue1,PRValue2,PRValue3,PRValue4,ValidDays,RecordType  FROM [TBL_BENEFIT_POLICY] with (nolock) where PolicyID =@PolicyID and CompanyID =@CompanyID ";


                BenefitPolicy_Model model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                     , db.Parameter("@PolicyID", policyId, DbType.String)).ExecuteObject<BenefitPolicy_Model>();

                if (model != null && model.PolicyID != "")
                {
                    string strSqlBranch = @" select T1.ID BranchID ,T1.BranchName,CASE ISNULL(T2.PolicyRelationID,0)  WHEN 0 THEN 0 ELSE 1 END IsExist from [BRANCH] T1 with (nolock) LEFT JOIN [TBL_POLICY_BRANCH] T2 WITH (NOLOCK) ON T1.ID = T2.BranchID AND T2.PolicyID =@PolicyID WHERE T1.Available = 1 AND T1.CompanyID =@CompanyID ";
                    model.listBranch = new List<BranchSelection_Model>();
                    model.listBranch = db.SetCommand(strSqlBranch, db.Parameter("@CompanyID", companyId, DbType.Int32)
                     , db.Parameter("@PolicyID", policyId, DbType.String)).ExecuteList<BranchSelection_Model>();


                    string strSqlRule = @" SELECT distinct PromotionType,PromotionTypeName FROM [SYS_PROMOTION_RULE] WITH (NOLOCK) where Type =2 ";
                    model.listRule = new List<PromotionRule_Model>();
                    model.listRule = db.SetCommand(strSqlRule).ExecuteList<PromotionRule_Model>();
                }

                return model;
            }
        }

        public List<PromotionRule_Model> getBenfitRule()
        {
            using (DbManager db = new DbManager())
            {
                List<PromotionRule_Model> list = new List<PromotionRule_Model>();
                string strSqlRule = @" SELECT distinct PromotionType,PromotionTypeName,PRCode FROM [SYS_PROMOTION_RULE] WITH (NOLOCK) where Type =2 ";
                list = db.SetCommand(strSqlRule).ExecuteList<PromotionRule_Model>();
                return list;
            }
        }

        public string AddBenefitPolicy(BenefitPolicy_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string PolicyID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "BenefitID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();
                if (string.IsNullOrWhiteSpace(PolicyID))
                {
                    db.RollbackTransaction();
                    return null;
                }

                string strSqlInsert = @" INSERT INTO [TBL_BENEFIT_POLICY]
                                    (PolicyID,PolicyName,PolicyType,PolicyActType,PolicyActPosition,PolicyDescription,PolicyComments,Amount,StartDate,PRCode,PRValue1,PRValue2,PRValue3,PRValue4,ValidDays,CompanyID,CreatorID,CreateTime,RecordType)
                                     VALUES
                                    (@PolicyID,@PolicyName,@PolicyType,@PolicyActType,@PolicyActPosition,@PolicyDescription,@PolicyComments,@Amount,@StartDate,@PRCode,@PRValue1,@PRValue2,@PRValue3,@PRValue4,@ValidDays,@CompanyID,@CreatorID,@CreateTime,1) ";

                int rows = db.SetCommand(strSqlInsert, db.Parameter("@PolicyID", PolicyID, DbType.String)
                    , db.Parameter("@PolicyName", model.PolicyName, DbType.String)
                    , db.Parameter("@PolicyType", model.PolicyType, DbType.Int32)
                    , db.Parameter("@PolicyActType", model.PolicyActType, DbType.Int32)
                    , db.Parameter("@PolicyActPosition", model.PolicyActPosition, DbType.Int32)
                    , db.Parameter("@PolicyDescription", model.PolicyDescription, DbType.String)
                    , db.Parameter("@PolicyComments", model.PolicyComments, DbType.String)
                    , db.Parameter("@Amount", model.Amount, DbType.Int32)
                    , db.Parameter("@StartDate", model.StartDate, DbType.DateTime2)
                    , db.Parameter("@PRCode", model.PRCode, DbType.String)
                    , db.Parameter("@PRValue1", model.PRValue1 == 0 ? (object)DBNull.Value : model.PRValue1, DbType.Decimal)
                    , db.Parameter("@PRValue2", model.PRValue2 == 0 ? (object)DBNull.Value : model.PRValue2, DbType.Decimal)
                    , db.Parameter("@PRValue3", model.PRValue3 == 0 ? (object)DBNull.Value : model.PRValue3, DbType.Decimal)
                    , db.Parameter("@PRValue4", model.PRValue4 == 0 ? (object)DBNull.Value : model.PRValue4, DbType.Decimal)
                    , db.Parameter("@ValidDays", model.ValidDays, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return null;
                }

                db.CommitTransaction();
                return PolicyID;

            }
        }

        public bool UpdateBenefitPolicy(BenefitPolicy_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCheck = @" SELECT count(0) FROM [TBL_BENEFIT_POLICY] WITH (NOLOCK) WHERE PolicyID =@PolicyID AND CompanyID =@CompanyID   AND StartDate > GETDATE() ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@PolicyID", model.PolicyID, DbType.String)).ExecuteScalar<int>();

                if (check == 0)
                {
                    string strSqlUpdate = @" UPDATE [TBL_BENEFIT_POLICY]
                                          set Amount = @Amount
                                          ,ValidDays = @ValidDays
                                          ,UpdaterID = @UpdaterID
                                          ,UpdateTime = @UpdateTime
                                          WHERE PolicyID=@PolicyID and CompanyID=@CompanyID ";


                    int rows = db.SetCommand(strSqlUpdate
                        , db.Parameter("@Amount", model.Amount, DbType.Int32)
                        , db.Parameter("@ValidDays", model.ValidDays, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@PolicyID", model.PolicyID, DbType.String)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false; ;
                    }
                }
                else
                {
                    string strSqlUpdate = @" UPDATE [TBL_BENEFIT_POLICY]
                                          SET PolicyName = @PolicyName
                                          ,PolicyType = @PolicyType
                                          ,PolicyActType = @PolicyActType 
                                          ,PolicyActPosition = @PolicyActPosition
                                          ,PolicyDescription = @PolicyDescription
                                          ,PolicyComments = @PolicyComments
                                          ,Amount = @Amount
                                          ,StartDate = @StartDate
                                          ,PRCode = @PRCode
                                          ,PRValue1 =@PRValue1
                                          ,PRValue2 =@PRValue2
                                          ,PRValue3 =@PRValue3
                                          ,PRValue4 =@PRValue4
                                          ,ValidDays = @ValidDays
                                          ,UpdaterID = @UpdaterID
                                          ,UpdateTime = @UpdateTime
                                          WHERE PolicyID=@PolicyID and CompanyID=@CompanyID ";


                    int rows = db.SetCommand(strSqlUpdate
                        , db.Parameter("@PolicyName", model.PolicyName, DbType.String)
                        , db.Parameter("@PolicyType", model.PolicyType, DbType.Int32)
                        , db.Parameter("@PolicyActType", model.PolicyActType, DbType.Int32)
                        , db.Parameter("@PolicyActPosition", model.PolicyActPosition, DbType.Int32)
                        , db.Parameter("@PolicyDescription", model.PolicyDescription, DbType.String)
                        , db.Parameter("@PolicyComments", model.PolicyComments, DbType.String)
                        , db.Parameter("@Amount", model.Amount, DbType.Int32)
                        , db.Parameter("@StartDate", model.StartDate, DbType.DateTime2)
                        , db.Parameter("@PRCode", model.PRCode, DbType.String)
                        , db.Parameter("@PRValue1", model.PRValue1 == 0 ? (object)DBNull.Value : model.PRValue1, DbType.Decimal)
                        , db.Parameter("@PRValue2", model.PRValue2 == 0 ? (object)DBNull.Value : model.PRValue2, DbType.Decimal)
                        , db.Parameter("@PRValue3", model.PRValue3 == 0 ? (object)DBNull.Value : model.PRValue3, DbType.Decimal)
                        , db.Parameter("@PRValue4", model.PRValue4 == 0 ? (object)DBNull.Value : model.PRValue4, DbType.Decimal)
                        , db.Parameter("@ValidDays", model.ValidDays, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@PolicyID", model.PolicyID, DbType.String)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false; ;
                    }
                }
                db.CommitTransaction();
                return true;
            }
        }



        public bool DeteleBenefitPolicy(BenefitPolicy_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCheck = @" SELECT count(0) FROM [TBL_BENEFIT_POLICY] WITH (NOLOCK) WHERE PolicyID =@PolicyID AND CompanyID =@CompanyID AND StartDate > GETDATE() ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@PolicyID", model.PolicyID, DbType.String)).ExecuteScalar<int>();

                if (check == 0)
                {
                    string strSqlDelete = @" UPDATE [TBL_BENEFIT_POLICY]
                                          set RecordType = 2
                                          ,UpdaterID = @UpdaterID
                                          ,UpdateTime = @UpdateTime
                                          WHERE PolicyID=@PolicyID and CompanyID=@CompanyID ";


                    int rows = db.SetCommand(strSqlDelete
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@PolicyID", model.PolicyID, DbType.String)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false; ;
                    }

                   
                }
                else
                {
                    string strSqlDelete = @" delete [TBL_BENEFIT_POLICY] WHERE PolicyID=@PolicyID and CompanyID=@CompanyID ";


                    int rows = db.SetCommand(strSqlDelete
                        , db.Parameter("@PolicyID", model.PolicyID, DbType.String)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false; ;
                    }
                }
                db.CommitTransaction();
                return true;
            }
        }


        public int OperateBranch(BranchSelectOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCheck = @" SELECT count(0) FROM [TBL_BENEFIT_POLICY] WITH (NOLOCK) WHERE PolicyID =@PolicyID AND CompanyID =@CompanyID AND StartDate > GETDATE() ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@PolicyID", model.ObjectCode, DbType.String)).ExecuteScalar<int>();

                if (check == 0)
                {
                    db.RollbackTransaction();
                    return -1;

                }

                string strSqlDelete = @" delete TBL_POLICY_BRANCH where PolicyID =@PolicyID and CompanyID =@CompanyID ";

                int rows = db.SetCommand(strSqlDelete, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@PolicyID", model.ObjectCode, DbType.String)).ExecuteNonQuery();

                if (model.BranchList != null && model.BranchList.Count > 0)
                {
                    string strSqlBranch = @" INSERT INTO [dbo].[TBL_POLICY_BRANCH]
                                            (PolicyID,BranchID,CompanyID,CreatorID,CreateTime,RecordType)
                                            VALUES
                                            (@PolicyID,@BranchID,@CompanyID,@CreatorID,@CreateTime,1)";

                    foreach (int item in model.BranchList)
                    {
                        rows = db.SetCommand(strSqlBranch
                                        , db.Parameter("@PolicyID", model.ObjectCode, DbType.String)
                                        , db.Parameter("@BranchID", item, DbType.Int32)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@CreatorID", model.OperatorID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.OperatorTime, DbType.DateTime2)).ExecuteNonQuery();
                        if (rows != 1)
                        {

                            db.RollbackTransaction();
                            return 0;
                        }
                    }
                }

                db.CommitTransaction();
                return 1;
            }
        }


    }
}
