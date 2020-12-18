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
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.FlyMessage;
import cn.com.antika.bean.MessageTemplate;
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
public class EditMessageTemplateActivity extends BaseActivity implements
		OnClickListener {
	private EditMessageTemplateActivityHandler mHandler = new EditMessageTemplateActivityHandler(this);
	private EditText templateTitleText;
	private Spinner templateTypeSpinner;
	private EditText templateContentText;
	private ProgressDialog progressDialog;
	private Thread requestWebServiceThread;
	private Button editTemplateBtn,deleteTemplateBtn;
	private MessageTemplate messageTemplate;
	private UserInfoApplication userinfoApplication;
	private String       fromSource;
	private String       des;
	private FlyMessage flyMessage;
	private String             toUsersID;
	private String             toUserName;
	private Timer              dialogTimer;
	private PackageUpdateUtil packageUpdateUtil;

	private static class EditMessageTemplateActivityHandler extends Handler {
		private final EditMessageTemplateActivity editMessageTemplateActivity;

		private EditMessageTemplateActivityHandler(EditMessageTemplateActivity activity) {
			WeakReference<EditMessageTemplateActivity> weakReference = new WeakReference<EditMessageTemplateActivity>(activity);
			editMessageTemplateActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (editMessageTemplateActivity.progressDialog != null) {
				editMessageTemplateActivity.progressDialog.dismiss();
				editMessageTemplateActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				AlertDialog alertDialog = DialogUtil.createShortShowDialog(editMessageTemplateActivity, "提示信息", "模板信息编辑成功！");
				alertDialog.show();
				Intent destIntent = new Intent(editMessageTemplateActivity, SendMarketingTemplateActivity.class);
				Bundle bundle = new Bundle();
				bundle.putSerializable("flyMessage", editMessageTemplateActivity.flyMessage);
				destIntent.putExtras(bundle);
				destIntent.putExtra("Des", editMessageTemplateActivity.des);
				destIntent.putExtra("FROMSOURCE", editMessageTemplateActivity.fromSource);
				destIntent.putExtra("toUsersID", editMessageTemplateActivity.toUsersID);
				destIntent.putExtra("toUsersName", editMessageTemplateActivity.toUserName);
				editMessageTemplateActivity.dialogTimer = new Timer();
				DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editMessageTemplateActivity.dialogTimer, editMessageTemplateActivity, destIntent);
				editMessageTemplateActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
			} else if (msg.what == 0) {
				DialogUtil.createShortDialog(editMessageTemplateActivity, (String) msg.obj);
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(editMessageTemplateActivity, "您的网络貌似不给力，请重试");
			else if (msg.what == 3) {
				AlertDialog alertDialog = DialogUtil.createShortShowDialog(editMessageTemplateActivity, "提示信息", "模板删除成功!");
				alertDialog.show();
				Intent destIntent = new Intent(editMessageTemplateActivity, SendMarketingTemplateActivity.class);
				Bundle bundle = new Bundle();
				bundle.putSerializable("flyMessage", editMessageTemplateActivity.flyMessage);
				destIntent.putExtras(bundle);
				destIntent.putExtra("Des", editMessageTemplateActivity.des);
				destIntent.putExtra("FROMSOURCE", editMessageTemplateActivity.fromSource);
				destIntent.putExtra("toUsersID", editMessageTemplateActivity.toUsersID);
				destIntent.putExtra("toUsersName", editMessageTemplateActivity.toUserName);
				editMessageTemplateActivity.dialogTimer = new Timer();
				DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editMessageTemplateActivity.dialogTimer, editMessageTemplateActivity, destIntent);
				editMessageTemplateActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(editMessageTemplateActivity, editMessageTemplateActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(editMessageTemplateActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + editMessageTemplateActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(editMessageTemplateActivity);
				editMessageTemplateActivity.packageUpdateUtil = new PackageUpdateUtil(editMessageTemplateActivity, editMessageTemplateActivity.mHandler, fileCache, downloadFileUrl, false, editMessageTemplateActivity.userinfoApplication);
				editMessageTemplateActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				editMessageTemplateActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = editMessageTemplateActivity.getFileStreamPath(filename);
				file.getName();
				editMessageTemplateActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (editMessageTemplateActivity.requestWebServiceThread != null) {
				editMessageTemplateActivity.requestWebServiceThread.interrupt();
				editMessageTemplateActivity.requestWebServiceThread = null;
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_edit_message_template);
		userinfoApplication = UserInfoApplication.getInstance();
		Intent intent=getIntent();
		flyMessage = (FlyMessage) intent.getSerializableExtra("flyMessage");
		des = intent.getStringExtra("Des");
		fromSource=intent.getStringExtra("FROMSOURCE");
		toUsersID=intent.getStringExtra("toUsersID");
		toUserName=intent.getStringExtra("toUsersName");
		initView();
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		templateTitleText = (EditText) findViewById(R.id.template_title);
		templateContentText = (EditText) findViewById(R.id.template_content);
		templateTypeSpinner = (Spinner) findViewById(R.id.template_type_spinner);
		messageTemplate = (MessageTemplate) getIntent().getSerializableExtra("template");
		editTemplateBtn = (Button) findViewById(R.id.edit_template_make_sure_btn);
		deleteTemplateBtn = (Button) findViewById(R.id.delete_template_btn);
		editTemplateBtn.setOnClickListener(this);
		deleteTemplateBtn.setOnClickListener(this);
		if (messageTemplate != null) {
			templateTitleText.setText(messageTemplate.getSubject());
			templateContentText.setText(messageTemplate.getTemplateContent());
			ArrayAdapter<String> templateTypeAdapter=new ArrayAdapter<String>(this,R.xml.spinner_checked_text,new String[] { "个人", "公用" });
			templateTypeSpinner.setAdapter(templateTypeAdapter);
			templateTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
			if (messageTemplate.getTemplateType() == 0)
				templateTypeSpinner.setSelection(1);
			else if (messageTemplate.getTemplateType() == 1)
				templateTypeSpinner.setSelection(0);
		}
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		switch (view.getId()) {
		case R.id.edit_template_make_sure_btn:
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
			else{
				progressDialog.setMessage(getString(R.string.please_wait));
				progressDialog.show();
				requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						int templateTypeValue = 0;
						if (templateType.equals("个人"))
							templateTypeValue = 1;
						String methodName = "updateTemplate";
						String endPoint = "Template";
						JSONObject updateTemplateJsonParam=new JSONObject();
						try {
							updateTemplateJsonParam.put("TemplateID",messageTemplate.getTemplateID());
							updateTemplateJsonParam.put("Subject", templateTitie);
							updateTemplateJsonParam.put("TemplateContent",templateContent);
							updateTemplateJsonParam.put("TemplateType",templateTypeValue);
						} catch (JSONException e) {
						}
						String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,updateTemplateJsonParam.toString(),userinfoApplication);
						if (serverRequestResult == null || serverRequestResult.equals(""))
							mHandler.sendEmptyMessage(2);
						else {
							int code=0;
							JSONObject resultJson=null;
							String     message="";
							try {
								resultJson=new JSONObject(serverRequestResult);
								code=resultJson.getInt("Code");
								message=resultJson.getString("Message");
							} catch (JSONException e) {
							}
							if (code==1)
								mHandler.sendEmptyMessage(3);
							else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR)
								mHandler.sendEmptyMessage(code);
							else{
								Message msg=new Message();
								msg.what=0;
								msg.obj=message;
								mHandler.sendEmptyMessage(0);
							}
						}
					}
				};
				requestWebServiceThread.start();
			}
			break;
		case R.id.delete_template_btn:
			progressDialog.setMessage(getString(R.string.please_wait));
			progressDialog.show();
			requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					String methodName = "deleteTemplate";
					String endPoint = "Template";
					JSONObject deleteTemplateJsonParam=new JSONObject();
					try {
						deleteTemplateJsonParam.put("TemplateID", messageTemplate.getTemplateID());
					} catch (JSONException e) {
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,deleteTemplateJsonParam.toString(),userinfoApplication);
					if (serverRequestResult == null || serverRequestResult.equals(""))
						mHandler.sendEmptyMessage(2);
					else {
						int code=0;
						JSONObject resultJson=null;
						String     message="";
						try {
							resultJson=new JSONObject(serverRequestResult);
							code=resultJson.getInt("Code");
							message=resultJson.getString("Message");
						} catch (JSONException e) {
						}
						if (code==1)
							mHandler.sendEmptyMessage(3);
						else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR)
							mHandler.sendEmptyMessage(code);
						else{
							Message msg=new Message();
							msg.what=0;
							msg.obj=message;
							mHandler.sendMessage(msg);
						}	
					}
				}
			};
			requestWebServiceThread.start();
			break;
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
