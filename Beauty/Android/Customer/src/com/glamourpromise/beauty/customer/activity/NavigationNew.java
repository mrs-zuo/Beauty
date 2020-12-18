package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.FragmentViewPagerAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseFragmentActivity;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NoScrollViewPager;
import com.glamourpromise.beauty.customer.fragment.AppointmentFragment;
import com.glamourpromise.beauty.customer.fragment.CartListFragment;
import com.glamourpromise.beauty.customer.fragment.ContactListFragment;
import com.glamourpromise.beauty.customer.fragment.HomePageFragment;
import com.glamourpromise.beauty.customer.fragment.PersonalFragment;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.RSAUtil;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
public class NavigationNew extends BaseFragmentActivity implements IConnectTask {
	private static final String LOGIN = "Login";
	private static final String UPDATE_LOGIN_INFO = "updateLoginInfo";
	private UserInfoApplication userInfo;
	private SharedPreferences sharedata;
	private List<Fragment>    fragmentList=new ArrayList<Fragment>();
	private HomePageFragment    homePageFragment;
	private AppointmentFragment appointmentFragment;
	private CartListFragment  cartListFragment;
	private ContactListFragment contactListFragment;
	private PersonalFragment  personalFragment;
	private NoScrollViewPager        navigationViewPager;
	private FragmentViewPagerAdapter fragmentViewPagerAdapter;
	private RelativeLayout    menuHomePage,menuAppointment,menuCart,menuMessage,menuMy;
	private ImageView         menuHomePageIcon,menuAppointmentIcon,menuCartIcon,menuMessageIcon,menuMyIcon;
	private TextView          navigationTitleText,addNewAppointmentBtn,cartEditBtn,cartEditCompleteBtn;
	private long              firstTime = 0;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_navigation_new);
		userInfo = (UserInfoApplication) getApplication();
		sharedata = userInfo.getSharedPreferences();
		navigationViewPager=(NoScrollViewPager)findViewById(R.id.navigation_view_pager);
		menuHomePage=(RelativeLayout)findViewById(R.id.menu_homepage);
		menuHomePage.setOnClickListener(this);
		menuAppointment=(RelativeLayout)findViewById(R.id.menu_appointment);
		menuAppointment.setOnClickListener(this);
		menuCart=(RelativeLayout)findViewById(R.id.menu_cart);
		menuCart.setOnClickListener(this);
		menuMessage=(RelativeLayout)findViewById(R.id.menu_message);
		menuMessage.setOnClickListener(this);
		menuMy=(RelativeLayout)findViewById(R.id.menu_my);
		menuMy.setOnClickListener(this);
		menuHomePageIcon=(ImageView)findViewById(R.id.menu_homepage_icon);
		menuAppointmentIcon=(ImageView) findViewById(R.id.menu_appointment_icon);
		menuCartIcon=(ImageView) findViewById(R.id.menu_cart_icon);
		menuMessageIcon=(ImageView) findViewById(R.id.menu_message_icon);
		menuMyIcon=(ImageView)findViewById(R.id.menu_setting_icon);
		navigationTitleText=(TextView)findViewById(R.id.navigation_title_text);
		addNewAppointmentBtn=(TextView)findViewById(R.id.add_new_appointment_btn);
		addNewAppointmentBtn.setOnClickListener(this);
		cartEditBtn=(TextView)findViewById(R.id.cart_edit_btn);
		cartEditBtn.setOnClickListener(this);
		cartEditCompleteBtn=(TextView)findViewById(R.id.cart_edit_complete_btn);
		cartEditCompleteBtn.setOnClickListener(this);
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		String categoryName = LOGIN;
		String methodName = UPDATE_LOGIN_INFO;
		JSONObject para = new JSONObject();
		String userName = RSAUtil.encrypt(sharedata.getString("lastLoginAccount", ""));
		String password = sharedata.getString("lastLoginPassword", "");
		try {
			para.put("LoginMobile", userName);
			para.put("Password", password);
			para.put("DeviceID", sharedata.getString("pushUUID", ""));
			para.put("DeviceModel", android.os.Build.MODEL);
			para.put("OSVersion", android.os.Build.VERSION.RELEASE);
			para.put("UserID", mCustomerID);
			para.put("CompanyID", mCompanyID);
			para.put("APPVersion", mApp.getPackageVersion());
			para.put("ClientType", 2);
			para.put("DeviceType", 2);
			para.put("IsNormalLogin", userInfo.isNormalLogin());
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(categoryName, methodName,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				try {
					JSONObject data = new JSONObject(response.getStringData());
					String guid = data.getString("GUID");
					mApp.setGUID(guid);
					mApp.getLoginInformation().setCurrencySymbols(data.getString("CurrencySymbol"));
					Editor editor = sharedata.edit();
					editor.putBoolean("autoLogin", true);
					editor.commit();
					initNavigationView();
				} catch (JSONException e) {
					e.printStackTrace();
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				// 当登陆异常时，则退出到登陆页
				mApp.AppExitToLoginActivity(this);
				Editor editor = mApp.getSharedPreferences().edit();
				editor.putBoolean("autoLogin", false);
				editor.commit();
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}
	protected void initNavigationView(){
		homePageFragment=new HomePageFragment();
		appointmentFragment=new AppointmentFragment();
		cartListFragment=new CartListFragment();
		contactListFragment=new ContactListFragment();
		personalFragment=new PersonalFragment();
		fragmentList.add(homePageFragment);
		fragmentList.add(appointmentFragment);
		fragmentList.add(cartListFragment);
		fragmentList.add(contactListFragment);
		fragmentList.add(personalFragment);
		fragmentViewPagerAdapter = new FragmentViewPagerAdapter(this.getSupportFragmentManager(),fragmentList);
		navigationViewPager.setAdapter(fragmentViewPagerAdapter);
		restAllItem();
		switchViewPager(0);
	}
	protected void restAllItem(){
		menuHomePageIcon.setImageResource(R.drawable.menu_homepage_icon);
		menuAppointmentIcon.setImageResource(R.drawable.menu_appointment_icon);
		menuCartIcon.setImageResource(R.drawable.menu_cart_icon);
		menuMessageIcon.setImageResource(R.drawable.menu_message_icon);
		menuMyIcon.setImageResource(R.drawable.menu_setting_icon);
	}
	@Override
	public void onClick(View view) {
		restAllItem();
		switch(view.getId()){
		case R.id.menu_homepage:
			switchViewPager(0);
			break;
		case R.id.menu_appointment:
			switchViewPager(1);
			break;
		case R.id.menu_cart:
			switchViewPager(2);
			break;
		case R.id.menu_message:
			switchViewPager(3);
			break;
		case R.id.menu_my:
			switchViewPager(4);
			break;
		case R.id.add_new_appointment_btn:
			Intent appointmentSelectBranchIt =new Intent(this,BranchSelectActivity.class);
			startActivity(appointmentSelectBranchIt);
			restAllItem();
			switchViewPager(1);
			break;
		case R.id.cart_edit_btn:
			cartEditBtn.setVisibility(View.INVISIBLE);
		    cartEditCompleteBtn.setVisibility(View.VISIBLE);
		    cartListFragment.setEditStatus(1);
		    restAllItem();
			switchViewPager(2);
			break;
		case R.id.cart_edit_complete_btn:
			cartEditBtn.setVisibility(View.VISIBLE);
		    cartEditCompleteBtn.setVisibility(View.INVISIBLE);
		    cartListFragment.setEditStatus(2);
		    restAllItem();
			switchViewPager(2);
			break;
		}
	}
	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
		int navigationType=intent.getIntExtra("NavigationType",0);
		restAllItem();
		switchViewPager(navigationType);
	}
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
	}
	protected void switchViewPager(int currentItem){
		switch(currentItem){
		case 0:
			menuHomePageIcon.setImageResource(R.drawable.menu_homepage_icon_current);
			navigationTitleText.setText("首页");
			addNewAppointmentBtn.setVisibility(View.INVISIBLE);
			cartEditBtn.setVisibility(View.INVISIBLE);
		    cartEditCompleteBtn.setVisibility(View.INVISIBLE);
			break;
		case 1:
			menuAppointmentIcon.setImageResource(R.drawable.menu_appointment_icon_current);
			navigationTitleText.setText("预约");
			addNewAppointmentBtn.setVisibility(View.VISIBLE);
			cartEditBtn.setVisibility(View.INVISIBLE);
			cartEditCompleteBtn.setVisibility(View.INVISIBLE);
			break;
		case 2:
			menuCartIcon.setImageResource(R.drawable.menu_cart_icon_current);
			navigationTitleText.setText("购物车");
			addNewAppointmentBtn.setVisibility(View.INVISIBLE);
			if(cartEditBtn.getVisibility()==View.VISIBLE){
				cartEditCompleteBtn.setVisibility(View.INVISIBLE);
			}
			else if(cartEditCompleteBtn.getVisibility()==View.VISIBLE){
				cartEditBtn.setVisibility(View.INVISIBLE);
			}
			else
				cartEditBtn.setVisibility(View.VISIBLE);
			break;
		case 3:
			menuMessageIcon.setImageResource(R.drawable.menu_message_icon_current);
			navigationTitleText.setText("飞语");
			addNewAppointmentBtn.setVisibility(View.INVISIBLE);
			cartEditBtn.setVisibility(View.INVISIBLE);
			cartEditCompleteBtn.setVisibility(View.INVISIBLE);
			break;
		case 4:
			menuMyIcon.setImageResource(R.drawable.menu_setting_icon_current);
			navigationTitleText.setText("我的");
			addNewAppointmentBtn.setVisibility(View.INVISIBLE);
			cartEditBtn.setVisibility(View.INVISIBLE);
			cartEditCompleteBtn.setVisibility(View.INVISIBLE);
			break;
		}
		navigationViewPager.setCurrentItem(currentItem,false);
	}
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			long secondTime = System.currentTimeMillis();
			// 如果两次按键时间间隔大于2000毫秒，则不退出
			if (secondTime - firstTime > 2000) {
				DialogUtil.createShortDialog(this, "再按一次退出程序...");
				firstTime = secondTime;
				return false;
			} else {
				this.finish();
			}
		}
		return super.onKeyUp(keyCode, event);
	}
	@Override
	public void parseData(WebApiResponse response) {

	}
}
