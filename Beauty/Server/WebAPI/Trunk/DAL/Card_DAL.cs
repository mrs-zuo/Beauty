using BLToolkit.Data;
using HS.Framework.Common;
using Model.Operation_Model;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Card_DAL
    {
        #region 构造类实例
        public static Card_DAL Instance
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
            internal static readonly Card_DAL instance = new Card_DAL();
        }
        #endregion


        public List<Card_Model> getCardList(int companyId)
        {

            using (DbManager db = new DbManager())
            {
                string strSqlCard = @" SELECT  T1.ID ,
                                                T1.CardName ,
                                                T1.Rate ,
                                                T1.CardTypeID ,
                                                T1.CardCode ,
                                                CASE WHEN T2.DefaultCardCode IS NOT NULL THEN 1
                                                     ELSE 0
                                                END IsDefault
                                        FROM    [MST_CARD] T1
                                                LEFT JOIN [COMPANY] T2 ON T1.CardCode = T2.DefaultCardCode
                                                                          AND T1.CompanyID = T2.ID
                                        WHERE   T1.CompanyID = @CompanyID AND T1.Available = 1
                                        ORDER BY T1.CardTypeID ,
                                                CardCode ";

                List<Card_Model> list = new List<Card_Model>();
                list = db.SetCommand(strSqlCard, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<Card_Model>();

                string strSqlDiscount = @" SELECT T4.CardID, T1.ID DiscountID, T1.DiscountName,ISNULL(T4.Discount ,1) Discount
                                        FROM [TBL_DISCOUNT] T1
                                        INNER JOIN
										(SELECT T3.DiscountID,T2.ID AS CardID,T3.Discount  FROM 
										 [MST_CARD] T2 
                                        LEFT JOIN [TBL_CARD_DISCOUNT] T3 
                                        ON T2.ID = T3.CardID  AND T3.Available = 1 WHERE T2.CompanyID=@CompanyID) T4 ON T1.ID = T4.DiscountID
                                        where T1.CompanyID =@CompanyID AND T1.Available = 1   ";


                List<CardDiscount_Model> listDiscount = new List<CardDiscount_Model>();
                listDiscount = db.SetCommand(strSqlDiscount, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<CardDiscount_Model>();

                foreach (Card_Model item in list)
                {
                    List<CardDiscount_Model> temp = listDiscount.Where(c => c.CardID == item.ID).ToList<CardDiscount_Model>();
                    if (temp.Count > 0)
                    {
                        item.listDiscount = new List<CardDiscount_Model>();
                        item.listDiscount = temp;
                    }
                }

                return list;

            }
        }


        public bool deleteCard(Card_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlHistory = @" INSERT INTO HST_CARD SELECT * FROM MST_CARD WHERE ID =@ID and CompanyID=@CompanyID ";


                    int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@ID", model.ID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlDelete = @" update [MST_CARD] set Available = 0 ,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID =@ID AND CompanyID=@CompanyID ";

                    rows = db.SetCommand(strSqlDelete
                       , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                       , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                       , db.Parameter("@ID", model.ID, DbType.Int32)
                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    db.CommitTransaction();
                    return true;

                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public Card_Model getCardDetail(long cardCode,int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCard = " select  ID,CardCode,CardName,CardTypeID,CardProductType,CardDescription,VaildPeriod,ValidPeriodUnit,StartAmount,BalanceNotice,Rate,PresentRate,CardBranchType,CardProductType,ProfitRate from [MST_CARD] WITH (NOLOCK) where CompanyID=@CompanyID AND CardCode = @CardCode and Available = 1 ";
                Card_Model model = new Card_Model();
                model = db.SetCommand(strSqlCard, db.Parameter("@CardCode", cardCode, DbType.String)
                                                , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteObject<Card_Model>();


                if (cardCode > 0)
                {
                    if (model == null)
                    {
                        model = new Card_Model();
                        model.ID = 0;
                    }
                    string strSqlDiscount = " SELECT T2.CardID,T1.ID DiscountID,ISNULL(T2.Discount,1) Discount,T1.DiscountName from [TBL_DISCOUNT] T1 LEFT JOIN [TBL_CARD_DISCOUNT] T2 ON T1.ID = T2.DiscountID AND T2.Available = 1 AND T2.CardID =@CardID WHERE T1.Available = 1 AND T1.CompanyID = @COMPANYID  ";

                    model.listDiscount = new List<CardDiscount_Model>();
                    model.listDiscount = db.SetCommand(strSqlDiscount, db.Parameter("@CardID", model.ID, DbType.Int32), db.Parameter("@COMPANYID", companyId, DbType.Int32)).ExecuteList<CardDiscount_Model>();

                    string strSqlBranch = " select T1.ID BranchID,T1.BranchName,T2.CardID from [BRANCH] T1 left join [MST_CARD_BRANCH] T2 ON T1.ID = T2.BranchID AND T2.CardID =@CardID where T1.CompanyID =@COMPANYID and T1.Available = 1 ";

                    model.listBranch = new List<CardBranch_Model>();
                    model.listBranch = db.SetCommand(strSqlBranch, db.Parameter("@CardID", model.ID, DbType.Int32), db.Parameter("@COMPANYID", companyId, DbType.Int32)).ExecuteList<CardBranch_Model>();

                }
                else
                {
                    if (model == null)
                    {
                        model = new Card_Model();
                    }
                    string strSqlDiscount = " select ID DiscountID,DiscountName from [TBL_DISCOUNT] where Available = 1 and CompanyID =@COMPANYID  ";

                    model.listDiscount = new List<CardDiscount_Model>();
                    model.listDiscount = db.SetCommand(strSqlDiscount, db.Parameter("@CardID", model.ID, DbType.Int32), db.Parameter("@COMPANYID", companyId, DbType.Int32)).ExecuteList<CardDiscount_Model>();

                    string strSqlBranch = " select T1.ID BranchID,T1.BranchName from [BRANCH] T1  where T1.CompanyID =@COMPANYID and T1.Available = 1  ";

                    model.listBranch = new List<CardBranch_Model>();
                    model.listBranch = db.SetCommand(strSqlBranch, db.Parameter("@CardID", model.ID, DbType.Int32), db.Parameter("@COMPANYID", companyId, DbType.Int32)).ExecuteList<CardBranch_Model>();
                }

                return model;
            }
        }

        public int addCard(Card_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    long cardCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CardCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                    if (cardCode == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlCheck = " select count(0) from [MST_CARD] where CardName =@CardName and CompanyID =@CompanyID and Available = 1";

                    int check = db.SetCommand(strSqlCheck,db.Parameter("@CardName", model.CardName, DbType.String)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (check > 0) {
                        return -1;
                    }

                    model.CardCode = cardCode;
                    string strSqlAdd = @" INSERT INTO [MST_CARD] 
                                        (CompanyID,CardCode,CardTypeID,CardName,CardDescription,VaildPeriod,ValidPeriodUnit,StartAmount,BalanceNotice,Rate,CardBranchType,CardProductType,PresentRate,Available,CreatorID,CreateTime,ProfitRate) 
                                        VALUES 
                                        (@CompanyID,@CardCode,@CardTypeID,@CardName,@CardDescription,@VaildPeriod,@ValidPeriodUnit,@StartAmount,@BalanceNotice,@Rate,@CardBranchType,@CardProductType,@PresentRate,@Available,@CreatorID,@CreateTime,@ProfitRate );
                                        SELECT @@IDENTITY ";

                    int cardId = db.SetCommand(strSqlAdd
                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                       , db.Parameter("@CardCode", model.CardCode, DbType.Int64)
                       , db.Parameter("@CardTypeID", model.CardTypeID, DbType.Int32)
                       , db.Parameter("@CardName", model.CardName, DbType.String)
                       , db.Parameter("@CardDescription", model.CardDescription, DbType.String)
                       , db.Parameter("@VaildPeriod", model.ValidPeriodUnit == 4 ? (object)DBNull.Value: model.VaildPeriod, DbType.Int16)
                       , db.Parameter("@ValidPeriodUnit", model.ValidPeriodUnit, DbType.Int16)
                       , db.Parameter("@StartAmount", model.StartAmount, DbType.Decimal)
                       , db.Parameter("@BalanceNotice", model.BalanceNotice, DbType.Decimal)
                       , db.Parameter("@Rate", model.Rate, DbType.Decimal)
                       , db.Parameter("@CardBranchType", model.CardBranchType, DbType.Int16)
                       , db.Parameter("@CardProductType", model.CardProductType, DbType.Int16)
                       , db.Parameter("@PresentRate", model.PresentRate, DbType.Decimal)
                       , db.Parameter("@Available", model.Available, DbType.Boolean)
                       , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                       , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                       , db.Parameter("@ProfitRate", model.ProfitRate, DbType.Decimal)).ExecuteScalar<int>();

                    if (cardId == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }



                    if (model.listDiscount != null && model.listDiscount.Count > 0)
                    {
                        string strSqlDiscount = @" INSERT INTO [TBL_CARD_DISCOUNT]
                                                (CardID,DiscountID,Discount,Available,CreatorID,CreateTime)
                                                Values 
                                                (@CardID,@DiscountID,@Discount,@Available,@CreatorID,@CreateTime) ";
                        foreach (CardDiscount_Model item in model.listDiscount)
                        {
                            int rows = db.SetCommand(strSqlDiscount
                                       , db.Parameter("@CardID", cardId, DbType.Int32)
                                       , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                                       , db.Parameter("@Discount", item.Discount, DbType.Decimal)
                                       , db.Parameter("@Available", true, DbType.Boolean)
                                       , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                       , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                    }

                    if (model.listBranch != null && model.listBranch.Count > 0)
                    {
                        string strSqlBranch = @" Insert into [MST_CARD_BRANCH] 
                                                (CompanyID,CardID,BranchID,Type,CreatorID,CreateTime) 
                                                values  
                                                (@CompanyID,@CardID,@BranchID,@Type,@CreatorID,@CreateTime) ";
                        foreach (CardBranch_Model item in model.listBranch)
                        {
                            int rows = db.SetCommand(strSqlBranch
                                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                       , db.Parameter("@CardID", cardId, DbType.Int32)
                                       , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                                       , db.Parameter("@Type", 0, DbType.Int32)
                                       , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                       , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                    }


                    string strSqlDefaultCheck = @" select count(*) from [MST_CARD] where CompanyID=@CompanyID and Available = 1 and CardTypeID = 1 ";

                    int CardCnt = db.SetCommand(strSqlDefaultCheck, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (CardCnt == 0) {
                        string strSqlUpdate = " update COMPANY set DefaultCardCode =@DefaultCardCode where CompanyID=@CompanyID ";

                        int rows = db.SetCommand(strSqlUpdate
                                  , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                  , db.Parameter("@DefaultCardCode", model.CardCode, DbType.Int64)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }

                    db.CommitTransaction();
                    return 1;

                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public int updateCard(Card_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    if (model.CardTypeID == 1)
                    {
                        string strSqlCheckName = " select count(0) from [MST_CARD] where CardName =@CardName and CompanyID =@CompanyID and CardCode!=@CardCode and Available = 1 ";

                        int check = db.SetCommand(strSqlCheckName, db.Parameter("@CardName", model.CardName, DbType.String)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@CardCode", model.CardCode, DbType.String)).ExecuteScalar<int>();

                        if (check > 0)
                        {
                            return -2;
                        }

                        string strSqlCheck = @" select ID from [MST_CARD] with (nolock) where CardCode=@CardCode and Available = 1 ";

                        int cardId = db.SetCommand(strSqlCheck, db.Parameter("@CardCode", model.CardCode, DbType.String)).ExecuteScalar<int>();
                        if (cardId != model.ID)
                        {
                            return -1;
                        }



                        //string strSqlUsed = " select count(0) from [TBL_CUSTOMER_CARD] where CardID =@CardID  ";

                        //int cnt = db.SetCommand(strSqlUsed, db.Parameter("@CardID", model.ID, DbType.Int32)).ExecuteScalar<int>();
                        int cnt = 0;
                        if (cnt == 0)
                        {

                            string strSqlHistory = @" INSERT INTO HST_CARD SELECT * FROM MST_CARD WHERE ID =@ID and CompanyID=@CompanyID ";

                            int rows = db.SetCommand(strSqlHistory
                                , db.Parameter("@ID", model.ID, DbType.Int32)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strSqlUpdate = @" update [MST_CARD] set CardName=@CardName,
                                                        CardDescription=@CardDescription,
                                                        VaildPeriod=@VaildPeriod,
                                                        ValidPeriodUnit=@ValidPeriodUnit,
                                                        StartAmount=@StartAmount,
                                                        BalanceNotice=@BalanceNotice,
                                                        Rate=@Rate,
                                                        CardBranchType=@CardBranchType,
                                                        CardProductType=@CardProductType,
                                                        PresentRate=@PresentRate,
                                                        UpdaterID=@UpdaterID,
                                                        UpdateTime=@UpdateTime,
                                                        ProfitRate=@ProfitRate
                                                        where CompanyID=@CompanyID and ID=@ID ";

                            rows = db.SetCommand(strSqlUpdate
                              , db.Parameter("@CardName", model.CardName, DbType.String)
                              , db.Parameter("@CardDescription", model.CardDescription, DbType.String)
                              , db.Parameter("@VaildPeriod", model.ValidPeriodUnit == 4 ? (object)DBNull.Value : model.VaildPeriod, DbType.Int16)
                              , db.Parameter("@ValidPeriodUnit", model.ValidPeriodUnit, DbType.Int16)
                              , db.Parameter("@StartAmount", model.StartAmount, DbType.Decimal)
                              , db.Parameter("@BalanceNotice", model.BalanceNotice, DbType.Decimal)
                              , db.Parameter("@Rate", model.Rate, DbType.Decimal)
                              , db.Parameter("@CardBranchType", model.CardBranchType, DbType.Int16)
                              , db.Parameter("@CardProductType", model.CardProductType, DbType.Int16)
                              , db.Parameter("@PresentRate", model.PresentRate, DbType.Decimal)
                              , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                              , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                              , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                              , db.Parameter("@ProfitRate", model.ProfitRate, DbType.Decimal)
                              , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }


                            #region 折扣分类

                            string strSqlDiscountCount = " select count(0) from [TBL_CARD_DISCOUNT] where CardID =@CardID ";

                            int DiscountCnt = db.SetCommand(strSqlDiscountCount
                                    , db.Parameter("@CardID", model.ID, DbType.Int32)).ExecuteScalar<int>();

                            string strSqlDiscountHistory = @" INSERT INTO [HST_CARD_DISCOUNT] SELECT * FROM [TBL_CARD_DISCOUNT] where CardID =@CardID ";

                            rows = db.SetCommand(strSqlDiscountHistory
                                        , db.Parameter("@CardID", model.ID, DbType.Int32)).ExecuteNonQuery();

                            if (DiscountCnt != rows)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strSqlDiscountDelete = @" delete [TBL_CARD_DISCOUNT] where CardID =@CardID ";

                            rows = db.SetCommand(strSqlDiscountDelete
                                        , db.Parameter("@CardID", model.ID, DbType.Int32)).ExecuteNonQuery();

                            if (DiscountCnt != rows)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }


                            if (model.listDiscount != null && model.listDiscount.Count > 0)
                            {
                                string strSqlDiscount = @" INSERT INTO [TBL_CARD_DISCOUNT]
                                                (CardID,DiscountID,Discount,Available,CreatorID,CreateTime)
                                                Values 
                                                (@CardID,@DiscountID,@Discount,@Available,@CreatorID,@CreateTime) ";
                                foreach (CardDiscount_Model item in model.listDiscount)
                                {
                                    rows = db.SetCommand(strSqlDiscount
                                              , db.Parameter("@CardID", model.ID, DbType.Int32)
                                              , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                                              , db.Parameter("@Discount", item.Discount, DbType.Decimal)
                                              , db.Parameter("@Available", true, DbType.Boolean)
                                              , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                              , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                                    if (rows == 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                }
                            }


                            #endregion


                            #region 门店
                            string strSqlBranchCount = " select count(0) from [MST_CARD_BRANCH] where CardID =@CardID and CompanyID =@CompanyID ";

                            int branchCnt = db.SetCommand(strSqlBranchCount
                                    , db.Parameter("@CardID", model.ID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                            string strSqlBranchHistory = @" INSERT INTO [HST_CARD_BRANCH] SELECT * FROM MST_CARD_BRANCH where CardID =@CardID and CompanyID =@CompanyID ";

                            rows = db.SetCommand(strSqlBranchHistory
                                        , db.Parameter("@CardID", model.ID, DbType.Int32)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                            if (branchCnt != rows)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strSqlBranchDelete = @" delete [MST_CARD_BRANCH] where CardID =@CardID and CompanyID =@CompanyID ";

                            rows = db.SetCommand(strSqlBranchDelete
                                        , db.Parameter("@CardID", model.ID, DbType.Int32)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                            if (branchCnt != rows)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }


                            if (model.listBranch != null && model.listBranch.Count > 0)
                            {
                                string strSqlDiscount = @" Insert into [MST_CARD_BRANCH] 
                                                (CompanyID,CardID,BranchID,Type,CreatorID,CreateTime) 
                                                values  
                                                (@CompanyID,@CardID,@BranchID,@Type,@CreatorID,@CreateTime) ";
                                foreach (CardBranch_Model item in model.listBranch)
                                {
                                    rows = db.SetCommand(strSqlDiscount
                                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                               , db.Parameter("@CardID", cardId, DbType.Int32)
                                               , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                                               , db.Parameter("@Type", 0, DbType.Int32)
                                               , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                               , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                                    if (rows == 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                }
                            }
                            #endregion
                        }
                        else
                        {

                            string strSqlHistory = @" INSERT INTO HST_CARD SELECT * FROM MST_CARD WHERE ID =@ID and CompanyID=@CompanyID ";

                            int rows = db.SetCommand(strSqlHistory
                                , db.Parameter("@ID", model.ID, DbType.Int32)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strSqlDelete = @" update [MST_CARD] set Available = 0 ,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID =@ID AND CompanyID=@CompanyID ";

                            rows = db.SetCommand(strSqlDelete
                               , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                               , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                               , db.Parameter("@ID", model.ID, DbType.Int32)
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strSqlAdd = @" INSERT INTO [MST_CARD] 
                                        (CompanyID,CardCode,CardTypeID,CardName,CardDescription,VaildPeriod,ValidPeriodUnit,StartAmount,BalanceNotice,Rate,CardBranchType,CardProductType,PresentRate,Available,CreatorID,CreateTime,ProfitRate) 
                                        VALUES 
                                        (@CompanyID,@CardCode,@CardTypeID,@CardName,@CardDescription,@VaildPeriod,@ValidPeriodUnit,@StartAmount,@BalanceNotice,@Rate,@CardBranchType,@CardProductType,@PresentRate,@Available,@CreatorID,@CreateTime,@ProfitRate );
                                        SELECT @@IDENTITY ";

                            cardId = db.SetCommand(strSqlAdd
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@CardCode", model.CardCode, DbType.Int64)
                               , db.Parameter("@CardTypeID", model.CardTypeID, DbType.Int32)
                               , db.Parameter("@CardName", model.CardName, DbType.String)
                               , db.Parameter("@CardDescription", model.CardDescription, DbType.String)
                               , db.Parameter("@VaildPeriod", model.VaildPeriod, DbType.Int16)
                               , db.Parameter("@ValidPeriodUnit", model.ValidPeriodUnit, DbType.Int16)
                               , db.Parameter("@StartAmount", model.StartAmount, DbType.Decimal)
                               , db.Parameter("@BalanceNotice", model.BalanceNotice, DbType.Decimal)
                               , db.Parameter("@Rate", model.Rate, DbType.Decimal)
                               , db.Parameter("@CardBranchType", model.CardBranchType, DbType.Int16)
                               , db.Parameter("@CardProductType", model.CardProductType, DbType.Int16)
                               , db.Parameter("@PresentRate", model.PresentRate, DbType.Decimal)
                               , db.Parameter("@Available", true, DbType.Boolean)
                               , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                               , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                               , db.Parameter("@ProfitRate", model.ProfitRate, DbType.Decimal)).ExecuteScalar<int>();
                            if (cardId == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }


                            if (model.listDiscount != null && model.listDiscount.Count > 0)
                            {
                                string strSqlDiscount = @" INSERT INTO [TBL_CARD_DISCOUNT]
                                                (CardID,DiscountID,Discount,Available,CreatorID,CreateTime)
                                                Values 
                                                (@CardID,@DiscountID,@Discount,@Available,@CreatorID,@CreateTime) ";
                                foreach (CardDiscount_Model item in model.listDiscount)
                                {
                                    rows = db.SetCommand(strSqlDiscount
                                              , db.Parameter("@CardID", cardId, DbType.Int32)
                                              , db.Parameter("@DiscountID", item.DiscountID, DbType.Int32)
                                              , db.Parameter("@Discount", item.Discount, DbType.Decimal)
                                              , db.Parameter("@Available", true, DbType.Boolean)
                                              , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                              , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                                    if (rows == 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                }
                            }


                            if (model.listBranch != null && model.listBranch.Count > 0)
                            {
                                string strSqlDiscount = @" Insert into [MST_CARD_BRANCH] 
                                                (CompanyID,CardID,BranchID,Type,CreatorID,CreateTime) 
                                                values  
                                                (@CompanyID,@CardID,@BranchID,@Type,@CreatorID,@CreateTime) ";
                                foreach (CardBranch_Model item in model.listBranch)
                                {
                                    rows = db.SetCommand(strSqlDiscount
                                              , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                              , db.Parameter("@CardID", cardId, DbType.Int32)
                                              , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                                              , db.Parameter("@Type", 0, DbType.Int32)
                                              , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                              , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                                    if (rows == 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        string strSqlHistory = @" INSERT INTO HST_CARD SELECT * FROM MST_CARD WHERE ID =@ID and CompanyID=@CompanyID ";

                        int rows = db.SetCommand(strSqlHistory
                            , db.Parameter("@ID", model.ID, DbType.Int32)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strSqlUpdate = @" update [MST_CARD] set CardName=@CardName,
                                                        CardDescription=@CardDescription,
                                                        VaildPeriod=@VaildPeriod,
                                                        ValidPeriodUnit=@ValidPeriodUnit,
                                                        Rate=@Rate,
                                                        PresentRate=@PresentRate,
                                                        UpdaterID=@UpdaterID,
                                                        UpdateTime=@UpdateTime,
                                                        ProfitRate=@ProfitRate
                                                        where CompanyID=@CompanyID and ID=@ID ";

                        rows = db.SetCommand(strSqlUpdate
                          , db.Parameter("@CardName", model.CardName, DbType.String)
                          , db.Parameter("@CardDescription", model.CardDescription, DbType.String)
                          , db.Parameter("@VaildPeriod", model.ValidPeriodUnit == 4 ? (object)DBNull.Value : model.VaildPeriod, DbType.Int16)
                          , db.Parameter("@ValidPeriodUnit", model.ValidPeriodUnit, DbType.Int16)
                          , db.Parameter("@Rate", model.Rate, DbType.Decimal)
                          , db.Parameter("@PresentRate", model.PresentRate, DbType.Decimal)
                          , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                          , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                          , db.Parameter("@ProfitRate", model.ProfitRate, DbType.Decimal)
                          , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    
                    }

                    db.CommitTransaction();
                    return 1;


                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }



        public bool updateDefaultCardID(Card_Model model)
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

                string strSql = @"UPDATE Company SET DefaultCardCode = @DefaultCardCode,
                                      UpdaterID = @UpdaterID,
                                      UpdateTime =@UpdateTime 
                                      WHERE ID = @CompanyID AND Available = 1";
                int rows = 0;
                if (model.CardCode > 0)
                {
                    rows = db.SetCommand(strSql,
                      db.Parameter("@DefaultCardCode", model.CardCode, DbType.Int64),
                      db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                      db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                      db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                }
                else
                {
                    rows = db.SetCommand(strSql,
                        db.Parameter("@DefaultCardCode", DBNull.Value, DbType.Int64),
                        db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                        db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
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

    }
}
