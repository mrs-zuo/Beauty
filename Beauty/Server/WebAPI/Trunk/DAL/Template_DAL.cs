using BLToolkit.Data;
using HS.Framework.Common;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Template_DAL
    {
        #region 构造类实例
        public static Template_DAL Instance
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
            internal static readonly Template_DAL instance = new Template_DAL();
        }
        #endregion


        public bool addTemplate(Template_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" insert into TEMPLATE(
                                    CompanyID,BranchID,Subject,TemplateContent,Type,CreatorID,CreateTime)
                                     values (
                                    @CompanyID,@BranchID,@Subject,@TemplateContent,@Type,@CreatorID,@CreateTime)
                                    ;select @@IDENTITY ";

                int rows = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@Subject", model.Subject, DbType.String)
                    , db.Parameter("@TemplateContent", model.TemplateContent, DbType.String)
                    , db.Parameter("@Type", model.TemplateType, DbType.Int32)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.OperateTime, DbType.DateTime2)).ExecuteScalar<int>();
                if (rows > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }


        public bool updateTemplate(Template_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlHistory = @" Insert into HISTORY_TEMPLATE 
                                            select * From TEMPLATE WHERE ID =@ID ";

                    int rows = db.SetCommand(strSqlHistory, db.Parameter("@ID", model.TemplateID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSql = @"update TEMPLATE set 
                                       Subject=@Subject,
                                       TemplateContent=@TemplateContent,
                                       Type=@Type,
                                       UpdaterID=@UpdaterID,
                                       UpdateTime=@UpdateTime
                                       where ID=@ID";

                    rows = db.SetCommand(strSql, db.Parameter("@Subject", model.Subject, DbType.String)
                       , db.Parameter("@TemplateContent", model.TemplateContent, DbType.String)
                       , db.Parameter("@Type", model.TemplateType, DbType.Int32)
                       , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                       , db.Parameter("@UpdateTime", model.OperateTime, DbType.DateTime2)
                       , db.Parameter("@ID", model.TemplateID, DbType.Int32)).ExecuteNonQuery();

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
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }



        public bool deleteTemplate(int templateId)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlHistory = @" Insert into HISTORY_TEMPLATE 
                                            select * From TEMPLATE WHERE ID =@ID ";

                    int rows = db.SetCommand(strSqlHistory, db.Parameter("@ID", templateId, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSql = @" delete TEMPLATE where ID=@ID ";

                    rows = db.SetCommand(strSql, db.Parameter("@ID", templateId, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    db.CommitTransaction();
                    return true;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public List<Template_Model> getTemplatList(int accountId, int companyId)
        {
            using (DbManager db = new DbManager())
            {

                string strSql = @"  select T1.ID TemplateID,T1.Type TemplateType, T1.TemplateContent,T1.subject Subject,T5.Name CreatorName,T6.Name UpdaterName,CONVERT(varchar(19),ISNULL(T1.UpdateTime,T1.CreateTime),20) OperateTime 
                                    FROM TEMPLATE T1 
                                    LEFT JOIN ( 
                                    select T4.UserID, T4.NAME Name from ACCOUNT T4) T5  
                                    ON T1.CreatorID = T5.UserID 
                                    LEFT JOIN( 
                                    select T4.UserID, T4.NAME Name from ACCOUNT T4) T6   
                                    ON T1.UpdaterID = T6.UserID 
                                    where (T1.CreatorID =@AccountID and T1.Type = 1) 
                                    OR  (T1.CompanyID =@CompanyID and T1.Type = 0 )
                                    order by OperateTime desc ";

                List<Template_Model> list = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<Template_Model>();

                return list;
            }
        }
    }
}
