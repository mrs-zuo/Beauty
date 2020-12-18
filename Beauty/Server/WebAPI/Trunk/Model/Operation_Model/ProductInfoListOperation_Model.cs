using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class ProductInfoListOperation_Model
    {
        public int CustomerID { get; set; }
        public int CardId { get; set; }
        public List<ProductCode_Model> ProductCode { get; set; }
        public int BranchID { get; set; }
    }

    [Serializable]
    public class ProductCode_Model
    {
        public long Code
        {
            get;
            set;
        }
        public int ProductType
        {
            set;
            get;
        }
    }
}
