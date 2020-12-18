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


namespace ClientAPI.DAL
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

        public List<GetReviewList_Model> getUnReviewList(int companyId,int customerId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T1.GroupNo ,
                                            T2.ServiceName ,
                                            T1.TGEndTime ,
                                            T2.TGFinishedCount ,
                                            T2.TGTotalCount ,
                                            T3.Name ResponsiblePersonName ,
                                            T1.OrderServiceID AS OrderObjectID
                                    FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                            INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                                                                 AND T2.Status <> 3
                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T6 WITH ( NOLOCK ) ON T6.MasterID = T2.OrderID AND T6.BusinessType = 1 AND T6.ConsultantType = 1
                                            LEFT JOIN [ACCOUNT] T3 WITH ( NOLOCK ) ON T6.ConsultantID = T3.UserID 
                                            INNER JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T2.BranchID = T4.ID
                                            INNER JOIN [ORDER] T5 WITH ( NOLOCK ) ON T2.OrderID = T5.ID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T2.CustomerID = @CustomerID
                                            AND T1.IsReviewed = 0
                                            AND T1.TGStatus = 2
                                            AND T5.OrderTime > T4.StartTime ";

                List<GetReviewList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<GetReviewList_Model>();
                return list;
            }
        }


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
                                            T4.Name ResponsiblePersonName
                                    FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                            INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                                                                 AND T2.Status <> 3
                                            LEFT JOIN [SERVICE] T3 WITH ( NOLOCK ) ON T2.ServiceID = T3.ID
                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T5 WITH ( NOLOCK ) ON T2.OrderID = T5.MasterID
                                                                                                  AND T5.BusinessType = 1
                                                                                                  AND T5.ConsultantType = 1
                                            LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T5.ConsultantID = T4.UserID
                                    WHERE   T1.GroupNo = @GroupNo
                                            AND T1.CompanyID = @CompanyID
                                            AND T1.IsReviewed = 0
                                            AND T1.TGStatus = 2 ";

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
                                                    AND T1.CompanyID = @CompanyID
                                                    AND T1.Status = 2
                                                    AND T1.IsReviewed = 0 ";
                    model.listTM = db.SetCommand(strSqlListTM
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@GroupNo", GroupNo, DbType.Int64)).ExecuteList<TMReviewDetail_Model>();
                }

                return model;
            }
        }

        public bool EditReview(ReviewOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlTG = @"  INSERT INTO [dbo].[TBL_TREATGROUP_REVIEW]
                                    (CompanyID,GroupNo,Comment,Satisfaction,CreatorID,CreateTime,RecordType)
                                        VALUES
                                    (@CompanyID,@GroupNo,@Comment,@Satisfaction,@CreatorID,@CreateTime,1)
                                    ;select @@IDENTITY";

                if (model.mTGReview.Satisfaction < 1 || model.mTGReview.Satisfaction > 5) {
                    db.RollbackTransaction();
                    return false;
                }
                int TGid = db.SetCommand(strSqlTG
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@GroupNo", model.mTGReview.GroupNo, DbType.Int64)
                    , db.Parameter("@Comment", model.mTGReview.Comment == "" ? (object)DBNull.Value : model.mTGReview.Comment, DbType.String)
                    , db.Parameter("@Satisfaction", model.mTGReview.Satisfaction, DbType.Int32)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                if (TGid == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlUpdateTG = " update TBL_TREATGROUP set IsReviewed = 1 where GroupNo = @GroupNo and CompanyID=@CompanyID ";

                int rows = db.SetCommand(strSqlUpdateTG
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@GroupNo", model.mTGReview.GroupNo, DbType.Int64)).ExecuteNonQuery();

                if (rows != 1) {
                    db.RollbackTransaction();
                    return false;
                }

                if (model.listTMReview != null && model.listTMReview.Count > 0)
                {

                    string strSqlTM = @"  INSERT INTO [dbo].[TBL_TREATMENT_REVIEW]
                                    (CompanyID,TreatmentID,Comment,Satisfaction,CreatorID,CreateTime,RecordType)
                                        VALUES
                                    (@CompanyID,@TreatmentID,@Comment,@Satisfaction,@CreatorID,@CreateTime,1)
                                    ;select @@IDENTITY";
                    foreach (Review_Model item in model.listTMReview)
                    {
                        if (item.Satisfaction < 1 || item.Satisfaction > 5)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                        int TMid = db.SetCommand(strSqlTM
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@TreatmentID", item.TreatmentID, DbType.Int64)
                                , db.Parameter("@Comment", item.Comment == "" ? (object)DBNull.Value : item.Comment, DbType.String)
                                , db.Parameter("@Satisfaction", item.Satisfaction, DbType.Int32)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                        if (TMid == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        string strSqlUpdateTM = " update TREATMENT set IsReviewed = 1 where ID = @ID and CompanyID=@CompanyID ";

                        rows = db.SetCommand(strSqlUpdateTM
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@ID", item.TreatmentID, DbType.Int64)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }
                }
                else {
                    string strSqlGet = "select ID from TREATMENT where GroupNo = @GroupNo and CompanyID=@CompanyID  AND SubServiceID IS NULL ";

                    List<int> listTMID = db.SetCommand(strSqlGet
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@GroupNo", model.mTGReview.GroupNo, DbType.Int64)).ExecuteScalarList<int>();

                    if (listTMID != null && listTMID.Count == 1) {
                        string strSqlTM = @"  INSERT INTO [dbo].[TBL_TREATMENT_REVIEW]
                                    (CompanyID,TreatmentID,Comment,Satisfaction,CreatorID,CreateTime,RecordType)
                                        VALUES
                                    (@CompanyID,@TreatmentID,@Comment,@Satisfaction,@CreatorID,@CreateTime,1)
                                    ;select @@IDENTITY";
                        int TMid = db.SetCommand(strSqlTM
                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                       , db.Parameter("@TreatmentID", listTMID[0], DbType.Int64)
                       , db.Parameter("@Comment", model.mTGReview.Comment == "" ? (object)DBNull.Value : model.mTGReview.Comment, DbType.String)
                       , db.Parameter("@Satisfaction", model.mTGReview.Satisfaction, DbType.Int32)
                       , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                       , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                        if (TMid == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        string strSqlUpdateTM = " update TREATMENT set IsReviewed = 1 where ID = @ID and CompanyID=@CompanyID ";

                        rows = db.SetCommand(strSqlUpdateTM
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@ID", listTMID[0], DbType.Int64)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }
                }

                db.CommitTransaction();
                return true;

            }
        }


        public Review_Model GetReviewDetailForTM(int treatmentId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  select T1.TMReviewID as ReviewID,T1.Satisfaction,T1.Comment ,T3.SubServiceName,T4.Name AS ExecuteName
                                    from TBL_TREATMENT_REVIEW T1
									INNER JOIN [TREATMENT] T2 ON T1.TreatmentID = T2.ID  
									left join [TBL_SUBSERVICE] T3 ON T2.SubServiceID = T3.ID  
									left join [ACCOUNT] T4 ON T2.ExecutorID = T4.UserID
                                    where T1.TreatmentID = @TreatmentID ";

                Review_Model model = db.SetCommand(strSql, db.Parameter("@TreatmentID", treatmentId, DbType.Int32)).ExecuteObject<Review_Model>();

                return model;
            }
        }

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
                    string selectCustomerDevice = @" SELECT TOP 1
                                                            ISNULL(T6.DeviceID, '') AS DeviceID ,
                                                            T4.Name AS CustomerName ,
                                                            T6.DeviceType ,
                                                            T3.ServiceName
                                                    FROM    TREATMENT T1 WITH ( NOLOCK )
                                                            LEFT JOIN [TBL_TREATGROUP] T2 WITH ( NOLOCK ) ON T1.GroupNo = T2.GroupNo
                                                            LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T2.OrderServiceID = T3.ID
                                                            LEFT JOIN [CUSTOMER] T4 WITH ( NOLOCK ) ON T4.UserID = T3.CustomerID
                                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T5 ON T5.MasterID = T3.OrderID
                                                                                                      AND BusinessType = 1
                                                                                                      AND ConsultantType = 2
                                                            LEFT JOIN [LOGIN] T6 WITH ( NOLOCK ) ON T5.ConsultantID = T6.UserID
                                                    WHERE   T1.ID = @TreatmentID ";
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
                                    HS.Framework.Common.Push.HSPush.pushMsg(pushmodel.DeviceID, pushmodel.DeviceType, 1, "顾客:" + pushmodel.CustomerName + "在" + model.CreateTime.ToString("yyyy-MM-dd HH:mm") + "对服务" + pushmodel.ServiceName + "进行了评价。", Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "3");
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

        public GetReviewDetail_Model getReviewDetailForTG(int companyId, long GroupNo)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T1.GroupNo ,
                                            T2.ServiceID ,
                                            T3.ServiceName ,
                                            T1.TGEndTime ,
                                            T2.TGFinishedCount ,
                                            T2.TGTotalCount ,
                                            T4.Name ResponsiblePersonName ,
                                            T5.Satisfaction ,
                                            T5.Comment
                                    FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                            INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                                                                 AND T2.Status <> 3
                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T6 WITH ( NOLOCK ) ON T6.MasterID = T2.OrderID AND T6.BusinessType = 1 AND T6.ConsultantType = 1
                                            LEFT JOIN [SERVICE] T3 WITH ( NOLOCK ) ON T2.ServiceID = T3.ID
                                            LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T6.ConsultantID = T4.UserID
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

    }
}
