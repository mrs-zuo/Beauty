using ClientAPI.DAL;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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
        /// <param name="companyID">公司ID</param>
        /// <returns></returns>
        public GetVSMSINFO_Model getVSMSINFODetail(int companyID)
        {
            GetVSMSINFO_Model model = SMSINFO_DAL.Instance.getVSMSINFODetail(companyID);
            return model;
        }

        /// <summary>
        /// 保存短信发送履历信息
        /// </summary>
        /// <param name="addSMSHIS_Model"></param>
        /// <returns></returns>
        public bool addSMSHIS_Model(AddSMSHIS_Model addSMSHIS_Model)
        {
            return SMSINFO_DAL.Instance.addSMSHIS_Model(addSMSHIS_Model);

        }
    }
}
