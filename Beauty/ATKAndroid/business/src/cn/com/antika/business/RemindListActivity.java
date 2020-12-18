package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.RemindListItemAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.RemindInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.minterface.RefreshListViewWithWebservice;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.RefreshListView;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 提醒页面  服务提醒  回访提醒 和生日提醒
 * */
public class RemindListActivity extends BaseActivity implements
		OnItemClickListener {
	private RemindListActivityHandler mHandler = new RemindListActivityHandler(this);
	private RefreshListView remindListView;
	private Thread requestWebServiceThread;
	private List<RemindInfo> remindList;
	private ProgressDialog progressDialog;
	private UserInfoApplication userinfoApplication;
	private RemindListItemAdapter remindListItemAdapter;
	private PackageUpdateUtil packageUpdateUtil;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_remind_list);
		remindListView = (RefreshListView) findViewById(R.id.remind_list_view);
		remindListView.setOnItemClickListener(this);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class RemindListActivityHandler extends Handler {
		private final RemindListActivity remindListActivity;

		private RemindListActivityHandler(RemindListActivity activity) {
			WeakReference<RemindListActivity> weakReference = new WeakReference<RemindListActivity>(activity);
			remindListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (remindListActivity.progressDialog != null) {
				remindListActivity.progressDialog.dismiss();
				remindListActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				remindListActivity.remindListItemAdapter = new RemindListItemAdapter(remindListActivity, remindListActivity.remindList);
				remindListActivity.remindListView.setAdapter(remindListActivity.remindListItemAdapter);
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(remindListActivity,
						"您的网络貌似不给力，请重试！");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(remindListActivity, remindListActivity.getString(R.string.login_error_message));
				remindListActivity.userinfoApplication.exitForLogin(remindListActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + remindListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(remindListActivity);
				remindListActivity.packageUpdateUtil = new PackageUpdateUtil(remindListActivity, remindListActivity.mHandler, fileCache, downloadFileUrl, false, remindListActivity.userinfoApplication);
				remindListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				remindListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = remindListActivity.getFileStreamPath(filename);
				file.getName();
				remindListActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (remindListActivity.requestWebServiceThread != null) {
				remindListActivity.requestWebServiceThread.interrupt();
				remindListActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		remindListView
				.setOnRefreshListener(new RefreshListViewWithWebservice() {

					@Override
					public Object refreshing() {
						// TODO Auto-generated method stub
						String returncode = "ok";
						if (requestWebServiceThread == null) {
							requestWebService(false);
						}
						return returncode;
					}

					@Override
					public void refreshed(Object obj) {
						// TODO Auto-generated method stub

					}
				});
		requestWebService(true);
	}

	protected void requestWebService(boolean isNeedProgressDialog) {
		if (isNeedProgressDialog) {
			progressDialog = new ProgressDialog(this,
					R.style.CustomerProgressDialog);
			progressDialog.setMessage(getString(R.string.please_wait));
			progressDialog.show();
		}
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "getRemindListByAccountID";
				String endPoint = "notice";
				String serverRequestResult = WebServiceUtil
						.requestWebServiceWithSSLUseJson(endPoint, methodName,
								"", userinfoApplication);
				if (serverRequestResult == null
						|| serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					int code = 0;
					JSONObject serverResultJson = null;
					try {
						serverResultJson = new JSONObject(serverRequestResult);
						code = serverResultJson.getInt("Code");
					} catch (JSONException e) {
					}
					if (code == 1) {
						remindList = new ArrayList<RemindInfo>();
						JSONObject remindJsonObject = null;
						try {
							remindJsonObject = serverResultJson
									.getJSONObject("Data");
						} catch (JSONException e) {
						}
						// 服务的提醒
						if (remindJsonObject.has("RemindList") && !remindJsonObject.isNull("RemindList")) {
							JSONArray remindJsonArray=null;
							try {
								remindJsonArray=remindJsonObject.getJSONArray("RemindList");
							} catch (JSONException e) {
							}
							for(int a=0;a<remindJsonArray.length();a++){
								JSONObject remindJson=null;
								try {
									remindJson=remindJsonArray.getJSONObject(a);
								} catch (JSONException e) {
								}
								RemindInfo serviceRemindInfo = new RemindInfo();
								String scheduleTime = "";
								String remindContent = "";
								int orderID = 0;
								try {
									if (remindJson.has("ScheduleTime")) {
										scheduleTime = remindJson.getString("ScheduleTime");
									}
									if (remindJson.has("RemindContent")) {
										remindContent = remindJson
												.getString("RemindContent");
									}
									if (remindJson.has("OrderID"))
										orderID = remindJson.getInt("OrderID");
								} catch (JSONException e) {
								}
								serviceRemindInfo.setScheduleTime(scheduleTime);
								serviceRemindInfo.setRemindContent(remindContent);
								serviceRemindInfo.setScheduleType(0);
								serviceRemindInfo.setOrderID(orderID);
								remindList.add(serviceRemindInfo);
							}
						}
						// 回访提醒
						if (remindJsonObject.has("VisitList") && !remindJsonObject.isNull("VisitList")) {
							JSONArray visitJsonArray=null;
							try {
								visitJsonArray=remindJsonObject.getJSONArray("VisitList");
							} catch (JSONException e) {
							}
							for(int c=0;c<visitJsonArray.length();c++){
								JSONObject visitJson=null;
								try {
									visitJson=visitJsonArray.getJSONObject(c);
								} catch (JSONException e) {
								}
								RemindInfo visitRemind = new RemindInfo();
								String remindContent = "";
								String updateTime = "";
								int orderID = 0;
								try {
									if (visitJson.has("RemindContent")) {
										remindContent = visitJson.getString("RemindContent");
									}
									if (visitJson.has("UpdateTime")) {
										updateTime = visitJson.getString("UpdateTime");
									}
									if (visitJson.has("OrderID"))
										orderID = visitJson.getInt("OrderID");
								} catch (JSONException e) {
	
								}
								visitRemind.setRemindContent(remindContent);
								visitRemind.setOrderID(orderID);
								visitRemind.setScheduleTime(updateTime);
								visitRemind.setScheduleType(1);
								remindList.add(visitRemind);
						}
						//生日提醒
						if (remindJsonObject.has("BirthdayList") && !remindJsonObject.isNull("BirthdayList")) {
							JSONArray birthdayJsonArray=null;
							try {
								birthdayJsonArray=remindJsonObject.getJSONArray("BirthdayList");
							} catch (JSONException e) {
							}
							for(int b=0;b<birthdayJsonArray.length();b++){
								JSONObject birthdayJson=null;
								try {
									birthdayJson=birthdayJsonArray.getJSONObject(b);
								} catch (JSONException e) {
								}
								RemindInfo birthRemind = new RemindInfo();
								String remindContent = "";
								String birthday = "";
								try {
									if (birthdayJson.has("RemindContent")) {
										remindContent = birthdayJson.getString("RemindContent");
									}
									if (birthdayJson.has("BirthDay")) {
										birthday = birthdayJson.getString("BirthDay");
									}
								} catch (JSONException e) {
								}
								birthRemind.setRemindContent(remindContent);
								birthRemind.setScheduleTime(birthday);
								birthRemind.setScheduleType(2);
								remindList.add(birthRemind);
							}
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
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
	}
	@Override
	public void onItemClick(AdapterView<?> adapterView, View view,
			int position, long id) {
		// TODO Auto-generated method stub
		if (position != 0) {
			// 如果是服务或者回访提醒，则跳转到订单详细 0：服务提醒 1：回访提醒 2：生日提醒
				if (remindList.get(position - 1).getScheduleType() != 2) {
					OrderInfo orderInfo = new OrderInfo();
					orderInfo.setOrderID(remindList.get(position - 1).getOrderID());
					orderInfo.setProductType(Constant.SERVICE_ORDER);
					Intent destIntent = new Intent(this, OrderDetailActivity.class);
					destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
					destIntent.putExtra("orderInfo", orderInfo);
					destIntent.putExtra("FromOrderList", true);
					startActivity(destIntent);
				}
		}
	}
}
