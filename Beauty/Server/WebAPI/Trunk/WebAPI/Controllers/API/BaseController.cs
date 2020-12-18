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
using Newtonsoft.Json.Serialization;

namespace WebAPI.Controllers.API
{
    public class BaseController : ApiController
    {
        public BaseController()
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

        public class LimitPropsContractResolver : DefaultContractResolver
        {
            List<string> props = null;

            bool retain;

            /// <summary>
            /// 构造函数
            /// </summary>
            /// <param name="props">传入的属性数组</param>
            /// <param name="retain">true:表示props是需要保留的字段  false：表示props是要排除的字段</param>
            public LimitPropsContractResolver(List<string> props, bool retain = true)
            {
                //指定要序列化属性的清单
                this.props = props;

                this.retain = retain;
            }

            protected override IList<JsonProperty> CreateProperties(Type type,

            MemberSerialization memberSerialization)
            {
                IList<JsonProperty> list =
                base.CreateProperties(type, memberSerialization);

                //只保留清单有列出的属性
                return list.Where(p =>
                {
                    if (retain)
                    {                        
                        return props.Contains(p.PropertyName);
                    }
                    else
                    {
                        return !props.Contains(p.PropertyName);
                    }
                }).ToList();
            }
        }

        public static HttpResponseMessage toJson(Object obj, string dateFormat = "yyyy-MM-dd HH:mm", List<string> outPutProperty = null, bool retain = true)
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
                if (outPutProperty != null)
                    s.ContractResolver = new LimitPropsContractResolver(outPutProperty, retain);
                str = JsonConvert.SerializeObject(obj, Formatting.Indented, s);
            }
            HttpResponseMessage result = new HttpResponseMessage { Content = new StringContent(str, Encoding.GetEncoding("UTF-8"), "application/json") };
            result.Headers.Add("Author", "jimmy.wu");
            return result;
        }

        public static HttpResponseMessage toXML(Type type, object obj)
        {
            using (MemoryStream Stream = new MemoryStream())
            {
                if (type == null)
                {

                    HttpResponseMessage result = new HttpResponseMessage { Content = new StringContent(obj.ToString(), Encoding.GetEncoding("UTF-8"), "application/xml") };

                    return result;

                }
                else
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
                }

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
