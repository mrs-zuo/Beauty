using Microsoft.International.Converters.PinYinConverter;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace WebAPI.Common
{
    public class CommonUtility
    {

        public static string getPinYin(string str)
        {
            string strWholeSpell = getWholeSpell(str);
            string strfirstSpell = getFirstSpell(str);
            if (!string.IsNullOrWhiteSpace(strfirstSpell) && strfirstSpell != "|")
            {
                return strWholeSpell + "," + strfirstSpell;
            }
            else
            {
                return strfirstSpell;
            }
        }

        public static string getWholeSpell(string str)
        {
            StringBuilder strChinese = new StringBuilder();
            List<string> listStr = new List<string>();
            List<string> list = new List<string>();
            char[] chs;
            int rows = str.Length > 5 ? 5 : str.Length;
            for (int i = 0; i < rows; i++)
            {
                char CharStr = Convert.ToChar(str.Substring(i, 1).ToString());
                if (ChineseChar.IsValidChar(CharStr))
                {
                    List<string> tempList = new List<string>();
                    ChineseChar CC = new ChineseChar(CharStr);
                    //将该汉字转化为拼音集合
                    ReadOnlyCollection<string> roc = CC.Pinyins;
                    //获取集合中第一个数据即为该汉字的拼音
                    for (int mCnt = 0; mCnt < roc.Count; mCnt++)
                    {
                        if (roc[mCnt] != null)
                        {
                            chs = roc[mCnt].ToLower().ToCharArray();
                            StringBuilder strPinyin = new StringBuilder();
                            //将该汉字的拼音首字母追加到可变字符串中
                            for (int j = 0; j < chs.Length - 1; j++)
                            {
                                strPinyin.Append(chs[j]);
                            }

                            if (tempList.Count == 0)
                            {
                                tempList.Add(strPinyin.ToString());
                            }
                            else
                            {
                                if (!tempList.Contains(chs[0].ToString()))
                                {
                                    tempList.Add(chs[0].ToString());
                                }
                            }
                        }
                    }
                    if (list.Count == 0)
                    {
                        list = tempList;
                    }
                    else
                    {
                        list = getChinese(list, tempList);
                    }
                }
                else
                {
                    List<string> tempList = new List<string>();
                    if (Char.IsDigit(CharStr) || Char.IsLetter(CharStr))
                        tempList.Add(CharStr.ToString());

                    if (list.Count == 0)
                    {
                        list = tempList;
                    }
                    else
                    {
                        if (tempList.Count != 0)
                            list = getChinese(list, tempList);
                    }
                }
            }

            list = list.Distinct().ToList<string>();
            int n = list.Count > 5 ? 5 : list.Count;

            for (int i = 0; i < n; i++)
            {
                if (i > 0)
                {
                    strChinese.Append("|");
                }
                strChinese.Append(list[i]);
            }
            return strChinese.ToString();
        }


        public static string getFirstSpell(string str)
        {
            StringBuilder strChineseFirst = new StringBuilder();
            List<string> list = new List<string>();
            char[] chs;
            int rows = str.Length > 5 ? 5 : str.Length;
            for (int i = 0; i < rows; i++)
            {
                char CharStr = Convert.ToChar(str.Substring(i, 1).ToString());
                if (ChineseChar.IsValidChar(CharStr))
                {
                    List<string> tempList = new List<string>();
                    ChineseChar CC = new ChineseChar(CharStr);
                    //将该汉字转化为拼音集合
                    ReadOnlyCollection<string> roc = CC.Pinyins;
                    //获取集合中第一个数据即为该汉字的拼音
                    for (int mCnt = 0; mCnt < roc.Count; mCnt++)
                    {
                        if (roc[mCnt] != null)
                        {
                            chs = roc[mCnt].ToLower().ToCharArray();
                            //将该汉字的拼音首字母追加到可变字符串中

                            if (tempList.Count == 0)
                            {
                                tempList.Add(chs[0].ToString());
                            }
                            else
                            {
                                if (!tempList.Contains(chs[0].ToString()))
                                {
                                    tempList.Add(chs[0].ToString());
                                }
                            }
                        }
                    }
                    if (list.Count == 0)
                    {
                        list = tempList;
                    }
                    else
                    {
                        list = getChinese(list, tempList);
                    }
                }
                else
                {
                    List<string> tempList = new List<string>();
                    if (Char.IsDigit(CharStr) || Char.IsLetter(CharStr))
                        tempList.Add(CharStr.ToString());

                    if (list.Count == 0)
                    {
                        list = tempList;
                    }
                    else
                    {
                        if (tempList.Count != 0)
                            list = getChinese(list, tempList);
                    }
                }
            }

            //多音字组成的 如拼音数超过5个 则只取5个
            list = list.Distinct().ToList<string>();
            int n = list.Count > 5 ? 5 : list.Count;

            for (int i = 0; i < n; i++)
            {
                if (i > 0)
                {
                    strChineseFirst.Append("|");
                }
                strChineseFirst.Append(list[i]);
            }

            return strChineseFirst.ToString(); ;
        }

        private static List<string> getChinese(List<string> arrayChinese, List<string> tempChinese)
        {
            List<string> list = new List<string>();
            for (int i = 0; i < arrayChinese.Count; i++)
            {
                for (int j = 0; j < tempChinese.Count; j++)
                {
                    string tempStr = arrayChinese[i] + tempChinese[j];
                    list.Add(tempStr);
                }
            }
            return list;
        }


        public static void autoCropperImage(Image originalImage, int maxWidth, int maxHeight, string fileUrl)
        {
            float width = originalImage.PhysicalDimension.Width;
            float height = originalImage.PhysicalDimension.Height;
            int Pixel = Convert.ToInt32((width + height) / 2);
            int realWidth, realHeight, spaceLeft, spaceTop;
            if (originalImage.Width > maxWidth && originalImage.Height > maxHeight)
            {
                realWidth = maxWidth;
                realHeight = maxWidth * originalImage.Height / originalImage.Width;
                if (realHeight > maxHeight)
                {
                    spaceLeft = 0;
                    spaceTop = (maxHeight - realHeight) / 2;
                }
                else
                {
                    realHeight = maxHeight;
                    realWidth = maxHeight * originalImage.Width / originalImage.Height;
                    spaceLeft = (maxWidth - realWidth) / 2;
                    spaceTop = 0;
                }
            }
            else if (originalImage.Width > maxWidth)
            {
                realWidth = maxWidth;
                realHeight = originalImage.Height;
                spaceLeft = 0;
                spaceTop = (maxHeight - originalImage.Height) / 2;
            }
            else if (originalImage.Height > maxHeight)
            {
                realHeight = maxHeight;
                realWidth = originalImage.Width;
                spaceLeft = (maxWidth - originalImage.Width) / 2;
                spaceTop = 0;
            }
            else
            {
                realWidth = originalImage.Width;
                realHeight = originalImage.Height;
                spaceLeft = (maxWidth - realWidth) / 2;
                spaceTop = (maxHeight - realHeight) / 2;
            }
            Bitmap bm = new Bitmap(maxWidth, maxHeight);
            Graphics g = Graphics.FromImage(bm);
            // 指定高质量、低速度呈现。
            g.SmoothingMode = SmoothingMode.HighQuality;
            // 指定高质量的双三次插值法。执行预筛选以确保高质量的收缩。此模式可产生质量最高的转换图像。
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;

            g.Clear(Color.White);
            g.DrawImage(originalImage, new Rectangle(spaceLeft, spaceTop, realWidth, realHeight), 0, 0, originalImage.Width, originalImage.Height, GraphicsUnit.Pixel);

            long[] quality = new long[1];
            if (Pixel > 100)
            {
                quality[0] = 100;
            }
            else
            {
                quality[0] = Pixel;
            }
            System.Drawing.Imaging.EncoderParameters encoderParams = new System.Drawing.Imaging.EncoderParameters();
            System.Drawing.Imaging.EncoderParameter encoderParam = new System.Drawing.Imaging.EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
            encoderParams.Param[0] = encoderParam;
            ImageCodecInfo[] arrayICI = ImageCodecInfo.GetImageEncoders();//获得包含有关内置图像编码解码器的信息的ImageCodecInfo 对象。
            ImageCodecInfo jpegICI = null;
            for (int i = 0; i < arrayICI.Length; i++)
            {
                if (arrayICI[i].FormatDescription.Equals("JPEG"))
                {
                    jpegICI = arrayICI[i];//设置JPEG编码
                    break;
                }
            }
            if (jpegICI != null)
            {
                bm.Save(fileUrl, jpegICI, encoderParams);
            }

            bm.Dispose();
            originalImage.Dispose();
            g.Dispose();

        }


        public static void imageUpload(Image originalImage, int maxWidth, int maxHeight, string fileUrl)
        {
            float width = originalImage.PhysicalDimension.Width;
            float height = originalImage.PhysicalDimension.Height;
            int Pixel = Convert.ToInt32((width + height) / 2);
            int realWidth, realHeight, spaceLeft, spaceTop;
            if (originalImage.Width > maxWidth && originalImage.Height > maxHeight)
            {
                realWidth = maxWidth;
                realHeight = maxWidth * originalImage.Height / originalImage.Width;
                if (realHeight > maxHeight)
                {
                    realHeight = maxHeight;
                    realWidth = maxHeight * originalImage.Width / originalImage.Height;
                    spaceLeft = (maxWidth - realWidth) / 2;
                    spaceTop = 0;
                }
                else
                {
                    spaceLeft = 0;
                    spaceTop = (maxHeight - realHeight) / 2;
                }
            }
            else if (originalImage.Width > maxWidth)
            {
                realWidth = maxWidth;
                realHeight = maxWidth * originalImage.Height / originalImage.Width;
                spaceLeft = 0;
                spaceTop = (maxHeight - realHeight) / 2;
            }
            else if (originalImage.Height > maxHeight)
            {
                realHeight = maxHeight;
                realWidth = maxHeight * originalImage.Width / originalImage.Height;
                spaceLeft = (maxWidth - realWidth) / 2;
                spaceTop = 0;
            }
            else
            {
                realWidth = originalImage.Width;
                realHeight = originalImage.Height;
                spaceLeft = (maxWidth - realWidth) / 2;
                spaceTop = (maxHeight - realHeight) / 2;
            }
            Bitmap bm = new Bitmap(maxWidth, maxHeight);
            Graphics g = Graphics.FromImage(bm);
            // 指定高质量、低速度呈现。
            g.SmoothingMode = SmoothingMode.HighQuality;
            // 指定高质量的双三次插值法。执行预筛选以确保高质量的收缩。此模式可产生质量最高的转换图像。
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;

            g.Clear(Color.White);
            g.DrawImage(originalImage, new Rectangle(spaceLeft, spaceTop, realWidth, realHeight), 0, 0, originalImage.Width, originalImage.Height, GraphicsUnit.Pixel);

            long[] quality = new long[1];
            if (Pixel > 100)
            {
                quality[0] = 100;
            }
            else
            {
                quality[0] = Pixel;
            }
            System.Drawing.Imaging.EncoderParameters encoderParams = new System.Drawing.Imaging.EncoderParameters();
            System.Drawing.Imaging.EncoderParameter encoderParam = new System.Drawing.Imaging.EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
            encoderParams.Param[0] = encoderParam;
            ImageCodecInfo[] arrayICI = ImageCodecInfo.GetImageEncoders();//获得包含有关内置图像编码解码器的信息的ImageCodecInfo 对象。
            ImageCodecInfo jpegICI = null;
            for (int i = 0; i < arrayICI.Length; i++)
            {
                if (arrayICI[i].FormatDescription.Equals("JPEG"))
                {
                    jpegICI = arrayICI[i];//设置JPEG编码
                    break;
                }
            }
            if (jpegICI != null)
            {
                bm.Save(fileUrl, jpegICI, encoderParams);
            }

            bm.Dispose();
            originalImage.Dispose();
            g.Dispose();

        }

        /// <summary>
        /// 拼路径
        /// </summary>
        /// <param name="objectType"></param>
        /// <param name="objectId"></param>
        /// <param name="category"></param>
        /// <returns></returns>
        public static String urlSpell(int companyId, int objectType, long objectId)
        {
            //拼路径,判断路径是否存在
            StringBuilder strUrl = new StringBuilder();
            strUrl.Append(Common.Const.server);
            strUrl.Append(Common.Const.strImage);
            strUrl.Append(companyId.ToString());
            strUrl.Append("/");

            if (objectType == 0)//Customer
            {
                strUrl.Append(Common.Const.strImageObjectType0);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 1)//Account
            {
                strUrl.Append(Common.Const.strImageObjectType1);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 2)//Company
            {
                strUrl.Append(Common.Const.strImageObjectType2);
            }
            else if (objectType == 4)//Treatment
            {
                strUrl.Append(Common.Const.strImageObjectType4);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 5)//Promotion
            {
                strUrl.Append(Common.Const.strImageObjectType5);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 6)//Commodity
            {
                strUrl.Append(Common.Const.strImageObjectType6);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 7)//Branch
            {
                strUrl.Append(Common.Const.strImageObjectType7);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 8)//Service
            {
                strUrl.Append(Common.Const.strImageObjectType8);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 9)//Category
            {
                strUrl.Append(Common.Const.strImageObjectType9);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 10)//TreatGroup
            {
                strUrl.Append(Common.Const.strImageObjectType10);
                strUrl.Append(objectId.ToString());
            }
            strUrl.Append("/");
            return strUrl.ToString();
        }

        public static bool IsNumeric(string str)
        {
            try
            {
                int temp = Convert.ToInt32(str);
                if (temp > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static bool IsMobile(string str)
        {
            try
            {
                Regex reg = new Regex(@"\d{8,13}");
                return str.Length < 14 && reg.IsMatch(str);
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static void CopyFolder(string fromFolder, string toFolder)
        {
            if (!Directory.Exists(toFolder))
                Directory.CreateDirectory(toFolder);

            // 子文件夹
            foreach (string sub in Directory.GetDirectories(fromFolder))
                CopyFolder(sub + "\\", toFolder + Path.GetFileName(sub) + "\\");

            // 文件
            foreach (string file in Directory.GetFiles(fromFolder))
                File.Copy(file, toFolder + Path.GetFileName(file), true);
        }



        /// <summary>
        /// 拼路径
        /// </summary>
        /// <param name="objectType"></param>
        /// <param name="objectId"></param>
        /// <param name="category"></param>
        /// <returns></returns>
        public static String updateUrlSpell(int companyId, int objectType, long objectId)
        {
            //拼路径,判断路径是否存在
            StringBuilder strUrl = new StringBuilder();
            strUrl.Append(System.Configuration.ConfigurationSettings.AppSettings["ImageServer"]);
            strUrl.Append(Common.Const.strImage);
            strUrl.Append(companyId.ToString());
            strUrl.Append("/");

            if (objectType == 0)//Customer
            {
                strUrl.Append(Common.Const.strImageObjectType0);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 1)//Account
            {
                strUrl.Append(Common.Const.strImageObjectType1);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 2)//Company
            {
                strUrl.Append(Common.Const.strImageObjectType2);
            }
            else if (objectType == 4)//Treatment
            {
                strUrl.Append(Common.Const.strImageObjectType4);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 5)//Promotion
            {
                strUrl.Append(Common.Const.strImageObjectType5);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 6)//Commodity
            {
                strUrl.Append(Common.Const.strImageObjectType6);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 7)//Branch
            {
                strUrl.Append(Common.Const.strImageObjectType7);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 8)//Service
            {
                strUrl.Append(Common.Const.strImageObjectType8);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 9)//Category
            {
                strUrl.Append(Common.Const.strImageObjectType9);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 10)//TreatGroup
            {
                strUrl.Append(Common.Const.strImageObjectType10);
                strUrl.Append(objectId.ToString());
            }
            strUrl.Append("/");
            return strUrl.ToString();
        }

        /// <summary>
        /// 拼路径
        /// </summary>
        /// <param name="objectType"></param>
        /// <param name="objectId"></param>
        /// <param name="category"></param>
        /// <returns></returns>
        public static String updateUrlSpell(int companyId, int objectType, string objectId)
        {
            //拼路径,判断路径是否存在
            StringBuilder strUrl = new StringBuilder();
            strUrl.Append(System.Configuration.ConfigurationSettings.AppSettings["ImageServer"]);
            strUrl.Append(Common.Const.strImage);
            strUrl.Append(companyId.ToString());
            strUrl.Append("/");

            if (objectType == 0)//Customer
            {
                strUrl.Append(Common.Const.strImageObjectType0);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 1)//Account
            {
                strUrl.Append(Common.Const.strImageObjectType1);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 2)//Company
            {
                strUrl.Append(Common.Const.strImageObjectType2);
            }
            else if (objectType == 4)//Treatment
            {
                strUrl.Append(Common.Const.strImageObjectType4);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 5)//Promotion
            {
                strUrl.Append(Common.Const.strImageObjectType5);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 6)//Commodity
            {
                strUrl.Append(Common.Const.strImageObjectType6);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 7)//Branch
            {
                strUrl.Append(Common.Const.strImageObjectType7);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 8)//Service
            {
                strUrl.Append(Common.Const.strImageObjectType8);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 9)//Category
            {
                strUrl.Append(Common.Const.strImageObjectType9);
                strUrl.Append(objectId.ToString());
            }
            else if (objectType == 10)//TreatGroup
            {
                strUrl.Append(Common.Const.strImageObjectType10);
                strUrl.Append(objectId.ToString());
            }
            strUrl.Append("/");
            return strUrl.ToString();
        }
    }
}
