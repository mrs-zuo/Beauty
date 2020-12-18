using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class ImageCommon_Model
    {
        public int ImageID { get; set; }
        public string FileUrl { get; set; }
        public string FileName { get; set; }


        public int ObjectType
        {
            get;
            set;
        }
        /// <summary>
        /// 
        /// </summary>
        public int ObjectID
        {
            get;
            set;
        }
        /// <summary>
        /// 分类。0:Head(头像)、1:Introduction(介绍)、2:Before(治疗前)、3:After(治疗后)。
        /// </summary>
        public int Category
        {
            get;
            set;
        }
        /// <summary>
        /// 
        /// </summary>
        public bool Available
        {
            get;
            set;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? CreatorID
        {
            get;
            set;
        }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? CreateTime
        {
            get;
            set;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? UpdaterID
        {
            get;
            set;
        }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? UpdateTime
        {
            get;
            set;
        }
    }
}
