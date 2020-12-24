using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.Common
{
    public class Const
    {

        static string server_Image = System.Configuration.ConfigurationSettings.AppSettings["ImagePath"];
        public static readonly string server = ConfigurationSettings.AppSettings["ImageDoMain"];
        //public static readonly string server = ConfigurationManager.AppSettings["ReleaseServer"];
        public static readonly string uploadServer = ConfigurationSettings.AppSettings["ImageServer"];

        public static string getUserHeadImg = server_Image + " + CAST({0} AS NVARCHAR(10)) + '/Account/' + CAST({1} AS NVARCHAR(20)) + '/' + {2}+ '&th={3}&tw={4}&bg=FFFFFF' AS HeadImageURL";

        public static string getClientTopPromotionImg = "'http://" + server + "/GetThumbnail.aspx?fn='+ CAST(T1.CompanyID AS NVARCHAR(20)) + '/Promotion/'+ CAST(T1.PromotionCode AS NVARCHAR(20)) + '/' + T1.ImageFile+ '&th={0}&tw={1}&bg=FFFFFF' PromotionPictureURL";

        public static string getPromotionImg = server_Image + " + CAST(T1.CompanyID AS NVARCHAR(20)) + '/Promotion/'+ CAST(T1.ID AS NVARCHAR(20)) + '/' + T1.ImageFile+ '&th={0}&tw={1}&bg=FFFFFF' PromotionPictureURL";

        public static string getCompanyImg = server_Image + " + CAST(T1.CompanyID AS NVARCHAR(20)) + '/Company/' + T1.FileName+ '&th={0}&tw={1}&bg=FFFFFF' AS CompanyImgURL";

        public static string getBranchImg = server_Image + " + CAST(T1.CompanyID AS NVARCHAR(20)) + '/Branch/'+ CAST(T1.BranchID AS NVARCHAR(20)) + '/' + T1.FileName+ '&th={0}&tw={1}&bg=FFFFFF' AS BranchImgURL";

        public static string getServiceImg = server_Image + " + CAST(T1.CompanyID AS NVARCHAR(20)) + '/Service/'+ CAST({0} AS NVARCHAR(20)) + '/' + {1}+ '&th={2}&tw={3}&bg=FFFFFF' AS ProductImgURL";

        public static string getCommodityImg = server_Image + " + CAST(T1.CompanyID AS NVARCHAR(20)) + '/Commodity/'+ CAST({0} AS NVARCHAR(20)) + '/' + {1}+ '&th={2}&tw={3}&bg=FFFFFF' AS ProductImgURL";

        public static string getPromotionImgForManager = "'http://" + server + "/GetThumbnail.aspx?fn='+ cast(T1.CompanyID as nvarchar(20)) +'/Promotion/'+ cast(T1.PromotionCode as nvarchar(20))+ '/' + T1.ImageFile +'&biFlg=1' AS PromotionImgUrl ";

        public static string getAccountImgForManager = strHttp + server + strMothod + "'+ cast(T1.CompanyID as nvarchar(20)) + '/" + strImageObjectType1 + "'+ cast(T1.UserID as nvarchar(20))+ '/' + T1.HeadImageFile +'&biFlg=1' AS HeadImageFile ";

        public static string getAccountImgForManagerList = strHttp + server + strMothod + "'+ cast(T1.CompanyID as nvarchar(20)) + '/" + strImageObjectType1 + "'+ cast(T1.UserID as nvarchar(20))+ '/' + T1.HeadImageFile +'&th=70&tw=70' AS HeadImageFile ";

        public static string getServiceImgForManager = "'http://" + server + "/GetThumbnail.aspx?fn='+ cast(T1.CompanyID as nvarchar(20)) +'/Service/'+ cast(T1.ServiceCode as nvarchar(20))+ '/' + T1.FileName +'&biFlg=1' AS FileUrl ";

        public static string getCustomerHeadImg = "'http://" + server + "/GetThumbnail.aspx?fn='+ cast({0} as nvarchar(20)) + '/Customer/'+ cast({1} as nvarchar(20))+ '/' + {2} + '&th={3}&tw={4}&bg=FFFFFF' AS HeadImageURL ";

        //WebService全局常量
        public const string strThumbTreatment = "'&th=120&tw=120&bg=FFFFFF'";
        public const string strThumb = "'&th=' + @ImageHeight + '&tw=' + @ImageWidth + '&bg=FFFFFF'";
        public const string strBigImageFlg = "+'&biFlg=1'";
        public const string strHttp = "'http://";
        public const string strMothod = "/GetThumbnail.aspx?fn=";
        public static readonly string strImage = ConfigurationSettings.AppSettings["ImageFolder"];
        public const string strImageObjectType0 = "Customer/";
        public const string strImageObjectType1 = "Account/";
        public const string strImageObjectType2 = "Company/";
        public const string strImageObjectType3 = "Item/";
        public const string strImageObjectType4 = "TreatGroup/";
        public const string strImageObjectType5 = "Promotion/";
        public const string strImageObjectType6 = "Commodity/";
        public const string strImageObjectType7 = "Branch/";
        public const string strImageObjectType8 = "Service/";
        public const string strImageObjectType9 = "Category/";
        public const string strImageObjectType10 = "TreatGroup/";
        public const string strImageCategory0 = "Head/";
        public const string strImageCategory1 = "Introduction/";
        public const string strImageCategory2 = "Before/";
        public const string strImageCategory3 = "After/";
        public const string strImageCategory4 = "Content/";
        public const string strImageCategory5 = "Thumbnail/";
        public const string strSingleMark = "'";


        public const string strTh = "'&th=";
        public const string strTw = "&tw=";
        public const string strBg = "&bg=FFFFFF'";

        public const string ImageNotAdd = "http://192.168.0.254:81/image/default/256x140NotAdd.png";
        public const string ImageGetFail = "http://192.168.0.254:81/image/default/256x140GetFail.png";
        public const string ImageNotExist = "http://192.168.0.254:81/image/default/256x140NotExist.png";
        public static readonly string[] strAccountRolePermission_Mobile = new string[] { "MyCustomer_Read", "AllCustomer_Read", "CustomerInfo_Read", "CustomerInfo_Write", "Record_Read", "Record_Write", "Order_Read", "Order_Write", "Payment_Use", "eCard_Read", "Recharge_Use", "CustomerLevel_Write", "Service_Read", "Commodity_Read", "Oppotunity_Use", "Chat_Use", "MyReport_Read", "BusinessReport_Read", "Marketing_Read", "Marketing_Write", "MyInfo_Write", "OrderTotalSalePrice_Write", "Money_Out" };
        public static readonly string[] strAccountRolePermission_Web = new string[] { "Service_Write", "Commodity_Write", "Marketing_Read", "Marketing_Write", "Notice_Write", "Promotion_Write", "BusinessInfo_Write", "MyInfo_Write", "AccountRole_Write", "Hierarchy_Write", "Relationship_Write", "RolePermission_Write", "LevelPolicy_Write", "Question_Write", "Step_Write", "Oppotunity_Use" };

        //Web用全局常量


        //SessionID 
        public const string SESSION_USERHEADIMAGE = "GlamourPromise_UserHeadImage";
        public const string SESSION_USERID = "GlamourPromise_UserID";
        public const string SESSION_COMPANYID = "GlamourPromise_CompanyID";
        public const string SESSION_BRANCHID = "GlamourPromise_BranchID";
        public const string SESSION_COMPANYCODE = "GlamourPromise_CompanyCode";
        public const string SESSION_USERNAME = "GlamourPromise_UserName";
        public const string SESSION_KEEPPAGEINFO = "GlamourPromise_KeepPageInfo";
        public const string SESSION_SORTEXPRESSION = "GlamourPromise_SortExpression";
        public const string SESSION_SORTDIRECTION = "GlamourPromise_SortDirection";
        public const string SESSION_PAGEINDEX = "GlamourPromise_PageIndex";
        public const string SESSION_QUERYSTR = "GlamourPromise_QueryStr";
        public const string SESSION_VALIDATECODE = "GlamourPromise_ValidateCode";
        public const string SESSION_ROLE = "GlamourPromise_Role";
        public const string SESSION_LOGINERROR = "GlamourPromise_LoginError";
        public const string SESSION_COMPANYSCALE = "GlamourPromise_CompanyScale";
        public const string SESSION_ADVANCED = "GlamourPromise_Advanced";


        //SessionRolePermission
        public const string SESSION_SERVICE_WRITE = "GlamourPromise_Service_Write";
        public const string SESSION_COMMODITY_WRITE = "GlamourPromise_Commodity_Write";
        public const string SESSION_MARKETING_READ = "GlamourPromise_Marketing_Read";
        public const string SESSION_MARKETING_WRITE = "GlamourPromise_Marketing_Write";
        public const string SESSION_NOTICE_WRITE = "GlamourPromise_Notice_Write";
        public const string SESSION_PROMOTION_WRITE = "GlamourPromise_Promotion_Write";
        public const string SESSION_BUSINESSINFO_WRITE = "GlamourPromise_BusinessInfo_Write";
        public const string SESSION_MYINFO_WRITE = "GlamourPromise_MyInfo_Write";
        public const string SESSION_ACCOUNTROLE_WRITE = "GlamourPromise_AccountRole_Write";
        public const string SESSION_HIERARCHY_WRITE = "GlamourPromise_Hierarchy_Write";
        public const string SESSION_RELATIONSHIP_WRITE = "GlamourPromise_Relationship_Write";
        public const string SESSION_ROLEPERMISSION_WRITE = "GlamourPromise_RolePermission_Write";
        public const string SESSION_LEVELPOLICY_WRITE = "GlamourPromise_LevelPolicy_Write";
        public const string SESSION_QUESTION_WRITE = "GlamourPromise_Question_Write";
        public const string SESSION_STEP_WRITE = "GlamourPromise_Step_Write";
        public const string SESSION_DOWNLOAD = "GlamourPromise_Download";
        public const string SESSION_CUSTOMERINFO_DOWNLOAD = "GlamourPromise_CustomerInfo_Download";
        public const string SESSION_COMMODITYSTOCKOPERATELOG_DOWNLOAD = "GlamourPromise_CommodityStockOperateLog_Download";
        public const string SESSION_COMMODITYSTOCK_DOWNLOAD = "GlamourPromise_CommodityStock_Download";
        public const string SESSION_ACCOUNTPERFORMANCE_DOWNLOAD = "GlamourPromise_AccountPerformance_Download";
        public const string SESSION_BALANCEDETAILDATA_DOWNLOAD = "GlamourPromise_BalanceDetailData_Download";
        public const string SESSION_PEOPLESTATISTICS_DOWNLOAD = "GlamourPromise_PeopleStatistics_Download";

        //Cookie Name
        public const string COOKIE_LANGUAGE = "GlamourPromise_Language";
        public const string COOKIE_USERNAME = "GlamourPromise_UserName";
        public const string COOKIE_PASSWORD = "GlamourPromise_PassWord";

        //Languge
        public const string ENGLISH = "English";
        public const string CHINISESIMPLE = "中文（简体）";

        //短信模板
        public const string MESSAGE_GLAMOURPROMISE = "美丽约定";
        public const string MESSAGE_AUTHENTICATIONCODE = "{0}：您的验证码为{1}，请在页面中输入验证码完成验证，该验证码五分钟内有效。";
        public const string MESSAGE_PASSWORD = "{0}：您的初始登录密码（验证码）{1}。欢迎使用美丽约定app。";
        public const string MESSAGE_BALANCE = "您在{0}的e卡余额于{1}发生变动，详情请使用客户端确认。";

        //到日导出列名
        public static readonly Dictionary<string, string> EXPORT_SERVICENAMEEXCHANGE = new Dictionary<string, string>{
        {"ServiceID", "服务编号"},{"CategoryName", "所属分类"},{"CategoryID","所属分类编号"},{"ServiceName", "服务名称"},{"UnitPrice", "单价"},{"RelativePath", "路径"}
        ,{"MarketingPolicy", "营销策略"},{"PromotionPrice", "促销价"},{"SubServiceName","服务子项"},{"SubServiceCodes","服务子项编号"},{"Describe", "服务描述"}
        ,{"CourseFrequency", "服务次数"},{"SpendTime", "服务时间"},{"VisitTime", "回访周期"}
        ,{"Available", "是否有效"},{"VisibleForCustomer", "是否对客户可见"},{"ExpirationDate", "服务有效期"}
        ,{"NeedVisit", "是否需要回访"},{"HaveExpiration", "是否有有效期"}
        ,{"DiscountName","折扣名称"},{"DiscountID","折扣编号"},{"IsConfirmed","确认方式"},{"AutoConfirm","自动确认"},{"AutoConfirmDays","自动确认等待日数"}
        };
        public static readonly Dictionary<string, string> EXPORT_COMMODITYNAMEEXCHANGE = new Dictionary<string, string>{
        {"CommodityID", "商品编号"},{"CategoryName", "所属分类"},{"CategoryID","所属分类编号"},{"CommodityName", "商品名称"},{"UnitPrice", "单价"},{"RelativePath", "路径"}
        ,{"MarketingPolicy", "营销策略"},{"PromotionPrice", "促销价"},{"Describe", "描述"}
        ,{"Specification", "规格"},{"New", "新品"}
        ,{"Recommended", "推荐"},{"Available", "是否有效"},{"VisibleForCustomer", "客户是否可见"}
        ,{"DiscountName","折扣名称"},{"DiscountID","折扣编号"},{"IsConfirmed","确认方式"},{"AutoConfirm","自动确认"},{"AutoConfirmDays","自动确认等待日数"}, { "Manufacturer","生产厂家"}, { "ApprovalNumber","批准文号"}
        };
        public static readonly Dictionary<string, string> EXPORT_COMMODITYBATCHINFO = new Dictionary<string, string>{
        {"CommodityName", "商品名称"},{"BatchNO","批次番号"},{"Quantity","数量(格式为:数字)"},{"ExpiryDate","有效期(格式:2020/12/12)"},{"SupplierName","供应商名称"}
        };
        //文件地址用
        public const string strFileHttp = "http://";

        //默认的分店的StartTime
        public static readonly DateTime DefaultBranchStartTime = HS.Framework.Common.Util.StringUtils.GetDateTime("1970-01-01");

        #region Web权限对应字符串
        public const string ROLE_SERVICE_WRITE = "|12|";
        public const string ROLE_COMMODITY_WRITE = "|14|";
        public const string ROLE_NOTICE_WRITE = "|18|";
        public const string ROLE_PROMOTION_WRITE = "|19|";
        public const string ROLE_BUSINESSINFO_WRITE = "|20|";
        public const string ROLE_MYINFO_WRITE = "|21|";
        public const string ROLE_ACCOUNTROLE_WRITE = "|22|";
        public const string ROLE_HIERARCHY_WRITE = "|23|";
        public const string ROLE_RELATIONSHIP_WRITE = "|24|";
        public const string ROLE_ROLEPERMISSION_WRITE = "|25|";
        public const string ROLE_LEVELPOLICY_WRITE = "|26|";
        public const string ROLE_QUESTION_WRITE = "|27|";
        public const string ROLE_STEP_WRITE = "|31|";
        public const string ROLE_MARKETING_READ = "|32|";
        public const string ROLE_MARKETING_WRITE = "|33|";
        public const string ROLE_DOWNLOAD = "|36|";
        public const string ROLE_COMMODITYSTOCKOPERATELOG_DOWNLOAD = "|37|";
        public const string ROLE_CUSTOMERINFO_DOWNLOAD = "|38|";
        public const string ROLE_COMMODITYSTOCK_DOWNLOAD = "|39|";
        public const string ROLE_ACCOUNTPERFORMANCE_DOWNLOAD = "|40|";
        public const string ROLE_BALANCEDETAILDATA_DOWNLOAD = "|42|";
        public const string ROLE_PEOPLESTATISTICS_DOWNLOAD = "|43|";
        public const string ROLE_SENIORFUNCTION_USE = "|46|";
        public const string ROLE_ATTENDANCE = "|47|";
        public const string ROLE_PROFITCOMMRULE = "|48|";
        public const string ROLE_SMSInfo = "|56|";

        public const string AllWebRole = "|12|14|18|19|20|21|22|23|24|25|26|27|31|32|33|36|37|38|39|40|42|43|46|47|48|56|";
        #endregion

        #region Mobile 对应权限
        public const string ROLE_MYORDER_WRITE = "|6|";
        public const string ROLE_ALLORDER_WRITE = "|45|";
        #endregion
    }
}
