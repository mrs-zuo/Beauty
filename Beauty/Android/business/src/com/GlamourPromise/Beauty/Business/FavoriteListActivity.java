package com.GlamourPromise.Beauty.Business;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.GlamourPromise.Beauty.adapter.FavoriteListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.FavoriteInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class FavoriteListActivity extends BaseActivity implements
		OnItemClickListener {
	private FavoriteListActivityHandler mhandler = new FavoriteListActivityHandler(this);
	private ListView favoriteListView;
	private List<FavoriteInfo> favoriteList;
	private UserInfoApplication userinfoApplication;
	private Thread requestWebServiceThread;
	public static FavoriteListAdapter favoriteListAdapter;
	private PackageUpdateUtil packageUpdateUtil;
	private int productType = -1;

	private static class FavoriteListActivityHandler extends Handler {
		private final FavoriteListActivity favoriteListActivity;

		private FavoriteListActivityHandler(FavoriteListActivity activity) {
			WeakReference<FavoriteListActivity> weakReference = new WeakReference<FavoriteListActivity>(activity);
			favoriteListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
				case 1:
					favoriteListAdapter = new FavoriteListAdapter(favoriteListActivity, favoriteListActivity.favoriteList);
					favoriteListActivity.favoriteListView.setAdapter(favoriteListAdapter);
					break;
				case 3:
					DialogUtil.createShortDialog(favoriteListActivity, msg.obj.toString());
					break;
				case 4:
					DialogUtil.createShortDialog(favoriteListActivity, msg.obj.toString());
					favoriteListActivity.initView();
					break;
				case Constant.LOGIN_ERROR:
					DialogUtil.createShortDialog(favoriteListActivity,
							favoriteListActivity.getString(R.string.login_error_message));
					UserInfoApplication.getInstance().exitForLogin(
							favoriteListActivity);
					break;
				case Constant.APP_VERSION_ERROR:
					String downloadFileUrl = Constant.SERVER_URL + favoriteListActivity.getString(R.string.download_apk_address);
					FileCache fileCache = new FileCache(favoriteListActivity);
					favoriteListActivity.packageUpdateUtil = new PackageUpdateUtil(favoriteListActivity, favoriteListActivity.mhandler, fileCache, downloadFileUrl, false, favoriteListActivity.userinfoApplication);
					favoriteListActivity.packageUpdateUtil.getPackageVersionInfo();
					ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
					serverPackageVersion.setPackageVersion((String) msg.obj);
					favoriteListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
					break;
				case 5:
					((DownloadInfo) msg.obj).getUpdateDialog().cancel();
					String filename = "com.glamourpromise.beauty.business.apk";
					File file = favoriteListActivity.getFileStreamPath(filename);
					file.getName();
					favoriteListActivity.packageUpdateUtil.showInstallDialog();
					break;
				case -5:
					((DownloadInfo) msg.obj).getUpdateDialog().cancel();
					break;
				case 7:
					int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
					((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
					break;
				default:
					break;
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_favorite_list);
		initView();
	}

	@Override
	protected void onRestart() {
		super.onRestart();
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
		// TODO Auto-generated method stub
		final int pos = arg2;
		if (favoriteList.get(arg2).isAvailable() == false) {
			Dialog dialog = new AlertDialog.Builder(this,R.style.CustomerAlertDialog)
					.setTitle(getString(R.string.delete_dialog_title))
					.setMessage(R.string.disable_service_or_commodity_delete_favorite_message)
					.setPositiveButton(getString(R.string.delete_confirm),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									dialog.dismiss();
									// TODO Auto-generated method stub
									requestWebServiceThread = new Thread() {
										@Override
										public void run() {
											// TODO Auto-generated method stub
											String methodName = "delFavorite";
											String endPoint = "account";
											JSONObject delFavoriteJsonParam=new JSONObject();
											try {
												delFavoriteJsonParam.put("FavoriteID", favoriteList.get(pos)
														.getFavoriteID());
											} catch (JSONException e) {
											}
											String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,delFavoriteJsonParam.toString(),userinfoApplication);
											if (serverRequestResult == null || serverRequestResult.equals(""))
												mhandler.sendEmptyMessage(2);
											else {
												int code=0;
												JSONObject delFavoriteJson=null;
												try {
													delFavoriteJson=new JSONObject(serverRequestResult);
													code=delFavoriteJson.getInt("Code");
												} catch (JSONException e) {
												}
												String returnMessage="";
												if (code==1) {
														try {
															returnMessage=delFavoriteJson.getString("Message");
														} catch (JSONException e) {
															returnMessage="";
														}
													mhandler.obtainMessage(4, returnMessage).sendToTarget();
												} else{
													try {
														returnMessage=delFavoriteJson.getString("Message");
													} catch (JSONException e) {
														returnMessage="";
													}
													mhandler.obtainMessage(3, returnMessage).sendToTarget();
												}
											}
										}
									};
									requestWebServiceThread.start();
								}
							})
					.setNegativeButton(getString(R.string.delete_cancel),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method stub
									dialog.dismiss();
									dialog = null;
								}
							}).create();
			dialog.show();
			dialog.setCancelable(false);
		} else {
			Intent destIntent = null;
			// 服务
			if (favoriteList.get(arg2).getProductType()==0) {
				destIntent = new Intent(this, ServiceDetailActivity.class);
				destIntent.putExtra("serviceCode", Long.valueOf(favoriteList.get(arg2).getProductCode()));
				destIntent.putExtra("CategoryID", "0");
				destIntent.putExtra("CategoryName", "");
			} else if (favoriteList.get(arg2).getProductType()==1) {
				destIntent = new Intent(this, CommodityDetailActivity.class);
				destIntent.putExtra("commodityCode",Long.valueOf(favoriteList.get(arg2).getProductCode()));
				destIntent.putExtra("CategoryID", "0");
				destIntent.putExtra("CategoryName", "");
			}
			destIntent.putExtra("resAcvitityname", "FavoriteListActivity");
			startActivity(destIntent);
		}
	}

	public void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		favoriteListView = (ListView) findViewById(R.id.favorite_listview);
		favoriteListView.setOnItemClickListener(this);
		favoriteList = new ArrayList<FavoriteInfo>();
		userinfoApplication = (UserInfoApplication) getApplication();
		getFavoriteListData(requestWebServiceThread,mhandler);
	}
	private void getFavoriteListData(Thread requestWebServiceThread,
			Handler mHandler) {
		final Handler handler = mHandler;
		final int screenWidth = userinfoApplication.getScreenWidth();
		int authServiceRead = userinfoApplication.getAccountInfo()
				.getAuthServiceRead();
		int authCommodityRead = userinfoApplication.getAccountInfo()
				.getAuthCommodityRead();
		if (authServiceRead != 0 || authCommodityRead != 0) {
			if (authServiceRead == 1 && authCommodityRead == 0)
				productType = 0;
			else if (authServiceRead == 0 && authCommodityRead == 1)
				productType = 1;
			else if (authServiceRead == 1 && authCommodityRead == 1)
				productType = -1;
			requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					String methodName = "getFavoriteList";
					String endPoint = "Account";
					JSONObject favoriteJsonParam=new JSONObject();
					try {
						favoriteJsonParam.put("ProductType", String.valueOf(productType));
						favoriteJsonParam.put("CustomerID",userinfoApplication.getSelectedCustomerID());
						if (screenWidth == 720) {
							favoriteJsonParam.put("ImageWidth", "110");
							favoriteJsonParam.put("ImageHeight", "110");
						} else if (screenWidth == 480) {
							favoriteJsonParam.put("ImageWidth", "80");
							favoriteJsonParam.put("ImageHeight", "80");
						} else if (screenWidth == 1080) {
							favoriteJsonParam.put("ImageWidth", "160");
							favoriteJsonParam.put("ImageHeight", "160");
						} else if (screenWidth == 1536) {
							favoriteJsonParam.put("ImageWidth", "185");
							favoriteJsonParam.put("ImageHeight", "185");
						} else {
							favoriteJsonParam.put("ImageWidth", "80");
							favoriteJsonParam.put("ImageHeight", "80");
						}
					} catch (JSONException e) {
						
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,favoriteJsonParam.toString(),userinfoApplication);
					if (serverRequestResult == null || serverRequestResult.equals(""))
						handler.sendEmptyMessage(-1);
					else {
						JSONObject resultJson=null;
						int code=0;
						JSONArray favoriteArray=null;
						try {
							resultJson=new JSONObject(serverRequestResult);
							code=resultJson.getInt("Code");
						} catch (JSONException e) {
							
						}
						if(code==1){
							try {
								favoriteArray=resultJson.getJSONArray("Data");
							} catch (JSONException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							if(favoriteArray!=null){
								for (int i = 0; i < favoriteArray.length(); i++) {
									FavoriteInfo favoriteInfo = new FavoriteInfo();
									JSONObject   favoriteJson=null;
									try {
										favoriteJson=favoriteArray.getJSONObject(i);
										if (favoriteJson.has("ID") && !favoriteJson.isNull("ID"))
												favoriteInfo.setFavoriteID(favoriteJson.getString("ID"));
										if (favoriteJson.has("ProductID") && !favoriteJson.isNull("ProductID"))
												favoriteInfo.setProductID(favoriteJson.getString("ProductID"));
										if (favoriteJson.has("ProductCode") && !favoriteJson.isNull("ProductCode"))
											favoriteInfo.setProductCode(favoriteJson.getString("ProductCode"));
										if (favoriteJson.has("ProductName") && !favoriteJson.isNull("ProductName"))
												favoriteInfo.setProductName(favoriteJson.getString("ProductName"));
										if (favoriteJson.has("ProductType") && !favoriteJson.isNull("ProductType"))
												favoriteInfo.setProductType(favoriteJson.getInt("ProductType"));
										if (favoriteJson.has("SortID") && !favoriteJson.isNull("SortID"))
												favoriteInfo.setSortID(favoriteJson.getString("SortID"));
										if (favoriteJson.has("MarketingPolicy") && !favoriteJson.isNull("MarketingPolicy"))
												favoriteInfo.setMarketingPolicy(favoriteJson.getInt("MarketingPolicy"));
										if (favoriteJson.has("UnitPrice") && !favoriteJson.isNull("UnitPrice"))
												favoriteInfo.setUnitPrice(favoriteJson.getString("UnitPrice"));
										if (favoriteJson.has("PromotionPrice") && !favoriteJson.isNull("PromotionPrice"))
												favoriteInfo.setPromotionPrice(favoriteJson.getString("PromotionPrice"));
										if (favoriteJson.has("FileUrl") && !favoriteJson.isNull("FileUrl"))
												favoriteInfo.setFileUrl(favoriteJson.getString("FileUrl"));
										if (favoriteJson.has("Available") && !favoriteJson.isNull("Available"))
												favoriteInfo.setAvailable(favoriteJson.getBoolean("Available"));
										if (favoriteJson.has("Specification") && !favoriteJson.isNull("Specification"))
												favoriteInfo.setSpecification(favoriteJson.getString("Specification"));
										if (favoriteJson.has("ExpirationTime") && !favoriteJson.isNull("ExpirationTime"))
												favoriteInfo.setExpirationDate(favoriteJson.getString("ExpirationTime"));
									} catch (JSONException e) {
										
									}
									favoriteList.add(favoriteInfo);
								}
								
							}
							handler.sendEmptyMessage(1);
						}
						else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR)
							handler.sendEmptyMessage(code);
						else{
							handler.sendEmptyMessage(0);
						}
					}
				}
			};
			requestWebServiceThread.start();
		}
	}

}
