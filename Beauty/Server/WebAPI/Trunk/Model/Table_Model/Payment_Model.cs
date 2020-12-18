using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    /// <summary>
    /// PAYMENT:实体类(属性说明自动提取数据库字段的描述信息)
    /// </summary>
    [Serializable]
    public partial class Payment_Model
    {
        public Payment_Model()
        { }
        /// <summary>
        /// 
        /// </summary>
        public int CompanyID { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public int CustomerID
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public string Password
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public int? BranchID
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public int ID
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public int OrderNumber
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public int IsCompletedFlag
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public decimal TotalPrice
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public bool Available
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public int? CreatorID
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? CreateTime
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public int? UpdaterID
        { set; get; }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? UpdateTime
        { set; get; }

        /// <summary>
        /// 
        /// </summary>
        public string Remark
        { set; get; }

    }
}
