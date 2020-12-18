using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class CustomerBenefit_Model
    {
        public string PolicyID { set; get; }
        public int ValidDays { set; get; }

    }
}
