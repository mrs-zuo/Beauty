using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            string token = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile("GetAccountListByCompanyIDCompanyID=7&PageIndex=1&Type=0&ImageHeight=170&ImageWidth=170&PageSize=15" + "HS", "MD5");

            NameValueCollection headers = new NameValueCollection();
            headers.Add("Authorization", token);
            string a = HS.Framework.Common.Net.NetUtil.GetResponse("http://www.webapi.com/api/Account/GetAccountListByCompanyID", "CompanyID=7&PageIndex=1&Type=0&ImageHeight=170&ImageWidth=170&PageSize=15", headers);
            Console.Write(a);
            Console.Read();
        }
    }
}
