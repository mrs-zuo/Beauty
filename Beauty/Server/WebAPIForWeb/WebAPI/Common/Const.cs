using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.Common
{
    public class Const
    {
        static string server_Demo = "'http://demo.beauty.glamourpromise.com/GetThumbnail.aspx?fn=UserData/'";
        static string server_Dev = "'http://dev.bizapper.com/GetThumbnail.aspx?fn=UserData/'";
        static string server = System.Configuration.ConfigurationSettings.AppSettings["ImagePath"];
        public static string getUserHeadImg = server + " + CAST(T1.CompanyID AS NVARCHAR(10)) + '/Account/' + CAST(T1.UserID AS NVARCHAR(10)) + '/' + T1.HeadImageFile+ '&th={0}&tw={1}&bg=FFFFFF' AS HeadImageURL";

        public static string getPromotionImg = server + " + CAST(T1.CompanyID AS NVARCHAR(10)) + '/Promotion/'+ CAST(T1.ID AS NVARCHAR(10)) + '/' + T1.ImageFile+ '&th={0}&tw={1}&bg=FFFFFF' PromotionPictureURL";

        public static string getCompanyImg = server + " + CAST(T1.CompanyID AS NVARCHAR(10)) + '/Company/' + T1.FileName+ '&th={0}&tw={1}&bg=FFFFFF' AS CompanyImgURL";

        public static string getBranchImg = server + " + CAST(T1.CompanyID AS NVARCHAR(10)) + '/Branch/'+ CAST(T1.BranchID AS NVARCHAR(10)) + '/' + T1.FileName+ '&th={0}&tw={1}&bg=FFFFFF' AS BranchImgURL";

        public static string getServiceImg = server + " + CAST(T1.CompanyID AS NVARCHAR(10)) + '/Service/'+ CAST({0} AS NVARCHAR(16)) + '/' + {1}+ '&th={2}&tw={3}&bg=FFFFFF' AS ProductImgURL";

        public static string getCommodityImg = server + " + CAST(T1.CompanyID AS NVARCHAR(10)) + '/Commodity/'+ CAST({0} AS NVARCHAR(16)) + '/' + {1}+ '&th={2}&tw={3}&bg=FFFFFF' AS ProductImgURL";
    }
}
