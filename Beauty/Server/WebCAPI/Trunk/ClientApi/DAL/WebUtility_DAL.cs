using BLToolkit.Data;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
{
    public class WebUtility_DAL
    {
        #region 构造类实例
        public static WebUtility_DAL Instance
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
            internal static readonly WebUtility_DAL instance = new WebUtility_DAL();
        }

        #endregion
        public void CustomerLocation(CustomerLocation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @"	INSERT INTO [TBL_CUSTOMER_LOCATION]
	                        (CustomerID,DeviceType,Longitude,Latitude,LocationTime,CompanyID,CreatorID,CreateTime,RecordType)
	                        	 VALUES
	                        (@CustomerID,@DeviceType,@Longitude,@Latitude,@LocationTime,@CompanyID,@CreatorID,@CreateTime,1)";

                db.SetCommand(strSql
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@DeviceType", model.DeviceType, DbType.Int32)
                    , db.Parameter("@Longitude", model.Longitude, DbType.Decimal)
                    , db.Parameter("@Latitude", model.Latitude, DbType.Decimal)
                    , db.Parameter("@LocationTime", model.LocationTime, DbType.DateTime2)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

            }
        }

    }
}
