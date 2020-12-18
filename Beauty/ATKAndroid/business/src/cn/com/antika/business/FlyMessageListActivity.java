package cn.com.antika.business;

import android.app.NotificationManager;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.PopupWindow;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.FlyMessageListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.FlyMessage;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.minterface.RefreshListViewWithWebservice;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FaceConversionUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.RefreshListView;
import cn.com.antika.webservice.WebServiceUtil;

public class FlyMessageListActivity extends BaseActivity implements
		OnClickListener, OnItemClickListener {
	private FlyMessageListActivityHandler mHandler = new FlyMessageListActivityHandler(this);
	// JPush
	public static boolean isForeground = false;
	public static final String NEW_MESSAGE_BROADCAST_ACTION = "flyMessageListActivityNewChatMesage";
	public static final String MESSAGE_RECEIVED_ACTION = "com.example.jpushdemo.MESSAGE_RECEIVED_ACTION";
	public static final String KEY_TITLE = "title";
	public static final String KEY_MESSAGE = "message";
	public static final String KEY_EXTRAS = "extras";
	private MessageRecevice messageRecevice;
	private IntentFilter filter;
	private RefreshListView flyMessageListView;
	private ProgressDialog progressDialog;
	private Thread requestWebServiceThread;
	private int accountType = 1;
	private List<FlyMessage> flyMessageList;
	private PopupWindow popupWindow;
	private ImageButton sendFlyMessageChooseToUser;
	private UserInfoApplication userinfoApplication;
	private RefreshListViewWithWebservice refreshListViewWithWebService;
	private FlyMessageListAdapter flyMessageListAdapter;
	private NotificationManager notificationManager;
	private static Integer APP_ICON = null;
	private PackageUpdateUtil packageUpdateUtil;

	private static class FlyMessageListActivityHandler extends Handler {
		private final FlyMessageListActivity flyMessageListActivity;

		private FlyMessageListActivityHandler(FlyMessageListActivity activity) {
			WeakReference<FlyMessageListActivity> weakReference = new WeakReference<FlyMessageListActivity>(activity);
			flyMessageListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (flyMessageListActivity.progressDialog != null) {
				flyMessageListActivity.progressDialog.dismiss();
				flyMessageListActivity.progressDialog = null;
			}
			if (message.what == 1) {
				if (flyMessageListActivity.flyMessageList != null && flyMessageListActivity.flyMessageList.size() != 0) {
					flyMessageListActivity.flyMessageListAdapter = new FlyMessageListAdapter(flyMessageListActivity, flyMessageListActivity.flyMessageList);
					flyMessageListActivity.flyMessageListView.setAdapter(flyMessageListActivity.flyMessageListAdapter);
				}
			} else if (message.what == 2)
				DialogUtil.createShortDialog(flyMessageListActivity,
						"您的网络貌似不给力，请重试");
			else if (message.what == 4) {
				if (flyMessageListActivity.requestWebServiceThread == null) {
					flyMessageListActivity.requestWebService(flyMessageListActivity.accountType);
				}
			} else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(flyMessageListActivity, flyMessageListActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(flyMessageListActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + flyMessageListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(flyMessageListActivity);
				flyMessageListActivity.packageUpdateUtil = new PackageUpdateUtil(flyMessageListActivity, flyMessageListActivity.mHandler, fileCache, downloadFileUrl, false, flyMessageListActivity.userinfoApplication);
				flyMessageListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				flyMessageListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = flyMessageListActivity.getFileStreamPath(filename);
				file.getName();
				flyMessageListActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (flyMessageListActivity.requestWebServiceThread != null) {
				flyMessageListActivity.requestWebServiceThread.interrupt();
				flyMessageListActivity.requestWebServiceThread = null;
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_fly_message_list);
		userinfoApplication = UserInfoApplication.getInstance();
		FaceConversionUtil.getInstace().getFileText(getApplication());
		boolean isFromJpush = getIntent().getBooleanExtra("FromJpush", false);
		if (isFromJpush) {
			if (userinfoApplication.getAccountInfo() != null
					&& userinfoApplication.getAccountInfo().getAccountId() != 0)
				initView(accountType);
			else
				finish();
		} else
			initView(accountType);
	}

	protected void initView(final int accountType) {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		flyMessageListView = (RefreshListView) findViewById(R.id.fly_message_list);
		flyMessageListView.setOnItemClickListener(this);
		refreshListViewWithWebService = new RefreshListViewWithWebservice() {

			@Override
			public Object refreshing() {
				// TODO Auto-generated method stub
				String returncode = "ok";
				if (requestWebServiceThread == null) {
					requestWebService(accountType);
				}
				return returncode;
			}

			@Override
			public void refreshed(Object obj) {

			}

		};
		flyMessageListView.setOnRefreshListener(refreshListViewWithWebService);
		sendFlyMessageChooseToUser = (ImageButton) findViewById(R.id.send_fly_message_choose_touser);
		sendFlyMessageChooseToUser.setOnClickListener(this);
		progressDialog = new ProgressDialog(this,
				R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		requestWebService(accountType);
	}

	protected void requestWebService(int accountType) {
		flyMessageList = new ArrayList<FlyMessage>();
		final int at = accountType;
		final int screenWidth = userinfoApplication.getScreenWidth();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "getContactListForAccount";
				String endPoint = "message";
				JSONObject flyMessageListJsonParam=new JSONObject();
				try {
					if (screenWidth == 720) {
						flyMessageListJsonParam.put("ImageWidth",100);
						flyMessageListJsonParam.put("ImageHeight",100);
					} else if (screenWidth == 480) {
						flyMessageListJsonParam.put("ImageWidth",60);
						flyMessageListJsonParam.put("ImageHeight",60);
					} else if (screenWidth == 1080) {
						flyMessageListJsonParam.put("ImageWidth", 120);
						flyMessageListJsonParam.put("ImageHeight", 120);
					} else if (screenWidth == 1536) {
						flyMessageListJsonParam.put("ImageWidth", 180);
						flyMessageListJsonParam.put("ImageHeight", 180);
					} else {
						flyMessageListJsonParam.put("ImageWidth",60);
						flyMessageListJsonParam.put("ImageHeight",60);
					}
				} catch (JSONException e) {
				}
				String  serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,flyMessageListJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONArray  flyMessageListJsonArray=null;
					int code=0;
					try {
						JSONObject flyMessageListJson=new JSONObject(serverRequestResult);
						code=flyMessageListJson.getInt("Code");
						flyMessageListJsonArray=flyMessageListJson.getJSONArray("Data");
					} catch (JSONException e) {
					}
					if(code==1){
						if(flyMessageListJsonArray!=null){
							for(int i=0;i<flyMessageListJsonArray.length();i++){
								FlyMessage flyMessage = new FlyMessage();
								String newMessageCount = "0";
								boolean available = true;
								String customerID = "0";
								String customerName = "";
								String lastMessageContent = "";
								String lastSendTime = "";
								String headImageUrl = "";
								try {
									JSONObject flyMessageJson=flyMessageListJsonArray.getJSONObject(i);
									
									if(flyMessageJson.has("NewMessageCount") && !flyMessageJson.isNull("NewMessageCount"))
										newMessageCount=flyMessageJson.getString("NewMessageCount");
									if(flyMessageJson.has("Available") && !flyMessageJson.isNull("Available"))
										available=flyMessageJson.getBoolean("Available");
									if(flyMessageJson.has("CustomerID") && !flyMessageJson.isNull("CustomerID"))
										customerID=flyMessageJson.getString("CustomerID");
									if(flyMessageJson.has("CustomerName") && !flyMessageJson.isNull("CustomerName"))
										customerName=flyMessageJson.getString("CustomerName");
									if(flyMessageJson.has("MessageContent") && !flyMessageJson.isNull("MessageContent"))
										lastMessageContent=flyMessageJson.getString("MessageContent");
									if(flyMessageJson.has("SendTime") && !flyMessageJson.isNull("SendTime"))
										lastSendTime=flyMessageJson.getString("SendTime");
									if(flyMessageJson.has("HeadImageURL") && !flyMessageJson.isNull("HeadImageURL"))
										headImageUrl=flyMessageJson.getString("HeadImageURL");
								} catch (JSONException e) {
									
								}
								flyMessage.setNewMessageCount(Integer.parseInt(newMessageCount));
								if(available)
									flyMessage.setAvailable(1);
								else
									flyMessage.setAvailable(0);
								flyMessage.setCustomerID(Integer.parseInt(customerID));
								flyMessage.setCustomerName(customerName);
								flyMessage.setLastMessageContent(lastMessageContent);
								flyMessage.setLastSendTime(lastSendTime);
								flyMessage.setHeadImageUrl(headImageUrl);
								flyMessageList.add(flyMessage);
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

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch (view.getId()) {
		case R.id.send_fly_message_choose_touser:
			Intent destIntent = new Intent(this, ChoosePersonActivity.class);
			Bundle bundle = new Bundle();
			bundle.putString("personRole", "Customer");
			bundle.putString("checkModel", "Multi");
			bundle.putString("messageType", "FlyMessage");
			destIntent.putExtra("mustSelectOne",true);
			destIntent.putExtras(bundle);
			startActivity(destIntent);
			break;
		case R.id.fly_message_my_customer:
			requestWebService(1);
			popupWindow.dismiss();
			break;
		case R.id.fly_message_branch_customer:
			requestWebService(2);
			popupWindow.dismiss();
			break;
		case R.id.fly_message_company_customer:
			requestWebService(3);
			popupWindow.dismiss();
			break;
		case R.id.fly_message_cancel_btn:
			popupWindow.dismiss();
			break;
		}
	}
	@Override
	public void onItemClick(AdapterView<?> adapterView, View view,
			int position, long id) {
		if (position != 0) {
			if (flyMessageList != null && flyMessageList.size() != 0) {
				StringBuilder toUsersName = new StringBuilder();
				StringBuilder toUsersID = new StringBuilder();
				toUsersName.append(userinfoApplication
						.getSelectedCustomerName() + ",");
				toUsersID.append(userinfoApplication.getSelectedCustomerID()
						+ ",");
				Intent destIntent = new Intent(this,
						FlyMessageDetailActivity.class);
				FlyMessage flyMessage = flyMessageList.get(position - 1);
				Bundle bundle = new Bundle();
				bundle.putSerializable("flyMessage", flyMessage);
				destIntent.putExtras(bundle);
				destIntent.putExtra("Des", "Detail");
				destIntent.putExtra("Source", "List");
				startActivity(destIntent);
			}
		}
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
		isForeground = true;
		if (messageRecevice == null)
			messageRecevice = new MessageRecevice();

		if (filter == null) {
			filter = new IntentFilter();
			filter.addAction(NEW_MESSAGE_BROADCAST_ACTION);
		}
		this.registerReceiver(messageRecevice, filter);

	}

	@Override
	protected void onPause() {
		super.onPause();
		isForeground = false;
		unregisterReceiver(messageRecevice);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		String isExit = intent.getStringExtra("exit");
		if (isExit != null && isExit.equals("1")) {
			userinfoApplication.setAccountInfo(null);
			userinfoApplication.setSelectedCustomerID(0);
			userinfoApplication.setSelectedCustomerName("");
			userinfoApplication.setSelectedCustomerHeadImageURL("");
			userinfoApplication.setSelectedCustomerLoginMobile("");
			userinfoApplication.setOrderInfo(null);
			userinfoApplication.setAccountNewMessageCount(0);
			Constant.formalFlag = 0;
			finish();
		} else {
			if (APP_ICON == null) {
				try {
					PackageManager pm = getPackageManager();
					PackageInfo pi = null;
					pi = pm.getPackageInfo(getPackageName(), 0);
					APP_ICON = pi.applicationInfo.icon;
				} catch (Exception e) {
					APP_ICON = 0; // failed, ignored
				}
			}
			if (notificationManager == null)
				notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
			notificationManager.cancel(APP_ICON);

		}
	}

	public class MessageRecevice extends BroadcastReceiver {

		@Override
		public void onReceive(Context arg0, Intent arg1) {
			// TODO Auto-generated method stub
			mHandler.obtainMessage(4).sendToTarget();
		}

	}
}
