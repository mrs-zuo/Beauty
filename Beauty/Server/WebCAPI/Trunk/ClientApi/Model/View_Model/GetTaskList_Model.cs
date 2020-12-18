using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetTaskListRes_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public List<GetTaskList_Model> TaskList { get; set; }
    }

    [Serializable]
    public class GetTaskList_Model
    {
        public int ResponsiblePersonID { get; set; }
        public string ResponsiblePersonName { get; set; }
        public string BranchPhone { get; set; }
        public string BranchName { get; set; }
        public string CustomerName { get; set; }
        public string TaskName { get; set; }
        public long TaskID { get; set; }
        public int TaskStatus { get; set; }
        public int TaskType { get; set; }
        public DateTime TaskScdlStartTime { get; set; }
        public bool ResponsiblePersonChat_Use { get; set; }
        public string HeadImageURL { get; set; }
    }

    [Serializable]
    public class TaskSimpleList_Model
    {
        public long TaskID { get; set; }
        public string ResponsiblePersonName { get; set; }
        public DateTime TaskScdlStartTime { get; set; }
    }
}
