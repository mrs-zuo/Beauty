package com.GlamourPromise.Beauty.Business;

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
import android.widget.Button;
import android.widget.SearchView;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.ServiceListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.ServiceInfo;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.minterface.RefreshListViewWithWebservice;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.RefreshListView;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
public class ServiceListActivity extends BaseActivity implements OnItemClickListener, OnClickListener,OnQueryTextListener {
	private ServiceListActivityHandler mhandler = new ServiceListActivityHandler(this);
	private static final  String  TAG="ServiceListActivity";
	private RefreshListView   serviceListView;
	private List<ServiceInfo> serviceList,searchResult;
	private Thread         requestWebServiceThread;
	private String         categoryID;
	private SearchView     searchServiceView;
	private ProgressDialog progressDialog;
	private UserInfoApplication userinfoApplication;
	public  ServiceListAdapter  serviceListAdapter;
	private TextView  serviceListTitleText;
	private String    categroyName;
	private RefreshListViewWithWebservice refreshListViewWithWebService;
	private PackageUpdateUtil packageUpdateUtil;
	private Button            chooseServiceMakeSureBtn;
	private List<OrderProduct> orderProductList;
	int fromSource=0;
	private static final int APPOINTMENT_TO_SERVICE=3;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_service_list);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		Intent intent = getIntent();
		categoryID = intent.getStringExtra("CategoryID");
		categroyName=intent.getStringExtra("CategoryName");
		fromSource=intent.getIntExtra("FROM_SOURCE",0);
		serviceListView = (RefreshListView) findViewById(R.id.service_listview);
		serviceListView.setOnItemClickListener(this);
		refreshListViewWithWebService = new RefreshListViewWithWebservice() {

			@Override
			public Object refreshing() {
				// TODO Auto-generated method stub
				String returncode = "ok";
				if(requestWebServiceThread==null){
					requestWebService();
				}
				return returncode;
			}

			@Override
			public void refreshed(Object obj) {

			}

		};
		serviceListView.setOnRefreshListener(refreshListViewWithWebService);
		//服务搜索视图
		searchServiceView = (SearchView) findViewById(R.id.search_service);
		searchServiceView.setOnQueryTextListener(this);
		chooseServiceMakeSureBtn=(Button) findViewById(R.id.choose_service_make_sure_btn);
		chooseServiceMakeSureBtn.setOnClickListener(this);
		if(fromSource==APPOINTMENT_TO_SERVICE)
			chooseServiceMakeSureBtn.setVisibility(View.GONE);
		else
			chooseServiceMakeSureBtn.setVisibility(View.VISIBLE);
			
		userinfoApplication=UserInfoApplication.getInstance();
		OrderInfo orderInfo = userinfoApplication.getOrderInfo();
		if (orderInfo == null)
			orderInfo = new OrderInfo();
		orderProductList = orderInfo.getOrderProductList();
		if (orderProductList == null)
			orderProductList = new ArrayList<OrderProduct>();
		userinfoApplication.setOrderInfo(orderInfo);
		userinfoApplication.getOrderInfo().setOrderProductList(orderProductList);
		initView();
	}

	private static class ServiceListActivityHandler extends Handler {
		private final ServiceListActivity serviceListActivity;

		private ServiceListActivityHandler(ServiceListActivity activity) {
			WeakReference<ServiceListActivity> weakReference = new WeakReference<ServiceListActivity>(activity);
			serviceListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (serviceListActivity.progressDialog != null) {
				serviceListActivity.progressDialog.dismiss();
				serviceListActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				if (serviceListActivity.searchResult == null) {
					serviceListActivity.searchResult = new ArrayList<ServiceInfo>();
				} else {
					serviceListActivity.searchResult.clear();
				}
				for (ServiceInfo serviceInfo : serviceListActivity.serviceList) {
					serviceListActivity.searchResult.add(serviceInfo);
				}
				serviceListActivity.serviceListAdapter = new ServiceListAdapter(serviceListActivity, serviceListActivity.searchResult, serviceListActivity.fromSource);
				serviceListActivity.serviceListView.setAdapter(serviceListActivity.serviceListAdapter);
			} else if (msg.what == 0)
				DialogUtil.createShortDialog(serviceListActivity, "您的网络貌似不给力，请重试");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(serviceListActivity, serviceListActivity.getString(R.string.login_error_message));
				serviceListActivity.userinfoApplication.exitForLogin(serviceListActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + serviceListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(serviceListActivity);
				serviceListActivity.packageUpdateUtil = new PackageUpdateUtil(serviceListActivity, serviceListActivity.mhandler, fileCache, downloadFileUrl, false, serviceListActivity.userinfoApplication);
				serviceListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				serviceListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = serviceListActivity.getFileStreamPath(filename);
				file.getName();
				serviceListActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (serviceListActivity.requestWebServiceThread != null) {
				serviceListActivity.requestWebServiceThread.interrupt();
				serviceListActivity.requestWebServiceThread = null;
			}
			System.gc();
		}
	}

	protected void initView() {
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		serviceListTitleText=(TextView)findViewById(R.id.service_list_title_text);
		if(categroyName==null || ("").equals(categroyName))
			serviceListTitleText.setText("服务(全部)");
		else
			serviceListTitleText.setText("服务("+categroyName+")");
		int authMyOrderWrite=userinfoApplication.getAccountInfo().getAuthMyOrderWrite();
		if(authMyOrderWrite==0)
			chooseServiceMakeSureBtn.setVisibility(View.GONE);
		requestWebService();
	}
	protected void requestWebService(){
		serviceList = new ArrayList<ServiceInfo>();
		final int screenWidth=userinfoApplication.getScreenWidth();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				String endPoint = "service";
				String methodName = "";
				JSONObject serviceJsonParam=new JSONObject();
				try {
					if (!categoryID.equals("0")) {
						methodName = "getServiceListByCategoryID";
						serviceJsonParam.put("CategoryID",categoryID);
					} else {
						methodName = "getServiceListByCompanyID";
					}
					serviceJsonParam.put("CustomerID",String.valueOf(userinfoApplication.getSelectedCustomerID()));
					if(screenWidth==720)
					{
						serviceJsonParam.put("ImageWidth","110");
						serviceJsonParam.put("ImageHeight","110");
					}
					else if(screenWidth == 480){
						serviceJsonParam.put("ImageWidth", "80");
						serviceJsonParam.put("ImageHeight", "80");
					}
					else if(screenWidth == 1080){
						serviceJsonParam.put("ImageWidth", "160");
						serviceJsonParam.put("ImageHeight", "160");
					}
					else if(screenWidth == 1536){
						serviceJsonParam.put("ImageWidth", "185");
						serviceJsonParam.put("ImageHeight", "185");
					}
					else{
						serviceJsonParam.put("ImageWidth", "80");
						serviceJsonParam.put("ImageHeight", "80");
					}
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,serviceJsonParam.toString(),userinfoApplication);
				if(serverRequestResult==null || serverRequestResult.equals(""))
					mhandler.sendEmptyMessage(0);
				else{
					JSONObject resultJson=null;
					JSONArray  serviceArray=null;
					int code=0;
					try {
						resultJson=new JSONObject(serverRequestResult);
						code=resultJson.getInt("Code");
					} catch (JSONException e) {
						code=0;
					}
					if(code==1){
						try {
							serviceArray=resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						if(serviceArray!=null){
							for (int i = 0; i < serviceArray.length(); i++) {
								JSONObject serviceJson=null;
								try {
									serviceJson=serviceArray.getJSONObject(i);
								} catch (JSONException e) {
								}
								ServiceInfo serviceInfo = new ServiceInfo();
								long serviceCode = 0;
								int serviceID = 0;
								String serviceName = "";
								int marketingPolicy = 0;
								int favoriteID=0;
								String unitPrice = "0";
								String promotionPrice = "0";
								String thumbnailUrl = "";
								String searchField="";
								String expirationDate="";
								try {
									if (serviceJson.has("ServiceCode") && !serviceJson.isNull("ServiceCode"))
										serviceCode = serviceJson.getLong("ServiceCode");
									if (serviceJson.has("ServiceID") && !serviceJson.isNull("ServiceID"))
										serviceID = serviceJson.getInt("ServiceID");
									if (serviceJson.has("ServiceName") && !serviceJson.isNull("ServiceName"))
										serviceName = serviceJson.getString("ServiceName");
									if (serviceJson.has("MarketingPolicy") && !serviceJson.isNull("MarketingPolicy"))
										marketingPolicy =serviceJson.getInt("MarketingPolicy");
									if (serviceJson.has("UnitPrice") && !serviceJson.isNull("UnitPrice"))
										unitPrice = serviceJson.getString("UnitPrice");
									if (serviceJson.has("PromotionPrice") && !serviceJson.isNull("PromotionPrice"))
										promotionPrice = serviceJson.getString("PromotionPrice");
									if (serviceJson.has("ThumbnailURL") && !serviceJson.isNull("ThumbnailURL"))
										thumbnailUrl = serviceJson.getString("ThumbnailURL");
									if(serviceJson.has("FavoriteID") && !serviceJson.isNull("FavoriteID"))
										favoriteID=serviceJson.getInt("FavoriteID");
									if(serviceJson.has("ExpirationTime") && !serviceJson.isNull("ExpirationTime"))
										expirationDate=serviceJson.getString("ExpirationTime");
									if(serviceJson.has("SearchField") && !serviceJson.isNull("SearchField"))
										searchField=serviceJson.getString("SearchField");
								} catch (JSONException e) {
									
								}
								serviceInfo.setServiceCode(serviceCode);
								serviceInfo.setServiceID(serviceID);
								serviceInfo.setServiceName(serviceName);
								serviceInfo.setUnitPrice(unitPrice);
								serviceInfo.setMarketingPolicy(marketingPolicy);
								serviceInfo.setFavoriteID(favoriteID);
								serviceInfo.setExpirationDate(expirationDate);
								serviceInfo.setPromotionPrice(promotionPrice);
								serviceInfo.setThumbnail(thumbnailUrl);
								serviceInfo.setSearchField(searchField);
								serviceList.add(serviceInfo);
							}
						}
						mhandler.sendEmptyMessage(1);
					}
					else
						mhandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		Intent destIntent;
		if(fromSource==APPOINTMENT_TO_SERVICE){
			destIntent=new Intent();
			destIntent.putExtra("serviceID", serviceList.get(position-1).getServiceID());
			destIntent.putExtra("serviceName", serviceList.get(position-1).getServiceName());
			destIntent.putExtra("serviceCode", serviceList.get(position-1).getServiceCode());
			setResult(RESULT_OK, destIntent);
			this.finish();
		}else{
			destIntent = new Intent(this, ServiceDetailActivity.class);
			if(searchResult!=null && searchResult.size()>0){
				destIntent.putExtra("serviceCode", searchResult.get(position-1).getServiceCode());
			}
			else{
				destIntent.putExtra("serviceCode", serviceList.get(position-1).getServiceCode());
			}
			destIntent.putExtra("CategoryID",categoryID);
			destIntent.putExtra("CategoryName",categroyName);
			destIntent.putExtra("resAcvitityname","ServiceListActivity");
			startActivity(destIntent);
			this.finish();
		}
	}
	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.choose_service_make_sure_btn:
			//将选中的服务列表加入到待开单列表
			List<OrderProduct> selectedServiceList=serviceListAdapter.getSelectedServiceList();
			if(selectedServiceList==null || selectedServiceList.size()==0)
				DialogUtil.createShortDialog(this,"请选择需要开单的服务");
			else
			{
				for(OrderProduct op:selectedServiceList){
					if(!orderProductList.contains(op))
						orderProductList.add(op);
				}
				Intent destIntent=new Intent(this,CustomerServicingActivity.class);
				destIntent.putExtra("currentItem",0);
				startActivity(destIntent);
			}
			break;
		}
	}
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		requestWebService();
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
	@Override
	public boolean onQueryTextSubmit(String query) {
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public boolean onQueryTextChange(String newText) {
		// TODO Auto-generated method stub
		newText = newText.toLowerCase();
		searchService(newText);
		updateLayout();
		return false;
	}

	private void searchService(String searchKeyWord) {
		if(searchResult==null){
			searchResult=new ArrayList<ServiceInfo>();
		}
		else{
			searchResult.clear();
		}
		if(searchKeyWord!=null && !(("").equals(searchKeyWord))){
			for (ServiceInfo service :serviceList) {
				if(service.getSearchField()!=null && !(("").equals(service.getSearchField()))){
					if (service.getSearchField().toLowerCase().contains(searchKeyWord.toLowerCase())) {
						searchResult.add(service);
					}
				}
			}
		}else{
			searchResult.addAll(serviceList);
		}
	}
	private void updateLayout() {
		if(serviceListAdapter==null){
			serviceListAdapter = new ServiceListAdapter(this,searchResult,fromSource);
			serviceListView.setAdapter(serviceListAdapter);
		}
		else{
			serviceListAdapter.notifyDataSetChanged();
		}
	}
}
