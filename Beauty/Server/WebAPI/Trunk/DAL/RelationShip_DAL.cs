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
    public class RelationShip_DAL
    {
        #region 构造类实例
        public static RelationShip_DAL Instance
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
            internal static readonly RelationShip_DAL instance = new RelationShip_DAL();
        }
        #endregion

        public List<Customer_Model> GetCustomerList(int branchId, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select  T2.UserID,T2.Name, '|' + ISNULL(T2.Name,'') + '|' +  ISNULL(T3.LoginMobile,'')+ '|' +  ISNULL(T2.PinYin,'') AS SearchOut FROM  [CUSTOMER] T2  
                                    INNER JOIN [USER] T3 ON T2.UserID = T3.ID AND T3.UserType = 0  ";
                //if (branchId > 0)
                //{
                //    strSql += "  INNER JOIN [RELATIONSHIP] T1   ON T1.CustomerID = T2.UserID  AND T1.Available = 1  ";
                //}
                strSql += "  WHERE T2.Available = 1 AND T2.CompanyID =@CompanyID ";
                if (branchId > 0)
                {
                    strSql += "  AND T2.BranchID =@BranchID ";
                }


                List<Customer_Model> list = new List<Customer_Model>();
                list = db.SetCommand(strSql, db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<Customer_Model>();

                return list;
            }
        }

        public List<Customer_Model> GetCustomerListByAccountName(int branchId, string inputSearch, int type)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select  T1.CustomerID UserID,T2.Name,'|' + ISNULL(T2.Name,'') + '|' +  ISNULL(T4.LoginMobile,'') + '|' +  ISNULL( T2.PinYin,'')  AS SearchOut
                                from [RELATIONSHIP] T1 INNER JOIN [CUSTOMER] T2 
                                ON T1.CustomerID = T2.UserID AND T2.Available = 1 
                                LEFT JOIN [ACCOUNT] T3 ON T1.AccountID = T3.UserID
                                INNER JOIN [USER] T4 ON T1.CustomerID = T4.ID AND T4.UserType = 0
                                WHERE T1.Available = 1  AND T1.BranchID =@BranchID AND T1.Type =@Type
                                AND T3.Name = @InputSearch ";

                List<Customer_Model> list = new List<Customer_Model>();
                list = db.SetCommand(strSql, db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@InputSearch",  inputSearch , DbType.String)
                    , db.Parameter("@Type", type, DbType.Int32)).ExecuteList<Customer_Model>();

                return list;

            }
        }

        public List<RelationShip_Model> GetAccountList(int branchId)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT 0 as ID,T1.UserID AccountID, 0 as Available,T1.Name AccountName,1 as AccountStatus , '|' + ISNULL(T1.Name,'') +  '|' + ISNULL(T1.Code,'') + '|' + ISNULL(T1.Mobile,'') AS SearchOut
                                FROM [ACCOUNT] T1 
                                INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 
                                ON T1.UserID = T2.UserID AND T2.Available = 1 AND T2.BranchID =@BranchID 
                                WHERE T1.Available = 1  ";



                List<RelationShip_Model> list = new List<RelationShip_Model>();
                list = db.SetCommand(strSql, db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteList<RelationShip_Model>();

                return list;

            }
        }

        public List<RelationShip_Model> GetRelationShipList(int customerId, int branchId, int type)
        {

            using (DbManager db = new DbManager())
            {
                string strSqlRelat = @" select T1.ID,T1.AccountID,T1.Available,T4.Name AccountName,T4.AccountStatus , '|' + ISNULL(T4.Name,'') +  '|' + ISNULL(T4.Code,'') + '|' + ISNULL(T4.Mobile,'')  AS SearchOut
                                from [RELATIONSHIP] T1 
                                INNER JOIN (SELECT T2.UserID,T2.Name,T2.Code,T2.Mobile,CASE WHEN T2.Available = 1 AND T3.Available = 1 THEN 1 ELSE 0 END AccountStatus  FROM [ACCOUNT] T2 
                                LEFT JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T3 
                                ON T2.UserID = T3.UserID AND T3.BranchID=@BranchID AND T3.Available = 1) T4 
                                ON T1.AccountID = T4.UserID 
                                WHERE T1.CustomerID =@CustomerID AND T1.BranchID=@BranchID AND T1.Type =@Type
                                ";

                List<RelationShip_Model> listRelat = new List<RelationShip_Model>();
                listRelat = db.SetCommand(strSqlRelat, db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@Type", type, DbType.Int32)).ExecuteList<RelationShip_Model>();

                string strUserId = "";
                if (listRelat != null && listRelat.Count > 0)
                {
                    foreach (RelationShip_Model item in listRelat)
                    {
                        if (strUserId != "")
                        {
                            strUserId += ",";
                        }
                        strUserId += item.AccountID;
                    }
                }


                string strSqlNorelat = @" select 0 as ID ,T1.UserID AccountID,0 as Available ,T1.Name AccountName,T1.Available AccountStatus  ,'|' + ISNULL(T1.Name,'') +  '|' + ISNULL(T1.Code,'') + '|' + ISNULL(T1.Mobile,'')  AS SearchOut
                                        from [ACCOUNT] T1 
                                        INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 
                                        ON T1.UserID = T2.UserID AND T2.Available = 1 AND T2.BranchID =@BranchID 
                                        WHERE T1.Available = 1";
                if (strUserId != "")
                {
                    strSqlNorelat += "  AND T1.UserID not in (  " + strUserId + " ) ";
                }


                List<RelationShip_Model> noRelatList = new List<RelationShip_Model>();
                noRelatList = db.SetCommand(strSqlNorelat, db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<RelationShip_Model>();

                if (noRelatList == null)
                {
                    if (listRelat != null)
                    {
                        noRelatList = new List<RelationShip_Model>();
                        foreach (RelationShip_Model item in listRelat)
                        {

                            noRelatList.Add(item);
                        }
                    }
                }
                else
                {
                    if (listRelat != null)
                    {
                        foreach (RelationShip_Model item in listRelat)
                        {
                            noRelatList.Insert(0, item);
                        }
                    }
                }

                return noRelatList;

            }
        }


        public bool changeRelationShip(RelationShip_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    if (model.listCustomerID != null && model.listCustomerID.Count > 0)
                    {
                        foreach (int customerId in model.listCustomerID)
                        {
                            string strSqlHistory = @" INSERT INTO [HISTORY_RELATIONSHIP] SELECT * FROM [RELATIONSHIP] WHERE  CustomerID=@CustomerID and BranchID=@BranchID and Type= @Type";

                            int rows = db.SetCommand(strSqlHistory, db.Parameter("@CustomerID", customerId, DbType.Int32)
                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                , db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteNonQuery();

                            string strSqlDelete = @" delete [RELATIONSHIP] where CustomerID=@CustomerID and BranchID=@BranchID and Type= @Type ";

                            int rowsDelete = db.SetCommand(strSqlDelete, db.Parameter("@CustomerID", customerId, DbType.Int32)
                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                , db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteNonQuery();

                            if (rows != rowsDelete)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            string strSqlCheck = @" select Count(*) from  [RELATIONSHIP] where CustomerID=@CustomerID and BranchID=@BranchID and Type= @Type ";

                            int checkCount = db.SetCommand(strSqlCheck, db.Parameter("@CustomerID", customerId, DbType.Int32)
                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                , db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteScalar<int>();

                            if (checkCount > 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }


                            if (model.listSubmitAccountID != null && model.listSubmitAccountID.Count > 0)
                            {
                                string strSqlAdd = @"insert into RELATIONSHIP(
                            CompanyID,AccountID,CustomerID,Available,CreatorID,CreateTime,BranchID,Type)
                             values (
                            @CompanyID,@AccountID,@CustomerID,@Available,@CreatorID,@CreateTime,@BranchID,@Type)";

                                foreach (int item in model.listSubmitAccountID)
                                {
                                    rows = db.SetCommand(strSqlAdd, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                  , db.Parameter("@AccountID", item, DbType.Int32)
                                  , db.Parameter("@CustomerID", customerId, DbType.Int32)
                                  , db.Parameter("@Available", true, DbType.Boolean)
                                  , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                  , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                  , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                  , db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteNonQuery();

                                    if (rows == 0)
                                    {
                                        db.RollbackTransaction();
                                        return false;
                                    }
                                }

                            }
                        }
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
    }
}
