using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class UtilityOperation_Model
    {
        public UtilityOperation_Model()
        {
            this.ImageHeight = 160;
            this.ImageWidth = 160;
        }

        public string BenefitID { get; set; }
        public long LongID { get; set; }
        public long GroupNo { get; set; }
        public int OrderObjectID { get; set; }
        public string CardCode { get; set; }
        public int ChangeType { get; set; }
        public int CardType { get; set; }
        public bool isOnlyMoneyCard { get; set; }
        public bool isShowAll { get; set; }
        public int PaymentMode { get; set; }
        public int Type { get; set; }
        public int ID { get; set; }
        public int OrderID { get; set; }
        public int UpdaterID { get; set; }
        public int PaymentID { get; set; }
        public int AccountID { get; set; }
        public List<int> AccountIDList { get; set; }
        public List<Slave_Model> ProfitList { get; set; }
        public int CustomerID { get; set; }
        public int CreatorID { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int UserID { get; set; }
        public int UserType { get; set; }
        public int ProductType { get; set; }
        public string TagIDs { get; set; }
        public long ProductCode { get; set; }
        public int ImageWidth { get; set; }
        public int ImageHeight { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public long ServiceCode { get; set; }
        public long CommodityCode { get; set; }
        public string strSearch { get; set; }
        public string GUID { get; set; }
        public string BrowseHistoryCodes { get; set; }
        public decimal TotalSalePrice { get; set; }
        public int ScheduleID { get; set; }
        public int TreatmentID { get; set; }
        public DateTime Time { get; set; }
        public int ExecutorID { get; set; }
        public DateTime ScheduleTime { get; set; }
        public int ResponsiblePersonID { get; set; }
        public int SalesID { get; set; }
        public string Remark { get; set; }
        public bool IsComplete { get; set; }
        public int Status { get; set; }
        public DateTime ExpirationTime { get; set; }
        public bool IsAddUp { get; set; }
        public bool IsDesignated { get; set; }
        public string OrderIDList { get; set; }
        public int OpportunityID { get; set; }
        public int ProgressID { get; set; }
        public int CategoryID { get; set; }
        public string LevelID { get; set; }
        public bool IsBusiness { get; set; }
        public int Flag { get; set; }
        public DateTime Date { get; set; }
        public string IDs { get; set; }
        public int Available { get; set; }
        public int RecordID { get; set; }
        public int ObjectType { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public string DiscountName { get; set; }
        public string CategoryName { get; set; }
        public string SubserviceName { get; set; }
        public string Advanced { get; set; }
        public string OrderCode { get; set; }
        public string PaymentCode { get; set; }
        public string BalanceCode { get; set; }
        public string TreatmentCode { get; set; }
        public bool TreatmentListFlag { get; set; }
        public string UserCardNo { get; set; }
        public bool SelectTreatment { get; set; }
        public string NetTradeNo { get; set; }
        public string FileName { get; set; }
        public int SourceType { get; set; }

        public int FavoriteID { get; set; }
        public string LoginMobile { get; set; }
        public int FilterByTimeFlag { get; set; }
        public string InputSearch { get; set; }
        public string Prama { get; set; }

        public List<int> listOrderID { get; set; }
        public int CommodityID { get; set; }
        public long SubServiceCode { get; set; }
        public int DiscountID { get; set; }
        public bool IsToday { get; set; }
        public int DeleteType { get; set; }


        public int ServicePIC { get; set; }

        public string DeliveryCode { get; set; }
        public string PromotionCode { get; set; }
        public int RegistFrom { get; set; }
        public int SupplierID { get; set; }

        public int FirstVisitType { get; set; }//0 全部  1  当日上门  2  输入具体日期
        public string FirstVisitDateTime { get; set; }
        public int EffectiveCustomerType { get; set; }// 0 全部  1 有效  2 无效
        public bool PageFlg { get; set; }//分页标记
        public string CustomerName { get; set; }
        public string CustomerTel { get; set; }
        public string SearchDateTime { get; set; }//起始查询时间(分页时解决传统分页数据变更时查询数据差异问题)
    }

    public class BrowseHistoryOperation_Model
    {
        public long CommodityCode { get; set; }
        public long ServiceCode { get; set; }
    }

    public class HtmlPartial_Model
    {
        public int Type { get; set; }
        public int ID { get; set; }
        public string Url { get; set; }
        public string Code { get; set; }
    }
}
