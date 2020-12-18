using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Template_BLL
    {
        #region 构造类实例
        public static Template_BLL Instance
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
            internal static readonly Template_BLL instance = new Template_BLL();
        }
        #endregion


        public bool addTemplate(Template_Model model) {
            return Template_DAL.Instance.addTemplate(model);
        }

        public bool updateTemplate(Template_Model model) {
            return Template_DAL.Instance.updateTemplate(model);
        }


        public bool deleteTemplate(int templateId) {
            return Template_DAL.Instance.deleteTemplate(templateId);
        }



        public List<Template_Model> getTemplatList(int accountId, int companyId) {
            return Template_DAL.Instance.getTemplatList(accountId, companyId);
        }
    }
}
