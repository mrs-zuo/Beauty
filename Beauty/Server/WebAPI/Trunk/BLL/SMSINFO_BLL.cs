using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class SMSINFO_BLL
    {
        #region 构造类实例
        public static SMSINFO_BLL Instance
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
            internal static readonly SMSINFO_BLL instance = new SMSINFO_BLL();
        }
        #endregion


        /// <summary>
        /// 获取公司发短信情况
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <param name="RcvNumber">接收号码</param>
        /// <param name="SendProgram">程序名及其他监察信息</param>
        /// <param name="UserID">登录的用户ID</param>
        /// <returns></returns>
        public int getSMSInfo(int CompanyID, string RcvNumber, string SendProgram, int UserID)
        {
            int result = SMSInfo_DAL.Instance.getSMSInfo(CompanyID, RcvNumber, SendProgram, UserID);
            return result;
        }



        /// <summary>
        /// 保存短信发送履历信息
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <param name="BranchID">门店ID</param>
        /// <param name="RcvNumber">接收号码</param>
        /// <param name="SMSContent">短信内容</param>
        /// <param name="SendProgram">程序名及其他监察信息</param>
        /// <param name="UserID">登录的用户ID</param>
        /// <returns></returns>
        public void addSMSHis(int CompanyID, int BranchID, string RcvNumber, string SMSContent, string SendProgram, int UserID)
        {
            SMSInfo_DAL.Instance.addSMSHis(CompanyID, BranchID, RcvNumber, SMSContent, SendProgram, UserID);
           
        }



        /// <summary>
        /// 取得公司可发送短信数量及已发送短信数量
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <param name="BranchID">门店ID</param>
        /// <returns>GetSMSNum_Model</returns>
        public GetSMSNum_Model getSMSNum(int CompanyID, int BranchID)
        {
            return SMSInfo_DAL.Instance.getSMSNum(CompanyID, BranchID);

        }
    }
}
