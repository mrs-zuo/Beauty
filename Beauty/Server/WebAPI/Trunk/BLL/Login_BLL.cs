﻿using HS.Framework.Common.Caching;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;
using WebAPI.Common;

namespace WebAPI.BLL
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

        public ObjectResult<object> getCompanyListForAccount(Login_Model loginModel)
        {
            ObjectResult<object> result = Login_DAL.Instance.getCompanyListForAccount(loginModel);
            return result;
        }

        public ObjectResult<object> getCompanyListForCustomer(Login_Model loginModel)
        {
            //ObjectResult<object> result = new ObjectResult<object>();
            ObjectResult<object> companyList = Login_DAL.Instance.getCompanyListForCustomer(loginModel);

            return companyList;
            //result.Code = companyList.Code;
            //if (companyList.Code == "1")
            //{
            //int totalMessageCount = 0;
            //foreach (CompanyListForCustomerLogin_Model item in companyList.Data)
            //{
            //    item.RemindCount = Notice_DAL.Instance.getRemindNumberByCustomer(item.CustomerID);
            //    item.PromotionCount = Promotion_DAL.Instance.getPromotionCount(item.CompanyID, 0, item.BranchID);
            //    item.UnpaidOrderCount = Order_DAL.Instance.getUnpaidOrderCount(item.CustomerID);
            //    item.UnconfirmedOrderCount = Order_DAL.Instance.getUnconfirmedOrderList(item.CustomerID).Count;
            //    item.NewMessageCount = Message_DAL.Instance.getMsgCount(item.CustomerID).NewMessageCount;
            //    totalMessageCount += item.NewMessageCount;
            //}
            // companyList.Data[0].TotalMessageCount = totalMessageCount;
            // result.Data = companyList.Data;
            //}
            // return result;
        }

        public ObjectResult<RoleForLogin_Model> updateLoginInfo(Login_Model loginModel, int ClientType)
        {
            ObjectResult<RoleForLogin_Model> result = Login_DAL.Instance.updateLoginInfo(loginModel, true);
            if (result.Code == "1")
            {
                //string temp = isBussiness ? "1" : "2";
                MemcachedNew.Set("Identity", result.Data.CompanyID + "^" + result.Data.UserID + "^" + ClientType, result.Data.CompanyID + "^" + result.Data.BranchID + "^" + result.Data.UserID + "^" + loginModel.GUID + "^" + ClientType);
            }
            return result;
        }

        public bool CheckIdentity(string GUID, int CompanyID, int BranchID, int UserID, int ClientType, out int RealUserType)
        {
            RealUserType = 0;
            //if (UserType == 3)
            //    UserType = 1;
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
                    MemcachedNew.Set("Identity", model.CompanyID + "^" + model.UserID, model.CompanyID + "^" + model.BranchID + "^" + model.UserID + "^" + model.GUID + "^" + ClientType);
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
                    RealUserType = Convert.ToInt32(data.ToString().Substring(data.ToString().LastIndexOf('^') + 1, data.ToString().Length - data.ToString().LastIndexOf('^') - 1));
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public void logOut(string GUID, int CompanyID, int BranchID, int UserID)
        {
            MemcachedNew.Remove("Identity", CompanyID + "^" + UserID);
            Login_DAL.Instance.logOut(GUID, CompanyID, BranchID, UserID);
        }

        /// <summary>
        /// 更改密码
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="newPassword"></param>
        /// <returns></returns>
        public int updateUserPassword(int userId, string oldPassword, string newPassword)
        {
            return Login_DAL.Instance.updateUserPassword(userId, oldPassword, newPassword);
        }

        /// <summary>
        /// 更改密码
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="newPassword"></param>
        /// <returns></returns>
        public bool updateUserPassword(Login_Model model)
        {
            return Login_DAL.Instance.updateUserPassword(model);
        }

        public void getAuthenticationCode(string loginMobile)
        {
            System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
            string strPgm;  //当前的程序名称及行号等监察信息

            Random random = new Random();
            string authenticationCode = random.Next(1000000).ToString("d6");
            MemcachedNew.Set("AuthenticationCode", loginMobile, authenticationCode, 7200);

            strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
            int result = SMSINFO_BLL.Instance.getSMSInfo(0, loginMobile, strPgm, 0);
            if (result == 0)
            {
                Common.SendShortMessage.sendShortMessage(loginMobile, authenticationCode, "", 0);
                //保存短信发送履历信息
                string strMsg = string.Format(Const.MESSAGE_AUTHENTICATIONCODE, "", authenticationCode);
                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                SMSINFO_BLL.Instance.addSMSHis(0, 0, loginMobile, strMsg, strPgm, 0);
            }
        }


        public ObjectResult<List<CompanyListByLoginMobile_Model>> checkAuthenticationCode(string loginMobile, string authenticationCode)
        {
            ObjectResult<List<CompanyListByLoginMobile_Model>> result = new ObjectResult<List<CompanyListByLoginMobile_Model>>();
            result.Code = "0";
            result.Data = null;
            result.Message = "";

            var data = MemcachedNew.Get("AuthenticationCode", loginMobile);
            if (data != null)
            {
                if (authenticationCode == (string)data)
                {
                    MemcachedNew.Remove("AuthenticationCode", loginMobile);
                    result = Login_DAL.Instance.getCompanyListByLoginMobile(loginMobile);
                }
            }
            return result;
        }
    }
}
