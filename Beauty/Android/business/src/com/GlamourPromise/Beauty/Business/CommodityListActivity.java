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

import com.GlamourPromise.Beauty.adapter.CommodityListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CommodityInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
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

public class CommodityListActivity extends BaseActivity implements
		OnItemClickListener, OnClickListener, OnQueryTextListener {
	private CommodityListActivityHandler mhandler = new CommodityListActivityHandler(this);
	private RefreshListView commodityListView;
	private List<CommodityInfo> commodityList = null, searchResult;
	private Thread requestWebServiceThread;
	private String categoryID;
	private SearchView searchCommodityView;
	private ProgressDialog progressDialog;
	private UserInfoApplication userinfoApplication;
	public CommodityListAdapter commodityListAdapter;
	private TextView commodityListTitle;
	private String categoryName;
	private RefreshListViewWithWebservice refreshListViewWithWebService;
	private PackageUpdateUtil packageUpdateUtil;
	private Button chooseCommodityMakeSureBtn;
	private List<OrderProduct> orderProductList;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_commodity_list);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		Intent intent = getIntent();
		categoryID = intent.getStringExtra("CategoryID");
		categoryName = intent.getStringExtra("CategoryName");
		commodityListView = (RefreshListView) findViewById(R.id.commodity_listview);
		commodityListView.setOnItemClickListener(this);
		refreshListViewWithWebService = new RefreshListViewWithWebservice() {

			@Override
			public Object refreshing() {
				// TODO Auto-generated method stub
				String returncode = "ok";
				if (requestWebServiceThread == null) {
					requestWebService();
				}
				return returncode;
			}

			@Override
			public void refreshed(Object obj) {

			}

		};
		commodityListView.setOnRefreshListener(refreshListViewWithWebService);
		// 商品搜索视图
		searchCommodityView = (SearchView) findViewById(R.id.search_commodity);
		searchCommodityView.setOnQueryTextListener(this);
		chooseCommodityMakeSureBtn = (Button) findViewById(R.id.choose_commodity_make_sure_btn);
		chooseCommodityMakeSureBtn.setOnClickListener(this);
		userinfoApplication = UserInfoApplication.getInstance();
		OrderInfo orderInfo = userinfoApplication.getOrderInfo();
		if (orderInfo == null)
			orderInfo = new OrderInfo();
		orderProductList = orderInfo.getOrderProductList();
		if (orderProductList == null)
			orderProductList = new ArrayList<OrderProduct>();
		userinfoApplication.setOrderInfo(orderInfo);
		userinfoApplication.getOrderInfo()
				.setOrderProductList(orderProductList);
		initView();
	}

	private static class CommodityListActivityHandler extends Handler {
		private final CommodityListActivity commodityListActivity;

		private CommodityListActivityHandler(CommodityListActivity activity) {
			WeakReference<CommodityListActivity> weakReference = new WeakReference<CommodityListActivity>(activity);
			commodityListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (commodityListActivity.progressDialog != null) {
				commodityListActivity.progressDialog.dismiss();
				commodityListActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				if (commodityListActivity.searchResult == null) {
					commodityListActivity.searchResult = new ArrayList<CommodityInfo>();
				} else {
					commodityListActivity.searchResult.clear();
				}
				for (CommodityInfo commodityInfo : commodityListActivity.commodityList) {
					commodityListActivity.searchResult.add(commodityInfo);
				}
				commodityListActivity.commodityListAdapter = new CommodityListAdapter(
						commodityListActivity, commodityListActivity.searchResult);
				commodityListActivity.commodityListView.setAdapter(commodityListActivity.commodityListAdapter);
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(commodityListActivity,
						"您的网络貌似不给力，请重试");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(commodityListActivity,
						commodityListActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(
						commodityListActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL
						+ commodityListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(commodityListActivity);
				commodityListActivity.packageUpdateUtil = new PackageUpdateUtil(
						commodityListActivity, commodityListActivity.mhandler, fileCache,
						downloadFileUrl, false, commodityListActivity.userinfoApplication);
				commodityListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				commodityListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			// 包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = commodityListActivity.getFileStreamPath(filename);
				file.getName();
				commodityListActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj)
						.getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(
						downLoadFileSize);
			}
			if (commodityListActivity.requestWebServiceThread != null) {
				commodityListActivity.requestWebServiceThread.interrupt();
				commodityListActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {

		progressDialog = new ProgressDialog(this,
				R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		commodityListTitle = (TextView) findViewById(R.id.commodity_list_title_text);
		if (categoryName == null || ("").equals(categoryName))
			commodityListTitle.setText("商品(全部)");
		else
			commodityListTitle.setText("商品(" + categoryName + ")");
		int authMyOrderWrite = userinfoApplication.getAccountInfo()
				.getAuthMyOrderWrite();
		if (authMyOrderWrite == 0)
			chooseCommodityMakeSureBtn.setVisibility(View.GONE);
		requestWebService();
	}

	protected void requestWebService() {

		commodityList = new ArrayList<CommodityInfo>();
		final int screenWidth = userinfoApplication.getScreenWidth();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				String endPoint = "Commodity";
				String methodName = "";
				JSONObject commodityJsonParam = new JSONObject();
				try {
					if (!categoryID.equals("0")) {
						methodName = "getCommodityListByCategoryID";
						commodityJsonParam.put("CategoryID", categoryID);
					} else {
						methodName = "getCommodityListByCompanyID";
					}
					if (screenWidth == 720) {
						commodityJsonParam.put("ImageWidth", "110");
						commodityJsonParam.put("ImageHeight", "110");
					} else if (screenWidth == 480) {
						commodityJsonParam.put("ImageWidth", "80");
						commodityJsonParam.put("ImageHeight", "80");
					} else if (screenWidth == 1080) {
						commodityJsonParam.put("ImageWidth", "160");
						commodityJsonParam.put("ImageHeight", "160");
					} else if (screenWidth == 1536) {
						commodityJsonParam.put("ImageWidth", "185");
						commodityJsonParam.put("ImageHeight", "185");
					} else {
						commodityJsonParam.put("ImageWidth", "80");
						commodityJsonParam.put("ImageHeight", "80");
					}
					commodityJsonParam.put("CustomerID", String
							.valueOf(userinfoApplication
									.getSelectedCustomerID()));
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil
						.requestWebServiceWithSSLUseJson(endPoint, methodName,
								commodityJsonParam.toString(),
								userinfoApplication);
				if (serverRequestResult == null
						|| serverRequestResult.equals(""))
					mhandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson = null;
					JSONArray commodityArray = null;
					int code = 0;
					try {
						resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
					} catch (JSONException e) {
						code = 0;
					}
					if (code == 1) {
						try {
							commodityArray = resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						if (commodityArray != null) {
							for (int i = 0; i < commodityArray.length(); i++) {
								JSONObject commodityJson = null;
								try {
									commodityJson = commodityArray
											.getJSONObject(i);
								} catch (JSONException e) {
								}
								CommodityInfo commodityInfo = new CommodityInfo();
								String commodityID = "0";
								String unitPrice = "0";
								String promotionPrice = "0";
								String commodityName = "";
								String isNew = "";
								String isRecommended = "";
								String specification = "";
								String thumbnailUrl = "";
								int marketingPolicy = 0;
								long commodityCode = 0;
								int favoriteID = 0;
								String searchField = "";
								try {
									if (commodityJson.has("CommodityID")
											&& !commodityJson
													.isNull("CommodityID"))
										commodityID = commodityJson
												.getString("CommodityID");
									if (commodityJson.has("UnitPrice")
											&& !commodityJson
													.isNull("UnitPrice"))
										unitPrice = commodityJson
												.getString("UnitPrice");
									if (commodityJson.has("PromotionPrice")
											&& !commodityJson
													.isNull("PromotionPrice"))
										promotionPrice = commodityJson
												.getString("PromotionPrice");

									if (commodityJson.has("CommodityName")
											&& !commodityJson
													.isNull("CommodityName"))
										commodityName = commodityJson
												.getString("CommodityName");

									if (commodityJson.has("New")
											&& !commodityJson.isNull("New"))
										isNew = commodityJson.getString("New");

									if (commodityJson.has("Recommended")
											&& !commodityJson
													.isNull("Recommended"))
										isRecommended = commodityJson
												.getString("Recommended");

									if (commodityJson.has("Specification")
											&& !commodityJson
													.isNull("Specification"))
										specification = commodityJson
												.getString("Specification");

									if (commodityJson.has("ThumbnailURL")
											&& !commodityJson
													.isNull("ThumbnailURL"))
										thumbnailUrl = commodityJson
												.getString("ThumbnailURL");

									if (commodityJson.has("MarketingPolicy")
											&& !commodityJson
													.isNull("MarketingPolicy"))
										marketingPolicy = commodityJson
												.getInt("MarketingPolicy");

									if (commodityJson.has("CommodityCode")
											&& !commodityJson
													.isNull("CommodityCode"))
										commodityCode = commodityJson
												.getLong("CommodityCode");
									if (commodityJson.has("FavoriteID")
											&& !commodityJson
													.isNull("FavoriteID"))
										favoriteID = commodityJson
												.getInt("FavoriteID");

									if (commodityJson.has("SearchField")
											&& !commodityJson
													.isNull("SearchField"))
										searchField = commodityJson
												.getString("SearchField");
								} catch (JSONException e) {
								}
								commodityInfo.setCommodityID(commodityID);
								commodityInfo.setUnitPrice(unitPrice);
								commodityInfo.setPromotionPrice(promotionPrice);
								commodityInfo.setCommodityName(commodityName);
								commodityInfo.setIsNew(isNew);
								commodityInfo.setRecommended(isRecommended);
								commodityInfo.setSpecification(specification);
								commodityInfo.setThumbnailUrl(thumbnailUrl);
								commodityInfo
										.setMarketingPolicy(marketingPolicy);
								commodityInfo.setFavoriteID(favoriteID);
								commodityInfo.setCommodityCode(commodityCode);
								commodityInfo.setSearchField(searchField);
								commodityList.add(commodityInfo);
							}
						}
						mhandler.sendEmptyMessage(1);
					} else
						mhandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		// TODO Auto-generated method stub
		if (position != 0) {
			Intent destIntent = new Intent(this, CommodityDetailActivity.class);
			if(searchResult!=null && searchResult.size()>0){
				destIntent.putExtra("commodityCode", searchResult.get(position - 1).getCommodityCode());
			}
			else{
				destIntent.putExtra("commodityCode", commodityList.get(position - 1).getCommodityCode());
			}
			destIntent.putExtra("CategoryID", categoryID);
			destIntent.putExtra("CategoryName", categoryName);
			destIntent.putExtra("resAcvitityname", "CommodityListActivity");
			startActivity(destIntent);
			this.finish();
		}
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch (view.getId()) {
		case R.id.choose_commodity_make_sure_btn:
			List<OrderProduct> selectedCommodityList = commodityListAdapter
					.getSelectedCommodityList();
			if (selectedCommodityList == null
					|| selectedCommodityList.size() == 0)
				DialogUtil.createShortDialog(this, "请选择需要开单的商品");
			else {
				for (OrderProduct op : selectedCommodityList) {
					if (!orderProductList.contains(op))
						orderProductList.add(op);
				}
				Intent destIntent = new Intent(this,
						CustomerServicingActivity.class);
				destIntent.putExtra("currentItem", 0);
				startActivity(destIntent);
			}
			break;
		}
	}

	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		initView();
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
	public boolean onQueryTextSubmit(String query) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean onQueryTextChange(String newText) {
		// TODO Auto-generated method stub
		newText = newText.toLowerCase();
		searchCommodity(newText);
		updateLayout();
		return false;
	}

	private void searchCommodity(String searchKeyWord) {
		if (searchResult == null) {
			searchResult = new ArrayList<CommodityInfo>();
		} else {
			searchResult.clear();
		}
		if (searchKeyWord != null && !(("").equals(searchKeyWord))) {
			for (CommodityInfo commodityInfo : commodityList) {
				if (commodityInfo.getSearchField().toLowerCase()
						.contains(searchKeyWord.toLowerCase())) {
					searchResult.add(commodityInfo);
				}
			}
		} else {
			searchResult.addAll(commodityList);
		}
	}

	private void updateLayout() {
		if (commodityListAdapter == null) {
			commodityListAdapter = new CommodityListAdapter(this, searchResult);
			commodityListView.setAdapter(commodityListAdapter);
		} else {
			commodityListAdapter.notifyDataSetChanged();
		}
	}
}
