using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetTreatmentImage_Model
    {
        public List<ImageBeforeTreatment_Model> ImageBeforeTreatment { set; get; }
        public List<ImageAfterTreatment_Model> ImageAfterTreatment { set; get; }
    }


    [Serializable]
    public class ImageBeforeTreatment_Model
    {
        public int TreatmentImageID { set; get; }
        public string ThumbnailURL { set; get; }
        public string OriginalImageURL { set; get; }
    }


    [Serializable]
    public class ImageAfterTreatment_Model
    {
        public int TreatmentImageID { set; get; }
        public string ThumbnailURL { set; get; }
        public string OriginalImageURL { set; get; }
    }

    [Serializable]
    public class PhotoAlbumList_Model {
        public DateTime CreateTime { set; get; }
        public string ImageURL { set; get; }
    }

    [Serializable]
    public class PhotoAlbumDetail_Model
    {
        public int ImageID { set; get; }
        public string ThumbnailURL { set; get; }
        public string OriginalImageURL { set; get; }
    }

    [Serializable]
    public class GetServiceEffectImage_Model
    {
        public List<ImageEffect_Model> ImageBeforeTreatment { set; get; }
        public List<ImageEffect_Model> ImageAfterTreatment { set; get; }
        public List<TMinTG_Model> TMList { get; set; }
    }

    [Serializable]
    public class AllServiceEffect_Model
    {
        public long GroupNo { get; set; }
        public DateTime TGStartTime { get; set; }
        public string ServiceName { get; set; }
        public int OrderID { get; set; }
        public List<ImageEffect_Model> ImageBeforeTreatment { set; get; }
        public List<ImageEffect_Model> ImageAfterTreatment { set; get; }
    }

    [Serializable]
    public class ImageEffect_Model
    {
        public int TreatmentImageID { set; get; }
        public string ThumbnailURL { set; get; }
        public string OriginalImageURL { set; get; }
    }

    [Serializable]
    public class TMinTG_Model
    {
        public int TreatmentID { get; set; }
        public string SubServiceName { get; set; }
    }

    [Serializable]
    public class AllCustomerRecPic
    {
        public string ServiceName { get; set; }
        public long ServiceCode { get; set; }
        public List<string> ImageURL { get; set; }
    }

    [Serializable]
    public class CustomerRecPicDetail
    {
        public string ServiceName { set; get; }
        public long ServiceCode { get; set; }
        public List<ServicePicList> ServicePicList { get; set; }
    }

    [Serializable]
    public class ServicePicList
    {
        public DateTime TGStartTime { set; get; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public string Comments { get; set; }
        public Int64 GroupNo { get; set; }
        public List<string> ImageURL { get; set; }
    }

    [Serializable]
    public class CustomerTGPic
    {
        public string ServiceName { set; get; }
        public long ServiceCode { get; set; }
        public DateTime TGStartTime { set; get; }
        public string Comments { get; set; }
        public string BranchName { get; set; }
        public int BranchID { get; set; }
        public long GroupNo { get; set; }
        public int ReviewCount { get; set; }
        public List<CustomerTGPicList> TGPicList { get; set; }
    }

    [Serializable]
    public class CustomerTGPicList
    {
        public string RecordImgID { get; set; }
        public string ImageTag { get; set; }
        public string ImageURL { get; set; }
    }
}
