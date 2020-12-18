using BLToolkit.Data;
using HS.Framework.Common;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Cart_DAL
    {
        #region 构造类实例
        public static Cart_DAL Instance
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
            internal static readonly Cart_DAL instance = new Cart_DAL();
        }
        #endregion


        public int addCart(CartOperation_Model model)
        {
            if (model == null)
            {
                return 0;
            }
            using (DbManager db = new DbManager())
            {
                string strSqlHasCommodity = @"select top 1 ID from Cart where CommodityCode =@CommodityCode and CustomerID =@CustomerID AND BranchID=@BranchID AND Status =0 order by ID desc";
                int cartID = db.SetCommand(strSqlHasCommodity,
                                           db.Parameter("@CommodityCode", model.CommodityCode, DbType.Int64),
                                           db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                           db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();

                #region 查询库存
                string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                                                           db.Parameter("@ProductCode", model.CommodityCode, DbType.Int64),
                                                           db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                           db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<ProductStockOperation_Model>();
                #endregion

                if (stockModel == null)
                {
                    return 0;
                }

                // 不计库存与超卖库存不需要判断库存是否足够
                if (stockModel.StockCalcType == 1)
                {
                    #region 判断库存
                    if (stockModel.ProductQty <= 0 || stockModel.ProductQty < model.Quantity)
                    {
                        return 3;
                    }
                    #endregion
                }

                if (cartID > 0)
                {
                    string strSqlUpdateCart = @"update CART set Quantity =Quantity + @Quantity,
                                                    UpdaterID =@UpdaterID,
                                                    UpdateTime =@UpdateTime 
                                                    where ID =@CartID";
                    int res = db.SetCommand(strSqlUpdateCart,
                              db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                              db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                              db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                              db.Parameter("@CartID", cartID, DbType.Int32)).ExecuteNonQuery();
                    if (res <= 0)
                    {
                        return 0;
                    }
                }
                else//购物车中没有该商品,插入一条数据
                {
                    string strSqlInsertCart = @"insert into CART(CompanyID,CustomerID,CommodityCode,Quantity,Status,CreatorID,CreateTime,BranchID)
                                                    values (@CompanyID,@CustomerID,@CommodityCode,@Quantity,@Status,@CreatorID,@CreateTime,@BranchID)";
                    int res = db.SetCommand(strSqlInsertCart,
                              db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                              db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                              db.Parameter("@CommodityCode", model.CommodityCode, DbType.Int64),
                              db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                              db.Parameter("@Status", model.Status, DbType.Int32),
                              db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                              db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                              db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteNonQuery();
                    if (res <= 0)
                    {
                        return 0;
                    }
                }

                return 1;
            }
        }


        public int updateCart(CartOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSqlSelectCode = @"SELECT CommodityCode FROM  [CART] WHERE ID=@ID";
                    long code = db.SetCommand(strSqlSelectCode, db.Parameter("@ID", model.CartID, DbType.Int32)).ExecuteScalar<long>();

                    if (code <= 0)
                    {
                        return 0;
                    }

                    #region 查询库存
                    string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                    ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                                                               db.Parameter("@ProductCode", code, DbType.Int64),
                                                               db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                               db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<ProductStockOperation_Model>();
                    #endregion

                    if (stockModel == null)
                    {
                        return 0;
                    }

                    // 不计库存与超卖库存不需要判断库存是否足够
                    if (stockModel.StockCalcType == 1)
                    {
                        #region 判断库存
                        if (stockModel.ProductQty <= 0 || stockModel.ProductQty < model.Quantity)
                        {
                            return 3;
                        }
                        #endregion
                    }

                    db.BeginTransaction();

                    #region 插入历史表
                    string strSqlInsertHis = @"Insert Into HISTORY_CART select * from CART where ID=@ID";
                    int res = db.SetCommand(strSqlInsertHis, db.Parameter("@ID", model.CartID, DbType.Int32)).ExecuteNonQuery();
                    #endregion

                    if (res <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #region 修改购物车数据
                    string strSqlUpdateCart = @"update CART set Quantity = @Quantity,
                                                    UpdaterID =@UpdaterID,
                                                    UpdateTime =@UpdateTime 
                                                    where ID =@CartID";
                    int updateRes = db.SetCommand(strSqlUpdateCart,
                              db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                              db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                              db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                              db.Parameter("@CartID", model.CartID, DbType.Int32)).ExecuteNonQuery();
                    #endregion

                    if (updateRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    db.CommitTransaction();
                    return 1;
                }
                catch(Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public bool deleteCart(List<CartIDList_Model> cartId, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlDel = @"update CART set 
                                            Status=@Status,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where ID=@ID ";
                    DateTime dt = DateTime.Now.ToLocalTime();
                    foreach (CartIDList_Model item in cartId)
                    {
                        string strSqlCopy = Common.SqlCommon.copySqlSpell("CART", "ID", item.CartID);
                        int rows = db.SetCommand(strSqlCopy).ExecuteNonQuery();
                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        rows = db.SetCommand(strSqlDel, db.Parameter("@Status", 2, DbType.Int32)
                            , db.Parameter("@UpdaterID", customerId, DbType.Int32)
                            , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                            , db.Parameter("@ID", item.CartID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
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

        public List<GetCartList_Model> getCartList(int customerId, int companyId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                int levelId = 0;
                if (customerId > 0)
                {
                    string strSqlLevelId = @" select  T1.LevelID from [CUSTOMER] T1 with (nolock)
                                          INNER JOIN [Level] T2 with (nolock) ON T1.LevelID=T2.ID
                                          where T1.UserID =@UserID and T1.Available = 1   ";

                    levelId = db.SetCommand(strSqlLevelId, db.Parameter("@UserID", customerId, DbType.Int32)).ExecuteScalar<int>();
                }

                string strSql = @" select DISTINCT T1.ID CartID,T1.CommodityCode,T1.Quantity,T4.CommodityName,T4.CommodityID,T4.MarketingPolicy ,T4.UnitPrice, CASE WHEN T4.MarketingPolicy = 2 THEN CASE WHEN @CardID = 0 THEN T4.UnitPrice ELSE T4.PromotionPrice END WHEN T4.MarketingPolicy = 1 THEN T4.UnitPrice * ISNULL(T8.Discount,1) END PromotionPrice, case  when T4.Available =1 and T6.Available = 1 and T7.Available = 1 then 1 else 0 end Available,T9.BranchName,T9.ID AS BranchID ,"
                                + Common.Const.strHttp + Common.Const.server + Common.Const.strMothod +  Common.Const.strSingleMark
                                + "  + cast(T10.CompanyID as nvarchar(10)) + " + Common.Const.strSingleMark + "/" + Common.Const.strImageObjectType6
                                + Common.Const.strSingleMark + "  + cast(T10.CommodityCode as nvarchar(16))+ '/' + T10.FileName + "
                                + Common.Const.strThumb
                                + @" ImageURL from CART T1  
                                    LEFT JOIN  ( 
                                    select T2.ID CommodityID,T2.CommodityName,T2.Code,T2.MarketingPolicy,T2.UnitPrice,T2.PromotionPrice,T2.Available,T2.DiscountID 
                                    from COMMODITY T2 
                                    WHERE T2.ID IN ( 
                                    select max(T3.id) 
                                    from COMMODITY T3 
                                    group by T3.Code)) T4 
                                    ON T1.CommodityCode = T4.Code 
                                    LEFT JOIN
                                    (  SELECT ID ,CompanyID ,BranchID ,Code ,Available
                                    FROM   dbo.TBL_MARKET_RELATIONSHIP
                                    WHERE  ID IN ( SELECT  MAX(T1.ID)
                                    FROM    TBL_MARKET_RELATIONSHIP T1 LEFT JOIN [CART] T2 ON T1.BranchID = T2.BranchID 
                                    WHERE   T1.Type = 1 AND T2.CustomerID = @CustomerID
                                    GROUP BY T1.Code,T1.BranchID)) T6 ON T4.Code = T6.Code AND T1.BranchID = T6.BranchID 
                                    LEFT JOIN (
                                    SELECT T1.BranchID,ProductCode Code ,CASE WHEN StockCalcType = 1 AND ProductQty <= 0 THEN 0 ELSE 1 END Available
                                    FROM dbo.TBL_PRODUCT_STOCK T1
                                    INNER JOIN dbo.CART T2 
                                    ON T1.BranchID = t2.BranchID AND T2.CommodityCode = T1.ProductCode AND T2.Status = 0
                                    WHERE   ProductType = 1
                                    AND T2.CustomerID = @CustomerID ) T7 ON T4.Code = T7.Code AND T7.BranchID = T1.BranchID 
                                    LEFT JOIN  (select CardID,DiscountID,Discount from [TBL_CARD_DISCOUNT] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.CardID=@CardID AND T4.DiscountID = T8.DiscountID 
                                    LEFT JOIN [BRANCH] T9 WITH(NOLOCK) ON T9.ID=T1.BranchID 
                                    LEFT JOIN [IMAGE_COMMODITY] T10 ON T4.CommodityID = T10.CommodityID AND T10.ImageType = 0
                                    where T1.CustomerID=@CustomerID and T1.Status = 0 ";

                List<GetCartList_Model> list = new List<GetCartList_Model>();
                list = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@CardID", levelId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<GetCartList_Model>();

                return list;
            }
        }

        public int getCartCount(int customerId)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlDel = @"select Count(*) 
                                         from CART T1  
                                         where T1.CustomerID=@CustomerID and T1.Status = 0 ";


                int cnt = db.SetCommand(strSqlDel, db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();
                return cnt;
            }
        }
    }
}
