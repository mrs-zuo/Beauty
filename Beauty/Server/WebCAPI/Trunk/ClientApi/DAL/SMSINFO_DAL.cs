using BLToolkit.Data;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
{
   public class SMSINFO_DAL
    {
        #region 构造类实例
        public static SMSINFO_DAL Instance
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
            internal static readonly SMSINFO_DAL instance = new SMSINFO_DAL();
        }
        #endregion
        /// <summary>
        /// 获取公司发短信详情
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <returns></returns>
        public Model.View_Model.GetVSMSINFO_Model getVSMSINFODetail(int companyID)
        {
            GetVSMSINFO_Model model = new GetVSMSINFO_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = "  SELECT T1.COMPANYID,T1.SMSNum,T1.SentNum,T1.StartDate,T1.EndDate FROM [vsmsinfo] T1 WITH(NOLOCK) WHERE COMPANYID=@CompanyID  ";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<GetVSMSINFO_Model>();
                return model;
            }
        }

        /// <summary>
        /// 保存短信发送履历信息
        /// </summary>
        /// <param name="addSMSHIS_Model"></param>
        /// <returns></returns>
        public bool addSMSHIS_Model(AddSMSHIS_Model addSMSHIS_Model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"INSERT INTO [SMSHIS](COMPANYID,RcvNumber,SendTime,SMSContent,CreatorID,CreateTime,UpdaterID,UpdateTime)
                                        VALUES(@CompanyID,@RcvNumber,@SendTime,@SMSContent,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime)";
                int res = db.SetCommand(strSql, db.Parameter("@CompanyID", addSMSHIS_Model.COMPANYID, DbType.Int32),
                                                db.Parameter("@RcvNumber", addSMSHIS_Model.RcvNumber, DbType.String),
                                                db.Parameter("@SendTime", addSMSHIS_Model.SendTime, DbType.DateTime),
                                                db.Parameter("@SMSContent", addSMSHIS_Model.SMSContent, DbType.String),
                                                db.Parameter("@CreatorID", addSMSHIS_Model.CreatorID, DbType.Int32),
                                                db.Parameter("@CreateTime", addSMSHIS_Model.CreateTime, DbType.DateTime),
                                                db.Parameter("@UpdaterID", null, DbType.Int32),
                                                db.Parameter("@UpdateTime", null, DbType.DateTime)
                                                ).ExecuteNonQuery();
                if (res <= 0)
                {
                    return false;
                }
                return true;

            }
        }
    }
}
