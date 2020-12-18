using BLToolkit.Data;
using HS.Framework.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Promotion_DAL
    {
        #region 构造类实例
        public static Promotion_DAL Instance
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
            internal static readonly Promotion_DAL instance = new Promotion_DAL();
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
            List<string> list=new List<string> ();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strPromotionImg = string.Format(WebAPI.Common.Const.getPromotionImg, hight, width);
                    string strSql = @" SELECT TOP 5 {0} FROM  [PROMOTION] T1 WITH(NOLOCK) WHERE T1.Type=@Type AND GETDATE() BETWEEN T1.StartDate AND T1.EndDate AND T1.Available=1 AND CompanyID=@CompanyID  ";
                    string strListSql = string.Format(strSql, strPromotionImg);

                    list = db.SetCommand(strListSql, db.Parameter("@Type", type, DbType.Int32), db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalarList<string>();

                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }
    }
}
