using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;
using System.Web.Mvc;
using System.Xml;

namespace WeChat.Controllers
{
    public class PayController : Controller
    {
        //public HttpResponseMessage Test()
        //{
        //    HttpResponseMessage result = new HttpResponseMessage { Content = new StringContent("{\"jimmy\":1}", Encoding.GetEncoding("UTF-8"), "application/json") };
        //    return result;
        //}

        public ActionResult test()
        {

            Stream s = System.Web.HttpContext.Current.Request.InputStream;
            byte[] b = new byte[s.Length];
            s.Read(b, 0, (int)s.Length);
            string postStr = Encoding.UTF8.GetString(b);

            //string Data = string.Empty;

            //XmlDocument xml = new XmlDocument();
            //xml.LoadXml(postStr);
            //if (xml != null && xml.InnerXml != "")
            //{
            //    HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
            //    Data = we.PayQRCode1(xml);
            //}

            return Content("12321");
        }

//        public ActionResult PayRs()
//        {
//            Stream s = System.Web.HttpContext.Current.Request.InputStream;
//            byte[] b = new byte[s.Length];
//            s.Read(b, 0, (int)s.Length);
//            string postStr = Encoding.UTF8.GetString(b);
//            XmlDocument doc = new XmlDocument();
//            doc.LoadXml(postStr);
//            if(doc!=null)
//            {
//                HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
//                if (we.PayResult(doc))
//                {
//                    return Content(@"<xml>
//                                  <return_code><![CDATA[SUCCESS]]></return_code>
//                                  <return_msg><![CDATA[OK]]></return_msg>
//                                </xml>
//                                ", "text/xml");
//                }
//                else
//                {
//                    return Content(@"<xml>
//                                  <return_code><![CDATA[FAIL]]></return_code>
//                                  <return_msg><![CDATA[参数丢失]]></return_msg>
//                                </xml>
//                                ", "text/xml");
//                }
//            }
//            return Content(@"<xml>
//                                  <return_code><![CDATA[FAIL]]></return_code>
//                                  <return_msg><![CDATA[参数丢失]]></return_msg>
//                                </xml>
//                                ", "text/xml");
//        }


        public ActionResult PaySaoMa(string auth_code)
        {
            WxPayData data = new WxPayData();
            data.SetValue("appid", WxPayConfig.APPID);
            data.SetValue("mch_id", WxPayConfig.MCHID);
            data.SetValue("nonce_str", WxPayApi.GenerateNonceStr());
            data.SetValue("body", "冈本超薄001");            
            data.SetValue("out_trade_no", DateTime.Now.ToUniversalTime().Ticks.ToString());
            data.SetValue("detail", "超薄001非一般的感受");
            data.SetValue("total_fee", "1");
            data.SetValue("spbill_create_ip", "61.129.96.206");
            data.SetValue("auth_code", auth_code);
            data.SetValue("sign", data.MakeSign());
            string xmlData = data.ToXml();
            string Data = string.Empty;
            HttpStatusCode code = HS.Framework.Common.Net.NetUtil.GetResponse("https://api.mch.weixin.qq.com/pay/micropay", xmlData, out Data);
            return Content(Data, "text/xml");
        }

        public ActionResult Chaxun(string transaction_id, string out_trade_no)
        {
            WxPayData data = new WxPayData();
            data.SetValue("appid",WxPayConfig.APPID);
            data.SetValue("mch_id",WxPayConfig.MCHID);
            data.SetValue("transaction_id",transaction_id);
            data.SetValue("out_trade_no",out_trade_no);
            data.SetValue("nonce_str",WxPayApi.GenerateNonceStr());
            data.SetValue("sign",data.MakeSign());
            string xmlData = data.ToXml();
            string Data = string.Empty;
            HttpStatusCode code = HS.Framework.Common.Net.NetUtil.GetResponse("https://api.mch.weixin.qq.com/pay/orderquery", xmlData, out Data);
            return Content(Data, "text/xml");
        }
    }
}
