package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DiscountDetail;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.ChangeServiceExpirationDateListener;
import com.GlamourPromise.Beauty.util.DateButton;
import com.GlamourPromise.Beauty.util.DateUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
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

public class CustomerEcardActivity extends BaseActivity implements
		OnClickListener {
	private CustomerEcardActivityHandler mHandler = new CustomerEcardActivityHandler(this);
	private Thread              requestWebServiceThread;
	private ProgressDialog      progressDialog;
	private TextView            ecardBalanceText;
	private RelativeLayout      ecardBalanceRelativeLayout;
	private RelativeLayout      ecardHistoryRelativeLayout;
	private EcardInfo           ecardInfo,customerEcardInfoPoint,customerEcardInfoCashCoupon;
	private UserInfoApplication userinfoApplication;
	private RelativeLayout      customerEcardExpirationDateRelativelayout;
	private PackageUpdateUtil   packageUpdateUtil;
	private LinearLayout        customerEcardDiscountLinearlayout;
	private LayoutInflater      layoutInflater;
	private RelativeLayout      setEcardDefaultRelativelayout;
	private Button				setEcardDefaultBtn;
	private boolean             isCustomerFirstEcard;
	private ImageView           assignToNewEcardBtn;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_customer_ecard);
		ecardBalanceText = (TextView) findViewById(R.id.ecard_balance_text);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		userinfoApplication = UserInfoApplication.getInstance();
		ecardBalanceRelativeLayout = (RelativeLayout) findViewById(R.id.ecard_money_in_relativelayout);
		ecardHistoryRelativeLayout = (RelativeLayout) findViewById(R.id.ecard_history_relativelayout);
		customerEcardExpirationDateRelativelayout=(RelativeLayout)findViewById(R.id.customer_ecard_expiration_date_relativelayout);
		customerEcardDiscountLinearlayout=(LinearLayout)findViewById(R.id.discount_detail_list_linearlayout);
		layoutInflater=LayoutInflater.from(this);
		((RelativeLayout) findViewById(R.id.ecard_money_out_relativelayout)).setOnClickListener(this);
		((EditText)findViewById(R.id.customer_ecard_expiration_date_text)).setInputType(InputType.TYPE_NULL);
		//管理顾客E账户权限
		if(userinfoApplication.getAccountInfo().getAuthCustomerEcardWrite()==1){
			customerEcardExpirationDateRelativelayout.setOnClickListener(this);
			((EditText)findViewById(R.id.customer_ecard_expiration_date_text)).setOnClickListener(this);
		}
		else{
			((RelativeLayout) findViewById(R.id.ecard_money_in_relativelayout)).setVisibility(View.GONE);
			findViewById(R.id.before_ecard_money_in_divide_view).setVisibility(View.GONE);
			((RelativeLayout) findViewById(R.id.ecard_money_out_relativelayout)).setVisibility(View.GONE);
			findViewById(R.id.before_ecard_money_out_divide_view).setVisibility(View.GONE);
			((EditText)findViewById(R.id.customer_ecard_expiration_date_text)).setOnClickListener(null);
			customerEcardExpirationDateRelativelayout.setOnClickListener(null);
			((EditText)findViewById(R.id.customer_ecard_expiration_date_text)).setTextColor(getResources().getColor(R.color.black));
		}	
		((TextView) findViewById(R.id.ecard_balance_title)).setText("余额");
		ecardBalanceRelativeLayout.setOnClickListener(this);
		setEcardDefaultRelativelayout=(RelativeLayout) findViewById(R.id.set_ecard_default_relativelayout);
		setEcardDefaultBtn=(Button) findViewById(R.id.set_ecard_default_btn);
		setEcardDefaultBtn.setOnClickListener(this);
		ecardHistoryRelativeLayout.setOnClickListener(this);
		Intent intent=getIntent();
		ecardInfo=(EcardInfo)intent.getSerializableExtra("customerEcard");
		customerEcardInfoPoint=(EcardInfo)intent.getSerializableExtra("customerEcardPoint");
		customerEcardInfoCashCoupon=(EcardInfo)intent.getSerializableExtra("customerEcardCashcoupon");
		isCustomerFirstEcard=intent.getBooleanExtra("isCustomerFirstCard",true);
		//转卡按钮
		assignToNewEcardBtn=(ImageView)findViewById(R.id.assign_to_new_ecard_btn);
		assignToNewEcardBtn.setOnClickListener(this);
		requestWebService();
		
	}
	private void requestWebService(){
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		requestWebServiceThread = new Thread() {
			public void run() {
				// TODO Auto-generated method stub
				String methodName = "GetCardInfo";
				String endPoint = "ECard";
				JSONObject ecardInfoJsonParam=new JSONObject();
				try {
					ecardInfoJsonParam.put("CustomerID",userinfoApplication.getSelectedCustomerID());
					ecardInfoJsonParam.put("UserCardNo",ecardInfo.getUserEcardNo());
				} catch (JSONException e) {
					
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,ecardInfoJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson=null;
					try {
						resultJson=new JSONObject(serverRequestResult);
					} catch (JSONException e) {
					}
					int code=0;
					try {
						code=resultJson.getInt("Code");
					} catch (JSONException e) {
					}
					JSONObject customerEcardJson=null;
					if(code==1){
						try {
							customerEcardJson=resultJson.getJSONObject("Data");
						} catch (JSONException e) {
						}
						String userEcardNo="";
						String realCardNo="";
						String userEcardName="";
						String userEcardBalance="";
						String userEcardCreateDate="";
						String userEcardExpirationDate="";
						int     userEcardType=1;
						String  userEcardTypeName="";
						String  userEcardDescription="";
						JSONArray discountJsonArray=null;
						List<DiscountDetail> discountDetailList=null;
						try {
							if (customerEcardJson.has("UserCardNo") &&  !customerEcardJson.isNull("UserCardNo"))
								userEcardNo=customerEcardJson.getString("UserCardNo");
							if (customerEcardJson.has("RealCardNo") &&  !customerEcardJson.isNull("RealCardNo"))
								realCardNo=customerEcardJson.getString("RealCardNo");
						    if(customerEcardJson.has("CardName") &&  !customerEcardJson.isNull("CardName"))
						    	userEcardName=customerEcardJson.getString("CardName");
						    if(customerEcardJson.has("Balance") &&  !customerEcardJson.isNull("Balance"))
						    	userEcardBalance=customerEcardJson.getString("Balance");
						    if(customerEcardJson.has("CardCreatedDate") &&  !customerEcardJson.isNull("CardCreatedDate"))
						    	userEcardCreateDate=customerEcardJson.getString("CardCreatedDate");
						    if(customerEcardJson.has("CardExpiredDate") &&  !customerEcardJson.isNull("CardExpiredDate"))
						    	userEcardExpirationDate=customerEcardJson.getString("CardExpiredDate");
						    if(customerEcardJson.has("CardType") &&  !customerEcardJson.isNull("CardType"))
						    	userEcardType=customerEcardJson.getInt("CardType");
						    if(customerEcardJson.has("CardTypeName") &&  !customerEcardJson.isNull("CardTypeName"))
						    	userEcardTypeName=customerEcardJson.getString("CardTypeName");
						    if(customerEcardJson.has("CardDescription") &&  !customerEcardJson.isNull("CardDescription"))
						    	userEcardDescription=customerEcardJson.getString("CardDescription");
						    if(customerEcardJson.has("DiscountList") && !customerEcardJson.isNull("DiscountList"))
						    	discountJsonArray=customerEcardJson.getJSONArray("DiscountList");
						    if(discountJsonArray!=null){
						    	discountDetailList=new ArrayList<DiscountDetail>();
						    	for(int i=0;i<discountJsonArray.length();i++){
						    		JSONObject discountJson=discountJsonArray.getJSONObject(i);
						    		DiscountDetail discountDetail=new DiscountDetail();
						    		if(discountJson.has("DiscountName"))
						    			discountDetail.setDiscountDetailName(discountJson.getString("DiscountName"));
						    		if(discountJson.has("Discount"))
						    			discountDetail.setDiscountRate(discountJson.getString("Discount"));
						    		discountDetailList.add(discountDetail);
						    	}
						    	
						    }
						} catch (JSONException e) {
						}
						EcardInfo latestEcardInfo=new EcardInfo();
						latestEcardInfo.setUserEcardNo(userEcardNo);
						latestEcardInfo.setUserRealCardNo(realCardNo);
						latestEcardInfo.setUserEcardName(userEcardName);
						latestEcardInfo.setUserEcardBalance(userEcardBalance);
						latestEcardInfo.setUserEcardCreateDate(userEcardCreateDate);
						latestEcardInfo.setUserEcardExpirationDate(userEcardExpirationDate);
						latestEcardInfo.setUserEcardType(userEcardType);
						latestEcardInfo.setUserEcardTypeName(userEcardTypeName);
						latestEcardInfo.setUserEcardDescription(userEcardDescription);
						latestEcardInfo.setDiscountDetailList(discountDetailList);
						latestEcardInfo.setDefault(ecardInfo.isDefault());
						Message msg = new Message();
						msg.obj = latestEcardInfo;
						msg.what = 1;
						mHandler.sendMessage(msg);
					}
					else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else
						mHandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}

	private static class CustomerEcardActivityHandler extends Handler {
		private final CustomerEcardActivity customerEcardActivity;

		private CustomerEcardActivityHandler(CustomerEcardActivity activity) {
			WeakReference<CustomerEcardActivity> weakReference = new WeakReference<CustomerEcardActivity>(activity);
			customerEcardActivity = weakReference.get();
		}

		@SuppressLint("ResourceType")
		@Override
		public void handleMessage(Message msg) {
			if (customerEcardActivity.progressDialog != null) {
				customerEcardActivity.progressDialog.dismiss();
				customerEcardActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				EcardInfo userEcardLatestInfo = (EcardInfo) msg.obj;
				((TextView) customerEcardActivity.findViewById(R.id.customer_ecard_no_text)).setText("No." + customerEcardActivity.ecardInfo.getUserEcardNo());
				//是储值卡并且实体卡号不为空时显示实体卡号
				String cardRealNo = userEcardLatestInfo.getUserRealCardNo();
				if (userEcardLatestInfo.getUserEcardType() == 1 && cardRealNo != null && !(("").equals(cardRealNo)))
					((TextView) customerEcardActivity.findViewById(R.id.customer_real_card_no_text)).setText("实体卡:" + cardRealNo);

				((TextView) customerEcardActivity.findViewById(R.id.customer_ecard_name_text)).setText(userEcardLatestInfo.getUserEcardName());
				((TextView) customerEcardActivity.findViewById(R.id.customer_ecard_type_text)).setText(userEcardLatestInfo.getUserEcardTypeName());
				//积分卡不需要显示货币单位
				if (customerEcardActivity.ecardInfo.getUserEcardType() == 2)
					customerEcardActivity.ecardBalanceText.setText(NumberFormatUtil.currencyFormat(userEcardLatestInfo.getUserEcardBalance()));
					//储值卡和现金券需要显示货币单位
				else
					customerEcardActivity.ecardBalanceText.setText(customerEcardActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(userEcardLatestInfo.getUserEcardBalance()));
				if (DateUtil.compareDate(userEcardLatestInfo.getUserEcardExpirationDate()))
					((ImageView) customerEcardActivity.findViewById(R.id.customer_ecard_has_expiration)).setVisibility(View.VISIBLE);
				else
					((ImageView) customerEcardActivity.findViewById(R.id.customer_ecard_has_expiration)).setVisibility(View.GONE);
				//只有储值卡才能进行转卡
				if (customerEcardActivity.ecardInfo.getUserEcardType() == 1 && customerEcardActivity.userinfoApplication.getAccountInfo().getAuthCustomerEcardWrite() == 1)
					customerEcardActivity.assignToNewEcardBtn.setVisibility(View.VISIBLE);
				else
					customerEcardActivity.assignToNewEcardBtn.setVisibility(View.GONE);
				((TextView) customerEcardActivity.findViewById(R.id.customer_ecard_expiration_date_text)).setText((userEcardLatestInfo.getUserEcardExpirationDate()));
				String ecardDescription = userEcardLatestInfo.getUserEcardDescription();
				if (ecardDescription != null && !("").equals(ecardDescription)) {
					customerEcardActivity.findViewById(R.id.ecard_description_before_view).setVisibility(View.VISIBLE);
					customerEcardActivity.findViewById(R.id.ecard_description_relativelayout).setVisibility(View.VISIBLE);
					customerEcardActivity.findViewById(R.id.ecard_description_after_view).setVisibility(View.VISIBLE);
					customerEcardActivity.findViewById(R.id.ecard_description_title_relativelayout).setVisibility(View.VISIBLE);
					((TextView) customerEcardActivity.findViewById(R.id.customer_ecard_description)).setText(ecardDescription);
				} else {
					customerEcardActivity.findViewById(R.id.ecard_description_before_view).setVisibility(View.GONE);
					customerEcardActivity.findViewById(R.id.ecard_description_relativelayout).setVisibility(View.GONE);
					customerEcardActivity.findViewById(R.id.ecard_description_after_view).setVisibility(View.GONE);
					customerEcardActivity.findViewById(R.id.ecard_description_title_relativelayout).setVisibility(View.GONE);
				}
				//显示该账户的折扣信息
				List<DiscountDetail> discountDetailList = userEcardLatestInfo.getDiscountDetailList();
				if (discountDetailList != null && discountDetailList.size() > 0) {
					customerEcardActivity.customerEcardDiscountLinearlayout.removeAllViews();
					View discountTitleView = customerEcardActivity.layoutInflater.inflate(R.xml.ecard_discount_title, null);
					customerEcardActivity.customerEcardDiscountLinearlayout.addView(discountTitleView);
					for (int i = 0; i < discountDetailList.size(); i++) {
						DiscountDetail discountDetail = discountDetailList.get(i);
						View discountDetailItemView = customerEcardActivity.layoutInflater.inflate(R.xml.discount_detail_list_item, null);
						TextView discountNameText = (TextView) discountDetailItemView.findViewById(R.id.discount_name_text);
						TextView discountRateText = (TextView) discountDetailItemView.findViewById(R.id.discount_rate_text);
						discountNameText.setText(discountDetail.getDiscountDetailName());
						discountRateText.setText(NumberFormatUtil.currencyFormat(discountDetail.getDiscountRate()));
						customerEcardActivity.customerEcardDiscountLinearlayout.addView(discountDetailItemView);
					}
				}
				//如果该账户是储值卡，有微信或者支付宝支付功能则显示第三方交易查询
				if (customerEcardActivity.ecardInfo.getUserEcardType() == 1 && (customerEcardActivity.userinfoApplication.getAccountInfo().getModuleInUse().contains("|5|") || customerEcardActivity.userinfoApplication.getAccountInfo().getModuleInUse().contains("|6|"))) {
					customerEcardActivity.findViewById(R.id.ecard_history_weixin_before_view).setVisibility(View.VISIBLE);
					customerEcardActivity.findViewById(R.id.ecard_history_weixin_relativelayout).setVisibility(View.VISIBLE);
					customerEcardActivity.findViewById(R.id.ecard_history_weixin_relativelayout).setOnClickListener(customerEcardActivity);
					customerEcardActivity.findViewById(R.id.ecard_history_weixin_after_view).setVisibility(View.VISIBLE);
				} else {
					customerEcardActivity.findViewById(R.id.ecard_history_weixin_before_view).setVisibility(View.GONE);
					customerEcardActivity.findViewById(R.id.ecard_history_weixin_relativelayout).setVisibility(View.GONE);
					customerEcardActivity.findViewById(R.id.ecard_history_weixin_after_view).setVisibility(View.GONE);
				}
				//如果该账户不是储值卡或者已经是默认卡了 或者没有编辑顾客账户权限
				if (customerEcardActivity.ecardInfo.getUserEcardType() != 1 || customerEcardActivity.ecardInfo.isDefault() || customerEcardActivity.userinfoApplication.getAccountInfo().getAuthCustomerEcardWrite() == 0) {
					customerEcardActivity.setEcardDefaultRelativelayout.setVisibility(View.GONE);
				} else {
					customerEcardActivity.setEcardDefaultRelativelayout.setVisibility(View.VISIBLE);
				}
				customerEcardActivity.ecardInfo = userEcardLatestInfo;
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(customerEcardActivity, "您的网络貌似不给力，请重试");
			else if (msg.what == 3) {
				customerEcardActivity.setEcardDefaultRelativelayout.setVisibility(View.GONE);
				DialogUtil.createShortDialog(customerEcardActivity, "设置默认卡成功");
			} else if (msg.what == 4) {
				customerEcardActivity.requestWebService();
			} else if (msg.what == 6) {
				DialogUtil.createShortDialog(customerEcardActivity, (String) msg.obj);
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(customerEcardActivity, customerEcardActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(customerEcardActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + customerEcardActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(customerEcardActivity);
				customerEcardActivity.packageUpdateUtil = new PackageUpdateUtil(customerEcardActivity, customerEcardActivity.mHandler, fileCache, downloadFileUrl, false, customerEcardActivity.userinfoApplication);
				customerEcardActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				customerEcardActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = customerEcardActivity.getFileStreamPath(filename);
				file.getName();
				customerEcardActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (customerEcardActivity.requestWebServiceThread != null) {
				customerEcardActivity.requestWebServiceThread.interrupt();
				customerEcardActivity.requestWebServiceThread = null;
			}
		}
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		Intent destIntent = null;
		switch (view.getId()) {
		case R.id.ecard_money_in_relativelayout:
			if(ecardInfo.getUserEcardType()==1)
				destIntent = new Intent(this,EditEcardBalanceActivity.class);
			else
				destIntent = new Intent(this,EditEcardTypeOtherBalanceActivity.class);
			Bundle bundle1=new Bundle();
			bundle1.putSerializable("ecardInfo",ecardInfo);
			bundle1.putSerializable("customerEcardPoint",customerEcardInfoPoint);
			bundle1.putSerializable("customerEcardCashcoupon",customerEcardInfoCashCoupon);
			destIntent.putExtras(bundle1);
			startActivity(destIntent);
			this.finish();
			break;
		case R.id.ecard_history_relativelayout:
			destIntent = new Intent(this,EcardHistoryListActivity.class);
			Bundle bundle=new Bundle();
			bundle.putSerializable("ecardInfo",ecardInfo);
			destIntent.putExtras(bundle);
			startActivity(destIntent);
			break;
		case R.id.ecard_money_out_relativelayout:
			if(ecardInfo.getUserEcardType()==1)
				destIntent = new Intent(this,EcardMoneyOut.class);
			else
				destIntent = new Intent(this,EcardTypeOtherMoneyOut.class);
			Bundle bundle2=new Bundle();
			bundle2.putSerializable("ecardInfo",ecardInfo);
			destIntent.putExtras(bundle2);
			startActivity(destIntent);
			this.finish();
			break;
		case R.id.customer_ecard_expiration_date_relativelayout:
			DateButton dateButton = new DateButton(this,(EditText)findViewById(R.id.customer_ecard_expiration_date_text),Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION,changeEcardExpirationDateListener);
			dateButton.datePickerDialog();
			break;
		case R.id.customer_ecard_expiration_date_text:
			DateButton dateButton2 = new DateButton(this,(EditText)findViewById(R.id.customer_ecard_expiration_date_text),Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION,changeEcardExpirationDateListener);
			dateButton2.datePickerDialog();
			break;
		case R.id.set_ecard_default_btn:
			setEcardDefault();
			break;
		case R.id.ecard_history_weixin_relativelayout:
			Intent resultIntent=new Intent();
			resultIntent.setClass(this,OrderDetailThirdPartPayListActivity.class);
			resultIntent.putExtra("thirdPartPayType",2);
			resultIntent.putExtra("userCardNo",ecardInfo.getUserEcardNo());
			startActivity(resultIntent);
			break;
		case R.id.assign_to_new_ecard_btn:
			Intent assignIntent=new Intent();
			assignIntent.setClass(this,AssignToNewCustomerEcardActivity.class);
			assignIntent.putExtra("oldEcard",ecardInfo);
			assignIntent.putExtra("isCustomerFirstCard",isCustomerFirstEcard);
			startActivity(assignIntent);
			break;
		}
	}
	//设置默认卡
	private void setEcardDefault(){
		progressDialog = new ProgressDialog(CustomerEcardActivity.this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		progressDialog.setCancelable(false);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName ="UpdateCustomerDefaultCard";
				String endPoint = "ECard";
				JSONObject setEcardDefaultJsonParam= new JSONObject();
				try {
					setEcardDefaultJsonParam.put("CustomerID",userinfoApplication.getSelectedCustomerID());
					setEcardDefaultJsonParam.put("UserCardNo",ecardInfo.getUserEcardNo());
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,setEcardDefaultJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null
						|| serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int   code = 0;
					String message = "";
					try {
						JSONObject resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1)
						mHandler.sendEmptyMessage(3);
					else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						Message msg = new Message();
						msg.what = 6;
						msg.obj = message;
						mHandler.sendMessage(msg);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}
	// 更改e卡有效期
	private ChangeServiceExpirationDateListener changeEcardExpirationDateListener = new ChangeServiceExpirationDateListener() {

			@Override
			public void changeServiceExpirationDate(String newExpirationDate) {
				// TODO Auto-generated method stub
				progressDialog = new ProgressDialog(CustomerEcardActivity.this,R.style.CustomerProgressDialog);
				progressDialog.setMessage(getString(R.string.please_wait));
				progressDialog.show();
				progressDialog.setCancelable(false);
				requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						String methodName ="UpdateExpirationDate";
						String endPoint = "ECard";
						JSONObject expirationDateJson = new JSONObject();
						try {
							expirationDateJson.put("CustomerID",userinfoApplication.getSelectedCustomerID());
							expirationDateJson.put("UserCardNo",ecardInfo.getUserEcardNo());
							expirationDateJson.put("CardExpiredDate",((EditText)findViewById(R.id.customer_ecard_expiration_date_text)).getText().toString());
						} catch (JSONException e) {
							e.printStackTrace();
						}
						String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName, expirationDateJson.toString(),userinfoApplication);
						if (serverRequestResult == null
								|| serverRequestResult.equals(""))
							mHandler.sendEmptyMessage(0);
						else {
							int   code = 0;
							String message = "";
							try {
								JSONObject resultJson = new JSONObject(serverRequestResult);
								code = resultJson.getInt("Code");
								message = resultJson.getString("Message");
							} catch (JSONException e) {
								e.printStackTrace();
								code = 0;
							}
							if (code== 1)
								mHandler.sendEmptyMessage(4);
							else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
								mHandler.sendEmptyMessage(code);
							else {
								Message msg = new Message();
								msg.what = 6;
								msg.obj = message;
								mHandler.sendMessage(msg);
							}
						}
					}
				};
				requestWebServiceThread.start();
			}
		};
	public void onBackPressed() {
		super.onBackPressed();
		Intent destIntent=new Intent();
		destIntent.setClass(this,CustomerEcardListActivity.class);
		destIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		startActivity(destIntent);
	};
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
	}
}
