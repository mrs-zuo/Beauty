using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetReportList_Model
    {
        public int ObjectID { get; set; }
        public string ObjectName { get; set; }
        public decimal SalesAmount { get; set; }
        public decimal RechargeAmount { get; set; }
    }

    [Serializable]
    public class GetReportBasic_Model
    {
        public decimal ServiceRevenueAll { get; set; }
        public decimal ServiceRevenueCash { get; set; }
        public decimal ServiceRevenueBank { get; set; }
        public decimal ServiceRevenueECard { get; set; }
        public decimal ServiceRevenuePoint { get; set; }
        public decimal ServiceRevenueCoupon { get; set; }
        public decimal ServiceRevenueOther { get; set; }
        public decimal ServiceRevenueWeChat { get; set; }
        public decimal ServiceRevenueAlipay { get; set; }
        public decimal ServiceRevenueLoan { get; set; }
        public decimal ServiceRevenueThird { get; set; }

        public decimal CommodityRevenueAll { get; set; }
        public decimal CommodityRevenueCash { get; set; }
        public decimal CommodityRevenueBank { get; set; }
        public decimal CommodityRevenueECard { get; set; }
        public decimal CommodityRevenuePoint { get; set; }
        public decimal CommodityRevenueCoupon { get; set; }
        public decimal CommodityRevenueOther { get; set; }
        public decimal CommodityRevenueWeChat { get; set; }
        public decimal CommodityRevenueAlipay { get; set; }
        public decimal CommodityRevenueLoan { get; set; }
        public decimal CommodityRevenueThird { get; set; }


        public int ServiceTimes { get; set; }
        public decimal ServiceRevenue { get; set; }
        public int CommodityTimes { get; set; }
        public decimal CommodityRevenue { get; set; }
        public decimal ECardAll { get; set; }
        public decimal ECardCash { get; set; }
        public decimal ECardBankCard { get; set; }
        public int TreatmentTimes { get; set; }
        public int NewAddCustomer { get; set; }
        public int NewAddEffectCustomer { get; set; }
        public int OldEffectCustomer { get; set; }

        //报表新增
        public decimal SalesAllIncome { get; set; }
        public decimal SalesCashIncome { get; set; }
        public decimal SalesBankIncome { get; set; }
        public decimal SalesWeChatIncome { get; set; }
        public decimal SalesAlipayIncome { get; set; }
        public decimal SalesRevenueLoan { get; set; }
        public decimal SalesRevenueThird { get; set; }


        public decimal ECardBalance { get; set; }
        public decimal ECardSales { get; set; }
        public decimal ECardConsume { get; set; }

        public decimal ServiceAchievementAll { get; set; }
        public decimal ServiceAchievementDesigned { get; set; }
        public decimal ServiceAchievementNotDesigned { get; set; }


        public decimal TreatmentTimesAll { get; set; }
        public decimal TreatmentTimesDesigned { get; set; }
        public decimal TreatmentTimesNotDesigned { get; set; }

        public int ServiceCustomerCountAll { get; set; }
        public int ServiceCustomerCountMale { get; set; }
        public int ServiceCustomerCountFemale { get; set; }
        public int ServiceCustomerCountUnknow { get; set; }


        public decimal EcardSalesAllIncome { get; set; }
        public decimal EcardSalesCashIncome { get; set; }
        public decimal EcardSalesBankIncome { get; set; }
        public decimal EcardWeChatIncome { get; set; }
        public decimal EcardAlipayIncome { get; set; }
    }

    [Serializable]
    public class GetReportDetail_Model
    {
        public GetProductReportDetail_Model ProductDetail { set; get; }
        public List<GetBalanceReportDetail_Model> BalanceDetail { set; get; }
        public List<GetTreatmentTimesDetail_Model> TreatmentTimesDetail { set; get; }
    }

    [Serializable]
    public class ReportBranchCount_Model
    {
        public int BranchID { set; get; }
        public string BranchName { set; get; }
        public int AllCustomerCount { set; get; }
        public Decimal AllECardRechargeCount { set; get; }
        public Decimal AllECardBalanceCount { set; get; }
        public int AllBranchCount { set; get; }
        public int AllAccountCount { set; get; }
        public int EffectOrderCount { set; get; }
        public int CompleteOrderCount { set; get; }
        public Decimal OrderTotalSalePrice { set; get; }
        public int ClientCount { set; get; }
        public int WeChatCount { set; get; }
        public int AllCardCount { get; set; }
    }

    [Serializable]
    public class SalesIncome_Model
    {
        public int Type { set; get; }
        public decimal Amount { set; get; }
        public int OrderID { set; get; }
        public int FinishCnt { set; get; }

    }



    [Serializable]
    public class CardInfo_Model
    {
        public int CardID { set; get; }
        public string CardName { set; get; }
        public int AllCount { set; get; }
        public int HaveBalance { set; get; }
        public decimal Balance { set; get; }

    }

    [Serializable]
    public class GetBalanceReportDetail_Model
    {
        public string CustomerName { set; get; }
        public decimal RechargeAmount { set; get; }
        public decimal PayAmount { set; get; }
        public decimal BalanceAmount { set; get; }
    }

    [Serializable]
    public class GetProductReportDetail_Model
    {
        public decimal AllTotalPrice { get; set; }
        public double AllQuantity { get; set; }
        //业绩比例总额
        public decimal AllTotalProfitRatePrice { get; set; }
        public List<GetProductDetailList_Model> ProductDetail { get; set; }
    }

    [Serializable]
    public class GetProductDetailList_Model
    {
        public string ObjectName { get; set; }
        public double Quantity { get; set; }
        public string QuantityScale { get; set; }
        public decimal TotalPrice { get; set; }
        public string TotalPriceScale { get; set; }
        //总金额
        public decimal Total { get; set; }
        //总数量
        public double TotalQuantity { get; set; }
        //业绩额
        public decimal TotalProfitRatePrice { get; set; }
        //总业绩额
        public decimal AllDetailTotalPrice { get; set; }
    }

    [Serializable]
    public class GetTreatmentTimesDetail_Model {
        public string ObjectName { get; set; }
        public int Total { get; set; }
        public int IsDesignated { get; set; }
    }

    [Serializable]
    public class GetBranchBusinessDetail_Model
    {
        public int CustomerCount { get; set; }
        public int TGExecutingCount { get; set; }
        public int TGFinishedCount { get; set; }
        public int TGUnConfirmed { get; set; }
        public int ServiceOrder { get; set; }
        public int CommodityOrder { get; set; }
        public decimal SalesAmount { get; set; }
        public int ServiceCancelCount { get; set; }
        public int CommodityCancelCount { get; set; }
    }

    [Serializable]
    public class GetAllKindsTG{
        public int TGCount { get; set; }
        public int TGStatus { get; set; }
    }
}
