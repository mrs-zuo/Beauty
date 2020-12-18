using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class UserHeadImageOperation_Model
    {
        public string ImageString { set; get; }
        public string ImageType { set; get; }
        public int ImageWidth { set; get; }
        public int ImageHeight { set; get; }
    }

    [Serializable]
    public class CropImageOperation_Model
    {
        public string FileUrl { set; get; }
        public int WidthStart { set; get; }
        public int WidthEnd { set; get; }
        public int HeightStart { set; get; }
        public int HeightEnd { set; get; }
        public int WidthShow { set; get; }
        public int HeightShow { set; get; }
        public int ThumbnailFlg { set; get; }
    }

    [Serializable]
    public class BusinessImageOperation_Model
    {
        public int CompanyID { set; get; }
        public int BranchID { set; get; }
        public int UserID { set; get; }
        public List<string> AddImage { set; get; }
        public List<string> DeleteImage { set; get; }
        public DateTime OperationTime { set; get; }
    }

    [Serializable]
    public class ProductImageOperation_Model
    {
        public int CompanyID { set; get; }
        public int BranchID { set; get; }
        public int UserID { set; get; }
        public int OriginalCommodityID { set; get; }
        public int OriginalServiceID { set; get; }
        public int CommodityID { set; get; }
        public int ServiceID { set; get; }
        public long CommodityCode { set; get; }
        public long ServiceCode { set; get; }
        public List<NoDeleteCommodityImage_Model> NoDeleteImageList { set; get; }
        public List<NoDeleteServiceImage_Model> NoDeleteServiceImageList { set; get; }
        public string AddThumbnail { get; set; }
        public List<string> AddBigImage { set; get; }
        public List<string> DeleteImage { set; get; }
        public DateTime OperationTime { set; get; }
    }

    [Serializable]
    public class NoDeleteCommodityImage_Model
    {
        public long CommodityCode { set; get; }
        public int CommodityID { set; get; }
        public int ImageType { set; get; }
        public string FileName { set; get; }
    }
    [Serializable]
    public class NoDeleteServiceImage_Model
    {
        public long ServiceCode { set; get; }
        public int ServiceID { set; get; }
        public int ImageType { set; get; }
        public string FileName { set; get; }
    }
}
