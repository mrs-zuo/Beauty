using BLToolkit.Data;
using HS.Framework.Common.Util;
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

        // <summary>
        /// 获取促销图片
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="hight">图片高度</param>
        /// <param name="width">图片宽度</param>
        /// <param name="type">促销类型 0:所有展示 1:顶部展示 2:列表展示</param>
        /// <returns></returns>
        public List<PromotionList_Model> GetPromotionList(int companyID, int branchID, int width, int hight, int type)
        {
            List<PromotionList_Model> list = new List<PromotionList_Model>();
            using (DbManager db = new DbManager())
            {
                string strPromotionImg = " T1.PromotionCode ,T1.StartDate ,T1.EndDate ,T1.Type ,T1.Title ,T1.HasProduct,T1.Description ";

                string field = " SELECT TOP 5 {0} ";
                string strWhere = " WHERE   T1.Type = @Type AND CONVERT(varchar(20), GETDATE(), 120) <= T1.EndDate AND T1.CompanyID = @CompanyID AND T1.RecordType = 1 ";
                string strSql = "";
                if (type == 1)// 头部
                {
                    strPromotionImg += " ," + string.Format(WebAPI.Common.Const.getClientTopPromotionImg, hight, width);
                }
                else if (type == 2)// 底部
                {
                    strPromotionImg += " ," + string.Format(WebAPI.Common.Const.getClientTopPromotionImg, hight, width);
                }
                else // 所有
                {
                    strPromotionImg += " ," + string.Format(WebAPI.Common.Const.getClientTopPromotionImg, hight, width);

                    field = " SELECT {0} ";
                    strWhere = " WHERE CONVERT(varchar(20), GETDATE(), 120) < T1.EndDate AND T1.CompanyID = @CompanyID AND T1.RecordType = 1 ";
                }

                strSql = field + " FROM    [TBL_PROMOTION] T1 WITH ( NOLOCK )  ";
                if (branchID > 0)
                {
                    strSql += " LEFT JOIN [TBL_PROMOTION_BRANCH] T2 WITH ( NOLOCK ) ON T1.PromotionCode = T2.PromotionCode  ";
                }
                strSql += strWhere;
                if (branchID > 0)
                {
                    strSql += " AND T2.BranchID = @BranchID ";
                }
                strSql += " ORDER BY T1.StartDate ";

                string strListSql = string.Format(strSql, strPromotionImg);
                list = db.SetCommand(strListSql, db.Parameter("@Type", type, DbType.Int32), db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<PromotionList_Model>();
                return list;
            }
        }

        public PromotionDetail_Model GetPromotionDetail(int companyID, int width, int hight, string promotionCode)
        {
            PromotionDetail_Model model = new PromotionDetail_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  {0} ,PromotionCode ,StartDate ,EndDate ,Type ,Title ,Description , HasProduct
                                    FROM    [TBL_PROMOTION] T1 WITH ( NOLOCK )
                                    WHERE   CompanyID = @CompanyID
                                            AND T1.PromotionCode = @PromotionCode
                                            AND T1.RecordType = 1 ";

                string strPromotionImg = string.Format(WebAPI.Common.Const.getClientTopPromotionImg, hight, width);
                string strListSql = string.Format(strSql, strPromotionImg);
                model = db.SetCommand(strListSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@PromotionCode", promotionCode, DbType.String)).ExecuteObject<PromotionDetail_Model>();
                return model;
            }
        }

        public List<SimpleBranch_Model> GetPromotionBranchList(int companyID, string promotionCode)
        {
            using (DbManager db = new DbManager())
            {
                List<SimpleBranch_Model> list = new List<SimpleBranch_Model>();
                string strSql = @"SELECT  T1.BranchID ,
                                        T2.BranchName
                                FROM    [TBL_PROMOTION_BRANCH] T1 WITH ( NOLOCK )
                                        INNER JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.PromotionCode = @PromotionCode";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@PromotionCode", promotionCode, DbType.String)).ExecuteList<SimpleBranch_Model>();
                return list;
            }
        }

        public List<PromotionProductList_Model> GetPromotionProductList(int companyID, string promotionCode, int width, int hight)
        {
            using (DbManager db = new DbManager())
            {
                string strSelSql = @" SELECT  T1.ProductPromotionName ,
                                                CASE T1.ProductType WHEN 0 THEN T3.UnitPrice ELSE T2.UnitPrice END AS UnitPrice ,
                                                CASE T1.ProductType WHEN 0 THEN T3.Code ELSE T2.Code END AS ProductCode ,
                                                T1.ProductID ,
                                                T1.DiscountPrice ,
                                                T1.ProductType ,
                                                T1.SoldQuantity,
												T4.PRValue , 
                                                ISNULL(T4.PRValue, -1) AS PRValue 
                                        FROM    [TBL_PROMOTION_PRODUCT] T1 WITH ( NOLOCK )
												LEFT JOIN [TBL_PROMOTION_RULE] T4 WITH ( NOLOCK ) on T1.PromotionID = T4.PromotionID AND T1.ProductID = T4.ProductID AND T1.ProductType = T4.ProductType AND T4.PromotionType = 1 AND T4.PRCode = 1
                                                LEFT JOIN [COMMODITY] T2 WITH ( NOLOCK ) ON T1.ProductID = T2.ID
                                                LEFT JOIN [SERVICE] T3 WITH ( NOLOCK ) ON T1.ProductID = T3.ID 
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T1.PromotionID = @PromotionID ";

                List<PromotionProductList_Model> list = db.SetCommand(strSelSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@PromotionID", promotionCode, DbType.String)).ExecuteList<PromotionProductList_Model>();

                if (list != null && list.Count > 0)
                {
                    foreach (PromotionProductList_Model item in list)
                    {
                        string strSql = "";
                        if (item.ProductType == 0)
                        {
                            strSql = "SELECT ";
                            strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                           + WebAPI.Common.Const.strSingleMark
                           + "  + cast(" + companyID + " as nvarchar(10)) + "
                           + WebAPI.Common.Const.strSingleMark
                           + "/"
                           + WebAPI.Common.Const.strImageObjectType8
                           + WebAPI.Common.Const.strSingleMark
                           + "  + cast(" + item.ProductCode + " as nvarchar(16))+ '/' + T4.FileName + "
                           + WebAPI.Common.Const.strThumb
                           + " ThumbnailURL ";
                            strSql += " FROM IMAGE_SERVICE T4 WITH(NOLOCK) WHERE  T4.ServiceID=@ProductID AND T4.ImageType = 0";

                        }
                        else
                        {
                            strSql = "SELECT ";
                            strSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod
                            + WebAPI.Common.Const.strSingleMark
                            + "  + cast(" + companyID + " as nvarchar(10)) + "
                            + WebAPI.Common.Const.strSingleMark
                            + "/"
                            + WebAPI.Common.Const.strImageObjectType6
                            + WebAPI.Common.Const.strSingleMark
                            + "  + cast(" + item.ProductCode + " as nvarchar(16))+ '/' + T4.FileName + "
                            + WebAPI.Common.Const.strThumb
                            + " ThumbnailURL ";
                            strSql += " FROM IMAGE_COMMODITY T4 WITH(NOLOCK) WHERE  T4.CommodityID=@ProductID AND T4.ImageType = 0";
                        }

                        item.ThumbnailURL = db.SetCommand(strSql
                                          , db.Parameter("@ProductID", item.ProductID, DbType.Int32)
                                                              , db.Parameter("@ImageHeight", hight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", width.ToString(), DbType.String)).ExecuteScalar<string>();

                    }
                }

                return list;
            }
        }

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

        
    }
}
