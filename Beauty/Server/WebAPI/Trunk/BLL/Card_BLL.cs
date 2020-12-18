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
    public class Card_BLL
    {
        #region 构造类实例
        public static Card_BLL Instance
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
            internal static readonly Card_BLL instance = new Card_BLL();
        }
        #endregion


        public List<Card_Model> getCardList(int companyId) {
            return Card_DAL.Instance.getCardList(companyId);
        }


        public bool deleteCard(Card_Model model)
        {
            return Card_DAL.Instance.deleteCard(model);
        }


        public Card_Model getCardDetail(long cardCode, int companyId)
        {
            return Card_DAL.Instance.getCardDetail(cardCode,companyId);
        }

        public int addCard(Card_Model model) {
            return Card_DAL.Instance.addCard(model);
        }


        public int updateCard(Card_Model model) {
            return Card_DAL.Instance.updateCard(model);
        }

        public bool updateDefaultCardID(Card_Model model)
        {
            return Card_DAL.Instance.updateDefaultCardID(model);
        }

    }
}
