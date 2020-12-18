using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Task_BLL
    {
        #region 构造类实例
        public static Task_BLL Instance
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
            internal static readonly Task_BLL instance = new Task_BLL();
        }
        #endregion

        public List<GetTaskList_Model> GetScheduleList(GetTaskListOperation_Model operationModel, out int recordCount)
        {
            List<GetTaskList_Model> list = Task_DAL.Instance.GetScheduleList(operationModel, out recordCount);
            return list;
        }

        public int GetScheduleCountByCustomerID(int companyID, int customerID)
        {
            int count = Task_DAL.Instance.GetScheduleCountByCustomerID(companyID, customerID);
            return count;
        }

        public int AddSchedule(AddTaskOperation_Model addModel)
        {
            int res = Task_DAL.Instance.AddSchedule(addModel);
            return res;
        }

        public GetScheduleDetail_Model GetScheduleDetail(int companyID, long taskID)
        {
            GetScheduleDetail_Model model = Task_DAL.Instance.GetScheduleDetail(companyID, taskID);
            return model;
        }

        public int ConfirmSchedule(AddTaskOperation_Model model)
        {
            int res = Task_DAL.Instance.ConfirmSchedule(model);
            return res;
        }

        public int CancelSchedule(int companyID, long taskID, int accountID, DateTime dt)
        {
            int res = Task_DAL.Instance.CancelSchedule(companyID, taskID, accountID, dt);
            return res;
        }

        public int EditVisitTask(AddTaskOperation_Model model)
        {
            int res = Task_DAL.Instance.EditVisitTask(model);
            return res;
        }

        public List<TaskSimpleList_Model> GetScheduleListByOrderID(int companyID, int orderID, int orderObjectID)
        {
            List<TaskSimpleList_Model> list = Task_DAL.Instance.GetScheduleListByOrderID(companyID, orderID, orderObjectID);
            return list;
        }
    }
}
