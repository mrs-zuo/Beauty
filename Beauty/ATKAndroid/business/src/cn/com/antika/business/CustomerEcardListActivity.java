package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class CustomerEcardListActivity extends BaseActivity implements OnClickListener {
    private CustomerEcardListActivityHandler mHandler = new CustomerEcardListActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private List<EcardInfo> customerEcardInfoList;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private ImageView addNewCustomerEcardBtn;
    private EcardInfo customerEcardInfoPoint;//积分卡
    private EcardInfo customerEcardInfoCashCoupon;//现金券卡
    private RelativeLayout allEcardHistoryRelativelayout;
    private LinearLayout ecardListLinearLayout;
    private LayoutInflater layoutInflater;
    private boolean isCustomerFirstCard = true;//是否是顾客的第一张卡
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_ecard_list);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class CustomerEcardListActivityHandler extends Handler {
        private final CustomerEcardListActivity customerEcardListActivity;

        private CustomerEcardListActivityHandler(CustomerEcardListActivity activity) {
            WeakReference<CustomerEcardListActivity> weakReference = new WeakReference<CustomerEcardListActivity>(activity);
            customerEcardListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (customerEcardListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerEcardListActivity.progressDialog != null) {
                customerEcardListActivity.progressDialog.dismiss();
                customerEcardListActivity.progressDialog = null;
            }
            if (customerEcardListActivity.requestWebServiceThread != null) {
                customerEcardListActivity.requestWebServiceThread.interrupt();
                customerEcardListActivity.requestWebServiceThread = null;
            }
            // 清除会员卡信息
            customerEcardListActivity.ecardListLinearLayout.removeAllViews();
            if (msg.what == 1) {
                customerEcardListActivity.getNewestCustomerInfo();
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(customerEcardListActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerEcardListActivity, customerEcardListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerEcardListActivity);
            } else if (msg.what == 3) {
                customerEcardListActivity.initEcardListView();
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerEcardListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerEcardListActivity);
                customerEcardListActivity.packageUpdateUtil = new PackageUpdateUtil(customerEcardListActivity, customerEcardListActivity.mHandler, fileCache, downloadFileUrl, false, customerEcardListActivity.userinfoApplication);
                customerEcardListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerEcardListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = customerEcardListActivity.getFileStreamPath(filename);
                file.getName();
                customerEcardListActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 99) {
                DialogUtil.createShortDialog(customerEcardListActivity, "服务器异常，请重试");
                // 清除eCard信息
                customerEcardListActivity.ecardListLinearLayout.removeAllViews();
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        /*progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();*/
        addNewCustomerEcardBtn = (ImageView) findViewById(R.id.add_new_customer_ecard_btn);
        addNewCustomerEcardBtn.setOnClickListener(this);
        //判断有没有创建顾客E账户的权限
        if (userinfoApplication.getAccountInfo().getAuthCustomerEcardAdd() == 0)
            addNewCustomerEcardBtn.setVisibility(View.GONE);
        else if (userinfoApplication.getAccountInfo().getAuthCustomerEcardAdd() == 1)
            addNewCustomerEcardBtn.setVisibility(View.VISIBLE);
        allEcardHistoryRelativelayout = (RelativeLayout) findViewById(R.id.all_ecard_history_relativelayout);
        allEcardHistoryRelativelayout.setOnClickListener(this);
        findViewById(R.id.all_ecard_history_third_part_payment_relativelayout).setOnClickListener(this);
        ecardListLinearLayout = (LinearLayout) findViewById(R.id.ecard_list_linearlayout);
        //如果没有第三方支付功能  则隐藏第三方支付功能
        if (userinfoApplication.getAccountInfo().getModuleInUse().contains("|5|") || userinfoApplication.getAccountInfo().getModuleInUse().contains("|6|")) {
            findViewById(R.id.all_ecard_history_third_part_payment_relativelayout).setVisibility(View.VISIBLE);
        } else {
            findViewById(R.id.all_ecard_history_third_part_payment_relativelayout).setVisibility(View.GONE);
        }
        requestWebService();
    }

    private void requestWebService() {
        progressDialog = ProgressDialogUtil.createProgressDialog(this);
        customerEcardInfoList = new ArrayList<EcardInfo>();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "GetCustomerCardList";
                String endPoint = "ECard";
                JSONObject getCustomerEcardListJsonParam = new JSONObject();
                try {
                    getCustomerEcardListJsonParam.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getCustomerEcardListJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    JSONArray customerEcardJsonArray = null;
                    int code = 0;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        try {
                            customerEcardJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        for (int i = 0; i < customerEcardJsonArray.length(); i++) {
                            JSONObject customerEcardJson = null;
                            try {
                                customerEcardJson = customerEcardJsonArray.getJSONObject(i);
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            String userEcardNo = "";
                            String userEcardName = "";
                            String userEcardBalance = "";
                            boolean isDefault = false;
                            int userEcardType = 1;
                            try {
                                if (customerEcardJson.has("UserCardNo") && !customerEcardJson.isNull("UserCardNo"))
                                    userEcardNo = customerEcardJson.getString("UserCardNo");
                                if (customerEcardJson.has("CardName") && !customerEcardJson.isNull("CardName"))
                                    userEcardName = customerEcardJson.getString("CardName");
                                if (customerEcardJson.has("Balance") && !customerEcardJson.isNull("Balance"))
                                    userEcardBalance = customerEcardJson.getString("Balance");
                                if (customerEcardJson.has("IsDefault") && !customerEcardJson.isNull("IsDefault"))
                                    isDefault = customerEcardJson.getBoolean("IsDefault");
                                if (customerEcardJson.has("CardTypeID") && !customerEcardJson.isNull("CardTypeID"))
                                    userEcardType = customerEcardJson.getInt("CardTypeID");
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            EcardInfo ecardInfo = new EcardInfo();
                            ecardInfo.setUserEcardNo(userEcardNo);
                            ecardInfo.setUserEcardName(userEcardName);
                            ecardInfo.setUserEcardBalance(userEcardBalance);
                            ecardInfo.setDefault(isDefault);
                            ecardInfo.setUserEcardType(userEcardType);
                            //将积分卡和现金券带到详细页，为了后面的充值使用
                            //积分卡
                            if (userEcardType == 2)
                                customerEcardInfoPoint = ecardInfo;
                                //现金券
                            else if (userEcardType == 3)
                                customerEcardInfoCashCoupon = ecardInfo;
                            customerEcardInfoList.add(ecardInfo);
                        }
                        //福利包
                        EcardInfo benefitEcard = new EcardInfo();
                        benefitEcard.setUserEcardNo("");
                        benefitEcard.setUserEcardName("福利包");
                        benefitEcard.setUserEcardBalance(String.valueOf(""));
                        benefitEcard.setDefault(false);
                        benefitEcard.setUserEcardType(4);
                        customerEcardInfoList.add(benefitEcard);
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void getNewestCustomerInfo() {
        progressDialog = ProgressDialogUtil.createProgressDialog(CustomerEcardListActivity.this);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetCustomerInfo";
                String endPoint = "customer";
                JSONObject customerBsaicJsonParam = new JSONObject();
                int selectedCustomerID = userinfoApplication.getSelectedCustomerID();
                try {
                    customerBsaicJsonParam.put("CustomerID", selectedCustomerID);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerBsaicJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject customerBasicJsonObject = null;
                    try {
                        customerBasicJsonObject = new JSONObject(serverRequestResult);
                        code = customerBasicJsonObject.getInt("Code");
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        JSONObject customerBasicJson = null;
                        try {
                            customerBasicJson = customerBasicJsonObject.getJSONObject("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        try {
                            String defaultCardNo = "";
                            if (customerBasicJson.has("DefaultCardNo") && !customerBasicJson.isNull("DefaultCardNo"))
                                defaultCardNo = customerBasicJson.getString("DefaultCardNo");
                            if (defaultCardNo.equals(""))
                                isCustomerFirstCard = true;
                            else
                                isCustomerFirstCard = false;
                        } catch (JSONException e) {
                            isCustomerFirstCard = false;
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        mHandler.sendEmptyMessage(3);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    private void initEcardListView() {
        ecardListLinearLayout.removeAllViews();
        if (customerEcardInfoList.size() > 0) {
            for (int i = 0; i < customerEcardInfoList.size(); i++) {
                final int ecardIndex = i;
                layoutInflater = LayoutInflater.from(this);
                View customerEcardListItem = layoutInflater.inflate(R.xml.customer_ecard_list_item, null);
                TableLayout ecardTableLayout = (TableLayout) customerEcardListItem.findViewById(R.id.ecard_tablelayout);
                ImageView customerIsDefaultIcon = (ImageView) customerEcardListItem.findViewById(R.id.customer_ecard_default);
                TextView customerEcardNameText = (TextView) customerEcardListItem.findViewById(R.id.customer_ecard_name);
                TextView customerEcardBalanceText = (TextView) customerEcardListItem.findViewById(R.id.customer_ecard_balance);
                TextView customerEcardNo = (TextView) customerEcardListItem.findViewById(R.id.customer_ecardno);
                RelativeLayout ecardRelativeLayout = (RelativeLayout) customerEcardListItem.findViewById(R.id.ecard_relativelayout);
                String currency = UserInfoApplication.getInstance().getAccountInfo().getCurrency();
                final int userCardType = customerEcardInfoList.get(i).getUserEcardType();
                customerEcardNameText.setText(customerEcardInfoList.get(i).getUserEcardName());
                if (userCardType == 1) {
                    ecardRelativeLayout.setBackgroundResource(R.drawable.ecard_background_orange);
                } else if (userCardType == 2) {
                    ecardRelativeLayout.setBackgroundResource(R.drawable.ecard_background_purple);
                } else if (userCardType == 3) {
                    ecardRelativeLayout.setBackgroundResource(R.drawable.ecard_background_green);
                } else if (userCardType == 4)
                    ecardRelativeLayout.setBackgroundResource(R.drawable.ecard_background_dark_red);
                //福利包的卡余额设置为空
                if (userCardType == 4) {
                    customerEcardBalanceText.setText("");
                } else {
                    if (userCardType != 2)
                        customerEcardBalanceText.setText(currency + customerEcardInfoList.get(i).getUserEcardBalance());
                    else
                        customerEcardBalanceText.setText(customerEcardInfoList.get(i).getUserEcardBalance());
                }
                boolean isDefault = customerEcardInfoList.get(i).isDefault();
                if (!TextUtils.isEmpty(customerEcardInfoList.get(i).getUserEcardNo())) {
                    customerEcardNo.setText(customerEcardInfoList.get(i).getUserEcardNo());
                }
                if (isDefault)
                    customerIsDefaultIcon.setBackgroundResource(R.drawable.customer_ecard_is_default_yellow_icon);

                ecardTableLayout.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent destIntent = null;
                        //如果不是福利包 则跳转到卡详细页
                        if (userCardType != 4) {
                            destIntent = new Intent(CustomerEcardListActivity.this, CustomerEcardActivity.class);
                            Bundle bundle = new Bundle();
                            bundle.putSerializable("customerEcard", customerEcardInfoList.get(ecardIndex));
                            bundle.putSerializable("customerEcardPoint", customerEcardInfoPoint);
                            bundle.putSerializable("customerEcardCashcoupon", customerEcardInfoCashCoupon);
                            destIntent.putExtra("isCustomerFirstCard", isCustomerFirstCard);
                            destIntent.putExtras(bundle);
                        }
                        //是福利包的话，则跳转到福利包的界面
                        else if (userCardType == 4) {
                            destIntent = new Intent(CustomerEcardListActivity.this, CustomerBenefitsActivity.class);
                        }
                        if (destIntent != null)
                            startActivity(destIntent);
                    }
                });
                ecardListLinearLayout.addView(customerEcardListItem);
            }
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
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
    protected void onRestart() {
        // TODO Auto-generated method stub
        super.onRestart();
        requestWebService();
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        //为客户新开卡
        if (view.getId() == R.id.add_new_customer_ecard_btn) {
            Intent destIntent = new Intent(this, AddNewCustomerEcardActivity.class);
            destIntent.putExtra("isCustomerFirstCard", isCustomerFirstCard);
            startActivity(destIntent);
        }
        //账户交易记录
        else if (view.getId() == R.id.all_ecard_history_relativelayout) {
            Intent destIntent = new Intent(this, AllEcardHistoryListActivity.class);
            startActivity(destIntent);
        }
        //卡的第三方交易记录(包括微信和支付宝)
        else if (view.getId() == R.id.all_ecard_history_third_part_payment_relativelayout) {
            Intent resultIntent = new Intent();
            resultIntent.setClass(this, OrderDetailThirdPartPayListActivity.class);
            resultIntent.putExtra("thirdPartPayType", 1);
            resultIntent.putExtra("customerID", userinfoApplication.getSelectedCustomerID());
            startActivity(resultIntent);
        }
    }
}
