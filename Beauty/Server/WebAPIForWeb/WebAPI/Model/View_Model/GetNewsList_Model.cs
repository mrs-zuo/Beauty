using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    public class GetNewsList_Model
    {
        public int NoticeID { get; set; }
        public string NoticeTitle { get; set; }
        public string NoticeContent { get; set; }
        public DateTime CreateTime { get; set; }
    }
}
