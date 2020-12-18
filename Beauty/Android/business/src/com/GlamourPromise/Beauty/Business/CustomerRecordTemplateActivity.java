package com.GlamourPromise.Beauty.Business;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.RecordTemplateListAdapter;
import com.GlamourPromise.Beauty.adapter.RecordTemplateListAdapter.Callback;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AdvancedSearchCondition;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.RecordTemplate;
import com.GlamourPromise.Beauty.bean.RecordTemplateListBaseConditionInfo;
import com.GlamourPromise.Beauty.bean.RecordTemplateListBaseConditionInfo.RecordTemplateListConditionBuilder;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.manager.RecordTemplateManager;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.XListView;
import com.GlamourPromise.Beauty.view.XListView.IXListViewListener;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class CustomerRecordTemplateActivity extends BaseActivity implements OnItemClickListener,OnClickListener,IXListViewListener,Callback{
	private CustomerRecordTemplateActivityHandler mHandler = new CustomerRecordTemplateActivityHandler(this);
	private List<RecordTemplate> recordTemplateList;
	private XListView            recordTemplateListView;
	private ImageView  addNewCustomerRecordBtn,customerRecordAdvancedSearchBtn;
	private UserInfoApplication userinfoApplication;
	private ProgressDialog    progressDialog;
	private PackageUpdateUtil packageUpdateUtil;
	private int pageCount = 1;// 全部模板的页数
	private int pageIndex;
	private Boolean isRefresh = false;
	private int getRecordTemplateListFlag;// 1:取最初的数据；2：取最新的数据；3：取老数据
	private RecordTemplateManager    recordTemplateManager;
	private RecordTemplateListAdapter  recordTemplateListAdapter;
	private static                              RecordTemplateListBaseConditionInfo recordTemplateListBaseConditionInfo;
	private TextView  				            recordTemplateListPageInfoText;
	private int userRole;
	private JSONObject  delAnswerJson;
	private Thread requestWebServiceThread;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_customer_record_template);
		userRole = getIntent().getIntExtra("USER_ROLE",Constant.USER_ROLE_BUSINESS);
		initView();
	}
	protected void initView() {
		userinfoApplication=UserInfoApplication.getInstance();
		recordTemplateListView=(XListView)findViewById(R.id.customer_record_template_list_view);
		recordTemplateListView.setOnItemClickListener(this);
		recordTemplateListView.setXListViewListener(this);
		addNewCustomerRecordBtn=(ImageView) findViewById(R.id.add_new_customer_record_btn);
		customerRecordAdvancedSearchBtn=(ImageView) findViewById(R.id.customer_record_advanced_search_btn);
		if(userRole==Constant.USER_ROLE_BUSINESS){
			addNewCustomerRecordBtn.setVisibility(View.GONE);
		}
		else if(userRole==Constant.USER_ROLE_CUSTOMER){
			//如果有编辑顾客咨询记录的权限，则可以新增
			addNewCustomerRecordBtn.setOnClickListener(this);	
		}	
		customerRecordAdvancedSearchBtn.setOnClickListener(this);
		recordTemplateList=new ArrayList<RecordTemplate>();
		recordTemplateManager=new RecordTemplateManager();
		recordTemplateListAdapter=new RecordTemplateListAdapter(this,recordTemplateList,false,this);
		recordTemplateListView.setAdapter(recordTemplateListAdapter);
		recordTemplateListView.setPullLoadEnable(true);
		recordTemplateListPageInfoText=(TextView) findViewById(R.id.customer_record_template_page_info_text);
		recordTemplateListBaseConditionInfo=new RecordTemplateListBaseConditionInfo();
		recordTemplateListBaseConditionInfo.setFilterByTimeFlag(0);
		recordTemplateListBaseConditionInfo.setResponsiblePersonID("");
		if(userRole==Constant.USER_ROLE_BUSINESS){
			recordTemplateListBaseConditionInfo.setCustomerID(0);
			findViewById(R.id.record_template_list_head_layout).setVisibility(View.VISIBLE);
			BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
			GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
			BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
			GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
			progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
			progressDialog.setMessage(getString(R.string.please_wait));
			progressDialog.show();
			initPageIndex();
			refreshList(1);
		}   
		else{
			findViewById(R.id.record_template_list_head_layout).setVisibility(View.GONE);
			recordTemplateListBaseConditionInfo.setShowAll(true);
			recordTemplateListBaseConditionInfo.setCustomerID(userinfoApplication.getSelectedCustomerID());
			initPageIndex();
			refreshList(1);
		}
	}

	private static class CustomerRecordTemplateActivityHandler extends Handler {
		private final CustomerRecordTemplateActivity customerRecordTemplateActivity;

		private CustomerRecordTemplateActivityHandler(CustomerRecordTemplateActivity activity) {
			WeakReference<CustomerRecordTemplateActivity> weakReference = new WeakReference<CustomerRecordTemplateActivity>(activity);
			customerRecordTemplateActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			customerRecordTemplateActivity.dismissDialog(customerRecordTemplateActivity.progressDialog);
			customerRecordTemplateActivity.isRefresh = false;
			switch (message.what) {
				case Constant.GET_WEB_DATA_TRUE:
					@SuppressWarnings("unchecked")
					ArrayList<RecordTemplate> tmpList = (ArrayList<RecordTemplate>) message.obj;
					customerRecordTemplateActivity.pageCount = message.arg2;
					//总页数不为0时显示
					if (customerRecordTemplateActivity.pageCount != 0) {
						customerRecordTemplateActivity.recordTemplateListPageInfoText.setText("(第" + customerRecordTemplateActivity.pageIndex + "/" + customerRecordTemplateActivity.pageCount + "页)");
					}
					//总页数为0时，则将模板页数信息置空
					else {
						customerRecordTemplateActivity.recordTemplateListPageInfoText.setText("");
					}
					// 有老数据时，当前页数加一
					if (tmpList.size() > 0) {
						//设置模板列表页数信息
						customerRecordTemplateActivity.pageIndex += 1;
					}
					if (customerRecordTemplateActivity.getRecordTemplateListFlag == 1 || customerRecordTemplateActivity.getRecordTemplateListFlag == 2) {
						customerRecordTemplateActivity.recordTemplateList.clear();
						customerRecordTemplateActivity.recordTemplateList.addAll(tmpList);
					} else if (customerRecordTemplateActivity.getRecordTemplateListFlag == 3 && tmpList != null && customerRecordTemplateActivity.recordTemplateList.size() > 0) {
						customerRecordTemplateActivity.recordTemplateList.addAll(customerRecordTemplateActivity.recordTemplateList.size(), tmpList);
					} else if (customerRecordTemplateActivity.getRecordTemplateListFlag == 3 && (tmpList == null || tmpList.size() == 0)) {
						customerRecordTemplateActivity.recordTemplateListView.hideFooterView();
						DialogUtil.createShortDialog(customerRecordTemplateActivity, "没有更多数据了！");
					}
					customerRecordTemplateActivity.recordTemplateListAdapter.notifyDataSetChanged();
					break;
				case Constant.GET_WEB_DATA_EXCEPTION:
					break;
				case Constant.GET_WEB_DATA_FALSE:
					if (customerRecordTemplateActivity.getRecordTemplateListFlag == 1 || customerRecordTemplateActivity.getRecordTemplateListFlag == 2) {
						customerRecordTemplateActivity.recordTemplateList.clear();
						customerRecordTemplateActivity.recordTemplateListAdapter.notifyDataSetChanged();
					}
					String msg = (String) message.obj;
					DialogUtil.createShortDialog(customerRecordTemplateActivity, msg);
					break;
				default:
					if (customerRecordTemplateActivity.getRecordTemplateListFlag == 1 || customerRecordTemplateActivity.getRecordTemplateListFlag == 2) {
						customerRecordTemplateActivity.recordTemplateList.clear();
						customerRecordTemplateActivity.recordTemplateListAdapter.notifyDataSetChanged();
					}
					DialogUtil.createShortDialog(customerRecordTemplateActivity, "您的网络貌似不给力，请重试");
					break;
				case 4:
					customerRecordTemplateActivity.refreshList(1);
					break;
				case Constant.LOGIN_ERROR:
					DialogUtil.createShortDialog(customerRecordTemplateActivity, customerRecordTemplateActivity.getString(R.string.login_error_message));
					UserInfoApplication.getInstance().exitForLogin(customerRecordTemplateActivity);
					break;
				case Constant.APP_VERSION_ERROR:
					String downloadFileUrl = Constant.SERVER_URL + customerRecordTemplateActivity.getString(R.string.download_apk_address);
					FileCache fileCache = new FileCache(customerRecordTemplateActivity);
					customerRecordTemplateActivity.packageUpdateUtil = new PackageUpdateUtil(customerRecordTemplateActivity, customerRecordTemplateActivity.mHandler, fileCache, downloadFileUrl, false, customerRecordTemplateActivity.userinfoApplication);
					customerRecordTemplateActivity.packageUpdateUtil.getPackageVersionInfo();
					ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
					serverPackageVersion.setPackageVersion((String) message.obj);
					customerRecordTemplateActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
					break;
				case 5:
					((DownloadInfo) message.obj).getUpdateDialog().cancel();
					String filename = "com.glamourpromise.beauty.business.apk";
					File file = customerRecordTemplateActivity.getFileStreamPath(filename);
					file.getName();
					customerRecordTemplateActivity.packageUpdateUtil.showInstallDialog();
					break;
				case -5:
					((DownloadInfo) message.obj).getUpdateDialog().cancel();
					break;
				case 7:
					int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
					((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
					break;
				case 8:
					customerRecordTemplateActivity.refreshList(2);
					break;
			}
			customerRecordTemplateActivity.onLoad();
		}
	}

	private void refreshList(int flag) {
		if(userRole==Constant.USER_ROLE_CUSTOMER){
			int  authAllCustomerRecordInfoWrite=userinfoApplication.getAccountInfo().getAuthAllCustomerRecordInfoWrite();
			if(authAllCustomerRecordInfoWrite==1 || userinfoApplication.getSelectedCustomerResponsiblePersonID()==userinfoApplication.getAccountInfo().getAccountId()){
				requestData(flag);
			}
			else{
				DialogUtil.createShortDialog(this,"你无权限查看顾客的专业记录");
				addNewCustomerRecordBtn.setVisibility(View.GONE);
			}
		}
		else{
			requestData(flag);
		}
	}
	private void   requestData(int flag){
		// 上一次取数据任务还没有完成，不在调用后台
		if (isRefresh)
				return;
		// 取老数据时，已经取完数据不在调用后台
		if (flag == 3 && (pageIndex > pageCount || recordTemplateList.size() < 10)) {
					DialogUtil.createShortDialog(this, "没有更多数据了！");
					onLoad();
					recordTemplateListView.hideFooterView();
					return;
				} else {
					recordTemplateListView.setPullLoadEnable(true);
				}
				isRefresh = true;
				getRecordTemplateListFlag = flag;
				if (flag == 1) {
					if (progressDialog == null) {
						progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
						progressDialog.setMessage(getString(R.string.please_wait));
						progressDialog.setCancelable(false);
					}
					progressDialog.show();
				}
				RecordTemplateListConditionBuilder recordTemplateListConditionBuilder = new RecordTemplateListBaseConditionInfo.RecordTemplateListConditionBuilder();
				int currentPageIndex = 1;
				String updateTime= "";
				if (getRecordTemplateListFlag == 3) {
					currentPageIndex = pageIndex;
					// 传模板列表的第一个UpdateTime
					if (currentPageIndex >= 1)
						updateTime = recordTemplateList.get(0).getRecordTemplateUpdateTime();
				} else if (getRecordTemplateListFlag == 2) {
					initPageIndex();
				}
				recordTemplateListConditionBuilder.setUpdateTime(updateTime).setPageIndex(currentPageIndex).setPageSize(10)
							.setResponsibleID(recordTemplateListBaseConditionInfo.getResponsiblePersonID())
							.setCustomerID(recordTemplateListBaseConditionInfo.getCustomerID())
							.setFilterByTimeFlag(recordTemplateListBaseConditionInfo.getFilterByTimeFlag()).setStartDate(recordTemplateListBaseConditionInfo.getStartDate()).setEndDate(recordTemplateListBaseConditionInfo.getEndDate()).setIsShowAll(recordTemplateListBaseConditionInfo.isShowAll());
			  recordTemplateManager.getRecordTemplateList(mHandler,recordTemplateListConditionBuilder.create(),userinfoApplication);
	}
	protected void dismissDialog(ProgressDialog dialog) {
		if (dialog != null) {
			dialog.dismiss();
			dialog = null;
		}
	}
	private void initPageIndex() {
		pageIndex = 1;
	}
	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
		refreshList(2);
	}
	@Override
	public void onLoadMore() {
		// TODO Auto-generated method stub
		refreshList(3);
	}
	private void onLoad() {
		recordTemplateListView.stopRefresh();
		recordTemplateListView.stopLoadMore();
		recordTemplateListView.setRefreshTime(new Date().toLocaleString());
	}
	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
		String isExit = intent.getStringExtra("exit");
		if (isExit != null && isExit.equals("1")) {
			userinfoApplication.setAccountInfo(null);
			userinfoApplication.setSelectedCustomerID(0);
			userinfoApplication.setSelectedCustomerName("");
			userinfoApplication.setSelectedCustomerHeadImageURL("");
			userinfoApplication.setSelectedCustomerLoginMobile("");
			userinfoApplication.setAccountNewMessageCount(0);
			userinfoApplication.setAccountNewRemindCount(0);
			userinfoApplication.setOrderInfo(null);
			Constant.formalFlag = 0;
			finish();
		} else {
			userRole = intent.getIntExtra("USER_ROLE",1);
			if(recordTemplateListBaseConditionInfo==null)
				recordTemplateListBaseConditionInfo=new RecordTemplateListBaseConditionInfo();
			recordTemplateListBaseConditionInfo.setFilterByTimeFlag(0);
			recordTemplateListBaseConditionInfo.setResponsiblePersonID("");
			if(userRole==Constant.USER_ROLE_BUSINESS){
				addNewCustomerRecordBtn.setVisibility(View.GONE);
				recordTemplateListBaseConditionInfo.setShowAll(false);
				recordTemplateListBaseConditionInfo.setCustomerID(0);
			}
			else if(userRole==Constant.USER_ROLE_CUSTOMER){
				recordTemplateListBaseConditionInfo.setShowAll(true);
				recordTemplateListBaseConditionInfo.setCustomerID(userinfoApplication.getSelectedCustomerID());
			}
			initPageIndex();
			refreshList(1);
		}
	}
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		super.onActivityResult(requestCode, resultCode, data);
		if(resultCode != RESULT_OK){
			return;
		}
		
		if(requestCode == 2){
			initPageIndex();
			refreshList(1);
		}
	}
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		// TODO Auto-generated method stub
		RecordTemplate rt=recordTemplateList.get(position-1);
		Intent destIntent=null;
		if(rt.isTemp()){
			destIntent=new Intent(this,AddNewCustomerVocationActivity.class);
			Bundle bundle=new Bundle();
			bundle.putSerializable("recordTemplate",rt);
			destIntent.putExtras(bundle);
		}
		else{
			destIntent=new Intent(this,CustomerRecordActivity.class);
			Bundle bundle=new Bundle();
			bundle.putSerializable("recordTemplate",rt);
			destIntent.putExtras(bundle);
		}
		startActivity(destIntent);
	}
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if(v.getId()==R.id.add_new_customer_record_btn){
			Intent destIntent=new Intent(this,ChooseCustomerRecordTemplateActivity.class);
			startActivity(destIntent);
		}
		else if(v.getId()==R.id.customer_record_advanced_search_btn){
			Intent destIntent = new Intent(this,OrderAdvancedSearchActivity.class);
			destIntent.putExtra("ConditionFlag",OrderAdvancedSearchActivity.RECORD_CONDITION);
			destIntent.putExtra("AccountID",userinfoApplication.getAccountInfo().getAccountId());
			if(userRole==Constant.USER_ROLE_CUSTOMER)
				destIntent.putExtra("IsByCustomer",true);
			startActivityForResult(destIntent,2);
		}
	}
	public static void setAdvancedCondition(AdvancedSearchCondition advancedCondition,boolean isByCustomer) {
		if(recordTemplateListBaseConditionInfo==null)
			recordTemplateListBaseConditionInfo=new RecordTemplateListBaseConditionInfo();
		recordTemplateListBaseConditionInfo.setCustomerID(advancedCondition.getCustomerID());
		recordTemplateListBaseConditionInfo.setResponsiblePersonID(advancedCondition.getResponsiblePersonID());
		recordTemplateListBaseConditionInfo.setFilterByTimeFlag(advancedCondition.getFilterByTimeFlag());
		if(isByCustomer)
			recordTemplateListBaseConditionInfo.setShowAll(true);
		else
			recordTemplateListBaseConditionInfo.setShowAll(false);
		if(advancedCondition.getFilterByTimeFlag()==1){
			recordTemplateListBaseConditionInfo.setStartDate(advancedCondition.getStartDate());
			recordTemplateListBaseConditionInfo.setEndDate(advancedCondition.getEndDate());
		}
		
	}
	@Override
	public void click(View v) {
		// TODO Auto-generated method stub
		//progressDialog.show();
		final RecordTemplate rt=recordTemplateList.get((Integer) v.getTag());
		new  AlertDialog.Builder(this)   
		.setTitle(String.valueOf("确认"))   
		.setMessage("确定删除该条纪录吗？" )  
		.setPositiveButton("确定" , new DialogInterface.OnClickListener() {
			 @Override  
			 public void onClick(DialogInterface dialog,int which) { 
					delAnswerJson=new JSONObject();
					try {
						delAnswerJson.put("GroupID",rt.getGroupID());
					} catch (JSONException e) {
						e.printStackTrace();
					}
					requestWebServiceThread = new Thread() {
						@Override
						public void run() {
							String methodName ="DelAnswer";
							String endPoint = "Paper";
							String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,delAnswerJson.toString(),userinfoApplication);
							JSONObject resultJson = null;
							try {
								resultJson = new JSONObject(serverResultResult);
							} catch (JSONException e1) {
							}
							if (serverResultResult == null || serverResultResult.equals(""))
								mHandler.sendEmptyMessage(2);
							else {
								String code = "0";
								try {
									code = resultJson.getString("Code");
								} catch (JSONException e) {
									code = "0";
								}
								if (Integer.parseInt(code) == 1) {
									mHandler.sendEmptyMessage(8);
								}
								else if(Integer.parseInt(code)==Constant.APP_VERSION_ERROR || Integer.parseInt(code)==Constant.LOGIN_ERROR)
									mHandler.sendEmptyMessage(Integer.parseInt(code));
								else 
									mHandler.sendEmptyMessage(0);
							}
						}
					};
					requestWebServiceThread.start();
			 }
		})
		.setNegativeButton("取消" , null)   
		.show();

		
	}
}
