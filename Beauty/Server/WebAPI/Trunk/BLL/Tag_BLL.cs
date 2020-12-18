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
    public class Tag_BLL
    {
        #region 构造类实例
        public static Tag_BLL Instance
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
            internal static readonly Tag_BLL instance = new Tag_BLL();
        }
        #endregion

        public int addTag(TagOperation_Model model)
        {
            int res = Tag_DAL.Instance.addTag(model);
            return res;
        }

        public List<TagList_Model> getTagList(int companyId, int type,int branchID, bool isShowHave = false)
        {
            List<TagList_Model> list = Tag_DAL.Instance.getTagList(companyId, type,branchID, isShowHave);
            return list;
        }

        public bool deleteTag(TagOperation_Model model)
        {
            bool res = Tag_DAL.Instance.deleteTag(model);
            return res;
        }

        /// <summary>
        /// 获取标签详细
        /// </summary>
        /// <param name="companyId">公司ID</param>
        /// <param name="tagID">标签ID</param>
        /// <param name="type">1:记事本,咨询记录 2:用户分组</param>
        /// <returns></returns>
        public TagDetailForWeb_Model getTagDetailForWeb(int companyId, int tagID, int type = 2)
        {
            TagDetailForWeb_Model model = Tag_DAL.Instance.getTagDetailForWeb(companyId, tagID, type);
            return model;
        }

        public int addTagForWeb(TagDetailForWeb_Model model)
        {
            int res = Tag_DAL.Instance.addTagForWeb(model);
            return res;
        }

        public int editTagForWeb(TagDetailForWeb_Model model)
        {
            int res = Tag_DAL.Instance.editTagForWeb(model);
            return res;
        }
    }
}
