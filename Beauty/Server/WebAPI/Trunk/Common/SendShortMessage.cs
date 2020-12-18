using HS.Framework.Common;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace WebAPI.Common
{
    public abstract class SendShortMessage
    {
        public SendShortMessage()
        {
        }

        //短信发送验证码
        //dataType： 0: 验证码;1:密码
        //return 0: 发送成功 -40：手机格式不正确 其他：发送失败
        public static int sendShortMessage(string mobile, string strMessage, string companyAbbreviation, int dataType)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(mobile))
                {
                    LogUtil.Log("手机号为空,请求时间:" + DateTime.Now, "手机号为空");
                    return 40;
                }
                //else if (!CommonUtility.IsMobile(mobile))
                //{
                //    LogUtil.Log("手机号为:" + mobile + ",请求时间:" + DateTime.Now, "手机号为空");
                //    return 40;
                //}
                else
                {
                    string msg = dataType == 0 ? string.Format(Const.MESSAGE_AUTHENTICATIONCODE, companyAbbreviation, strMessage) : string.Format(Const.MESSAGE_PASSWORD, companyAbbreviation, strMessage);
                    string parm = "account=cf_wuxu" + "&password=wuxv19900920" + "&mobile=" + mobile + "&content=" + msg;
                    //string parm = "account=cf_wuxu" + "&password=111" + "&mobile=" + mobile + "&content=" + msg;
                    byte[] data = Encoding.UTF8.GetBytes(parm);

                    HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create("http://106.ihuyi.cn/webservice/sms.php?method=Submit");
                    req.KeepAlive = false;
                    req.ProtocolVersion = HttpVersion.Version10;
                    req.Method = "POST";
                    req.ContentType = "application/x-www-form-urlencoded";
                    req.ContentLength = data.Length;
                    req.Timeout = 10 * 1000;
                    Stream newStream = req.GetRequestStream();
                    newStream.Write(data, 0, data.Length);
                    newStream.Close();

                    HttpWebResponse myResponse = (HttpWebResponse)req.GetResponse();
                    StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);

                    string content = reader.ReadToEnd();
                    myResponse.Close();

                    LogUtil.Log("手机号:" + mobile + ",请求时间:" + DateTime.Now, content);

                    XmlDocument xmlContent = new XmlDocument();
                    xmlContent.XmlResolver = null;
                    xmlContent.LoadXml(content);
                    int result = 0;
                    XmlNode xmn = xmlContent.GetElementsByTagName("code").Item(0);
                    if (xmn != null)
                    {
                        result = Convert.ToInt32(xmn.InnerText);
                    }
                    return result;
                }
            }
            catch (Exception ex)
            {
                string strType = dataType == 0 ? "验证码" : "密码";
                LogUtil.Error(ex, "手机号:" + mobile + ",信息:" + strMessage + ",companyAbbreviation:" + companyAbbreviation + ",dataType:" + strType);
                return -1;
            }
        }


        public static int sendShortMessageForBalance(string mobile, string companyAbbreviation, string time)
        {
            string msg = "";
            try
            {
                if (string.IsNullOrWhiteSpace(mobile))
                {
                    LogUtil.Log("消费提醒手机号为空,请求时间:" + DateTime.Now, "手机号为空");
                    return 40;
                }
                else
                {
                    msg = string.Format(Const.MESSAGE_BALANCE, companyAbbreviation, time);
                    string parm = "account=cf_wuxu" + "&password=wuxv19900920" + "&mobile=" + mobile + "&content=" + msg;
                    byte[] data = Encoding.UTF8.GetBytes(parm);

                    HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create("http://106.ihuyi.cn/webservice/sms.php?method=Submit");
                    req.KeepAlive = false;
                    req.ProtocolVersion = HttpVersion.Version10;
                    req.Method = "POST";
                    req.ContentType = "application/x-www-form-urlencoded";
                    req.ContentLength = data.Length;
                    req.Timeout = 10 * 1000;
                    Stream newStream = req.GetRequestStream();
                    newStream.Write(data, 0, data.Length);
                    newStream.Close();

                    HttpWebResponse myResponse = (HttpWebResponse)req.GetResponse();
                    StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);

                    string content = reader.ReadToEnd();
                    myResponse.Close();

                    LogUtil.Log("手机号:" + mobile + ",请求时间:" + DateTime.Now, content);

                    XmlDocument xmlContent = new XmlDocument();
                    xmlContent.XmlResolver = null;
                    xmlContent.LoadXml(content);
                    int result = 0;
                    XmlNode xmn = xmlContent.GetElementsByTagName("code").Item(0);
                    if (xmn != null)
                    {
                        result = Convert.ToInt32(xmn.InnerText);
                    }
                    return result;
                }
            }
            catch (Exception ex)
            {
                string strType = "消费提醒";
                LogUtil.Error(ex, "手机号:" + mobile + ",信息:" + msg + ",companyAbbreviation:" + companyAbbreviation + ",dataType:" + strType);
                return -1;
            }
        }

        public static bool sendShortMessageForTask(string mobile, string msg)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(mobile))
                {
                    LogUtil.Log("手机号为空,请求时间:" + DateTime.Now, "手机号为空");
                    return false;
                }
                else
                {
                    string parm = "account=cf_wuxu" + "&password=wuxv19900920" + "&mobile=" + mobile + "&content=" + msg;
                    byte[] data = Encoding.UTF8.GetBytes(parm);

                    HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create("http://106.ihuyi.cn/webservice/sms.php?method=Submit");
                    req.KeepAlive = false;
                    req.ProtocolVersion = HttpVersion.Version10;
                    req.Method = "POST";
                    req.ContentType = "application/x-www-form-urlencoded";
                    req.ContentLength = data.Length;
                    req.Timeout = 10 * 1000;
                    Stream newStream = req.GetRequestStream();
                    newStream.Write(data, 0, data.Length);
                    newStream.Close();

                    HttpWebResponse myResponse = (HttpWebResponse)req.GetResponse();
                    StreamReader reader = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8);

                    string content = reader.ReadToEnd();
                    myResponse.Close();

                    LogUtil.Log("手机号:" + mobile + ",请求时间:" + DateTime.Now, content);

                    XmlDocument xmlContent = new XmlDocument();
                    xmlContent.XmlResolver = null;
                    xmlContent.LoadXml(content);
                    int result = 0;
                    XmlNode xmn = xmlContent.GetElementsByTagName("code").Item(0);
                    if (xmn != null)
                    {
                        result = Convert.ToInt32(xmn.InnerText);
                    }
                    if (result == 2)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
            catch (Exception ex)
            {
                LogUtil.Error(ex, "手机号:" + mobile + ",信息:Task推送出错");
                return false;
            }
        }
    }
}
