using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetNetTradeQRCode_Model
    {
        public string QRCodeUrl { get; set; }
        public string ProductName { get; set; }
        public string NetTradeNo { get; set; }
    }
}
