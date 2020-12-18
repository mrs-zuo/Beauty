using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class ServiceEffectImageOperation_Model
    {
        public ServiceEffectImageOperation_Model()
        {
            this.ImageHeight = 160;
            this.ImageWidth = 160;
        }
        public int TreatmentID { set; get; }
        public long GroupNo { get; set; }
        public List<AddTreatmentImageOperation_Model> AddImage { set; get; }
        public List<DeleteTreatmentImageOperation_Model> DeleteImage { set; get; }
        public int CustomerID { set; get; }
        public string CreateDate { set; get; }

        public int ImageHeight { set; get; }
        public int ImageWidth { set; get; }
        public int ImageThumbHeight { set; get; }
        public int ImageThumbWidth { set; get; }
    }

    [Serializable]
    public class AddTreatmentImageOperation_Model
    {
        public bool ImageType { set; get; }
        public string ImageString { set; get; }
        public string ImageFormat { set; get; }
        public string ImageName { set; get; }
    }


    [Serializable]
    public class DeleteTreatmentImageOperation_Model
    {
        public int ImageID { set; get; }
    }

   

}
