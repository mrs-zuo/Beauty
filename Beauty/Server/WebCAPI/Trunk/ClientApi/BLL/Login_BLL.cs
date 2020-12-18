using ClientAPI.DAL;
using HS.Framework.Common.Caching;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;

namespace ClientAPI.BLL
{
    public class Login_BLL
    {
        #region 构造类实例
        public static Login_BLL Instance
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
            internal static readonly Login_BLL instance = new Login_BLL();
        }
        #endregion

        public bool CheckIdentity(string GUID, int CompanyID, int BranchID, int UserID, int ClientType, out int RealUserType)
        {
            RealUserType = 0;
            //if (UserType == 3)
            //    UserType = 1;
            //else if (UserType == 4)
            //    UserType = 2;

            if (ClientType == 3)
            {
                RealUserType = 1;
            }
            else if (ClientType == 4)
            {
                RealUserType = 2;
            }

            var data = MemcachedNew.Get("Identity", CompanyID + "^" + UserID + "^" + ClientType);
            if (data == null)
            {
                //缓存不存在 从数据库取
                UtilityOperation_Model model = Login_DAL.Instance.getUserInfo(CompanyID, BranchID, UserID, GUID);
                if (model != null)
                {
                    MemcachedNew.Set("Identity", model.CompanyID + "^" + model.UserID + "^" + ClientType, model.CompanyID + "^" + model.BranchID + "^" + model.UserID + "^" + model.GUID + "^" + ClientType);
                    RealUserType = model.UserType;
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                //缓存有数据 则比对是否相同
                string strTemp = CompanyID + "^" + BranchID + "^" + UserID + "^" + GUID + "^" + ClientType;
                if (strTemp == data.ToString())
                {
                    //RealUserType = Convert.ToInt32(data.ToString().Substring(data.ToString().LastIndexOf('^') + 1, data.ToString().Length - data.ToString().LastIndexOf('^') - 1));
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public ObjectResult<RoleForLogin_Model> updateLoginInfo(Login_Model loginModel, int ClientType)
        {
            ObjectResult<RoleForLogin_Model> result = Login_DAL.Instance.updateLoginInfo(loginModel);
            if (result.Code == "1")
            {
                MemcachedNew.Set("Identity", result.Data.CompanyID + "^" + result.Data.UserID + "^" + ClientType, result.Data.CompanyID + "^" + result.Data.BranchID + "^" + result.Data.UserID + "^" + loginModel.GUID + "^" + ClientType);
            }
            return result;
        }

        public void logOut(string GUID, int CompanyID, int BranchID, int UserID, int ClientType)
        {
            MemcachedNew.Remove("Identity", CompanyID + "^" + UserID + "^" + ClientType);
            Login_DAL.Instance.logOut(GUID, CompanyID, UserID, ClientType);
        }

        public ObjectResult<object> getCompanyListForCustomer(Login_Model loginModel)
        {
            ObjectResult<object> companyList = Login_DAL.Instance.getCompanyListForCustomer(loginModel);
            return companyList;
        }

        public Login_Model getUserByWeChatOpenID(int companyID, string weChatOpenID)
        {
            Login_Model model = Login_DAL.Instance.getUserByWeChatOpenID(companyID, weChatOpenID);
            return model;
        }

        public ObjectResult<RoleForLogin_Model> updateLoginInfoForWeChat(Login_Model loginModel)
        {
            ObjectResult<RoleForLogin_Model> result = Login_DAL.Instance.updateLoginInfoForWeChat(loginModel);
            if (result.Code == "1")
            {
                MemcachedNew.Set("Identity", result.Data.CompanyID + "^" + result.Data.UserID + "^4", result.Data.CompanyID + "^" + result.Data.BranchID + "^" + result.Data.UserID + "^" + loginModel.GUID + "^" + "4");
            }
            return result;
        }

        public ObjectResult<CompanyListForCustomerLogin_Model> bindWeChatOpenID(Login_Model loginModel, string fileName, int sex)
        {
            ObjectResult<CompanyListForCustomerLogin_Model> model = Login_DAL.Instance.bindWeChatOpenID(loginModel, fileName, sex);
            return model;
        }


        public bool updateUserPassword(int userId, string oldPassword, string newPassword)
        {
            return Login_DAL.Instance.updateUserPassword(userId, oldPassword, newPassword);
        }

        public int getAuthenticationCode(string loginMobile, int companyId,int creatorID)
        {
            byte[] buffer = Guid.NewGuid().ToByteArray();
            int iSeed = BitConverter.ToInt32(buffer, 0);
            Random random = new Random(iSeed);
            string authenticationCode = random.Next(1000000).ToString("d6");
            string strKey = companyId.ToString() + "/" + loginMobile;
            MemcachedNew.Set("AuthenticationCode", strKey, authenticationCode, 7200);
            #region 可发短信情况
            UtilityOperation_Model model = Customer_BLL.Instance.getCustomerInfo(loginMobile, companyId);
            if (model !=null) {
                companyId = model.CompanyID;
            }
            GetVSMSINFO_Model vSMSINFO_Model = new GetVSMSINFO_Model();
            vSMSINFO_Model = SMSINFO_BLL.Instance.getVSMSINFODetail(companyId);
            #endregion

            #region 获取公司短信抬头
            PushOperation_Model pushmodel = Company_DAL.Instance.getCompanyInfo(loginMobile, companyId);
            if (pushmodel == null) {
                return 0;
            }
            #endregion
            #region   可发送短信件数大于已发送短信件数
            if (vSMSINFO_Model.SMSNum > vSMSINFO_Model.SentNum)
            {
                //保存短信发送履历信息
                string msg = string.Format(Const.MESSAGE_AUTHENTICATIONCODE, pushmodel.CompanyName, authenticationCode, 0,1);
                DateTime time = DateTime.Now.ToLocalTime();
                AddSMSHIS_Model addSMSHIS_Model = new AddSMSHIS_Model
                {
                    COMPANYID = companyId,
                    RcvNumber = loginMobile,
                    CreatorID = creatorID,
                    CreateTime = time,
                    SendTime = time,
                    SMSContent = msg
                };
                SMSINFO_BLL.Instance.addSMSHIS_Model(addSMSHIS_Model);
                return WebAPI.Common.SendShortMessage.sendShortMessage(loginMobile, authenticationCode, pushmodel.CompanyName, 0);
            } else {
                return 0;
            }
            #endregion
        }

        public ObjectResult<List<CompanyListByLoginMobile_Model>> checkAuthenticationCode(string loginMobile, string authenticationCode, int companyId)
        {
            ObjectResult<List<CompanyListByLoginMobile_Model>> result = new ObjectResult<List<CompanyListByLoginMobile_Model>>();
            result.Code = "0";
            result.Data = null;
            result.Message = "";

            string strKey = companyId.ToString() + "/" + loginMobile;
            var data = MemcachedNew.Get("AuthenticationCode", strKey);
            if (data != null)
            {
                if (authenticationCode == (string)data)
                {
                    MemcachedNew.Remove("AuthenticationCode", loginMobile);
                    result = Login_DAL.Instance.getCompanyListByLoginMobile(loginMobile, companyId);
                }
            }
            return result;
        }

        public bool updateUserPassword(Login_Model model)
        {
            return Login_DAL.Instance.updateUserPassword(model);
        }

        public bool unBindWeChat(string GUID, int CompanyID, int UserID, int ClientType)
        {

            MemcachedNew.Remove("Identity", CompanyID + "^" + UserID + "^" + ClientType);
            return Login_DAL.Instance.unBindWeChat(GUID, CompanyID, UserID, ClientType);
        }

    }
}
