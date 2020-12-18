using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class AddTaskOperation_Model
    {
        /// <summary>
        /// 指定的操作人
        /// </summary>
        public int ExecutorID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public long ID { get; set; }

        /// <summary>
        /// 任务类型 1:服务预约 2:订单回访 3:联系任务 
        /// </summary>
        public int TaskType { get; set; }

        /// <summary>
        /// 任务名（任务类型为服务预约时，填服务名）
        /// </summary>
        public string TaskName { get; set; }

        /// <summary>
        /// 任务描述
        /// </summary>
        public string TaskDescription { get; set; }

        /// <summary>
        /// 任务备注
        /// </summary>
        public string Remark { get; set; }

        /// <summary>
        /// 任务结果
        /// </summary>
        public string TaskResult { get; set; }

        /// <summary>
        /// 任务状态：1：待确认 2：已确认 3：已执行 4：已取消
        /// </summary>
        public int TaskStatus { get; set; }

        /// <summary>
        /// 任务预定开始时间（服务预约时就是到店时间）
        /// </summary>
        public DateTime TaskScdlStartTime { get; set; }

        /// <summary>
        /// 任务预定结束时间（服务预约时就是到店时间）
        /// </summary>
        public DateTime TaskScdlEndTime { get; set; }

        /// <summary>
        /// 任务类型为服务预约时 1:存单 2：新单
        /// </summary>
        public int ReservedOrderType { get; set; }

        /// <summary>
        /// 订单ID 任务类型为服务预约时，存单的情况下记录
        /// </summary>
        public int ReservedOrderID { get; set; }

        /// <summary>
        /// 订单服务ID 任务类型为服务预约时，存单的情况下记录
        /// </summary>
        public int ReservedOrderServiceID { get; set; }

        /// <summary>
        /// 服务Code 任务类型为服务预约时，存单，新单时均设定
        /// </summary>
        public long ReservedServiceCode { get; set; }

        /// <summary>
        /// 订单ID 预约开单时，TG完成生成订单回访时设定
        /// </summary>
        public int ActedOrderID { get; set; }

        /// <summary>
        /// 订单服务ID 预约开单时，TG完成生成订单回访时设定
        /// </summary>
        public int ActedOrderServiceID { get; set; }


        /// <summary>
        /// TG ID 预约开单时，TG完成生成订单回访时设定
        /// </summary>
        public int ActedTreatGroupID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public int BranchID { get; set; }
        public int CompanyID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public bool IsBusiness { get; set; }
        /// <summary>
        /// 任务发起者区分 1:顾客 2:店内
        /// </summary>
        public int TaskOwnerType { get; set; }

        /// <summary>
        /// 发起者区分为顾客时，任务发起者ID设顾客ID，店内发起时，设员工ID
        /// </summary>
        public int TaskOwnerID { get; set; }

        /// <summary>
        /// 预约确认者ID 服务预约确定的时候设定
        /// </summary>
        public int ReservationConfirmer { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public DateTime ExecuteStartTime { get; set; }
    }
}