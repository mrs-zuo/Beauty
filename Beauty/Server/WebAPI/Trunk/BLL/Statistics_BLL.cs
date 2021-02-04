using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Statistics_BLL
    { 
        #region 构造类实例
        public static Statistics_BLL Instance
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
            internal static readonly Statistics_BLL instance = new Statistics_BLL();
        }
        #endregion

        public ObjectResultSup<List<StatisticsSurplus_Model>> getConsumeStatisticsSurplus(StatisticsOperation_Model model)
        {
            return Statistics_DAL.Instance.getConsumeStatisticsSurplus(model);
        }

        public List<Statistics_Model> getConsumeStatisticsByObejctName(StatisticsOperation_Model model)
        {
            return Statistics_DAL.Instance.getConsumeStatisticsByObejctName(model);
        }

        public List<Statistics_Model> getConsumeStatisticsByPrice(StatisticsOperation_Model model)
        {

            return Statistics_DAL.Instance.getConsumeStatisticsByPrice(model);
        }



        public List<Statistics_Model> getConsumeStatisticsByMonth(StatisticsOperation_Model model)
        {
            return Statistics_DAL.Instance.getConsumeStatisticsByMonth(model);

        }

        #region 门店

        public List<Statistics_Model> getBranchBusinessStatistics(StatisticsOperation_Model model, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatistics(model, endTime);
        }

        public List<Statistics_Model> getBranchBusinessStatisticsTMCount(StatisticsOperation_Model model, string startTime, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatisticsTMCount(model, startTime, endTime);
        }

        public List<Statistics_Model> getBranchBusinessStatisticsConsume(StatisticsOperation_Model model, string startTime, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatisticsConsume(model, startTime, endTime);
        }

        public List<Statistics_Model> getBranchBusinessStatisticsRecharge(StatisticsOperation_Model model, string startTime, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatisticsRecharge(model, startTime, endTime);
        }


        public List<Statistics_Model> getBranchBusinessStatisticsProduct(StatisticsOperation_Model model, string startTime, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatisticsProduct(model, startTime, endTime);
        }


        public List<Statistics_Model> getBranchBusinessStatisticsTMCountMonth(StatisticsOperation_Model model, string startTime, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatisticsTMCountMonth(model, startTime, endTime);
        }


        public List<Statistics_Model> getBranchBusinessStatisticsConsumeMonth(StatisticsOperation_Model model, string startTime, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatisticsConsumeMonth(model, startTime, endTime);
        }


        public List<Statistics_Model> getBranchBusinessStatisticsRechargeMonth(StatisticsOperation_Model model, string startTime, string endTime)
        {
            return Statistics_DAL.Instance.getBranchBusinessStatisticsRechargeMonth(model, startTime, endTime);
        }
        #endregion
    }
}
