using BLToolkit.Data;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
{
    public class Paper_DAL
    {
        #region 构造类实例
        public static Paper_DAL Instance
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
            internal static readonly Paper_DAL instance = new Paper_DAL();
        }
        #endregion


        public List<AnswerPaper_Model> GetAnswerPaperList(GetAnswerPaperListOperation_Model operationModel, out int recordCount)
        {
            List<AnswerPaper_Model> list = new List<AnswerPaper_Model>();
            using (DbManager db = new DbManager())
            {
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.UpdateTime DESC, T1.ID DESC ) AS rowNum ,
                                                T1.ID AS GroupID ,T1.PaperID ,T2.Title ,T3.Name AS CustomerName ,T2.CanEditAnswer, 
                                                ISNULL(T4.Name,'')  AS ResponsiblePersonName ,T1.IsVisible ,T1.UpdateTime";


                string strSql = @" SELECT {0}
                                FROM    TBL_PAPER_GROUP T1 WITH(NOLOCK)
                                        INNER JOIN [TBL_PAPER] T2 WITH(NOLOCK) ON T1.PaperID = T2.ID
                                        INNER JOIN [CUSTOMER] T3 WITH(NOLOCK) ON T1.CustomerID = T3.UserID
                                        LEFT JOIN [ACCOUNT] T4 WITH(NOLOCK) ON T1.CreatorID = T4.UserID
                                WHERE   T1.CompanyID = @CompanyID AND T1.Available=1 ";

                if (operationModel.PageIndex > 1)
                {
                    strSql += " AND T1.UpdateTime <= @UpdateTime";
                }

                if (operationModel.ResponsiblePersonIDs != null && operationModel.ResponsiblePersonIDs.Count > 0)
                {
                    strSql += " AND T1.CreatorID in ( ";
                    for (int i = 0; i < operationModel.ResponsiblePersonIDs.Count; i++)
                    {
                        if (i == 0)
                        {
                            strSql += operationModel.ResponsiblePersonIDs[i].ToString();
                        }
                        else
                        {
                            strSql += "," + operationModel.ResponsiblePersonIDs[i].ToString();
                        }
                    }
                    strSql += " )";
                }

                if (operationModel.FilterByTimeFlag == 1)
                {

                    strSql += WebAPI.Common.APICommon.getSqlWhereData_1_7_2(4, operationModel.StartTime, operationModel.EndTime, " T1.UpdateTime");
                }

                if (operationModel.CustomerID > 0)
                {
                    strSql += " AND T1.CustomerID = @CustomerID";
                }

                // Customer端只能查看可见的试卷答案
                if (!operationModel.IsBusiness)
                {
                    strSql += " AND T1.IsVisible = 1";
                }

                string strCountSql = string.Format(strSql, " count(0) ");

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((operationModel.PageIndex - 1) * operationModel.PageSize + 1) + " and " + operationModel.PageIndex * operationModel.PageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                                        , db.Parameter("@UpdateTime", operationModel.UpdateTime, DbType.DateTime)
                                                        , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                                  , db.Parameter("@UpdateTime", operationModel.UpdateTime, DbType.DateTime)
                                                  , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteList<AnswerPaper_Model>();
                return list;
            }
        }

        public List<PaperDetail> GetPaperDetail(GetAnswerDetailOperation_Model model)
        {
            List<PaperDetail> list = new List<PaperDetail>();
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                if (model.GroupID > 0)
                {
                    strSql = @" SELECT  
                                        T2.ID AS QuestionID ,
                                        T2.QuestionName ,
                                        T2.QuestionType ,
                                        T2.QuestionContent ,
                                        ISNULL(T5.AnswerContent, '') AS AnswerContent ,
                                        ISNULL(T5.ID, 0) AS AnswerID ,
                                        ISNULL(T2.QuestionDescription, '') AS QuestionDescription
                                FROM    [TBL_PAPER_QUESTION_RELATIONSHIP] T1 WITH ( NOLOCK )
                                        INNER JOIN [QUESTION] T2 WITH ( NOLOCK ) ON T1.QuestionID = T2.ID
                                                                                    AND T1.CompanyID = @CompanyID
                                        LEFT JOIN [TBL_PAPER_GROUP] T3 ON T3.PaperID = @PaperID
                                                                          AND T1.ID = @GroupID
                                        LEFT JOIN [ANSWER] T5 ON T5.QuestionID = T2.ID
                                                                 AND T5.GroupID = @GroupID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.PaperID = @PaperID
                                ORDER BY T1.SortID";
                }
                else
                {
                    strSql = @" SELECT      T2.ID AS QuestionID ,
                                            T2.QuestionName ,
                                            T2.QuestionType ,
                                            T2.QuestionContent ,
                                            ISNULL(T2.QuestionDescription, '') AS QuestionDescription,
                                            0 AS AnswerID ,
                                            '' AS AnswerContent
                                    FROM    [TBL_PAPER_QUESTION_RELATIONSHIP] T1 WITH ( NOLOCK )
                                            INNER JOIN [QUESTION] T2 WITH ( NOLOCK ) ON T1.QuestionID = T2.ID
                                                                                        AND T1.CompanyID = @CompanyID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.PaperID = @PaperID
                                            AND T1.Available=1
                                    ORDER BY T1.SortID";
                }

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@PaperID", model.PaperID, DbType.Int32)
                    , db.Parameter("@GroupID", model.GroupID, DbType.Int32)).ExecuteList<PaperDetail>();
                return list;
            }
        }


    }
}
