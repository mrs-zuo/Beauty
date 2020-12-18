using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetBusinessDetail_Model
    {
        public string Name { get; set; }    
        public string Summary { get; set; }
        public string Contact { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Address { get; set; }
        public string Zip { get; set; }
        public string Web { get; set; }
        public string BusinessHours { get; set; }
        public int ImageCount { get; set; }
        public List<string> ImageURL { get; set; }
        public decimal Longitude { get; set; }
        public decimal Latitude { get; set; }
        public int AccountCount { get; set; }
    }
}
