using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class StorageDetail_Model
    {
        //门店名称
        public string BranchName { get; set; }
        //公司ID
        public int CompanyID { get; set; }
        //分店ID
        public int BranchID { get; set; }
        //主键
        public int ID { get; set; }
        //商品Code
        public long ProductCode { get; set; }
        //批次番号
        public string BatchNO { get; set; }
        //数量
        public int Quantity { get; set; }
        //有效期
        public DateTime ExpiryDate { get; set; }
        //申请状态
        public int Status { get; set; }
        //操作人ID
        public int OperatorID { get; set; }
        //操作时间
        public DateTime OperateTime { get; set; }
    }
}
