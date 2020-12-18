using BLToolkit.Data;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL.Customer
{
    public class Payment_CDAL
    {
        #region 构造类实例
        public static Payment_CDAL Instance
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
            internal static readonly Payment_CDAL instance = new Payment_CDAL();
        }
        #endregion

        public List<Profit_Model> getProfitListByMasterID(int masterID, int type)
        {
            List<Profit_Model> list = new List<Profit_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T2.Name AS AccountName,T2.UserID As AccountID
                                    FROM    TBL_PROFIT T1 WITH ( NOLOCK )
                                            LEFT JOIN ACCOUNT T2 WITH ( NOLOCK ) ON T1.SlaveID = T2.UserID
                                    WHERE   T1.Type = @Type
                                            AND T1.MasterID = @MasterID ";

                list = db.SetCommand(strSql, db.Parameter("@Type", type, DbType.Int32)
                                           , db.Parameter("@MasterID", masterID, DbType.Int32)).ExecuteList<Profit_Model>();

                return list;
            }
        }
    }
}
