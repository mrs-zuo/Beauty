using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class News_BLL
    {
        #region 构造类实例
        public static News_BLL Instance
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
            internal static readonly News_BLL instance = new News_BLL();
        }
        #endregion

        /// <summary>
        /// 获取新闻公告列表
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="pageIndex">当前页数</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="type">0:公告 1:新闻</param>
        /// <param name="recordCount">总共数量</param>
        /// <returns></returns>
        public List<GetNewsList_Model> getNewsList(int companyID, int pageIndex, int pageSize, int type, out int recordCount)
        {
            List<GetNewsList_Model> list = News_DAL.Instance.getNewsList(companyID, pageIndex, pageSize, type, out recordCount);
            return list; 
        }

        public GetNewsDetail_Model getNewsDetail(int companyID, int id)
        {
            GetNewsDetail_Model model = News_DAL.Instance.getNewsDetail(companyID, id);
            return model;
        }
    }
}
