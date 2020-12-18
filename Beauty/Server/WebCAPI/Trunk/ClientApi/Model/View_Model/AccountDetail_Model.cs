using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class AccountDetail_Model
    {
        public string Name {get;set;}
        public string Department {get;set;}
        public string Title {get;set;}
        public string Code {get;set;}
        public string Introduction {get;set;}
        public string Expert {get;set;}
        public string Mobile {get;set;}
        public bool Chat_Use {get;set;}
        public string HeadImageURL {get;set;}
    }
}
