using BLToolkit.Data;
using HS.Framework.Common.Util;
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
                string strSqlHasCommodity = @" SELECT TOP 1
                                                        CartID
                                                FROM    [TBL_CART]
                                                WHERE   ProductCode = @ProductCode
                                                        AND ProductType = @ProductType
                                                        AND CompanyID = @CompanyID
                                                        AND CustomerID = @CustomerID
                                                        AND BranchID = @BranchID
                                                        AND Status = 1 ";
                string cartID = db.SetCommand(strSqlHasCommodity
                                           , db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                                           , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                           , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<string>();

                if (model.ProductType == 1)
                {
                    #region 查询库存
                    string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                    ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                                                               db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
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
                }

                if (!string.IsNullOrWhiteSpace(cartID))
                {
                    string strSqlUpdateCart = @"update TBL_CART set Quantity =Quantity + @Quantity,
                                                    UpdaterID =@UpdaterID,
                                                    UpdateTime =@UpdateTime 
                                                    where CartID =@CartID";
                    int res = db.SetCommand(strSqlUpdateCart,
                              db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                              db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                              db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                              db.Parameter("@CartID", cartID, DbType.String)).ExecuteNonQuery();
                    if (res <= 0)
                    {
                        return 0;
                    }
                }
                else//购物车中没有该商品,插入一条数据
                {
                    cartID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "CartID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                    string strSqlInsertCart = @"INSERT INTO TBL_CART( CompanyID ,BranchID ,CartID ,CustomerID ,ProductType ,ProductCode ,Quantity ,Status ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BranchID ,@CartID ,@CustomerID ,@ProductType ,@ProductCode ,@Quantity ,@Status ,@CreatorID ,@CreateTime )";
                    int res = db.SetCommand(strSqlInsertCart
                              , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                              , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                              , db.Parameter("@CartID", cartID, DbType.String)
                              , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                              , db.Parameter("@ProductType", model.ProductType, DbType.Int32)
                              , db.Parameter("@ProductCode", model.ProductCode, DbType.Int64)
                              , db.Parameter("@Quantity", model.Quantity, DbType.Int32)
                              , db.Parameter("@Status", model.Status, DbType.Int32)
                              , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                              , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

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
                    string strSqlSelectCode = @"SELECT ProductCode ,ProductType ,BranchID FROM  [TBL_CART] WHERE CartID=@CartID";

                    DataTable dt = db.SetCommand(strSqlSelectCode, db.Parameter("@CartID", model.CartID, DbType.String)).ExecuteDataTable();

                    if (dt == null || dt.Rows.Count != 1)
                    {
                        return 0;
                    }

                    long code = StringUtils.GetDbLong(dt.Rows[0]["ProductCode"]);
                    int productType = StringUtils.GetDbInt(dt.Rows[0]["ProductType"]);
                    int branchID = StringUtils.GetDbInt(dt.Rows[0]["BranchID"]);

                    if (code <= 0)
                    {
                        return 0;
                    }

                    if (productType == 1)
                    {
                        #region 查询库存
                        string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                        ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                                                                   db.Parameter("@ProductCode", code, DbType.Int64),
                                                                   db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                                   db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteObject<ProductStockOperation_Model>();
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
                    }


                    db.BeginTransaction();

                    #region 修改购物车数据
                    string strSqlUpdateCart = @"update TBL_CART set Quantity = @Quantity,
                                                    UpdaterID =@UpdaterID,
                                                    UpdateTime =@UpdateTime 
                                                    where CartID =@CartID";
                    int updateRes = db.SetCommand(strSqlUpdateCart,
                              db.Parameter("@Quantity", model.Quantity, DbType.Int32),
                              db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                              db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                              db.Parameter("@CartID", model.CartID, DbType.String)).ExecuteNonQuery();
                    #endregion

                    if (updateRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    db.CommitTransaction();
                    return 1;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public bool deleteCart(CartOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlDel = @"update TBL_CART set 
                                            Status=@Status,
                                            RecordType=@RecordType ,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where CartID=@CartID 
                                            AND CustomerID=@CustomerID 
                                            AND CompanyID=@CompanyID ";
                DateTime dt = DateTime.Now.ToLocalTime();
                foreach (string item in model.CartIDList)
                {
                    int rows = db.SetCommand(strSqlDel
                        , db.Parameter("@Status", 3, DbType.Int32)
                        , db.Parameter("@RecordType", 2, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.CustomerID, DbType.Int32)
                        , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                        , db.Parameter("@CartID", item, DbType.String)
                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                db.CommitTransaction();
                return true;
            }
        }

        public List<GetCartList_Model> getCartList(int customerId, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSelBranchSql = @" SELECT DISTINCT
                                                    T1.BranchID ,
                                                    T2.BranchName ,
                                                    T3.CreateTime
                                            FROM    [TBL_CART] T1 WITH ( NOLOCK )
                                                    INNER JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID AND T2.Available = 1 
                                                    INNER JOIN [TBL_CART] T3 WITH ( NOLOCK ) ON T3.CartID = ( SELECT MAX(T4.CartID) FROM [TBL_CART] T4 WHERE T4.BranchID = T1.BranchID )
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerID = @CustomerID 
                                                    AND T1.Status = 1 
                                            ORDER BY T3.CreateTime DESC ";

                List<GetCartList_Model> list = db.SetCommand(strSelBranchSql
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<GetCartList_Model>();

                if (list == null || list.Count <= 0)
                {
                    return null;
                }

                return list;
            }
        }

        public List<CartDetail_Model> getCartDetailByBranchID(int companyID, int customerId, int branchID, int productType, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                string strCommoditySql = @" SELECT  T1.CartID ,
                                                        T1.BranchID ,
                                                        T1.ProductCode ,
                                                        T1.ProductType ,
                                                        T1.Quantity ,
                                                        T2.CommodityName AS ProductName ,
                                                        T1.CreateTime ,
                                                        T2.UnitPrice, 
                                                        T2.Available ,";
                strCommoditySql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod + WebAPI.Common.Const.strSingleMark
                                                + "  + cast(T4.CompanyID as nvarchar(10)) + " + WebAPI.Common.Const.strSingleMark + "/" + WebAPI.Common.Const.strImageObjectType6
                                                + WebAPI.Common.Const.strSingleMark + "  + cast(T4.CommodityCode as nvarchar(16))+ '/' + T4.FileName + "
                                                + WebAPI.Common.Const.strThumb + " ImageURL ";
                strCommoditySql += @" FROM    [TBL_CART] T1 WITH ( NOLOCK )
                                                        INNER JOIN [COMMODITY] T2 WITH ( NOLOCK ) ON T1.ProductCode = T2.Code
                                                                                                     AND T2.ID = ( SELECT
                                                                                                              MAX(ID)
                                                                                                              FROM
                                                                                                              [COMMODITY] T3
                                                                                                              WHERE
                                                                                                              T3.Code = T2.Code
                                                                                                              )
                                                        LEFT JOIN [IMAGE_COMMODITY] T4 WITH ( NOLOCK ) ON T2.ID = T4.CommodityID
                                                                                                          AND T4.ImageType = 0
                                                        INNER JOIN [TBL_MARKET_RELATIONSHIP] T5 ON T5.Code = T1.ProductCode
                                                                                                   AND T5.Available = 1
                                                                                                   AND T5.Type = 1
                                                                                                   AND T5.BranchID = @BranchID
                                                WHERE   T1.CompanyID = @CompanyID
                                                        AND T1.BranchID = @BranchID
                                                        AND T1.CustomerID = @CustomerID
                                                        AND T1.ProductType = 1 
                                                        AND T1.Status = 1 ";


                string strServiceSql = @" SELECT  T1.CartID ,
                                                        T1.BranchID ,
                                                        T1.ProductCode ,
                                                        T1.ProductType ,
                                                        T1.Quantity ,
                                                        T2.ServiceName AS ProductName ,
                                                        T1.CreateTime ,
                                                        T2.UnitPrice, 
                                                        T2.Available, ";
                strServiceSql += WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod + WebAPI.Common.Const.strSingleMark
                                                + "  + cast(T4.CompanyID as nvarchar(10)) + " + WebAPI.Common.Const.strSingleMark + "/" + WebAPI.Common.Const.strImageObjectType8
                                                + WebAPI.Common.Const.strSingleMark + "  + cast(T4.ServiceCode as nvarchar(16))+ '/' + T4.FileName + "
                                                + WebAPI.Common.Const.strThumb + " ImageURL ";
                strServiceSql += @" FROM    [TBL_CART] T1 WITH ( NOLOCK )
                                                        INNER JOIN [SERVICE] T2 WITH ( NOLOCK ) ON T1.ProductCode = T2.Code
                                                                                                     AND T2.ID = ( SELECT
                                                                                                              MAX(ID)
                                                                                                              FROM
                                                                                                              [SERVICE] T3
                                                                                                              WHERE
                                                                                                              T3.Code = T2.Code
                                                                                                              )
                                                        LEFT JOIN [IMAGE_SERVICE] T4 WITH ( NOLOCK ) ON T2.ID = T4.ServiceID
                                                                                                          AND T4.ImageType = 0
                                                        INNER JOIN [TBL_MARKET_RELATIONSHIP] T5 ON T5.Code = T1.ProductCode
                                                                                                   AND T5.Available = 1
                                                                                                   AND T5.Type = 0
                                                                                                   AND T5.BranchID = @BranchID
                                                WHERE   T1.CompanyID = @CompanyID
                                                        AND T1.BranchID = @BranchID
                                                        AND T1.CustomerID = @CustomerID
                                                        AND T1.ProductType = 0 
                                                        AND T1.Status = 1 ";

                if (productType == 1)
                {
                    strSql = strCommoditySql;
                }
                else if (productType == 0)
                {
                    strSql = strServiceSql;
                }
                else
                {
                    strSql = strCommoditySql + " UNION ALL " + strServiceSql;
                }

                List<CartDetail_Model> list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<CartDetail_Model>();

                return list;
            }
        }

        public int getCartCount(int companyID, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlDel = @" SELECT  COUNT(0)
                                        FROM    TBL_CART AS T1
                                        WHERE   T1.CustomerID = @CustomerID
                                                AND T1.CompanyID = @CompanyID
                                                AND T1.Status = 1 ";


                int cnt = db.SetCommand(strSqlDel
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();
                return cnt;
            }
        }
    }
}
