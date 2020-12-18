using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace WebManager.Controllers
{
    public class WebServiceController : Controller
    {
        //
        // GET: /WebService/

        [ActionName("Version.asmx")]
        [HttpPost]
        public ActionResult getServerVersion(string parm)
        {
            //string xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><Result><Flag>1</Flag><Message></Message><Content><Version>2.4.1</Version><MustUpgrade>1</MustUpgrade></Content></Result>";
            StringBuilder xml=new StringBuilder();
                        xml.Append("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
                                    xml.Append("<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">");
                          xml.Append("<soap12:Body>");
                            xml.Append("<getServerVersionResponse xmlns=\"http://tempuri.org/\">");
                            xml.Append("<getServerVersionResult><Result xmlns=\"\"><Flag>1</Flag><Message></Message><Content><Version>2.4.1</Version><MustUpgrade>1</MustUpgrade></Content></Result></getServerVersionResult>");
                            xml.Append("</getServerVersionResponse>");
                          xml.Append("</soap12:Body>");
                        xml.Append("</soap12:Envelope>");
            //string xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap12:Envelope xmlns:soap12=\"http://schemas.xmlsoap12.org/soap12/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><soap12:Body><getServerVersionResponse xmlns=\"http://tempuri.org/\"><getServerVersionResult></getServerVersionResult></getServerVersionResponse></soap12:Body></soap12:Envelope>";
                        return Content(xml.ToString(), "application/soap+xml");
            
        }

        [ActionName("User.asmx")]
        [HttpPost]
        public ActionResult getCompanyList(string parm)
        {
            //string json = "{Code:1,Version:\"2.4.1\",MustUpgrade:true}";
            tempLogin t = new tempLogin();
            t.Code = -3;
            t.Data = new Data();
            t.Data.MustUpgrade = true;
            t.Data.Version = "2.4.1";
            t.Message = "";
            return Json(t);
        }

        public class tempLogin {
            public int Code { get; set; }
            public Data Data { get; set; }
            public string Message { get; set; }
        }

        public class Data
        {
            public bool MustUpgrade { get; set; }
            public string Version { get; set; }
        }

        

    }
}
