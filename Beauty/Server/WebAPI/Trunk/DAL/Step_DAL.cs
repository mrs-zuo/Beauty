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
    public class Step_DAL
    {
        #region 构造类实例
        public static Step_DAL Instance
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
            internal static readonly Step_DAL instance = new Step_DAL();
        }
        #endregion

        /// <summary>
        /// 新增销售步骤
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddStep(Step_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSPsql = "GetSerialNo";

                long StepCode = db.SetSpCommand(strSPsql, db.Parameter("@TableName", "Step", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                if (StepCode > 0)
                {
                    model.StepCode = StepCode;
                }
                else { return false; }

                string strsql = @"insert into STEP(CompanyID,StepNumber,StepContent,CrteatorID,CreateTime,StepName,StepCode)
                                  values (@CompanyID,@StepNumber,@StepContent,@CrteatorID,@CreateTime,@StepName,@StepCode)";
                return db.SetCommand(strsql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                    db.Parameter("@StepNumber", model.StepNumber, DbType.Int32),
                    db.Parameter("@StepContent", model.StepContent, DbType.String,50),
                    db.Parameter("@CrteatorID", model.CrteatorID, DbType.Int32),
                    db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                    db.Parameter("@StepName", model.StepName, DbType.String),
                    db.Parameter("@StepCode", model.StepCode, DbType.Int64)).ExecuteNonQuery() > 0;
            }
        }

        /// <summary>
        /// 修改销售步骤
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateStep(Step_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strsql = @"insert into STEP(CompanyID,StepNumber,StepContent,CrteatorID,CreateTime,StepName,StepCode)
                                  values (@CompanyID,@StepNumber,@StepContent,@CrteatorID,@CreateTime,@StepName,@StepCode)";
                return db.SetCommand(strsql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                    db.Parameter("@StepNumber", model.StepNumber, DbType.Int32),
                    db.Parameter("@StepContent", model.StepContent, DbType.String, 50),
                    db.Parameter("@CrteatorID", model.CrteatorID, DbType.Int32),
                    db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                    db.Parameter("@StepName", model.StepName, DbType.String),
                    db.Parameter("@StepCode", model.StepCode, DbType.Int64)).ExecuteNonQuery() > 0;
            }
        }

        /// <summary>
        /// 获取商机列表
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <returns></returns>
        public List<Step_Model> GetStepList(int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                string strsql = @"SELECT StepName,ID FROM dbo.STEP WHERE id IN(
                                SELECT MAX(ID) FROM dbo.STEP WHERE CompanyID=@CompanyID GROUP BY stepCode)";
                return db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteList<Step_Model>();
            }
        }

        /// <summary>
        /// 获取商机详情
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="ID"></param>
        /// <returns></returns>
        public Step_Model GetStepByID(int CompanyID, int ID)
        {
            using (DbManager db = new DbManager())
            {
                string strsql = @"SELECT StepName,StepContent,ID,StepCode FROM dbo.STEP WHERE CompanyID=@CompanyID AND ID=@ID";
                return db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32), db.Parameter("@ID", ID, DbType.Int32)).ExecuteObject<Step_Model>();
            }
        }


    }
}
