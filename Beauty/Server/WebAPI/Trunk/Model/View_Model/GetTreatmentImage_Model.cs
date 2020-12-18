using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
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
        public int OrderObjectID { get; set; }
        public List<ImageTotalEffect_Model> ImageEffect { set; get; }
    }

    [Serializable]
    public class ImageEffect_Model
    {
        public int TreatmentImageID { set; get; }
        public string ThumbnailURL { set; get; }
        public string OriginalImageURL { set; get; }
    }

    [Serializable]
    public class ImageTotalEffect_Model
    {
        public int TreatmentImageID { set; get; }
        public int ImageType { get; set; }
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
    public class PhotoAlbumList_Model
    {
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
}
