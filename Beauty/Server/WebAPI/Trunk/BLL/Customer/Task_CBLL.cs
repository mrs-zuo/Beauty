using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL.Customer;

namespace WebAPI.BLL.Customer
{
    public class Task_CBLL
    {
        #region 构造类实例
        public static Task_CBLL Instance
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
            internal static readonly Task_CBLL instance = new Task_CBLL();
        }
        #endregion

        public List<GetTaskList_Model> GetScheduleList(GetTaskListOperation_Model operationModel, out int recordCount)
        {
            List<GetTaskList_Model> list = Task_CDAL.Instance.GetScheduleList(operationModel, out recordCount);
            return list;
        }

        public int AddSchedule(AddTaskOperation_Model addModel)
        {
            int res = Task_CDAL.Instance.AddSchedule(addModel);
            return res;
        }

        public GetScheduleDetail_Model GetScheduleDetail(int companyID, long taskID)
        {
            GetScheduleDetail_Model model = Task_CDAL.Instance.GetScheduleDetail(companyID, taskID);
            return model;
        }

        public int CancelSchedule(int companyID, long taskID, int accountID, DateTime dt)
        {
            int res = Task_CDAL.Instance.CancelSchedule(companyID, taskID, accountID, dt);
            return res;
        }

        public List<TaskSimpleList_Model> GetScheduleListByOrderID(int companyID, int orderID, int orderObjectID)
        {
            List<TaskSimpleList_Model> list = Task_CDAL.Instance.GetScheduleListByOrderID(companyID, orderID, orderObjectID);
            return list;
        }
    }
}
