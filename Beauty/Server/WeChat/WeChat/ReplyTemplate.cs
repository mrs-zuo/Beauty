using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WeChat
{
    public class ReplyTemplate
    {
        public static string TextModeTemplate(string toUserName, string fromUserName, string createTime, string content)
        {
            string res = @" <xml>
                                <ToUserName><![CDATA[{0}]]></ToUserName>
                                <FromUserName><![CDATA[{1}]]></FromUserName>
                                <CreateTime>{2}</CreateTime>
                                <MsgType><![CDATA[text]]></MsgType>
                                <Content><![CDATA[{3}]]></Content>
                                </xml>";

            res = string.Format(res, toUserName, fromUserName, createTime, content);

            return res;
        }

        public static string PicModeTemplate(string toUserName, string fromUserName, string createTime, string ImageID)
        {
            string res = @" <xml>
                                <ToUserName><![CDATA[{0}]]></ToUserName>
                                <FromUserName><![CDATA[{1}]]></FromUserName>
                                <CreateTime>{2}</CreateTime>
                                <MsgType><![CDATA[image]]></MsgType>
                                <Image>
                                    <MediaId><![CDATA[{3}]]></MediaId>
                                </Image>
                                </xml>";

            res = string.Format(res, toUserName, fromUserName, createTime, ImageID);

            return res;
        }

        public static string NewsModeTemplate(string toUserName, string fromUserName, string createTime, List<NewsModel> list)
        {
            string res = @" <xml>
                                <ToUserName><![CDATA[{0}]]></ToUserName>
                                <FromUserName><![CDATA[{1}]]></FromUserName>
                                <CreateTime>{2}</CreateTime>
                                <MsgType><![CDATA[news]]></MsgType>
                                <ArticleCount>{3}</ArticleCount>
                                <Articles>";
            res = string.Format(res, toUserName, fromUserName, createTime, list.Count);

            foreach (NewsModel item in list)
            {
                res += " <item>";
                res += "<Title><![CDATA[" + item.Title + "]]></Title>";
                res += "<Description><![CDATA[" + item.Description + "]]></Description>";
                res += "<PicUrl><![CDATA[" + item.PicUrl + "]]></PicUrl>";
                res += "<Url><![CDATA[" + item.Url + "]]></Url>";
                res += "</item> ";
            }

            res += "</Articles></xml>";

            return res;
        }

        public static string VoiceModeTemplate(string toUserName, string fromUserName, string createTime, string mediaID)
        { 
            string res = @" <xml>
                                <ToUserName><![CDATA[{0}]]></ToUserName>
                                <FromUserName><![CDATA[{1}]]></FromUserName>
                                <CreateTime>{2}</CreateTime>
                                <MsgType><![CDATA[voice]]></MsgType>
                                <Voice>
                                <MediaId><![CDATA[{2}]]></MediaId>
                                </Voice>
                                </xml>";

            res = string.Format(res, toUserName, fromUserName, createTime, mediaID);

            return res;
        }

        public class NewsModel
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string PicUrl { get; set; }
            public string Url { get; set; }
        }
    }
}