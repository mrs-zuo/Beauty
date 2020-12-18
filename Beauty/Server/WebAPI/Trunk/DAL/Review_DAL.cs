using BLToolkit.Data;
using HS.Framework.Common;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Review_DAL
    {
        #region 构造类实例
        public static Review_DAL Instance
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
            internal static readonly Review_DAL instance = new Review_DAL();
        }
        #endregion


        //        public Review_Model getReviewDetail(int treatmentId)
        //        {
        //            using (DbManager db = new DbManager())
        //            {
        //                string strSql = @"  select top 1 ID ReviewID,Satisfaction,Comment 
        //                                    from REVIEW  
        //                                    where TreatmentID = @TreatmentID  
        //                                    ORDER by ID";

        //                Review_Model model = db.SetCommand(strSql, db.Parameter("@TreatmentID", treatmentId, DbType.Int32)).ExecuteObject<Review_Model>();

        //                return model;
        //            }
        //        }

        public int addReview(Review_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"insert into Review(CompanyID,TreatmentID,Comment,Satisfaction,CreatorID,CreateTime) 
                                      values (@CompanyID,@TreatmentID,@Comment,@Satisfaction,@CreatorID,@CreateTime);select @@IDENTITY";

                int res = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)
                                                    , db.Parameter("@Comment", model.Comment, DbType.String)
                                                    , db.Parameter("@Satisfaction", model.Satisfaction, DbType.Int32)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteScalar<int>();
                if (res <= 0)
                {
                    return 0;
                }

                if (model.TreatmentID > 0)
                {
                    #region 推送
                    string selectCustomerDevice = @"SELECT TOP 1
                                                    ISNULL(T2.DeviceID, '') AS DeviceID ,
                                                    T1.Name AS AccountName ,
                                                    T4.Name AS CustomerName ,
                                                    T2.DeviceType ,
                                                    T5.ServiceName ,
                                                    T8.CreateTime AS Time
                                            FROM    [ACCOUNT] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [LOGIN] T2 WITH ( NOLOCK ) ON T1.UserID = T2.UserID
                                                    LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T3.ResponsiblePersonID = T1.UserID
                                                    LEFT JOIN [CUSTOMER] T4 WITH ( NOLOCK ) ON T3.CustomerID = T4.UserID
                                                    LEFT JOIN [SERVICE] T5 WITH ( NOLOCK ) ON T3.ServiceID = T5.ID
                                                    LEFT JOIN [TBL_TREATGROUP] T6 WITH ( NOLOCK ) ON T6.OrderServiceID = T3.ID
                                                    LEFT JOIN [TREATMENT] T7 WITH ( NOLOCK ) ON T6.GroupNo = T7.GroupNo
                                                    LEFT JOIN [REVIEW] T8 WITH ( NOLOCK ) ON T7.ID = T8.TreatmentID
                                            WHERE   T7.ID = @TreatmentID";
                    PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                                                                                      , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)).ExecuteObject<PushOperation_Model>();
                    if (pushmodel != null)
                    {
                        Task.Factory.StartNew(() =>
                        {
                            if (!string.IsNullOrWhiteSpace(pushmodel.DeviceID))
                            {
                                try
                                {
                                    HS.Framework.Common.Push.HSPush.pushMsg(pushmodel.DeviceID, pushmodel.DeviceType, 1, "顾客:" + pushmodel.CustomerName + "在" + pushmodel.Time.ToString("yyyy-MM-dd HH:mm") + "对服务" + pushmodel.ServiceName + "进行了评价。", Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "3");
                                }
                                catch (Exception)
                                {
                                    LogUtil.Log("评论失败", "push评论失败,时间:" + model.CreateTime);
                                }
                            }
                            else
                            {
                                LogUtil.Log("评论失败", "的DeviceID为空");
                            }

                        });
                    }
                    else
                    {
                        LogUtil.Log("评论失败", "数据抽取失败");
                    }
                    #endregion
                }

                return res;
            }
        }

        public bool updateReview(Review_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlHistory = @"  insert into HISTORY_REVIEW 
                                        select * from REVIEW where ID =@ID";

                int rows = db.SetCommand(strSqlHistory, db.Parameter("@ID", model.ReviewID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @" update Review set 
                                    Comment=@Comment,
                                    Satisfaction=@Satisfaction,
                                    UpdaterID=@UpdaterID,
                                    UpdateTime=@UpdateTime
                                    where ID=@ID";

                rows = db.SetCommand(strSql, db.Parameter("@Comment", model.Comment, DbType.String)
                                            , db.Parameter("@Satisfaction", model.Satisfaction, DbType.Int32)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                            , db.Parameter("@ID", model.ReviewID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;

            }
        }

        ///////////////////////////////////////////////////////////////////////

        public GetReviewDetail_Model getReviewDetail(int companyId, long GroupNo)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T1.GroupNo ,
                                            T2.ServiceID ,
                                            T3.ServiceName ,
                                            T1.TGEndTime ,
                                            T2.TGFinishedCount ,
                                            T2.TGTotalCount ,
                                            T6.Name AS ResponsiblePersonName ,
                                            T5.Satisfaction ,
                                            T5.Comment
                                    FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                            INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                                                                 AND T2.Status <> 3
                                            LEFT JOIN [SERVICE] T3 WITH ( NOLOCK ) ON T2.ServiceID = T3.ID
                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T4 WITH ( NOLOCK ) ON T2.OrderID = T4.MasterID
                                                                                                  AND T4.BusinessType = 1
                                                                                                  AND T4.ConsultantType = 1
                                            LEFT JOIN [ACCOUNT] T6 WITH ( NOLOCK ) ON T4.ConsultantID = T6.UserID
                                            LEFT JOIN [TBL_TREATGROUP_REVIEW] T5 ON T1.GroupNo = T5.GroupNo
                                    WHERE   T1.GroupNo = @GroupNo
                                            AND T1.CompanyID = @CompanyID ";

                GetReviewDetail_Model model = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@GroupNo", GroupNo, DbType.Int64)).ExecuteObject<GetReviewDetail_Model>();

                if (model != null)
                {

                    model.listTM = new List<TMReviewDetail_Model>();
                    string strSqlListTM = @" SELECT  T2.SubServiceName ,
                                                    T3.TMReviewID ,
                                                    T3.Comment ,
                                                    T3.Satisfaction ,
                                                    T1.ID AS TreatmentID
                                            FROM    [TREATMENT] T1
                                                    INNER JOIN [TBL_SUBSERVICE] T2 ON T1.SubServiceID = T2.ID
                                                    LEFT JOIN [TBL_TREATMENT_REVIEW] T3 ON T1.ID = T3.TreatmentID
                                                                                           AND T3.RecordType = 1
                                            WHERE   T1.GroupNo = @GroupNo
                                                    AND T1.CompanyID = @CompanyID ";
                    model.listTM = db.SetCommand(strSqlListTM
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@GroupNo", GroupNo, DbType.Int64)).ExecuteList<TMReviewDetail_Model>();
                }

                return model;
            }
        }

        public Review_Model GetReviewDetailForTM(int treatmentId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  select top 1 TMReviewID ReviewID,Satisfaction,Comment 
                                    from TBL_TREATMENT_REVIEW  
                                    where TreatmentID = @TreatmentID  
                                    ORDER by TMReviewID";

                Review_Model model = db.SetCommand(strSql, db.Parameter("@TreatmentID", treatmentId, DbType.Int32)).ExecuteObject<Review_Model>();

                return model;
            }
        }
    }
}
