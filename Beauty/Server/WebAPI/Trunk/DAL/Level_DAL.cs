using BLToolkit.Data;
using HS.Framework.Common.Util;
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
    public class Level_DAL
    {
        #region 构造类实例
        public static Level_DAL Instance
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
            internal static readonly Level_DAL instance = new Level_DAL();
        }
        #endregion

        public List<GetLevelList_Model> getLevelList(int companyId, int flag)
        {
            using (DbManager db = new DbManager())
            {
                List<GetLevelList_Model> list = new List<GetLevelList_Model>();
                string strSql = @"SELECT T1.ID AS LevelID , T1.LevelName, CASE WHEN T2.DefaultCardID=T1.ID THEN 1 ELSE 0 END AS IsDefault,T1.Available
                                            FROM    [LEVEL] T1 WITH(NOLOCK)
                                            LEFT JOIN [COMPANY] T2 WITH(NOLOCK) ON T1.CompanyID=T2.ID
                                            WHERE   T1.CompanyID = @CompanyID ";

                if (flag == 0)
                {
                    strSql += " and T1.Available = 1 ";
                }

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<GetLevelList_Model>();

                return list;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public List<GetDiscountList_Model> getDiscountListForWebService(int levelId, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                List<GetDiscountList_Model> list = new List<GetDiscountList_Model>();
                if (levelId == 0 && customerId > 0)
                {
                    string strSql = @"select T2.DiscountName,T2.Discount 
                                        from [CUSTOMER] T1 WITH (NOLOCK) 
                                        INNER JOIN (
                                        select T4.CompanyID ,T3.CardID,T3.Available,T3.Discount,T4.DiscountName 
                                        from [TBL_CARD_DISCOUNT] T3 WITH (NOLOCK) 
                                        INNER JOIN [TBL_DISCOUNT] T4 WITH (NOLOCK) 
                                        ON T3.DiscountID = T4.ID) T2
                                        ON T1.LevelID = T2.LevelID 
                                        AND T1.CompanyID = T2.CompanyID AND T2.Available = 1 
                                        WHERE T1.UserID =@UserID ";
                    list = db.SetCommand(strSql, db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteList<GetDiscountList_Model>();
                }
                else if (levelId > 0 && customerId == 0)
                {
                    string strSql = @" select T1.DiscountName,T1.Discount 
                                    from (
                                    select T4.CompanyID ,T3.CardID,T3.Available,T3.Discount,T4.DiscountName 
                                    from [TBL_CARD_DISCOUNT] T3 WITH (NOLOCK) 
                                    INNER JOIN [TBL_DISCOUNT] T4 WITH (NOLOCK) 
                                    ON T3.DiscountID = T4.ID) T1
                                    where T1.CardID = @CardID AND T1.Available = 1  ";
                    list = db.SetCommand(strSql, db.Parameter("@CardID", levelId, DbType.Int32)).ExecuteList<GetDiscountList_Model>();
                }
                return list;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool changeLevel(int levelId, int customerId)
        {
            using (DbManager db = new DbManager())
            {

                db.BeginTransaction();

                string strSqlHistoryUser = " INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE UserID =@UserID ";
                int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @" UPDATE CUSTOMER SET LevelID =@LevelID where UserID =@UserID";

                object objLevelId = DBNull.Value;
                if (levelId > 0)
                {
                    objLevelId = levelId;
                }

                int rows = db.SetCommand(strSql, db.Parameter("@LevelID", objLevelId, DbType.Int32)
                                               , db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteNonQuery();

                if (rows > 0)
                {
                    db.CommitTransaction();
                    return true;
                }
                else
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }

        public List<GetDiscountListForManager_Model> getDiscountListForManager(int companyId, int flag, int pageIndex, int pageSize, out int recordCount)
        {
            using (DbManager db = new DbManager())
            {
                List<GetDiscountListForManager_Model> list = new List<GetDiscountListForManager_Model>();

                string fileds = @" ROW_NUMBER() OVER ( ORDER BY ID ASC ) AS rowNum ,
                                                  ID,DiscountName,CreateTime,Available ";

                string strSql = "";

                strSql = @"SELECT  {0} FROM TBL_DISCOUNT WHERE CompanyID=@CompanyID ";

                if (flag == 0)
                {
                    strSql += " AND Available=1 ";
                }

                string strCountSql = string.Format(strSql, " count(0) ");

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<GetDiscountListForManager_Model>();
                return list;
            }
        }

        public bool deleteDiscount(Discount_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlCheck = @"SELECT SUM(cnt) from (
                                        select COUNT(id) cnt from [SERVICE]
                                        where DiscountID =@DiscountID and Available = 1 AND CompanyID=@CompanyID
                                        union all
                                        select COUNT(id) cnt from  COMMODITY 
                                        where DiscountID =@DiscountID and Available = 1 AND CompanyID=@CompanyID ) T1";

                int cnt = db.SetCommand(strSqlCheck
                    , db.Parameter("@DiscountID", model.ID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                if (cnt != 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlDiscountHistory = "INSERT INTO [TBL_HISTORY_DISCOUNT] SELECT * FROM [TBL_DISCOUNT] WHERE ID =@ID AND CompanyID=@CompanyID";
                int rows = db.SetCommand(strSqlDiscountHistory
                    , db.Parameter("@ID", model.ID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlUpdateDiscount = @"update [TBL_DISCOUNT] set 
                                                    Available=@Available,
                                                    UpdaterID=@UpdaterID,
                                                    UpdateTime=@UpdateTime
                                                    where ID=@ID AND CompanyID=@CompanyID ";
                rows = db.SetCommand(strSqlUpdateDiscount
                    , db.Parameter("@Available", model.Available, DbType.Boolean)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@ID", model.ID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                //string strSqlRelatHistory = @" INSERT INTO [HST_CARD_DISCOUNT] select T1.* from [TBL_CARD_DISCOUNT] T1 INNER JOIN [TBL_DISCOUNT] T2 ON T1.DiscountID = T2.ID AND T2.CompanyID=@CompanyID WHERE T1.DiscountID=@ID";


                //rows = db.SetCommand(strSqlRelatHistory
                //    , db.Parameter("@ID", model.ID, DbType.Int32)
                //    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();


                //if (rows <= 0)
                //{
                //    db.RollbackTransaction();
                //    return false;
                //}
                //string strSqlRelatDelete = @"  delete   [TBL_CARD_DISCOUNT] From  [TBL_CARD_DISCOUNT]  T1  INNER JOIN   [TBL_DISCOUNT] T2 ON T1.DiscountID = T2.ID AND T2.CompanyID=@CompanyID WHERE T1.DiscountID=@ID ";


                //rows = db.SetCommand(strSqlRelatDelete
                //    , db.Parameter("@ID", model.ID, DbType.Int32)
                //    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();



                //if (rows <= 0)
                //{
                //    db.RollbackTransaction();
                //    return false;
                //}

                db.CommitTransaction();
                return true;
            }
        }

        public bool isExistDiscountName(int companyID, string DiscountName)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCheck = @"SELECT COUNT(0) FROM  TBL_DISCOUNT WHERE DiscountName=@DiscountName AND CompanyID=@CompanyID AND Available=1";

                int count = db.SetCommand(strSqlCheck
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@DiscountName", DiscountName, DbType.String)).ExecuteScalar<int>();

                if (count == 0)
                {
                    return false;
                }

                return true;
            }
        }

        public bool isExistDiscountID(int companyID, int discountID)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCheck = @"SELECT COUNT(0) FROM  TBL_DISCOUNT WHERE ID=@DiscountID AND CompanyID=@CompanyID AND Available=1";

                int count = db.SetCommand(strSqlCheck
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@DiscountID", discountID, DbType.Int32)).ExecuteScalar<int>();

                return count>0;
            }
        }

        public GetDiscountDetail_Model getDiscountDetailForManager(int companyID, int discountID)
        {
            using (DbManager db = new DbManager())
            {
                GetDiscountDetail_Model model = new GetDiscountDetail_Model();
                string strSql = @"SELECT ID AS DiscountID,DiscountName,CreateTime,Available
                                            FROM    TBL_DISCOUNT WITH(NOLOCK)
                                            WHERE CompanyID=@CompanyID AND ID=@ID ";
                model = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@ID", discountID, DbType.Int32)).ExecuteObject<GetDiscountDetail_Model>();

                return model;
            }
        }

        public List<GetLevelInfo_Model> getLevelListByDiscountID(int companyID, int discountID)
        {
            using (DbManager db = new DbManager())
            {
                List<GetLevelInfo_Model> list = new List<GetLevelInfo_Model>();
                string strSql = "";
                if (discountID > 0)
                {
                    strSql = @"SELECT  T1.ID AS LevelID,T1.LevelName,T2.Discount,T2.DiscountID,ISNULL(T2.Available,0) AS IsExist 
                                    FROM    [LEVEL] T1
                                            LEFT JOIN [TBL_CARD_DISCOUNT] T2 ON T1.ID = T2.CardID AND T2.DiscountID = @DiscountID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.Available = 1";
                }
                else
                {
                    strSql = @"SELECT  T1.ID AS LevelID ,T1.LevelName ,1 AS Discount,0 AS IsExist
                                FROM    [LEVEL] T1
                                WHERE   T1.CompanyID = @CompanyID AND T1.Available = 1";
                }

                list = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@DiscountID", discountID, DbType.Int32)).ExecuteList<GetLevelInfo_Model>();

                return list;
            }
        }

        public bool addDiscount(AddDiscount_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSql = @"INSERT INTO dbo.TBL_DISCOUNT (CompanyID ,DiscountName ,Available ,CreatorID ,CreateTime) 
                                    VALUES(@CompanyID ,@DiscountName ,@Available ,@CreatorID ,@CreateTime);select @@IDENTITY";

                int discountID = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@DiscountName", model.DiscountName, DbType.String)
                        , db.Parameter("@Available", true, DbType.Boolean)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteScalar<int>();

                if (discountID <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                if (model.List != null && model.List.Count > 0)
                {
                    foreach (GetLevelInfo_Model item in model.List)
                    {
                        string strAddLevelDiscountSql = @"INSERT INTO TBL_CARD_DISCOUNT (CardID ,DiscountID ,Discount ,Available ,CreatorID ,CreateTime) 
                                                        VALUES(@CardID ,@DiscountID ,@Discount ,@Available ,@CreatorID ,@CreateTime)";

                        int addRes = db.SetCommand(strAddLevelDiscountSql
                                , db.Parameter("@CardID", item.LevelID, DbType.Int32)
                                , db.Parameter("@DiscountID", discountID, DbType.Int32)
                                , db.Parameter("@Discount", item.Discount, DbType.Decimal)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

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

        public bool editDiscount(AddDiscount_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                if (!string.IsNullOrEmpty(model.DiscountName) || model.DiscountName != "")
                {
                    string strSqlDiscountHistory = "INSERT INTO [TBL_HISTORY_DISCOUNT] SELECT * FROM [TBL_DISCOUNT] WHERE ID =@ID";
                    int rows = db.SetCommand(strSqlDiscountHistory, db.Parameter("@ID", model.DiscountID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                    string strSqlUpdateDiscount = @"update [TBL_DISCOUNT] set 
                                                    DiscountName=@DiscountName,
                                                    UpdaterID=@UpdaterID,
                                                    UpdateTime=@UpdateTime
                                                    where ID=@ID ";
                    rows = db.SetCommand(strSqlUpdateDiscount
                        , db.Parameter("@DiscountName", model.DiscountName, DbType.String)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@ID", model.DiscountID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

//                foreach (GetLevelInfo_Model item in model.List)
//                {
//                    string strSqlRelationCheck = "SELECT isnull(Count(*),0) FROM [TBL_LEVEL_DISCOUNT_RELATIONSHIP]  WHERE DiscountID =@DiscountID and LevelID =@LevelID";

//                    int obj = db.SetCommand(strSqlRelationCheck
//                    , db.Parameter("@DiscountID", model.DiscountID, DbType.Int32)
//                    , db.Parameter("@LevelID", item.LevelID, DbType.Int32)).ExecuteScalar<int>();

//                    if (obj <= 0)
//                    {
//                        string strSqlAddRelationShip = @" INSERT INTO [TBL_LEVEL_DISCOUNT_RELATIONSHIP]
//                                                (LevelID,DiscountID,Discount,CreatorID,CreateTime,Available)
//                                                VALUES
//                                                (@LevelID,@DiscountID,@Discount,@CreatorID,@CreateTime,@Available)";
//                        int addrows = db.SetCommand(strSqlAddRelationShip
//                            , db.Parameter("@LevelID", item.LevelID, DbType.Int32)
//                            , db.Parameter("@DiscountID", model.DiscountID, DbType.Int32)
//                            , db.Parameter("@Discount", item.Discount, DbType.Decimal)
//                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
//                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
//                            , db.Parameter("@Available", 1, DbType.Boolean)).ExecuteNonQuery();

//                        if (addrows <= 0)
//                        {
//                            db.RollbackTransaction();
//                            return false;
//                        }
//                    }
//                    else
//                    {

//                        string strSqlRelationHistory = "INSERT INTO [TBL_HISTORY_LEVEL_DISCOUNT_RELATIONSHIP]  SELECT * FROM [TBL_LEVEL_DISCOUNT_RELATIONSHIP]  WHERE DiscountID =@DiscountID and LevelID =@LevelID";
//                        int addrows = db.SetCommand(strSqlRelationHistory
//                                        , db.Parameter("@DiscountID", model.DiscountID, DbType.Int32)
//                                        , db.Parameter("@LevelID", item.LevelID, DbType.Int32)).ExecuteNonQuery();
//                        if (addrows <= 0)
//                        {
//                            db.RollbackTransaction();
//                            return false;
//                        }
//                        string strSqlUpdateLevelDiscount = @"update [TBL_LEVEL_DISCOUNT_RELATIONSHIP] set 
//                                                    Discount=@Discount,
//                                                    Available=@Available,
//                                                    UpdaterID=@UpdaterID,
//                                                    UpdateTime=@UpdateTime
//                                                    where DiscountID=@DiscountID and LevelID =@LevelID ";
//                        int rows = db.SetCommand(strSqlUpdateLevelDiscount
//                            , db.Parameter("@Discount", item.Discount, DbType.Decimal)
//                            , db.Parameter("@Available", 1, DbType.Boolean)
//                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
//                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
//                            , db.Parameter("@DiscountID", model.DiscountID, DbType.Int32)
//                            , db.Parameter("@LevelID", item.LevelID, DbType.Int32)).ExecuteNonQuery();

//                        if (rows <= 0)
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

        public GetLevelDetail_Model getLevelDetailForManager(int companyID, int levelID)
        {
            using (DbManager db = new DbManager())
            {
                GetLevelDetail_Model model = new GetLevelDetail_Model();
                string strSql = @"SELECT ID AS LevelID ,LevelName ,CreateTime ,Available, Threshold
                                   FROM    [LEVEL] WITH ( NOLOCK )
                                   WHERE CompanyID=@CompanyID AND ID=@ID";

                model = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@ID", levelID, DbType.Int32)).ExecuteObject<GetLevelDetail_Model>();

                return model;
            }
        }

        public List<GetDiscountInfo_Model> getDiscountListByLevelID(int companyID, int levelID)
        {
            using (DbManager db = new DbManager())
            {
                List<GetDiscountInfo_Model> list = new List<GetDiscountInfo_Model>();
                string strSql = "";
                if (levelID > 0)
                {
                    strSql = @"SELECT  T1.ID AS DiscountID ,T1.DiscountName ,T2.Discount,T2.LevelID,ISNULL(T2.Available,0) AS IsExist   
                                FROM    [TBL_DISCOUNT] T1
                                        LEFT JOIN [TBL_CARD_DISCOUNT] T2 ON T1.ID = T2.DiscountID AND T2.CardID = @CardID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.Available = 1";
                }
                else
                {
                    strSql = @"SELECT  T1.ID AS DiscountID ,T1.DiscountName ,1 AS Discount,0 AS IsExist
                                FROM    [TBL_DISCOUNT] T1
                                WHERE   T1.CompanyID = @CompanyID AND T1.Available = 1";
                }

                list = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@CardID", levelID, DbType.Int32)).ExecuteList<GetDiscountInfo_Model>();

                return list;
            }
        }

        public bool addLevel(AddLevel_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSql = @"INSERT INTO dbo.LEVEL( CompanyID ,LevelName  ,Available ,CreatorID ,CreateTime ,Threshold) 
                                    VALUES(@CompanyID ,@LevelName ,@Available ,@CreatorID ,@CreateTime ,@Threshold);select @@IDENTITY";

                int levelID = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@LevelName", model.LevelName, DbType.String)
                        , db.Parameter("@Available", true, DbType.Boolean)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                        , db.Parameter("@Threshold", model.Threshold, DbType.Decimal)).ExecuteScalar<int>();

                if (levelID <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                if (model.List != null && model.List.Count > 0)
                {
                    foreach (GetDiscountInfo_Model item in model.List)
                    {
                        string strAddLevelDiscountSql = @"INSERT INTO TBL_CARD_DISCOUNT (CardID ,DiscountID ,Discount ,Available ,CreatorID ,CreateTime) 
                                                        VALUES(@CardID ,@DiscountID ,@Discount ,@Available ,@CreatorID ,@CreateTime)";

                        int addRes = db.SetCommand(strAddLevelDiscountSql
                                , db.Parameter("@CardID", levelID, DbType.Int32)
                                , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                                , db.Parameter("@Discount", item.Discount, DbType.Decimal)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

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

        public bool editDiscount(AddLevel_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                if (!string.IsNullOrEmpty(model.LevelName) || model.LevelName != "" || model.Threshold >= 0)
                {
                    string strSqlDiscountHistory = "INSERT INTO [HISTORY_LEVEL] SELECT * FROM [LEVEL] WHERE ID =@ID";
                    int rows = db.SetCommand(strSqlDiscountHistory, db.Parameter("@ID", model.LevelID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    if (model.Threshold < 0)
                    {
                        model.Threshold = 1;
                    }

                    string strSqlUpdateDiscount = @"update [LEVEL] set ";
                    if (!string.IsNullOrEmpty(model.LevelName) || model.LevelName != "")
                    {
                        strSqlUpdateDiscount += "LevelName=@LevelName,";
                    }

                    if (model.Threshold >= 0)
                    {
                        strSqlUpdateDiscount += "Threshold=@Threshold,";
                    }
                    strSqlUpdateDiscount += @" UpdaterID=@UpdaterID,
                                               UpdateTime=@UpdateTime
                                               where ID=@ID ";
                    rows = db.SetCommand(strSqlUpdateDiscount
                        , db.Parameter("@LevelName", model.LevelName, DbType.String)
                        , db.Parameter("@Threshold", model.Threshold, DbType.Decimal)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@ID", model.LevelID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                foreach (GetDiscountInfo_Model item in model.List)
                {
                    string strSqlRelationCheck = "SELECT isnull(Count(*),0) FROM [TBL_CARD_DISCOUNT]  WHERE DiscountID =@DiscountID and CardID =@CardID";

                    int obj = db.SetCommand(strSqlRelationCheck
                    , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                    , db.Parameter("@CardID", model.LevelID, DbType.Int32)).ExecuteScalar<int>();

                    if (obj <= 0)
                    {
                        string strSqlAddRelationShip = @" INSERT INTO [TBL_CARD_DISCOUNT]
                                                (CardID,DiscountID,Discount,CreatorID,CreateTime,Available)
                                                VALUES
                                                (@CardID,@DiscountID,@Discount,@CreatorID,@CreateTime,@Available)";
                        int addrows = db.SetCommand(strSqlAddRelationShip
                            , db.Parameter("@CardID", model.LevelID, DbType.Int32)
                            , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                            , db.Parameter("@Discount", item.Discount, DbType.Decimal)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                            , db.Parameter("@Available", 1, DbType.Boolean)).ExecuteNonQuery();

                        if (addrows <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }
                    else
                    {

                        string strSqlRelationHistory = "INSERT INTO [HST_CARD_DISCOUNT]  SELECT * FROM [TBL_CARD_DISCOUNT]  WHERE DiscountID =@DiscountID and CardID =@CardID";
                        int addrows = db.SetCommand(strSqlRelationHistory
                                        , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                                        , db.Parameter("@CardID", model.LevelID, DbType.Int32)).ExecuteNonQuery();
                        if (addrows <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                        string strSqlUpdateLevelDiscount = @"update [TBL_CARD_DISCOUNT] set 
                                                    Discount=@Discount,
                                                    Available=@Available,
                                                    UpdaterID=@UpdaterID,
                                                    UpdateTime=@UpdateTime
                                                    where DiscountID=@DiscountID and CardID =@CardID ";
                        int rows = db.SetCommand(strSqlUpdateLevelDiscount
                            , db.Parameter("@Discount", item.Discount, DbType.Decimal)
                            , db.Parameter("@Available", 1, DbType.Boolean)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                            , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                            , db.Parameter("@CardID", model.LevelID, DbType.Int32)).ExecuteNonQuery();

                        if (rows <= 0)
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

        public bool deleteLevel(AddLevel_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlLevelHistory = @"insert into HISTORY_LEVEL select * from LEVEL where ID =@ID";
                int rows = db.SetCommand(strSqlLevelHistory, db.Parameter("@ID", model.LevelID, DbType.Int32)).ExecuteNonQuery();
                if (rows <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }
                string strSqlUpdateLevel = @"update LEVEL set
                                                    Available=@Available,
                                                    UpdaterID=@UpdaterID,
                                                    UpdateTime=@UpdateTime
                                                    where ID=@ID ";
                rows = db.SetCommand(strSqlUpdateLevel
                    , db.Parameter("@Available", model.Available, DbType.String)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@ID", model.LevelID, DbType.Int32)).ExecuteNonQuery();

                if (rows <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }


                db.CommitTransaction();
                return true;
            }
        }

        public bool updateDefaultLevelID(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlHistoryUser = " INSERT INTO [HISTORY_COMPANY] SELECT * FROM [COMPANY] WHERE ID = @CompanyID And Available = 1";
                int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @"UPDATE Company SET DefaultCardID = @DefaultCardID,
                                      UpdaterID = @UpdaterID,
                                      UpdateTime =@UpdateTime 
                                      WHERE ID = @CompanyID AND Available = 1";
                int rows = 0;
                if (model.ID > 0)
                {
                    rows = db.SetCommand(strSql,
                      db.Parameter("@DefaultCardID", model.ID, DbType.String),
                      db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                      db.Parameter("@UpdateTime", model.Time, DbType.DateTime2),
                      db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                }
                else
                {
                    rows = db.SetCommand(strSql,
                        db.Parameter("@DefaultCardID", DBNull.Value),
                        db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                        db.Parameter("@UpdateTime", model.Time, DbType.DateTime2),
                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                }


                if (rows == 1)
                {
                    db.CommitTransaction();
                    return true;
                }
                else
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }

        public int getDiscountIDByName(int companyId, string discountName)
        {
            using (DbManager db = new DbManager())
            {

                string strSqlCommand = @"SELECT  ID
                                         FROM    dbo.TBL_DISCOUNT
                                         WHERE   DiscountName = @DiscountName
                                         AND Available = 1
                                         AND CompanyID = @CompanyID";


                int res = 0;

                res = db.SetCommand(strSqlCommand, db.Parameter("@DiscountName", discountName, DbType.String)
                                                 , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();
                return res;
            }
        }
    }
}
