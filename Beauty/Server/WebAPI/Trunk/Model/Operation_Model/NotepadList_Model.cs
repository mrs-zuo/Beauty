using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class GetNotepadListByAccount_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public List<NotepadList_Model> NotepadList { get; set; }
    }

    [Serializable]
    public class NotepadList_Model
    {
        public int ID { get; set; }
        public string TagName { get; set; }
        public DateTime? CreateTime { get; set; }
        public string Content { get; set; }
        public string CreatorName { get; set; }
        public string CustomerName { get; set; }
    }
}
