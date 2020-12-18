package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Date;

import cn.com.antika.adapter.AppointmentListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AppointmentConditionInfo;
import cn.com.antika.bean.AppointmentInfo;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.XListView;
import cn.com.antika.webservice.WebServiceUtil;

public class AppointmentTaskListActivity extends BaseActivity implements OnClickListener,OnItemClickListener, XListView.IXListViewListener {
	private AppointmentTaskListActivityHandler handler = new AppointmentTaskListActivityHandler(this);
	ImageButton activityAppointmentCustomerSearchNewBtn,activityAppointmentCreateBtn;
	private ProgressDialog progressDialog;
	private Boolean isRefresh = false;
	private Thread requestWebServiceThread;
	private PackageUpdateUtil packageUpdateUtil;
	private UserInfoApplication userinfoApplication;
	private AppointmentConditionInfo appointmentConditionInfo;
	int status[];
	ArrayList<AppointmentInfo> appointmentInfoList;
	private AppointmentListAdapter appointmentListAdapter;
	private XListView appointmentInfoView;
	private int pageIndex;
	private int appointmentInfoListFlag;// 1:取最初的数据；2：取最新的数据；3：取老数据
	private int pageCount = 1;// 全部页数
	private TextView activityAppointmentCustomerListTitleText;
	boolean isSearchOnLoadMore=false;
	boolean isSearchOnRefresh=false;

	private static class AppointmentTaskListActivityHandler extends Handler {
		private final AppointmentTaskListActivity appointmentTaskListActivity;

		private AppointmentTaskListActivityHandler(AppointmentTaskListActivity activity) {
			WeakReference<AppointmentTaskListActivity> weakReference = new WeakReference<AppointmentTaskListActivity>(activity);
			appointmentTaskListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (appointmentTaskListActivity.progressDialog != null) {
				appointmentTaskListActivity.progressDialog.dismiss();
				appointmentTaskListActivity.progressDialog = null;
			}
			appointmentTaskListActivity.isRefresh = false;
			switch (msg.what) {
				case 1:
					@SuppressWarnings("unchecked")
					ArrayList<AppointmentInfo> tmpList = (ArrayList<AppointmentInfo>) msg.obj;
					appointmentTaskListActivity.pageCount = msg.arg2;
					// 有老数据时，当前页数加一
					if (tmpList.size() > 0) {
						//设置订单列表页数信息
						appointmentTaskListActivity.pageIndex += 1;
					}
					if (appointmentTaskListActivity.appointmentInfoListFlag == 1 || appointmentTaskListActivity.appointmentInfoListFlag == 2) {
						appointmentTaskListActivity.appointmentInfoList.clear();
						appointmentTaskListActivity.appointmentInfoList.addAll(tmpList);
					} else if (appointmentTaskListActivity.appointmentInfoListFlag == 3 && tmpList != null && tmpList.size() > 0) {
						appointmentTaskListActivity.appointmentInfoList.addAll(appointmentTaskListActivity.appointmentInfoList.size(), tmpList);
					} else if (appointmentTaskListActivity.appointmentInfoListFlag == 3 && (tmpList == null || tmpList.size() == 0)) {
						appointmentTaskListActivity.appointmentInfoView.hideFooterView();
						DialogUtil.createShortDialog(appointmentTaskListActivity, "没有更早的任务！");
					}
					appointmentTaskListActivity.appointmentListAdapter.notifyDataSetChanged();
					break;
				case Constant.LOGIN_ERROR:
					DialogUtil.createShortDialog(appointmentTaskListActivity, appointmentTaskListActivity.getString(R.string.login_error_message));
					UserInfoApplication.getInstance().exitForLogin(appointmentTaskListActivity);
					break;
				case Constant.APP_VERSION_ERROR:
					String downloadFileUrl = Constant.SERVER_URL + appointmentTaskListActivity.getString(R.string.download_apk_address);
					FileCache fileCache = new FileCache(appointmentTaskListActivity);
					appointmentTaskListActivity.packageUpdateUtil = new PackageUpdateUtil(appointmentTaskListActivity, appointmentTaskListActivity.handler, fileCache, downloadFileUrl, false, appointmentTaskListActivity.userinfoApplication);
					appointmentTaskListActivity.packageUpdateUtil.getPackageVersionInfo();
					ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
					serverPackageVersion.setPackageVersion((String) msg.obj);
					appointmentTaskListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
					break;
				case 5:
					((DownloadInfo) msg.obj).getUpdateDialog().cancel();
					String filename = "cn.com.antika.business.apk";
					File file = appointmentTaskListActivity.getFileStreamPath(filename);
					file.getName();
					appointmentTaskListActivity.packageUpdateUtil.showInstallDialog();
					break;
				case -5:
					((DownloadInfo) msg.obj).getUpdateDialog().cancel();
					break;
				case 7:
					int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
					((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
					break;
				default:
					if (appointmentTaskListActivity.appointmentInfoListFlag == 1 || appointmentTaskListActivity.appointmentInfoListFlag == 2) {
						appointmentTaskListActivity.appointmentInfoList.clear();
						appointmentTaskListActivity.appointmentListAdapter.notifyDataSetChanged();
					}
					DialogUtil.createShortDialog(appointmentTaskListActivity, "您的网络貌似不给力，请重试");
					break;
			}
			appointmentTaskListActivity.onLoad();
		}
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_appointment_customer_list);
		userinfoApplication = UserInfoApplication.getInstance();
		appointmentInfoView=(XListView) findViewById(R.id.activity_appointment_customer_list_view);
		activityAppointmentCustomerSearchNewBtn=(ImageButton) findViewById(R.id.activity_appointment_customer_search_new_btn);
		activityAppointmentCreateBtn=(ImageButton) findViewById(R.id.activity_appointment_create_btn);
		activityAppointmentCustomerListTitleText=(TextView) findViewById(R.id.activity_appointment_customer_list_title_text);
		activityAppointmentCustomerSearchNewBtn.setOnClickListener(this);
		activityAppointmentCreateBtn.setOnClickListener(this);
		appointmentInfoView.setOnItemClickListener(this);
		appointmentInfoView.setXListViewListener(this);
		appointmentInfoView.setPullLoadEnable(true);
		appointmentInfoList=new ArrayList<AppointmentInfo>();
		appointmentListAdapter=new AppointmentListAdapter(AppointmentTaskListActivity.this,appointmentInfoList,"MENU_LEFT");
		appointmentInfoView.setAdapter(appointmentListAdapter);
		appointmentInfoList.clear();
		findViewById(R.id.head_layout).setVisibility(View.GONE);
		activityAppointmentCreateBtn.setVisibility(View.GONE);
		activityAppointmentCustomerListTitleText.setText("服务预约");
		initPageIndex();
		refreshList(1,false);
	
	}
	
	
	private void refreshList(int flag , boolean isSelect) {
		// 上一次取数据任务还没有完成，不在调用后台
		if (isRefresh)
			return;
		// 取老数据时，已经取完数据不在调用后台
		if (flag == 3 && (pageIndex > pageCount || appointmentInfoList.size() < 10)) {
			DialogUtil.createShortDialog(this, "没有更早的任务！");
			onLoad();
			appointmentInfoView.hideFooterView();
			return;
		} else {
			appointmentInfoView.setPullLoadEnable(true);
		}
		isRefresh = true;
		appointmentInfoListFlag = flag;
		if (flag == 1) {
			if (progressDialog == null) {
				progressDialog = new ProgressDialog(AppointmentTaskListActivity.this,R.style.CustomerProgressDialog);
				progressDialog.setMessage(getString(R.string.please_wait));
				progressDialog.setCancelable(false);
			}
			progressDialog.show();
		}
		int currentPageIndex = 1;
		if (appointmentInfoListFlag == 3) {
			currentPageIndex = pageIndex;
			if (currentPageIndex >= 1)
				appointmentConditionInfo.setTaskScdlStartTime(appointmentInfoList.get(appointmentInfoList.size()-1).getTaskScdlStartTime());
		} else if (appointmentInfoListFlag == 2) {
			initPageIndex();
		}
		if(!isSelect){
			appointmentConditionInfo=new AppointmentConditionInfo();
			appointmentConditionInfo.setBranchID(userinfoApplication.getAccountInfo().getBranchId());
			appointmentConditionInfo.setPageSize(10);
			status =new int[]{2};
			//查看所有任务权限  如果ResponsiblePersonIDs为空  则读取本店所有的任务   如果不为空 则查看指定的ResponsiblePersonIDs的任务
			int  authAllTaskRead=userinfoApplication.getAccountInfo().getAuthAllTaskRead();
			if(authAllTaskRead==1){
				appointmentConditionInfo.setResponsiblePersonIDs("[]");
			}else{
				appointmentConditionInfo.setResponsiblePersonIDs("["+userinfoApplication.getAccountInfo().getAccountId()+"]");
			}
			appointmentConditionInfo.setStatus(status);
			appointmentConditionInfo.setTaskType(0);
		}
		appointmentConditionInfo.setPageIndex(currentPageIndex);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetScheduleList";
				String endPoint = "Task";
				
				JSONArray statusArray=new JSONArray();
				JSONObject appointmentJson = new JSONObject();
		    	if(appointmentConditionInfo.getStatus().length>0){
		    		status=appointmentConditionInfo.getStatus();
		    		for(int i=0;i<appointmentConditionInfo.getStatus().length;i++){
		    			statusArray.put(status[i]);
		    		}
		    	}
		    	try {
					appointmentJson.put("BranchID", appointmentConditionInfo.getBranchID());
			    	appointmentJson.put("FilterByTimeFlag", appointmentConditionInfo.getFilterByTimeFlag());
			    	appointmentJson.put("PageIndex", appointmentConditionInfo.getPageIndex());
			    	appointmentJson.put("PageSize",appointmentConditionInfo.getPageSize());
			    	appointmentJson.put("TaskScdlStartTime",appointmentConditionInfo.getTaskScdlStartTime());
			    	//服务预约类型数据
			    	JSONArray taskTypeArray=new JSONArray();
			    	taskTypeArray.put(1);
			    	appointmentJson.put("TaskType",taskTypeArray);
			    	appointmentJson.put("Status",statusArray);
			    	if(appointmentConditionInfo.getResponsiblePersonIDs().length()>0){
			    		JSONArray responsiblePersonIDsArray=new JSONArray(appointmentConditionInfo.getResponsiblePersonIDs());
			    		if(responsiblePersonIDsArray.length()>0){
			    			appointmentJson.put("ResponsiblePersonIDs", responsiblePersonIDsArray);
			    		}
			    	}
			    	appointmentJson.put("CustomerID", appointmentConditionInfo.getCustomerID());
			    	appointmentJson.put("StartTime", appointmentConditionInfo.getStartTime());
			    	appointmentJson.put("EndTime", appointmentConditionInfo.getEndTime());
				} catch (JSONException e) {
					e.printStackTrace();
				}
				
				String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName, appointmentJson.toString(),userinfoApplication);
				JSONObject resultJson = null;
				Message msg = handler.obtainMessage();
				try {
					resultJson = new JSONObject(serverResultResult);
				} catch (JSONException e) {
				}
				
				if (serverResultResult == null || serverResultResult.equals(""))
					handler.sendEmptyMessage(-1);
				else {
					int    code=0;
					String message = "";
					try {
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1) {
						ArrayList<AppointmentInfo> appointmentList=new ArrayList<AppointmentInfo>();
						JSONObject appointmentObject = null;
						try {
							appointmentObject = resultJson.getJSONObject("Data");
						} catch (JSONException e) {
	
						}
						if (appointmentObject != null) {
							try{
							
							if(appointmentObject.has("RecordCount")){
								msg.arg1 = appointmentObject.getInt("RecordCount");
							}
							if(appointmentObject.has("PageCount")){
								msg.arg2 = appointmentObject.getInt("PageCount");
							}
							if(appointmentObject.has("TaskList") && !appointmentObject.isNull("TaskList")){
								JSONArray taskListaArray=new JSONArray();
								taskListaArray=appointmentObject.getJSONArray("TaskList");
								if(taskListaArray.length()>0){
									for (int i = 0; i < taskListaArray.length(); i++) {
										JSONObject taskjson = null;
											taskjson = (JSONObject) taskListaArray.get(i);
											AppointmentInfo appointmentInfo = new AppointmentInfo();
											if (taskjson.has("ResponsiblePersonName")) {
												appointmentInfo.setResponsiblePersonName(taskjson.getString("ResponsiblePersonName"));
											}
											if (taskjson.has("CustomerName")) {
												appointmentInfo.setCustomerName(taskjson.getString("CustomerName"));
											}
											if (taskjson.has("TaskName")) {
												appointmentInfo.setTaskName(taskjson.getString("TaskName"));
											}
											if (taskjson.has("TaskID")) {
												appointmentInfo.setTaskID(taskjson.getLong("TaskID"));
											}
											if(taskjson.has("TaskStatus") && taskjson.has("TaskStatus")){
												appointmentInfo.setTaskStatus(taskjson.getInt("TaskStatus"));
											}
											if(taskjson.has("TaskType") && taskjson.has("TaskType")){
												appointmentInfo.setTaskType(taskjson.getInt("TaskType"));
											}
											if(taskjson.has("TaskScdlStartTime") && taskjson.has("TaskScdlStartTime")){
												appointmentInfo.setTaskScdlStartTime(taskjson.getString("TaskScdlStartTime"));
											}
											if(taskjson.has("ResponsiblePersonID") && taskjson.has("ResponsiblePersonID")){
												appointmentInfo.setResponsiblePersonID(taskjson.getInt("ResponsiblePersonID"));
											}
											if(taskjson.has("ResponsiblePersonMobile") && taskjson.has("ResponsiblePersonMobile")){
												appointmentInfo.setResponsiblePersonMobile(taskjson.getString("ResponsiblePersonMobile"));
											}
											if(taskjson.has("BranchName") && taskjson.has("BranchName")){
												appointmentInfo.setBranchName(taskjson.getString("BranchName"));
											}
											appointmentList.add(appointmentInfo);
									}
								 }
							  }
	                        }catch(JSONException e){
						  }
						}
						msg.obj=appointmentList;
						msg.what = 1;
						handler.sendMessage(msg);
					}
					else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
						handler.sendEmptyMessage(code);
					else {
						msg.what = 0;
						msg.obj = message;
						handler.sendMessage(msg);
					}
				}
			}
		};
		 requestWebServiceThread.start();
	}
	
	
	private void initPageIndex() {
		pageIndex = 1;
	}     
	
	@SuppressWarnings("deprecation")
	private void onLoad() {
		appointmentInfoView.stopRefresh();
		appointmentInfoView.stopLoadMore();
		appointmentInfoView.setRefreshTime(new Date().toLocaleString());
	}
	@Override
	public void onRefresh() {
		isSearchOnLoadMore=true;
		isSearchOnRefresh=true;
		refreshList(2,isSearchOnRefresh);
	}
	
	@Override
	public void onLoadMore() {
		if(isSearchOnRefresh){
			if(isSearchOnLoadMore)
				refreshList(3,true);
			else
				refreshList(3,false);
		}else{
			if(isSearchOnLoadMore)
				refreshList(3,false);
			else
				refreshList(3,true);
		}
	}
	
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		if (position != 0) {
			Intent intent = null;
			if (appointmentInfoList != null && appointmentInfoList.size() != 0) {
				AppointmentInfo appointmentInfo = appointmentInfoList.get(position - 1);
				intent = new Intent(this, AppointmentDetailActivity.class);
				Bundle bu=new Bundle();
				bu.putLong("taskID", appointmentInfo.getTaskID());
				intent.putExtras(bu);
				intent.putExtra("taskStatus", appointmentInfo.getTaskStatus());
				startActivity(intent);
			}
		}
	}
	
	@Override
	public void onClick(View v) {
		Intent intent;
		Bundle bundle;
		switch (v.getId()) {
		case R.id.activity_appointment_customer_search_new_btn:
			intent=new Intent(this,AppointmentTaskSearchActivity.class);
			bundle=new Bundle();
			bundle.putSerializable("appointmentConditionInfo", appointmentConditionInfo);
			intent.putExtras(bundle);
			getParent().startActivityForResult(intent,1);
			break;
		}
		
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// 选择员工成功返回
	  if (resultCode == RESULT_OK) {
			if (requestCode == 1) {
				appointmentConditionInfo=(AppointmentConditionInfo) data.getSerializableExtra("appointmentCondition");
				initPageIndex();
				isSearchOnRefresh=true;
				isSearchOnLoadMore=true;
				refreshList(1,isSearchOnRefresh);
			}
			else if (requestCode == 3) {
				initPageIndex();
				isSearchOnRefresh=true;
				isSearchOnLoadMore=true;
				refreshList(1,true);
			}
	     }
	  }
	
	@Override
	protected void onRestart() {
		super.onRestart();
	}
	@Override
	protected void onDestroy() {
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
		if (appointmentInfoList != null) {
			appointmentInfoList.clear();
			appointmentInfoList = null;
		}
	}
}
