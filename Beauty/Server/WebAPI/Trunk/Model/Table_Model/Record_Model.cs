using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public partial class Record_Model
    {
        public Record_Model()
        { }
        #region Model
        public int ID
        {
            set ;
            get ; 
        }
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
        //public int AccountID
        //{
        //    set { _accountid = value; }
        //    get { return _accountid; }
        //}
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
        public DateTime? RecordTime
        {
            set;
            get;
        }
        /// <summary>
        /// 类型。0:初诊、1:复诊、2:回诊。
        /// </summary>
        //public int Type
        //{
        //    set { _type = value; }
        //    get { return _type; }
        //}
        /// <summary>
        /// 
        /// </summary>
        public string Problem
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Suggestion
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? OrderID
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
        /// <summary>
        /// 
        /// </summary>
        public bool IsVisible
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
        #endregion Model

    }
}
