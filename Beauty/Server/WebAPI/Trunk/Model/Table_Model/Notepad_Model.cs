using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Notepad_Model
    {
        public Notepad_Model()
        { }
        #region Model
        /// <summary>
        /// 
        /// </summary>
        public int CompanyID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int BranchID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int ID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int CustomerID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string TagIDs
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Content
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public bool Available
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? CreatorID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? CreateTime
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? UpdaterID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? UpdateTime
        {
            set;
            get;
        }


        #endregion Model
    }
}
