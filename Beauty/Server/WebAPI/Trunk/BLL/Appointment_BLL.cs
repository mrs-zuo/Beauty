using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Appointment_BLL
    {
        #region 构造类实例
        public static Appointment_BLL Instance
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
            internal static readonly Appointment_BLL instance = new Appointment_BLL();
        }
        #endregion

        /// <summary>
        /// 获取门店的预约信息列表
        /// </summary>
        /// <param name="Appointment_Search_Model"></param>
        /// <returns></returns>
        public List<Appointment_Model> GetAppointmentList(Appointment_Search_Model model)
        {
            return Appointment_DAL.Instance.GetAppointmentList(model);//
        }
    }
}
