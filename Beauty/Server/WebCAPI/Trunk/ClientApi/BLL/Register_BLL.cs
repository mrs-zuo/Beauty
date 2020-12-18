using ClientAPI.DAL;
using HS.Framework.Common.Caching;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
   public  class Register_BLL
   {
       #region 构造类实例
       public static Register_BLL Instance
       {
           get
           {
               return Nested.instance;
           }
       }

       class Nested
       {
           static Nested()
           {
           }
           internal static readonly Register_BLL instance = new Register_BLL();
       }
       #endregion



       public int checkAuthenticationCode(RegisterOperation_Model model)
       {
           string strKey = model.CompanyID.ToString() + "/" + model.LoginMobile;
           var data = MemcachedNew.Get("AuthenticationCode", strKey);
           if (data != null)
           {
               if (model.AuthenticationCode == (string)data)
               {
                   int result = Register_DAL.Instance.RegisterUser(model);
                   if (result == 1)
                   {
                       MemcachedNew.Remove("AuthenticationCode", model.LoginMobile);
                   }
                   return result;
               }
           }
           return 0;
       }
    }
}
