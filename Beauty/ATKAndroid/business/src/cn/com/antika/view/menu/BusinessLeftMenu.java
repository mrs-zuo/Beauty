package cn.com.antika.view.menu;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.com.antika.adapter.LeftMenuAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AccountInfo;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.business.AccountAttendanceActivity;
import cn.com.antika.business.CustomerRecordTemplateActivity;
import cn.com.antika.business.EMarketingActivity;
import cn.com.antika.business.FlyMessageListActivity;
import cn.com.antika.business.NotepadListActivity;
import cn.com.antika.business.OrderListTabActivity;
import cn.com.antika.business.R;
import cn.com.antika.business.RemindListActivity;
import cn.com.antika.business.ReportMainActivity;
import cn.com.antika.business.SettingActivity;
import cn.com.antika.business.TaskListTabActivity;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class BusinessLeftMenu {
	private BusinessLeftMenuHandler mhandler = new BusinessLeftMenuHandler(this);
	private SlidingMenu menu;
	private Thread subThread;
	private UserInfoApplication userInfoApplication;
	private Context mContext;
	private PackageUpdateUtil packageUpdateUtil;
	public SlidingMenu getMenu() {
		return menu;
	}
	public void createLeftMenu(Context context) {
		menu = new SlidingMenu(context);
		menu.setMode(SlidingMenu.LEFT);
		menu.setTouchModeAbove(SlidingMenu.TOUCHMODE_NONE);
		menu.setBehindOffsetRes(R.dimen.slidingmenu_offset);
		menu.setBehindWidth((int) context.getResources().getDimension(R.dimen.slidingmenu_width));
		menu.setFadeDegree(0.35f);
		// 设置阴影
		menu.setShadowWidth(30);
		menu.setShadowDrawable(R.xml.left_shadow);
		menu.attachToActivity((Activity) context, SlidingMenu.SLIDING_CONTENT);
		menu.setMenu(R.layout.business_left_menu);
		final ListView leftMenuListView = (ListView) ((Activity) context).findViewById(R.id.menu_left_listview);
		userInfoApplication = UserInfoApplication.getInstance();
		String bussinessHeadImageUrl = userInfoApplication.getAccountInfo().getHeadImage();
		String bussinessAccountName = userInfoApplication.getAccountInfo().getAccountName();
		ImageView bussinessHeadImage = (ImageView) ((Activity) context).findViewById(R.id.bussiness_headimage);
		TextView bussinessAccountNameText = (TextView) ((Activity) context).findViewById(R.id.bussiness_accountname);
		ImageLoader imageLoader =ImageLoader.getInstance();
		DisplayImageOptions displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		imageLoader.displayImage(bussinessHeadImageUrl, bussinessHeadImage,displayImageOptions);
		bussinessAccountNameText.setText(bussinessAccountName);
		AccountInfo accountInfo = userInfoApplication.getAccountInfo();
		// Business所在店的规模
		String moduleInUse = accountInfo.getModuleInUse();
		//查看我的订单  顾客订单
		int authMyOrderRead = accountInfo.getAuthMyOrderRead();
		//飞语的权限
		int authChatUse = accountInfo.getAuthChatUse();
		//营销的权限
		int authMarketingRead = accountInfo.getAuthMarketingRead();
		//报表的权限
		int authMyReportRead = accountInfo.getAuthMyReportRead();
		int authBusinessReportRead = accountInfo.getAuthBusinessReportRead();
		// 提醒个数
		final List<String> menuTetxtList = new ArrayList<String>();
		final List<Integer> menuIconList = new ArrayList<Integer>();
		menuTetxtList.add("任务");
		menuIconList.add(R.drawable.menu_left_00);
		if (moduleInUse == null || ("").equals(moduleInUse)) {
			if (authMyOrderRead == 1) {
				menuTetxtList.add("业务");
				menuIconList.add(R.drawable.menu_left_03);
			}
			menuTetxtList.add("笔记");
			menuIconList.add(R.drawable.right_menu_customer_05);
			menuTetxtList.add("专业");
			menuIconList.add(R.drawable.menu_left_vocation_icon);
			if (authChatUse == 1) {
				menuTetxtList.add("飞语");
				menuIconList.add(R.drawable.menu_left_04);
			}
			if (authMyReportRead == 1 || authBusinessReportRead == 1) {
				menuTetxtList.add("报表");
				menuIconList.add(R.drawable.menu_left_06);
			}
		} else {
			if (authMyOrderRead == 1) {
				menuTetxtList.add("业务");
				menuIconList.add(R.drawable.menu_left_03);
			}
			menuTetxtList.add("专业");
			menuIconList.add(R.drawable.menu_left_vocation_icon);
			menuTetxtList.add("笔记");
			menuIconList.add(R.drawable.right_menu_customer_05);
			if (authChatUse == 1) {
				menuTetxtList.add("飞语");
				menuIconList.add(R.drawable.menu_left_04);
			}
			if (moduleInUse.contains("|3|") && authMarketingRead == 1) {
				menuTetxtList.add("营销");
				menuIconList.add(R.drawable.menu_left_05);
			}
			if (authMyReportRead == 1 || authBusinessReportRead == 1) {
				menuTetxtList.add("报表");
				menuIconList.add(R.drawable.menu_left_06);
			}
		}
		menuTetxtList.add("考勤");
		menuIconList.add(R.drawable.menu_left_10);
		menuTetxtList.add("设置");
		menuIconList.add(R.drawable.menu_left_07);
		Integer[] menuLeftIcons = new Integer[menuIconList.size()];
		String menuLeftItems[] = new String[menuTetxtList.size()];
		menuIconList.toArray(menuLeftIcons);
		menuTetxtList.toArray(menuLeftItems);
		List<Map<String, Object>> menuLeftList = new ArrayList<Map<String, Object>>();
		for (int i = 0; i < menuLeftItems.length; i++) {
			Map<String, Object> menuItem = new HashMap<String, Object>();
			menuItem.put("menu_icon", menuLeftIcons[i]);
			menuItem.put("menu_text", menuLeftItems[i]);
			menuLeftList.add(menuItem);
		}
		mContext = context;
		final LeftMenuAdapter leftMenuAdapter = new LeftMenuAdapter(mContext,menuLeftList);
		leftMenuListView.setAdapter(leftMenuAdapter);
		leftMenuListView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Intent destIntent = null;
				try {
					if (menuTetxtList.get(position).equals("任务")){
						destIntent = new Intent(mContext,TaskListTabActivity.class);
					}
					if (menuTetxtList.get(position).equals("提醒"))
						destIntent = new Intent(mContext, RemindListActivity.class);
					else if (menuTetxtList.get(position).equals("笔记")){
						destIntent = new Intent(mContext,NotepadListActivity.class);
						destIntent.putExtra("isByCustomerID",false);
					}
					else if (menuTetxtList.get(position).equals("专业")) {
						destIntent = new Intent(mContext,CustomerRecordTemplateActivity.class);
					}  
					else if (menuTetxtList.get(position).equals("业务")) {
						destIntent = new Intent(mContext,OrderListTabActivity.class);
					} 
					else if (menuTetxtList.get(position).equals("飞语")) {
						destIntent = new Intent(mContext,FlyMessageListActivity.class);
					} else if (menuTetxtList.get(position).equals("营销")) {
						destIntent = new Intent(mContext, EMarketingActivity.class);
					} else if (menuTetxtList.get(position).equals("报表")) {
						destIntent = new Intent(mContext,ReportMainActivity.class);
					} else if(menuTetxtList.get(position).equals("考勤")){
						destIntent = new Intent(mContext,AccountAttendanceActivity.class);
					}
					else if (menuTetxtList.get(position).equals("设置")) {
						destIntent = new Intent(mContext, SettingActivity.class);
					}
				} catch (Exception e) {
					
				}
				if (destIntent != null) {
					destIntent.putExtra("USER_ROLE",Constant.USER_ROLE_BUSINESS);
					mContext.startActivity(destIntent);
					menu.showContent();
				}
			}

		});
		// 设置菜单打开事件
		menu.setOnOpenedListener(new SlidingMenu.OnOpenedListener() {
			@Override
			public void onOpened() {
				// TODO Auto-generated method stub
				int accountNewRemindCount = userInfoApplication.getAccountNewRemindCount();
				if (accountNewRemindCount > 0) {
					leftMenuAdapter.notifyDataSetChanged();
				}
				// 上次取数据时间
				long lastGetNewMessageTime = userInfoApplication.getLastGetNewMessageTime();
				// 当前时间
				long currentTime = System.currentTimeMillis();
				if (currentTime - lastGetNewMessageTime >= 5000) {
					userInfoApplication.setLastGetNewMessageTime(currentTime);
					getNewMessageCountByWebService();
					leftMenuAdapter.notifyDataSetChanged();
				}
			}
		});
	}

	private static class BusinessLeftMenuHandler extends Handler {
		private final BusinessLeftMenu businessLeftMenu;

		private BusinessLeftMenuHandler(BusinessLeftMenu activity) {
			WeakReference<BusinessLeftMenu> weakReference = new WeakReference<BusinessLeftMenu>(activity);
			businessLeftMenu = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (businessLeftMenu.subThread != null) {
				businessLeftMenu.subThread.interrupt();
				businessLeftMenu.subThread = null;
			}
			if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(businessLeftMenu.mContext, businessLeftMenu.mContext.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(businessLeftMenu.mContext);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + businessLeftMenu.mContext.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(businessLeftMenu.mContext);
				businessLeftMenu.packageUpdateUtil = new PackageUpdateUtil(businessLeftMenu.mContext, businessLeftMenu.mhandler, fileCache, downloadFileUrl, false, businessLeftMenu.userInfoApplication);
				businessLeftMenu.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				businessLeftMenu.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = businessLeftMenu.mContext.getFileStreamPath(filename);
				file.getName();
				businessLeftMenu.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			} else {
				if (msg.what == 1) {
					if (!msg.obj.equals("0")) {
						businessLeftMenu.userInfoApplication.setAccountNewMessageCount(Integer.valueOf((String) msg.obj));
					}
				}
				if (msg.what == 2) {
					businessLeftMenu.userInfoApplication.setAccountNewRemindCount(Integer.valueOf((String) msg.obj));
				}
			}
		}
	}

	private void getNewMessageCountByWebService() {
		subThread = new Thread() {
			@Override
			public void run() {
				String methodName = "getNewMessageCount";
				String endPoint = "Message";
				String serverRequestResult =WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,"",userInfoApplication);
				Message msg = new Message();
				
				if (serverRequestResult == null || serverRequestResult.equals(""))
					msg.obj = "0";
				else {
					int code=0;
					String newMessageCount="0";
					JSONObject newMessageJson=null;
					try {
						newMessageJson=new JSONObject(serverRequestResult);
						code=newMessageJson.getInt("Code");
						newMessageCount=((JSONObject)newMessageJson.get("Data")).getString("NewMessageCount");
					} catch (JSONException e) {
					}
					if(code==1){
						msg.what = 1;
						msg.obj = newMessageCount;
					}
					else if (code == Constant.APP_VERSION_ERROR ||code == Constant.LOGIN_ERROR)
						mhandler.sendEmptyMessage(code);
					else
					{
						msg.what = 1;
						msg.obj ="0";
					}
				}
				mhandler.sendMessage(msg);
			}
		};
		subThread.start();
	}
}
