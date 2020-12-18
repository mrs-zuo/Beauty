using Model.Operation_Model;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class InOutItem_BLL
    {
        #region 构造类实例
        public static InOutItem_BLL Instance
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
            internal static readonly InOutItem_BLL instance = new InOutItem_BLL();
        }
        #endregion
        /// <summary>
        /// 获取公司下面所有大项目
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <returns></returns>
        public List<InOutItemA_Model> GetInOutItemAList(int CompanyID)
        {
            return InOutItem_DAL.Instance.GetInOutItemAList(CompanyID);
        }
        /// <summary>
        /// 获取大项目下面所有中项目
        /// </summary>
        /// <param name="ItemAID">大项目ID</param>
        /// <returns></returns>
        public List<InOutItemB_Model> GetInOutItemBList(int ItemAID)
        {
            return InOutItem_DAL.Instance.GetInOutItemBList(ItemAID);
        }
        /// <summary>
        /// 获取中项目下面所有小项目
        /// </summary>
        /// <param name="ItemBID">中项目ID</param>
        /// <returns></returns>
        public List<InOutItemC_Model> GetInOutItemCList(int ItemBID)
        {
            return InOutItem_DAL.Instance.GetInOutItemCList(ItemBID);
        }
        /// <summary>
        /// 添加大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddInOutItemA(InOutItemAOperation_Model model)
        {
            return InOutItem_DAL.Instance.AddInOutItemA(model);
        }
        /// <summary>
        /// 更新大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateInOutItemA(InOutItemAOperation_Model model)
        {
            return InOutItem_DAL.Instance.UpdateInOutItemA(model);
        }
        /// <summary>
        /// 添加中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddInOutItemB(InOutItemBOperation_Model model)
        {
            return InOutItem_DAL.Instance.AddInOutItemB(model);
        }
        /// <summary>
        /// 添加中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateInOutItemB(InOutItemBOperation_Model model)
        {
            return InOutItem_DAL.Instance.UpdateInOutItemB(model);
        }
        /// <summary>
        /// 添加小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddInOutItemC(InOutItemCOperation_Model model)
        {
            return InOutItem_DAL.Instance.AddInOutItemC(model);
        }
        /// <summary>
        /// 更新小项目
        /// </summary>
        /// <param name="ItemAID"></param>
        /// <returns></returns>
        public bool UpdateInOutItemC(InOutItemCOperation_Model model)
        {
            return InOutItem_DAL.Instance.UpdateInOutItemC(model);
        }
        /// <summary>
        /// 删除大项目
        /// </summary>
        /// <param name="ItemAID"></param>
        /// <returns></returns>
        public bool DeleteInOutItemA(int ItemAID)
        {
            return InOutItem_DAL.Instance.DeleteInOutItemA(ItemAID);
        }
        /// <summary>
        /// 删除中项目
        /// </summary>
        /// <param name="ItemBID"></param>
        /// <returns></returns>
        public bool DeleteInOutItemB(int ItemBID)
        {
            return InOutItem_DAL.Instance.DeleteInOutItemB(ItemBID);
        }
        /// <summary>
        /// 删除小项目
        /// </summary>
        /// <param name="ItemCID"></param>
        /// <returns></returns>
        public bool DeleteInOutItemC(int ItemCID)
        {
            return InOutItem_DAL.Instance.DeleteInOutItemC(ItemCID);
        }
        /// <summary>
        /// 判断是否存在同名的大类项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool FindInOutItemASameItemAName(InOutItemA_Model model)
        {
            return InOutItem_DAL.Instance.FindInOutItemASameItemAName(model);
        }
        /// <summary>
        /// 判断是否存在同名的中类项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool FindInOutItemBSameItemBName(InOutItemB_Model model)
        {
            return InOutItem_DAL.Instance.FindInOutItemBSameItemBName(model);
        }
        /// <summary>
        /// 判断是否存在同名的小类项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool FindInOutItemCSameItemCName(InOutItemC_Model model)
        {
            return InOutItem_DAL.Instance.FindInOutItemCSameItemCName(model);
        }
    }
}
