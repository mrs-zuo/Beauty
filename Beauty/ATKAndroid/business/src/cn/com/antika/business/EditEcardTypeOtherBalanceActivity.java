package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import org.json.JSONArray;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.implementation.RechargeEcardTask;
import cn.com.antika.manager.NetUtil;
import cn.com.antika.timer.DialogTimerTask;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

/*
 *积分卡和现金券充值界面
 **/
@SuppressLint("ResourceType")
public class EditEcardTypeOtherBalanceActivity extends BaseActivity implements OnClickListener, OnItemSelectedListener {
	private EditEcardTypeOtherBalanceActivityHandler mHandler = new EditEcardTypeOtherBalanceActivityHandler(this);
	private TextView      ecardTypeOtherBalanceCustomerNameText;
	private String        ecardTypeName="";
	private TextView      eCardTypeOtherMoneyText;
	private Spinner       eCardTypeOtherRechargeTypeSpinner;
	private EditText      eCardTypeOtherRechargeNumberText;
	private int           rechargeOtherType = 0;
	private Button        editEcardBalanceTypeOtherMakeSureBtn;
	private String[]             typeOtherArray;
	private ProgressDialog       progressDialog;
	private EditText            ecardTypeOtherBalanceRemark;
	private UserInfoApplication userInfoApplication;
	private TextView            rechargeTypeOtherNumberTitle,ecardTypeOtherRemarkNumberText;
	private Timer dialogTimer;
	private PackageUpdateUtil packageUpdateUtil;
	private EcardInfo ecardInfo;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_edit_ecard_type_other_balance);
		userInfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class EditEcardTypeOtherBalanceActivityHandler extends Handler {
		private final EditEcardTypeOtherBalanceActivity editEcardTypeOtherBalanceActivity;

		private EditEcardTypeOtherBalanceActivityHandler(EditEcardTypeOtherBalanceActivity activity) {
			WeakReference<EditEcardTypeOtherBalanceActivity> weakReference = new WeakReference<EditEcardTypeOtherBalanceActivity>(activity);
			editEcardTypeOtherBalanceActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (editEcardTypeOtherBalanceActivity.progressDialog != null) {
				editEcardTypeOtherBalanceActivity.progressDialog.dismiss();
				editEcardTypeOtherBalanceActivity.progressDialog = null;
			}
			if (msg.what == Constant.GET_WEB_DATA_TRUE) {
				AlertDialog alertDialog = DialogUtil.createShortShowDialog(editEcardTypeOtherBalanceActivity, "提示信息", editEcardTypeOtherBalanceActivity.ecardTypeName + "充值成功！");
				alertDialog.show();
				Intent destIntent = new Intent(editEcardTypeOtherBalanceActivity, CustomerEcardActivity.class);
				Bundle bundle = new Bundle();
				bundle.putSerializable("customerEcard", editEcardTypeOtherBalanceActivity.ecardInfo);
				destIntent.putExtras(bundle);
				editEcardTypeOtherBalanceActivity.dialogTimer = new Timer();
				DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editEcardTypeOtherBalanceActivity.dialogTimer, editEcardTypeOtherBalanceActivity, destIntent);
				editEcardTypeOtherBalanceActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
			} else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
				DialogUtil.createShortDialog(editEcardTypeOtherBalanceActivity, editEcardTypeOtherBalanceActivity.ecardTypeName + "充值失败，请重新尝试！");
			} else if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR)
				DialogUtil.createShortDialog(editEcardTypeOtherBalanceActivity, "您的网络貌似不给力，请重试");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(editEcardTypeOtherBalanceActivity, editEcardTypeOtherBalanceActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(editEcardTypeOtherBalanceActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + editEcardTypeOtherBalanceActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(editEcardTypeOtherBalanceActivity);
				editEcardTypeOtherBalanceActivity.packageUpdateUtil = new PackageUpdateUtil(editEcardTypeOtherBalanceActivity, editEcardTypeOtherBalanceActivity.mHandler, fileCache, downloadFileUrl, false, editEcardTypeOtherBalanceActivity.userInfoApplication);
				editEcardTypeOtherBalanceActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				editEcardTypeOtherBalanceActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = editEcardTypeOtherBalanceActivity.getFileStreamPath(filename);
				file.getName();
				editEcardTypeOtherBalanceActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
		}
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		
		List<String> typeArray=new ArrayList<String>();
		typeArray.add("直充");
		if(userInfoApplication.getAccountInfo().getAuthBalanceCharge() == 1) {
			typeArray.add("余额转入");
		}
		typeOtherArray=new String[typeArray.size()];
		typeArray.toArray(typeOtherArray);
		
		eCardTypeOtherMoneyText = (TextView) findViewById(R.id.ecard_type_other_money_text);
		eCardTypeOtherRechargeTypeSpinner = (Spinner) findViewById(R.id.ecard_type_other_recharge_type_spinner);
		eCardTypeOtherRechargeNumberText = (EditText) findViewById(R.id.ecard_type_other_recharge_number_text);
		rechargeTypeOtherNumberTitle = (TextView) findViewById(R.id.ecard_type_other_recharge_number_title);
		ecardTypeOtherBalanceCustomerNameText = (TextView)findViewById(R.id.ecard_type_other_money_customer_name);
		editEcardBalanceTypeOtherMakeSureBtn = (Button)findViewById(R.id.edit_ecard_type_other_balance_make_sure_btn);
		editEcardBalanceTypeOtherMakeSureBtn.setOnClickListener(this);
		ecardTypeOtherRemarkNumberText = (TextView) findViewById(R.id.ecard_type_other_remark_number);
		ecardTypeOtherRemarkNumberText.setText("0/200");
		ecardTypeOtherBalanceRemark = (EditText) findViewById(R.id.ecard_type_other_balance_remark_text);
		ecardTypeOtherBalanceCustomerNameText.setText(userInfoApplication.getSelectedCustomerName());
		Intent intent = getIntent();
		ecardInfo=(EcardInfo) intent.getSerializableExtra("ecardInfo");
		int ecardType=ecardInfo.getUserEcardType();
		if(ecardType==2){
			eCardTypeOtherMoneyText.setText( NumberFormatUtil.currencyFormat(ecardInfo.getUserEcardBalance()));
			ecardTypeName="积分";
		}	
		else if(ecardType==3){
			eCardTypeOtherMoneyText.setText(userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(ecardInfo.getUserEcardBalance()));
			ecardTypeName="现金券";
		}
		((TextView)findViewById(R.id.ecard_type_other_money)).setText("剩余"+ecardTypeName);
		((TextView)findViewById(R.id.edit_ecard_type_other_balance_title_text)).setText(ecardTypeName+"充值");
		((TextView)findViewById(R.id.ecard_type_other_recharge_number_title)).setText("充值"+ecardTypeName);
		ArrayAdapter<String> ecardRechargeTypeAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text,typeOtherArray);
		eCardTypeOtherRechargeTypeSpinner.setAdapter(ecardRechargeTypeAdapter);
		ecardRechargeTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		eCardTypeOtherRechargeTypeSpinner.setOnItemSelectedListener(this);
		ecardTypeOtherBalanceRemark.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,int count) {
				if (s != null && !(("").equals(s.toString().trim())))
					ecardTypeOtherRemarkNumberText.setText(s.toString().length() + "/200");
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,int after) {
			
			}
			@Override
			public void afterTextChanged(Editable s) {
			}
		});
	}

	@Override
	public void onClick(View view) {
		if(ProgressDialogUtil.isFastClick())
			return;
		switch (view.getId()) {
		case R.id.edit_ecard_type_other_balance_make_sure_btn:
			if(userInfoApplication.getSelectedCustomerID()==0){
				DialogUtil.createMakeSureDialog(this,"温馨提示","您未选中顾客，不能进行操作");
			}
			else{
			if (eCardTypeOtherRechargeNumberText.getText() == null || ("").equals(eCardTypeOtherRechargeNumberText.getText().toString()))
				DialogUtil.createShortDialog(this, "充值积分数不能为空!");
			else {
				String dialogMsg = "";
				if (eCardTypeOtherRechargeTypeSpinner.getSelectedItemPosition()==0)
					dialogMsg = "本次充值合计:"+ eCardTypeOtherRechargeNumberText.getText().toString() + "。";
				else
					dialogMsg = "本次转入合计:"+ eCardTypeOtherRechargeNumberText.getText().toString()+ "。";
				Dialog dialog = new AlertDialog.Builder(this,R.style.CustomerAlertDialog)
						.setTitle(getString(R.string.delete_dialog_title)).setMessage(dialogMsg)
						.setPositiveButton(getString(R.string.delete_confirm),
								new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										dialog.dismiss();
										progressDialog =ProgressDialogUtil.createProgressDialog(EditEcardTypeOtherBalanceActivity.this);
										String selectedItemStr = eCardTypeOtherRechargeTypeSpinner.getSelectedItem().toString();
										//积分卡和现金券充值  1：直充  2：余额转入
										if (selectedItemStr.equals(typeOtherArray[0]))
											rechargeOtherType = 1;
										else if (selectedItemStr.equals(typeOtherArray[1]))
											rechargeOtherType = 2;
										rechargeToServer();
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
				}
			}
			break;
		}
	}
	private void rechargeToServer(){
		RechargeEcardTask task = createRechargeTask();
		NetUtil netUtil = NetUtil.getNetUtil();
		netUtil.submitDownloadTask(task);
	}
	
	private RechargeEcardTask createRechargeTask(){
		JSONArray giveJsonArray=new JSONArray();
		RechargeEcardTask.Builder builder = new RechargeEcardTask.Builder();
		int customerID = userInfoApplication.getSelectedCustomerID();
		String amount = eCardTypeOtherRechargeNumberText.getText().toString();
		String remark = "";
		if (ecardTypeOtherBalanceRemark.getText().toString() != null && !(ecardTypeOtherBalanceRemark.getText().toString().equals(""))) {
			remark = ecardTypeOtherBalanceRemark.getText().toString();
		}
		builder.setAmount(amount).setChangeType(3).setCardType(ecardInfo.getUserEcardType()).setDepositMode(rechargeOtherType).
		setUserCardNo(ecardInfo.getUserEcardNo()).setCustomerID(customerID).setHandler(mHandler)
		.setRemark(remark).setResponsiblePersonID(0).setGiveJsonArray(giveJsonArray);
		return builder.create();
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
	public void onItemSelected(AdapterView<?> parent, View view, int position,long id) {
		// 余额转入
		if (position == 0) {
			rechargeTypeOtherNumberTitle.setText("充值"+ecardTypeName);
		} else if(position==1){
			rechargeTypeOtherNumberTitle.setText("转入"+ecardTypeName);
		}
	}
	@Override
	public void onNothingSelected(AdapterView<?> parent) {
		// TODO Auto-generated method stub
	}
}
