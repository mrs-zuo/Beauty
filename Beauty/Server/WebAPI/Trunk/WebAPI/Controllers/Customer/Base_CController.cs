﻿using HS.Framework.Common.Util;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Http;
using System.Xml.Serialization;

namespace WebAPI.Controllers.Customer
{
    public class Base_CController : ApiController
    {
        public Base_CController()
        {
            CompanyID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["CO"], 0);
            BranchID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["BR"], 0);
            UserID = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["US"], 0);
            ClientType = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["CT"], 0);
            DeviceType = StringUtils.GetDbInt(HttpContext.Current.Request.Headers["DT"], 0);
            APPVersion = StringUtils.GetDbString(HttpContext.Current.Request.Headers["AV"]);
            Method = HttpContext.Current.Request.Headers["ME"];
            Time = StringUtils.GetDbDateTime(HttpContext.Current.Request.Headers["TI"]);
            GUID = StringUtils.GetDbString(HttpContext.Current.Request.Headers["GU"]);

            if (ClientType == 1 || ClientType == 3)
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
        public int DeviceType { get; set; }
        public string APPVersion { get; set; }
        public string GUID { get; set; }
        public bool IsBusiness { get; set; }

        public string sn { get; set; }

        public static HttpResponseMessage toJson(Object obj, string dateFormat = "yyyy-MM-dd HH:mm")
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
                s.NullValueHandling = NullValueHandling.Include;
                str = JsonConvert.SerializeObject(obj, s);
            }
            HttpResponseMessage result = new HttpResponseMessage { Content = new StringContent(str, Encoding.GetEncoding("UTF-8"), "application/json") };
            result.Headers.Add("Author", "jimmy.wu");
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
