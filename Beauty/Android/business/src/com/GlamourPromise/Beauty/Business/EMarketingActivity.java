package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.EMarketingItemAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EmarketingInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.XListView;
import com.GlamourPromise.Beauty.view.XListView.IXListViewListener;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/*
 *营销列表 
 * */
public class EMarketingActivity extends BaseActivity implements
		OnClickListener,IXListViewListener {
	private EMarketingActivityHandler mHandler = new EMarketingActivityHandler(this);
	private XListView emarketingListView;
	private ProgressDialog progressDialog;
	private Thread requestWebServiceThread;
	private List<EmarketingInfo> emarketingInfoList;
	private EMarketingItemAdapter emarketingItemAdapter;
	private ImageButton sendNewEmarketingMessageBtn;
	private int pageSize=10,pageIndex=1,pageCount=0;;
	private UserInfoApplication userinfoApplication;
	private Boolean isUpPullMoreData = false;
	private PackageUpdateUtil packageUpdateUtil;
	private TextView  emarketingPageInfoText;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_emarketing);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class EMarketingActivityHandler extends Handler {
		private final EMarketingActivity eMarketingActivity;

		private EMarketingActivityHandler(EMarketingActivity activity) {
			WeakReference<EMarketingActivity> weakReference = new WeakReference<EMarketingActivity>(activity);
			eMarketingActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (eMarketingActivity.progressDialog != null) {
				eMarketingActivity.progressDialog.dismiss();
				eMarketingActivity.progressDialog = null;
			}
			switch (message.what) {
				case 0:
					// 上拉更多
					if (eMarketingActivity.emarketingInfoList != null && eMarketingActivity.emarketingInfoList.size() != 0 && !eMarketingActivity.isUpPullMoreData) {
						eMarketingActivity.emarketingPageInfoText.setText("第" + eMarketingActivity.pageIndex + "/" + eMarketingActivity.pageCount + "页");
						eMarketingActivity.isUpPullMoreData = true;
						int lastMessageID = eMarketingActivity.emarketingInfoList.get(eMarketingActivity.emarketingInfoList.size() - 1).getMessageID();
						eMarketingActivity.upPullLoadMore();
					}
					eMarketingActivity.onLoad();
					break;
				case 1:

					if (eMarketingActivity.emarketingItemAdapter == null) {
						eMarketingActivity.emarketingItemAdapter = new EMarketingItemAdapter(eMarketingActivity, eMarketingActivity.emarketingInfoList);
						eMarketingActivity.emarketingListView.setAdapter(eMarketingActivity.emarketingItemAdapter);
					}
					if (eMarketingActivity.emarketingInfoList != null && eMarketingActivity.emarketingInfoList.size() > 0) {
						eMarketingActivity.emarketingPageInfoText.setText("第" + eMarketingActivity.pageIndex + "/" + eMarketingActivity.pageCount + "页");
					} else {
						// 隐藏查看更多
						eMarketingActivity.emarketingListView.setPullLoadEnable(false);
						eMarketingActivity.emarketingListView.hideFooterView();
					}
					eMarketingActivity.emarketingListView.setDividerHeight(20);
					eMarketingActivity.emarketingItemAdapter.notifyDataSetChanged();
					eMarketingActivity.onLoad();
					break;
				case 2:
					eMarketingActivity.emarketingPageInfoText.setText("第" + eMarketingActivity.pageIndex + "/" + eMarketingActivity.pageCount + "页");
					eMarketingActivity.emarketingItemAdapter.notifyDataSetChanged();
					eMarketingActivity.onLoad();
					break;
				case 3:
					DialogUtil.createShortDialog(eMarketingActivity, "您的网络貌似不给力，请重试");
					break;
				case 4:
					eMarketingActivity.emarketingPageInfoText.setText("第" + eMarketingActivity.pageIndex + "/" + eMarketingActivity.pageCount + "页");
					eMarketingActivity.isUpPullMoreData = false;
					ArrayList<EmarketingInfo> emarketingList = (ArrayList<EmarketingInfo>) message.obj;
					if (emarketingList.size() == 0) {
						// 隐藏查看更多
						eMarketingActivity.emarketingListView.setPullLoadEnable(false);
						eMarketingActivity.emarketingListView.hideFooterView();
						DialogUtil.createShortDialog(eMarketingActivity, "没有更早的营销了");
					} else {
						eMarketingActivity.emarketingInfoList.addAll(emarketingList);
						eMarketingActivity.emarketingItemAdapter.notifyDataSetChanged();
					}
					eMarketingActivity.onLoad();
					break;
				case Constant.LOGIN_ERROR:
					DialogUtil.createShortDialog(eMarketingActivity, eMarketingActivity.getString(R.string.login_error_message));
					UserInfoApplication.getInstance().exitForLogin(eMarketingActivity);
					break;
				case Constant.APP_VERSION_ERROR:
					String downloadFileUrl = Constant.SERVER_URL + eMarketingActivity.getString(R.string.download_apk_address);
					FileCache fileCache = new FileCache(eMarketingActivity);
					eMarketingActivity.packageUpdateUtil = new PackageUpdateUtil(eMarketingActivity, eMarketingActivity.mHandler, fileCache, downloadFileUrl, false, eMarketingActivity.userinfoApplication);
					eMarketingActivity.packageUpdateUtil.getPackageVersionInfo();
					ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
					serverPackageVersion.setPackageVersion((String) message.obj);
					eMarketingActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
					break;
				case 5:
					((DownloadInfo) message.obj).getUpdateDialog().cancel();
					String filename = "com.glamourpromise.beauty.business.apk";
					File file = eMarketingActivity.getFileStreamPath(filename);
					file.getName();
					eMarketingActivity.packageUpdateUtil.showInstallDialog();
					break;
				case -5:
					((DownloadInfo) message.obj).getUpdateDialog().cancel();
					break;
				case 7:
					int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
					((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
					break;
			}
			if (eMarketingActivity.requestWebServiceThread != null) {
				eMarketingActivity.requestWebServiceThread.interrupt();
				eMarketingActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		emarketingListView = (XListView) findViewById(R.id.emarketing_list_view);
		emarketingListView.setXListViewListener(this);
		emarketingListView.setPullLoadEnable(true);
		sendNewEmarketingMessageBtn = (ImageButton) findViewById(R.id.send_new_emarketing_message);
		sendNewEmarketingMessageBtn.setOnClickListener(this);
		emarketingPageInfoText=(TextView) findViewById(R.id.emarketing_page_info_text);
		if (userinfoApplication.getAccountInfo().getAuthMarketingWrite() == 0)
			sendNewEmarketingMessageBtn.setVisibility(View.GONE);
		emarketingInfoList = new ArrayList<EmarketingInfo>();
		initEmarketingList();
	}

	private void downPullLoadMore() {
		pageIndex=1;
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetMessageForMarket";
				String endPoint = "Message";
				JSONObject jsonParam = new JSONObject();
				try {
					jsonParam.put("PageIndex",pageIndex);
					jsonParam.put("PageSize",pageSize);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,jsonParam.toString(), userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(3);
				else {
					JSONArray resultArray = null;
					int code = 0;
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						pageCount=((JSONObject)resultJson.get("Data")).getInt("PageCount");
						resultArray = ((JSONObject)resultJson.get("Data")).getJSONArray("MessageList");
					} catch (JSONException e) {
					}
					if (code == 1) {
						parseWebServiceResult(resultArray);
						mHandler.sendEmptyMessage(1);
					} else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						mHandler.sendEmptyMessage(3);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}

	private void initEmarketingList() {
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetMessageForMarket";
				String endPoint = "Message";
				JSONObject jsonParam = new JSONObject();
				try {
					jsonParam.put("PageIndex",pageIndex);
					jsonParam.put("PageSize",pageSize);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,jsonParam.toString(), userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(3);
				else {
					JSONArray resultArray = null;
					int code = 0;
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						pageCount=((JSONObject)resultJson.get("Data")).getInt("PageCount");
						resultArray = ((JSONObject)resultJson.get("Data")).getJSONArray("MessageList");
					} catch (JSONException e) {
					}
					if (code == 1) {
						parseWebServiceResult(resultArray);
						mHandler.sendEmptyMessage(1);
					} else if (code == Constant.APP_VERSION_ERROR  || code == Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						mHandler.sendEmptyMessage(3);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}

	private void upPullLoadMore() {
		pageIndex=pageIndex+1;
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetMessageForMarket";
				String endPoint = "Message";
				JSONObject jsonParam = new JSONObject();
				try {
					jsonParam.put("PageIndex",pageIndex);
					jsonParam.put("PageSize",pageSize);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,jsonParam.toString(), userinfoApplication);
				if (serverRequestResult == null
						|| serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(3);
				else {
					ArrayList<EmarketingInfo> emarketingList = new ArrayList<EmarketingInfo>();
					JSONArray resultArray = null;
					int code = 0;
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						pageCount=((JSONObject)resultJson.get("Data")).getInt("PageCount");
						resultArray = ((JSONObject)resultJson.get("Data")).getJSONArray("MessageList");
					} catch (JSONException e) {
					}
					if (code == 1) {
						for (int i = 0; i < resultArray.length(); i++) {
							JSONObject resultJson = null;
							try {
								resultJson = (JSONObject) resultArray.get(i);
							} catch (JSONException e) {
							}
							String fromUserID = "0";
							String fromUserName = "";
							String messageID = "0";
							String messageContent = "";
							String sendTime = "";
							String sendCount = "0";
							String receiveCount = "0";
							StringBuilder toUserName = new StringBuilder();
							JSONArray toUserNameArray = null;
							try {
								if (resultJson.has("FromUserID")
										&& !resultJson.isNull("FromUserID"))
									fromUserID = resultJson
											.getString("FromUserID");
								if (resultJson.has("FromUserName")
										&& !resultJson.isNull("FromUserName"))
									fromUserName = resultJson
											.getString("FromUserName");
								if (resultJson.has("MessageID")
										&& !resultJson.isNull("MessageID"))
									messageID = resultJson
											.getString("MessageID");
								if (resultJson.has("MessageContent")
										&& !resultJson.isNull("MessageContent"))
									messageContent = resultJson
											.getString("MessageContent");
								if (resultJson.has("SendTime")
										&& !resultJson.isNull("SendTime"))
									sendTime = resultJson.getString("SendTime");
								if (resultJson.has("SendCount")
										&& !resultJson.isNull("SendCount"))
									sendCount = resultJson
											.getString("SendCount");
								if (resultJson.has("ReceiveCount")
										&& !resultJson.isNull("ReceiveCount"))
									receiveCount = resultJson
											.getString("ReceiveCount");
								if (resultJson.has("ToUserName")
										&& !resultJson.isNull("ToUserName"))
									toUserNameArray = resultJson
											.getJSONArray("ToUserName");
							} catch (JSONException e) {
							}
							for (int j = 0; j < toUserNameArray.length(); j++) {
								try {
									toUserName.append(toUserNameArray.get(j)
											+ ",");
								} catch (JSONException e) {

								}
							}
							EmarketingInfo emarketingInfo = new EmarketingInfo();
							emarketingInfo.setFromUserID(Integer
									.parseInt(fromUserID));
							emarketingInfo.setFromUserName(fromUserName);
							emarketingInfo.setMessageID(Integer
									.parseInt(messageID));
							emarketingInfo.setMessageContent(messageContent);
							emarketingInfo.setSendTime(sendTime);
							emarketingInfo.setSendCount(Integer
									.parseInt(sendCount));
							emarketingInfo.setReceiveCount(Integer
									.parseInt(receiveCount));
							emarketingInfo.setToUserName(toUserName.toString());
							emarketingList.add(emarketingInfo);
						}
						if((emarketingList==null || emarketingList.size()==0) && pageIndex>1)
							pageIndex=pageIndex-1;
						mHandler.obtainMessage(4, emarketingList).sendToTarget();
					} else
						mHandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.send_new_emarketing_message:
			Intent destIntent = new Intent(this,SendNewEmarketingMessageActivity.class);
			startActivity(destIntent);
			break;
		}
	}
	private void parseWebServiceResult(JSONArray resultArray) {
		for (int i = 0; i < resultArray.length(); i++) {
			JSONObject resultJson = null;
			try {
				resultJson = (JSONObject) resultArray.get(i);
			} catch (JSONException e) {
			}
			String fromUserID = "0";
			String fromUserName = "";
			String messageID = "0";
			String messageContent = "";
			String sendTime = "";
			String sendCount = "0";
			String receiveCount = "0";
			StringBuilder toUserName = new StringBuilder();
			JSONArray toUserNameArray = null;
			try {
				if (resultJson.has("FromUserID")
						&& !resultJson.isNull("FromUserID"))
					fromUserID = resultJson.getString("FromUserID");
				if (resultJson.has("FromUserName")
						&& !resultJson.isNull("FromUserName"))
					fromUserName = resultJson.getString("FromUserName");
				if (resultJson.has("MessageID")
						&& !resultJson.isNull("MessageID"))
					messageID = resultJson.getString("MessageID");
				if (resultJson.has("MessageContent")
						&& !resultJson.isNull("MessageContent"))
					messageContent = resultJson.getString("MessageContent");
				if (resultJson.has("SendTime")
						&& !resultJson.isNull("SendTime"))
					sendTime = resultJson.getString("SendTime");
				if (resultJson.has("SendCount")
						&& !resultJson.isNull("SendCount"))
					sendCount = resultJson.getString("SendCount");
				if (resultJson.has("ReceiveCount")
						&& !resultJson.isNull("ReceiveCount"))
					receiveCount = resultJson.getString("ReceiveCount");
				if (resultJson.has("ToUserName")
						&& !resultJson.isNull("ToUserName"))
					toUserNameArray = resultJson.getJSONArray("ToUserName");
			} catch (JSONException e) {
			}
			for (int j = 0; j < toUserNameArray.length(); j++) {
				try {
					toUserName.append(toUserNameArray.get(j) + ",");
				} catch (JSONException e) {

				}
			}
			EmarketingInfo emarketingInfo = new EmarketingInfo();
			emarketingInfo.setFromUserID(Integer.parseInt(fromUserID));
			emarketingInfo.setFromUserName(fromUserName);
			emarketingInfo.setMessageID(Integer.parseInt(messageID));
			emarketingInfo.setMessageContent(messageContent);
			emarketingInfo.setSendTime(sendTime);
			emarketingInfo.setSendCount(Integer.parseInt(sendCount));
			emarketingInfo.setReceiveCount(Integer.parseInt(receiveCount));
			emarketingInfo.setToUserName(toUserName.toString());
			if (emarketingInfoList != null)
				emarketingInfoList.add(i, emarketingInfo);
		}
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
	}

	@Override
	public void onRefresh() {
		if (requestWebServiceThread == null) {
			if(emarketingInfoList!=null)
				emarketingInfoList.clear();
			downPullLoadMore();
		}
	}

	@Override
	public void onLoadMore() {
		mHandler.sendEmptyMessage(0);
	}

	private void onLoad() {
		emarketingListView.stopRefresh();
		emarketingListView.stopLoadMore();
		emarketingListView.setRefreshTime(new Date().toLocaleString());
	}
}
