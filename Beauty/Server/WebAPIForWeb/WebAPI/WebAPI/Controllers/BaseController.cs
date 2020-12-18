using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;
using Newtonsoft.Json;
using System.IO;
using System.Xml.Serialization;
using HS.Framework.Common.Util;
using HS.Framework.Common.Entity;
using System.Web;

namespace WebAPI.Controllers
{
    public class BaseController : ApiController
    {
        public BaseController()
        {
            CompanyID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["CO"], 0);
            BranchID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["BR"], 0);
            UserID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["US"], 0);
            ClientType = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["CT"], 0);
            APPVersion = StringUtils.GetDbString(HttpContext.Current.Request.Headers["AV"]);
            Method = HttpContext.Current.Request.Headers["ME"];
            Time = StringUtils.GetDbDateTime(HttpContext.Current.Request.Headers["TI"]);
            GUID = StringUtils.GetDbString(HttpContext.Current.Request.Headers["GU"]);
            
            if (ClientType == 2 || ClientType == 4)
            {
                IsBusiness = true;
            }
        }

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int UserID { get; set; }
        public string Method { get; set; }
        public DateTime Time { get; set; }
        public string Version { get; set; }
        public int ClientType { get; set; }
        public string APPVersion { get; set; }
        public string GUID { get; set; }
        public bool IsBusiness { get; set; }

        public void ValidationSoapHeader()
        {

            //CompanyID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["CO"], 0);
            //BranchID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["BR"], 0);
            //UserID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["US"], 0);
            //ClientType = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["CT"], 0);
            //APPVersion = StringUtils.GetDbString(HttpContext.Current.Request.Headers["AV"]);
            //Method = HttpContext.Current.Request.Headers["ME"];
            //Time = StringUtils.GetDbDateTime(HttpContext.Current.Request.Headers["TI"]);
            //GUID = StringUtils.GetDbString(HttpContext.Current.Request.Headers["GU"]);

            //if (string.IsNullOrWhiteSpace(Method))
            //{
            //    return "10003";
            //}

            //if (!Method.Equals("LoginForAccount", StringComparison.CurrentCultureIgnoreCase))
            //{
            //    if (CompanyID<=0)
            //    {
            //        return "10004";
            //    }

            //    if (BranchID <= 0)
            //    {
            //        return "10005";
            //    }

            //    if (UserID <= 0)
            //    {
            //        return "10006";
            //    }

            //    if (ClientType <= 0)
            //    {
            //        return "10007";
            //    }

            //    if (string.IsNullOrWhiteSpace(APPVersion))
            //    {
            //        return "10008";
            //    }

            //    if (string.IsNullOrWhiteSpace(GUID))
            //    {
            //        return "10009";
            //    }
            //}

            //return "";
        }

        public string sn { get; set; }

        public static HttpResponseMessage toJson(Object obj, string dateFormat = "")
        {
            String str;
            if (obj is String || obj is Char)
            {
                str = obj.ToString();
            }
            else
            {
                JsonSerializerSettings s = new JsonSerializerSettings();
                s.DateFormatString = dateFormat;
                str = JsonConvert.SerializeObject(obj, s);
            }
            HttpResponseMessage result = new HttpResponseMessage { Content = new StringContent(str, Encoding.GetEncoding("UTF-8"), "application/json") };

            return result;
        }

        public static HttpResponseMessage toXML(Type type, object obj)
        {
            using (MemoryStream Stream = new MemoryStream())
            {
                XmlSerializer xml = new XmlSerializer(type);
                try
                {
                    //序列化对象  
                    xml.Serialize(Stream, obj);
                }
                catch (InvalidOperationException)
                {
                    throw;
                }
                Stream.Position = 0;
                using (StreamReader sr = new StreamReader(Stream))
                {
                    string str = sr.ReadToEnd();

                    sr.Dispose();

                    Stream.Dispose();

                    HttpResponseMessage result = new HttpResponseMessage { Content = new StringContent(str, Encoding.GetEncoding("UTF-8"), "application/xml") };

                    return result;
                }
            }
        }

        public class BaseHederResult
        {
            public string Code { get; set; }
            public string Message { get; set; }
        }

    }
}
