using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Statement_BLL
    {
        #region 构造类实例
        public static Statement_BLL Instance
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
            internal static readonly Statement_BLL instance = new Statement_BLL();
        }
        #endregion

        public List<StatementCategory_Model> getStatementCategoryList(int CompanyID)
        {
            return Statement_DAL.Instance.getStatementCategoryList(CompanyID);
        }

        public StatementCategory_Model getStatementCategoryDetail(int CompanyID, int CategoryID)
        {
            return Statement_DAL.Instance.getStatementCategoryDetail(CompanyID, CategoryID);
        }

        public List<GetProductList_Model> getProductList(int ProductType, int CategoryID, int CompanyID) {
            return Statement_DAL.Instance.getProductList(ProductType, CategoryID, CompanyID);
        }

        public bool EditStatement(StatementCategory_Model model) {
            return Statement_DAL.Instance.EditStatement(model);
        }

        public bool DeleteStatement(int CategoryId, int CompanyID) {
            return Statement_DAL.Instance.DeleteStatement(CategoryId,CompanyID);
        }
    }
}
