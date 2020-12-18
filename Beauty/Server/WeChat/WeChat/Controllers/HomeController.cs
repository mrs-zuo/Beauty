using HS.Framework.Common;
using HS.Framework.Common.Net;
using HS.Framework.Common.WeChat;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Mvc;
using System.Xml;

namespace WeChat.Controllers
{
    public class HomeController : Controller
    {
        //
        // GET: /Home/
        //private readonly string Token = "B1zApp3r";//与微信公众账号后台的Token设置保持一致，区分大小写。
        //公众平台上开发者设置的token, appID, EncodingAESKey
        private readonly string sTokenmeiliyueding = "ASc3aoDco4a4fa8DaDF";
        private readonly string sAppIDmeiliyueding = "wx1aa3ce096117de41";
        private readonly string sEncodingAESKeymeiliyueding = "SsvJYPWZ4u2Dt7orPAjmnR2qEqpYa2kTH023waoWkrZ";

        private readonly string sTokenhanhongkeji = "ADSf2zdsga34asdfvcSDfsdcv";
        private readonly string sAppIDhanhongkeji = "wx90954065982d2e76";
        private readonly string sEncodingAESKeyhanhongkeji = "Qxmn0ReZD9cNGCjdxTuwntnlbSoKEeFe3O497KpQyf9";

        //private readonly string sTokenlameizhimi = "jfhdiusu9u4382u48h";
        //private readonly string sAppIDlameizhimi = "wxfdd7b6a10e5af1d2";
        //private readonly string sEncodingAESKeylameizhimi = "Omh1qQPQTw6WOg41ZJHsEzU4D2QXVh7BfXnqAHiPWcB";

        private void WriteContent(string str)
        {

            System.Web.HttpContext.Current.Response.Clear();
            System.Web.HttpContext.Current.Response.BufferOutput = true;
            //System.Web.HttpContext.Current.Response.Charset = "UTF-8";
            //System.Web.HttpContext.Current.Response.ContentType = "text/xml";
            System.Web.HttpContext.Current.Response.Write(str);
            Response.End();
        }

        public ViewResult meiliyueding()
        {
            string signature = System.Web.HttpContext.Current.Request["signature"];
            string timestamp = System.Web.HttpContext.Current.Request["timestamp"];
            string nonce = System.Web.HttpContext.Current.Request["nonce"];
            string echostr = System.Web.HttpContext.Current.Request["echostr"];
            HS.Framework.Common.WeChat.WeChat wechat = new HS.Framework.Common.WeChat.WeChat();
            WXCompanyInfoBase baseinfo = wechat.GetBaseInfo(45);
            string accessToken = string.Empty;
            accessToken = wechat.GetWeChatToken(45);
            string EnCodeCompanyID = HttpUtility.UrlEncode(HS.Framework.Common.Safe.CryptDES.DESEncrypt("45", "65033255", true));
            //认证
            if (Request.HttpMethod == "GET")
            {
                //get method - 仅在微信后台填写URL验证时触发
                if (CheckSignature.Check(signature, timestamp, nonce, baseinfo.Token))
                {
                    WriteContent(echostr); //返回随机字符串则表示验证通过
                }
                else
                {
                    WriteContent("failed:" + signature + "," + CheckSignature.GetSignature(timestamp, nonce, baseinfo.Token) + "。" +
                                "如果你在浏览器中看到这句话，说明此地址可以被作为微信公众账号后台的Url，请注意保持Token一致。");
                }
                Response.End();
            }
            else
            {
                Stream s = Request.InputStream;
                string postStr = "";
                byte[] b = new byte[s.Length];
                s.Read(b, 0, (int)s.Length);
                postStr = Encoding.UTF8.GetString(b);

                LogUtil.Log("解密前", postStr);

                Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(baseinfo.Token, baseinfo.EncodingAESKey, baseinfo.APPID);

                string temp = "";
                wxcpt.DecryptMsg(signature, timestamp, nonce, postStr, ref temp);

                LogUtil.Log("解密后", temp);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(temp);
                if (doc != null && doc.InnerXml != "")
                {
                    XmlNode root = null;
                    root = doc.FirstChild;
                    string toUserName = root["ToUserName"].InnerText;
                    string FromUserName = root["FromUserName"].InnerText;
                    string msgType = root["MsgType"].InnerText;
                    if (msgType.ToLower() == "event" && root["Event"].InnerText == "subscribe")
                    {
                        string Data = string.Empty;
                        List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                        ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=45/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                        newsmodel.Title = "亲，欢迎关注【美丽约定】！";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                        newsmodel.Title = "绑定【美丽约定】账号";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    }
                    else
                    {
                        string temp1 = string.Empty;
                        string neirong  = "感谢您关注美丽约定，您身边的美丽专家。\n"
                                        + "--------------------------------\n"
                                        + "您可以随时查询消费记录、会员卡余额；在线购买、预约服务；第一时间获取优惠信息。更多惊喜等待您的发掘！\n"
                                        + "--------------------------------\n"
                                        + "请使用菜单栏选择您想要的服务内容。";
                        neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), neirong);
                        wxcpt.EncryptMsg(neirong, timestamp, nonce, ref temp1);
                        WriteContent(temp1);
                    }
                    #region 暂时不要
                    //                {
                    //                    XmlNode root = null;
                    //                    root = doc.FirstChild;
                    //                    string toUserName = root["ToUserName"].InnerText;
                    //                    string FromUserName = root["FromUserName"].InnerText;
                    //                    string msgType = root["MsgType"].InnerText;
                    //                    switch (msgType.ToLower())
                    //                    {
                    //                            //文字
                    //                        case "text":                            
                    //                            
                    //                            string Content = root["Content"].InnerText;
                    //                            string neirong = string.Empty;
                    //                            if (msgType.ToUpper().Equals("TEXT") && Content.Equals("新闻"))
                    //                            {
                    //                                List<WeChat.ReplyTemplate.NewsModel> list = new List<ReplyTemplate.NewsModel>();
                    //                                list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去百度哦", Title = "点一下就带你去百度哦？", Url = "http://www.baidu.com", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //                                list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去苏宁哦", Title = "点一下就带你去苏宁哦？", Url = "http://www.suning.com/", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //
                    //                                neirong = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), list);
                    //                                WriteContent(neirong);
                    //                            }
                    //                            else
                    //                            {
                    //                                neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), Content + "吴振涛1");
                    //                                WriteContent(neirong);
                    //                            }
                    //
                    //                            LogUtil.Log("发送后", neirong);
                    //                            break;
                    //                            //事件
                    //                        case "event":                            
                    //                            //订阅
                    //                            if (root["Event"].InnerText == "subscribe")
                    //                            {                                   
                    //                                string Data=string.Empty;                                
                    //                                List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                    //                                ReplyTemplate.NewsModel newsmodel=new ReplyTemplate.NewsModel();
                    //                                newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=45/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                    //                                newsmodel.Title="亲，欢迎关注【美丽约定】！";
                    //                                newsmodel.Url="https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";                                
                    //                                listModel.Add(newsmodel);
                    //                                newsmodel = new ReplyTemplate.NewsModel();
                    //                                newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                    //                                newsmodel.Title = "绑定【美丽约定】账号";
                    //                                newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";                                
                    //                                WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(),listModel));
                    //                            }
                    //                            break;
                    //                            //语音
                    //                        case "voice":
                    //                            WriteContent(ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(),root["Recognition"].InnerText));
                    //                            break;
                    #endregion

                }

            }

            return View();
        }

        public ViewResult hanhongkeji()
        {
            string signature = System.Web.HttpContext.Current.Request["signature"];
            string timestamp = System.Web.HttpContext.Current.Request["timestamp"];
            string nonce = System.Web.HttpContext.Current.Request["nonce"];
            string echostr = System.Web.HttpContext.Current.Request["echostr"];
            string strAAA = System.Web.HttpContext.Current.Request["aaa"];
            HS.Framework.Common.WeChat.WeChat wechat = new HS.Framework.Common.WeChat.WeChat();
            WXCompanyInfoBase baseinfo = wechat.GetBaseInfo(46);
            string accessToken = string.Empty;
            accessToken = wechat.GetWeChatToken(46);
            string EnCodeCompanyID = HttpUtility.UrlEncode(HS.Framework.Common.Safe.CryptDES.DESEncrypt("46", "65033255", true));
            //认证
            if (Request.HttpMethod == "GET")
            {
                //get method - 仅在微信后台填写URL验证时触发
                if (CheckSignature.Check(signature, timestamp, nonce, baseinfo.Token))
                {
                    WriteContent(echostr); //返回随机字符串则表示验证通过
                }
                else
                {
                    WriteContent("failed:" + signature + "," + CheckSignature.GetSignature(timestamp, nonce, baseinfo.Token) + "。" +
                                "如果你在浏览器中看到这句话，说明此地址可以被作为微信公众账号后台的Url，请注意保持Token一致。");
                }
                Response.End();
            }
            else
            {
                Stream s = Request.InputStream;
                string postStr = "";
                byte[] b = new byte[s.Length];
                s.Read(b, 0, (int)s.Length);
                postStr = Encoding.UTF8.GetString(b);

                LogUtil.Log("解密前", postStr);

                Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(baseinfo.Token, baseinfo.EncodingAESKey, baseinfo.APPID);

                string temp = "";
                wxcpt.DecryptMsg(signature, timestamp, nonce, postStr, ref temp);

                LogUtil.Log("解密后", temp);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(temp);
                if (doc != null && doc.InnerXml != "")
                {
                    XmlNode root = null;
                    root = doc.FirstChild;
                    string toUserName = root["ToUserName"].InnerText;
                    string FromUserName = root["FromUserName"].InnerText;
                    string msgType = root["MsgType"].InnerText;
                    if (msgType.ToLower() == "event" && root["Event"].InnerText == "subscribe")
                    {
                        string Data = string.Empty;
                        List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                        ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=46/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                        newsmodel.Title = "亲，欢迎关注【汉弘信息】！";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.test.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                        newsmodel.Title = "绑定【汉弘信息】账号";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.test.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    }
                    else
                    {
                        string temp1 = string.Empty;
                        string neirong  = "感谢您关注汉弘信息，您身边的美丽专家。\n"
                                        + "--------------------------------\n"
                                        + "随时查询消费记录、会员卡余额；在线购买、预约服务；第一时间获取优惠信息。更多惊喜等待您的发掘！\n"
                                        + "--------------------------------\n"
                                        + "请使用菜单栏选择您想要的服务内容。\n\n"
                                        + strAAA;
                        neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), neirong);
                        wxcpt.EncryptMsg(neirong, timestamp, nonce, ref temp1);
                        WriteContent(temp1);
                    }

                    #region 暂时不要
                    //switch (msgType.ToLower())
                    //{
                    //    //文字
                    //    case "text":

                    //        string Content = root["Content"].InnerText;
                    //        string neirong = string.Empty;
                    //        if (msgType.ToUpper().Equals("TEXT") && Content.Equals("新闻"))
                    //        {
                    //            List<WeChat.ReplyTemplate.NewsModel> list = new List<ReplyTemplate.NewsModel>();
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去百度哦", Title = "点一下就带你去百度哦？", Url = "http://www.baidu.com", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去苏宁哦", Title = "点一下就带你去苏宁哦？", Url = "http://www.suning.com/", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });

                    //            neirong = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), list);

                    //            WriteContent(neirong);
                    //        }
                    //        else
                    //        {

                    //        }
                    //        break;
                    //    //事件
                    //    case "event":
                    //        //订阅
                    //        if (root["Event"].InnerText == "subscribe")
                    //        {
                    //            string Data = string.Empty;
                    //            List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                    //            ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=46/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                    //            newsmodel.Title = "亲，欢迎关注【汉弘科技】！";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.test.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            listModel.Add(newsmodel);
                    //            newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                    //            newsmodel.Title = "绑定【汉弘科技】账号";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.test.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    //        }
                    //        break;
                    //    //语音
                    //    case "voice":
                    //        WriteContent(ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), root["Recognition"].InnerText));
                    //        break;
                    //}
                    #endregion
                }
            }
            return View();
        }

        public ViewResult taimumeirong()
        {
            string signature = System.Web.HttpContext.Current.Request["signature"];
            string timestamp = System.Web.HttpContext.Current.Request["timestamp"];
            string nonce = System.Web.HttpContext.Current.Request["nonce"];
            string echostr = System.Web.HttpContext.Current.Request["echostr"];
            HS.Framework.Common.WeChat.WeChat wechat = new HS.Framework.Common.WeChat.WeChat();
            WXCompanyInfoBase baseinfo = wechat.GetBaseInfo(17);
            string accessToken = string.Empty;
            accessToken = wechat.GetWeChatToken(17);
            string EnCodeCompanyID = HttpUtility.UrlEncode(HS.Framework.Common.Safe.CryptDES.DESEncrypt("17", "65033255", true));
            //认证
            if (Request.HttpMethod == "GET")
            {
                //get method - 仅在微信后台填写URL验证时触发
                if (CheckSignature.Check(signature, timestamp, nonce, baseinfo.Token))
                {
                    WriteContent(echostr); //返回随机字符串则表示验证通过
                }
                else
                {
                    WriteContent("failed:" + signature + "," + CheckSignature.GetSignature(timestamp, nonce, baseinfo.Token) + "。" +
                                "如果你在浏览器中看到这句话，说明此地址可以被作为微信公众账号后台的Url，请注意保持Token一致。");
                }
                Response.End();
            }
            else
            {
                Stream s = Request.InputStream;
                string postStr = "";
                byte[] b = new byte[s.Length];
                s.Read(b, 0, (int)s.Length);
                postStr = Encoding.UTF8.GetString(b);

                LogUtil.Log("解密前", postStr);

                Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(baseinfo.Token, baseinfo.EncodingAESKey, baseinfo.APPID);

                string temp = "";
                wxcpt.DecryptMsg(signature, timestamp, nonce, postStr, ref temp);

                LogUtil.Log("解密后", temp);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(temp);
                if (doc != null && doc.InnerXml != "")
                {
                    XmlNode root = null;
                    root = doc.FirstChild;
                    string toUserName = root["ToUserName"].InnerText;
                    string FromUserName = root["FromUserName"].InnerText;
                    string msgType = root["MsgType"].InnerText;
                    if (msgType.ToLower() == "event" && root["Event"].InnerText == "subscribe")
                    {
                        string Data = string.Empty;
                        List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                        ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=17/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                        newsmodel.Title = "亲，欢迎关注【肽慕医疗】！";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                        newsmodel.Title = "绑定【肽慕医疗】账号";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    }
                    else
                    {
                        string temp1 = string.Empty;
                        string neirong  = "感谢您关注肽慕医疗，您身边的美丽专家。\n"
                                        + "--------------------------------\n"
                                        + "随时查询消费记录、会员卡余额；在线购买、预约服务；第一时间获取优惠信息。更多惊喜等待您的发掘！\n"
                                        + "--------------------------------\n"
                                        + "请使用菜单栏选择您想要的服务内容。";
                        neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), neirong);
                        wxcpt.EncryptMsg(neirong, timestamp, nonce, ref temp1);
                        WriteContent(temp1);
                    }

                    #region 暂时不要
                    //switch (msgType.ToLower())
                    //{
                    //    //文字
                    //    case "text":

                    //        string Content = root["Content"].InnerText;
                    //        string neirong = string.Empty;
                    //        if (msgType.ToUpper().Equals("TEXT") && Content.Equals("新闻"))
                    //        {
                    //            List<WeChat.ReplyTemplate.NewsModel> list = new List<ReplyTemplate.NewsModel>();
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去百度哦", Title = "点一下就带你去百度哦？", Url = "http://www.baidu.com", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去苏宁哦", Title = "点一下就带你去苏宁哦？", Url = "http://www.suning.com/", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });

                    //            neirong = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), list);

                    //            WriteContent(neirong);
                    //        }
                    //        else
                    //        {

                    //        }
                    //        break;
                    //    //事件
                    //    case "event":
                    //        //订阅
                    //        if (root["Event"].InnerText == "subscribe")
                    //        {
                    //            string Data = string.Empty;
                    //            List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                    //            ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=17/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                    //            newsmodel.Title = "亲，欢迎关注【肽慕医疗】！";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            listModel.Add(newsmodel);
                    //            newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                    //            newsmodel.Title = "绑定【肽慕医疗】账号";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    //        }
                    //        break;
                    //    //语音
                    //    case "voice":
                    //        WriteContent(ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), root["Recognition"].InnerText));
                    //        break;
                    //}
                    #endregion
                }
            }
            return View();
        }

        public ViewResult vcut()
        {
            string signature = System.Web.HttpContext.Current.Request["signature"];
            string timestamp = System.Web.HttpContext.Current.Request["timestamp"];
            string nonce = System.Web.HttpContext.Current.Request["nonce"];
            string echostr = System.Web.HttpContext.Current.Request["echostr"];
            HS.Framework.Common.WeChat.WeChat wechat = new HS.Framework.Common.WeChat.WeChat();
            WXCompanyInfoBase baseinfo = wechat.GetBaseInfo(66);
            string accessToken = string.Empty;
            accessToken = wechat.GetWeChatToken(66);
            string EnCodeCompanyID = HttpUtility.UrlEncode(HS.Framework.Common.Safe.CryptDES.DESEncrypt("66", "65033255", true));
            //认证
            if (Request.HttpMethod == "GET")
            {
                //get method - 仅在微信后台填写URL验证时触发
                if (CheckSignature.Check(signature, timestamp, nonce, baseinfo.Token))
                {
                    WriteContent(echostr); //返回随机字符串则表示验证通过
                }
                else
                {
                    WriteContent("failed:" + signature + "," + CheckSignature.GetSignature(timestamp, nonce, baseinfo.Token) + "。" +
                                "如果你在浏览器中看到这句话，说明此地址可以被作为微信公众账号后台的Url，请注意保持Token一致。");
                }
                Response.End();
            }
            else
            {
                Stream s = Request.InputStream;
                string postStr = "";
                byte[] b = new byte[s.Length];
                s.Read(b, 0, (int)s.Length);
                postStr = Encoding.UTF8.GetString(b);

                LogUtil.Log("解密前", postStr);

                Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(baseinfo.Token, baseinfo.EncodingAESKey, baseinfo.APPID);

                string temp = "";
                wxcpt.DecryptMsg(signature, timestamp, nonce, postStr, ref temp);

                LogUtil.Log("解密后", temp);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(temp);
                if (doc != null && doc.InnerXml != "")
                {
                    XmlNode root = null;
                    root = doc.FirstChild;
                    string toUserName = root["ToUserName"].InnerText;
                    string FromUserName = root["FromUserName"].InnerText;
                    string msgType = root["MsgType"].InnerText;
                    if (msgType.ToLower() == "event" && root["Event"].InnerText == "subscribe")
                    {
                        string Data = string.Empty;
                        List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                        ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=66/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                        newsmodel.Title = "亲，欢迎关注【VCut发型机构】！";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                        newsmodel.Title = "绑定【VCut发型机构】账号";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    }
                    else
                    {
                        string temp1 = string.Empty;
                        string neirong  = "感谢您关注VCut发型机构，您身边的美丽专家。\n"
                                        + "--------------------------------\n"
                                        + "随时查询消费记录、会员卡余额；在线购买、预约服务；第一时间获取优惠信息。更多惊喜等待您的发掘！\n"
                                        + "--------------------------------\n"
                                        + "请使用菜单栏选择您想要的服务内容。";
                        neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), neirong);
                        wxcpt.EncryptMsg(neirong, timestamp, nonce, ref temp1);
                        WriteContent(temp1);
                    }

                    #region 暂时不要
                    //switch (msgType.ToLower())
                    //{
                    //    //文字
                    //    case "text":

                    //        string Content = root["Content"].InnerText;
                    //        string neirong = string.Empty;
                    //        if (msgType.ToUpper().Equals("TEXT") && Content.Equals("新闻"))
                    //        {
                    //            List<WeChat.ReplyTemplate.NewsModel> list = new List<ReplyTemplate.NewsModel>();
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去百度哦", Title = "点一下就带你去百度哦？", Url = "http://www.baidu.com", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去苏宁哦", Title = "点一下就带你去苏宁哦？", Url = "http://www.suning.com/", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });

                    //            neirong = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), list);

                    //            WriteContent(neirong);
                    //        }
                    //        else
                    //        {

                    //        }
                    //        break;
                    //    //事件
                    //    case "event":
                    //        //订阅
                    //        if (root["Event"].InnerText == "subscribe")
                    //        {
                    //            string Data = string.Empty;
                    //            List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                    //            ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=66/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                    //            newsmodel.Title = "亲，欢迎关注【Vcut发型机构】！";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            listModel.Add(newsmodel);
                    //            newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                    //            newsmodel.Title = "绑定【Vcut发型机构】账号";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    //        }
                    //        break;
                    //    //语音
                    //    case "voice":
                    //        WriteContent(ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), root["Recognition"].InnerText));
                    //        break;
                    //}
                    #endregion
                }
            }
            return View();
        }

        public ViewResult ouquan()
        {
            string signature = System.Web.HttpContext.Current.Request["signature"];
            string timestamp = System.Web.HttpContext.Current.Request["timestamp"];
            string nonce = System.Web.HttpContext.Current.Request["nonce"];
            string echostr = System.Web.HttpContext.Current.Request["echostr"];
            HS.Framework.Common.WeChat.WeChat wechat = new HS.Framework.Common.WeChat.WeChat();
            WXCompanyInfoBase baseinfo = wechat.GetBaseInfo(72);
            string accessToken = string.Empty;
            accessToken = wechat.GetWeChatToken(72);
            string EnCodeCompanyID = HttpUtility.UrlEncode(HS.Framework.Common.Safe.CryptDES.DESEncrypt("72", "65033255", true));
            //认证
            if (Request.HttpMethod == "GET")
            {
                //get method - 仅在微信后台填写URL验证时触发
                if (CheckSignature.Check(signature, timestamp, nonce, baseinfo.Token))
                {
                    WriteContent(echostr); //返回随机字符串则表示验证通过
                }
                else
                {
                    WriteContent("failed:" + signature + "," + CheckSignature.GetSignature(timestamp, nonce, baseinfo.Token) + "。" +
                                "如果你在浏览器中看到这句话，说明此地址可以被作为微信公众账号后台的Url，请注意保持Token一致。");
                }
                Response.End();
            }
            else
            {
                Stream s = Request.InputStream;
                string postStr = "";
                byte[] b = new byte[s.Length];
                s.Read(b, 0, (int)s.Length);
                postStr = Encoding.UTF8.GetString(b);

                LogUtil.Log("解密前", postStr);

                Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(baseinfo.Token, baseinfo.EncodingAESKey, baseinfo.APPID);

                string temp = "";
                wxcpt.DecryptMsg(signature, timestamp, nonce, postStr, ref temp);

                LogUtil.Log("解密后", temp);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(temp);
                if (doc != null && doc.InnerXml != "")
                {
                    XmlNode root = null;
                    root = doc.FirstChild;
                    string toUserName = root["ToUserName"].InnerText;
                    string FromUserName = root["FromUserName"].InnerText;
                    string msgType = root["MsgType"].InnerText;
                    if (msgType.ToLower() == "event" && root["Event"].InnerText == "subscribe")
                    {
                        string Data = string.Empty;
                        List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                        ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=72/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                        newsmodel.Title = "亲，欢迎关注【欧泉美业科技】！";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                        newsmodel.Title = "绑定【欧泉美业科技】账号";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    }
                    else
                    {
                        string temp1 = string.Empty;
                        string neirong  = "感谢您关注欧泉美业科技，您身边的美丽专家。\n"
                                        + "--------------------------------\n"
                                        + "随时查询消费记录、会员卡余额；在线购买、预约服务；第一时间获取优惠信息。更多惊喜等待您的发掘！\n"
                                        + "--------------------------------\n"
                                        + "请使用菜单栏选择您想要的服务内容。";
                        neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), neirong);
                        wxcpt.EncryptMsg(neirong, timestamp, nonce, ref temp1);
                        WriteContent(temp1);
                    }

                    #region 暂时不要
                    //switch (msgType.ToLower())
                    //{
                    //    //文字
                    //    case "text":

                    //        string Content = root["Content"].InnerText;
                    //        string neirong = string.Empty;
                    //        if (msgType.ToUpper().Equals("TEXT") && Content.Equals("新闻"))
                    //        {
                    //            List<WeChat.ReplyTemplate.NewsModel> list = new List<ReplyTemplate.NewsModel>();
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去百度哦", Title = "点一下就带你去百度哦？", Url = "http://www.baidu.com", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去苏宁哦", Title = "点一下就带你去苏宁哦？", Url = "http://www.suning.com/", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });

                    //            neirong = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), list);

                    //            WriteContent(neirong);
                    //        }
                    //        else
                    //        {

                    //        }
                    //        break;
                    //    //事件
                    //    case "event":
                    //        //订阅
                    //        if (root["Event"].InnerText == "subscribe")
                    //        {
                    //            string Data = string.Empty;
                    //            List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                    //            ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=72/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                    //            newsmodel.Title = "亲，欢迎关注【欧泉美业】！";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            listModel.Add(newsmodel);
                    //            newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                    //            newsmodel.Title = "绑定【欧泉美业】账号";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    //        }
                    //        break;
                    //    //语音
                    //    case "voice":
                    //        WriteContent(ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), root["Recognition"].InnerText));
                    //        break;
                    //}
                    #endregion
                }
            }
            return View();
        }

        public ViewResult mulisha()
        {
            string signature = System.Web.HttpContext.Current.Request["signature"];
            string timestamp = System.Web.HttpContext.Current.Request["timestamp"];
            string nonce = System.Web.HttpContext.Current.Request["nonce"];
            string echostr = System.Web.HttpContext.Current.Request["echostr"];
            HS.Framework.Common.WeChat.WeChat wechat = new HS.Framework.Common.WeChat.WeChat();
            WXCompanyInfoBase baseinfo = wechat.GetBaseInfo(14);
            string accessToken = string.Empty;
            accessToken = wechat.GetWeChatToken(14);
            string EnCodeCompanyID = HttpUtility.UrlEncode(HS.Framework.Common.Safe.CryptDES.DESEncrypt("14", "65033255", true));
            //认证
            if (Request.HttpMethod == "GET")
            {
                //get method - 仅在微信后台填写URL验证时触发
                if (CheckSignature.Check(signature, timestamp, nonce, baseinfo.Token))
                {
                    WriteContent(echostr); //返回随机字符串则表示验证通过
                }
                else
                {
                    WriteContent("failed:" + signature + "," + CheckSignature.GetSignature(timestamp, nonce, baseinfo.Token) + "。" +
                                "如果你在浏览器中看到这句话，说明此地址可以被作为微信公众账号后台的Url，请注意保持Token一致。");
                }
                Response.End();
            }
            else
            {
                Stream s = Request.InputStream;
                string postStr = "";
                byte[] b = new byte[s.Length];
                s.Read(b, 0, (int)s.Length);
                postStr = Encoding.UTF8.GetString(b);

                LogUtil.Log("解密前", postStr);

                Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(baseinfo.Token, baseinfo.EncodingAESKey, baseinfo.APPID);

                string temp = "";
                wxcpt.DecryptMsg(signature, timestamp, nonce, postStr, ref temp);

                LogUtil.Log("解密后", temp);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(temp);
                if (doc != null && doc.InnerXml != "")
                {
                    XmlNode root = null;
                    root = doc.FirstChild;
                    string toUserName = root["ToUserName"].InnerText;
                    string FromUserName = root["FromUserName"].InnerText;
                    string msgType = root["MsgType"].InnerText;
                    if (msgType.ToLower() == "event" && root["Event"].InnerText == "subscribe")
                    {
                        string Data = string.Empty;
                        List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                        ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=14/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                        newsmodel.Title = "亲，欢迎关注【慕丽莎】！";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                        newsmodel.Title = "绑定【慕丽莎】账号";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    }
                    else
                    {
                        string temp1 = string.Empty;
                        string neirong  = "感谢您关注慕丽莎，您身边的美丽专家。\n"
                                        + "--------------------------------\n"
                                        + "随时查询消费记录、会员卡余额；在线购买、预约服务；第一时间获取优惠信息。更多惊喜等待您的发掘！\n"
                                        + "--------------------------------\n"
                                        + "请使用菜单栏选择您想要的服务内容。";
                        neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), neirong);
                        wxcpt.EncryptMsg(neirong, timestamp, nonce, ref temp1);
                        WriteContent(temp1);
                    }

                    #region 暂时不要
                    //switch (msgType.ToLower())
                    //{
                    //    //文字
                    //    case "text":

                    //        string Content = root["Content"].InnerText;
                    //        string neirong = string.Empty;
                    //        if (msgType.ToUpper().Equals("TEXT") && Content.Equals("新闻"))
                    //        {
                    //            List<WeChat.ReplyTemplate.NewsModel> list = new List<ReplyTemplate.NewsModel>();
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去百度哦", Title = "点一下就带你去百度哦？", Url = "http://www.baidu.com", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去苏宁哦", Title = "点一下就带你去苏宁哦？", Url = "http://www.suning.com/", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });

                    //            neirong = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), list);

                    //            WriteContent(neirong);
                    //        }
                    //        else
                    //        {

                    //        }
                    //        break;
                    //    //事件
                    //    case "event":
                    //        //订阅
                    //        if (root["Event"].InnerText == "subscribe")
                    //        {
                    //            string Data = string.Empty;
                    //            List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                    //            ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=14/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                    //            newsmodel.Title = "亲，欢迎关注【慕丽莎】！";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            listModel.Add(newsmodel);
                    //            newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                    //            newsmodel.Title = "绑定【慕丽莎】账号";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    //        }
                    //        break;
                    //    //语音
                    //    case "voice":
                    //        WriteContent(ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), root["Recognition"].InnerText));
                    //        break;
                    //}
                    #endregion
                }
            }
            return View();
        }

        public ActionResult set()
        {
            string signature = System.Web.HttpContext.Current.Request["signature"];
            string timestamp = System.Web.HttpContext.Current.Request["timestamp"];
            string nonce = System.Web.HttpContext.Current.Request["nonce"];
            string echostr = System.Web.HttpContext.Current.Request["echostr"];
            string strCompanyID = System.Web.HttpContext.Current.Request["CI"];
            string strCompanyName = System.Web.HttpContext.Current.Request["CN"];
            string strTestFlag = System.Web.HttpContext.Current.Request["TF"];

            string strTest = string.Empty;
            if (strTestFlag == "1")
            {
                strTest = "test.";
            }

            HS.Framework.Common.WeChat.WeChat wechat = new HS.Framework.Common.WeChat.WeChat();
            WXCompanyInfoBase baseinfo = wechat.GetBaseInfo(Int32.Parse(strCompanyID));
            string accessToken = string.Empty;
            accessToken = wechat.GetWeChatToken(Int32.Parse(strCompanyID));
            string EnCodeCompanyID = HttpUtility.UrlEncode(HS.Framework.Common.Safe.CryptDES.DESEncrypt(strCompanyID, "65033255", true));
            //认证
            if (Request.HttpMethod == "GET")
            {
                //get method - 仅在微信后台填写URL验证时触发
                if (CheckSignature.Check(signature, timestamp, nonce, baseinfo.Token))
                {
                    return Content(echostr); //返回随机字符串则表示验证通过
                }
                else
                {
                    return Content("failed:" + signature + "," + CheckSignature.GetSignature(timestamp, nonce, baseinfo.Token) + "。" +
                                "如果你在浏览器中看到这句话，说明此地址可以被作为微信公众账号后台的Url，请注意保持Token一致。");
                }
                Response.End();
            }
            else
            {
                Stream s = Request.InputStream;
                string postStr = "";
                byte[] b = new byte[s.Length];
                s.Read(b, 0, (int)s.Length);
                postStr = Encoding.UTF8.GetString(b);

                //LogUtil.Log("解密前", postStr);

                Tencent.WXBizMsgCrypt wxcpt = new Tencent.WXBizMsgCrypt(baseinfo.Token, baseinfo.EncodingAESKey, baseinfo.APPID);

                string temp = "";
                wxcpt.DecryptMsg(signature, timestamp, nonce, postStr, ref temp);

                //LogUtil.Log("解密后", temp);

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(temp);
                if (doc != null && doc.InnerXml != "")
                {
                    XmlNode root = null;
                    root = doc.FirstChild;
                    string toUserName = root["ToUserName"].InnerText;
                    string FromUserName = root["FromUserName"].InnerText;
                    string msgType = root["MsgType"].InnerText;
                    if (msgType.ToLower() == "event" && root["Event"].InnerText == "subscribe")
                    {
                        string Data = string.Empty;
                        List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                        ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://data." + strTest + "beauty.glamise.com/GetThumbnail.aspx?fn=" + strCompanyID + "/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                        newsmodel.Title = "亲，欢迎关注【" + strCompanyName + "】！";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t." + strTest + "beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        newsmodel = new ReplyTemplate.NewsModel();
                        newsmodel.PicUrl = "http://Mobile." + strTest + "Beauty.Glamise.com/pic/Link.png";
                        newsmodel.Title = "♥   绑定【" + strCompanyName + "】账号";
                        newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t." + strTest + "beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                        listModel.Add(newsmodel);
                        string temp2 = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel);
                        return Content(temp2, "text/xml");
                    }
                    else
                    {
                        string temp1 = string.Empty;
                        string neirong = "感谢您关注" + strCompanyName + "，您身边的美丽专家。\n"
                                        + "--------------------\n"
                                        + "随时查询消费记录、会员卡余额；在线购买、预约服务；第一时间获取优惠信息。更多惊喜等待您的发掘！\n"
                                        + "--------------------\n"
                                        + "请使用菜单栏选择您想要的服务内容。";
                        neirong = ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), neirong);
                        wxcpt.EncryptMsg(neirong, timestamp, nonce, ref temp1);
                        return Content(temp1, "text/xml");                        
                    }

                    #region 暂时不要
                    //switch (msgType.ToLower())
                    //{
                    //    //文字
                    //    case "text":

                    //        string Content = root["Content"].InnerText;
                    //        string neirong = string.Empty;
                    //        if (msgType.ToUpper().Equals("TEXT") && Content.Equals("新闻"))
                    //        {
                    //            List<WeChat.ReplyTemplate.NewsModel> list = new List<ReplyTemplate.NewsModel>();
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去百度哦", Title = "点一下就带你去百度哦？", Url = "http://www.baidu.com", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });
                    //            list.Add(new ReplyTemplate.NewsModel() { Description = "点一下就带你去苏宁哦", Title = "点一下就带你去苏宁哦？", Url = "http://www.suning.com/", PicUrl = "http://www.hsquare-tech.com/Image/jianjie.png" });

                    //            neirong = ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), list);

                    //            WriteContent(neirong);
                    //        }
                    //        else
                    //        {

                    //        }
                    //        break;
                    //    //事件
                    //    case "event":
                    //        //订阅
                    //        if (root["Event"].InnerText == "subscribe")
                    //        {
                    //            string Data = string.Empty;
                    //            List<ReplyTemplate.NewsModel> listModel = new List<ReplyTemplate.NewsModel>();
                    //            ReplyTemplate.NewsModel newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://data.beauty.glamise.com/GetThumbnail.aspx?fn=46/Company/Logo_wxmp.png&th=900&tw=500&bg=FFFFFF";
                    //            newsmodel.Title = "亲，欢迎关注【汉弘科技】！";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.test.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            listModel.Add(newsmodel);
                    //            newsmodel = new ReplyTemplate.NewsModel();
                    //            newsmodel.PicUrl = "http://Mobile.Beauty.Glamise.com/pic/Link.png";
                    //            newsmodel.Title = "绑定【汉弘科技】账号";
                    //            newsmodel.Url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + baseinfo.APPID + "&redirect_uri=http://t.test.beauty.glamise.com/Account/MyHome&response_type=code&scope=snsapi_base&state=" + EnCodeCompanyID + "#wechat_redirect";
                    //            WriteContent(ReplyTemplate.NewsModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), listModel));
                    //        }
                    //        break;
                    //    //语音
                    //    case "voice":
                    //        WriteContent(ReplyTemplate.TextModeTemplate(FromUserName, toUserName, ((DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000).ToString(), root["Recognition"].InnerText));
                    //        break;
                    //}
                    #endregion
                }
            }
            return View();
        }


        public class PostModel
        {
            public string Signature { get; set; }
            public string Msg_Signature { get; set; }
            public string Timestamp { get; set; }
            public string Nonce { get; set; }
        }

        [Serializable]
        public class WXUserDetail
        {
            public int subscribe { get; set; }
            public string openid { get; set; }
            public string nickname { get; set; }
            public int sex { get; set; }
            public string language { get; set; }
            public string city { get; set; }
            public string province { get; set; }
            public string country { get; set; }
            public string headimgurl { get; set; }
            public long subscribe_time { get; set; }
            public string unionid { get; set; }
            public string remark { get; set; }
            public int groupid { get; set; }
        }

    }
}
