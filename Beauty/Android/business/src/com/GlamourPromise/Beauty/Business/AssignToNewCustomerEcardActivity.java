package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DiscountDetail;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
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
import java.util.Timer;
/*
 * 为客户转卡
 * */
public class AssignToNewCustomerEcardActivity extends BaseActivity implements OnClickListener, OnItemSelectedListener {
	private AssignToNewCustomerEcardActivityHandler mHandler = new AssignToNewCustomerEcardActivityHandler(this);
	private Spinner             ecardNameSpinner;
	private Button         		assignToNewCustomerEcardMakeSureBtn;
	private Thread              requestWebServiceThread;
	private List<EcardInfo>     ecardInfoList;
	private ProgressDialog      progressDialog;
	private UserInfoApplication userinfoApplication;
	private Timer               dialogTimer;
	private LayoutInflater      layoutInflater;
	private PackageUpdateUtil 	packageUpdateUtil;
	private EcardInfo         	selectedEcardInfo,oldEcard;
	private TableLayout       	ecardInfoDiscountTablelayout;
	private RelativeLayout    	newCustomerEcardIsDefaultRelativelayout;
	private ImageView         	newCustomerEcardIsDefaultIcon;
	private boolean           	newCustomerEcardIsDefault,isCustomerFirstCard;
	private TextView          	newCustomerEcardStartDateText,newCustomerEcardExpirationDateText;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_assign_to_new_customer_ecard);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class AssignToNewCustomerEcardActivityHandler extends Handler {
		private final AssignToNewCustomerEcardActivity assignToNewCustomerEcardActivity;

		private AssignToNewCustomerEcardActivityHandler(AssignToNewCustomerEcardActivity activity) {
			WeakReference<AssignToNewCustomerEcardActivity> weakReference = new WeakReference<AssignToNewCustomerEcardActivity>(activity);
			assignToNewCustomerEcardActivity = weakReference.get();
		}

		@SuppressLint("ResourceType")
		@Override
		public void handleMessage(Message msg) {
			if (assignToNewCustomerEcardActivity.progressDialog != null) {
				assignToNewCustomerEcardActivity.progressDialog.dismiss();
				assignToNewCustomerEcardActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				if (assignToNewCustomerEcardActivity.ecardInfoList.size() > 0) {
					((TextView) assignToNewCustomerEcardActivity.findViewById(R.id.old_customer_ecard_name)).setText(assignToNewCustomerEcardActivity.oldEcard.getUserEcardName());
					((TextView) assignToNewCustomerEcardActivity.findViewById(R.id.old_customer_ecard_balance)).setText(assignToNewCustomerEcardActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(assignToNewCustomerEcardActivity.oldEcard.getUserEcardBalance()));
					String[] ecardNameArray = new String[assignToNewCustomerEcardActivity.ecardInfoList.size()];
					for (int i = 0; i < assignToNewCustomerEcardActivity.ecardInfoList.size(); i++) {
						ecardNameArray[i] = assignToNewCustomerEcardActivity.ecardInfoList.get(i).getUserEcardName();
					}
					ArrayAdapter<String> ecardNameAdapter = new ArrayAdapter<String>(assignToNewCustomerEcardActivity, R.xml.spinner_checked_text, ecardNameArray);
					ecardNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
					assignToNewCustomerEcardActivity.ecardNameSpinner.setAdapter(ecardNameAdapter);
					assignToNewCustomerEcardActivity.ecardNameSpinner.setSelection(0);
				}
			} else if (msg.what == 2) {
				AlertDialog alertDialog = DialogUtil.createShortShowDialog(assignToNewCustomerEcardActivity, "提示信息", "转卡成功！");
				alertDialog.show();
				Intent destIntent = new Intent(assignToNewCustomerEcardActivity, CustomerEcardListActivity.class);
				assignToNewCustomerEcardActivity.dialogTimer = new Timer();
				DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, assignToNewCustomerEcardActivity.dialogTimer, assignToNewCustomerEcardActivity, destIntent);
				assignToNewCustomerEcardActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
			} else if (msg.what == 0) {
				DialogUtil.createShortDialog(assignToNewCustomerEcardActivity, (String) msg.obj);
			} else if (msg.what == 3)
				DialogUtil.createShortDialog(assignToNewCustomerEcardActivity, "您的网络貌似不给力，请重试");
			else if (msg.what == 4) {
				if (!assignToNewCustomerEcardActivity.isCustomerFirstCard) {
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefault = false;
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.no_select_btn);
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefaultRelativelayout.setOnClickListener(assignToNewCustomerEcardActivity);
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setOnClickListener(assignToNewCustomerEcardActivity);
				} else {
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefault = true;
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.select_btn);
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setOnClickListener(null);
					assignToNewCustomerEcardActivity.newCustomerEcardIsDefaultRelativelayout.setOnClickListener(null);
				}
				((TextView) assignToNewCustomerEcardActivity.findViewById(R.id.new_customer_ecard_expiration_date)).setText(assignToNewCustomerEcardActivity.selectedEcardInfo.getUserEcardExpirationDate());
				String ecardDescription = assignToNewCustomerEcardActivity.selectedEcardInfo.getUserEcardDescription();
				if (ecardDescription != null && !ecardDescription.equals("")) {
					assignToNewCustomerEcardActivity.findViewById(R.id.ecard_description_table_layout).setVisibility(View.VISIBLE);
					((TextView) assignToNewCustomerEcardActivity.findViewById(R.id.new_customer_ecard_description)).setText(assignToNewCustomerEcardActivity.selectedEcardInfo.getUserEcardDescription());
				} else
					assignToNewCustomerEcardActivity.findViewById(R.id.ecard_description_table_layout).setVisibility(View.GONE);
				List<DiscountDetail> discountDetailList = assignToNewCustomerEcardActivity.selectedEcardInfo.getDiscountDetailList();
				assignToNewCustomerEcardActivity.ecardInfoDiscountTablelayout.removeAllViews();
				if (discountDetailList != null && discountDetailList.size() > 0) {
					View discountTitleView = assignToNewCustomerEcardActivity.layoutInflater.inflate(R.xml.ecard_discount_title, null);
					assignToNewCustomerEcardActivity.ecardInfoDiscountTablelayout.addView(discountTitleView);
					for (int i = 0; i < discountDetailList.size(); i++) {
						DiscountDetail discountDetail = discountDetailList.get(i);
						View discountDetailItemView = assignToNewCustomerEcardActivity.layoutInflater.inflate(R.xml.discount_detail_list_item, null);
						TextView discountNameText = (TextView) discountDetailItemView.findViewById(R.id.discount_name_text);
						TextView discountRateText = (TextView) discountDetailItemView.findViewById(R.id.discount_rate_text);
						discountNameText.setText(discountDetail.getDiscountDetailName());
						discountRateText.setText(NumberFormatUtil.currencyFormat(discountDetail.getDiscountRate()));
						assignToNewCustomerEcardActivity.ecardInfoDiscountTablelayout.addView(discountDetailItemView);
					}
				}

			} else if (msg.what == 6)
				DialogUtil.createShortDialog(assignToNewCustomerEcardActivity,
						(String) msg.obj);
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(assignToNewCustomerEcardActivity, assignToNewCustomerEcardActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(assignToNewCustomerEcardActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + assignToNewCustomerEcardActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(assignToNewCustomerEcardActivity);
				assignToNewCustomerEcardActivity.packageUpdateUtil = new PackageUpdateUtil(assignToNewCustomerEcardActivity, assignToNewCustomerEcardActivity.mHandler, fileCache, downloadFileUrl, false, assignToNewCustomerEcardActivity.userinfoApplication);
				assignToNewCustomerEcardActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				assignToNewCustomerEcardActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = assignToNewCustomerEcardActivity.getFileStreamPath(filename);
				file.getName();
				assignToNewCustomerEcardActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (assignToNewCustomerEcardActivity.requestWebServiceThread != null) {
				assignToNewCustomerEcardActivity.requestWebServiceThread.interrupt();
				assignToNewCustomerEcardActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		layoutInflater = LayoutInflater.from(this);
		ecardNameSpinner = (Spinner)findViewById(R.id.ecard_name_spinner);
		ecardNameSpinner.setOnItemSelectedListener(this);
		assignToNewCustomerEcardMakeSureBtn = (Button)findViewById(R.id.assign_to_new_customer_ecard_make_sure_btn);
		assignToNewCustomerEcardMakeSureBtn.setOnClickListener(this);
		ecardInfoDiscountTablelayout=(TableLayout) findViewById(R.id.discount_detail_list_tablelayout);
		newCustomerEcardStartDateText=(TextView)findViewById(R.id.new_customer_ecard_start_date);
		newCustomerEcardStartDateText.setText(DateUtil.getNowFormateDate2());
		newCustomerEcardExpirationDateText=(TextView)findViewById(R.id.new_customer_ecard_expiration_date);
		newCustomerEcardExpirationDateText.setOnClickListener(this);
		newCustomerEcardIsDefaultRelativelayout=(RelativeLayout) findViewById(R.id.new_customer_ecard_is_default_relativelayout);
		newCustomerEcardIsDefaultIcon=(ImageView)findViewById(R.id.ecard_is_default_icon);
		Intent intent=getIntent();
		isCustomerFirstCard=intent.getBooleanExtra("isCustomerFirstCard",true);
		oldEcard=(EcardInfo)intent.getSerializableExtra("oldEcard");
		requestWebServiceThread = new Thread() {
			public void run() {
				String methodName ="GetBranchCardList";
				String endPoint = "ECard";
				JSONObject getEcardListJsonParam = new JSONObject();
				try {
					getEcardListJsonParam.put("isOnlyMoneyCard",true);
					getEcardListJsonParam.put("isShowAll",false);
					getEcardListJsonParam.put("BranchID",userinfoApplication.getAccountInfo().getBranchId());
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,getEcardListJsonParam.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverRequestResult);
				} catch (JSONException e) {
				}
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(3);
				else {
					int code = 0;
					String message = "";
					try {
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1) {
						JSONArray ecardJsonArray = null;
						try {
							ecardJsonArray = resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						if (ecardJsonArray!= null) {
							ecardInfoList=new ArrayList<EcardInfo>();
							for (int i = 0; i < ecardJsonArray.length(); i++) {
								JSONObject ecardJson = null;
								try {
									ecardJson = (JSONObject)ecardJsonArray.get(i);
								} catch (JSONException e1) {
								}
								int    cardID=0;
								String userEcardName="";
								String userEcardBalance="";
								String userEcardCreateDate="";
								String userEcardExpirationDate="";
								int     userEcardType=1;
								String  userEcardDescription="";
								JSONArray discountJsonArray=null;
								List<DiscountDetail> discountDetailList=null;
								try {
									if (ecardJson.has("CardID") &&  !ecardJson.isNull("CardID"))
										cardID=ecardJson.getInt("CardID");
								    if(ecardJson.has("CardName") &&  !ecardJson.isNull("CardName"))
								    	userEcardName=ecardJson.getString("CardName");
								    if(ecardJson.has("Balance") &&  !ecardJson.isNull("Balance"))
								    	userEcardBalance=ecardJson.getString("Balance");
								    if(ecardJson.has("CardCreatedDate") &&  !ecardJson.isNull("CardCreatedDate"))
								    	userEcardCreateDate=ecardJson.getString("CardCreatedDate");
								    if(ecardJson.has("CardExpiredDate") &&  !ecardJson.isNull("CardExpiredDate"))
								    	userEcardExpirationDate=ecardJson.getString("CardExpiredDate");
								    if(ecardJson.has("CardTypeID") &&  !ecardJson.isNull("CardTypeID"))
								    	userEcardType=ecardJson.getInt("CardTypeID");
								    if(ecardJson.has("CardDescription") &&  !ecardJson.isNull("CardDescription"))
								    	userEcardDescription=ecardJson.getString("CardDescription");
								    if(ecardJson.has("DiscountList") && !ecardJson.isNull("DiscountList"))
								    	discountJsonArray=ecardJson.getJSONArray("DiscountList");
								    if(discountJsonArray!=null){
								    	discountDetailList=new ArrayList<DiscountDetail>();
								    	for(int j=0;j<discountJsonArray.length();j++){
								    		JSONObject discountJson=discountJsonArray.getJSONObject(j);
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
								EcardInfo customerEcardInfo=new EcardInfo();
								customerEcardInfo.setUserEcardID(cardID);
								customerEcardInfo.setUserEcardName(userEcardName);
								customerEcardInfo.setUserEcardBalance(userEcardBalance);
								customerEcardInfo.setUserEcardCreateDate(userEcardCreateDate);
								customerEcardInfo.setUserEcardExpirationDate(userEcardExpirationDate);
								customerEcardInfo.setUserEcardType(userEcardType);
								customerEcardInfo.setUserEcardDescription(userEcardDescription);
								customerEcardInfo.setDiscountDetailList(discountDetailList);
								ecardInfoList.add(customerEcardInfo);
							}
						}
						mHandler.sendEmptyMessage(1);
					} 
					else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR)
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

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch (view.getId()) {
		case R.id.assign_to_new_customer_ecard_make_sure_btn:
			if(userinfoApplication.getSelectedCustomerID()==0){
				DialogUtil.createMakeSureDialog(this,"温馨提示","您未选中顾客，不能进行操作");
			}
			else{
			progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
			progressDialog.setMessage(getString(R.string.please_wait));
			progressDialog.show();
		    //实体卡号
			final String userRealCardNo=((EditText)findViewById(R.id.new_customer_ecard_real_card_no_text)).getText().toString();
			requestWebServiceThread = new Thread() {
				public void run() {
					// TODO Auto-generated method stub
					String methodName ="CardOutAndIn";
					String endPoint = "ECard";
					JSONObject assignToNewCustomerEcardJson=new JSONObject();
					try {
						assignToNewCustomerEcardJson.put("OutCardNo",oldEcard.getUserEcardNo());
						assignToNewCustomerEcardJson.put("CardID",selectedEcardInfo.getUserEcardID());
						assignToNewCustomerEcardJson.put("IsDefault",newCustomerEcardIsDefault);
						assignToNewCustomerEcardJson.put("CustomerID",userinfoApplication.getSelectedCustomerID());
						//assignToNewCustomerEcardJson.put("CardCreatedDate",((TextView)findViewById(R.id.new_customer_ecard_start_date)).getText().toString());
						assignToNewCustomerEcardJson.put("CardExpiredDate",((TextView)findViewById(R.id.new_customer_ecard_expiration_date)).getText().toString());
						if(userRealCardNo!=null && !("").equals(userRealCardNo))
							assignToNewCustomerEcardJson.put("RealCardNo",userRealCardNo);
						else
							assignToNewCustomerEcardJson.put("RealCardNo","");
					} catch (JSONException e) {
					}
					String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,assignToNewCustomerEcardJson.toString(),userinfoApplication);
					String msg="";
					if (serverRequestResult == null || serverRequestResult.equals(""))
						mHandler.sendEmptyMessage(3);
					else {
						JSONObject resultJson=null;
						int code=0;
						try {
							resultJson=new JSONObject(serverRequestResult);
							code=resultJson.getInt("Code");
							msg=resultJson.getString("Message");
						} catch (JSONException e) {
						}
						if (code==1)
							mHandler.sendEmptyMessage(2);
						else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR)
							mHandler.sendEmptyMessage(code);
						else{
							Message message=new Message();
							message.what=0;
							message.obj=msg;
							mHandler.sendMessage(message);
						}
							
					}
				}
			};
			requestWebServiceThread.start();
			}
			break;
		case R.id.new_customer_ecard_is_default_relativelayout:
			setEcardDefault();
			break;
		case R.id.ecard_is_default_icon:
			setEcardDefault();
			break;
		}
	}
	//显示选择日期的对话框
	protected void showDateDialog(int textViewResourcesID){
		DateButton dateButton = new DateButton(this,(EditText)findViewById(textViewResourcesID),Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION,null);
		dateButton.datePickerDialog();
	}
	protected void  setEcardDefault(){
		if(newCustomerEcardIsDefault){
			newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.no_select_btn);
			newCustomerEcardIsDefault=false;
		}
		else if(!newCustomerEcardIsDefault){
			newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.select_btn);
			newCustomerEcardIsDefault=true;
		}
	}
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position,long id) {
		selectedEcardInfo=ecardInfoList.get(position);
		mHandler.sendEmptyMessage(4);
	}
	@Override
	public void onNothingSelected(AdapterView<?> arg0) {
		
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

}
