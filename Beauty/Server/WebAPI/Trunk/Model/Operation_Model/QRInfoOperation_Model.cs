using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class QRInfoOperation_Model
    {
        public string QRCode { set; get; }
        public int AccountID { set; get; }
        /// <summary>
        /// 二维码类型: 000：用户 001:商品 002:服务
        /// </summary>
        public int Type { set; get; }
        /// <summary>
        /// 公司编号
        /// </summary>
        public string CompanyCode { set; get; }
        /// <summary>
        /// 用户ID 或商品服务的Code
        /// </summary>
        public int Code { set; get; }
        /// <summary>
        /// 二维码尺寸
        /// </summary>
        public int QRCodeSize { set; get; }
        public int BranchID { set; get; }
    }
}
