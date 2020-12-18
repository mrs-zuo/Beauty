using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.Common
{
    public class APICommon
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="cycleType">0:日 1：月 2：季 3：年 4：自定义</param>
        /// <param name="startTime"></param>
        /// <param name="endtime"></param>
        /// <param name="strCompare"></param>
        /// <returns></returns>
        public static string getSqlWhereData_1_7_2(int cycleType, string startTime, string endtime, string strCompare)
        {
            string sqlAppend = "";
            switch (cycleType)
            {
                case 0:
                    sqlAppend = " AND DATEDIFF(dd, " + strCompare + ",getdate()) = 0";
                    break;
                case 1:
                    sqlAppend = " AND DATEPART(yy, " + strCompare + ") = DATEPART(YY,GETDATE()) AND DATEPART(MM, " + strCompare + ")=DATEPART(MM,GETDATE()) ";
                    break;
                case 2:
                    sqlAppend = " AND DATEPART(q, " + strCompare + ") = DATEPART(qq, GETDATE()) and DATEPART(yy, " + strCompare + ") = DATEPART(yy,GETDATE() ) ";
                    break;
                case 3:
                    sqlAppend = " AND DATEPART(yy, " + strCompare + ") =DATEPART(YY,GETDATE()) ";
                    break;
                case 4:
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                    sqlAppend = " AND " + strCompare + " BETWEEN '" + startTime + "' AND '" + endtime + "' ";
                    break;
                default:
                    break;
            }
            return sqlAppend;
        }


        #region 使用 缺省密钥字符串 加密/解密string

        /// <summary>
        /// 使用缺省密钥字符串加密string
        /// </summary>
        /// <param name="original">明文</param>
        /// <returns>密文</returns>
        public static string Encrypt(string original)
        {
            return Encrypt(original, "HhXxJsFw");
        }
        public static string UrlEncrypt(string original)
        {
            string result = Encrypt(original, "GlamourPromise");
            result = result.Replace("=", "%3D");
            result = result.Replace("+", "%2B");
            result = result.Replace("/", "%2F");
            return result;
        }
        /// <summary>
        /// 使用缺省密钥字符串解密string
        /// </summary>
        /// <param name="original">密文</param>
        /// <returns>明文</returns>
        public static string Decrypt(string original)
        {
            return Decrypt(original, "GlamourPromise", System.Text.Encoding.Default);
        }
        public static string UrlDecrypt(string original)
        {
            original = original.Replace("%3D", "=");
            original = original.Replace("%2B", "+");
            original = original.Replace("%2F", "/");
            return Decrypt(original, "GlamourPromise", System.Text.Encoding.Default);
        }
        #endregion

        #region 使用 给定密钥字符串 加密/解密string
        /// <summary>
        /// 使用给定密钥字符串加密string
        /// </summary>
        /// <param name="original">原始文字</param>
        /// <param name="key">密钥</param>
        /// <param name="encoding">字符编码方案</param>
        /// <returns>密文</returns>
        public static string Encrypt(string original, string key)
        {
            byte[] buff = System.Text.Encoding.Default.GetBytes(original);
            byte[] kb = System.Text.Encoding.Default.GetBytes(key);
            return Convert.ToBase64String(Encrypt(buff, kb));
        }
        /// <summary>
        /// 使用给定密钥字符串解密string
        /// </summary>
        /// <param name="original">密文</param>
        /// <param name="key">密钥</param>
        /// <returns>明文</returns>
        public static string Decrypt(string original, string key)
        {
            return Decrypt(original, key, System.Text.Encoding.Default);
        }

        /// <summary>
        /// 使用给定密钥字符串解密string,返回指定编码方式明文
        /// </summary>
        /// <param name="encrypted">密文</param>
        /// <param name="key">密钥</param>
        /// <param name="encoding">字符编码方案</param>
        /// <returns>明文</returns>
        public static string Decrypt(string encrypted, string key, Encoding encoding)
        {
            byte[] buff = Convert.FromBase64String(encrypted);
            byte[] kb = System.Text.Encoding.Default.GetBytes(key);
            return encoding.GetString(Decrypt(buff, kb));
        }
        #endregion

        #region 使用 缺省密钥字符串 加密/解密/byte[]
        /// <summary>
        /// 使用缺省密钥字符串解密byte[]
        /// </summary>
        /// <param name="encrypted">密文</param>
        /// <param name="key">密钥</param>
        /// <returns>明文</returns>
        public static byte[] Decrypt(byte[] encrypted)
        {
            byte[] key = System.Text.Encoding.Default.GetBytes("GlamourPromise");
            return Decrypt(encrypted, key);
        }
        /// <summary>
        /// 使用缺省密钥字符串加密
        /// </summary>
        /// <param name="original">原始数据</param>
        /// <param name="key">密钥</param>
        /// <returns>密文</returns>
        public static byte[] Encrypt(byte[] original)
        {
            byte[] key = System.Text.Encoding.Default.GetBytes("GlamourPromise");
            return Encrypt(original, key);
        }
        #endregion

        #region  使用 给定密钥 加密/解密/byte[]

        /// <summary>
        /// 生成MD5摘要
        /// </summary>
        /// <param name="original">数据源</param>
        /// <returns>摘要</returns>
        public static byte[] MakeMD5(byte[] original)
        {
            MD5CryptoServiceProvider hashmd5 = new MD5CryptoServiceProvider();
            byte[] keyhash = hashmd5.ComputeHash(original);
            hashmd5 = null;
            return keyhash;
        }


        /// <summary>
        /// 使用给定密钥加密
        /// </summary>
        /// <param name="original">明文</param>
        /// <param name="key">密钥</param>
        /// <returns>密文</returns>
        public static byte[] Encrypt(byte[] original, byte[] key)
        {
            TripleDESCryptoServiceProvider des = new TripleDESCryptoServiceProvider();
            des.Key = MakeMD5(key);
            des.Mode = CipherMode.ECB;

            return des.CreateEncryptor().TransformFinalBlock(original, 0, original.Length);
        }

        /// <summary>
        /// 使用给定密钥解密数据
        /// </summary>
        /// <param name="encrypted">密文</param>
        /// <param name="key">密钥</param>
        /// <returns>明文</returns>
        public static byte[] Decrypt(byte[] encrypted, byte[] key)
        {
            TripleDESCryptoServiceProvider des = new TripleDESCryptoServiceProvider();
            des.Key = MakeMD5(key);
            des.Mode = CipherMode.ECB;

            return des.CreateDecryptor().TransformFinalBlock(encrypted, 0, encrypted.Length);
        }

        #endregion

        #region 比对
        public delegate bool EqualsComparer<T>(T x, T y);

        public class Compare<T> : IEqualityComparer<T>
        {
            private EqualsComparer<T> _equalsComparer;

            public Compare(EqualsComparer<T> equalsComparer)
            {
                this._equalsComparer = equalsComparer;
            }

            public bool Equals(T x, T y)
            {
                if (null != this._equalsComparer)
                    return this._equalsComparer(x, y);
                else
                    return false;
            }

            public int GetHashCode(T obj)
            {
                return obj.ToString().GetHashCode();
            }
        }
        #endregion
    }
}
