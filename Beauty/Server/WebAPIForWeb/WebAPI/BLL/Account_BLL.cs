using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Account_BLL
    {
        #region 构造类实例
        public static Account_BLL Instance
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
            internal static readonly Account_BLL instance = new Account_BLL();
        }
        #endregion


        /// <summary>
        /// 获取公司下面所有员工
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="width">头像宽</param>
        /// <param name="hight">头像高</param>
        /// <param name="pageIndex">当前页数</param>
        /// <param name="pageSize">分页大小</param>
        /// <param name="type">0:抽取全部 1:抽取首页标志</param>
        /// <param name="recordCount">共有多少条</param>
        /// <returns></returns>
        public List<GetAccountList_Model> getAccountList(int companyID,int width,int hight,int pageIndex,int pageSize,int type, out int recordCount)
        {
            List<GetAccountList_Model> list = Account_DAL.Instance.getAccountList(companyID, width, hight, pageIndex, pageSize, type, out recordCount);
            return list;
        }

        public GetAccountList_Model getAccountDetail(int companyID, int accountID, int hight, int width)
        {
            GetAccountList_Model detail = Account_DAL.Instance.getAccountDetail(companyID, accountID, hight, width);
            return detail;
        }
    }
}
