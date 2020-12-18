package com.GlamourPromise.Beauty.Business;

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
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
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

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Timer;

public class EditPersonalMessageActivity extends BaseActivity implements
		OnClickListener {
	private EditPersonalMessageActivityHandler mHandler = new EditPersonalMessageActivityHandler(this);
	private ImageView personalHeadImageView;
	private ImageLoader imageLoader;
	private RelativeLayout editPersonalPasswordRelativeLayout;
	private String personalMessageHeadImageBase64;
	private Button editPersonalMessageMakeSureBtn;
	private Thread requestWebServiceThread;
	private ProgressDialog progressDialog;
	private UserInfoApplication userinfoApplication;
	private Timer               dialogTimer;
	private PackageUpdateUtil packageUpdateUtil;
	private DisplayImageOptions displayImageOptions;
	private Uri imageUri;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_edit_personal_message);
		userinfoApplication = UserInfoApplication.getInstance();
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		personalHeadImageView = (ImageView) findViewById(R.id.personal_message_headimage);
		personalHeadImageView.setOnClickListener(this);
		String psersonalHeadImage = userinfoApplication.getAccountInfo().getHeadImage();
		imageLoader.displayImage(psersonalHeadImage, personalHeadImageView,displayImageOptions);
		editPersonalPasswordRelativeLayout = (RelativeLayout) findViewById(R.id.edit_personal_password_relativelayout);
		editPersonalPasswordRelativeLayout.setOnClickListener(this);
		editPersonalMessageMakeSureBtn = (Button) findViewById(R.id.edit_personal_message_make_sure_btn);
		editPersonalMessageMakeSureBtn.setOnClickListener(this);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		imageUri=Uri.parse(Constant.IMAGE_FILE_LOCATION);
	}

	private static class EditPersonalMessageActivityHandler extends Handler {
		private final EditPersonalMessageActivity editPersonalMessageActivity;

		private EditPersonalMessageActivityHandler(EditPersonalMessageActivity activity) {
			WeakReference<EditPersonalMessageActivity> weakReference = new WeakReference<EditPersonalMessageActivity>(activity);
			editPersonalMessageActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (editPersonalMessageActivity.progressDialog != null) {
				editPersonalMessageActivity.progressDialog.dismiss();
				editPersonalMessageActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				AlertDialog alertDialog = DialogUtil.createShortShowDialog(editPersonalMessageActivity, "提示信息", "个人信息修改成功！");
				alertDialog.show();
				Intent destIntent = new Intent(editPersonalMessageActivity, SettingActivity.class);
				editPersonalMessageActivity.dialogTimer = new Timer();
				DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editPersonalMessageActivity.dialogTimer, editPersonalMessageActivity, destIntent);
				editPersonalMessageActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
			} else if (msg.what == 0) {
				DialogUtil.createMakeSureDialog(
						editPersonalMessageActivity, "提示信息", "操作失败，请重试！");
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(editPersonalMessageActivity,
						"您的网络貌似不给力，请重试");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(editPersonalMessageActivity, editPersonalMessageActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(editPersonalMessageActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + editPersonalMessageActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(editPersonalMessageActivity);
				editPersonalMessageActivity.packageUpdateUtil = new PackageUpdateUtil(editPersonalMessageActivity, editPersonalMessageActivity.mHandler, fileCache, downloadFileUrl, false, editPersonalMessageActivity.userinfoApplication);
				editPersonalMessageActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				editPersonalMessageActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = editPersonalMessageActivity.getFileStreamPath(filename);
				file.getName();
				editPersonalMessageActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (editPersonalMessageActivity.requestWebServiceThread != null) {
				editPersonalMessageActivity.requestWebServiceThread.interrupt();
				editPersonalMessageActivity.requestWebServiceThread = null;
			}
		}
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch (view.getId()) {
		case R.id.edit_personal_password_relativelayout:
			Intent destIntent = new Intent(this,EditPersonalPasswordActivity.class);
			startActivity(destIntent);
			break;
		case R.id.personal_message_headimage:
			final CharSequence[] items = { "相册", "拍照" };
			AlertDialog dlg = new AlertDialog.Builder(this,R.style.CustomerAlertDialog).setTitle("选择照片").setItems(items, new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog,
								int which) {
							// 在items数组里面定义了两种方式，拍照的下标为1所以就调用拍照方法
							if (which == 1) {
								Intent getImageByCamera = new Intent("android.media.action.IMAGE_CAPTURE");
								getImageByCamera.putExtra(MediaStore.EXTRA_OUTPUT,imageUri);
								startActivityForResult(getImageByCamera,1);
							} else {
								Intent getImage = new Intent(Intent.ACTION_GET_CONTENT);
								getImage.addCategory(Intent.CATEGORY_OPENABLE);
								getImage.setType("image/jpeg");
								startActivityForResult(getImage,0);
							}
						}
					}).create();
			dlg.show();
		
			if (!dlg.isShowing()) {
				dlg.show();
			}
			break;
		case R.id.edit_personal_message_make_sure_btn:
			if(personalMessageHeadImageBase64==null || "".equals(personalMessageHeadImageBase64))
				DialogUtil.createShortDialog(this,"请选择一张图片！");
			else{
				progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
				progressDialog.setMessage(getString(R.string.please_wait));
				progressDialog.show();
				requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						String methodName = "updateUserHeadImage";
						String endPoint = "image";
						JSONObject updateUserHeadImageJsonParam=new JSONObject();
						try {
							updateUserHeadImageJsonParam.put("UserID", String.valueOf(userinfoApplication.getAccountInfo().getAccountId()));
							updateUserHeadImageJsonParam.put("UserType",1);
							if (personalMessageHeadImageBase64 != null && !(("").equals(personalMessageHeadImageBase64))) {
								updateUserHeadImageJsonParam.put("ImageString",personalMessageHeadImageBase64);
								updateUserHeadImageJsonParam.put("ImageType", ".JPEG");
							}
							int screenWidth=userinfoApplication.getScreenWidth();
							int screenHeight=userinfoApplication.getScreenHeight();
							if(screenWidth==720 && screenHeight==1280){
								updateUserHeadImageJsonParam.put("ImageWidth", "160");
								updateUserHeadImageJsonParam.put("ImageHeight", "160");
							}
						} catch (JSONException e) {
						}
						String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,updateUserHeadImageJsonParam.toString(),userinfoApplication);
						if (serverRequestResult == null || serverRequestResult.equals(""))
							mHandler.sendEmptyMessage(2);
						else {
							int code=0;
							JSONObject resultJson=null;
							try {
								resultJson=new JSONObject(serverRequestResult);
								code=resultJson.getInt("Code");
							} catch (JSONException e) {
							}
							if (code==1)
							{
								String businessHeadImageUrl ="";
								try {
									businessHeadImageUrl= resultJson.getString("Data");
								} catch (JSONException e) {
								}
								userinfoApplication.getAccountInfo().setHeadImage(businessHeadImageUrl);
								userinfoApplication.setAccountHeadImage(businessHeadImageUrl);
								mHandler.sendEmptyMessage(1);
							}
							else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR)
								mHandler.sendEmptyMessage(code);
							else
								mHandler.sendEmptyMessage(0);
						}
					}
				};
				requestWebServiceThread.start();
			}	
			break;
		}
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if(resultCode!=RESULT_OK)
			return;
		Bitmap myBitmap = null;
		byte[] mContent = null;
		if (requestCode == 0 && resultCode==RESULT_OK) {
			try {
				if (data != null) {
					Uri selectedImage = data.getData();
					CropUtil.cropImageByPhoto(this,selectedImage,imageUri,Constant.CROPIMAGEWIDTH,Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		// 拍照获取图片
		else if (requestCode == 1 && resultCode==RESULT_OK) {
			CropUtil.cropImageByCamera(this,imageUri,Constant.CROPIMAGEWIDTH,Constant.CROPIMAGEHEIGHT, Constant.CROP_PICTURE);
		} else if (requestCode == Constant.CROP_PICTURE) {
			if (imageUri != null) {
				myBitmap = CropUtil.decodeBitmapImageUri(this,imageUri);
				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				myBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
				// 压缩图片
				myBitmap = UploadImageUtil.resizeBitmap(myBitmap,Constant.RESIZEBITMAPMAXWIDTH,Constant.RESIZEBITMAPMAXWIDTH);
				if (baos != null)
					mContent = baos.toByteArray();
				personalHeadImageView.setImageBitmap(myBitmap);
			}
			if (mContent != null)
				personalMessageHeadImageBase64 = new String(Base64Util.encode(mContent));
		}
	}

	// 图片裁剪
	public void cropImage(Uri uri, int outputX, int outputY, int requestCode) {
		// 裁剪图片意图
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(uri, "image/*");
		intent.putExtra("crop", "true");
		// 裁剪框的比例，1：1
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		// 裁剪后输出图片的尺寸大小
		intent.putExtra("outputX", outputX);
		intent.putExtra("outputY", outputY);
		// 图片格式
		intent.putExtra("outputFormat", "JPEG");
		intent.putExtra("noFaceDetection", true);
		intent.putExtra("return-data", true);
		startActivityForResult(intent, requestCode);
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
