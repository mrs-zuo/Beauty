package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Spinner;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.FlyMessage;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.timer.DialogTimerTask;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class AddMessageTemplateActivity extends BaseActivity implements
		OnClickListener {
	private AddMessageTemplateActivityHandler mHandler = new AddMessageTemplateActivityHandler(this);
	private EditText templateTitleText;
	private Spinner templateTypeSpinner;
	private EditText templateContentText;
	private ImageButton addTemplateMakeSureBtn;
	private ProgressDialog progressDialog;
	private Thread requestWebServiceThread;
	private UserInfoApplication userinfoApplication;
	private String       fromSource;
	private FlyMessage flyMessage;
	private String      des;
	private String             toUsersID;
	private String             toUserName;
	private Timer              dialogTimer;
	private PackageUpdateUtil packageUpdateUtil;

	private static class AddMessageTemplateActivityHandler extends Handler {
		private final AddMessageTemplateActivity addMessageTemplateActivity;

		private AddMessageTemplateActivityHandler(AddMessageTemplateActivity activity) {
			WeakReference<AddMessageTemplateActivity> weakReference = new WeakReference<AddMessageTemplateActivity>(activity);
			addMessageTemplateActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (addMessageTemplateActivity.progressDialog != null) {
				addMessageTemplateActivity.progressDialog.dismiss();
				addMessageTemplateActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				AlertDialog alertDialog = DialogUtil.createShortShowDialog(addMessageTemplateActivity, "提示信息", "添加模板信息成功！");
				alertDialog.show();
				Intent destIntent = new Intent(addMessageTemplateActivity,
						SendMarketingTemplateActivity.class);
				Bundle bundle = new Bundle();
				bundle.putSerializable("flyMessage", addMessageTemplateActivity.flyMessage);
				destIntent.putExtras(bundle);
				destIntent.putExtra("Des", addMessageTemplateActivity.des);
				destIntent.putExtra("FROMSOURCE", addMessageTemplateActivity.fromSource);
				destIntent.putExtra("toUsersID", addMessageTemplateActivity.toUsersID);
				destIntent.putExtra("toUsersName", addMessageTemplateActivity.toUserName);
				addMessageTemplateActivity.dialogTimer = new Timer();
				DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, addMessageTemplateActivity.dialogTimer, addMessageTemplateActivity, destIntent);
				addMessageTemplateActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
			} else if (msg.what == 0)
				DialogUtil.createShortDialog(addMessageTemplateActivity,
						"模板信息添加失败！");
			else if (msg.what == 2)
				DialogUtil.createShortDialog(addMessageTemplateActivity, "您的网络貌似不给力，请重试!");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(addMessageTemplateActivity, addMessageTemplateActivity.getString(R.string.login_error_message));
				addMessageTemplateActivity.userinfoApplication.exitForLogin(addMessageTemplateActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + addMessageTemplateActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(addMessageTemplateActivity);
				addMessageTemplateActivity.packageUpdateUtil = new PackageUpdateUtil(addMessageTemplateActivity, addMessageTemplateActivity.mHandler, fileCache, downloadFileUrl, false, addMessageTemplateActivity.userinfoApplication);
				addMessageTemplateActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				addMessageTemplateActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = addMessageTemplateActivity.getFileStreamPath(filename);
				file.getName();
				addMessageTemplateActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (addMessageTemplateActivity.requestWebServiceThread != null) {
				addMessageTemplateActivity.requestWebServiceThread.interrupt();
				addMessageTemplateActivity.requestWebServiceThread = null;
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_add_message_template);
		fromSource=getIntent().getStringExtra("FROMSOURCE");
		Intent intent=getIntent();
		flyMessage = (FlyMessage) intent
				.getSerializableExtra("flyMessage");
		des = intent.getStringExtra("Des");
		toUsersID=intent.getStringExtra("toUsersID");
		toUserName=intent.getStringExtra("toUsersName");
		initView();
	}
	protected void initView() {
		templateTitleText = (EditText) findViewById(R.id.template_title);
		templateTypeSpinner = (Spinner) findViewById(R.id.template_type_spinner);
		templateContentText = (EditText) findViewById(R.id.template_content);
		ArrayAdapter<String> templateTypeAdapter=new ArrayAdapter<String>(this,
				R.xml.spinner_checked_text,new String[] { "个人", "公用" });
		templateTypeSpinner.setAdapter(templateTypeAdapter);
		templateTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		addTemplateMakeSureBtn = (ImageButton) findViewById(R.id.add_template_make_sure_btn);
		addTemplateMakeSureBtn.setOnClickListener(this);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		userinfoApplication=UserInfoApplication.getInstance();
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		if (view.getId() == R.id.add_template_make_sure_btn) {
			final String templateTitie = templateTitleText.getText().toString();
			final String templateType = templateTypeSpinner.getSelectedItem()
					.toString();
			final String templateContent = templateContentText.getText()
					.toString();
			if (templateTitie == null || ("").equals(templateTitie))
				DialogUtil.createMakeSureDialog(this, "提示信息", "消息主题不能为空！");
			else if (templateContent == null || ("").equals(templateContent))
				DialogUtil.createMakeSureDialog(this, "提示信息", "消息内容不能为空！");
			else if (templateType == null || ("").equals(templateType))
				DialogUtil.createMakeSureDialog(this, "提示信息", "消息类型不能为空！");
			else {
				progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
				progressDialog.setMessage(getString(R.string.please_wait));
				progressDialog.show();
				requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						int templateTypeValue = 0;
						if (templateType.equals("个人"))
							templateTypeValue = 1;
						String methodName = "addTemplate";
						String endPoint = "Template";
						JSONObject addTemplateJsonParam=new JSONObject();
						try {
							addTemplateJsonParam.put("Subject", templateTitie);
							addTemplateJsonParam.put("TemplateContent",templateContent);
							addTemplateJsonParam.put("TemplateType",templateTypeValue);
						} catch (JSONException e) {
						}
						String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,addTemplateJsonParam.toString(),userinfoApplication);
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
								mHandler.sendEmptyMessage(1);
							else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
								mHandler.sendEmptyMessage(code);
							else
								mHandler.sendEmptyMessage(0);
						}
					}
				};
				requestWebServiceThread.start();
			}
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
		System.gc();
	}
}
