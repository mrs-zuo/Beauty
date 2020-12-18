using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public partial class Category_Model
    {
        public int CompanyID
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int? BranchID
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int? ParentID
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int ID
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string CategoryName
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool Available
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int? CreatorID
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public DateTime CreateTime
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int? UpdaterID
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public DateTime UpdateTime
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int Type
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string ImageFile
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string Describe
        { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int Level
        { get; set; }

        public int Total
        { get; set; }
    }
}
