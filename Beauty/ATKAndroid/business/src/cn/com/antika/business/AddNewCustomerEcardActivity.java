package cn.com.antika.business;

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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DiscountDetail;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.timer.DialogTimerTask;
import cn.com.antika.util.DateButton;
import cn.com.antika.util.DateUtil;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 为顾客新开卡
 * */
@SuppressLint("ResourceType")
public class AddNewCustomerEcardActivity extends BaseActivity implements OnClickListener, OnItemSelectedListener {
    private AddNewCustomerEcardActivityHandler mHandler = new AddNewCustomerEcardActivityHandler(this);
    private Spinner ecardNameSpinner;
    private Button addNewCustomerEcardMakeSureBtn;
    private Thread requestWebServiceThread;
    private List<EcardInfo> ecardInfoList;
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private Timer dialogTimer;
    private LayoutInflater layoutInflater;
    private PackageUpdateUtil packageUpdateUtil;
    private EcardInfo selectedEcardInfo;
    private TableLayout ecardInfoDiscountTablelayout;
    private RelativeLayout newCustomerEcardIsDefaultRelativelayout;
    private ImageView newCustomerEcardIsDefaultIcon;
    private boolean newCustomerEcardIsDefault, isCustomerFirstCard;
    private TextView newCustomerEcardStartDateText, newCustomerEcardExpirationDateText;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_add_new_customer_ecard);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class AddNewCustomerEcardActivityHandler extends Handler {
        private final AddNewCustomerEcardActivity addNewCustomerEcardActivity;

        private AddNewCustomerEcardActivityHandler(AddNewCustomerEcardActivity activity) {
            WeakReference<AddNewCustomerEcardActivity> weakReference = new WeakReference<AddNewCustomerEcardActivity>(activity);
            addNewCustomerEcardActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (addNewCustomerEcardActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (addNewCustomerEcardActivity.progressDialog != null) {
                addNewCustomerEcardActivity.progressDialog.dismiss();
                addNewCustomerEcardActivity.progressDialog = null;
            }
            if (addNewCustomerEcardActivity.requestWebServiceThread != null) {
                addNewCustomerEcardActivity.requestWebServiceThread.interrupt();
                addNewCustomerEcardActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                if (addNewCustomerEcardActivity.ecardInfoList.size() > 0) {
                    String[] ecardNameArray = new String[addNewCustomerEcardActivity.ecardInfoList.size()];
                    for (int i = 0; i < addNewCustomerEcardActivity.ecardInfoList.size(); i++) {
                        ecardNameArray[i] = addNewCustomerEcardActivity.ecardInfoList.get(i).getUserEcardName();
                    }
                    ArrayAdapter<String> ecardNameAdapter = new ArrayAdapter<String>(addNewCustomerEcardActivity, R.xml.spinner_checked_text, ecardNameArray);
                    ecardNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    addNewCustomerEcardActivity.ecardNameSpinner.setAdapter(ecardNameAdapter);
                    addNewCustomerEcardActivity.ecardNameSpinner.setSelection(0);
                }
            } else if (msg.what == 2) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(addNewCustomerEcardActivity, "提示信息", "新增储值卡成功！");
                alertDialog.show();
                Intent destIntent = new Intent(addNewCustomerEcardActivity, CustomerEcardListActivity.class);
                addNewCustomerEcardActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, addNewCustomerEcardActivity.dialogTimer, addNewCustomerEcardActivity, destIntent);
                addNewCustomerEcardActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 0) {
                DialogUtil.createShortDialog(addNewCustomerEcardActivity, (String) msg.obj);
            } else if (msg.what == 3)
                DialogUtil.createShortDialog(addNewCustomerEcardActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == 4) {
                if (!addNewCustomerEcardActivity.isCustomerFirstCard) {
                    addNewCustomerEcardActivity.newCustomerEcardIsDefault = false;
                    addNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.no_select_btn);
                    addNewCustomerEcardActivity.newCustomerEcardIsDefaultRelativelayout.setOnClickListener(addNewCustomerEcardActivity);
                    addNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setOnClickListener(addNewCustomerEcardActivity);
                } else {
                    addNewCustomerEcardActivity.newCustomerEcardIsDefault = true;
                    addNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.select_btn);
                    addNewCustomerEcardActivity.newCustomerEcardIsDefaultIcon.setOnClickListener(null);
                    addNewCustomerEcardActivity.newCustomerEcardIsDefaultRelativelayout.setOnClickListener(null);
                }
                ((TextView) addNewCustomerEcardActivity.findViewById(R.id.new_customer_ecard_expiration_date)).setText(addNewCustomerEcardActivity.selectedEcardInfo.getUserEcardExpirationDate());
                String ecardDescription = addNewCustomerEcardActivity.selectedEcardInfo.getUserEcardDescription();
                if (ecardDescription != null && !ecardDescription.equals("")) {
                    addNewCustomerEcardActivity.findViewById(R.id.ecard_description_table_layout).setVisibility(View.VISIBLE);
                    ((TextView) addNewCustomerEcardActivity.findViewById(R.id.new_customer_ecard_description)).setText(addNewCustomerEcardActivity.selectedEcardInfo.getUserEcardDescription());
                } else
                    addNewCustomerEcardActivity.findViewById(R.id.ecard_description_table_layout).setVisibility(View.GONE);
                List<DiscountDetail> discountDetailList = addNewCustomerEcardActivity.selectedEcardInfo.getDiscountDetailList();
                addNewCustomerEcardActivity.ecardInfoDiscountTablelayout.removeAllViews();
                if (discountDetailList != null && discountDetailList.size() > 0) {
                    View discountTitleView = addNewCustomerEcardActivity.layoutInflater.inflate(R.xml.ecard_discount_title, null);
                    addNewCustomerEcardActivity.ecardInfoDiscountTablelayout.addView(discountTitleView);
                    for (int i = 0; i < discountDetailList.size(); i++) {
                        DiscountDetail discountDetail = discountDetailList.get(i);
                        View discountDetailItemView = addNewCustomerEcardActivity.layoutInflater.inflate(R.xml.discount_detail_list_item, null);
                        TextView discountNameText = (TextView) discountDetailItemView.findViewById(R.id.discount_name_text);
                        TextView discountRateText = (TextView) discountDetailItemView.findViewById(R.id.discount_rate_text);
                        discountNameText.setText(discountDetail.getDiscountDetailName());
                        discountRateText.setText(NumberFormatUtil.currencyFormat(discountDetail.getDiscountRate()));
                        addNewCustomerEcardActivity.ecardInfoDiscountTablelayout.addView(discountDetailItemView);
                    }
                }

            } else if (msg.what == 6)
                DialogUtil.createShortDialog(addNewCustomerEcardActivity,
                        (String) msg.obj);
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(addNewCustomerEcardActivity, addNewCustomerEcardActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(addNewCustomerEcardActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + addNewCustomerEcardActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(addNewCustomerEcardActivity);
                addNewCustomerEcardActivity.packageUpdateUtil = new PackageUpdateUtil(addNewCustomerEcardActivity, addNewCustomerEcardActivity.mHandler, fileCache, downloadFileUrl, false, addNewCustomerEcardActivity.userinfoApplication);
                addNewCustomerEcardActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                addNewCustomerEcardActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = addNewCustomerEcardActivity.getFileStreamPath(filename);
                file.getName();
                addNewCustomerEcardActivity.packageUpdateUtil.showInstallDialog();
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
        layoutInflater = LayoutInflater.from(this);
        ecardNameSpinner = (Spinner) findViewById(R.id.ecard_name_spinner);
        ecardNameSpinner.setOnItemSelectedListener(this);
        ((TextView) findViewById(R.id.new_custmer_ecard_customer_name)).setText(userinfoApplication.getSelectedCustomerName());
        addNewCustomerEcardMakeSureBtn = (Button) findViewById(R.id.add_new_customer_ecard_make_sure_btn);
        addNewCustomerEcardMakeSureBtn.setOnClickListener(this);
        ecardInfoDiscountTablelayout = (TableLayout) findViewById(R.id.discount_detail_list_tablelayout);
        newCustomerEcardStartDateText = (TextView) findViewById(R.id.new_customer_ecard_start_date);
        newCustomerEcardStartDateText.setText(DateUtil.getNowFormateDate2());
        newCustomerEcardExpirationDateText = (TextView) findViewById(R.id.new_customer_ecard_expiration_date);
        newCustomerEcardExpirationDateText.setOnClickListener(this);
        newCustomerEcardIsDefaultRelativelayout = (RelativeLayout) findViewById(R.id.new_customer_ecard_is_default_relativelayout);
        newCustomerEcardIsDefaultIcon = (ImageView) findViewById(R.id.ecard_is_default_icon);
        isCustomerFirstCard = getIntent().getBooleanExtra("isCustomerFirstCard", true);

        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetBranchCardList";
                String endPoint = "ECard";
                JSONObject getEcardListJsonParam = new JSONObject();
                try {
                    getEcardListJsonParam.put("isOnlyMoneyCard", true);
                    getEcardListJsonParam.put("isShowAll", false);
                    getEcardListJsonParam.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getEcardListJsonParam.toString(), userinfoApplication);
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
                    if (code == 1) {
                        JSONArray ecardJsonArray = null;
                        try {
                            ecardJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (ecardJsonArray != null) {
                            ecardInfoList = new ArrayList<EcardInfo>();
                            for (int i = 0; i < ecardJsonArray.length(); i++) {
                                JSONObject ecardJson = null;
                                try {
                                    ecardJson = (JSONObject) ecardJsonArray.get(i);
                                } catch (JSONException e1) {
                                }
                                int cardID = 0;
                                String userEcardName = "";
                                String userEcardBalance = "";
                                String userEcardCreateDate = "";
                                String userEcardExpirationDate = "";
                                int userEcardType = 1;
                                String userEcardDescription = "";
                                JSONArray discountJsonArray = null;
                                List<DiscountDetail> discountDetailList = null;
                                try {
                                    if (ecardJson.has("CardID") && !ecardJson.isNull("CardID"))
                                        cardID = ecardJson.getInt("CardID");
                                    if (ecardJson.has("CardName") && !ecardJson.isNull("CardName"))
                                        userEcardName = ecardJson.getString("CardName");
                                    if (ecardJson.has("Balance") && !ecardJson.isNull("Balance"))
                                        userEcardBalance = ecardJson.getString("Balance");
                                    if (ecardJson.has("CardCreatedDate") && !ecardJson.isNull("CardCreatedDate"))
                                        userEcardCreateDate = ecardJson.getString("CardCreatedDate");
                                    if (ecardJson.has("CardExpiredDate") && !ecardJson.isNull("CardExpiredDate"))
                                        userEcardExpirationDate = ecardJson.getString("CardExpiredDate");
                                    if (ecardJson.has("CardTypeID") && !ecardJson.isNull("CardTypeID"))
                                        userEcardType = ecardJson.getInt("CardTypeID");
                                    if (ecardJson.has("CardDescription") && !ecardJson.isNull("CardDescription"))
                                        userEcardDescription = ecardJson.getString("CardDescription");
                                    if (ecardJson.has("DiscountList") && !ecardJson.isNull("DiscountList"))
                                        discountJsonArray = ecardJson.getJSONArray("DiscountList");
                                    if (discountJsonArray != null) {
                                        discountDetailList = new ArrayList<DiscountDetail>();
                                        for (int j = 0; j < discountJsonArray.length(); j++) {
                                            JSONObject discountJson = discountJsonArray.getJSONObject(j);
                                            DiscountDetail discountDetail = new DiscountDetail();
                                            if (discountJson.has("DiscountName"))
                                                discountDetail.setDiscountDetailName(discountJson.getString("DiscountName"));
                                            if (discountJson.has("Discount"))
                                                discountDetail.setDiscountRate(discountJson.getString("Discount"));
                                            discountDetailList.add(discountDetail);
                                        }

                                    }
                                } catch (JSONException e) {
                                }
                                EcardInfo customerEcardInfo = new EcardInfo();
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
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
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
            case R.id.add_new_customer_ecard_make_sure_btn:
                if (userinfoApplication.getSelectedCustomerID() == 0) {
                    DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
                } else if (selectedEcardInfo.getUserEcardID() == 0) {
                    DialogUtil.createShortDialog(this, "您还没有选择卡！");
                } else {
                    progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                    progressDialog.setMessage(getString(R.string.please_wait));
                    progressDialog.show();
                    //实体卡号
                    final String userRealCardNo = ((EditText) findViewById(R.id.new_customer_ecard_real_card_no_text)).getText().toString();
                    requestWebServiceThread = new Thread() {
                        public void run() {
                            // TODO Auto-generated method stub
                            String methodName = "AddCustomerCard";
                            String endPoint = "ECard";
                            JSONObject addNewCustomerEcardJson = new JSONObject();
                            try {
                                addNewCustomerEcardJson.put("CardID", selectedEcardInfo.getUserEcardID());
                                addNewCustomerEcardJson.put("IsDefault", newCustomerEcardIsDefault);
                                addNewCustomerEcardJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                                addNewCustomerEcardJson.put("Currency", userinfoApplication.getAccountInfo().getCurrency());
                                addNewCustomerEcardJson.put("CardCreatedDate", ((TextView) findViewById(R.id.new_customer_ecard_start_date)).getText().toString());
                                addNewCustomerEcardJson.put("CardExpiredDate", ((TextView) findViewById(R.id.new_customer_ecard_expiration_date)).getText().toString());
                                if (userRealCardNo != null && !("").equals(userRealCardNo))
                                    addNewCustomerEcardJson.put("RealCardNo", userRealCardNo);
                                else
                                    addNewCustomerEcardJson.put("RealCardNo", "");
                            } catch (JSONException e) {
                            }
                            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addNewCustomerEcardJson.toString(), userinfoApplication);
                            String msg = "";
                            if (serverRequestResult == null || serverRequestResult.equals(""))
                                mHandler.sendEmptyMessage(3);
                            else {
                                JSONObject resultJson = null;
                                int code = 0;
                                try {
                                    resultJson = new JSONObject(serverRequestResult);
                                    code = resultJson.getInt("Code");
                                    msg = resultJson.getString("Message");
                                } catch (JSONException e) {
                                }
                                if (code == 1)
                                    mHandler.sendEmptyMessage(2);
                                else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                    mHandler.sendEmptyMessage(code);
                                else {
                                    Message message = new Message();
                                    message.what = 0;
                                    message.obj = msg;
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
    protected void showDateDialog(int textViewResourcesID) {
        DateButton dateButton = new DateButton(this, (EditText) findViewById(textViewResourcesID), Constant.DATE_DIALOG_SHOW_TYPE_EXPIRATION, null);
        dateButton.datePickerDialog();
    }

    protected void setEcardDefault() {
        if (newCustomerEcardIsDefault) {
            newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.no_select_btn);
            newCustomerEcardIsDefault = false;
        } else if (!newCustomerEcardIsDefault) {
            newCustomerEcardIsDefaultIcon.setBackgroundResource(R.drawable.select_btn);
            newCustomerEcardIsDefault = true;
        }
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        selectedEcardInfo = ecardInfoList.get(position);
        mHandler.sendEmptyMessage(4);
    }

    @Override
    public void onNothingSelected(AdapterView<?> arg0) {

    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
    }

}
