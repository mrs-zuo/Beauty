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
    public class Appointment_DAL
    {
        #region 构造类实例
        public static Appointment_DAL Instance
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
            internal static readonly Appointment_DAL instance = new Appointment_DAL();
        }
        #endregion
        /// <summary>
        /// 获取门店的预约信息列表
        /// </summary>
        /// <param name="Appointment_Search_Model"></param>
        /// <returns></returns>
        public List<Appointment_Model> GetAppointmentList(Appointment_Search_Model model)
        {
            using (DbManager db = new DbManager())
            {
                //已经选择的
                string strSqlRelat = @"SELECT ReserveTime,CustomerName,ServiceName,StaffName,Remark,TaskStatus 
                                              FROM fgetReserveList (@CompanyID,@BranchID,@ReserveDate,@inCustomerName,@inServiceName,@inStaffName,@inTaskStatus_1,@inTaskStatus_2,@inTaskStatus_3) 
                                              ";
                strSqlRelat += " order by ReserveTime, CustomerName ASC ";
                List<Appointment_Model> listRelat = new List<Appointment_Model>();
                listRelat = db.SetCommand(strSqlRelat, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                     , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                     , db.Parameter("@ReserveDate", model.ReserveDate, DbType.String)
                                                     , db.Parameter("@inCustomerName", model.inCustomerName == null ? "": model.inCustomerName.Trim(), DbType.String)
                                                     , db.Parameter("@inServiceName", model.inServiceName == null ? "" : model.inServiceName.Trim(), DbType.String)
                                                     , db.Parameter("@inStaffName", model.inStaffName == null ? "" : model.inStaffName.Trim(), DbType.String)
                                                     , db.Parameter("@inTaskStatus_1", model.inTaskStatus_1, DbType.Int32)
                                                     , db.Parameter("@inTaskStatus_2", model.inTaskStatus_2, DbType.Int32)
                                                     , db.Parameter("@inTaskStatus_3", model.inTaskStatus_3, DbType.Int32)
                                                     ).ExecuteList<Appointment_Model>();
                return listRelat;
            }
        }
    }

   
}
