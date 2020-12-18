using BLToolkit.Data;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL.Customer
{
    public class Promotion_CDAL
    {
        #region 构造类实例
        public static Promotion_CDAL Instance
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
            internal static readonly Promotion_CDAL instance = new Promotion_CDAL();
        }
        #endregion

        /// <summary>
        /// 获取促销图片
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="hight">图片高度</param>
        /// <param name="width">图片宽度</param>
        /// <param name="type">促销类型 0:所有展示 1:顶部展示 2:列表展示</param>
        /// <returns></returns>
        public List<TBL_PromotionList_Model> getPromotionList(int companyID, int width, int hight, int type = 0)
        {
            List<TBL_PromotionList_Model> list = new List<TBL_PromotionList_Model>();
            using (DbManager db = new DbManager())
            {
                string strPromotionImg = "";
                string strSql = @" SELECT TOP 5 {0} ,PromotionCode ,StartDate ,EndDate ,Type ,Title
                                    FROM    [TBL_PROMOTION] T1 WITH ( NOLOCK )
                                    WHERE   T1.Type = @Type
                                            AND GETDATE() BETWEEN T1.StartDate AND T1.EndDate
                                            AND CompanyID = @CompanyID AND T1.RecordType = 1
                                    ORDER BY T1.StartDate ";
                if (type == 1)
                {
                    strPromotionImg = string.Format(WebAPI.Common.Const.getPromotionImg, hight, width);
                }
                else if (type == 2)
                {
                    strPromotionImg = string.Format(WebAPI.Common.Const.getPromotionImg, hight, width);
                }
                else
                {
                    strPromotionImg = string.Format(WebAPI.Common.Const.getPromotionImg, hight, width);

                    strSql = @" SELECT {0} ,PromotionCode ,StartDate ,EndDate ,Type ,Title
                                    FROM    [TBL_PROMOTION] T1 WITH ( NOLOCK )
                                    WHERE   T1.Type = @Type
                                            AND GETDATE() BETWEEN T1.StartDate AND T1.EndDate
                                            AND CompanyID = @CompanyID AND T1.RecordType = 1
                                    ORDER BY T1.StartDate  ";
                }
               
                string strListSql = string.Format(strSql, strPromotionImg);
                list = db.SetCommand(strListSql, db.Parameter("@Type", type, DbType.Int32), db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<TBL_PromotionList_Model>();
                return list;
            }
        }


        /// <summary>
        /// 获取促销信息数量
        /// </summary>
        /// <param name="objectId"></param>
        /// <param name="objectType"> 0:按公司ID查找 1：按客户ID查找</param>
        /// <returns></returns>
        public int getPromotionCount(int objectId, int objectType, int branchId)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = " select Count(T1.ID) from PROMOTION T1  ";
                if (branchId > 0)
                {
                    strSql += @" INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 
                                    on T1.ID = T2.Code and T2.Type = 2 and T2.Available = 1 and T2.BranchID =@BranchID ";
                }

                if (objectType == 0)
                {
                    strSql += " where T1.CompanyID = @ObjectID ";
                }
                else
                {
                    strSql += " where T1.CompanyID = (select CompanyID from [USER] where ID =@ObjectID) ";
                }
                strSql += @" AND T1.StartDate <= @Datatime AND T1.EndDate >=  @Datatime  AND T1.Available = 1";

                int cnt = db.SetCommand(strSql, db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@ObjectID", objectId, DbType.Int32)
                    , db.Parameter("@Datatime", DateTime.Now, DbType.Date)).ExecuteScalar<int>();

                return cnt;
            }
        }


        public List<PromotionList_Model> getCompanyPromotionInfo(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = @"select distinct T1.ID PromotionID,LEFT(T1.StartDate,10) StartDate,LEFT(T1.EndDate,10) EndDate, T1.Type PromotionType,T1.TextContent  PromotionContent,CASE WHEN T1.Type=1 THEN T1.TextContent ELSE {0}{1}{2}{3}{4}+ cast(T1.CompanyID as nvarchar(10)) + '/'+ {5}{6}{7}+ cast(T1.ID as nvarchar(10))+ '/'+ T1.ImageFile +{8}  END PromotionPictureURL  
                                   from PROMOTION T1 WITH(NOLOCK) 
                                   INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 WITH ( NOLOCK ) ON T2.Available = 1 
                                   AND T2.CompanyID = T1.CompanyID  AND T2.Type = 2 AND T1.ID = T2.Code 
                                   INNER JOIN dbo.BRANCH T3 WITH(NOLOCK) ON T3.Available = 1 
                                   where T1.CompanyID = @CompanyID 
                                   AND T2.BranchID IN(SELECT BranchID FROM dbo.RELATIONSHIP WHERE CustomerID = @CustomerID AND Available = 1) 
                                   AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.EndDate) >= 0
                                   AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.StartDate) <= 0
                                   AND T1.Available = 1";

                strSql = string.Format(strSql,
                     Common.Const.strHttp,
                     Common.Const.server,
                     Common.Const.strMothod,
                     "",
                     Common.Const.strSingleMark,
                     Common.Const.strSingleMark,
                     Common.Const.strImageObjectType5,
                     Common.Const.strSingleMark,
                     Common.Const.strThumb);


                List<PromotionList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                    db.Parameter("@ImageHeight", model.ImageHeight, DbType.String),
                                                    db.Parameter("@ImageWidth", model.ImageWidth, DbType.String),
                                                    db.Parameter("@datatime", DateTime.Now, DbType.DateTime2),
                                                    db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<PromotionList_Model>();

                if (list != null && model.CustomerID > 0)
                {

                    string strSqlCommand = @" SELECT   T3.BranchName,T3.ID BranchID
                                                FROM     dbo.BRANCH T3
                                                WHERE    ID IN ( 
                                                SELECT  T1.BranchID 
                                                FROM    dbo.RELATIONSHIP T1 
                                                INNER JOIN dbo.TBL_MARKET_RELATIONSHIP T2 
                                                ON T1.BranchID = T2.BranchID  AND T2.Available = 1 AND T2.Type = 2 
                                                WHERE T1.CustomerID = @CustomerID  AND T2.Code = @PromotionID  )";

                    foreach (PromotionList_Model item in list)
                    {
                        List<ServiceEnalbeInfoDetail_Model> listBranch = db.SetCommand(strSqlCommand, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                                            db.Parameter("@PromotionID", item.PromotionID, DbType.Int32)).ExecuteList<ServiceEnalbeInfoDetail_Model>();

                        item.BranchList = listBranch;
                    }

                }
                return list;

            }
        }
    }
}
