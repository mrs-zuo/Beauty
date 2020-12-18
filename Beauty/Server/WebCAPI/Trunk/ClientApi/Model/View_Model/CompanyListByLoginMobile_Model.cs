using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CompanyListByLoginMobile_Model
    {
        public int UserID{get;set;}
        public string Name{get;set;}
        public int CompanyID{get;set;}
        public string CompanyAbbreviation { get; set; }

    }
}
