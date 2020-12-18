using ClientAPI.DAL;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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

        public List<PhotoAlbumList_Model> getPhotoAlbumList(int CustomerID, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getPhotoAlbumList(CustomerID, imageWidth, imageHeight);
        }

        public List<PhotoAlbumDetail_Model> getPhotoAlbumDetail(int CustomerID, string CreateDate, string thumbnailSize, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getPhotoAlbumDetail(CustomerID, CreateDate, thumbnailSize, imageWidth, imageHeight);
        }

        public List<ImageCommon_Model> getCommodityImage_2_2(int commodityId, int imageType, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getCommodityImage_2_2(commodityId, imageType, imageWidth, imageHeight);
        }



        public List<string> getServiceImage(int serviceId, int imageType, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getServiceImage(serviceId, imageType, imageWidth, imageHeight);
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
        public bool updateUserHeadImage(int userId, int userType, string fileName)
        {
            return Image_DAL.Instance.updateUserHeadImage(userId, userType, fileName);
        }

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

        public GetTreatmentImage_Model getTreatmentImage(int companyId, int treatmentID, string imageSize, int imageWidth, int imageHeight)
        {
            return Image_DAL.Instance.getTreatmentImage(companyId, treatmentID, imageSize, imageWidth, imageHeight);
        }
        public List<ImageCommon_Model> getBusinessImage(int companyId, int branchId, int photoHeight, int photoWidth)
        {
            return Image_DAL.Instance.getBusinessImage(companyId, branchId, photoHeight, photoWidth);
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

        public bool updateServiceEffectImage(int userId, int companyId, int customerId, int treatmentId, long groupNo, string Comment, List<AddTreatmentImageOperation_Model> listAdd, List<DeleteTreatmentImageOperation_Model> listDelete)
        {
            DateTime dt = DateTime.Now.ToLocalTime();
            Random random = new Random();
            int randomNumber = random.Next(100000);
            int i = 0;
            if (listAdd != null && listAdd.Count > 0)
            {
                foreach (AddTreatmentImageOperation_Model item in listAdd)
                {
                    item.ImageName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + (randomNumber + i).ToString("d5") +  item.ImageFormat;
                    i++;
                }
            }


            if (addServiceEffectFiles(companyId, customerId, treatmentId, groupNo, listAdd))
            {
                return Image_DAL.Instance.updateServiceEffectImage(userId, companyId, customerId, treatmentId, groupNo, Comment, listAdd, listDelete);
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// 拼路径，写入文件
        /// </summary>
        public bool addServiceEffectFiles(int companyId, int customerID, int treatmentId, long groupNo, List<AddTreatmentImageOperation_Model> list)
        {
            string url2 = System.Configuration.ConfigurationManager.AppSettings["ImageServer"]
               + WebAPI.Common.Const.strImage
               + companyId.ToString() + "/"
               + "Customer/" + customerID.ToString() + "/BeautyRec/";

            if (url2 == null)
            {
                return false;
            }

            if (!Directory.Exists(url2))
            {
                Directory.CreateDirectory(url2);
            }

            if (list != null && list.Count > 0)
            {
                foreach (AddTreatmentImageOperation_Model item in list)
                {
                    string fileUrl2 = url2 + item.ImageName;
                    Byte[] imageByte = Convert.FromBase64String(item.ImageString);

                    using (MemoryStream ms = new MemoryStream(imageByte))
                    {
                        FileStream fs = new FileStream(fileUrl2, FileMode.Create);
                        ms.WriteTo(fs);

                        ms.Close();
                        fs.Close();
                        fs = null;
                    }
                    bool upChk = uploadChk(item.ImageString, fileUrl2);
                    if (!upChk)
                    {
                        return false;
                    }

                }
            }
            return true;
        }

        public List<AllCustomerRecPic> getCustomerRecPic(int companyId, int customerID, int year, int imageWidth, int imageHeight)
        {
            List<AllCustomerRecPic> list = Image_DAL.Instance.getCustomerRecPic(companyId, customerID, year, imageWidth, imageHeight);
            return list;
        }

        public CustomerRecPicDetail getCustomerServicePic(int companyId, int customerID, long serviceCode,int serviceYear, int imageWidth, int imageHeight)
        {
            CustomerRecPicDetail model = Image_DAL.Instance.getCustomerServicePic(companyId, customerID, serviceCode,serviceYear, imageWidth, imageHeight);
            return model;
        }

        public CustomerTGPic getCustomerTGPic(int companyId, int customerID, long groupNo, int imageWidth, int imageHeight)
        {
            CustomerTGPic model = Image_DAL.Instance.getCustomerTGPic(companyId, customerID, groupNo, imageWidth, imageHeight);
            return model;
        }

        public CustomerTGPicList getCustomerPicDetail(int companyId, int customerID, string recordImgID, int imageWidth, int imageHeight)
        {
            CustomerTGPicList model = Image_DAL.Instance.getCustomerPicDetail(companyId, customerID, recordImgID, imageWidth, imageHeight);
            return model;
        }

        public bool editCustomerPic(int companyId, int customerID, string recordImgID, long groupNo, string imageTag, int type = 1)
        {
            bool res = Image_DAL.Instance.editCustomerPic(companyId, customerID, recordImgID, groupNo, imageTag, type);
            return res;
        }
    }
}
