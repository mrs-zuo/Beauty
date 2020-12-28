/**
 * DispenseOrderFragment.java
 * cn.com.antika.fragment
 * tim.zhang@bizapper.com
 * 2015年7月6日 下午1:48:56
 * @version V1.0
 */
package cn.com.antika.fragment;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.FavoriteListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.FavoriteInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.business.CommodityDetailActivity;
import cn.com.antika.business.PrepareOrderActivity;
import cn.com.antika.business.R;
import cn.com.antika.business.ServiceDetailActivity;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.menu.BusinessRightMenu;
import cn.com.antika.webservice.WebServiceUtil;

/**
 * DispenseOrderFragment
 * 收藏列表的Fragment
 *
 * @author tim.zhang@bizapper.com
 * 2015年7月6日 下午1:48:56
 */
@SuppressLint("ResourceType")
public class DispenseFavoriteListFragment extends Fragment implements OnItemClickListener,OnClickListener{
	private DispenseFavoriteListFragmentHandler mHandler = new DispenseFavoriteListFragmentHandler(this);
	private ListView favoriteListView;
	private List<FavoriteInfo> favoriteList;
	private UserInfoApplication userinfoApplication;
	private Thread requestWebServiceThread;
	public static FavoriteListAdapter favoriteListAdapter;
	private PackageUpdateUtil packageUpdateUtil;
	private int productType = -1;
	private Button addOrderBtn,prepareOrderBtn;
	private List<OrderProduct> orderProductList;
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreateView(inflater, container, savedInstanceState);
		View dispenseFavoriteListView=inflater.inflate(R.xml.dispense_favorite_list_fragment_layout,container,false);
		favoriteListView = (ListView)dispenseFavoriteListView.findViewById(R.id.favorite_listview);
		favoriteListView.setOnItemClickListener(this);
		userinfoApplication = (UserInfoApplication)getActivity().getApplication();
		addOrderBtn=(Button) dispenseFavoriteListView.findViewById(R.id.favorite_list_add_order_btn);
		addOrderBtn.setOnClickListener(this);
		prepareOrderBtn=(Button)dispenseFavoriteListView.findViewById(R.id.favorite_list_prepare_order_btn);
		prepareOrderBtn.setOnClickListener(this);
		int authMyOrderWrite=userinfoApplication.getAccountInfo().getAuthMyOrderWrite();
		if(authMyOrderWrite==0){
			addOrderBtn.setVisibility(View.GONE);
			prepareOrderBtn.setVisibility(View.GONE);
		}
		OrderInfo orderInfo = userinfoApplication.getOrderInfo();
		if (orderInfo == null)
			orderInfo = new OrderInfo();
		orderProductList = orderInfo.getOrderProductList();
		if (orderProductList == null)
			orderProductList = new ArrayList<OrderProduct>();
		userinfoApplication.setOrderInfo(orderInfo);
		userinfoApplication.getOrderInfo().setOrderProductList(orderProductList);
		getFavoriteListData(requestWebServiceThread,mHandler);
		return dispenseFavoriteListView;
	}
	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
		
	}

	private static class DispenseFavoriteListFragmentHandler extends Handler {
		private final DispenseFavoriteListFragment dispenseFavoriteListFragment;

		private DispenseFavoriteListFragmentHandler(DispenseFavoriteListFragment activity) {
			WeakReference<DispenseFavoriteListFragment> weakReference = new WeakReference<DispenseFavoriteListFragment>(activity);
			dispenseFavoriteListFragment = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (dispenseFavoriteListFragment == null || dispenseFavoriteListFragment.getActivity() == null) {
				UserInfoApplication.getInstance().exitForLogin(null);
			}
			switch (msg.what) {
				case 1:
					favoriteListAdapter = new FavoriteListAdapter(dispenseFavoriteListFragment.getActivity(), dispenseFavoriteListFragment.favoriteList);
					dispenseFavoriteListFragment.favoriteListView.setAdapter(favoriteListAdapter);
					((TextView) dispenseFavoriteListFragment.getActivity().findViewById(R.id.tab_favorite_title)).setText("收藏" + "(" + dispenseFavoriteListFragment.favoriteList.size() + ")");
					break;
				case 2:
					DialogUtil.createShortDialog(dispenseFavoriteListFragment.getActivity(), "您的网络貌似不给力，请重试");
					break;
				case 3:
					DialogUtil.createShortDialog(dispenseFavoriteListFragment.getActivity(), msg.obj.toString());
					break;
				case 4:
					DialogUtil.createShortDialog(dispenseFavoriteListFragment.getActivity(), msg.obj.toString());
					dispenseFavoriteListFragment.getFavoriteListData(dispenseFavoriteListFragment.requestWebServiceThread, dispenseFavoriteListFragment.mHandler);
					break;
				case Constant.LOGIN_ERROR:
					DialogUtil.createShortDialog(dispenseFavoriteListFragment.getActivity(), dispenseFavoriteListFragment.getString(R.string.login_error_message));
					UserInfoApplication.getInstance().exitForLogin(dispenseFavoriteListFragment.getActivity());
					break;
				case Constant.APP_VERSION_ERROR:
					String downloadFileUrl = Constant.SERVER_URL + dispenseFavoriteListFragment.getString(R.string.download_apk_address);
					FileCache fileCache = new FileCache(dispenseFavoriteListFragment.getActivity());
					dispenseFavoriteListFragment.packageUpdateUtil = new PackageUpdateUtil(dispenseFavoriteListFragment.getActivity(), dispenseFavoriteListFragment.mHandler, fileCache, downloadFileUrl, false, dispenseFavoriteListFragment.userinfoApplication);
					dispenseFavoriteListFragment.packageUpdateUtil.getPackageVersionInfo();
					ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
					serverPackageVersion.setPackageVersion((String) msg.obj);
					dispenseFavoriteListFragment.packageUpdateUtil.mustUpdate(serverPackageVersion);
					break;
				case 5:
					((DownloadInfo) msg.obj).getUpdateDialog().cancel();
					String filename = "cn.com.antika.business.apk";
					File file = dispenseFavoriteListFragment.getActivity().getFileStreamPath(filename);
					file.getName();
					dispenseFavoriteListFragment.packageUpdateUtil.showInstallDialog();
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

	private void getFavoriteListData(Thread requestWebServiceThread,Handler mHandler) {
		if(favoriteList!=null && favoriteList.size()>0)
			favoriteList.clear();
		else
			favoriteList = new ArrayList<FavoriteInfo>();
		final Handler handler = mHandler;
		final int screenWidth = userinfoApplication.getScreenWidth();
		int authServiceRead = userinfoApplication.getAccountInfo().getAuthServiceRead();
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
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		final int pos = position;
		if (favoriteList.get(position).isAvailable() == false) {
			Dialog dialog = new AlertDialog.Builder(getActivity(),R.style.CustomerAlertDialog)
					.setTitle(getString(R.string.delete_dialog_title)).setMessage(R.string.disable_service_or_commodity_delete_favorite_message)
					.setPositiveButton(getString(R.string.delete_confirm),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									dialog.dismiss();
									requestWebServiceThread = new Thread() {
										@Override
										public void run() {
											String methodName = "delFavorite";
											String endPoint = "account";
											JSONObject delFavoriteJsonParam=new JSONObject();
											try {
												delFavoriteJsonParam.put("FavoriteID", favoriteList.get(pos).getFavoriteID());
											} catch (JSONException e) {
											}
											String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,delFavoriteJsonParam.toString(),userinfoApplication);
											if (serverRequestResult == null || serverRequestResult.equals(""))
												mHandler.sendEmptyMessage(2);
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
													mHandler.obtainMessage(4, returnMessage).sendToTarget();
												} else{
													try {
														returnMessage=delFavoriteJson.getString("Message");
													} catch (JSONException e) {
														returnMessage="";
													}
													mHandler.obtainMessage(3, returnMessage).sendToTarget();
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
								public void onClick(DialogInterface dialog,int which) {
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
			if (favoriteList.get(position).getProductType()==0) {
				destIntent = new Intent(getActivity(),ServiceDetailActivity.class);
				destIntent.putExtra("serviceCode", Long.valueOf(favoriteList.get(position).getProductCode()));
				destIntent.putExtra("CategoryID", "0");
				destIntent.putExtra("CategoryName", "");
			} else if (favoriteList.get(position).getProductType()==1) {
				destIntent = new Intent(getActivity(),CommodityDetailActivity.class);
				destIntent.putExtra("commodityCode",Long.valueOf(favoriteList.get(position).getProductCode()));
				destIntent.putExtra("CategoryID", "0");
				destIntent.putExtra("CategoryName", "");
			}
			destIntent.putExtra("resAcvitityname", "FavoriteListActivity");
			startActivity(destIntent);
		}
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		if(view.getId()==R.id.favorite_list_add_order_btn){
			orderProductList = new ArrayList<OrderProduct>();
			List<OrderProduct> selectedFavoriteList=null;
			if(favoriteListAdapter!=null)
				selectedFavoriteList=favoriteListAdapter.getSelectedFavoriteList();
			if(userinfoApplication.getSelectedCustomerID()==0)
				DialogUtil.createShortDialog(getActivity(),"请先选择顾客");
			else if(selectedFavoriteList==null || selectedFavoriteList.size()==0)
				DialogUtil.createShortDialog(getActivity(),"请选择商品或者服务！");
			else{
				for(OrderProduct op:selectedFavoriteList){
					orderProductList.add(op);
				}
				userinfoApplication.getOrderInfo().setOrderProductList(orderProductList);
				Intent destIntent=new Intent(getActivity(),PrepareOrderActivity.class);
				destIntent.putExtra("FROM_SOURCE","MENU");
				startActivity(destIntent);
			}
		}
		else if(view.getId()==R.id.favorite_list_prepare_order_btn){
			List<OrderProduct> selectedFavoriteList=null;
			if(favoriteListAdapter!=null)
				selectedFavoriteList=favoriteListAdapter.getSelectedFavoriteList();
			if(selectedFavoriteList==null || selectedFavoriteList.size()==0)
				DialogUtil.createShortDialog(getActivity(),"请选择商品或者服务！");
			else
			{
				for(OrderProduct op:selectedFavoriteList){
					orderProductList.add(op);
				}
				BusinessRightMenu.createMenuContent();
				BusinessRightMenu.rightMenuAdapter.notifyDataSetChanged();
				((ViewPager)getActivity().findViewById(R.id.customer_servicing_order_view_pager)).setCurrentItem(0);
			}
		}
	}
}
