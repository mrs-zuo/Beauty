using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Web;

namespace GetThumbnail
{
    public partial class GetThumbnail : System.Web.UI.Page
    {
        #region Web 窗体设计器生成的代码
        override protected void OnInit(EventArgs e)
        {
            //
            // CODEGEN: 该调用是 ASP.NET Web 窗体设计器所必需的。
            //
            InitializeComponent();
            base.OnInit(e);
        }

        /**/
        /// <summary>
        /// 设计器支持所需的方法 - 不要使用代码编辑器修改
        /// 此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.Load += new System.EventHandler(this.Page_Load);
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Clear();
            //参数说明
            //fn：文件名
            //th：指定输出的图片高度
            //tw：指定输出的图片宽度
            //bg：填充的背景颜色
            //cq：图片压缩质量(按百分比)
            //biFlg：按原图尺寸输出的标识

            //string originalFileName = Server.MapPath(Request.QueryString["fn"]);
            //图片文件
            string originalFileName = System.Configuration.ConfigurationSettings.AppSettings["ImageServer"]
                                    + System.Configuration.ConfigurationSettings.AppSettings["ImageFolder"]
                                    + Request.QueryString["fn"].ToString();
            int thumbnailWidth = Convert.ToInt16(Request.QueryString["tw"]);
            int thumbnailHeight = Convert.ToInt16(Request.QueryString["th"]);
            long CompressionQuality = Convert.ToInt16(Request.QueryString["cq"]);
            string bgColorString = Convert.ToString(Request.QueryString["bg"]);
            int bigImageFlg = Convert.ToInt16(Request.QueryString["biFlg"]);

            if (File.Exists(originalFileName))
            {
                ColorConverter cv = new ColorConverter();
                Color bgColor = (Color)cv.ConvertFromString(string.IsNullOrEmpty(bgColorString) ? "#FFF" : "#" + bgColorString);

                if (CompressionQuality == 0)
                {
                    //默认压缩质量
                    CompressionQuality = 80;
                }

                Image img = Image.FromFile(originalFileName);
                ImageFormat thisFormat = img.RawFormat;
                Size newSize = new Size();
                if (bigImageFlg == 1 || thumbnailWidth == 0 || thumbnailHeight == 0)
                {
                    //按原尺寸输出
                    newSize.Width = img.Width;
                    newSize.Height = img.Height;
                    thumbnailWidth = img.Width;
                    thumbnailHeight = img.Height;
                }
                else
                {
                    //按指定的尺寸输出
                    newSize = this.GetNewSize(thumbnailWidth, thumbnailHeight, img.Width, img.Height);
                }
                Bitmap outBmp = new Bitmap(thumbnailWidth, thumbnailHeight);

                Graphics g = Graphics.FromImage(outBmp);

                //设置画布的描绘质量
                g.CompositingQuality = CompositingQuality.HighQuality;
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                //g.Clear(Color.FromArgb(255, 249, 255, 240));
                g.Clear(bgColor);
                g.DrawImage(img, new Rectangle((thumbnailWidth - newSize.Width) / 2,
                                                (thumbnailHeight - newSize.Height) / 2,
                                                newSize.Width, newSize.Height),
                                                0, 0, img.Width, img.Height, GraphicsUnit.Pixel);
                //g.DrawImage(img, new Rectangle(0,
                //                               0,
                //                               thumbnailWidth, thumbnailHeight),
                //                               0, 0, img.Width, img.Height, GraphicsUnit.Pixel);
                g.Dispose();

                if (thisFormat.Equals(ImageFormat.Gif))
                {
                    Response.ContentType = "image/gif";
                }
                else if (thisFormat.Equals(ImageFormat.Png))
                {
                    Response.ContentType = "image/png";
                }
                else
                {
                    Response.ContentType = "image/jpeg";
                }

                //设置压缩质量
                EncoderParameters encoderParams = new EncoderParameters();
                //EncoderParameter encoderParam = new EncoderParameter(Encoder.Quality, new long[] { 85 });
                EncoderParameter encoderParam = new EncoderParameter(Encoder.Quality, new long[] { CompressionQuality });
                encoderParams.Param[0] = encoderParam;

                //获得包含有关内置图像编码解码器的信息的ImageCodecInfo 对象。
                ImageCodecInfo[] arrayICI = ImageCodecInfo.GetImageEncoders();
                ImageCodecInfo jpegICI = null;

                for (int fwd = 0; fwd < arrayICI.Length; fwd++)
                {
                    if (arrayICI[fwd].FormatDescription.Equals("JPEG"))
                    {
                        jpegICI = arrayICI[fwd];
                        break;
                    }
                }
                if (jpegICI != null)
                {
                    outBmp.Save(Response.OutputStream, jpegICI, encoderParams);
                }
                //else
                //{
                //    outBmp.Save(Response.OutputStream, thisFormat);
                //}
                outBmp.Dispose();
                img.Dispose();
            }
        }

        System.Drawing.Size GetNewSize(int maxWidth, int maxHeight, int width, int height)
        {
            //变换图片尺寸
            Double w = 0.0;
            Double h = 0.0;
            Double sw = Convert.ToDouble(width);
            Double sh = Convert.ToDouble(height);
            Double mw = Convert.ToDouble(maxWidth);
            Double mh = Convert.ToDouble(maxHeight);

            if (sw > mw && sh > mh)
            {

                w = mw;
                h = w * sh / sw;
                if (h > mh)
                {
                    h = mh;
                    w = h * sw / sh;
                }
            }
            else if (sw > mw)
            {
                w = mw;
                h = w * sh / sw;
            }
            else if (sh > mh)
            {
                h = mh;
                w = h * sw / sh;
            }
            else
            {
                if (sw < sh)
                {
                    h = mh;
                    w = h * sw / sh;
                }
                else
                {
                    w = mw;
                    h = w * sh / sw;
                }
            }
            return new Size(Convert.ToInt32(w), Convert.ToInt32(h));
        }

    }
}


