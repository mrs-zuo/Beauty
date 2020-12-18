using HS.Framework.Common.Entity;
using Model.Operation_Model;
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
    public class Notepad_BLL
    {
        #region 构造类实例
        public static Notepad_BLL Instance
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
            internal static readonly Notepad_BLL instance = new Notepad_BLL();
        }
        #endregion

        public ObjectResult<object> getNotepadList(NotepadListOperation_Model model)
        {
            return Notepad_DAL.Instance.getNotepadList(model);
        }

        public bool addNotepad(Notepad_Model model)
        {
            return Notepad_DAL.Instance.addNotepad(model);
        }

        public bool deleteNotepad(NotepadDeleteOperation_Model model)
        {
            return Notepad_DAL.Instance.deleteNotepad(model);
        }

        public bool updateNotepad(Notepad_Model model)
        {
            return Notepad_DAL.Instance.updateNotepad(model);
        }

        public List<NotepadList_Model> getNotepadListByAccountID(NotepadListOperation_Model model, int pageSize, int pageIndex, out int recordCount)
        {
            return Notepad_DAL.Instance.getNotepadListByAccountID(model, pageSize, pageIndex, out recordCount);
        }

    }
}
