using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model.Table_Model;
using BLToolkit.Data;
using HS.Framework.Common;
using System.Data;
using Model.View_Model;
using Model.Operation_Model;
using HS.Framework.Common.Util;

namespace WebAPI.DAL
{
    public class Image_DAL
    {
        #region 构造类实例
        public static Image_DAL Instance
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
            internal static readonly Image_DAL instance = new Image_DAL();
        }
        #endregion


        /// <summary>
        /// 获取Business图片
        /// </summary>
        public List<ImageCommon_Model> getBusinessImage(int companyId, int branchId, int photoHeight, int photoWidth)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " Select "
                    + Common.Const.strHttp
                    + Common.Const.server
                    + Common.Const.strMothod
                    + Common.Const.strSingleMark
                    + "  + cast(IMAGE_BUSINESS.CompanyID as nvarchar(10)) + "
                    + Common.Const.strSingleMark
                    + "/";
                if (branchId == 0)
                {
                    strSql += Common.Const.strImageObjectType2
                            + Common.Const.strSingleMark
                            + " + IMAGE_BUSINESS.FileName + ";
                }
                else
                {
                    strSql += Common.Const.strImageObjectType7
                            + Common.Const.strSingleMark
                            + "  + cast(IMAGE_BUSINESS.BranchID as nvarchar(10))+ '/' + IMAGE_BUSINESS.FileName + ";
                }
                strSql += Common.Const.strTh
                        + photoHeight
                        + Common.Const.strTw
                        + photoWidth
                        + Common.Const.strBg
                        + @" FileUrl,  FileName , ID ImageID from IMAGE_BUSINESS 
                        where CompanyID=@CompanyID
                        AND BranchID=@BranchID
                        AND Available = 1 ";

                List<ImageCommon_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteList<ImageCommon_Model>();
                return list;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="commodityId"></param>
        /// <param name="imageType"></param>
        /// <param name="imageWidth"></param>
        /// <param name="imageHeight"></param>
        /// <returns></returns>
        public List<ImageCommon_Model> getCommodityImage_2_2(int commodityId, int imageType, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" Select ");
                strSql.Append(Common.Const.strHttp);
                strSql.Append(Common.Const.server);
                strSql.Append(Common.Const.strMothod);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(CompanyID as nvarchar(10)) + ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(Common.Const.strImageObjectType6);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(CommodityCode as nvarchar(16))+ '/' + FileName + ");
                strSql.Append(Common.Const.strThumb);
                strSql.Append(" FileUrl, ");
                strSql.Append(" FileName, ");
                strSql.Append(" ID ImageID");
                strSql.Append(" from IMAGE_COMMODITY");
                strSql.Append(" where CommodityID=@CommodityID");
                strSql.Append(" AND ImageType=@ImageType");

                List<ImageCommon_Model> list = db.SetCommand(strSql.ToString(),
                    db.Parameter("@CommodityID", commodityId, DbType.Int32),
                    db.Parameter("@imageType", imageType, DbType.Boolean),
                    db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                    db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageCommon_Model>();

                return list;

            }
        }



        public List<string> getServiceImage(int serviceId, int imageType, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" Select "
                            + Common.Const.strHttp
                            + Common.Const.server
                            + Common.Const.strMothod
                            + Common.Const.strSingleMark
                            + "  + cast(CompanyID as nvarchar(10)) + "
                            + Common.Const.strSingleMark
                            + "/"
                            + Common.Const.strImageObjectType8
                            + Common.Const.strSingleMark
                            + "  + cast(ServiceCode as nvarchar(16))+ '/' + FileName + "
                            + Common.Const.strThumb
                            + @"FileUrl
                                    from IMAGE_SERVICE
                                    where ServiceID=@ServiceID
                                    AND ImageType=@ImageType";

                List<string> list = db.SetCommand(strSql.ToString(),
                    db.Parameter("@ServiceID", serviceId, DbType.Int32),
                    db.Parameter("@imageType", imageType, DbType.Boolean),
                    db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                    db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteScalarList<string>();

                return list;
            }
        }

        public GetServiceEffectImage_Model getServiceEffectImage(int companyId, int treatmentID, long groupNo, string imageSize, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                GetServiceEffectImage_Model model = new GetServiceEffectImage_Model();
                string strSql = @" Select ID TreatmentImageID,"
                                + Common.Const.strHttp
                                + Common.Const.server
                                + Common.Const.strMothod
                                + Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                + Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "+ T1.FileName +"
                                + Common.Const.strThumb
                                + " ThumbnailURL,"
                                + Common.Const.strHttp
                                + Common.Const.server
                                + Common.Const.strMothod
                                + Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                 + Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "+ T1.FileName + "
                                + imageSize
                                + @" OriginalImageURL
                                    from IMAGE_TREATMENT T1 
                                    where T1.CompanyID=@CompanyID
                                    AND T1.Available=@Available
                                    AND T1.ImageType=@ImageType ";


                if (groupNo > 0 && treatmentID <= 0)
                {
                    strSql += " AND T1.GroupNo=@GroupNo AND T1.TreatmentID=0 ";
                }
                else if (treatmentID > 0)
                {
                    strSql += " AND T1.TreatmentID=@TreatmentID AND T1.TreatmentID<>0 ";
                }

                model.ImageBeforeTreatment = db.SetCommand(strSql,
                        db.Parameter("@CompanyID", companyId, DbType.Int32),
                        db.Parameter("@TreatmentID", treatmentID, DbType.Int32),
                        db.Parameter("@GroupNo", groupNo, DbType.Int64),
                        db.Parameter("@Available", true, DbType.Boolean),
                        db.Parameter("@ImageType", false, DbType.Boolean),
                        db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                        db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageEffect_Model>();

                model.ImageAfterTreatment = db.SetCommand(strSql,
                        db.Parameter("@CompanyID", companyId, DbType.Int32),
                        db.Parameter("@TreatmentID", treatmentID, DbType.Int32),
                        db.Parameter("@GroupNo", groupNo, DbType.Int64),
                        db.Parameter("@Available", true, DbType.Boolean),
                        db.Parameter("@ImageType", true, DbType.Boolean),
                        db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                        db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageEffect_Model>();

                if (groupNo > 0 && treatmentID <= 0)
                {
                    string strSelTMSql = @" SELECT  T1.ID AS TreatmentID ,
                                                CASE WHEN ISNULL(T2.SubServiceName, '') = '' THEN '服务操作'
                                                     ELSE T2.SubServiceName
                                                END AS SubServiceName
                                        FROM    [TREATMENT] T1 WITH ( NOLOCK )
                                                LEFT JOIN [TBL_SUBSERVICE] T2 WITH ( NOLOCK ) ON T1.SubServiceID = T2.ID
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T1.GroupNo = @GroupNo AND T1.Status <> 3 AND T1.Status <> 4 ";

                    model.TMList = db.SetCommand(strSelTMSql
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@GroupNo", groupNo, DbType.Int64)).ExecuteList<TMinTG_Model>();
                }

                return model;
            }
        }

        public bool updateServiceEffectImage(int userId, int companyId, int customerId, int treatmentId, long groupNo, List<AddTreatmentImageOperation_Model> listAdd, List<DeleteTreatmentImageOperation_Model> listDelete)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    DateTime dt = DateTime.Now.ToLocalTime();
                    string strSqlAdd = @" insert into IMAGE_TREATMENT( CompanyID,TreatmentID,ImageType,FileName,Available,CreatorID,CreateTime,CustomerID,GroupNo)
                         values (@CompanyID,@TreatmentID,@ImageType,@FileName,@Available,@CreatorID,@CreateTime,@CustomerID,@GroupNo);select @@IDENTITY ";


                    string strCustomerAddSql = @" INSERT INTO IMT_CUSTOMER_RECPIC( CompanyID ,CustomerID ,GroupNo ,RecordImgID ,ImageTag ,FileName ,CreatorID ,CreateTime )
VALUES  (@CompanyID ,@CustomerID ,@GroupNo ,@RecordImgID ,@ImageTag ,@FileName ,@CreatorID ,@CreateTime ) ";

                    if (listAdd != null && listAdd.Count > 0)
                    {
                        foreach (AddTreatmentImageOperation_Model item in listAdd)
                        {
                            int ImageId = db.SetCommand(strSqlAdd,
                            db.Parameter("@CompanyID", companyId, DbType.Int32),
                            db.Parameter("@TreatmentID", treatmentId, DbType.Int32),
                            db.Parameter("@ImageType", item.ImageType, DbType.Boolean),
                            db.Parameter("@FileName", item.ImageName, DbType.String),
                            db.Parameter("@Available", true, DbType.Boolean),
                            db.Parameter("@CreatorID", userId, DbType.Int32),
                            db.Parameter("@CreateTime", dt, DbType.DateTime2),
                            db.Parameter("@CustomerID", customerId, DbType.Int32),
                            db.Parameter("@GroupNo", groupNo, DbType.Int64)).ExecuteScalar<int>();

                            if (ImageId == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            string ICRNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "ICRNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                            int ImageRes = db.SetCommand(strCustomerAddSql,
                            db.Parameter("@CompanyID", companyId, DbType.Int32),
                            db.Parameter("@CustomerID", customerId, DbType.Int32),
                            db.Parameter("@GroupNo", groupNo, DbType.Int64),
                            db.Parameter("@RecordImgID", ICRNo, DbType.String),
                            db.Parameter("@ImageTag", item.ImageType ? "服务后" : "服务前", DbType.String),
                            db.Parameter("@FileName", item.ImageName, DbType.String),
                            db.Parameter("@CreatorID", userId, DbType.Int32),
                            db.Parameter("@CreateTime", dt, DbType.DateTime2)).ExecuteNonQuery();

                            if (ImageRes == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    //执行treatmentImage删除操作
                    string strSqlDelete = @"update IMAGE_TREATMENT set 
                                            Available=@Available,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where ID=@ID ";

                    if (listDelete != null && listDelete.Count > 0)
                    {
                        foreach (DeleteTreatmentImageOperation_Model item in listDelete)
                        {
                            int rows = db.SetCommand(strSqlDelete,
                            db.Parameter("@Available", false, DbType.Boolean),
                            db.Parameter("@UpdaterID", userId, DbType.Int32),
                            db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                            db.Parameter("@ID", item.ImageID, DbType.Int32)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
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

        public List<AllServiceEffect_Model> GetAllServiceEffectByCustomerID(int customerID, int companyId, string imageSize, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSelGroupSql = @" SELECT  T1.GroupNo ,
                                                    T2.TGStartTime ,
                                                    T3.ServiceName ,
                                                    T3.OrderID,
                                                    T3.ID AS OrderObjectID 
                                            FROM    IMAGE_TREATMENT T1 WITH ( NOLOCK )
                                                    INNER JOIN TBL_TREATGROUP T2 WITH ( NOLOCK ) ON T2.GroupNo = T1.GroupNo
                                                    INNER JOIN TBL_ORDER_SERVICE T3 ON T3.ID = T2.OrderServiceID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerID = @CustomerID AND T1.Available = 1 
                                            GROUP BY T1.GroupNo ,T2.TGStartTime ,T3.ServiceName ,T3.OrderID,T3.ID 
                                            ORDER BY T2.TGStartTime DESC ";

                List<AllServiceEffect_Model> list = db.SetCommand(strSelGroupSql
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<AllServiceEffect_Model>();

                if (list != null && list.Count > 0)
                {
                    foreach (AllServiceEffect_Model item in list)
                    {
                        string strSelIMGSql = @" Select ID TreatmentImageID ,T1.ImageType , "
                                + Common.Const.strHttp
                                + Common.Const.server
                                + Common.Const.strMothod
                                + Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                + Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "+ T1.FileName +"
                                + Common.Const.strThumb
                                + " ThumbnailURL,"
                                + Common.Const.strHttp
                                + Common.Const.server
                                + Common.Const.strMothod
                                + Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                 + Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + Common.Const.strSingleMark
                                + "/"
                                + Common.Const.strSingleMark
                                + "+ T1.FileName + "
                                + imageSize
                                 + @" OriginalImageURL
                                    from IMAGE_TREATMENT T1 
                                    where T1.CompanyID=@CompanyID
                                    AND T1.Available=@Available 
                                    AND T1.GroupNo=@GroupNo ";

                        item.ImageEffect = db.SetCommand(strSelIMGSql
                                                   , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                   , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                                   , db.Parameter("@Available", true, DbType.Boolean)
                            //, db.Parameter("@ImageType", false, DbType.Boolean)
                                                   , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                                                   , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageTotalEffect_Model>();

                        //item.ImageAfterTreatment = db.SetCommand(strSelIMGSql
                        //                        , db.Parameter("@CompanyID", companyId, DbType.Int32)
                        //                        , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                        //                        , db.Parameter("@Available", true, DbType.Boolean)
                        //                        , db.Parameter("@ImageType", true, DbType.Boolean)
                        //                        , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                        //                        , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageEffect_Model>();
                    }
                }
                return list;
            }
        }

        public List<PhotoAlbumList_Model> getPhotoAlbumList(int CustomerID, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlTime = @" select CONVERT(varchar(10),CreateTime,20) CreateDate from IMAGE_TREATMENT 
                                        where Available = 1 and CustomerID = @CustomerID 
                                        group by CONVERT(varchar(10),CreateTime,20) ";

                List<DateTime> listDt = db.SetCommand(strSqlTime, db.Parameter("@CustomerID", CustomerID, DbType.Int32)).ExecuteScalarList<DateTime>();

                string strSql = @" select top 1 CONVERT(varchar(10),T1.CreateTime,20) CreateTime, "
                                    + Common.Const.strHttp
                                    + Common.Const.server
                                    + Common.Const.strMothod
                                    + Common.Const.strSingleMark
                                    + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                    + Common.Const.strSingleMark
                                    + "/"
                                    + Common.Const.strImageObjectType4
                                    + Common.Const.strSingleMark
                                    + "  + cast(T1.TreatmentID as nvarchar(10))+ '/' + T1.FileName + "
                                    + Common.Const.strThumb
                                    + @"  ImageURL  FROM IMAGE_TREATMENT T1
                                        where DATEDIFF(dd,CONVERT(varchar(10),CreateTime,20),CONVERT(varchar(10),@CreateDate,20))=0 
                                        and Available = 1 and CustomerID = @CustomerID 
                                        order by CreateTime desc";

                List<PhotoAlbumList_Model> list = new List<PhotoAlbumList_Model>();

                foreach (DateTime item in listDt)
                {

                    PhotoAlbumList_Model model = db.SetCommand(strSql,
                            db.Parameter("@CreateDate", item, DbType.DateTime),
                            db.Parameter("@CustomerID", CustomerID, DbType.Int32),
                            db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                            db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteObject<PhotoAlbumList_Model>();

                    if (model != null)
                    {
                        list.Add(model);
                    }
                }

                return list;
            }
        }

        public List<PhotoAlbumDetail_Model> getPhotoAlbumDetail(int CustomerID, string CreateDate, string thumbnailSize, int imageWidth, int imageHeight)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.CreateTime, T1.ID ImageID, "
                    + Common.Const.strHttp
                    + Common.Const.server
                    + Common.Const.strMothod
                    + Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + "
                    + Common.Const.strSingleMark
                    + "/"
                    + Common.Const.strImageObjectType4
                    + Common.Const.strSingleMark
                    + "  + cast(T1.TreatmentID as nvarchar(10))+ '/' + T1.FileName + "
                    + Common.Const.strThumb
                    + " ThumbnailURL, "
                    + Common.Const.strHttp
                    + Common.Const.server
                    + Common.Const.strMothod
                    + Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + "
                    + Common.Const.strSingleMark
                    + "/"
                    + Common.Const.strImageObjectType4
                    + Common.Const.strSingleMark
                    + "  + cast(T1.TreatmentID as nvarchar(10))+ '/' + T1.FileName "
                    + " + "
                    + thumbnailSize
                    + Common.Const.strBigImageFlg
                    + @" OriginalImageURL 
                        FROM IMAGE_TREATMENT T1 
                        where DATEDIFF(hh,CONVERT(varchar(10),T1.CreateTime,20),@CreateDate)=0 
                        and  T1.Available = 1 and T1.CustomerID = @CustomerID  
                        order by CreateTime,ImageID desc";

                List<PhotoAlbumDetail_Model> list = db.SetCommand(strSql,
                        db.Parameter("@CreateDate", CreateDate, DbType.String),
                        db.Parameter("@CustomerID", CustomerID, DbType.Int32),
                        db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                        db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<PhotoAlbumDetail_Model>();

                return list;
            }
        }

        /// <summary>
        /// 修改头像
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="userType"></param>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public bool updateUserHeadImage(int userId, int userType, string fileName)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " update ";
                if (userType == 2)
                {
                    strSql += " CUSTOMER ";
                }
                else
                {
                    strSql += " ACCOUNT ";
                }
                strSql += @" set HeadImageFile = @HeadImageFile,
                       UpdaterID = @UpdaterID,
                       UpdateTime = @UpdateTime 
                       where UserID = @UserID";

                int rows = db.SetCommand(strSql,
                             db.Parameter("@HeadImageFile", fileName, DbType.String),
                             db.Parameter("@UserID", userId, DbType.Int32),
                             db.Parameter("@UpdaterID", userId, DbType.Int32),
                             db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();

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


        public List<NoDeleteCommodityImage_Model> getCommodityImageSameCodeNoDelete(string strDeleteImageName, int CommodityID, bool addThumnail)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlSel = @"
                                 select CompanyID, CommodityCode, CommodityID, ImageType, FileName
                                 from IMAGE_COMMODITY
                                 where CommodityID =@CommodityID ";

                if (strDeleteImageName != "")
                {
                    strSqlSel += @" and FileName not in( "
                                + "'" + strDeleteImageName + "'"
                                + ")";
                }
                strSqlSel += addThumnail ? " and ImageType = 1 " : "";

                List<NoDeleteCommodityImage_Model> List = new List<NoDeleteCommodityImage_Model>();
                List = db.SetCommand(strSqlSel, db.Parameter("@CommodityID", CommodityID, DbType.Int32)).ExecuteList<NoDeleteCommodityImage_Model>();

                return List;
            }
        }

        public List<NoDeleteServiceImage_Model> getServiceImageSameCodeNoDelete(string strDeleteImageName, int ServiceID, bool addThumnail)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlSel = @"
                                 select CompanyID, ServiceCode, ServiceID, ImageType, FileName
                                 from IMAGE_SERVICE
                                 where ServiceID =@ServiceID ";

                if (strDeleteImageName != "")
                {
                    strSqlSel += @" and FileName not in( "
                                + "'" + strDeleteImageName + "'"
                                + ")";
                }
                strSqlSel += addThumnail ? " and ImageType = 1 " : "";
                List<NoDeleteServiceImage_Model> List = new List<NoDeleteServiceImage_Model>();
                List = db.SetCommand(strSqlSel, db.Parameter("@ServiceID", ServiceID, DbType.Int32)).ExecuteList<NoDeleteServiceImage_Model>();

                return List;
            }
        }


        #region 后台方法

        /// <summary>
        /// 获取Business图片
        /// </summary>
        public List<ImageCommon_Model> getBusinessImageForWeb(int companyId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " Select "
                    + Common.Const.strHttp
                    + Common.Const.server
                    + Common.Const.strMothod
                    + Common.Const.strSingleMark
                    + "  + cast(IMAGE_BUSINESS.CompanyID as nvarchar(10)) + "
                    + Common.Const.strSingleMark
                    + "/";
                if (branchId == 0)
                {
                    strSql += Common.Const.strImageObjectType2 + Common.Const.strSingleMark + " + IMAGE_BUSINESS.FileName  ";
                }
                else
                {
                    strSql += Common.Const.strImageObjectType7 + Common.Const.strSingleMark + " + cast(IMAGE_BUSINESS.BranchID as nvarchar(10))+ '/' + IMAGE_BUSINESS.FileName  ";
                }
                strSql += @"+'&biFlg=1' FileUrl, FileName , ID ImageID from IMAGE_BUSINESS 
                                where CompanyID=@CompanyID
                                AND BranchID=@BranchID
                                AND Available = 1 ";

                List<ImageCommon_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32), db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteList<ImageCommon_Model>();
                return list;
            }
        }

        public bool updateBusinessImage(BusinessImageOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    if (model.AddImage != null && model.AddImage.Count > 0)
                    {
                        string strSqlAdd = @" insert into IMAGE_BUSINESS(
                                        CompanyID,BranchID,FileName,Available,CreatorID,CreateTime)
                                         values (
                                        @CompanyID,@BranchID,@FileName,@Available,@CreatorID,@CreateTime) ";

                        foreach (string item in model.AddImage)
                        {
                            int rows = db.SetCommand(strSqlAdd, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                , db.Parameter("@FileName", item, DbType.String)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreatorID", model.UserID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.OperationTime, DbType.DateTime)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    if (model.DeleteImage != null && model.DeleteImage.Count > 0)
                    {
                        string strSqlDelete = @"update IMAGE_BUSINESS set 
                                        Available=@Available,
                                        UpdaterID=@UpdaterID,
                                        UpdateTime=@UpdateTime
                                        where FileName =@FileName";
                        foreach (string item in model.DeleteImage)
                        {
                            int rows = db.SetCommand(strSqlDelete
                                    , db.Parameter("@Available", false, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.UserID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.OperationTime, DbType.DateTime)
                                    , db.Parameter("@FileName", item, DbType.String)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
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

        public bool updateCommodityImage(ProductImageOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    if (model.NoDeleteImageList != null && model.NoDeleteImageList.Count > 0)
                    {
                        for (int i = 0; i < model.NoDeleteImageList.Count; i++)
                        {
                            string strSqlAdd = @" insert into IMAGE_COMMODITY(
                                              CompanyID,CommodityCode,CommodityID,ImageType,FileName,CreatorID,CreateTime)
                                               values (
                                              @CompanyID,@CommodityCode,@CommodityID,@ImageType,@FileName,@CreatorID,@CreateTime) ";

                            int rows = db.SetCommand(strSqlAdd
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@CommodityCode", model.CommodityCode, DbType.Int64)
                                    , db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                                    , db.Parameter("@ImageType", model.NoDeleteImageList[i].ImageType, DbType.Boolean)
                                    , db.Parameter("@FileName", model.NoDeleteImageList[i].FileName, DbType.String)
                                    , db.Parameter("@CreatorID", model.UserID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.OperationTime, DbType.DateTime)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    if (!string.IsNullOrEmpty(model.AddThumbnail))
                    {
                        string strSqlCheck = " select Count(0) from [IMAGE_COMMODITY] where ImageType =0 and CommodityID=@CommodityID and CompanyID=@CompanyID ";

                        int cnt = db.SetCommand(strSqlCheck
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)).ExecuteScalar<int>();

                        if (cnt > 0)
                        {

                            string strSqlDeleteThumbnail = @"delete IMAGE_COMMODITY  where CommodityID=@CommodityID and CompanyID=@CompanyID and  ImageType =0 ";

                            int deleteRows = db.SetCommand(strSqlDeleteThumbnail
                                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                   , db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)).ExecuteNonQuery();


                            if (deleteRows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }

                        string strSqlAddThumbnail = @" insert into IMAGE_COMMODITY(
                                              CompanyID,CommodityCode,CommodityID,ImageType,FileName,CreatorID,CreateTime)
                                               values (
                                              @CompanyID,@CommodityCode,@CommodityID,@ImageType,@FileName,@CreatorID,@CreateTime) ";

                        int rows = db.SetCommand(strSqlAddThumbnail
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int64)
                               , db.Parameter("@CommodityCode", model.CommodityCode, DbType.Int64)
                               , db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                               , db.Parameter("@ImageType", false, DbType.Boolean)
                               , db.Parameter("@FileName", model.AddThumbnail, DbType.String)
                               , db.Parameter("@CreatorID", model.UserID, DbType.Int32)
                               , db.Parameter("@CreateTime", model.OperationTime, DbType.DateTime)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }

                    if (model.AddBigImage != null && model.AddBigImage.Count > 0)
                    {
                        string strSqlAdd = @" insert into IMAGE_COMMODITY(
                                              CompanyID,CommodityCode,CommodityID,ImageType,FileName,CreatorID,CreateTime)
                                               values (
                                              @CompanyID,@CommodityCode,@CommodityID,@ImageType,@FileName,@CreatorID,@CreateTime)";

                        foreach (string item in model.AddBigImage)
                        {
                            int rows = db.SetCommand(strSqlAdd
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CommodityCode", model.CommodityCode, DbType.Int64)
                                , db.Parameter("@CommodityID", model.CommodityID, DbType.Int32)
                                , db.Parameter("@ImageType", true, DbType.Boolean)
                                , db.Parameter("@FileName", item, DbType.String)
                                , db.Parameter("@CreatorID", model.UserID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.OperationTime, DbType.DateTime)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    if (model.DeleteImage != null && model.DeleteImage.Count > 0)
                    {
                        string strSqlDelete = @"delete IMAGE_COMMODITY 
                                        where FileName =@FileName";
                        foreach (string item in model.DeleteImage)
                        {
                            int rows = db.SetCommand(strSqlDelete
                                    , db.Parameter("@UpdaterID", model.UserID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.OperationTime, DbType.DateTime)
                                    , db.Parameter("@FileName", item, DbType.String)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
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


        public bool updateServiceImage(ProductImageOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    if (model.NoDeleteServiceImageList != null && model.NoDeleteServiceImageList.Count > 0)
                    {
                        for (int i = 0; i < model.NoDeleteServiceImageList.Count; i++)
                        {
                            string strSqlAdd = @" insert into IMAGE_Service(
                                              CompanyID,ServiceCode,ServiceID,ImageType,FileName,CreatorID,CreateTime)
                                               values (
                                              @CompanyID,@ServiceCode,@ServiceID,@ImageType,@FileName,@CreatorID,@CreateTime) ";

                            int rows = db.SetCommand(strSqlAdd
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@ServiceCode", model.ServiceCode, DbType.Int64)
                                    , db.Parameter("@ServiceID", model.ServiceID, DbType.Int32)
                                    , db.Parameter("@ImageType", model.NoDeleteServiceImageList[i].ImageType, DbType.Boolean)
                                    , db.Parameter("@FileName", model.NoDeleteServiceImageList[i].FileName, DbType.String)
                                    , db.Parameter("@Available", true, DbType.Boolean)
                                    , db.Parameter("@CreatorID", model.UserID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.OperationTime, DbType.DateTime)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    if (!string.IsNullOrEmpty(model.AddThumbnail))
                    {
                        string strSqlCheck = " select Count(0) from [IMAGE_SERVICE] where ImageType =0 and ServiceID=@ServiceID and CompanyID=@CompanyID ";

                        int cnt = db.SetCommand(strSqlCheck
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@ServiceID", model.ServiceID, DbType.Int32)).ExecuteScalar<int>();

                        if (cnt > 0)
                        {

                            string strSqlDeleteThumbnail = @"delete IMAGE_SERVICE where ServiceID=@ServiceID and CompanyID=@CompanyID and  ImageType =0 ";

                            int deleteRows = db.SetCommand(strSqlDeleteThumbnail
                                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                   , db.Parameter("@ServiceID", model.ServiceID, DbType.Int32)).ExecuteNonQuery();


                            if (deleteRows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                        string strSqlAddThumbnail = @" insert into IMAGE_Service(
                                              CompanyID,ServiceCode,ServiceID,ImageType,FileName,CreatorID,CreateTime)
                                               values (
                                              @CompanyID,@ServiceCode,@ServiceID,@ImageType,@FileName,@CreatorID,@CreateTime) ";

                        int rows = db.SetCommand(strSqlAddThumbnail
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int64)
                                , db.Parameter("@ServiceCode", model.ServiceCode, DbType.Int64)
                                , db.Parameter("@ServiceID", model.ServiceID, DbType.Int32)
                                , db.Parameter("@ImageType", false, DbType.Boolean)
                                , db.Parameter("@FileName", model.AddThumbnail, DbType.String)
                                , db.Parameter("@CreatorID", model.UserID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.OperationTime, DbType.DateTime)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }

                    if (model.AddBigImage != null && model.AddBigImage.Count > 0)
                    {
                        string strSqlAdd = @" insert into IMAGE_Service(
                                              CompanyID,ServiceCode,ServiceID,ImageType,FileName,CreatorID,CreateTime)
                                               values (
                                              @CompanyID,@ServiceCode,@ServiceID,@ImageType,@FileName,@CreatorID,@CreateTime)";

                        foreach (string item in model.AddBigImage)
                        {
                            int rows = db.SetCommand(strSqlAdd
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@ServiceCode", model.ServiceCode, DbType.Int64)
                                , db.Parameter("@ServiceID", model.ServiceID, DbType.Int32)
                                , db.Parameter("@ImageType", true, DbType.Boolean)
                                , db.Parameter("@FileName", item, DbType.String)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreatorID", model.UserID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.OperationTime, DbType.DateTime)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    if (model.DeleteImage != null && model.DeleteImage.Count > 0)
                    {
                        string strSqlDelete = @"delete IMAGE_Service 
                                        where FileName =@FileName";
                        foreach (string item in model.DeleteImage)
                        {
                            int rows = db.SetCommand(strSqlDelete
                                    , db.Parameter("@Available", false, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.UserID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.OperationTime, DbType.DateTime)
                                    , db.Parameter("@FileName", item, DbType.String)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
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


        /// <summary>
        /// 获取Commodity图片
        /// </summary>
        public DataTable getCommodityImageForExport(int commodityId)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" Select ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append(Common.Const.strImage);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(CompanyID as nvarchar(10)) + ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(Common.Const.strImageObjectType6);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(CommodityCode as nvarchar(16))+ '/' + FileName ");
                strSql.Append(" FileUrl, ");
                strSql.Append(" ImageType");
                strSql.Append(" from IMAGE_COMMODITY");
                strSql.Append(" where CommodityID=@CommodityID");

                return db.SetCommand(strSql.ToString(), db.Parameter("@CommodityID", commodityId, DbType.Int32)).ExecuteDataTable();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="serviceId"></param>
        /// <returns></returns>
        public DataTable getServiceImageForExport(int serviceId)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" Select ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append(Common.Const.strImage);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(CompanyID as nvarchar(10)) + ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(Common.Const.strImageObjectType8);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(ServiceCode as nvarchar(16))+ '/' + FileName  ");
                strSql.Append(" FileUrl, ");
                strSql.Append(" ImageType ");
                strSql.Append(" from IMAGE_SERVICE");
                strSql.Append(" where ServiceID=@ServiceID");

                return db.SetCommand(strSql.ToString(), db.Parameter("@ServiceID", serviceId, DbType.Int32)).ExecuteDataTable();
            }
        }


        #endregion

    }
}
