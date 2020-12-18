using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class ProductList_Model
    {
        public long ProductCode { get; set; }
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        public decimal UnitPrice { get; set; }
        public int SortID { get; set; }
        public bool New { get; set; }
        public bool Recommended { get; set; }
        public string ThumbnailURL { get; set; }
        public string SearchField { get; set; }
        public string Specification { get; set; }
        public int ProductType { get; set; }
    }

    [Serializable]
    public class ProductListInfo_Model
    {
        public int CategoryID { get; set; }
        public string CategoryName { get; set; }
        public List<ProductList_Model> ProductList { get; set; }
    }
}
