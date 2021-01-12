package com.GlamourPromise.Beauty.Business;

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
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.RechargeEcardTask;
import com.GlamourPromise.Beauty.implementation.RechargeEcardTask.Builder;
import com.GlamourPromise.Beauty.manager.NetUtil;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.LowerCase2Uppercase;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
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
 *储值卡充值界面
 **/
@SuppressLint({"ResourceType", "ClickableViewAccessibility"})
public class EditEcardBalanceActivity extends BaseActivity implements OnClickListener, OnItemSelectedListener {
    private EditEcardBalanceActivityHandler mHandler = new EditEcardBalanceActivityHandler(this);
    private TextView eCardMoneyText;
    private Spinner eCardRechargeTypeSpinner;
    private EditText eCardRechargeNumberText;
    private View giveAmountDivideView;
    private EditText eCardRechargeGiveNumberText;
    private RelativeLayout giveAmountRelativeLayout;
    private TextView eCardRechargeTotalText;
    private int rechargeType = 0;
    private Button editEcardBalanceMakeSureBtn;
    private String[] typeArray;
    private ProgressDialog progressDialog;
    private String mBenefitPersonIDs;
    private String mBenefitPersonNames;
    private EditText ecardBalanceRemark;
    private TextView ecardRemarkNumber;
    private UserInfoApplication userInfoApplication;
    private TextView rechargeNumberTitle, thisTimepayment_benefit_share_btn;
    private RelativeLayout rechargeNumberTotalRelativelayout;
    private TextView ecardBalanceCustomerNameText;
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    private TableLayout ecardGiveOtherTablelayout;
    private EcardInfo ecardInfo, customerEcardInfoPoint, customerEcardInfoCashCoupon;
    private EditText givePointText, giveCashCouponText, thisBenefitSharePercent;
    private Thread requestWebServiceThread;
    private String mSlaveID, mSlaveName;
    private LayoutInflater layoutInflater;
    private TableLayout ecardSlaverTablelayout;
    private int shareFlg = 0, namegetFlg = 0, cnt_i, changeFlg = 0;
    private boolean isComissionCalc = true;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_edit_ecard_balance);
        userInfoApplication = UserInfoApplication.getInstance();
        isComissionCalc = userInfoApplication.getAccountInfo().isComissionCalc();
        thisTimepayment_benefit_share_btn = (TextView) findViewById(R.id.payment_benefit_share_btn_e);
        findViewById(R.id.payment_benefit_share_btn_e).setOnClickListener(this);
        if (!isComissionCalc) {
            thisTimepayment_benefit_share_btn.setVisibility(View.GONE);
        }

        getDefaultSlaveID();
    }

    protected void getDefaultSlaveID() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getAccountList";
                String endPoint = "account";
                JSONObject getAccountListJsonParam = new JSONObject();
                try {
                    getAccountListJsonParam.put("CustomerID", userInfoApplication.getSelectedCustomerID());
                } catch (JSONException e) {

                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getAccountListJsonParam.toString(), userInfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {

                    }
                    JSONArray salesArray = null;
                    if (code == 1) {
                        try {
                            salesArray = resultJson.getJSONArray("Data");
                            String salesID = "";
                            String salesPersonName = "";
                            if (salesArray != null) {
                                JSONArray salesIDJsonArray = new JSONArray();
                                for (int j = 0; j < salesArray.length(); j++) {
                                    JSONObject obj = salesArray.getJSONObject(j);
                                    int accountType = obj.getInt("AccountType");
                                    if (accountType == 1) {
                                        salesIDJsonArray.put(obj.getInt("AccountID"));
                                        if (j == salesArray.length() - 1) {
                                            salesPersonName += obj.getString("AccountName");
                                        } else {
                                            salesPersonName += obj.getString("AccountName") + "、";
                                        }
                                    }
                                }
                                salesID = salesIDJsonArray.toString();
                            }
                            mSlaveID = salesID;
                            mSlaveName = salesPersonName;
                            namegetFlg = 1;
                        } catch (JSONException e) {
                        }
                        mHandler.sendEmptyMessage(6);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    private static class EditEcardBalanceActivityHandler extends Handler {
        private final EditEcardBalanceActivity editEcardBalanceActivity;

        private EditEcardBalanceActivityHandler(EditEcardBalanceActivity activity) {
            WeakReference<EditEcardBalanceActivity> weakReference = new WeakReference<EditEcardBalanceActivity>(activity);
            editEcardBalanceActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (editEcardBalanceActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editEcardBalanceActivity.progressDialog != null) {
                editEcardBalanceActivity.progressDialog.dismiss();
                editEcardBalanceActivity.progressDialog = null;
            }
            if (msg.what == Constant.GET_WEB_DATA_TRUE) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(editEcardBalanceActivity, "提示信息", "账户充值成功！");
                alertDialog.show();
                Intent destIntent = new Intent(editEcardBalanceActivity, CustomerEcardActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("customerEcard", editEcardBalanceActivity.ecardInfo);
                bundle.putSerializable("customerEcardPoint", editEcardBalanceActivity.customerEcardInfoPoint);
                bundle.putSerializable("customerEcardCashcoupon", editEcardBalanceActivity.customerEcardInfoCashCoupon);
                destIntent.putExtras(bundle);
                editEcardBalanceActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editEcardBalanceActivity.dialogTimer, editEcardBalanceActivity, destIntent);
                editEcardBalanceActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
                DialogUtil.createShortDialog(editEcardBalanceActivity, "账户充值失败，请重新尝试！");
            } else if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR)
                DialogUtil.createShortDialog(editEcardBalanceActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editEcardBalanceActivity, editEcardBalanceActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editEcardBalanceActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editEcardBalanceActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editEcardBalanceActivity);
                editEcardBalanceActivity.packageUpdateUtil = new PackageUpdateUtil(editEcardBalanceActivity, editEcardBalanceActivity.mHandler, fileCache, downloadFileUrl, false, editEcardBalanceActivity.userInfoApplication);
                editEcardBalanceActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                editEcardBalanceActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = editEcardBalanceActivity.getFileStreamPath(filename);
                file.getName();
                editEcardBalanceActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 6) {
                editEcardBalanceActivity.initView();
            }
            if (editEcardBalanceActivity.requestWebServiceThread != null) {
                editEcardBalanceActivity.requestWebServiceThread.interrupt();
                editEcardBalanceActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        layoutInflater = LayoutInflater.from(this);
        ecardSlaverTablelayout = (TableLayout) findViewById(R.id.layout_responsible);
        //充值的可选充值方式
        List<String> rechargeModeList = new ArrayList<String>();
        rechargeModeList.add("现金");
        rechargeModeList.add("银行卡");
        if (userInfoApplication.getAccountInfo().getModuleInUse().contains("|5|"))
            rechargeModeList.add("微信");
        if (userInfoApplication.getAccountInfo().getModuleInUse().contains("|6|"))
            rechargeModeList.add("支付宝");
        if (userInfoApplication.getAccountInfo().getAuthBalanceCharge() == 1)
            rechargeModeList.add("余额转入");
        typeArray = new String[rechargeModeList.size()];
        rechargeModeList.toArray(typeArray);
        eCardMoneyText = (TextView) findViewById(R.id.ecard_money_text);
        eCardRechargeTypeSpinner = (Spinner) findViewById(R.id.ecard_recharge_type_spinner);
        eCardRechargeNumberText = (EditText) findViewById(R.id.ecard_recharge_number_text);
        /*findViewById(R.id.benefit_person_layout).setOnClickListener(this);*/
        findViewById(R.id.ecard_money_benefit_person).setOnClickListener(this);
        findViewById(R.id.payment_benefit_textv_e).setOnClickListener(this);

        giveAmountDivideView = findViewById(R.id.give_amount_divide_view);
        giveAmountRelativeLayout = (RelativeLayout) findViewById(R.id.give_amount_relativelayout);
        eCardRechargeGiveNumberText = (EditText) findViewById(R.id.ecard_recharge_give_number_text);
        rechargeNumberTotalRelativelayout = (RelativeLayout) findViewById(R.id.ecard_recharge_number_total_relativelayout);
        eCardRechargeTotalText = (TextView) findViewById(R.id.ecard_recharge_number_total_text);
        rechargeNumberTitle = (TextView) findViewById(R.id.ecard_recharge_number_title);
        ecardBalanceCustomerNameText = (TextView) findViewById(R.id.ecard_money_customer_name);
        eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        editEcardBalanceMakeSureBtn = (Button) findViewById(R.id.edit_ecard_balance_make_sure_btn);
        editEcardBalanceMakeSureBtn.setOnClickListener(this);
        ecardRemarkNumber = (TextView) findViewById(R.id.ecard_remark_number);
        ecardRemarkNumber.setText("0/200");
        ecardBalanceRemark = (EditText) findViewById(R.id.ecard_balance_remark_text);
        ((TextView) findViewById(R.id.ecard_recharge_currency_text)).setText(userInfoApplication.getAccountInfo().getCurrency());
        ecardBalanceCustomerNameText.setText(userInfoApplication.getSelectedCustomerName());
        setBenefitPersonInfo(mSlaveID, mSlaveName);
        Intent intent = getIntent();
        ecardInfo = (EcardInfo) intent.getSerializableExtra("ecardInfo");
        customerEcardInfoPoint = (EcardInfo) intent.getSerializableExtra("customerEcardPoint");
        customerEcardInfoCashCoupon = (EcardInfo) intent.getSerializableExtra("customerEcardCashcoupon");
        eCardMoneyText.setText(userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(ecardInfo.getUserEcardBalance()));
        ArrayAdapter<String> ecardRechargeTypeAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, typeArray);
        eCardRechargeTypeSpinner.setAdapter(ecardRechargeTypeAdapter);
        ecardRechargeTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        eCardRechargeTypeSpinner.setOnItemSelectedListener(this);
        ecardGiveOtherTablelayout = (TableLayout) findViewById(R.id.ecard_this_time_give_point_and_cash_coupon_tablelayout);
        givePointText = (EditText) findViewById(R.id.this_time_give_point_count);
        givePointText.setText(String.valueOf(0));
        giveCashCouponText = (EditText) findViewById(R.id.this_time_give_cash_coupon_count);
        giveCashCouponText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        thisBenefitSharePercent = (EditText) findViewById(R.id.benefit_share_percent_e);
        eCardRechargeNumberText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                double rechargeGiveNumber = 0;
                try {
                    rechargeGiveNumber = Double.valueOf(eCardRechargeGiveNumberText.getText().toString());
                } catch (NumberFormatException e) {
                    rechargeGiveNumber = 0;
                }
                if (s != null && !(("").equals(s.toString().trim()))) {
                    try {
                        eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(s.toString()) + rechargeGiveNumber)));
                    } catch (NumberFormatException e) {
                        eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                } else {
                    eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(0) + rechargeGiveNumber)));
                }

            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
        eCardRechargeGiveNumberText.addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                double rechargeNumber = 0;
                try {
                    rechargeNumber = Double.valueOf(eCardRechargeNumberText.getText().toString());
                } catch (NumberFormatException e) {
                    rechargeNumber = 0;
                }
                if (s != null && !(("").equals(s.toString().trim()))) {
                    try {
                        eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(s.toString()) + rechargeNumber)));
                    } catch (NumberFormatException e) {
                        eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(0) + rechargeNumber)));
                    }
                } else {
                    eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(0) + rechargeNumber)));
                }
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
        ecardBalanceRemark.addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s != null && !(("").equals(s.toString().trim())))
                    ecardRemarkNumber.setText(s.toString().length() + "/200");
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
    }

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        switch (view.getId()) {
            case R.id.edit_ecard_balance_make_sure_btn:
                final String selectedItemStr = eCardRechargeTypeSpinner.getSelectedItem().toString();
                if (userInfoApplication.getSelectedCustomerID() == 0) {
                    DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
                } else {
                    if (eCardRechargeNumberText.getText() == null || ("").equals(eCardRechargeNumberText.getText().toString()))
                        DialogUtil.createShortDialog(this, "请输入充值金额!");
                    else if (Float.valueOf(eCardRechargeNumberText.getText().toString()) == 0)
                        DialogUtil.createShortDialog(this, "请输入充值金额!");
                    else {
                        String dialogMsg = "";
                        if (eCardRechargeTypeSpinner.getSelectedItem().toString().equals("余额转入"))
                            dialogMsg = "本次转入合计:"
                                    + userInfoApplication.getAccountInfo().getCurrency()
                                    + eCardRechargeTotalText.getText().toString()
                                    + ","
                                    + LowerCase2Uppercase.l2Uppercase(Double.valueOf(eCardRechargeTotalText.getText().toString())) + "。";
                        else {
                            //充值类型
                            String rechargeMode = eCardRechargeTypeSpinner.getSelectedItem().toString();
                            dialogMsg = "本次" + rechargeMode + "充值合计:"
                                    + userInfoApplication.getAccountInfo().getCurrency()
                                    + eCardRechargeNumberText.getText().toString()
                                    + ","
                                    + LowerCase2Uppercase.l2Uppercase(Double.valueOf(eCardRechargeTotalText.getText().toString())) + "。";
                        }

                        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                                .setTitle(getString(R.string.delete_dialog_title)).setMessage(dialogMsg)
                                .setPositiveButton(getString(R.string.delete_confirm),
                                        new DialogInterface.OnClickListener() {

                                            @Override
                                            public void onClick(DialogInterface dialog, int which) {
                                                dialog.dismiss();
                                                progressDialog = ProgressDialogUtil.createProgressDialog(EditEcardBalanceActivity.this);
                                                if (selectedItemStr.equals("现金"))
                                                    rechargeType = 1;
                                                else if (selectedItemStr.equals("银行卡"))
                                                    rechargeType = 2;
                                                else if (selectedItemStr.equals("余额转入"))
                                                    rechargeType = 3;
                                                //如果不是微信充值  现金/银行卡/余额转入
                                                if (!selectedItemStr.equals("微信") && !selectedItemStr.equals("支付宝"))
                                                    rechargeToServer();
                                                    //微信或者支付宝充值，则跳转到微信或者支付宝支付界面
                                                else {
                                                    thirdPartPay(selectedItemStr);
                                                }
                                            }
                                        })
                                .setNegativeButton(getString(R.string.delete_cancel), new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialog, int which) {
                                        dialog.dismiss();
                                        dialog = null;
                                    }
                                }).create();
                        dialog.show();
                        dialog.setCancelable(false);
                    }
                }
                break;
/*		case R.id.benefit_person_layout:
			Intent chooseBenefitPersonIntent = new Intent(this,ChoosePersonActivity.class);
			chooseBenefitPersonIntent.putExtra("personRole","Doctor");
			chooseBenefitPersonIntent.putExtra("checkModel","Multi");
			chooseBenefitPersonIntent.putExtra("selectPersonIDs",mBenefitPersonIDs);
			chooseBenefitPersonIntent.putExtra("customerID",userInfoApplication.getSelectedCustomerID());
			startActivityForResult(chooseBenefitPersonIntent, 101);
			break;*/
            case R.id.ecard_money_benefit_person:
                Intent chooseBenefitPersonIntent2 = new Intent(this, ChoosePersonActivity.class);
                chooseBenefitPersonIntent2.putExtra("personRole", "Doctor");
                chooseBenefitPersonIntent2.putExtra("checkModel", "Multi");
                chooseBenefitPersonIntent2.putExtra("selectPersonIDs", mBenefitPersonIDs);
                chooseBenefitPersonIntent2.putExtra("customerID", userInfoApplication.getSelectedCustomerID());
                startActivityForResult(chooseBenefitPersonIntent2, 101);
                break;
            case R.id.payment_benefit_textv_e:
                Intent chooseBenefitPersonIntent3 = new Intent(this, ChoosePersonActivity.class);
                chooseBenefitPersonIntent3.putExtra("personRole", "Doctor");
                chooseBenefitPersonIntent3.putExtra("checkModel", "Multi");
                chooseBenefitPersonIntent3.putExtra("selectPersonIDs", mBenefitPersonIDs);
                chooseBenefitPersonIntent3.putExtra("customerID", userInfoApplication.getSelectedCustomerID());
                startActivityForResult(chooseBenefitPersonIntent3, 101);
                break;
            case R.id.payment_benefit_share_btn_e:
                if (shareFlg == 0 && !checkBenefitPersonIsNull() && isComissionCalc) {
                    shareFlg = 1;
                    setBenefitPersonInfo(mBenefitPersonIDs, mBenefitPersonNames);
                }
                break;
        }
    }

    private boolean checkBenefitPersonIsNull() {
        if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]") || mBenefitPersonIDs.equals("[]"))
            return true;
        else
            return false;
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != RESULT_OK) {
            return;
        }
        if (requestCode == 101) {
            namegetFlg = 1;
            setBenefitPersonInfo(data.getStringExtra("personId"), data.getStringExtra("personName"));
        }
    }

    private void setBenefitPersonInfo(String id, String name) {
        if (namegetFlg == 1) {
            mBenefitPersonIDs = id;
            mBenefitPersonNames = name;
            namegetFlg = 0;
        }
        ecardSlaverTablelayout.removeViews(5, ecardSlaverTablelayout.getChildCount() - 5);
        JSONArray idArray = null;
        try {
            idArray = new JSONArray(id);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        if (idArray != null && idArray.length() > 0) {
            String[] nameArray = name.split("、");
            for (int i = 0; i < nameArray.length; i++) {
                View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                benefitPersonNameText.setText(nameArray[i]);
                EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                benefitPersonPercentText.setOnTouchListener(new View.OnTouchListener() {
                    int touch_flag = 0;

                    @Override
                    public boolean onTouch(View v, MotionEvent event) {
                        touch_flag++;
                        if (touch_flag == 2) {
                            touch_flag = 0;
                            if (shareFlg == 1) {
                                String[] nameArray = mBenefitPersonNames.split("、");
                                ecardSlaverTablelayout.removeViews(5, ecardSlaverTablelayout.getChildCount() - 5);
                                for (int j = 0; j < nameArray.length; j++) {
                                    View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                                    TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                                    benefitPersonNameText.setText(nameArray[j]);
                                    EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                                    TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                                    EditText[] editText = new EditText[]{benefitPersonPercentText};
                                    NumberFormatUtil.setPricePointArray(editText, 2);
                                    benefitPersonPercentText.setText(String.valueOf(0));
                                    ecardSlaverTablelayout.addView(benefitPersonItemView, 5 + j);
                                }
                                shareFlg = 0;
                                return true;
                            }
                        }
                        return false;
                    }
                });
                TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                if (!isComissionCalc) {
                    benefitPersonPercentText.setVisibility(View.GONE);
                    benefitPersonPercentMark.setVisibility(View.GONE);
                }
                EditText[] editText = new EditText[]{benefitPersonPercentText};
                NumberFormatUtil.setPricePointArray(editText, 2);
                if (shareFlg == 1) {
                    benefitPersonPercentText.setText("均分");
                } else {
                    benefitPersonPercentText.setText(String.valueOf(0));
                }
                ecardSlaverTablelayout.addView(benefitPersonItemView, 5 + i);
            }
        }
    }

    private void rechargeToServer() {
        RechargeEcardTask task = createRechargeTask();
        NetUtil netUtil = NetUtil.getNetUtil();
        netUtil.submitDownloadTask(task);
    }

    private RechargeEcardTask createRechargeTask() {
        RechargeEcardTask.Builder builder = new Builder();
        int customerID = userInfoApplication.getSelectedCustomerID();
        String amount = eCardRechargeNumberText.getText().toString();
        String giveAmount = "0";
        String giveAmountPoint = "0";
        String giveAmountCashCoupon = "0";
        String remark = "";
        if (eCardRechargeGiveNumberText.getText().toString() != null && !(eCardRechargeGiveNumberText.getText().toString().equals(""))) {
            giveAmount = eCardRechargeGiveNumberText.getText().toString();
        }
        if (givePointText.getText().toString() != null && !(givePointText.getText().toString().equals(""))) {
            giveAmountPoint = givePointText.getText().toString();
        }
        if (giveCashCouponText.getText().toString() != null && !(giveCashCouponText.getText().toString().equals(""))) {
            giveAmountCashCoupon = giveCashCouponText.getText().toString();
        }
        if (ecardBalanceRemark.getText().toString() != null && !(ecardBalanceRemark.getText().toString().equals(""))) {
            remark = ecardBalanceRemark.getText().toString();
        }
        JSONArray giveJsonArray = new JSONArray();
        if (Double.valueOf(giveAmount) != 0) {
            JSONObject giveAmountJson = new JSONObject();
            try {
                giveAmountJson.put("CardType", ecardInfo.getUserEcardType());
                giveAmountJson.put("UserCardNo", ecardInfo.getUserEcardNo());
                giveAmountJson.put("Amount", NumberFormatUtil.currencyFormat(giveAmount));
            } catch (JSONException e) {
            }
            giveJsonArray.put(giveAmountJson);
        }
        if (Double.valueOf(giveAmountPoint) != 0) {
            JSONObject giveAmountPointJson = new JSONObject();
            try {
                giveAmountPointJson.put("CardType", customerEcardInfoPoint.getUserEcardType());
                giveAmountPointJson.put("UserCardNo", customerEcardInfoPoint.getUserEcardNo());
                giveAmountPointJson.put("Amount", NumberFormatUtil.currencyFormat(giveAmountPoint));
            } catch (JSONException e) {
            }
            giveJsonArray.put(giveAmountPointJson);
        }
        if (Double.valueOf(giveAmountCashCoupon) != 0) {
            JSONObject giveAmountCashCouponJson = new JSONObject();
            try {
                giveAmountCashCouponJson.put("CardType", customerEcardInfoCashCoupon.getUserEcardType());
                giveAmountCashCouponJson.put("UserCardNo", customerEcardInfoCashCoupon.getUserEcardNo());
                giveAmountCashCouponJson.put("Amount", NumberFormatUtil.currencyFormat(giveAmountCashCoupon));
            } catch (JSONException e) {
            }
            giveJsonArray.put(giveAmountCashCouponJson);
        }
        JSONArray benefitDetailJsonArray = new JSONArray();
        if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]"))
            ;
        else {
            try {
                JSONArray tmp = new JSONArray(mBenefitPersonIDs);
                for (int i = 5; i < ecardSlaverTablelayout.getChildCount(); i++) {
                    EditText percentEditText = ((EditText) ecardSlaverTablelayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                    double percent = 0;
                    if (percentEditText.getText() != null && shareFlg == 0)
                        percent = Double.valueOf(percentEditText.getText().toString()) / 100;
                    JSONObject benefitJson = new JSONObject();
                    benefitJson.put("SlaveID", tmp.get(i - 5));
                    benefitJson.put("ProfitPct", percent);
                    benefitDetailJsonArray.put(benefitJson);
                }
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        builder.setAmount(amount).setChangeType(3).setCardType(ecardInfo.getUserEcardType()).setDepositMode(rechargeType).
                setUserCardNo(ecardInfo.getUserEcardNo()).setCustomerID(customerID).setHandler(mHandler)
                .setRemark(remark).setResponsiblePersonID(0).setSlaveIDs(benefitDetailJsonArray.toString()).setGiveJsonArray(giveJsonArray)
                .setAverageFlag(shareFlg).setBranchProfitRate(Double.valueOf(thisBenefitSharePercent.getText().toString()) / 100);
        return builder.create();
    }

    //跳转到微信或者支付宝支付界面
    protected void thirdPartPay(String selectedItemStr) {
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        int customerID = userInfoApplication.getSelectedCustomerID();
        String amount = eCardRechargeNumberText.getText().toString();
        String giveAmount = "0";
        String giveAmountPoint = "0";
        String giveAmountCashCoupon = "0";
        String remark = "";
        if (eCardRechargeGiveNumberText.getText().toString() != null && !(eCardRechargeGiveNumberText.getText().toString().equals(""))) {
            giveAmount = eCardRechargeGiveNumberText.getText().toString();
        }
        if (givePointText.getText().toString() != null && !(givePointText.getText().toString().equals(""))) {
            giveAmountPoint = givePointText.getText().toString();
        }
        if (giveCashCouponText.getText().toString() != null && !(giveCashCouponText.getText().toString().equals(""))) {
            giveAmountCashCoupon = giveCashCouponText.getText().toString();
        }
        if (ecardBalanceRemark.getText().toString() != null && !(ecardBalanceRemark.getText().toString().equals(""))) {
            remark = ecardBalanceRemark.getText().toString();
        }
        Intent destIntent = new Intent();
        destIntent.putExtra("customerID", customerID);
        Bundle bundle = new Bundle();
        bundle.putSerializable("ecardInfo", ecardInfo);
        bundle.putSerializable("customerEcardPoint", customerEcardInfoPoint);
        bundle.putSerializable("customerEcardCashcoupon", customerEcardInfoCashCoupon);
        destIntent.putExtras(bundle);
        JSONArray benefitDetailJsonArray = new JSONArray();
        if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]"))
            ;
        else {
            try {
                JSONArray tmp = new JSONArray(mBenefitPersonIDs);
                for (int i = 5; i < ecardSlaverTablelayout.getChildCount(); i++) {
                    EditText percentEditText = ((EditText) ecardSlaverTablelayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                    double percent = 0;
                    if (percentEditText.getText() != null)
                        percent = Double.valueOf(percentEditText.getText().toString()) / 100;
                    JSONObject benefitJson = new JSONObject();
                    benefitJson.put("SlaveID", tmp.get(i - 5));
                    benefitJson.put("ProfitPct", percent);
                    benefitDetailJsonArray.put(benefitJson);
                }
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        destIntent.putExtra("slaveID", benefitDetailJsonArray.toString());
        destIntent.putExtra("totalAmount", NumberFormatUtil.currencyFormat(amount));
        destIntent.putExtra("pointAmount", NumberFormatUtil.currencyFormat(giveAmountPoint));
        destIntent.putExtra("couponAmount", NumberFormatUtil.currencyFormat(giveAmountCashCoupon));
        destIntent.putExtra("moneyAmount", NumberFormatUtil.currencyFormat(giveAmount));
        destIntent.putExtra("remark", remark);
        destIntent.putExtra("payType", 1);
        destIntent.putExtra("AverageFlag", shareFlg);
        destIntent.putExtra("BranchProfitRate", Double.valueOf(thisBenefitSharePercent.getText().toString()) / 100);
        if (selectedItemStr.equals("微信")) {
            destIntent.putExtra("paymentMode", Constant.PAYMENT_MODE_WEIXIN);
        } else if (selectedItemStr.equals("支付宝")) {
            destIntent.putExtra("paymentMode", Constant.PAYMENT_MODE_ALI);
        }
        destIntent.setClass(EditEcardBalanceActivity.this, PaymentActionThirdPartActivity.class);
        startActivity(destIntent);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        // 余额转入
        if (eCardRechargeTypeSpinner.getSelectedItem().toString().equals("余额转入")) {
            eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
            eCardRechargeNumberText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
            eCardRechargeGiveNumberText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
            rechargeNumberTotalRelativelayout.setVisibility(View.GONE);
            giveAmountDivideView.setVisibility(View.GONE);
            giveAmountRelativeLayout.setVisibility(View.GONE);
            rechargeNumberTitle.setText("转入金额");
            findViewById(R.id.benefit_person_divide_view).setVisibility(View.GONE);
            findViewById(R.id.benefit_person_layout).setVisibility(View.GONE);
            ecardSlaverTablelayout.removeViews(5, ecardSlaverTablelayout.getChildCount() - 5);
            ecardGiveOtherTablelayout.setVisibility(View.GONE);
        } else {
            rechargeNumberTotalRelativelayout.setVisibility(View.VISIBLE);
            eCardRechargeTotalText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
            eCardRechargeNumberText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
            eCardRechargeGiveNumberText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
            giveAmountDivideView.setVisibility(View.VISIBLE);
            giveAmountRelativeLayout.setVisibility(View.VISIBLE);
            rechargeNumberTitle.setText("充值金额");
            findViewById(R.id.benefit_person_divide_view).setVisibility(View.VISIBLE);
            findViewById(R.id.benefit_person_layout).setVisibility(View.VISIBLE);
            ecardGiveOtherTablelayout.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {
    }
}
