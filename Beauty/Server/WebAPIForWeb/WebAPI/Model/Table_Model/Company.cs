using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{    
    [Serializable]
    public class Company
    {
        public string Name{get;set;}        
        public DateTime CreateTime { get; set; }
    }
}
