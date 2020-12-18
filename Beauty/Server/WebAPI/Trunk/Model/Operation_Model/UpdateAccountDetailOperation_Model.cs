using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class UpdateAccountDetailOperation_Model
    {
        public string LoginMobile{get;set;}
        public int UpdaterID{get;set;}
        public string HeadImageFile{get;set;}
        public DateTime UpdateTime{get;set;}
        public int AccountID { get; set; }
        public string FileName { get; set; }
        public int HeadFlag { get; set; }
        public int ImageType { get; set; }
        public string ImageString { get; set; }
        public int ImageWidth { get; set; }
        public int ImageHeight { get; set; }
    }
}
