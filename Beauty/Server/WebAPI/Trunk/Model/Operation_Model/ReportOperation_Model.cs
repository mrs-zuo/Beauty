using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class ReportOperation_Model
    {
        public int AccountID { get; set; }
        /// <summary>
        /// 0:日 1：月 2：季 3：年 4:自定义
        /// </summary>
        public int CycleType { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        /// <summary>
        /// 0:个人 1：分店 2：公司 3:分组
        /// </summary>
        public int ObjectType { get; set; }
        /// <summary>
        /// 0:按CustomerName名取  1：按商品或服务名取
        /// </summary>
        public int OrderType { get; set; }
        /// <summary>
        /// 0:服务 1：商品
        /// </summary>
        public int ProductType { get; set; }
        /// <summary>
        /// 抽取类别
        /// 
        /// </summary>
        public int ExtractItemType { get; set; }
        /// <summary>
        /// 排序 1:次数 2:销售额
        /// </summary>
        public int SortType { get; set; }
        /// <summary>
        /// 分类
        /// </summary>
        public int StatementCategoryID { get; set; }
    }

    [Serializable]
    public class ReportDownloadOperation_Model
    {
        public int Type { get; set; }
        public DateTime BeginDay { get; set; }
        public DateTime EndDay { get; set; }
        public int StatementCategoryID { get; set; }
    }

    [Serializable]
    public class ReportCookie_ListModel
    {
        public List<ReportCookie_Model> list { get; set; }
    }


    [Serializable]
    public class ReportCookie_Model
    {
        public int Type { set; get; }
        public int Status { set; get; }
        public string fileName { set; get; }
        public string DonwloadUrl { set; get; }
        public int New { set; get; }
    }
}
