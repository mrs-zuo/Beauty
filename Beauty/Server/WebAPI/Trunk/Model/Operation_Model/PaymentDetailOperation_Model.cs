using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class PaymentDetailOperation_Model
    {
        public int ID
        {
            set;
            get;
        }
        public decimal TotalPrice
        {
            set;
            get;
        }
        public decimal BankCard
        {
            set;
            get;
        }
        public decimal Others
        {
            set;
            get;
        }
        public decimal Cash
        {
            set;
            get;
        }
        public decimal Ecard
        {
            set;
            get;
        }
    }
}
