using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Promotion_BLL
    {
        #region 构造类实例
        public static Promotion_BLL Instance
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
            internal static readonly Promotion_BLL instance = new Promotion_BLL();
        }
        #endregion

        /// <summary>
        /// 获取促销图片
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="hight">图片高度</param>
        /// <param name="width">图片宽度</param>
        /// <param name="type">促销类型</param>
        /// <returns></returns>
        public List<string> getPromotionImg(int companyID, int width, int hight, int type = 0)
        {    
            List<string> list = Promotion_DAL.Instance.getPromotionImg(companyID, width, hight, type = 0);
            return list;
        }
    }
}
