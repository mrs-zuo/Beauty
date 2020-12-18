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
using WebAPI.Common;

namespace WebAPI.DAL
{
    public class Promotion_DAL
    {
        #region 构造类实例
        public static Promotion_DAL Instance
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
            internal static readonly Promotion_DAL instance = new Promotion_DAL();
        }
        #endregion

        /// <summary>
        /// 获取促销图片
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="hight">图片高度</param>
        /// <param name="width">图片宽度</param>
        /// <param name="type">促销类型</param>
        /// <returns></returns>
        public List<string> getPromotionImg(int companyID, int width, int hight, int type = 0)
        {
            List<string> list = new List<string>();
            using (DbManager db = new DbManager())
            {
                string strPromotionImg = string.Format(WebAPI.Common.Const.getPromotionImg, hight, width);
                string strSql = @" SELECT TOP 5 {0} FROM  [PROMOTION] T1 WITH(NOLOCK) WHERE T1.Type=@Type AND GETDATE() BETWEEN T1.StartDate AND T1.EndDate AND T1.Available=1 AND CompanyID=@CompanyID  ";
                string strListSql = string.Format(strSql, strPromotionImg);

                list = db.SetCommand(strListSql, db.Parameter("@Type", type, DbType.Int32), db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalarList<string>();

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

        public List<Promotion_Model> getPromotionForManager(UtilityOperation_Model model)
        {
            List<Promotion_Model> list = new List<Promotion_Model>();

            using (DbManager db = new DbManager())
            {

                string strSql = " SELECT T1.ID,T1.StartDate,T1.EndDate,T1.Type,T1.TextContent,T1.ImageFile," + Const.getPromotionImgForManager
                                + @" FROM [PROMOTION] T1 WITH(NOLOCK)";

                if (model.BranchID > 0)
                {
                    strSql += " LEFT JOIN [TBL_MARKET_RELATIONSHIP] T2 WITH(NOLOCK) ON T2.Code=T1.ID ";
                }

                strSql += " WHERE  T1.Available=1 AND T1.CompanyID=@CompanyID ";

                if (model.BranchID > 0)
                {
                    strSql += " AND T2.BranchID=@BranchID AND T2.Type=2 ";
                }

                if (model.Flag == 1)//未开始
                {
                    strSql += " AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.StartDate) > 0 ";
                }
                else if (model.Flag == 2)//进行中
                {
                    strSql += @" AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.EndDate) >= 0
                                 AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.StartDate) <= 0 ";
                }
                else if (model.Flag == 3)//已结束
                {
                    strSql += " AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.EndDate) < 0 ";
                }

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<Promotion_Model>();

                return list;

            }
        }

        public Promotion_Model getPromotionDetailForManager(UtilityOperation_Model model)
        {
            Promotion_Model res = new Promotion_Model();

            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT T1.ID,T1.CompanyID,T1.StartDate,T1.EndDate,T1.Type,T1.TextContent,T1.ImageFile," + Const.getPromotionImgForManager
                                + @" FROM [PROMOTION] T1 WITH(NOLOCK) 
                                    WHERE T1.Available=1 AND T1.CompanyID=@CompanyID AND T1.ID=@ID ";

                res = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteObject<Promotion_Model>();

                return res;

            }
        }

        public List<BranchSelection_Model> getBranchIDListByPromotionIDForManager(int companyID, int promotionID)
        {
            List<BranchSelection_Model> list = new List<BranchSelection_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT DISTINCT T1.ID AS BranchID, T1.BranchName,
                                CASE WHEN T2.BranchID=T1.ID THEN 1 ELSE 0 END AS IsExist
                                FROM    BRANCH T1
                                        LEFT JOIN TBL_MARKET_RELATIONSHIP T2 ON T1.ID = T2.BranchID AND T2.type = 2 AND Code=@ID AND T2.Available=1 
                                WHERE   T1.CompanyID = @CompanyID  AND T1.Available=1 ";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@ID", promotionID, DbType.Int32)).ExecuteList<BranchSelection_Model>();

                return list;
            }
        }

        public int addPromotionForManager(Promotion_Model model, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSql = @" INSERT INTO PROMOTION (CompanyID ,BranchID ,StartDate ,EndDate ,Type ,TextContent ,ImageFile ,Available ,CreatorID ,CreateTime) 
                                   VALUES (@CompanyID ,@BranchID ,@StartDate ,@EndDate ,@Type ,@TextContent ,@ImageFile ,@Available ,@CreatorID ,@CreateTime);select @@IDENTITY";
                object objText = DBNull.Value;
                if (model.Type == 1)
                {
                    objText = model.TextContent;
                }
                object objImgUrl = DBNull.Value;
                if (model.Type == 0)
                {
                    objImgUrl = model.PromotionImgUrl;
                }

                int promotionID = db.SetCommand(strSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", 0, DbType.Int32)
                                                , db.Parameter("@StartDate", model.StartDate, DbType.Date)
                                                , db.Parameter("@EndDate", model.EndDate, DbType.Date)
                                                , db.Parameter("@Type", model.Type, DbType.Int32)
                                                , db.Parameter("@TextContent", objText, DbType.String)
                                                , db.Parameter("@ImageFile", objImgUrl, DbType.String)
                                                , db.Parameter("@Available", true, DbType.Boolean)
                                                , db.Parameter("@CreatorID", model.OperatorID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.OperatorTime, DbType.DateTime)).ExecuteScalar<int>();

                if (promotionID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                if (branchID > 0)
                {
                    string addRelationship = @"INSERT INTO TBL_MARKET_RELATIONSHIP (CompanyID ,BranchID ,Type ,Code ,Available ,OperatorID ,OperateTime) 
                                                            VALUES(@CompanyID ,@BranchID ,@Type ,@Code ,@Available ,@OperatorID ,@OperateTime)";

                    int addRes = db.SetCommand(addRelationship
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", branchID, DbType.String)
                                                    , db.Parameter("@Type", 2, DbType.Int32)
                                                    , db.Parameter("@Code", promotionID, DbType.Int32)
                                                    , db.Parameter("@Available", true, DbType.Boolean)
                                                    , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                                    , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();

                    if (addRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                db.CommitTransaction();
                return promotionID;

            }
        }

        public bool updatePromotionForManager(Promotion_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlPromotionHistory = "INSERT INTO [HISTORY_PROMOTION] SELECT * FROM [PROMOTION] WHERE ID =@ID";

                int rows = db.SetCommand(strSqlPromotionHistory, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                object objText = DBNull.Value;
                if (model.Type == 1)
                {
                    objText = model.TextContent;
                }
                object objImgUrl = DBNull.Value;
                if (model.Type == 0)
                {
                    objImgUrl = model.PromotionImgUrl;
                }

                string strUpdatePromotionSql = @"UPDATE  PROMOTION
                                                SET     StartDate = @StartDate
                                                        ,EndDate = @EndDate
                                                        ,TextContent = @TextContent
                                                        ,ImageFile = @ImageFile
                                                        ,UpdaterID = @UpdaterID
                                                        ,UpdateTime = UpdateTime";

                strUpdatePromotionSql += @" WHERE   CompanyID = @CompanyID
                                                        AND ID = @ID AND Type=@Type";

                int updateRes = db.SetCommand(strUpdatePromotionSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@StartDate", model.StartDate, DbType.Date)
                                                , db.Parameter("@EndDate", model.EndDate, DbType.Date)
                                                , db.Parameter("@TextContent", objText, DbType.String)
                                                , db.Parameter("@ImageFile", objImgUrl, DbType.String)
                                                , db.Parameter("@UpdaterID", model.OperatorID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", model.OperatorTime, DbType.DateTime)
                                                , db.Parameter("@ID", model.ID, DbType.Int32)
                                                , db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteNonQuery();

                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                //                if (model.BranchList != null && model.BranchList.Count > 0)
                //                {
                //                    string strSqlMarketPromoHistory = "INSERT INTO [TBL_HISTORY_MARKET_RELATIONSHIP] SELECT * FROM [TBL_MARKET_RELATIONSHIP] WHERE Code=@ID AND Type=2";
                //                    int hisRows = db.SetCommand(strSqlMarketPromoHistory, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();
                //                    if (rows <= 0)
                //                    {
                //                        db.RollbackTransaction();
                //                        return false;
                //                    }

                //                    string strUpdateMarketPromotionSql = @"UPDATE [TBL_MARKET_RELATIONSHIP] 
                //                                                        SET Available=0  
                //                                                        ,OperatorID=@OperatorID
                //                                                        ,OperateTime=@OperateTime
                //                                                        WHERE Code=@ID AND Type=2 ";
                //                    int updatehisRows = db.SetCommand(strUpdateMarketPromotionSql
                //                                                    , db.Parameter("@ID", model.ID, DbType.Int32)
                //                                                    , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                //                                                    , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();


                //                    foreach (BranchSelection_Model item in model.BranchList)
                //                    {
                //                        string addRelationship = @"INSERT INTO TBL_MARKET_RELATIONSHIP (CompanyID ,BranchID ,Type ,Code ,Available ,OperatorID ,OperateTime) 
                //                                            VALUES(@CompanyID ,@BranchID ,@Type ,@Code ,@Available ,@OperatorID ,@OperateTime)";

                //                        int addRes = db.SetCommand(addRelationship
                //                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                //                                                        , db.Parameter("@BranchID", item.BranchID, DbType.String)
                //                                                        , db.Parameter("@Type", 2, DbType.Int32)
                //                                                        , db.Parameter("@Code", model.ID, DbType.Int32)
                //                                                        , db.Parameter("@Available", true, DbType.Boolean)
                //                                                        , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                //                                                        , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();

                //                        if (addRes <= 0)
                //                        {
                //                            db.RollbackTransaction();
                //                            return false;
                //                        }
                //                    }
                //                }

                db.CommitTransaction();
                return true;
            }
        }

        public bool deletePromotionForManager(Promotion_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlPromotionHistory = "INSERT INTO [HISTORY_PROMOTION] SELECT * FROM [PROMOTION] WHERE ID =@ID";

                int rows = db.SetCommand(strSqlPromotionHistory, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strUpdatePromotionSql = @"UPDATE  PROMOTION
                                                SET      Available=0
                                                        ,UpdaterID = @UpdaterID
                                                        ,UpdateTime = UpdateTime";

                strUpdatePromotionSql += @" WHERE   CompanyID = @CompanyID
                                                        AND ID = @ID AND Type=@Type";

                int updateRes = db.SetCommand(strUpdatePromotionSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@UpdaterID", model.OperatorID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", model.OperatorTime, DbType.DateTime)
                                                , db.Parameter("@ID", model.ID, DbType.Int32)
                                                , db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteNonQuery();

                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlCount = @" select Count(*) from [TBL_MARKET_RELATIONSHIP] where Code =@Code and Type =2 ";

                int count = db.SetCommand(strSqlCount
                         , db.Parameter("@Code", model.ID, DbType.Int32)).ExecuteScalar<int>();

                if (count > 0)
                {

                    string strSqlMarketPromoHistory = "INSERT INTO [TBL_HISTORY_MARKET_RELATIONSHIP] SELECT * FROM [TBL_MARKET_RELATIONSHIP] WHERE Code=@ID AND Type=2";
                    int hisRows = db.SetCommand(strSqlMarketPromoHistory, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();
                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strUpdateMarketPromotionSql = @"UPDATE [TBL_MARKET_RELATIONSHIP] 
                                                        SET Available=0  
                                                        ,OperatorID=@OperatorID
                                                        ,OperateTime=@OperateTime
                                                        WHERE Code=@ID AND Type=2 ";
                    int updatehisRows = db.SetCommand(strUpdateMarketPromotionSql
                                                    , db.Parameter("@ID", model.ID, DbType.Int32)
                                                    , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                                    , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();
                    if (updatehisRows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                db.CommitTransaction();
                return true;
            }

        }

        public bool OperateBranch(BranchSelectOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCount = @" select Count(*) from [TBL_MARKET_RELATIONSHIP] where Code =@Code and Type =2 ";

                int count = db.SetCommand(strSqlCount
                         , db.Parameter("@Code", model.ObjectID, DbType.Int32)).ExecuteScalar<int>();

                if (count > 0)
                {

                    string strUpdateMarketPromotionSql = @"UPDATE [TBL_MARKET_RELATIONSHIP] 
                                                                        SET Available=0  
                                                                        ,OperatorID=@OperatorID
                                                                        ,OperateTime=@OperateTime
                                                                        WHERE Code=@ID AND Type=2 ";
                    int updatehisRows = db.SetCommand(strUpdateMarketPromotionSql
                                                    , db.Parameter("@ID", model.ObjectID, DbType.Int32)
                                                    , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                                    , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();

                    if (updatehisRows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlMarketPromoHistory = "INSERT INTO [TBL_HISTORY_MARKET_RELATIONSHIP] SELECT * FROM [TBL_MARKET_RELATIONSHIP] WHERE Code=@ID AND Type=2";
                    int hisRows = db.SetCommand(strSqlMarketPromoHistory, db.Parameter("@ID", model.ObjectID, DbType.Int32)).ExecuteNonQuery();
                    if (hisRows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqldELMarketPromo = "DELETE [TBL_MARKET_RELATIONSHIP]  WHERE Code=@ID AND Type=2";
                    int delRows = db.SetCommand(strSqldELMarketPromo, db.Parameter("@ID", model.ObjectID, DbType.Int32)).ExecuteNonQuery();
                    if (delRows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                if (model.BranchList != null)
                {
                    foreach (int item in model.BranchList)
                    {
                        string addRelationship = @"INSERT INTO TBL_MARKET_RELATIONSHIP (CompanyID ,BranchID ,Type ,Code ,Available ,OperatorID ,OperateTime) 
                                                            VALUES(@CompanyID ,@BranchID ,@Type ,@Code ,@Available ,@OperatorID ,@OperateTime)";

                        int addRes = db.SetCommand(addRelationship
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", item, DbType.String)
                                                        , db.Parameter("@Type", 2, DbType.Int32)
                                                        , db.Parameter("@Code", model.ObjectID, DbType.Int32)
                                                        , db.Parameter("@Available", true, DbType.Boolean)
                                                        , db.Parameter("@OperatorID", model.OperatorID, DbType.Int32)
                                                        , db.Parameter("@OperateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();

                        if (addRes <= 0)
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

        public List<New_Promotion_Model> getPromotionForManager_new(UtilityOperation_Model model)
        {
            List<New_Promotion_Model> list = new List<New_Promotion_Model>();

            using (DbManager db = new DbManager())
            {

                string strSql = "  SELECT T1.PromotionCode,T1.StartDate,T1.EndDate,T1.Type,T1.Title,T1.Description,T1.ImageFile,T1.PromotionType," + Const.getPromotionImgForManager
                                + @" FROM [TBL_PROMOTION] T1 WITH(NOLOCK)";

                if (model.BranchID > 0)
                {
                    strSql += " LEFT JOIN [TBL_PROMOTION_BRANCH] T2 WITH(NOLOCK) ON T2.PromotionCode=T1.PromotionCode AND T2.RecordType = 1 ";
                }

                strSql += "  WHERE  T1.RecordType=1 AND T1.CompanyID=@CompanyID ";

                if (model.BranchID > 0)
                {
                    strSql += "  AND T2.BranchID=@BranchID  ";
                }

                if (model.Flag == 1)//未开始
                {
                    strSql += " AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.StartDate) > 0 ";
                }
                else if (model.Flag == 2)//进行中
                {
                    strSql += @" AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.EndDate) >= 0
                                 AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.StartDate) <= 0 ";
                }
                else if (model.Flag == 3)//已结束
                {
                    strSql += " AND DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),T1.EndDate) < 0 ";
                }

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<New_Promotion_Model>();

                return list;

            }
        }



        public New_Promotion_Model getPromotionDetailForManager_New(UtilityOperation_Model model)
        {
            New_Promotion_Model res = new New_Promotion_Model();

            using (DbManager db = new DbManager())
            {
                string strSql = "  SELECT T1.PromotionCode,T1.StartDate,T1.EndDate,T1.Type,T1.Title,T1.Description,T1.ImageFile,T1.HasProduct,T1.PromotionType," + Const.getPromotionImgForManager
                                + @" FROM [TBL_PROMOTION] T1 WITH(NOLOCK) 
                                    WHERE T1.RecordType=1 AND T1.CompanyID=@CompanyID AND T1.PromotionCode=@PromotionCode ";

                res = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@PromotionCode", model.PromotionCode, DbType.String)).ExecuteObject<New_Promotion_Model>();

                return res;

            }
        }


        public List<BranchSelection_Model> getBranchIDListByPromotionIDForManager_New(int companyID, string PromotionCode)
        {
            List<BranchSelection_Model> list = new List<BranchSelection_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT DISTINCT T1.ID AS BranchID, T1.BranchName,
                                CASE WHEN T2.BranchID=T1.ID THEN 1 ELSE 0 END AS IsExist
                                FROM    BRANCH T1
                                        LEFT JOIN TBL_PROMOTION_BRANCH T2 ON T1.ID = T2.BranchID and PromotionCode=@PromotionCode AND T2.RecordType=1 
                                WHERE   T1.CompanyID = @CompanyID  AND T1.Available=1 ";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@PromotionCode", PromotionCode, DbType.String)).ExecuteList<BranchSelection_Model>();

                return list;
            }
        }


        public string addPromotionForManager_New(New_Promotion_Model model, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string PromotionCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "PROMOTIONCODE", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();
                if (PromotionCode == null || PromotionCode == "")
                {
                    db.RollbackTransaction();
                    return null;
                }



                string strSql = @" INSERT INTO [TBL_PROMOTION]
                                (CompanyID,BranchID,PromotionCode,StartDate,EndDate,Title,Description,Type,ImageFile,CreatorID,CreateTime,RecordType,HasProduct,PromotionType)
                                  VALUES
                                (@CompanyID,@BranchID,@PromotionCode,@StartDate,@EndDate,@Title,@Description,@Type,@ImageFile,@CreatorID,@CreateTime,1,@HasProduct,@PromotionType)";
                int rows = db.SetCommand(strSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", 0, DbType.Int32)
                                                , db.Parameter("@PromotionCode", PromotionCode, DbType.String)
                                                , db.Parameter("@StartDate", model.StartDate, DbType.Date)
                                                , db.Parameter("@EndDate", model.EndDate, DbType.Date)
                                                , db.Parameter("@Title", model.Title, DbType.String)
                                                , db.Parameter("@Description", model.Description, DbType.String)
                                                , db.Parameter("@Type", model.Type, DbType.Int32)
                                                , db.Parameter("@ImageFile", model.ImageFile, DbType.String)
                                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                                , db.Parameter("@HasProduct", model.HasProduct, DbType.Int32)
                                                , db.Parameter("@PromotionType", model.PromotionType, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return null;
                }

                if (branchID > 0)
                {
                    string addRelationship = @"INSERT INTO [TBL_PROMOTION_BRANCH]
                                           (CompanyID,BranchID,PromotionCode,CreatorID,CreateTime,RecordType)
                                            VALUES
                                           (@CompanyID,@BranchID,@PromotionCode,@CreatorID,@CreateTime,1)";

                    int addRes = db.SetCommand(addRelationship
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", branchID, DbType.String)
                                                    , db.Parameter("@PromotionCode", PromotionCode, DbType.String)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                    if (addRes != 1)
                    {
                        db.RollbackTransaction();
                        return null;
                    }
                }

                db.CommitTransaction();
                return PromotionCode;

            }
        }


        public bool updatePromotionForManager_New(New_Promotion_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCheck = @" SELECT count(0) FROM TBL_PROMOTION WITH (NOLOCK) WHERE PromotionCode =@PromotionCode AND CompanyID =@CompanyID  AND StartDate > GETDATE()  ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@PromotionCode", model.PromotionCode, DbType.String)).ExecuteScalar<int>();
                if (check == 0)
                {
                    string strUpdatePromotionSql = @"UPDATE  TBL_PROMOTION
                                                SET     EndDate = @EndDate
                                                        ,UpdaterID = @UpdaterID
                                                        ,UpdateTime =@UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                        AND PromotionCode = @PromotionCode ";

                    int updateRes = db.SetCommand(strUpdatePromotionSql
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@EndDate", model.EndDate, DbType.Date)
                                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                                    , db.Parameter("@PromotionCode", model.PromotionCode, DbType.String)).ExecuteNonQuery();

                    if (updateRes != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                else
                {

                    string strUpdatePromotionSql = @"UPDATE  TBL_PROMOTION
                                                SET     StartDate = @StartDate
                                                        ,EndDate = @EndDate
                                                        ,Title = @Title
                                                        ,Description = @Description
                                                        ,Type = @Type
                                                        ,UpdaterID = @UpdaterID
                                                        ,UpdateTime =@UpdateTime
                                                        ,PromotionType = @PromotionType";
                    if (model.ImageFile != "" && model.ImageFile != null)
                    {
                        strUpdatePromotionSql += "  ,ImageFile = @ImageFile ";
                    }

                    strUpdatePromotionSql += @" WHERE   CompanyID = @CompanyID
                                                        AND PromotionCode = @PromotionCode ";

                    int updateRes = db.SetCommand(strUpdatePromotionSql
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@StartDate", model.StartDate, DbType.Date)
                                                    , db.Parameter("@EndDate", model.EndDate, DbType.Date)
                                                    , db.Parameter("@Title", model.Title, DbType.String)
                                                    , db.Parameter("@Description", model.Description, DbType.String)
                                                    , db.Parameter("@Type", model.Type, DbType.Int32)
                                                    , db.Parameter("@ImageFile", model.ImageFile, DbType.String)
                                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                                    , db.Parameter("@PromotionCode", model.PromotionCode, DbType.String)
                                                    , db.Parameter("@PromotionType", model.PromotionType, DbType.Int32)).ExecuteNonQuery();

                    if (updateRes != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                db.CommitTransaction();
                return true;
            }
        }


        public bool deletePromotionForManager_New(New_Promotion_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                //string strSqlPromotionHistory = "INSERT INTO [HISTORY_PROMOTION] SELECT * FROM [PROMOTION] WHERE ID =@ID";

                //int rows = db.SetCommand(strSqlPromotionHistory, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                //if (rows <= 0)
                //{
                //    db.RollbackTransaction();
                //    return false;
                //}

                string strUpdatePromotionSql = @"UPDATE  PROMOTION
                                                SET      RecordType=2
                                                        ,UpdaterID = @UpdaterID
                                                        ,UpdateTime = UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                        AND PromotionCode = @PromotionCode";


                int updateRes = db.SetCommand(strUpdatePromotionSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                                , db.Parameter("@PromotionCode", model.PromotionCode, DbType.String)).ExecuteNonQuery();

                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlCount = @" select Count(*) from [TBL_PROMOTION_BRANCH] where PromotionCode =@PromotionCode and CompanyID =@CompanyID ";

                int count = db.SetCommand(strSqlCount
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@PromotionCode", model.PromotionCode, DbType.String)).ExecuteScalar<int>();

                if (count > 0)
                {

                    //string strSqlMarketPromoHistory = "INSERT INTO [TBL_HISTORY_MARKET_RELATIONSHIP] SELECT * FROM [TBL_MARKET_RELATIONSHIP] WHERE Code=@ID AND Type=2";
                    //int hisRows = db.SetCommand(strSqlMarketPromoHistory, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();
                    //if (rows <= 0)
                    //{
                    //    db.RollbackTransaction();
                    //    return false;
                    //}

                    string strUpdateMarketPromotionSql = @"UPDATE [TBL_MARKET_RELATIONSHIP] 
                                                        SET RecordType=2  
                                                        ,OperatorID=@OperatorID
                                                        ,OperateTime=@OperateTime
                                                        WHERE PromotionCode=@PromotionCode  and CompanyID =@CompanyID ";
                    int updatehisRows = db.SetCommand(strUpdateMarketPromotionSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                                , db.Parameter("@PromotionCode", model.PromotionCode, DbType.String)).ExecuteNonQuery();
                    if (updatehisRows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                db.CommitTransaction();
                return true;
            }

        }


        public int OperateBranch_New(BranchSelectOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCheck = @" SELECT count(0) FROM TBL_PROMOTION WITH (NOLOCK) WHERE PromotionCode =@PromotionCode AND CompanyID =@CompanyID AND StartDate > GETDATE() ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@PromotionCode", model.ObjectCode, DbType.String)).ExecuteScalar<int>();
                if (check == 0)
                {
                    return -1;
                }
                string strSqlCount = @" select Count(*) from [TBL_PROMOTION_BRANCH] where PromotionCode =@PromotionCode ";

                int count = db.SetCommand(strSqlCount
                         , db.Parameter("@PromotionCode", model.ObjectCode, DbType.String)).ExecuteScalar<int>();

                if (count > 0)
                {

                    string strSqlMarketPromoHistory = "INSERT INTO [HST_PROMOTION_BRANCH] SELECT * FROM [TBL_PROMOTION_BRANCH]  where PromotionCode =@PromotionCode ";
                    int hisRows = db.SetCommand(strSqlMarketPromoHistory, db.Parameter("@PromotionCode", model.ObjectCode, DbType.String)).ExecuteNonQuery();
                    if (hisRows <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqldELMarketPromo = "DELETE  [TBL_PROMOTION_BRANCH]  where PromotionCode =@PromotionCode ";
                    int delRows = db.SetCommand(strSqldELMarketPromo, db.Parameter("@PromotionCode", model.ObjectCode, DbType.String)).ExecuteNonQuery();
                    if (delRows <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                if (model.BranchList != null)
                {
                    foreach (int item in model.BranchList)
                    {
                        string addRelationship = @"INSERT INTO [TBL_PROMOTION_BRANCH]
                                                    (CompanyID,BranchID,PromotionCode,CreatorID,CreateTime,RecordType)
                                                     VALUES
                                                    (@CompanyID,@BranchID,@PromotionCode,@CreatorID,@CreateTime,1)";
                        int addRes = db.SetCommand(addRelationship
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", item, DbType.String)
                                                        , db.Parameter("@PromotionCode", model.ObjectCode, DbType.String)
                                                        , db.Parameter("@CreatorID", model.OperatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.OperatorTime, DbType.DateTime)).ExecuteNonQuery();

                        if (addRes <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }
                }


                string strSqlHasProduct = @" update [TBL_PROMOTION] set HasProduct = 0 where PromotionCode =@PromotionCode and CompanyID =@CompanyID ";
                int rows = db.SetCommand(strSqlHasProduct
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@PromotionCode", model.ObjectCode, DbType.String)).ExecuteNonQuery();


                string strSqldelProduct = @" delete TBL_PROMOTION_PRODUCT where PromotionID =@PromotionID and CompanyID =@CompanyID ";
                rows = db.SetCommand(strSqldelProduct
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@PromotionID", model.ObjectCode, DbType.String)).ExecuteNonQuery();



                string strSqldelRule = @" delete TBL_PROMOTION_RULE where PromotionID =@PromotionID and CompanyID =@CompanyID ";
                rows = db.SetCommand(strSqldelRule
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@PromotionID", model.ObjectCode, DbType.String)).ExecuteNonQuery();


                db.CommitTransaction();
                return 1;
            }
        }

        #region 新促销规则
        public List<PromotionRule_Model> getPromotionRuleList()
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT distinct PromotionType,PromotionTypeName FROM [SYS_PROMOTION_RULE] WITH (NOLOCK) where Type = 1 ";
                List<PromotionRule_Model> list = db.SetCommand(strSql).ExecuteList<PromotionRule_Model>();
                return list;
            }
        }

        public List<PromotoinProduct_Model> getPromotionProductSelect(int companyId, string promotionCode, int type)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlGetBranch = @" SELECT BranchID FROM [TBL_PROMOTION_BRANCH] T1 where T1.PromotionCode =@PromotionCode and T1.CompanyID =@CompanyID ";
                List<int> listBranchID = db.SetCommand(strSqlGetBranch, db.Parameter("@PromotionCode", promotionCode, DbType.String)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalarList<int>();

                string strWhereBranch = "";
                int branchCount = 0;
                if (listBranchID == null || listBranchID.Count == 0)
                {
                    return null;
                }
                else
                {
                    foreach (int item in listBranchID)
                    {
                        if (strWhereBranch != "")
                        {
                            strWhereBranch += ",";
                        }
                        strWhereBranch += item.ToString();
                    }
                    branchCount = listBranchID.Count;
                }



                string strSqlProduct;
                if (type == 0)
                {
                    strSqlProduct = @" select T2.Code ProductCode,T2.ServiceName ProductName  ,T2.UnitPrice
                                            from [TBL_MARKET_RELATIONSHIP] T1 with (nolock) 
                                            INNER JOIN [SERVICE] T2 with (nolock) 
                                            ON T1.Code = T2.Code AND T2.Available = 1 
                                            where  T1.Available = 1 and T1.Type = 0 and T1.BranchID in ({0}) 
                                            GROUP BY T2.Code,T2.ServiceName,T2.UnitPrice having count(0) =@BranchCount  ";

                }
                else
                {
                    strSqlProduct = @"  select T2.Code ProductCode,T2.CommodityName ProductName,T2.UnitPrice,T2.Specification
                                        from [TBL_MARKET_RELATIONSHIP] T1 with (nolock) 
                                        INNER JOIN [COMMODITY] T2  with (nolock) 
                                        ON T1.Code = T2.Code AND T2.Available = 1 
                                        where  T1.Available = 1 and T1.Type = 1 and T1.BranchID in ({0}) 
                                        GROUP BY T2.Code,T2.CommodityName ,T2.UnitPrice,T2.Specification having count(0) =@BranchCount ";
                }

                string strSqlFinal = string.Format(strSqlProduct, strWhereBranch);

                List<PromotoinProduct_Model> list = db.SetCommand(strSqlFinal
                      , db.Parameter("@BranchCount", branchCount, DbType.Int32)).ExecuteList<PromotoinProduct_Model>();
                return list;
            }
        }


        public List<PromotoinProduct_Model> getPromotionProductList(string promotionCode, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.PromotionID, T1.ProductID,T1.ProductID,T1.ProductPromotionName,ISNULL(T2.UnitPrice,ISNULL(T3.UnitPrice,0)) UnitPrice,T1.DiscountPrice,T4.PRValue - T1.SoldQuantity SurplusQuantity,T1.ProductType as ProductType,T3.Specification from [TBL_PROMOTION_PRODUCT] T1 with (nolock) 
                                left join [SERVICE] T2  with (nolock)  ON T1.ProductID = T2.ID AND T1.ProductType = 0 
                                left join [COMMODITY] T3  with (nolock)  ON T1.ProductID = T3.ID AND T1.ProductType = 1 
                                LEFT JOIN [TBL_PROMOTION_RULE] T4 with (nolock)  ON T1.PromotionID = T4.PromotionID AND T4.PRCode = 1 AND T1.ProductID = T4.ProductID AND T1.ProductType = T4.ProductType
                                WHERE T1.PromotionID =@PromotionCode AND T1.CompanyID =@CompanyID ";
                List<PromotoinProduct_Model> list = db.SetCommand(strSql, db.Parameter("@PromotionCode", promotionCode, DbType.String)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<PromotoinProduct_Model>();

                return list;
            }
        }

        public int addPromotionProduct(PromotoinProduct_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlCheck = @" SELECT count(0) FROM TBL_PROMOTION WITH (NOLOCK) WHERE PromotionCode =@PromotionCode AND CompanyID =@CompanyID  AND StartDate > GETDATE() ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@PromotionCode", model.PromotionID, DbType.String)).ExecuteScalar<int>();
                if (check == 0)
                {
                    return -1;
                }

                string strSql = @" INSERT INTO [TBL_PROMOTION_PRODUCT]
                                (CompanyID,PromotionID,ProductID,ProductPromotionName,ProductType,DiscountPrice,Notice,SoldQuantity,CreatorID,CreateTime,RecordType)
                                VALUES
                                (@CompanyID,@PromotionID,@ProductID,@ProductPromotionName,@ProductType,@DiscountPrice,@Notice,@SoldQuantity,@CreatorID,@CreateTime,@RecordType) ";
                int rows = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@PromotionID", model.PromotionID, DbType.String)
                     , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                     , db.Parameter("@ProductPromotionName", model.ProductPromotionName, DbType.String)
                     , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                     , db.Parameter("@DiscountPrice", model.DiscountPrice, DbType.Decimal)
                     , db.Parameter("@Notice", model.Notice, DbType.String)
                     , db.Parameter("@SoldQuantity", 0, DbType.Int32)
                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                     , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                     , db.Parameter("@RecordType", 1, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                if (model.PromotionRuleList != null && model.PromotionRuleList.Count > 0)
                {
                    string strSqlRule = @" INSERT INTO [TBL_PROMOTION_RULE]
                                        (CompanyID,ProductID,ProductType,PromotionID,PromotionType,PRCode,PRValue,CreatorID,CreateTime,RecordType)
                                         VALUES
                                        (@CompanyID,@ProductID,@ProductType,@PromotionID,@PromotionType,@PRCode,@PRValue,@CreatorID,@CreateTime,@RecordType) ";

                    foreach (PromotionRule_Model item in model.PromotionRuleList)
                    {
                        rows = db.SetCommand(strSqlRule, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@PromotionID", model.PromotionID, DbType.String)
                             , db.Parameter("@PromotionType", model.PromotionType, DbType.Int32)
                             , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                             , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                             , db.Parameter("@PRCode", item.PRCode, DbType.String)
                             , db.Parameter("@PRValue", item.PRValue, DbType.Int32)
                             , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                             , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                             , db.Parameter("@RecordType", 1, DbType.Int32)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }
                }

                string strSqlHasProduct = @" update TBL_PROMOTION set HasProduct = 1 where PromotionCode =@PromotionCode and CompanyID =@CompanyID ";

                rows = db.SetCommand(strSqlHasProduct, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@PromotionCode", model.PromotionID, DbType.String)
                           ).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public int updatePromotionProduct(PromotoinProduct_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlCheck = @" SELECT count(0) FROM TBL_PROMOTION WITH (NOLOCK) WHERE PromotionCode =@PromotionCode AND CompanyID =@CompanyID  AND StartDate > GETDATE()  ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@PromotionCode", model.PromotionID, DbType.String)).ExecuteScalar<int>();
                if (check == 0)
                {
                    return -1;
                }

                string strSql = @" UPDATE [TBL_PROMOTION_PRODUCT]
                                    SET ProductPromotionName = @ProductPromotionName
                                    ,DiscountPrice = @DiscountPrice
                                    ,Notice = @Notice
                                    ,UpdaterID = @UpdaterID
                                    ,UpdateTime = @UpdateTime
                                    WHERE PromotionID = @PromotionID and ProductID=@ProductID and ProductType=@ProductType and CompanyID=@CompanyID ";
                int rows = db.SetCommand(strSql
                     , db.Parameter("@ProductPromotionName", model.ProductPromotionName, DbType.String)
                     , db.Parameter("@DiscountPrice", model.DiscountPrice, DbType.Decimal)
                     , db.Parameter("@Notice", model.Notice, DbType.String)
                     , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                     , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                     , db.Parameter("@PromotionID", model.PromotionID, DbType.String)
                     , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                     , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }



                string strSqlDelete = @"delete TBL_PROMOTION_RULE   WHERE CompanyID = @CompanyID
                                                and PromotionID = @PromotionID and  ProductID=@ProductID and ProductType=@ProductType ";

                rows = db.SetCommand(strSqlDelete
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@PromotionID", model.PromotionID, DbType.String)
                    , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                    , db.Parameter("@ProductType", model.ProductType, DbType.Int32)).ExecuteNonQuery();

                if (model.PromotionRuleList != null && model.PromotionRuleList.Count > 0)
                {

                    string strSqlRule = @" INSERT INTO [TBL_PROMOTION_RULE]
                                        (CompanyID,ProductID,ProductType,PromotionID,PromotionType,PRCode,PRValue,CreatorID,CreateTime,RecordType)
                                         VALUES
                                        (@CompanyID,@ProductID,@ProductType,@PromotionID,@PromotionType,@PRCode,@PRValue,@CreatorID,@CreateTime,@RecordType) ";

                    foreach (PromotionRule_Model item in model.PromotionRuleList)
                    {
                        rows = db.SetCommand(strSqlRule, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@PromotionID", model.PromotionID, DbType.String)
                             , db.Parameter("@PromotionType", model.PromotionType, DbType.Int32)
                             , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                             , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                             , db.Parameter("@PRCode", item.PRCode, DbType.String)
                             , db.Parameter("@PRValue", item.PRValue, DbType.Int32)
                             , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                             , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                             , db.Parameter("@RecordType", 1, DbType.Int32)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }
                }

                db.CommitTransaction();
                return 1;
            }
        }


        public PromotoinProduct_Model getPromotionProductDetailAdd(string PromotionCode, long ProductCode, int ProductType, int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                PromotoinProduct_Model model = new PromotoinProduct_Model();

                //新添加
                if (ProductType == 0)
                {
                    string strSql = @" select ServiceName ProductName,ID ProductID,UnitPrice, 0 as ProductType  from [SERVICE] with (NOLOCK) where Code =@Code and CompanyID =@CompanyID and Available = 1";
                    model = db.SetCommand(strSql
                         , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                         , db.Parameter("@Code", ProductCode, DbType.Int64)).ExecuteObject<PromotoinProduct_Model>();
                }
                else
                {
                    string strSql = @" select CommodityName ProductName,ID ProductID,UnitPrice, 1 as ProductType from [COMMODITY] with (NOLOCK) where Code =@Code and CompanyID =@CompanyID and Available = 1 ";
                    model = db.SetCommand(strSql
                         , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                         , db.Parameter("@Code", ProductCode, DbType.Int64)).ExecuteObject<PromotoinProduct_Model>();
                }

                if (model == null)
                {
                    return null;
                }

                string strSqlRule = @"select T2.PromotionType,T2.PromotionTypeName,T2.PRCode,T2.PRDesc, 0 AS IsUse
                                    from [TBL_PROMOTION] T1 WITH (NOLOCK) 
                                    INNER JOIN [SYS_PROMOTION_RULE] T2 WITH (NOLOCK) 
                                    ON T1.PromotionType = T2.PromotionType
                                    where T1.PromotionCode=@PromotionCode and T1.CompanyID=@CompanyID ";

                model.PromotionRuleList = new List<PromotionRule_Model>();
                model.PromotionRuleList = db.SetCommand(strSqlRule
                         , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                         , db.Parameter("@PromotionCode", PromotionCode, DbType.String)).ExecuteList<PromotionRule_Model>();

                if (model.PromotionRuleList != null)
                {
                    model.PromotionType = model.PromotionRuleList[0].PromotionType;
                }

                return model;
            }
        }


        public PromotoinProduct_Model getPromotionProductDetailEdit(string PromotionCode, int ProductID, int ProductType, int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                PromotoinProduct_Model model = new PromotoinProduct_Model();
                string strSql = @" select T1.PromotionID, T1.ProductPromotionName ,T1.ProductID,T2.UnitPrice,T1.Notice,T1.ProductType,T1.DiscountPrice {1} from [TBL_PROMOTION_PRODUCT] T1  with (NOLOCK)
                                {0}
                                where T1.PromotionID =@PromotionID and T1.CompanyID =@CompanyID and T1.ProductID =@ProductID and T1.ProductType=@ProductType ";
                string strProduct = "";
                string strProductName = "";
                if (ProductType == 0)
                {
                    strProductName = " , T2.ServiceName ProductName ";
                    strProduct = "  LEFT JOIN [SERVICE] T2 with (NOLOCK) ON T1.ProductID = T2.ID AND T1.ProductType = 0 ";
                }
                else
                {
                    strProductName = " , T2.CommodityName ProductName ";
                    strProduct = "   LEFT JOIN [COMMODITY] T2 with (NOLOCK) ON T1.ProductID = T2.ID AND T1.ProductType = 1 ";
                }
                string strFinal = string.Format(strSql, strProduct, strProductName);
                model = db.SetCommand(strFinal
                     , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                     , db.Parameter("@PromotionID", PromotionCode, DbType.String)
                     , db.Parameter("@ProductID", ProductID, DbType.Int32)
                     , db.Parameter("@ProductType", ProductType, DbType.Int32)).ExecuteObject<PromotoinProduct_Model>();

                if (model == null)
                {
                    return null;
                }
                string strSqlRule = @"select T2.PromotionType,T2.PromotionTypeName,T2.PRCode,T2.PRDesc,T3.PRValue ,ISNULL(T3.ID,0) IsUse
                                    from [TBL_PROMOTION] T1 WITH (NOLOCK) 
                                    INNER JOIN [SYS_PROMOTION_RULE] T2 WITH (NOLOCK) 
                                    ON T1.PromotionType = T2.PromotionType
									LEFT JOIN [TBL_PROMOTION_RULE] T3 WITH (NOLOCK) 
                                    ON T1.PromotionCode = T3.PromotionID AND T1.PromotionType = T3.PromotionType AND T2.PRCode = T3.PRCode AND T3.ProductID=@ProductID AND T3.ProductType=@ProductType
                                    where T1.PromotionCode=@PromotionCode and T1.CompanyID=@CompanyID ";

                model.PromotionRuleList = new List<PromotionRule_Model>();
                model.PromotionRuleList = db.SetCommand(strSqlRule
                         , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                         , db.Parameter("@PromotionCode", PromotionCode, DbType.String)
                        , db.Parameter("@ProductID", ProductID, DbType.Int32)
                        , db.Parameter("@ProductType", ProductType, DbType.Int32)).ExecuteList<PromotionRule_Model>();
                if (model.PromotionRuleList != null && model.PromotionRuleList.Count > 0)
                {
                    model.PromotionType = model.PromotionRuleList[0].PromotionType;
                }
                return model;
            }
        }




        public List<PromotionSale_Model> getPromotionSaleDetail(int companyID, String promotionID)
        {
            List<PromotionSale_Model> list = new List<PromotionSale_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" select  T1.PromotionID, T2.ProductPromotionName,T3.BranchName,T2.DiscountPrice,Count(0) RushOrderCount,T7.PRValue as PRValue,SUM(T1.RushQuantity) as RushQuantity,ISNULL(T4.PayOrder,0) AS PayOrder ,ISNULL(T4.PayQuantity,0) AS SoldQuantity  ,T6.PRValue - T2.SoldQuantity SurplusQuantity, T2.DiscountPrice *  ISNULL(T4.PayQuantity,0) PayAmount from [TBL_RUSH_ORDER] T1 WITH (NOLOCK) 
                                    INNER JOIN [TBL_PROMOTION_PRODUCT] T2 WITH (NOLOCK) 
                                    ON T1.PromotionID = T2.PromotionID AND T1.ProductID = T2.ProductID AND T1.ProductType = T2.ProductType
                                    LEFT JOIN [TBL_PROMOTION_RULE] T7 ON T2.PromotionID = T7.PromotionID AND T2.ProductID = T7.ProductID AND T2.ProductType = T7.ProductType AND T7.RecordType = 1 and T7.PromotionType = 1 AND T7.PRCode = 1
									LEFT JOIN [BRANCH] T3 WITH (NOLOCK) ON T1.BranchID = T3.ID 

									LEFT JOIN (select T5.PromotionID,T5.BranchID, T5.ProductType,T5.ProductID,Count(0) PayOrder,Sum(T5.RushQuantity) PayQuantity from [TBL_RUSH_ORDER] T5 WITH (NOLOCK) where T5.PromotionID =@PromotionID AND T5.CompanyID =@CompanyID and T5.PaymentStatus = 2 GROUP BY  T5.PromotionID, T5.ProductType,T5.ProductID,T5.BranchID) T4 ON T1.PromotionID = T4.PromotionID AND T1.ProductType = T4.ProductType AND T1.ProductID = T4.ProductID AND T1.BranchID = T4.BranchID
									LEFT JOIN [TBL_PROMOTION_RULE] T6 ON T1.PromotionID = T6.PromotionID AND T1.ProductType = T6.ProductType AND T6.ProductID = T6.ProductID AND T6.PRCode = 1
                                    WHERE T1.PromotionID =@PromotionID AND T1.CompanyID =@CompanyID GROUP BY  T1.PromotionID, T2.ProductPromotionName,T3.BranchName,T2.DiscountPrice, T2.SoldQuantity ,T4.PayOrder,T6.PRValue,T4.PayQuantity,T7.PRValue";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@PromotionID", promotionID, DbType.String)).ExecuteList<PromotionSale_Model>();

                return list;
            }
        }
        #endregion

        public int deletePromotionProduct(PromotoinProduct_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlCheck = @" SELECT count(0) FROM TBL_PROMOTION WITH (NOLOCK) WHERE PromotionCode =@PromotionCode AND CompanyID =@CompanyID AND StartDate > GETDATE()  ";

                int check = db.SetCommand(strSqlCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@PromotionCode", model.PromotionID, DbType.String)).ExecuteScalar<int>();
                if (check == 0)
                {
                    return -1;
                }

                string strSql = @" delete [TBL_PROMOTION_PRODUCT]
                                    WHERE PromotionID = @PromotionID and ProductID=@ProductID and ProductType=@ProductType and CompanyID=@CompanyID ";
                int rows = db.SetCommand(strSql
                     , db.Parameter("@PromotionID", model.PromotionID, DbType.String)
                     , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                     , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }


                string strSqlDelete = @"delete TBL_PROMOTION_RULE   WHERE CompanyID = @CompanyID
                                                and PromotionID = @PromotionID and  ProductID=@ProductID and ProductType=@ProductType ";

                rows = db.SetCommand(strSqlDelete
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@PromotionID", model.PromotionID, DbType.String)
                    , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                    , db.Parameter("@ProductType", model.ProductType, DbType.Int32)).ExecuteNonQuery();

                db.CommitTransaction();
                return 1;
            }
        }


    }
}
