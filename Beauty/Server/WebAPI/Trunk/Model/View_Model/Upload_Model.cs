using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class Upload_Model
    {
        public int Status { set; get; }
        public string  FileUrl { set; get; }
        public int Height { set; get; }
        public int Width { set; get; }
        // 1:图片 2: EXCEL
        public int Type { set; get; }
    }

    [Serializable]
    public class UploadImage_Model
    {
        public int ThumbnailFlg { set; get; }
        public string ThumbFileUrl { set; get; }
        public string TempFileUrl { set; get; }
    }
}
