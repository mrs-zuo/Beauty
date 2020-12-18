using BLToolkit.Data;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class CustomerSource_DAL
    {
        #region 构造类实例
        public static CustomerSource_DAL Instance
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
            internal static readonly CustomerSource_DAL instance = new CustomerSource_DAL();
        }
        #endregion

        public List<CustomerSource_Model> getCustomerSourceList(int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select ID,Name from [TBL_CUSTOMER_SOURCE_TYPE] with (nolock) where CompanyID=@CompanyID and RecordType = 1 ";

                List<CustomerSource_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteList<CustomerSource_Model>();

                return list;
            }
        }

        public bool deleteCustomerSource(CustomerSource_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" update [TBL_CUSTOMER_SOURCE_TYPE] set RecordType = 2,
                                       UpdaterID =@UpdaterID,
                                       UpdateTime =@UpdateTime
                                       where CompanyID=@CompanyID and ID =@ID ";

                int rows = db.SetCommand(strSql
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    return false;
                }

                return true;
            }
        }

        public CustomerSource_Model getCustomerSourceDetail(int CompanyID, int ID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select ID,Name from [TBL_CUSTOMER_SOURCE_TYPE] with (nolock) where CompanyID=@CompanyID and RecordType = 1 and ID =@ID ";

                CustomerSource_Model model = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@ID", ID, DbType.Int32)).ExecuteObject<CustomerSource_Model>();

                return model;
            }
        }

        public bool addCustomerSource(CustomerSource_Model model) {
            using (DbManager db = new DbManager())
            {
                string strSql = @" INSERT INTO [TBL_CUSTOMER_SOURCE_TYPE]
                                 (CompanyID,Name,CreatorID,CreateTime,RecordType)
                                   VALUES
                                (@CompanyID,@Name,@CreatorID,@CreateTime,1);
                                  select @@IDENTITY ";

                int id = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@Name", model.Name, DbType.String)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                if (id <= 0) {
                    return false;
                }

                return true;
            }
        }



        public bool updateCustomerSource(CustomerSource_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" update [TBL_CUSTOMER_SOURCE_TYPE]
                                   set Name=@Name,
                                       UpdaterID =@UpdaterID,
                                       UpdateTime =@UpdateTime
                                    where CompanyID=@CompanyID and ID=@ID ";

                int rows = db.SetCommand(strSql
                    , db.Parameter("@Name", model.Name, DbType.String)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows != 1)
                {
                    return false;
                }

                return true;
            }
        }

    }
}
