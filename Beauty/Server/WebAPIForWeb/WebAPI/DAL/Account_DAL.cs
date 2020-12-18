using BLToolkit.Data;
using HS.Framework.Common;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace WebAPI.DAL
{
    public class Account_DAL
    {
        #region 构造类实例
        public static Account_DAL Instance
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
            internal static readonly Account_DAL instance = new Account_DAL();
        }
        #endregion

        /// <summary>
        /// 获取公司下面所有员工
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="width">头像宽</param>
        /// <param name="hight">头像高</param>
        /// <param name="pageIndex">当前页数</param>
        /// <param name="pageSize">分页大小</param>
        /// <param name="type">0:抽取全部 1:抽取首页标志</param>
        /// <param name="recordCount">共有多少条</param>
        /// <returns></returns>
        public List<GetAccountList_Model> getAccountList(int companyID,int width,int hight,int pageIndex,int pageSize,int type, out int recordCount)
        {
            recordCount = 0;
            List<GetAccountList_Model> list=new List<GetAccountList_Model> ();
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strHeadImg = string.Format(WebAPI.Common.Const.getUserHeadImg, hight, width);
                    string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.IsRecommend DESC, T1.UserID ) AS rowNum ,
                                                  T1.UserID AS AccountID,T1.Name AS AccountName,T1.Department,T1.Title,T1.Expert,T1.Introduction," + strHeadImg;

                    string strSql = " SELECT {0} FROM [ACCOUNT] T1 WITH(NOLOCK) WHERE CompanyID=@CompanyID  AND Available = 1 ";

                    if (type == 1)
                    {
                        strSql += " AND T1.IsRecommend = 1 ";
                    }

                    string strCountSql = string.Format(strSql, " count(0) ");

                    recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }
                    if (type == 0)
                    {
                        string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;
                        list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetAccountList_Model>();
                    }
                    else if (type == 1) {
                        string strgetListSql = string.Format(strSql, fileds);
                        list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetAccountList_Model>();
                    
                    }
                    return list;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }

        public GetAccountList_Model getAccountDetail(int companyID, int accountID, int hight, int width)
        {
            GetAccountList_Model model;
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strHeadImg = string.Format(WebAPI.Common.Const.getUserHeadImg, hight, width);
                    string fileds = @"Select T1.UserID AS AccountID,T1.Name AS AccountName,T1.Department,T1.Title,T1.Expert,T1.Introduction,ISNull(T1.UpdateTime,T1.CreateTime) UpdateTime," + strHeadImg;

                           fileds += @" from Account T1 
                                        where T1.UserID =@UserID and CompanyID =@CompanyID";
                           model = db.SetCommand(fileds, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                        , db.Parameter("@UserID", accountID, DbType.Int32)).ExecuteObject<GetAccountList_Model>();
                           return model;
                }
                catch (Exception ex)
                {
                    LogUtil.Log(ex);
                    return null;
                }
            }
        }
    }
}
