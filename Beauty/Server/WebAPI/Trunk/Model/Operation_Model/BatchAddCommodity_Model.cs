using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class BatchAddCommodity_Model
    {
        public DataTable dt { get; set; }
        public Commodity_Model mCommodity { get; set; }
        public Dictionary<int, string> dcCategoryName { get; set; }
        public Dictionary<int, string> dcDiscountName { get; set; }
    }
}
