using BLToolkit.Data;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class SMSInfo_DAL
    {
        #region 构造类实例
        public static SMSInfo_DAL Instance
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
            internal static readonly SMSInfo_DAL instance = new SMSInfo_DAL();
        }
        #endregion


        /// <summary>
        /// 获取公司可否发送短信，无记录时添加一条记录
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <param name="RcvNumber">接受方号码</param>
        /// <param name="SendProgram">发送短信的程序名等监察信息</param>
        /// <param name="UserID">发送方的用户ID</param>
        /// <returns>0：可发短信，0以外：不可发短信</returns>
        public int getSMSInfo(int CompanyID, string RcvNumber, string SendProgram, int UserID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"pGetSMSInfo";
                int result = db.SetSpCommand(strSql
                , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                , db.Parameter("@RcvNumber", RcvNumber, DbType.String)
                , db.Parameter("@SendProgram", SendProgram, DbType.String)
                , db.Parameter("@UserID", UserID, DbType.Int32)).ExecuteScalar<int>();

                return result;
            }
        }


        /// <summary>
        /// 记录短信，并将公司已发送短信数量加1
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <param name="BranchID">门店ID</param>
        /// <param name="RcvNumber">接受方号码</param>
        /// <param name="SMSContent">短信内容</param>
        /// <param name="SendProgram">发送短信的程序名</param>
        /// <param name="UserID">发送方的用户ID</param>
        /// <returns></returns>
        public void addSMSHis(int CompanyID, int BranchID, string RcvNumber, string SMSContent, string SendProgram, int UserID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"pAddSMSHis";
                int result = db.SetSpCommand(strSql
                , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                , db.Parameter("@BranchID", BranchID, DbType.Int32)
                , db.Parameter("@RcvNumber", RcvNumber, DbType.String)
                , db.Parameter("@SMSContent", SMSContent, DbType.String)
                , db.Parameter("@SendProgram", SendProgram, DbType.String)
                , db.Parameter("@UserID", UserID, DbType.Int32)).ExecuteNonQuery();
            }
        }



        /// <summary>
        /// 取得可发送短信数量及已发送数量
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <param name="BranchID">门店ID</param>
        /// <returns></returns>
        public GetSMSNum_Model getSMSNum(int CompanyID, int BranchID)
        {
            using (DbManager db = new DbManager())
            {
                GetSMSNum_Model result = new GetSMSNum_Model();

                // 总的可发送件数和已发送件数
                string strSql1 = @"
                    select top 1
                        a.SMSNum as SMSNum,
                        a.SMSSent as SMSSent
                    from
                        SMSINFO a
                    where a.CompanyID = @CompanyID";
                result = db.SetCommand(strSql1, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteObject<GetSMSNum_Model>();

                // 各门店的已发送件数
                List<SMSNumList_Model> list = new List<SMSNumList_Model>();
                string strSql2 = @"
                    select
                        a.BranchName,
                        isnull(b.TotalSent, 0) as SentNum
                    from
                        BRANCH a
                        left join (
                            select 
                                s.BranchID,
                                count(1) as TotalSent
                            from
                                SMSHIS s
                            where s.CompanyID = @CompanyID
                              and (@BranchID = 0 or s.BranchID = @BranchID)
                            group by s.BranchID) b on b.BranchID = a.ID
                    where a.CompanyID = @CompanyID
                      and (@BranchID = 0 or a.ID = @BranchID)
                    order by a.ID";
                list = db.SetCommand(strSql2
                , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteList<SMSNumList_Model>();

                result.SMSNumList = list;
                return result;
            }
        }
    }
}
