package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ImageContent;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.Treatment;
import com.GlamourPromise.Beauty.bean.TreatmentGroup;
import com.GlamourPromise.Beauty.bean.TreatmentImage;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.Base64Util;
import com.GlamourPromise.Beauty.util.CropUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.UploadImageUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

@SuppressLint("ResourceType")
public class EditTreatmentTreatmentDetailActivity extends BaseActivity implements OnClickListener {
	private EditTreatmentTreatmentDetailActivityHandler mHandler = new EditTreatmentTreatmentDetailActivityHandler(this);
	private LinearLayout beforeTreatmentImageContent;
	private LinearLayout afterTreatmentImageContent;
	private Thread requestWebServiceThread;
	private TreatmentGroup  treatmentGroup;
	private Treatment treatment;
	private List<TreatmentImage> beforeTreatmentImageList;
	private List<TreatmentImage> afterTreatmentImageList;
	private List<View> mViewList = new ArrayList<View>();
	private List<View> mViewList2 = new ArrayList<View>();
	private LayoutInflater mLayoutInflater;
	private ImageLoader imageLoader;
	private List<TreatmentImage> treatmentImageRemoveList = new ArrayList<TreatmentImage>();
	private List<ImageContent> treatmentImageUploadList = new ArrayList<ImageContent>();
	private Button editTreatmentTreatmentDetailBtn;
	private JSONArray    uploadImageArray = new JSONArray();
	private JSONArray    deleteImageArray = new JSONArray();
	private UserInfoApplication userinfoApplication;
	private int treatmentTypeFlag;
	private ProgressDialog progressDialog;
	private PackageUpdateUtil packageUpdateUtil;
	private DisplayImageOptions displayImageOptions;
	private Uri imageUri;
	private String groupNo;
	private int    customerID,orderEditFlag;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_edit_treatment_treatment_detail);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class EditTreatmentTreatmentDetailActivityHandler extends Handler {
		private final EditTreatmentTreatmentDetailActivity editTreatmentTreatmentDetailActivity;

		private EditTreatmentTreatmentDetailActivityHandler(EditTreatmentTreatmentDetailActivity activity) {
			WeakReference<EditTreatmentTreatmentDetailActivity> weakReference = new WeakReference<EditTreatmentTreatmentDetailActivity>(activity);
			editTreatmentTreatmentDetailActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (editTreatmentTreatmentDetailActivity.progressDialog != null) {
				editTreatmentTreatmentDetailActivity.progressDialog.dismiss();
				editTreatmentTreatmentDetailActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				for (int i = 0; i < editTreatmentTreatmentDetailActivity.beforeTreatmentImageList.size(); i++) {
					final TreatmentImage beforeTreatmentImage = editTreatmentTreatmentDetailActivity.beforeTreatmentImageList.get(i);
					final View beforeChildView = editTreatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.treatment_treatment_detail_image_view, null);
					ImageView beforeTreatmentImageView = (ImageView) beforeChildView.findViewById(R.id.treatment_detail_image);
					ImageButton beforeDelPhoto = (ImageButton) beforeChildView.findViewById(R.id.del_photo);
					editTreatmentTreatmentDetailActivity.imageLoader.displayImage(beforeTreatmentImage.getTreatmentImageURL(), beforeTreatmentImageView, editTreatmentTreatmentDetailActivity.displayImageOptions);
					beforeDelPhoto.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View view) {
							editTreatmentTreatmentDetailActivity.beforeTreatmentImageContent.removeView(beforeChildView);
							editTreatmentTreatmentDetailActivity.treatmentImageRemoveList.add(beforeTreatmentImage);
						}
					});
					editTreatmentTreatmentDetailActivity.beforeTreatmentImageContent.addView(beforeChildView);
				}
				View beforeAddNewPhoto = editTreatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.add_new_photo, null);
				ImageButton beforeAddNewImageButton = (ImageButton) beforeAddNewPhoto
						.findViewById(R.id.add_new_photo);
				beforeAddNewImageButton
						.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View view) {
								// TODO Auto-generated method stub
								if (editTreatmentTreatmentDetailActivity.treatmentImageUploadList != null && editTreatmentTreatmentDetailActivity.treatmentImageUploadList.size() >= 8) {
									DialogUtil.createMakeSureDialog(editTreatmentTreatmentDetailActivity, "温馨提示", "一次最多只能上传8张照片");
								} else {
									final CharSequence[] items = {"相册", "拍照"};
									AlertDialog dlg = new AlertDialog.Builder(
											editTreatmentTreatmentDetailActivity, R.style.CustomerAlertDialog)
											.setTitle("选择照片")
											.setItems(items, new DialogInterface.OnClickListener() {
												@Override
												public void onClick(
														DialogInterface dialog,
														int which) {
													if (which == 1) {
														Intent getImageByCamera = new Intent("android.media.action.IMAGE_CAPTURE");
														getImageByCamera.putExtra(MediaStore.EXTRA_OUTPUT, editTreatmentTreatmentDetailActivity.imageUri);
														editTreatmentTreatmentDetailActivity.startActivityForResult(getImageByCamera, 100);
														editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 1;
													} else {
														Intent getImage = new Intent(Intent.ACTION_GET_CONTENT);
														getImage.addCategory(Intent.CATEGORY_OPENABLE);
														getImage.setType("image/jpeg");
														editTreatmentTreatmentDetailActivity.startActivityForResult(getImage, 200);
														editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 2;
													}
												}
											}).create();
									dlg.show();
								}
							}
						});
				editTreatmentTreatmentDetailActivity.beforeTreatmentImageContent.addView(beforeAddNewPhoto);
				for (int i = 0; i < editTreatmentTreatmentDetailActivity.afterTreatmentImageList.size(); i++) {
					final TreatmentImage afterTreatmentImage = editTreatmentTreatmentDetailActivity.afterTreatmentImageList.get(i);
					final View afterChildView = editTreatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.treatment_treatment_detail_image_view, null);
					ImageView afterTreatmentImageView = (ImageView) afterChildView.findViewById(R.id.treatment_detail_image);
					ImageButton afterDelPhoto = (ImageButton) afterChildView.findViewById(R.id.del_photo);
					editTreatmentTreatmentDetailActivity.imageLoader.displayImage(afterTreatmentImage.getTreatmentImageURL(), afterTreatmentImageView, editTreatmentTreatmentDetailActivity.displayImageOptions);
					afterDelPhoto.setOnClickListener(new OnClickListener() {

						@Override
						public void onClick(View view) {
							editTreatmentTreatmentDetailActivity.afterTreatmentImageContent.removeView(afterChildView);
							editTreatmentTreatmentDetailActivity.treatmentImageRemoveList.add(afterTreatmentImage);
						}
					});
					editTreatmentTreatmentDetailActivity.afterTreatmentImageContent.addView(afterChildView);
				}
				View afterAddNewPhoto = editTreatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.add_new_photo, null);
				ImageButton afterAddNewImageButton = (ImageButton) afterAddNewPhoto.findViewById(R.id.add_new_photo);
				afterAddNewImageButton
						.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View view) {
								// TODO Auto-generated method stub
								if (editTreatmentTreatmentDetailActivity.treatmentImageUploadList != null && editTreatmentTreatmentDetailActivity.treatmentImageUploadList.size() >= 8) {
									DialogUtil.createMakeSureDialog(editTreatmentTreatmentDetailActivity, "温馨提示", "一次最多只能上传8张照片");
								} else {
									final CharSequence[] items = {"相册", "拍照"};
									AlertDialog dlg = new AlertDialog.Builder(
											editTreatmentTreatmentDetailActivity, R.style.CustomerAlertDialog)
											.setTitle("选择照片").setItems(items, new DialogInterface.OnClickListener() {
												@Override
												public void onClick(DialogInterface dialog, int which) {

													// 这里item是根据选择的方式，
													// 在items数组里面定义了两种方式，拍照的下标为1所以就调用拍照方法
													if (which == 1) {
														Intent getImageByCamera = new Intent("android.media.action.IMAGE_CAPTURE");
														getImageByCamera.putExtra(MediaStore.EXTRA_OUTPUT, editTreatmentTreatmentDetailActivity.imageUri);
														editTreatmentTreatmentDetailActivity.startActivityForResult(
																getImageByCamera,
																300);
														editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 3;
													} else {
														Intent getImage = new Intent(
																Intent.ACTION_GET_CONTENT);
														getImage.addCategory(Intent.CATEGORY_OPENABLE);
														getImage.setType("image/jpeg");
														editTreatmentTreatmentDetailActivity.startActivityForResult(
																getImage,
																400);
														editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 4;
													}
												}
											}).create();
									dlg.show();
								}
							}
						});
				editTreatmentTreatmentDetailActivity.afterTreatmentImageContent.addView(afterAddNewPhoto);
			} else if (msg.what == 3) {
				DialogUtil.createShortDialog(editTreatmentTreatmentDetailActivity, "服务效果更新成功！");
				Intent destIntent = null;
				Bundle bundle = new Bundle();

				if (editTreatmentTreatmentDetailActivity.groupNo != null && !"".equals(editTreatmentTreatmentDetailActivity.groupNo)) {
					destIntent = new Intent(editTreatmentTreatmentDetailActivity, TreatmentGroupDetailTabActivity.class);
					destIntent.putExtra("CustomerID", editTreatmentTreatmentDetailActivity.customerID);
					destIntent.putExtra("GroupNo", editTreatmentTreatmentDetailActivity.groupNo);
					destIntent.putExtra("orderEditFlag", editTreatmentTreatmentDetailActivity.orderEditFlag);
				} else {
					destIntent = new Intent(editTreatmentTreatmentDetailActivity, TreatmentDetailActivity.class);
					bundle.putSerializable("treatment", editTreatmentTreatmentDetailActivity.treatment);
				}
				destIntent.putExtra("current_tab", 1);
				destIntent.putExtras(bundle);
				editTreatmentTreatmentDetailActivity.startActivity(destIntent);
				editTreatmentTreatmentDetailActivity.finish();
			} else if (msg.what == 4) {
				DialogUtil.createShortDialog(
						editTreatmentTreatmentDetailActivity,
						"服务效果更新失败，请重试");
			} else if (msg.what == -1) {
				DialogUtil.createShortDialog(editTreatmentTreatmentDetailActivity, "您的网络貌似不给力，请重试");
			} else if (msg.what == 2) {
				View addNewPhoto1 = editTreatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.add_new_photo, null);
				addNewPhoto1.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						if (editTreatmentTreatmentDetailActivity.treatmentImageUploadList != null && editTreatmentTreatmentDetailActivity.treatmentImageUploadList.size() >= 8) {
							DialogUtil.createMakeSureDialog(editTreatmentTreatmentDetailActivity, "温馨提示", "一次最多只能上传8张照片");
						} else {
							final CharSequence[] items = {"相册", "拍照"};
							AlertDialog dlg = new AlertDialog.Builder(
									editTreatmentTreatmentDetailActivity, R.style.CustomerAlertDialog)
									.setTitle("选择照片")
									.setItems(items,
											new DialogInterface.OnClickListener() {
												@Override
												public void onClick(DialogInterface dialog, int which) {
													if (which == 1) {
														Intent getImageByCamera = new Intent("android.media.action.IMAGE_CAPTURE");
														getImageByCamera.putExtra(MediaStore.EXTRA_OUTPUT, editTreatmentTreatmentDetailActivity.imageUri);
														editTreatmentTreatmentDetailActivity.startActivityForResult(getImageByCamera, 100);
														editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 1;
													} else {
														Intent getImage = new Intent(Intent.ACTION_GET_CONTENT);
														getImage.addCategory(Intent.CATEGORY_OPENABLE);
														getImage.setType("image/jpeg");
														editTreatmentTreatmentDetailActivity.startActivityForResult(getImage, 200);
														editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 2;
													}
												}
											}).create();
							dlg.show();
						}
					}
				});
				editTreatmentTreatmentDetailActivity.mViewList.add(addNewPhoto1);
				View addNewPhoto2 = editTreatmentTreatmentDetailActivity.mLayoutInflater.inflate(R.xml.add_new_photo, null);
				addNewPhoto2.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						if (editTreatmentTreatmentDetailActivity.treatmentImageUploadList != null && editTreatmentTreatmentDetailActivity.treatmentImageUploadList.size() >= 8) {
							DialogUtil.createMakeSureDialog(editTreatmentTreatmentDetailActivity, "温馨提示", "一次最多只能上传8张照片");
						} else {
							final CharSequence[] items = {"相册", "拍照"};
							AlertDialog dlg = new AlertDialog.Builder(editTreatmentTreatmentDetailActivity, R.style.CustomerAlertDialog)
									.setTitle("选择照片")
									.setItems(items, new DialogInterface.OnClickListener() {
										@Override
										public void onClick(DialogInterface dialog, int which) {
											if (which == 1) {
												Intent getImageByCamera = new Intent("android.media.action.IMAGE_CAPTURE");
												getImageByCamera.putExtra(MediaStore.EXTRA_OUTPUT, editTreatmentTreatmentDetailActivity.imageUri);
												editTreatmentTreatmentDetailActivity.startActivityForResult(getImageByCamera, 300);
												editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 3;
											} else {
												Intent getImage = new Intent(Intent.ACTION_GET_CONTENT);
												getImage.addCategory(Intent.CATEGORY_OPENABLE);
												getImage.setType("image/jpeg");
												editTreatmentTreatmentDetailActivity.startActivityForResult(getImage, 400);
												editTreatmentTreatmentDetailActivity.treatmentTypeFlag = 4;
											}
										}
									}).create();
							dlg.show();
						}
					}
				});
				editTreatmentTreatmentDetailActivity.mViewList2.add(addNewPhoto2);
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(editTreatmentTreatmentDetailActivity, editTreatmentTreatmentDetailActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(editTreatmentTreatmentDetailActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + editTreatmentTreatmentDetailActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(editTreatmentTreatmentDetailActivity);
				editTreatmentTreatmentDetailActivity.packageUpdateUtil = new PackageUpdateUtil(editTreatmentTreatmentDetailActivity, editTreatmentTreatmentDetailActivity.mHandler, fileCache, downloadFileUrl, false, editTreatmentTreatmentDetailActivity.userinfoApplication);
				editTreatmentTreatmentDetailActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				editTreatmentTreatmentDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = editTreatmentTreatmentDetailActivity.getFileStreamPath(filename);
				file.getName();
				editTreatmentTreatmentDetailActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}

		}
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		beforeTreatmentImageContent = (LinearLayout) findViewById(R.id.before_treatment_image_content);
		afterTreatmentImageContent = (LinearLayout) findViewById(R.id.after_treatment_image_content);
		Intent intent=getIntent();
		groupNo=intent.getStringExtra("groupNo");
		customerID=intent.getIntExtra("CustomerID",0);
		orderEditFlag=intent.getIntExtra("orderEditFlag",orderEditFlag);
		if(groupNo==null || groupNo.equals("")){
			treatment = (Treatment)intent.getSerializableExtra("treatment");
			treatmentGroup=(TreatmentGroup)intent.getSerializableExtra("treatmentGroup");
		}
		else{
			((TextView)findViewById(R.id.treatment_treatment_detail_text)).setText("服务效果编辑");
			((TextView)findViewById(R.id.before_treatment_text)).setText("服务前照片");
			((TextView)findViewById(R.id.after_treatment_text)).setText("服务后照片");
		}
		editTreatmentTreatmentDetailBtn = (Button)findViewById(R.id.edit_treatment_treatment_detail_make_sure_btn);
		editTreatmentTreatmentDetailBtn.setOnClickListener(this);
		beforeTreatmentImageList = new ArrayList<TreatmentImage>();
		afterTreatmentImageList = new ArrayList<TreatmentImage>();
		mLayoutInflater = getLayoutInflater();
		imageUri=Uri.parse(Constant.IMAGE_FILE_LOCATION);
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				String methodName = "getServiceEffectImage";
				String endPoint = "Image";
				JSONObject getTreatmentImageJsonParam=new JSONObject();
				int screenWidth=userinfoApplication.getScreenWidth();
				try {
					if(groupNo!=null && !("".equals(groupNo))){
						getTreatmentImageJsonParam.put("GroupNo",groupNo);
					}
					else{
						getTreatmentImageJsonParam.put("TreatmentID", String.valueOf(treatment.getId()));
					}
					if (screenWidth == 720) {
						getTreatmentImageJsonParam.put("ImageThumbHeight","150");
						getTreatmentImageJsonParam.put("ImageThumbWidth","150");
					}
					else if (screenWidth ==1536) {
						getTreatmentImageJsonParam.put("ImageThumbHeight", "300");
						getTreatmentImageJsonParam.put("ImageThumbWidth", "300");
					}
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,getTreatmentImageJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson=null;
					JSONObject treatmentJson=null;
					JSONArray  beforeImageJsonArray=null;
					JSONArray  afterImageJsonArray=null;
					int code=0;
					beforeTreatmentImageList = new ArrayList<TreatmentImage>();
					afterTreatmentImageList = new ArrayList<TreatmentImage>();
					try {
						resultJson=new JSONObject(serverRequestResult);
						code=resultJson.getInt("Code");
					} catch (JSONException e) {
					}
			        if(code==1){
			        	try {
							treatmentJson=resultJson.getJSONObject("Data");
							beforeImageJsonArray=treatmentJson.getJSONArray("ImageBeforeTreatment");
							afterImageJsonArray=treatmentJson.getJSONArray("ImageAfterTreatment");
						} catch (JSONException e) {
						}
			        	if(beforeImageJsonArray!=null){
			        		for (int i = 0; i < beforeImageJsonArray.length(); i++) {
								JSONObject beforeImageJson=null;
								try {
									beforeImageJson=beforeImageJsonArray.getJSONObject(i);
								} catch (JSONException e) {
								}
								TreatmentImage beforeTreatmentImage = new TreatmentImage();
								int treatmentImageID = 0;
								String treatmentImageURL = "";
								try {
									if (beforeImageJson.has("TreatmentImageID") && !beforeImageJson.isNull("TreatmentImageID"))
										treatmentImageID = beforeImageJson.getInt("TreatmentImageID");
									if (beforeImageJson.has("ThumbnailURL") && !beforeImageJson.isNull("ThumbnailURL"))
										treatmentImageURL = beforeImageJson.getString("ThumbnailURL");
								} catch (JSONException e) {
								}
								beforeTreatmentImage.setTreatmentImageID(treatmentImageID);
								beforeTreatmentImage.setTreatmentImageURL(treatmentImageURL);
								beforeTreatmentImageList.add(beforeTreatmentImage);
							}
			        	}
			        	if(afterImageJsonArray!=null){
			        		for (int i = 0; i < afterImageJsonArray.length(); i++) {
								JSONObject afterImageJson=null;
								try {
									afterImageJson=afterImageJsonArray.getJSONObject(i);
								} catch (JSONException e) {
								}
								TreatmentImage afterTreatmentImage = new TreatmentImage();
								int treatmentImageID = 0;
								String treatmentImageURL = "";
								try {
									if (afterImageJson.has("TreatmentImageID") && !afterImageJson.isNull("TreatmentImageID"))
										treatmentImageID = afterImageJson.getInt("TreatmentImageID");
									if (afterImageJson.has("ThumbnailURL") && !afterImageJson.isNull("ThumbnailURL"))
										treatmentImageURL = afterImageJson.getString("ThumbnailURL");
								} catch (JSONException e) {
								}
								afterTreatmentImage.setTreatmentImageID(treatmentImageID);
								afterTreatmentImage.setTreatmentImageURL(treatmentImageURL);
								afterTreatmentImageList.add(afterTreatmentImage);
							}
			        	}
			        	mHandler.sendEmptyMessage(1);
			        }
			        else
			        	mHandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		if(resultCode!=RESULT_OK)
			return;
		// 调用相机
		if (requestCode == 100 || requestCode == 300) {
			if(resultCode!=RESULT_CANCELED){
				CropUtil.cropImageByCamera(this,imageUri,Constant.CROPIMAGEWIDTH,Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
			}
		}
		// 调用相册
		else if (requestCode == 200 || requestCode == 400) {
			if (data != null) {
				Uri selectedImage = data.getData();
				CropUtil.cropImageByPhoto(this,selectedImage,imageUri,Constant.CROPIMAGEWIDTH,Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
			}
		} else if (requestCode == Constant.CROP_PICTURE) {
			Bitmap myBitmap = null;
			byte[] mContent = null;
			if (imageUri != null) {
				myBitmap = CropUtil.decodeBitmapImageUri(this,imageUri);
				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				myBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
				// 压缩图片
				myBitmap = UploadImageUtil.resizeBitmap(myBitmap,Constant.RESIZEBITMAPMAXWIDTH,Constant.RESIZEBITMAPMAXWIDTH);
				if (baos != null)
					mContent = baos.toByteArray();
				switch (treatmentTypeFlag) {
				case 1:
					final View beforeChildView1 = mLayoutInflater.inflate(R.xml.treatment_treatment_detail_image_view, null);
					ImageView beforeTreatmentImageView1 = (ImageView) beforeChildView1.findViewById(R.id.treatment_detail_image);
					ImageButton beforeDelPhoto1 = (ImageButton) beforeChildView1.findViewById(R.id.del_photo);
					beforeDelPhoto1.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							// TODO Auto-generated method stub
							beforeTreatmentImageContent.removeView(beforeChildView1);
						}
					});
					beforeTreatmentImageView1.setImageBitmap(myBitmap);
					ImageContent imageContent1 = new ImageContent();
					if (mContent != null)
						imageContent1.setImageContentByte(new String(Base64Util.encode(mContent)));
					imageContent1.setImageFormat(".JPEG");
					imageContent1.setImageType(0);
					treatmentImageUploadList.add(imageContent1);
					beforeTreatmentImageContent.addView(beforeChildView1,beforeTreatmentImageContent.getChildCount() - 1);
					break;
				case 2:
					final View beforeChildView = mLayoutInflater.inflate(
							R.xml.treatment_treatment_detail_image_view, null);
					ImageView beforeTreatmentImageView = (ImageView) beforeChildView
							.findViewById(R.id.treatment_detail_image);
					ImageButton beforeDelPhoto = (ImageButton) beforeChildView
							.findViewById(R.id.del_photo);
					beforeDelPhoto.setOnClickListener(new OnClickListener() {
						
						@Override
						public void onClick(View v) {
							// TODO Auto-generated method stub
							beforeTreatmentImageContent.removeView(beforeChildView);
						}
					});
					beforeTreatmentImageView.setImageBitmap(myBitmap);
					ImageContent imageContent = new ImageContent();
					if (mContent != null)
						imageContent.setImageContentByte(new String(Base64Util
								.encode(mContent)));
					imageContent.setImageFormat(".JPEG");
					imageContent.setImageType(0);
					treatmentImageUploadList.add(imageContent);
					beforeTreatmentImageContent.addView(beforeChildView,beforeTreatmentImageContent.getChildCount() - 1);
					break;
				case 3:
					final View afterChildView3 = mLayoutInflater.inflate(
							R.xml.treatment_treatment_detail_image_view, null);
					ImageView beforeTreatmentImageView3 = (ImageView) afterChildView3
							.findViewById(R.id.treatment_detail_image);
					ImageButton beforeDelPhoto3 = (ImageButton) afterChildView3
							.findViewById(R.id.del_photo);
					beforeDelPhoto3.setOnClickListener(new OnClickListener() {
						
						@Override
						public void onClick(View v) {
							// TODO Auto-generated method stub
							afterTreatmentImageContent.removeView(afterChildView3);
						}
					});
					beforeTreatmentImageView3.setImageBitmap(myBitmap);
					ImageContent imageContent3 = new ImageContent();
					imageContent3.setImageContentByte(new String(Base64Util.encode(mContent)));
					imageContent3.setImageFormat(".JPEG");
					imageContent3.setImageType(1);
					treatmentImageUploadList.add(imageContent3);
					afterTreatmentImageContent.addView(afterChildView3,afterTreatmentImageContent.getChildCount() - 1);
					break;
				case 4:
					final View afterChildView4 = mLayoutInflater.inflate(R.xml.treatment_treatment_detail_image_view, null);
					ImageView afterTreatmentImageView4 = (ImageView) afterChildView4.findViewById(R.id.treatment_detail_image);
					ImageButton afterDelPhoto = (ImageButton) afterChildView4.findViewById(R.id.del_photo);
					afterDelPhoto.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							// TODO Auto-generated method stub
							afterTreatmentImageContent.removeView(afterChildView4);
						}
					});
					afterTreatmentImageView4.setImageBitmap(myBitmap);
					ImageContent imageContent4 = new ImageContent();
					imageContent4.setImageContentByte(new String(Base64Util.encode(mContent)));
					imageContent4.setImageFormat(".JPEG");
					imageContent4.setImageType(1);
					treatmentImageUploadList.add(imageContent4);
					afterTreatmentImageContent.addView(afterChildView4,afterTreatmentImageContent.getChildCount() - 1);
					break;
				}
			}
		}
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		if (view.getId() == R.id.edit_treatment_treatment_detail_make_sure_btn) {
			progressDialog=new ProgressDialog(this,R.style.CustomerProgressDialog);
			progressDialog.setMessage(getString(R.string.please_wait));
			progressDialog.show();
			progressDialog.setCancelable(false);
			if (treatmentImageRemoveList.size() != 0) {
				for (TreatmentImage treatmentImage : treatmentImageRemoveList) {
					JSONObject deleteImageJson=new JSONObject();
					try {
						deleteImageJson.put("ImageID",treatmentImage.getTreatmentImageID());
					} catch (JSONException e) {
						
					}
					deleteImageArray.put(deleteImageJson);
				}
			}
			if (treatmentImageUploadList != null && treatmentImageUploadList.size() != 0) {
				for (ImageContent imageContent : treatmentImageUploadList) {
					JSONObject uploadImageJson=new JSONObject();
					try {
						uploadImageJson.put("ImageType",imageContent.getImageType());
						uploadImageJson.put("ImageString",imageContent.getImageContentByte());
						uploadImageJson.put("ImageFormat",imageContent.getImageFormat());
					} catch (JSONException e) {
					}
					uploadImageArray.put(uploadImageJson);
				}
			}
			requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					String methodName = "UpdateServiceEffectImage";
					String endPoint = "Image";
					JSONObject updateTreatmentImageJsonParam=new JSONObject();
					try {
						updateTreatmentImageJsonParam.put("CustomerID",customerID);
						if(groupNo!=null && !("".equals(groupNo))){
							updateTreatmentImageJsonParam.put("GroupNo",groupNo);
						}
						else{
							updateTreatmentImageJsonParam.put("GroupNo",treatmentGroup.getTreatmentGroupID());
							updateTreatmentImageJsonParam.put("TreatmentID",treatment.getId());
						}		
						if (deleteImageArray!=null && deleteImageArray.length()!=0)
							updateTreatmentImageJsonParam.put("DeleteImage",deleteImageArray);
						if (uploadImageArray!=null && uploadImageArray.length()!=0)
							updateTreatmentImageJsonParam.put("AddImage",uploadImageArray);
					} catch (JSONException e) {
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,updateTreatmentImageJsonParam.toString(),userinfoApplication);
					if(serverRequestResult==null || serverRequestResult.equals(""))
						mHandler.sendEmptyMessage(-1);
					else
					{
						int code=0;
						JSONObject resultJson=null;
						try {
							resultJson=new JSONObject(serverRequestResult);
							code=resultJson.getInt("Code");
						} catch (JSONException e) {
						}
						if (code==1)
							mHandler.sendEmptyMessage(3);
						else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR)
							mHandler.sendEmptyMessage(code);
						else {
							mHandler.sendEmptyMessage(4);
						}
					}
				}
			};
			requestWebServiceThread.start();
		}

	}
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if(progressDialog!=null){
			progressDialog.dismiss();
			progressDialog=null;
		}
	}
}
