using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;
using WebAPI.DAL;


namespace WebAPI.BLL
{
    public class Image_BLL
    {
        #region 构造类实例
        public static Image_BLL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly Image_BLL instance = new Image_BLL();
        }
        #endregion

        /// <summary>
        /// 获取Business图片
        /// </summary>
        public List<ImageCommon_Model> getBusinessImage(int companyId, int branchId, int photoHeight, int photoWidth)
        {
            return Image_DAL.Instance.getBusinessImage(companyId, branchId, photoHeight, photoWidth);
        }

        /// <summary>
        /// 判断图片是否存在
        /// </summary>
        /// <param name="strImage"></param>
        /// <returns></returns>
        public bool chkImage(string strImage)
        {
            if (File.Exists(strImage))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// 获取Business图片
        /// </summary>
        public List<ImageCommon_Model> getCommodityImage_2_2(int commodityId, int imageType, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getCommodityImage_2_2(commodityId, imageType, imageWidth, imageHeight);
        }

        /// <summary>
        /// 判断上传是否成功
        /// </summary>
        /// <param name="filesStr"></param>
        /// <param name="filePath"></param>
        /// <returns></returns>
        public bool uploadChk(string filesStr, string filePath)
        {
            FileStream files = new FileStream(filePath, FileMode.Open);
            Byte[] fliesByte = new byte[files.Length];
            files.Read(fliesByte, 0, fliesByte.Length);
            files.Close();
            string filesStrLocal = Convert.ToBase64String(fliesByte);
            if (filesStr == filesStrLocal)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public List<string> getServiceImage(int serviceId, int imageType, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getServiceImage(serviceId, imageType, imageWidth, imageHeight);
        }

        public GetServiceEffectImage_Model getServiceEffectImage(int companyId, int treatmentID, long groupNo, string imageSize, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getServiceEffectImage(companyId, treatmentID, groupNo, imageSize, imageWidth, imageHeight);
        }

        public List<AllServiceEffect_Model> GetAllServiceEffectByCustomerID(int customerID, int companyId, string imageSize, int imageWidth, int imageHeight)
        {
            List<AllServiceEffect_Model> list = Image_DAL.Instance.GetAllServiceEffectByCustomerID(customerID, companyId, imageSize, imageWidth, imageHeight);
            return list;
        }

        public bool updateServiceEffectImage(int userId, int companyId, int customerId, int treatmentId, long groupNo, List<AddTreatmentImageOperation_Model> listAdd, List<DeleteTreatmentImageOperation_Model> listDelete)
        {

            DateTime dt = DateTime.Now.ToLocalTime();
            Random random = new Random();
            int randomNumber = random.Next(100000);
            int i = 0;
            if (listAdd != null && listAdd.Count > 0)
            {
                foreach (AddTreatmentImageOperation_Model item in listAdd)
                {
                    item.ImageName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + (randomNumber + i).ToString("d5") + item.ImageFormat;
                    i++;
                }
            }


            if (addServiceEffectFiles(companyId, customerId, treatmentId, groupNo, listAdd) && addCustomerServiceEffectFiles(companyId, customerId, treatmentId, groupNo, listAdd))
            {
                return Image_DAL.Instance.updateServiceEffectImage(userId, companyId, customerId, treatmentId, groupNo, listAdd, listDelete);
            }
            else
            {
                return false;
            }
        }


        public List<PhotoAlbumList_Model> getPhotoAlbumList(int CustomerID, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getPhotoAlbumList(CustomerID, imageWidth, imageHeight);
        }

        public List<PhotoAlbumDetail_Model> getPhotoAlbumDetail(int CustomerID, string CreateDate, string thumbnailSize, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getPhotoAlbumDetail(CustomerID, CreateDate, thumbnailSize, imageWidth, imageHeight);
        }

        /// <summary>
        /// 修改头像
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="userType"></param>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public bool updateUserHeadImage(int userId, int userType, string fileName)
        {
            return Image_DAL.Instance.updateUserHeadImage(userId, userType, fileName);
        }

        /// <summary>
        /// 拼路径，写入文件
        /// </summary>
        public bool addServiceEffectFiles(int companyId,int customerID, int treatmentId, long groupNo, List<AddTreatmentImageOperation_Model> list)
        {
            string url = System.Configuration.ConfigurationManager.AppSettings["ImageServer"]
                + Common.Const.strImage
                + companyId.ToString() + "/"
                + "TreatGroup/" + groupNo.ToString() + "/" + treatmentId.ToString() + "/";

            if (url == null)
            {
                return false;
            }
            if (!Directory.Exists(url))
            {
                Directory.CreateDirectory(url);
            }

            if (list != null && list.Count > 0)
            {
                foreach (AddTreatmentImageOperation_Model item in list)
                {
                    string fileUrl = url + item.ImageName;
                    //string fileUrl2 = url2 + item.ImageName;
                    Byte[] imageByte = Convert.FromBase64String(item.ImageString);
                  
                    using (MemoryStream ms = new MemoryStream(imageByte))
                    { 
                       
                        FileStream fs = new FileStream(fileUrl, FileMode.Create);
                        ms.WriteTo(fs);
                        ms.Close();
                        fs.Close();
                        fs = null;
                    }

                    bool upChk = uploadChk(item.ImageString, fileUrl);
                    if (!upChk)
                    {
                        return false;
                    }

                }
            }
            return true;
        }

        /// <summary>
        /// 拼路径，写入文件
        /// </summary>
        public bool addCustomerServiceEffectFiles(int companyId, int customerID, int treatmentId, long groupNo, List<AddTreatmentImageOperation_Model> list)
        {
            string url = System.Configuration.ConfigurationManager.AppSettings["ImageServer"]
               + Common.Const.strImage
               + companyId.ToString() + "/"
               + "Customer/" + customerID.ToString() + "/BeautyRec/";

            if (url == null)
            {
                return false;
            }
            if (!Directory.Exists(url))
            {
                Directory.CreateDirectory(url);
            }

            if (list != null && list.Count > 0)
            {
                foreach (AddTreatmentImageOperation_Model item in list)
                {
                    string fileUrl = url + item.ImageName;
                    Byte[] imageByte = Convert.FromBase64String(item.ImageString);

                    using (MemoryStream ms = new MemoryStream(imageByte))
                    {
                        FileStream fs = new FileStream(fileUrl, FileMode.Create);
                        ms.WriteTo(fs);
                        ms.Close();
                        fs.Close();
                        fs = null;
                    }
                    bool upChk = uploadChk(item.ImageString, fileUrl);
                    if (!upChk)
                    {
                        return false;
                    }

                }
            }
            return true;
        }

        public bool addUserHeadImage(int companyId, int userId, int userType, string strImageString, string fileUrl)
        {
            Byte[] imageByte = Convert.FromBase64String(strImageString);
            //生成并写入图片
            using (MemoryStream ms = new MemoryStream(imageByte))
            {
                FileStream fs = new FileStream(fileUrl, FileMode.Create);

                ms.WriteTo(fs);
                ms.Close();
                fs.Close();
                fs = null;

                bool upChk = uploadChk(strImageString, fileUrl);
                if (!upChk)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
        }

        #region 后台方法

        /// <summary>
        /// 获取Business图片
        /// </summary>
        public List<ImageCommon_Model> getBusinessImageForWeb(int companyId, int branchId)
        {
            return Image_DAL.Instance.getBusinessImageForWeb(companyId, branchId);
        }


        public bool updateBusinessImage(BusinessImageOperation_Model model)
        {
            bool result = false;
            if (model.AddImage != null)
            {
                if (model.BranchID == 0)
                {
                    result = ImageMove(model.AddImage, 2, model.BranchID, model.CompanyID, false);
                }
                else
                {
                    result = ImageMove(model.AddImage, 7, model.BranchID, model.CompanyID, false);
                }

                if (result)
                {
                    return Image_DAL.Instance.updateBusinessImage(model);
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return Image_DAL.Instance.updateBusinessImage(model);
            }
        }


        public bool updateCommodityImage(ProductImageOperation_Model model, bool idChange)
        {
            string strDelImage = "";
            if (model.DeleteImage != null && model.DeleteImage.Count > 0)
            {
                for (int i = 0; i < model.DeleteImage.Count; i++)
                {
                    if (i != 0)
                    {
                        strDelImage += ",";
                    }
                    strDelImage += model.DeleteImage[i];
                }
            }
            if (idChange)
            {
                model.NoDeleteImageList = Image_DAL.Instance.getCommodityImageSameCodeNoDelete(strDelImage, model.OriginalCommodityID, !string.IsNullOrEmpty(model.AddThumbnail));
            }

            bool res = Image_DAL.Instance.updateCommodityImage(model);
            if (res)
            {
                ImageMove(model.AddBigImage, 6, model.CommodityCode, model.CompanyID, false);
                if (!string.IsNullOrEmpty(model.AddThumbnail))
                {
                    List<string> listThum = new List<string>();
                    listThum.Add(model.AddThumbnail);
                    ImageMove(listThum, 6, model.CommodityCode, model.CompanyID, true);
                }
            }
            return true;
        }
        public bool updateServiceImage(ProductImageOperation_Model model, bool idChange)
        {
            string strDelImage = "";
            if (model.DeleteImage != null && model.DeleteImage.Count > 0)
            {
                for (int i = 0; i < model.DeleteImage.Count; i++)
                {
                    if (i != 0)
                    {
                        strDelImage += ",";
                    }
                    strDelImage += model.DeleteImage[i];
                }
            }
            if (idChange)
            {
                model.NoDeleteServiceImageList = Image_DAL.Instance.getServiceImageSameCodeNoDelete(strDelImage, model.OriginalServiceID, !string.IsNullOrEmpty(model.AddThumbnail));
            }

            bool res = Image_DAL.Instance.updateServiceImage(model);
            if (res)
            {
                ImageMove(model.AddBigImage, 8, model.ServiceCode, model.CompanyID, false);
                if (!string.IsNullOrEmpty(model.AddThumbnail))
                {
                    List<string> listThum = new List<string>();
                    listThum.Add(model.AddThumbnail);
                    ImageMove(listThum, 8, model.ServiceCode, model.CompanyID, true);
                }
            }
            return true;
        }


        //把上传的临时文件移动到正确的目录下面
        public bool ImageMove(List<string> fileName, int objectType, long objectId, int companyId, bool thunmbFlg)
        {
            try
            {
                string destPath = CommonUtility.updateUrlSpell(companyId, objectType, objectId);
                if (!Directory.Exists(destPath))
                {
                    Directory.CreateDirectory(destPath);
                }

                if (fileName != null && fileName.Count > 0)
                {
                    for (int i = 0; i < fileName.Count; i++)
                    {

                        string tempFile = Const.uploadServer + "/" + Const.strImage + "temp/" + fileName[i];
                        string destFile = destPath + "\\" + fileName[i];
                        FileInfo fi = new FileInfo(tempFile);
                        fi.MoveTo(destFile);
                        if (thunmbFlg)
                        {
                            string tempFileO = Const.uploadServer + "/" + Const.strImage + "temp/T" + fileName[i].Substring(1);
                            string destFileO = destPath + "\\T" + fileName[i].Substring(1);
                            FileInfo fiO = new FileInfo(tempFileO);
                            fiO.MoveTo(destFileO);
                        }
                    }
                }
                return true;
            }
            catch(Exception ex)
            {
                HS.Framework.Common.LogUtil.Error(ex);
                return false;
            }
        }

        public bool ImageMove(string fileName, int objectType, long objectId, int companyId)
        {
            try
            {
                string destPath = CommonUtility.updateUrlSpell(companyId, objectType, objectId);
                if (!Directory.Exists(destPath))
                {
                    Directory.CreateDirectory(destPath);
                }

                string tempFile = Const.uploadServer + "/" + Const.strImage + "temp/" + fileName;
                string destFile = destPath + "\\" + fileName;
                FileInfo fi = new FileInfo(tempFile);
                fi.MoveTo(destFile);
                //string tempFileO = Const.uploadServer + "/" + Const.strImage + "temp/T" + fileName.Substring(1);
                //string destFileO = destPath + "\\T" + fileName.Substring(1);
                //FileInfo fiO = new FileInfo(tempFileO);
                //fiO.MoveTo(destFileO);
                return true;
            }
            catch(Exception ex)
            {
                HS.Framework.Common.LogUtil.Error(ex);
                return false;
            }
        }



        public bool ImageMove(string fileName, int objectType, string objectId, int companyId)
        {
            try
            {
                string destPath = CommonUtility.updateUrlSpell(companyId, objectType, objectId);
                if (!Directory.Exists(destPath))
                {
                    Directory.CreateDirectory(destPath);
                }

                string tempFile = Const.uploadServer + "/" + Const.strImage + "temp/" + fileName;
                string destFile = destPath + "\\" + fileName;
                FileInfo fi = new FileInfo(tempFile);
                fi.MoveTo(destFile);
                //string tempFileO = Const.uploadServer + "/" + Const.strImage + "temp/T" + fileName.Substring(1);
                //string destFileO = destPath + "\\T" + fileName.Substring(1);
                //FileInfo fiO = new FileInfo(tempFileO);
                //fiO.MoveTo(destFileO);
                return true;
            }
            catch(Exception ex)
            {
                HS.Framework.Common.LogUtil.Error(ex);
                return false;
            }
        }
        #endregion

       
    }
}
