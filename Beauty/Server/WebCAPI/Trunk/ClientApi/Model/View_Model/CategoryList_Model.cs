using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CategoryList_Model
    {
        public int CategoryID { get; set; }
        public int ParentID { get; set; }
        public string CategoryName { get; set; }
        //public string CategoryNameForEdit { get; set; }
        public int NextCategoryCount { get; set; }
        public int ProductCount { get; set; }
    }

    [Serializable]
    public class CategoryInfo_Model
    {
        public int CategoryID { get; set; }
        public string CategoryName { get; set; }
        public List<CategoryList_Model> CategoryList { get; set; }
    }

}
