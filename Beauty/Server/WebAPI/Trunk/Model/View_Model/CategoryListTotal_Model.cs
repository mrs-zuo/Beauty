using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CategoryListTotal_Model
    {
        public List<CategoryList_Model> CategoryList { get; set; }

        public int ProductCount { get; set; }
    }
}
