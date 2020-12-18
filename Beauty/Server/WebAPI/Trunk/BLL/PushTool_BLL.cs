using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class PushTool_BLL
    {
        #region 构造类实例
        public static PushTool_BLL Instance
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
            internal static readonly PushTool_BLL instance = new PushTool_BLL();
        }
        #endregion

        public void getPushPoolList()
        {
            PushTool_DAL.Instance.getPushPoolList();
        }

    }
}
