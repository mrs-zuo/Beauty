using BLToolkit.Data;
using HS.Framework.Common.Util;
using Model.Operation_Model;
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
                    + WebAPI.Common.Const.strHttp
                    + WebAPI.Common.Const.server
                    + WebAPI.Common.Const.strMothod
                    + WebAPI.Common.Const.strSingleMark
                    + "  + cast(IMAGE_BUSINESS.CompanyID as nvarchar(10)) + "
                    + WebAPI.Common.Const.strSingleMark
                    + "/";
                if (branchId == 0)
                {
                    strSql += WebAPI.Common.Const.strImageObjectType2
                            + WebAPI.Common.Const.strSingleMark
                            + " + IMAGE_BUSINESS.FileName + ";
                }
                else
                {
                    strSql += WebAPI.Common.Const.strImageObjectType7
                            + WebAPI.Common.Const.strSingleMark
                            + "  + cast(IMAGE_BUSINESS.BranchID as nvarchar(10))+ '/' + IMAGE_BUSINESS.FileName + ";
                }
                strSql += WebAPI.Common.Const.strTh
                        + photoHeight
                        + WebAPI.Common.Const.strTw
                        + photoWidth
                        + WebAPI.Common.Const.strBg
                        + @" FileUrl,  FileName , ID ImageID from IMAGE_BUSINESS 
                        where CompanyID=@CompanyID
                        AND BranchID=@BranchID
                        AND Available = 1 ";

                List<ImageCommon_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteList<ImageCommon_Model>();
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
                                    + WebAPI.Common.Const.strHttp
                                    + WebAPI.Common.Const.server
                                    + WebAPI.Common.Const.strMothod
                                    + WebAPI.Common.Const.strSingleMark
                                    + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                    + WebAPI.Common.Const.strSingleMark
                                    + "/TreatGroup/"
                                    + WebAPI.Common.Const.strSingleMark
                                    + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                    + WebAPI.Common.Const.strSingleMark
                                    + "/"
                                    + WebAPI.Common.Const.strSingleMark
                                    + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                    + WebAPI.Common.Const.strSingleMark
                                    + "/"
                                    + WebAPI.Common.Const.strSingleMark
                                    + "+ T1.FileName +"
                                    + WebAPI.Common.Const.strThumb
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
                    + WebAPI.Common.Const.strHttp
                    + WebAPI.Common.Const.server
                    + WebAPI.Common.Const.strMothod
                    + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + "
                    + WebAPI.Common.Const.strSingleMark
                    + "/TreatGroup/"
                    + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.GroupNo as nvarchar(16)) + "
                    + WebAPI.Common.Const.strSingleMark
                    + "/"
                    + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                    + WebAPI.Common.Const.strSingleMark
                    + "/"
                    + WebAPI.Common.Const.strSingleMark
                    + "+ T1.FileName +"
                    + WebAPI.Common.Const.strThumb
                    + " ThumbnailURL, "
                    + WebAPI.Common.Const.strHttp
                    + WebAPI.Common.Const.server
                    + WebAPI.Common.Const.strMothod
                    + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + "
                        + WebAPI.Common.Const.strSingleMark
                    + "/TreatGroup/"
                    + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.GroupNo as nvarchar(16)) + "
                    + WebAPI.Common.Const.strSingleMark
                    + "/"
                    + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                    + WebAPI.Common.Const.strSingleMark
                    + "/"
                    + WebAPI.Common.Const.strSingleMark
                    + "+ T1.FileName + "
                    + thumbnailSize
                    + WebAPI.Common.Const.strBigImageFlg
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

        public List<ImageCommon_Model> getCommodityImage_2_2(int commodityId, int imageType, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" Select ");
                strSql.Append(WebAPI.Common.Const.strHttp);
                strSql.Append(WebAPI.Common.Const.server);
                strSql.Append(WebAPI.Common.Const.strMothod);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(CompanyID as nvarchar(10)) + ");
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(WebAPI.Common.Const.strImageObjectType6);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(CommodityCode as nvarchar(16))+ '/' + FileName + ");
                strSql.Append(WebAPI.Common.Const.strThumb);
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
                            + WebAPI.Common.Const.strHttp
                            + WebAPI.Common.Const.server
                            + WebAPI.Common.Const.strMothod
                            + WebAPI.Common.Const.strSingleMark
                            + "  + cast(CompanyID as nvarchar(10)) + "
                            + WebAPI.Common.Const.strSingleMark
                            + "/"
                            + WebAPI.Common.Const.strImageObjectType8
                            + WebAPI.Common.Const.strSingleMark
                            + "  + cast(ServiceCode as nvarchar(16))+ '/' + FileName + "
                            + WebAPI.Common.Const.strThumb
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

        public GetTreatmentImage_Model getTreatmentImage(int companyId, int treatmentID, string imageSize, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                GetTreatmentImage_Model model = new GetTreatmentImage_Model();
                string strSql = @" Select ID TreatmentImageID,"
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(IMAGE_TREATMENT.CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strImageObjectType4
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(IMAGE_TREATMENT.TreatmentID as nvarchar(10))+ '/' + IMAGE_TREATMENT.FileName + "
                                + WebAPI.Common.Const.strThumb
                                + " ThumbnailURL,"
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(IMAGE_TREATMENT.CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strImageObjectType4
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(IMAGE_TREATMENT.TreatmentID as nvarchar(10))+ '/' + IMAGE_TREATMENT.FileName + "
                                + imageSize
                                + @" OriginalImageURL
                                    from IMAGE_TREATMENT 
                                    where CompanyID=@CompanyID
                                    AND TreatmentID=@TreatmentID
                                    AND Available=@Available
                                    AND ImageType=@ImageType ";
                model.ImageBeforeTreatment = db.SetCommand(strSql,
                        db.Parameter("@CompanyID", companyId, DbType.Int32),
                        db.Parameter("@TreatmentID", treatmentID, DbType.Int32),
                        db.Parameter("@Available", true, DbType.Boolean),
                        db.Parameter("@ImageType", false, DbType.Boolean),
                        db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                        db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageBeforeTreatment_Model>();

                model.ImageAfterTreatment = db.SetCommand(strSql,
                        db.Parameter("@CompanyID", companyId, DbType.Int32),
                        db.Parameter("@TreatmentID", treatmentID, DbType.Int32),
                        db.Parameter("@Available", true, DbType.Boolean),
                        db.Parameter("@ImageType", true, DbType.Boolean),
                        db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                        db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageAfterTreatment_Model>();

                return model;
            }
        }

        public GetServiceEffectImage_Model getServiceEffectImage(int companyId, int treatmentID, long groupNo, string imageSize, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                GetServiceEffectImage_Model model = new GetServiceEffectImage_Model();
                string strSql = @" Select ID TreatmentImageID,"
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ T1.FileName +"
                                + WebAPI.Common.Const.strThumb
                                + " ThumbnailURL,"
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                 + WebAPI.Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ T1.FileName  "
                    //+ imageSize
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

        public List<AllServiceEffect_Model> GetAllServiceEffectByCustomerID(int customerID, int companyId, string imageSize, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSelGroupSql = @" SELECT  T1.GroupNo ,
                                                    T2.TGStartTime ,
                                                    T3.ServiceName ,
                                                    T3.OrderID
                                            FROM    IMAGE_TREATMENT T1 WITH ( NOLOCK )
                                                    INNER JOIN TBL_TREATGROUP T2 WITH ( NOLOCK ) ON T2.GroupNo = T1.GroupNo
                                                    INNER JOIN TBL_ORDER_SERVICE T3 ON T3.ID = T2.OrderServiceID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerID = @CustomerID AND T1.Available = 1 
                                            GROUP BY T1.GroupNo ,T2.TGStartTime ,T3.ServiceName ,T3.OrderID ";

                List<AllServiceEffect_Model> list = db.SetCommand(strSelGroupSql
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<AllServiceEffect_Model>();

                if (list != null && list.Count > 0)
                {
                    foreach (AllServiceEffect_Model item in list)
                    {
                        string strSelIMGSql = @" Select ID TreatmentImageID,"
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ T1.FileName +"
                                + WebAPI.Common.Const.strThumb
                                + " ThumbnailURL,"
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.CompanyID as nvarchar(10)) + "
                                 + WebAPI.Common.Const.strSingleMark
                                + "/TreatGroup/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.GroupNo as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T1.TreatmentID as nvarchar(10))+ "
                                + WebAPI.Common.Const.strSingleMark
                                + "/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ T1.FileName + "
                                + imageSize
                                 + @" OriginalImageURL
                                    from IMAGE_TREATMENT T1 
                                    where T1.CompanyID=@CompanyID
                                    AND T1.Available=@Available
                                    AND T1.ImageType=@ImageType 
                                    AND T1.GroupNo=@GroupNo ";

                        item.ImageBeforeTreatment = db.SetCommand(strSelIMGSql
                                                   , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                   , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                                   , db.Parameter("@Available", true, DbType.Boolean)
                                                   , db.Parameter("@ImageType", false, DbType.Boolean)
                                                   , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                                                   , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageEffect_Model>();

                        item.ImageAfterTreatment = db.SetCommand(strSelIMGSql
                                                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                                , db.Parameter("@Available", true, DbType.Boolean)
                                                , db.Parameter("@ImageType", true, DbType.Boolean)
                                                , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                                                , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<ImageEffect_Model>();
                    }
                }
                return list;
            }
        }

        public bool updateServiceEffectImage(int userId, int companyId, int customerId, int treatmentId, long groupNo, string Comment, List<AddTreatmentImageOperation_Model> listAdd, List<DeleteTreatmentImageOperation_Model> listDelete)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    DateTime dt = DateTime.Now.ToLocalTime();

                    string strCustomerAddSql = @" INSERT INTO IMT_CUSTOMER_RECPIC( CompanyID ,CustomerID ,GroupNo ,RecordImgID ,ImageTag ,FileName ,CreatorID ,CreateTime )
VALUES  (@CompanyID ,@CustomerID ,@GroupNo ,@RecordImgID ,@ImageTag ,@FileName ,@CreatorID ,@CreateTime ) ";

                    if (listAdd != null && listAdd.Count > 0)
                    {
                        foreach (AddTreatmentImageOperation_Model item in listAdd)
                        {
                            string ICRNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "ICRNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                            int ImageRes = db.SetCommand(strCustomerAddSql,
                            db.Parameter("@CompanyID", companyId, DbType.Int32),
                            db.Parameter("@CustomerID", customerId, DbType.Int32),
                            db.Parameter("@GroupNo", groupNo, DbType.Int64),
                            db.Parameter("@RecordImgID", ICRNo, DbType.String),
                            db.Parameter("@ImageTag", item.ImageTag, DbType.String),
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
                    string strSqlDelete = @" DELETE IMT_CUSTOMER_RECPIC WHERE RecordImgID=@RecordImgID ";

                    if (listDelete != null && listDelete.Count > 0)
                    {
                        foreach (DeleteTreatmentImageOperation_Model item in listDelete)
                        {
                            int rows = db.SetCommand(strSqlDelete
                                , db.Parameter("@RecordImgID", item.ImageID, DbType.String)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }

                    if (!string.IsNullOrWhiteSpace(Comment))
                    {
                        string strUpdateComment = @" UPDATE [TBL_TREATGROUP] SET Comments=@Comments,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE GroupNo=@GroupNo ";
                        int updateRes = db.SetCommand(strUpdateComment
                                    , db.Parameter("@Comments", Comment, DbType.String)
                                    , db.Parameter("@UpdaterID", userId, DbType.Int32)
                                    , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                                    , db.Parameter("@GroupNo", groupNo, DbType.Int64)).ExecuteNonQuery();

                        if (updateRes != 1)
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

        public List<AllCustomerRecPic> getCustomerRecPic(int companyId, int customerID, int year, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSelServiceSql = @" SELECT  T2.ServiceName ,
                                                    T2.ServiceCode
                                            FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                    INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID AND T2.Available=1 
                                            WHERE   YEAR(TGStartTime) = @Year
                                                    AND T2.CustomerID = @CustomerID
                                                    AND T1.CompanyID = @CompanyID 
                                                    AND T1.TGStatus IN(1,2,5)
                                                    AND T1.DeleteFlag =1 
                                            GROUP BY T2.ServiceName ,
                                                    T2.ServiceCode ";

                //DateTime dt = StringUtils.GetDbDateTime(year + "-01-01 00:00:00");

                List<AllCustomerRecPic> serviceList = db.SetCommand(strSelServiceSql
                    , db.Parameter("@Year", year, DbType.Int32)
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<AllCustomerRecPic>();

                if (serviceList != null && serviceList.Count > 0)
                {
                    foreach (AllCustomerRecPic item in serviceList)
                    {
                        string strPicSql = @" SELECT  TOP 4 "
                        + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(T3.CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/Customer/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(@CustomerID as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/BeautyRec/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ T3.FileName +"
                                + WebAPI.Common.Const.strThumb
                                + " ImageURL "
                                + @" FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                            INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                            INNER JOIN [IMT_CUSTOMER_RECPIC] T3 WITH ( NOLOCK ) ON T1.GroupNo = T3.GroupNo
                                    WHERE   T2.ServiceCode = @ServiceCode
                                            AND T3.CompanyID = @CompanyID 
                                            AND T1.TGStatus IN(1,2,5) 
                                            AND T3.CustomerID = @CustomerID 
                                            AND T1.DeleteFlag =1 and YEAR(T1.TGStartTime)=@Year
                                    ORDER BY T3.CreateTime DESC ";
                     
                        item.ImageURL = db.SetCommand(strPicSql
                                      , db.Parameter("@ServiceCode", item.ServiceCode, DbType.Int64)
                                      , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                      , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                      , db.Parameter("@Year", year, DbType.Int32)
                                      , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                                      , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteScalarList<string>();
                    }
                }

                return serviceList;
            }
        }

        public CustomerRecPicDetail getCustomerServicePic(int companyId, int customerID, long serviceCode,int serviceYear, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strGetServiceSql = @" SELECT Code AS ServiceCode,ServiceName FROM [SERVICE] WHERE CompanyID=@CompanyID AND Code=@ServiceCode AND Available=1 ";
                CustomerRecPicDetail model = db.SetCommand(strGetServiceSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)).ExecuteObject<CustomerRecPicDetail>();
                if (model != null)
                {
                    //ServicePicList listmodel = new ServicePicList();
                    string strGetTGSql = @" SELECT  T1.TGStartTime ,
                                                    T4.BranchName ,
                                                    T4.ID AS BranchID ,
                                                    T1.Comments ,
                                                    T1.GroupNo
                                            FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                    INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                    INNER JOIN [BRANCH] T4 ON T1.BranchID = T4.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T2.CustomerID = @CustomerID
                                                    AND T2.ServiceCode = @ServiceCode 
                                                    AND T1.TGStatus IN(1,2,5)
                                                    AND T1.DeleteFlag =1 
                                                    AND DATEDIFF(YEAR, TGStartTime, @Year) = 0 
                                            ORDER BY T1.TGStartTime DESC ";
                    List<ServicePicList> listmodel = db.SetCommand(strGetTGSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)
                    , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)
                    , db.Parameter("@Year", serviceYear.ToString(), DbType.String)).ExecuteList<ServicePicList>();

                    if (listmodel != null && listmodel.Count > 0)
                    {
                        foreach (ServicePicList item in listmodel)
                        {
                            string strGetPicImg = @" SELECT TOP 4 "
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/Customer/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(@CustomerID as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/BeautyRec/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ FileName +"
                                + WebAPI.Common.Const.strThumb
                                + " ImageURL "
                                + @" FROM [IMT_CUSTOMER_RECPIC] 
                                WHERE GroupNo=@GroupNo AND CustomerID=@CustomerID 
                                ORDER BY CreateTime DESC ";

                            item.ImageURL = db.SetCommand(strGetPicImg
                                     , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                     , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                     , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                                     , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteScalarList<string>();
                        }
                        model.ServicePicList = listmodel;
                    }
                }
                return model;
            }
        }

        public CustomerTGPic getCustomerTGPic(int companyId, int customerID, long groupNo, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T1.TGStartTime ,
                                    T4.BranchName ,
                                    T4.ID AS BranchID ,
                                    T1.Comments ,
                                    T3.ServiceName,
                                    T2.ServiceCode,
                                    T1.GroupNo,T5.ReviewCount
                            FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                    INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                    INNER JOIN [SERVICE] T3 WITH(NOLOCK) ON T3.Code=T2.ServiceCode
                                    INNER JOIN [BRANCH] T4 ON T1.BranchID = T4.ID 
                                    LEFT JOIN [TBL_SHARE_STATICS] T5 on T1.GroupNo=T5.RecordID 
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T2.CustomerID = @CustomerID
                                    AND T1.GroupNo = @GroupNo; ";

                CustomerTGPic model = db.SetCommand(strSql
                                      , db.Parameter("@GroupNo", groupNo, DbType.Int64)
                                      , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                      , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteObject<CustomerTGPic>();

                if (model != null)
                {
                    string strSelPicSql = @"SELECT RecordImgID ,ImageTag ,"
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/Customer/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(@CustomerID as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/BeautyRec/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ FileName +"
                                + WebAPI.Common.Const.strThumb
                                + " ImageURL "
                                + @" FROM [IMT_CUSTOMER_RECPIC] 
                                WHERE GroupNo=@GroupNo AND CustomerID=@CustomerID 
                                ORDER BY CreateTime DESC ";

                    model.TGPicList = db.SetCommand(strSelPicSql
                                      , db.Parameter("@GroupNo", groupNo, DbType.Int64)
                                      , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                      , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                                      , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<CustomerTGPicList>();
                }
                return model;
            }
        }

        public CustomerTGPicList getCustomerPicDetail(int companyId, int customerID, string recordImgID, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT ImageTag ,RecordImgID, "
                                + WebAPI.Common.Const.strHttp
                                + WebAPI.Common.Const.server
                                + WebAPI.Common.Const.strMothod
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(CompanyID as nvarchar(10)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/Customer/"
                                + WebAPI.Common.Const.strSingleMark
                                + "  + cast(@CustomerID as nvarchar(16)) + "
                                + WebAPI.Common.Const.strSingleMark
                                + "/BeautyRec/"
                                + WebAPI.Common.Const.strSingleMark
                                + "+ FileName +"
                                + WebAPI.Common.Const.strThumb
                                + " ImageURL "
                                + @" FROM [IMT_CUSTOMER_RECPIC] WHERE CustomerID=@CustomerID AND RecordImgID=@RecordImgID AND CompanyID=@CompanyID ";

                CustomerTGPicList model = db.SetCommand(strSql
                                     , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                     , db.Parameter("@RecordImgID", recordImgID, DbType.String)
                                     , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                     , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                                     , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteObject<CustomerTGPicList>();
                return model;
            }
        }

        public bool editCustomerPic(int companyId, int customerID, string recordImgID, long groupNo, string imageTag, int type = 1)
        {
            using (DbManager db = new DbManager())
            {
                DateTime dt = DateTime.Now.ToLocalTime();
                db.BeginTransaction();
                if (type == 1)
                {
                    #region 删除TG
                    string strSql = @" UPDATE  [TBL_TREATGROUP]
                                        SET     DeleteFlag = 0 ,
                                                UpdaterID = @UpdaterID ,
                                                UpdateTime = @UpdateTime
                                        WHERE   CompanyID = @CompanyID
                                                AND GroupNo = @GroupNo ";
                    int res = db.SetCommand(strSql
                        , db.Parameter("@UpdaterID", customerID, DbType.Int32)
                        , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                        , db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@GroupNo", groupNo, DbType.Int64)).ExecuteNonQuery();

                    if (res != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                    #endregion
                }
                else if (type == 2)
                {
                    #region 删除单张照片
                    string strSql = @" DELETE [IMT_CUSTOMER_RECPIC] WHERE CompanyID=@CompanyID AND CustomerID=@CustomerID AND RecordImgID=@RecordImgID ";
                    int res = db.SetCommand(strSql
                       , db.Parameter("@CompanyID", companyId, DbType.Int32)
                       , db.Parameter("@CustomerID", customerID, DbType.Int32)
                       , db.Parameter("@RecordImgID", recordImgID, DbType.String)).ExecuteNonQuery();

                    if (res != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                    #endregion
                }
                else if (type == 3)
                {
                    #region 修改照片的标签
                    string strSql = @" UPDATE  [IMT_CUSTOMER_RECPIC]
                                        SET     ImageTag = @ImageTag ,
                                                UpdaterID = @UpdaterID ,
                                                UpdateTime = UpdateTime
                                        WHERE   CompanyID = @CompanyID
                                                AND CustomerID = @CustomerID
                                                AND RecordImgID = @RecordImgID ";

                    int res = db.SetCommand(strSql
                        , db.Parameter("@ImageTag", imageTag, DbType.String)
                        , db.Parameter("@UpdaterID", customerID, DbType.Int32)
                        , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                        , db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@CustomerID", customerID, DbType.Int32)
                        , db.Parameter("@RecordImgID", recordImgID, DbType.String)).ExecuteNonQuery();

                    if (res != 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                    #endregion
                }
                db.CommitTransaction();
                return true;
            }
        }
    }
}
