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
    public class Review_BLL
    {
        #region 构造类实例
        public static Review_BLL Instance
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
            internal static readonly Review_BLL instance = new Review_BLL();
        }
        #endregion


        //public Review_Model getReviewDetail(int treatmentId) {
        //    return Review_DAL.Instance.getReviewDetail(treatmentId);
        //}


        public int addReview(Review_Model model) {
            return Review_DAL.Instance.addReview(model);
        }


        public bool updateReview(Review_Model model) {
            return Review_DAL.Instance.updateReview(model);
        }

        /////////////////////////////////////////////////////////////////

        public GetReviewDetail_Model getReviewDetail(int companyId, long GroupNo)
        {
            return Review_DAL.Instance.getReviewDetail(companyId, GroupNo);
        }

        public Review_Model GetReviewDetailForTM(int treatmentId)
        {
            return Review_DAL.Instance.GetReviewDetailForTM(treatmentId);
        }
    }
}
