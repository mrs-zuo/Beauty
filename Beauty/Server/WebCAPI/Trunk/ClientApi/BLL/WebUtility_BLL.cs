using ClientAPI.DAL;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class WebUtility_BLL
    {
        #region 构造类实例
        public static WebUtility_BLL Instance
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
            internal static readonly WebUtility_BLL instance = new WebUtility_BLL();
        }

        #endregion

        public void CustomerLocation(CustomerLocation_Model model)
        {
            WebUtility_DAL.Instance.CustomerLocation(model);
        }

        public string GetDomain(int Type)
        {
            string strDomain = "";
            switch (Type)
            {
                case 1:
                    strDomain = "https://t.beauty.glamise.com/";
                    break;
                case 2:
                    strDomain = "http://t.test.beauty.glamise.com/";
                    break;
                default:
                    strDomain = "https://t.beauty.glamise.com/";
                    break;
            }
            return strDomain;
        }
    }
}
