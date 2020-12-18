using BLToolkit.Data;
using HS.Framework.Common.Entity;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebManager.Controllers
{
    public class ynapmocddaController : Controller
    {
        //
        // GET: /ynapmocdda/

        public ActionResult ddaCom()
        {
            return View();
        }

        [Serializable]
        public class CompanyModel
        {
            public string CompanyName { set; get; }
            public string Abbreviation { set; get; }
            public string BossName { set; get; }
            public string MobilePhone { set; get; }
            public string SMSNum { set; get; }
        }



        public ActionResult addCompany(CompanyModel model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "操作失败";
            res.Code = "0";
            res.Data = false;
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlGetCount = @" select Count(0) from [COMPANY] where DATEDIFF([month], CreateTime , GETDATE()) = 0 and DATEDIFF([YEAR], CreateTime , GETDATE()) = 0 ";

                DateTime dt = DateTime.Now.ToLocalTime();
                int Cnt = db.SetCommand(strSqlGetCount).ExecuteScalar<int>();

                string CompanyCode = "CN" + dt.Year.ToString().Substring(2, 2) + dt.Month.ToString().PadLeft(2, '0') + (Cnt + 1).ToString().PadLeft(4, '0');


                string strSqlAddCompany = @" INSERT INTO [COMPANY] ([CompanyCode],[AccountNumber],[BranchNumber],[Name],[Abbreviation],[CompanyScale],[Contact],[Phone],[SettlementCurrency],[Visible],[Available],[CreatorID],[CreateTime],[Advanced],[BalanceRemind],[smsheading])
                                VALUES
                                (@CompanyCode,10,1,@CompanyName,@Abbreviation,0,@BossName,@MiblePhone,1,1,1,0,GETDATE(),NULL,0,@smsheading);
                                select @@IDENTITY ";

                int CompanyID = db.SetCommand(strSqlAddCompany
                    , db.Parameter("@CompanyCode", CompanyCode, DbType.String)
                    , db.Parameter("@CompanyName", model.CompanyName, DbType.String)
                    , db.Parameter("@Abbreviation", model.Abbreviation, DbType.String)
                    , db.Parameter("@BossName", model.BossName, DbType.String)
                    , db.Parameter("@MiblePhone", model.MobilePhone, DbType.String)
                    , db.Parameter("@smsheading", model.Abbreviation, DbType.String)).ExecuteScalar<int>();

                if (CompanyID == 0)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }
                //添加短信信息管理
                string strSqlAddSMSINFO = @"insert into [SMSINFO] ([CompanyID], [SMSNum], [SMSSent], [CreatorPGM], [CreatorID], [CreateTime], [UpdatePGM], [UpdaterID], [UpdateTime])
                             values(@CompanyID, @SMSNum, 0, 'addCompany', 0, getdate(), 'addCompany', 0, getdate())";

                int SMSINFONum = db.SetCommand(strSqlAddSMSINFO
                                , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                , db.Parameter("@SMSNum", model.SMSNum, DbType.Int32)).ExecuteNonQuery();
                if (SMSINFONum <= 0)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }

                string strSqlAddUser = @" INSERT INTO [USER]
                                           ([CompanyID],[UserType] ,[Password],[LoginMobile])
                                            VALUES
                                           (@newCompanyID,1,'dkAapgKvwDQ=',@MiblePhone); 
                                         select @@IDENTITY ";



                int UserID = db.SetCommand(strSqlAddUser
                    , db.Parameter("@newCompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@MiblePhone", model.MobilePhone, DbType.String)).ExecuteScalar<int>();

                if (UserID == 0)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }

                string strSqlAddAccount = @" INSERT INTO [ACCOUNT]
                                            ([CompanyID],[BranchID],[UserID],[RoleID],[Name],[Mobile],[Available],[CreatorID],[CreateTime],[IsRecommend])
                                                VALUES
                                            (@newCompanyID,0,@newUserID,-1,@BossName,@MiblePhone,1,0,GETDATE(),0) ";

                int rows = db.SetCommand(strSqlAddAccount
                    , db.Parameter("@newCompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@newUserID", UserID, DbType.Int32)
                    , db.Parameter("@BossName", model.BossName, DbType.String)
                    , db.Parameter("@MiblePhone", model.MobilePhone, DbType.String)).ExecuteNonQuery();

                if (rows != 1)
                {

                    db.RollbackTransaction();
                    return Json(res);
                }

                string strSqlAddRelation = @" INSERT INTO [TBL_ACCOUNTBRANCH_RELATIONSHIP]
                                            ([CompanyID],[BranchID],[UserID],[Available],[CreatorID],[CreateTime])
                                             VALUES
                                            (@newCompanyID,0,@newUserID,1,0,GETDATE()) ";

                rows = db.SetCommand(strSqlAddRelation
                    , db.Parameter("@newCompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@newUserID", UserID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }

                long CardCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CardCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                if (CardCode == 0)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }

                string strSqlAddCard = @" INSERT  INTO [MST_CARD]
                                     ( CompanyID ,CardCode ,CardTypeID ,CardName ,VaildPeriod ,ValidPeriodUnit ,StartAmount ,BalanceNotice ,Rate ,CardBranchType ,CardProductType ,Available ,CreatorID ,CreateTime ,PresentRate)
                                     VALUES  
                                     ( @newCompanyID ,@CardCode ,2 ,'积分' ,NULL ,4 ,0 ,0 ,1 ,2 ,2 ,1 ,0 ,GETDATE() ,0) ";

                rows = db.SetCommand(strSqlAddCard
                   , db.Parameter("@newCompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@CardCode", CardCode, DbType.Int64)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }



                long CardCode2 = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CardCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                if (CardCode2 == 0)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }

                string strSqlAddCard2 = @" INSERT  INTO [MST_CARD]
                                ( CompanyID ,CardCode ,CardTypeID ,CardName ,VaildPeriod ,ValidPeriodUnit ,StartAmount ,BalanceNotice ,Rate ,CardBranchType ,CardProductType ,Available ,CreatorID ,CreateTime ,PresentRate)          
                                VALUES  
                                ( @newCompanyID ,@CardCode ,3 ,'现金券' ,NULL ,4 ,0 ,0 ,1 ,2 ,2 ,1 ,0 ,GETDATE() ,0) ";

                rows = db.SetCommand(strSqlAddCard2
                   , db.Parameter("@newCompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@CardCode", CardCode2, DbType.Int64)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }

                string strSqlScountType = @" INSERT INTO [TBL_CUSTOMER_SOURCE_TYPE]
                                         ( CompanyID,Name,CreatorID,CreateTime,RecordType) 
                                         VALUES ( @newCompanyID,'本店' ,0 ,GETDATE() ,1) ";

                rows = db.SetCommand(strSqlScountType
                 , db.Parameter("@newCompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    db.RollbackTransaction();
                    return Json(res);
                }

                db.CommitTransaction();

            }
            res.Message = "操作成功";
            res.Code = "1";
            res.Data = true;
            return Json(res);
        }

    }
}
