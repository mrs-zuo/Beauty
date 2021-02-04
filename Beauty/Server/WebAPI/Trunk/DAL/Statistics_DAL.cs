using BLToolkit.Data;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HS.Framework.Common.Util;

namespace WebAPI.DAL
{
    public class Statistics_DAL
    {
        #region 构造类实例
        public static Statistics_DAL Instance
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
            internal static readonly Statistics_DAL instance = new Statistics_DAL();
        }
        #endregion

        public ObjectResultSup<List<StatisticsSurplus_Model>> getConsumeStatisticsSurplus(StatisticsOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                ObjectResultSup<List<StatisticsSurplus_Model>> res = new ObjectResultSup<List<StatisticsSurplus_Model>>();

                StringBuilder strSql = new StringBuilder();
                switch (model.ObjectType)
                {
                    case 0:
                        // 服务
                        strSql.Append("select a.OrderID,a.ServiceName as ProductName");
                        // 订单编号
                        strSql.Append(",SUBSTRING(CONVERT(varchar(6) ,d.OrderTime ,12),3,4) + right('000000'+ cast(d.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,d.OrderTime ,12) as OrderNumber");
                        strSql.Append(",case a.TGTotalCount");
                        // 未完成次数
                        strSql.Append("   when 0 then");
                        strSql.Append("      case when a.Expirationtime < getdate() then 0");
                        strSql.Append("      else DATEDIFF(dd, getdate(), a.Expirationtime)");
                        strSql.Append("      end");
                        strSql.Append("   else a.TGTotalCount - a.TGFinishedCount");
                        strSql.Append(" end as ProductSurPlusNum");
                        // 服务方式(时间卡|服务次数)
                        strSql.Append(",case a.TGTotalCount when 0 then 1 else 2 end as ProductServiceType");
                        // 剩余金额
                        strSql.Append(",case a.TGTotalCount");
                        strSql.Append("   when 0 then");
                        strSql.Append("      case when a.Expirationtime < getdate() or DATEDIFF(dd, d.OrderTime, a.Expirationtime) = 0 then 0");
                        strSql.Append("      else isnull(c.SumPaid, 0) * DATEDIFF(dd, getdate(), a.Expirationtime) / DATEDIFF(dd, d.OrderTime, a.Expirationtime)");
                        strSql.Append("      end");
                        strSql.Append("   else isnull(c.SumPaid, 0) * (a.TGTotalCount - a.TGFinishedCount) / a.TGTotalCount");
                        strSql.Append(" end as ProductSurplusPrice");

                        strSql.Append(" from TBL_ORDER_SERVICE a");

                        strSql.Append(" left join TBL_ORDERPAYMENT_RELATIONSHIP b on b.OrderID = a.OrderID");

                        strSql.Append(" left join");
                        strSql.Append(" (");
                        strSql.Append(" select s1.ID as PaymentID,sum(s2.PaymentAmount * case s1.type when 2 then -1 else 1 end) as SumPaid");
                        strSql.Append(" from PAYMENT s1");
                        strSql.Append(" inner join PAYMENT_DETAIL s2 on s2.PaymentID = s1.ID");
                        strSql.Append(" inner join TBL_ORDERPAYMENT_RELATIONSHIP s3 on s3.PaymentID = s1.ID");
                        strSql.Append(" inner join TBL_ORDER_SERVICE s4 on s4.OrderID = s3.OrderID and s4.CustomerID = @CustomerID");
                        strSql.Append(" where s1.Status <> 1");
                        strSql.Append(" group by s1.ID");
                        strSql.Append(" ) c on c.PaymentID = b.PaymentID");

                        strSql.Append(" inner join [order] d on d.ID = a.OrderID");

                        strSql.Append(" where a.CustomerID = @CustomerID");
                        strSql.Append(" and a.Status = 1");
                        strSql.Append(" and d.RecordType = 1");
                        strSql.Append(" and d.Status = 1");

                        res.Data = db.SetCommand(strSql.ToString(), db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<StatisticsSurplus_Model>();
                        break;
                    case 1:
                        // 商品
                        strSql.Append("select a.OrderID,a.CommodityName as ProductName,a.Quantity - a.DeliveredAmount as ProductSurPlusNum");
                        // 订单编号
                        strSql.Append(",SUBSTRING(CONVERT(varchar(6) ,d.OrderTime ,12),3,4) + right('000000'+ cast(d.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,d.OrderTime ,12) as OrderNumber");
                        // 剩余金额
                        strSql.Append(",isnull(c.SumPaid, 0) * (a.Quantity - a.DeliveredAmount) / a.Quantity as ProductSurplusPrice");
                        strSql.Append(" from TBL_ORDER_COMMODITY a");
                        strSql.Append(" left join TBL_ORDERPAYMENT_RELATIONSHIP b on b.OrderID = a.OrderID");
                        strSql.Append(" left join");
                        strSql.Append(" (");
                        strSql.Append("select s1.ID as PaymentID,sum(s2.PaymentAmount * case s1.type when 2 then -1 else 1 end) as SumPaid");
                        strSql.Append(" from PAYMENT s1");
                        strSql.Append(" inner join PAYMENT_DETAIL s2 on s2.PaymentID = s1.ID");
                        strSql.Append(" inner join TBL_ORDERPAYMENT_RELATIONSHIP s3 on s3.PaymentID = s1.ID");
                        strSql.Append(" inner join TBL_ORDER_COMMODITY s4 on s4.OrderID = s3.OrderID and s4.CustomerID = @CustomerID");
                        strSql.Append(" where s1.Status <> 1");
                        strSql.Append(" group by s1.ID");
                        strSql.Append(" ) c on c.PaymentID = b.PaymentID");
                        strSql.Append(" inner join [order] d on d.ID = a.OrderID");
                        strSql.Append(" where a.CustomerID = @CustomerID");
                        strSql.Append(" and a.Status = 1");
                        strSql.Append(" and d.RecordType = 1");
                        strSql.Append("and d.Status = 1");

                        res.Data = db.SetCommand(strSql.ToString(), db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<StatisticsSurplus_Model>();
                        break;
                }
                return res;
            }
        }


        public List<Statistics_Model> getConsumeStatisticsByObejctName(StatisticsOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                if (model.ObjectType == 0)
                {
                    strSql = @"  SELECT COUNT(0) ObjectCount, T2.ServiceName ObjectName FROM [TBL_TREATGROUP] T1 
                                        INNER JOIN [TBL_ORDER_SERVICE] T2 
                                        ON T1.OrderID = T2.OrderID AND T2.TGTotalCount > 0 
                                        INNER JOIN [ORDER] T3 
                                        ON T1.OrderID = T3.ID AND T3.RecordType = 1
                                        LEFT JOIN [BRANCH] T4 
                                        ON T3.BranchID = T4.ID
                                        WHERE T1.CompanyID =@CompanyID AND T1.BranchID = @BranchID AND T1.TGStatus <> 3 AND T3.OrderTime > T4.StartTime and T2.CustomerID =@CustomerID
                                        GROUP BY T2.ServiceName ORDER BY ObjectCount DESC ";
                }
                else
                {
                    strSql = @" SELECT SUM(T2.Quantity) ObjectCount, T2.CommodityName ObjectName FROM  [TBL_ORDER_COMMODITY] T2 
                                INNER JOIN [ORDER] T3 
                                ON T2.OrderID = T3.ID AND T3.RecordType = 1
                                LEFT JOIN [BRANCH] T4 
                                ON T3.BranchID = T4.ID
                                WHERE T2.CompanyID =@CompanyID AND T2.BranchID = @BranchID AND T2.Status <> 3 AND T3.OrderTime > T4.StartTime and T2.CustomerID =@CustomerID
                                
                                GROUP BY T2.CommodityName ORDER BY ObjectCount DESC ";
                }

                List<Statistics_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<Statistics_Model>();

                return list;
            }
        }

        public List<Statistics_Model> getConsumeStatisticsByPrice(StatisticsOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                if (model.ObjectType == 0)
                {
                    strSql = @"  SELECT SUM(T1.Quantity) ObjectCount, T4.UnitPrice SumOrigPrice FROM [TBL_ORDER_SERVICE] T1
                                        INNER JOIN [ORDER] T2 
                                        ON T1.OrderID = T2.ID AND T2.RecordType = 1
										LEFT JOIN [SERVICE] T4 ON T1.ServiceID = T4.ID 
                                        LEFT JOIN [BRANCH] T3
                                        ON T1.BranchID = T3.ID
                                        WHERE T1.CompanyID =@CompanyID AND T1.BranchID = @BranchID AND T1.Status <> 3 AND T2.OrderTime > T3.StartTime and T1.CustomerID =@CustomerID
                                          GROUP BY T4.UnitPrice ORDER BY ObjectCount DESC ";
                }
                else
                {
                    strSql = @"    SELECT SUM(T1.Quantity) ObjectCount, T4.UnitPrice SumOrigPrice FROM [TBL_ORDER_COMMODITY] T1
                                        INNER JOIN [ORDER] T2 
                                        ON T1.OrderID = T2.ID AND T2.RecordType = 1
										LEFT JOIN [COMMODITY] T4 ON T1.CommodityID = T4.ID 
                                        LEFT JOIN [BRANCH] T3
                                        ON T1.BranchID = T3.ID
                                        WHERE T1.CompanyID =@CompanyID AND T1.BranchID = @BranchID AND T1.Status <> 3 AND T2.OrderTime > T3.StartTime and T1.CustomerID =@CustomerID
                                        GROUP BY  T4.UnitPrice ORDER BY ObjectCount DESC ";
                }

                List<Statistics_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<Statistics_Model>();




                if (list != null && list.Count > 0)
                {
                    string strSqlgetRange = @" select PriceRangeValue from [TBL_A_PRICERANGE] where CompanyID =@CompanyID and BranchID =@BranchID ";
                    string priceRange = db.SetCommand(strSqlgetRange, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<string>();

                    if (priceRange == "" || priceRange == null)
                    {
                        priceRange = "|0|100|500|1000|3000|5000|";
                    }
                    List<string> listRange = priceRange.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries).ToList<string>();


                    List<Statistics_Model> listRes = new List<Statistics_Model>();
                    for (int i = 0; i < listRange.Count; i++)
                    {
                        if (i == listRange.Count - 1)
                        {

                            Statistics_Model temp = new Statistics_Model();
                            temp.ObjectCount = list.Where(c => c.SumOrigPrice >= StringUtils.GetDbDecimal(listRange[i])).ToList<Statistics_Model>().Sum(d => d.ObjectCount);
                            temp.ObjectName = listRange[i].ToString() + " 以上 ";
                            listRes.Add(temp);
                        }
                        else
                        {
                            Statistics_Model temp = new Statistics_Model();
                            temp.ObjectCount = list.Where(c => c.SumOrigPrice >= StringUtils.GetDbDecimal(listRange[i]) && c.SumOrigPrice < StringUtils.GetDbDecimal(listRange[i + 1])).ToList<Statistics_Model>().Sum(d => d.ObjectCount);
                            temp.ObjectName = listRange[i].ToString() + " - " + listRange[i + 1].ToString();
                            listRes.Add(temp);
                        }
                    }

                    return listRes;
                }
                else
                {
                    return null;
                }
            }
        }



        public List<Statistics_Model> getConsumeStatisticsByMonth(StatisticsOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlConsumeCount = @" SELECT COUNT(0) ObjectCount,CONVERT(varchar(7),T1.TGStartTime, 111) ObjectName FROM [TBL_TREATGROUP] T1 
                                        INNER JOIN [TBL_ORDER_SERVICE] T2 
                                        ON T1.OrderID = T2.OrderID AND T2.TGTotalCount > 0 and T2.CustomerID =@CustomerID
                                        INNER JOIN [ORDER] T3 
                                        ON T1.OrderID = T3.ID AND T3.RecordType = 1
                                        LEFT JOIN [BRANCH] T4 
                                        ON T3.BranchID = T4.ID
                                        WHERE T1.CompanyID =@CompanyID AND T1.BranchID = @BranchID AND T1.TGStatus <> 3 AND T3.OrderTime > T4.StartTime 
                                        GROUP BY CONVERT(varchar(7),T1.TGStartTime, 111) ORDER BY ObjectName DESC ";


                List<Statistics_Model> listConsumeCount = db.SetCommand(strSqlConsumeCount, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<Statistics_Model>();


                string strSqlConsumePrice = @" 
                                       SELECT SUM(T6.ConsumeAmout) ConsumeAmout,T6.ObjectName FROM (
                                SELECT SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount ELSE T1.PaymentAmount * -1 END) ConsumeAmout, CONVERT(varchar(7),T2.PaymentTime, 111) ObjectName FROM [PAYMENT_DETAIL] T1
                                        INNER JOIN [PAYMENT] T2 ON T1.PaymentID = T2.ID AND T2.OrderNumber = 1
                                        INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 ON T1.PaymentID = T3.PaymentID
                                        INNER JOIN [ORDER] T4 ON T3.OrderID = T4.ID AND T4.RecordType = 1  and T4.CustomerID =@CustomerID
                                        LEFT JOIN [BRANCH] T5
                                        ON T2.BranchID = T5.ID
                                        WHERE T1.CompanyID =@CompanyID AND T2.BranchID = @BranchID AND (T1.PaymentMode = 0 or T1.PaymentMode = 2 OR T1.PaymentMode = 8  OR T1.PaymentMode = 9  OR T1.PaymentMode = 100  OR T1.PaymentMode = 101) AND T2.PaymentTime > T5.StartTime
                                        GROUP BY CONVERT(varchar(7),T2.PaymentTime, 111) 
										UNION ALL 
										SELECT SUM(CASE T2.Type WHEN 1 THEN T4.TotalSalePrice ELSE T4.TotalSalePrice * -1 END) ConsumeAmout, CONVERT(varchar(7),T2.PaymentTime, 111) ObjectName FROM [PAYMENT_DETAIL] T1
                                        INNER JOIN [PAYMENT] T2 ON T1.PaymentID = T2.ID AND T2.OrderNumber > 1
                                        INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 ON T1.PaymentID = T3.PaymentID
                                        INNER JOIN [ORDER] T4 ON T3.OrderID = T4.ID AND T4.RecordType = 1  and T4.CustomerID =@CustomerID
                                        LEFT JOIN [BRANCH] T5
                                        ON T2.BranchID = T5.ID
                                        WHERE T1.CompanyID =@CompanyID AND T2.BranchID = @BranchID AND (T1.PaymentMode = 0 or T1.PaymentMode = 2 OR T1.PaymentMode = 8 OR T1.PaymentMode = 9  OR T1.PaymentMode = 100  OR T1.PaymentMode = 101) AND T2.PaymentTime > T5.StartTime
                                        GROUP BY CONVERT(varchar(7),T2.PaymentTime, 111) ) T6 GROUP BY T6.ObjectName ORDER BY T6.ObjectName DESC  ";


                List<Statistics_Model> listConsumePrice = db.SetCommand(strSqlConsumePrice, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<Statistics_Model>();

                string strSqlRecharge = @" SELECT SUM(T2.Amount) RechargeAmout, CONVERT(varchar(7),T1.CreateTime, 111) ObjectName FROM [TBL_CUSTOMER_BALANCE] T1
                                        INNER JOIN [TBL_MONEY_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID
                                        LEFT JOIN [BRANCH] T3
                                        ON T1.BranchID = T3.ID
                                        WHERE T1.CompanyID =@CompanyID AND T1.BranchID = @BranchID AND ((T2.ActionMode = 3 AND  (T2.DepositMode = 1 OR T2.DepositMode = 2 OR T2.DepositMode = 4)) OR (T2.ActionMode = 4 AND  (T2.DepositMode = 1 OR T2.DepositMode = 2 OR T2.DepositMode = 4))) AND T1.UserID =@CustomerID
                                        GROUP BY CONVERT(varchar(7),T1.CreateTime, 111) ORDER BY ObjectName DESC ";

                List<Statistics_Model> listRecharge = db.SetCommand(strSqlRecharge, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                       , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                       , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<Statistics_Model>();

                List<Statistics_Model> list = new List<Statistics_Model>();
                DateTime dt = StringUtils.GetDbDateTime(model.EndTime);
                for (int i = 0; i > 0 - model.MonthCount; i--)
                {
                    Statistics_Model mSt = new Statistics_Model();
                    string strDate = dt.AddMonths(i).ToString("yyyy/MM");
                    mSt.Datesort = strDate;
                    mSt.ObjectName = dt.AddMonths(i).Month + "月";
                    if (listConsumeCount != null)
                    {
                        List<Statistics_Model> temp = listConsumeCount.Where(c => c.ObjectName == strDate).ToList<Statistics_Model>();
                        if (temp != null && temp.Count > 0)
                        {
                            mSt.ObjectCount = temp[0].ObjectCount;
                        }
                    }
                    if (listConsumePrice != null)
                    {
                        List<Statistics_Model> temp = listConsumePrice.Where(c => c.ObjectName == strDate).ToList<Statistics_Model>();
                        if (temp != null && temp.Count > 0)
                        {
                            mSt.ConsumeAmout += temp[0].ConsumeAmout;
                        }
                    }
                    if (listRecharge != null)
                    {
                        List<Statistics_Model> temp = listRecharge.Where(c => c.ObjectName == strDate).ToList<Statistics_Model>();
                        if (temp != null && temp.Count > 0)
                        {
                            mSt.RechargeAmout += temp[0].RechargeAmout;
                        }
                    }
                    mSt.TotalAmout = mSt.ConsumeAmout + mSt.RechargeAmout;
                    list.Add(mSt);
                }

                if (model.ExtractItemType == 3)
                {
                    list = list.OrderBy(x => x.Datesort).ToList<Statistics_Model>();
                }
                else if (model.ExtractItemType == 4)
                {
                    list = list.OrderByDescending(x => x.Datesort).ToList<Statistics_Model>();
                }

                return list;
            }
        }



        #region 门店

        public List<Statistics_Model> getBranchBusinessStatistics(StatisticsOperation_Model model, string endTime)
        {
            using (DbManager db = new DbManager())
            {
                List<Statistics_Model> list = new List<Statistics_Model>();
                    //营业统计柱状图及详情统计

                    string strSql = "";
                    DbType type = DbType.String;
                    switch (model.TimeChooseFlag)
                    {
                        //按日（7天）
                        case 0:
                            strSql = @"getBranchBusinessStatisticsDay";
                            break;
                        //按周（6周）
                        case 1:
                            strSql = @"getBranchBusinessStatisticsWeek";
                            type = DbType.DateTime;
                            break;
                        //按月（6月）
                        case 2:
                            strSql = @"getBranchBusinessStatisticsMonth";
                            break;
                        //按季（6季）
                        case 3:
                            strSql = @"getBranchBusinessStatisticsSeason";
                            break;
                        //按年（6年）
                        case 4:
                            strSql = @"getBranchBusinessStatisticsYear";
                            break;
                        default:
                            break;
                    }
                    list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@EndTime", endTime, type)).ExecuteList<Statistics_Model>();

                    if (model.ObjectType != 1)
                    {
                        list = list.OrderBy(x => x.Datesort).ToList<Statistics_Model>();
                    }
                    return list;
            }
        }

        public List<Statistics_Model> getBranchBusinessStatisticsTMCount(StatisticsOperation_Model model, string startTime, string endTime)
        {
            using (DbManager db = new DbManager())
            {
                //员工业绩占比图表（操作）
                string strSql = @"getBranchBusinessStatisticsTMCount";
                List<Statistics_Model> list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@StartTime", startTime, DbType.String)
                    , db.Parameter("@EndTime", endTime, DbType.String)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteList<Statistics_Model>();

                return list;
            }
        }

        public List<Statistics_Model> getBranchBusinessStatisticsTMCountMonth(StatisticsOperation_Model model, string startTime, string endTime)
        {
            using (DbManager db = new DbManager())
            {
                //员工业绩排行榜的数据（操作/个人）
                string strSql = @"getBranchBusinessStatisticsTMCountMonth";
                List<Statistics_Model> list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@StartTime", startTime, DbType.String)
                    , db.Parameter("@EndTime", endTime, DbType.String)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteList<Statistics_Model>();
                return list;
            }
        }

        public List<Statistics_Model> getBranchBusinessStatisticsConsume(StatisticsOperation_Model model, string startTime, string endTime)
        {

            using (DbManager db = new DbManager())
            {
                //员工业绩占比图表（销售）
                string strSql = @"getBranchBusinessStatisticsConsume";
                List<Statistics_Model> list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@StartTime", startTime, DbType.String)
                    , db.Parameter("@EndTime", endTime, DbType.String)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteList<Statistics_Model>();


                return list;
            }
        }

        public List<Statistics_Model> getBranchBusinessStatisticsConsumeMonth(StatisticsOperation_Model model, string startTime, string endTime)
        {
            using (DbManager db = new DbManager())
            {
                //员工业绩占比图表（销售/个人）
                string strSql = @"getBranchBusinessStatisticsConsumeMonth";
                List<Statistics_Model> list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@StartTime", startTime, DbType.String)
                    , db.Parameter("@EndTime", endTime, DbType.String)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteList<Statistics_Model>();
                return list;
            }
        }

        public List<Statistics_Model> getBranchBusinessStatisticsRecharge(StatisticsOperation_Model model, string startTime, string endTime)
        {

            using (DbManager db = new DbManager())
            {
                //员工业绩占比图表（充值）
                string strSql = @"getBranchBusinessStatisticsRecharge";
                List<Statistics_Model> list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@StartTime", startTime, DbType.String)
                    , db.Parameter("@EndTime", endTime, DbType.String)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteList<Statistics_Model>();

                return list;
            }
        }

        public List<Statistics_Model> getBranchBusinessStatisticsRechargeMonth(StatisticsOperation_Model model, string startTime, string endTime)
        {
            using (DbManager db = new DbManager())
            {
                //员工业绩占比图表（充值/个人）
                string strSql = @"getBranchBusinessStatisticsRechargeMonth";
                List<Statistics_Model> list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@StartTime", startTime, DbType.String)
                    , db.Parameter("@EndTime", endTime, DbType.String)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteList<Statistics_Model>();
                return list;
            }
        }


        public List<Statistics_Model> getBranchBusinessStatisticsProduct(StatisticsOperation_Model model, string startTime, string endTime)
        {
            using (DbManager db = new DbManager())
            {
                //产品消费占比图标（服务/商品总览）
                string strSql = @"getBranchBusinessStatisticsProduct";
                List<Statistics_Model> list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@StartTime", startTime, DbType.String)
                    , db.Parameter("@EndTime", endTime, DbType.String)
                    , db.Parameter("@ObjectType", model.ObjectType, DbType.Int32)).ExecuteList<Statistics_Model>();

                return list;

            }
        }

        #endregion
    }
}
