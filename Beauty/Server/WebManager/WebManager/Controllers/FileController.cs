using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebAPI.Common;
using WebManager.Controllers.Base;


namespace WebManager.Controllers
{
    public class FileController : BaseController
    {
        //
        // GET: /Image/

        public string FileUpload()
        {          
            Upload_Model model = new Upload_Model();
            try
            {
                HttpFileCollection hfc = System.Web.HttpContext.Current.Request.Files;
                System.Web.HttpContext.Current.Response.ContentType = "text/html";
                string bx = "";
                if (hfc.Count > 0)
                {
                    if (hfc[0].ContentLength >= 4194304)
                    {

                    }
                    BinaryReader r = new BinaryReader(hfc[0].InputStream);
                    byte buffer = r.ReadByte();
                    bx = buffer.ToString();
                    buffer = r.ReadByte();
                    bx += buffer.ToString();

                    if (bx == "255216" || bx == "7173" || bx == "6677" || bx == "13780")
                    {
                        //图片处理
                        string imgPath = hfc[0].FileName;
                        string suffix = "";
                        if (bx == "255216")
                        {
                            suffix = ".jpg";
                        }
                        else if (bx == "7173")
                        {
                            suffix = ".gif";
                        }
                        else if (bx == "6677")
                        {
                            suffix = ".bmp";
                        }
                        else if (bx == "13780")
                        {
                            suffix = ".png";
                        }
                        Image originalImage = Image.FromStream(hfc[0].InputStream);

                        if (!Directory.Exists(Const.uploadServer + "/" + Const.strImage + "temp/"))
                        {
                            Directory.CreateDirectory(Const.uploadServer + "/" + Const.strImage + "temp/");
                        }
                        string fileName = getFileName(suffix);
                        string tempFileUrl = Const.uploadServer + "/" + Const.strImage + "temp/" + fileName;
                        hfc[0].SaveAs(tempFileUrl);

                        int width = 0;
                        int height = 0;
                        if (originalImage.Width >= originalImage.Height)
                        {
                            width = 500;
                            height = 500 * originalImage.Height / originalImage.Width;
                        }
                        else
                        {
                            height = 500;
                            width = 500 * originalImage.Width / originalImage.Height;
                        }

                        originalImage.Dispose();
                        string filePath = "http://" + Const.server + "/GetThumbnail.aspx?fn=temp/" + fileName + "&biFlg=1";

                        model.Status = 1;
                        model.FileUrl = filePath;
                        model.Height = height;
                        model.Width = width;
                        model.Type = 1;
                        return JsonConvert.SerializeObject(model);
                      //  return Json(model);
                    }
                    else if (bx == "208207")
                    {
                        //EXCEL文件
                        return null;
                    }
                    else
                    {

                        return null;
                    }
                }
                else
                {
                    return null;
                }
            }
            catch (Exception ex) {
                model.Status = 0;
                return JsonConvert.SerializeObject(model);
                //return Json(model);
            }
        }

        private string getFileName(string suffix)
        {
            DateTime dt = DateTime.Now.ToLocalTime();
            string randomNumber = "";
            int seed = Guid.NewGuid().GetHashCode();
            Random random = new Random(seed);
            for (int j = 0; j < 5; j++)
            {
                randomNumber += random.Next(10).ToString();
            }
            string fileName = "O" + string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber +  suffix;
            return fileName;
        }


        public ActionResult CropImage(CropImageOperation_Model model)
        {
            ObjectResult<UploadImage_Model> res = new ObjectResult<UploadImage_Model>();
            try
            {
                string imgPath = model.FileUrl.Replace("&amp;", "&");

                imgPath = imgPath.Substring(imgPath.IndexOf("temp/"), imgPath.IndexOf("&bi") - imgPath.IndexOf("temp/"));
                string imgSrc = Const.uploadServer +  Const.strImage +  imgPath;
                string fileName = "C" + imgPath.Substring(imgPath.IndexOf("temp/") + 6);

                string suffix = imgSrc.Substring(imgSrc.LastIndexOf(".") + 1).ToLower();/*获取后缀名并转为小写： jpg*/

                Image originalImage = Image.FromFile(imgSrc);

                if (!Directory.Exists(Const.uploadServer + "/" + Const.strImage + "temp/"))
                {
                    Directory.CreateDirectory(Const.uploadServer + "/" + Const.strImage + "temp/");
                }

                int width = originalImage.Width;
                int height = originalImage.Height;

                int CropWidthStart = model.WidthStart * width / model.WidthShow;
                int CropHeightStart = model.HeightStart * height / model.HeightShow;
                int CropWidthEnd = (model.WidthEnd + model.WidthStart) * width / model.WidthShow - CropWidthStart;
                int CropHeightEnd = ( model.HeightEnd + model.HeightStart) * height / model.HeightShow - CropHeightStart;



                int flg = 1;

                Bitmap bm = new Bitmap(CropWidthEnd, CropHeightEnd);

                Graphics g = Graphics.FromImage(bm);
                // 指定高质量、低速度呈现。
                g.SmoothingMode = SmoothingMode.HighQuality;
                // 指定高质量的双三次插值法。执行预筛选以确保高质量的收缩。此模式可产生质量最高的转换图像。
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;

                g.Clear(Color.White);
                g.DrawImage(originalImage, new Rectangle(0, 0, CropWidthEnd, CropHeightEnd), CropWidthStart, CropHeightStart, CropWidthEnd, CropHeightEnd, GraphicsUnit.Pixel);

                string tempFileUrl = Const.uploadServer + "/" + Const.strImage + "temp/" + fileName;
                string ThumbFileUrl = Const.uploadServer + "/" + Const.strImage + "temp/T" + fileName;
                string filePath = "http://" + Const.server + "/GetThumbnail.aspx?fn=temp/" + fileName + "&biFlg=1";
                string ThumbFilePath = "http://" + Const.server + "/GetThumbnail.aspx?fn=temp/T" + fileName + "&biFlg=1";
                if (model.ThumbnailFlg == 1)
                {
                    bm.Save(ThumbFileUrl);
                }
                else if (model.ThumbnailFlg == 2)
                {
                    bm.Save(tempFileUrl);
                }
                else if (model.ThumbnailFlg == 3)
                {
                    bm.Save(ThumbFileUrl);
                    bm.Save(tempFileUrl);
                }

                bm.Dispose();
                g.Dispose();
                originalImage.Dispose();

                UploadImage_Model data = new UploadImage_Model();
                data.ThumbnailFlg = model.ThumbnailFlg;
                data.ThumbFileUrl = ThumbFilePath;
                data.TempFileUrl = filePath;
                res.Data = data;
                return Json(res);
            }
            catch (Exception ex)
            {
                return Json(res);
            }
        }



        public string WXFileUpload()
        {
            Upload_Model model = new Upload_Model();
            try
            {
                HttpFileCollection hfc = System.Web.HttpContext.Current.Request.Files;
                System.Web.HttpContext.Current.Response.ContentType = "text/html";
                string bx = "";
                if (hfc.Count > 0)
                {
                    if (hfc[0].ContentLength >= 4194304)
                    {

                    }
                    BinaryReader r = new BinaryReader(hfc[0].InputStream);
                    byte buffer = r.ReadByte();
                    bx = buffer.ToString();
                    buffer = r.ReadByte();
                    bx += buffer.ToString();

                    if (bx == "255216" || bx == "7173" || bx == "6677" || bx == "13780")
                    {
                        //图片处理
                        string imgPath = hfc[0].FileName;
                        Image originalImage = Image.FromStream(hfc[0].InputStream);

                        if (!Directory.Exists(Const.uploadServer + "/" + Const.strImage +  this.CompanyID  +"/Company/"))
                        {
                            Directory.CreateDirectory(Const.uploadServer + "/" + Const.strImage + this.CompanyID + "/Company/");
                        }
                        string fileName = "Logo_wxmp.png";
                        string tempFileUrl = Const.uploadServer + "/" + Const.strImage + this.CompanyID + "/Company/" + fileName;
                        hfc[0].SaveAs(tempFileUrl);

                        model.Status = 1;
                        return JsonConvert.SerializeObject(model);
                        //  return Json(model);
                    }
                    else
                    {

                        return null;
                    }
                }
                else
                {
                    return null;
                }
            }
            catch (Exception ex)
            {
                model.Status = 0;
                return JsonConvert.SerializeObject(model);
                //return Json(model);
            }
        }


    }
}
