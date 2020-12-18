using BLToolkit.Data;
using HS.Framework.Common.Entity;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
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

        public List<GetBranchList_Model> GetCustomerBranch(int companyId, int customerID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT DISTINCT T1.ID AS BranchID ,
                                            T1.BranchName
                                    FROM    [BRANCH ] T1 WITH ( NOLOCK )
                                            INNER JOIN RELATIONSHIP T2 WITH ( NOLOCK ) ON T1.ID = T2.BranchID
                                    WHERE   T2.CustomerID = @CustomerID
                                            AND T2.Available = 1
                                            AND T1.Available = 1
                                            AND T1.CompanyID = @CompanyID ";

                List<GetBranchList_Model> list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteList<GetBranchList_Model>();
                return list;
            }
        }

        public ObjectResult<List<GetBranchList_Model>> GetBranchListForRegister(int companyId, int branchID)
        {
            ObjectResult<List<GetBranchList_Model>> result = new ObjectResult<List<GetBranchList_Model>>();
            result.Code = "0";
            result.Data = null;
            result.Message = "";
            using (DbManager db = new DbManager())
            {
                string strSql = @"select ID BranchID,BranchName from [BRANCH] with (nolock) where CompanyID =@CompanyID  ";

                if (branchID > 0)
                {
                    strSql += " and ID = @BranchID ";
                }

                List<GetBranchList_Model> list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<GetBranchList_Model>();

                if (list != null)
                {
                    result.Data = list;
                    result.Code = "1";
                }
            }
            return result;
        }
    }
}
