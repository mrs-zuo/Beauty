package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.Customer;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

/*
 * 我的顾客--详细信息
 * */
public class CustomerDetailActivity extends BaseActivity {
    private CustomerDetailActivityHandler mHandler = new CustomerDetailActivityHandler(this);
    private Thread requestWebServiceThread;
    private TableLayout customerDetailBasicTableLayout;
    private TableLayout customerDetailRemarkTableLayout;
    private ProgressDialog progressDialog;
    private ImageButton customerDetailEditBtn;
    private String birthday = "";
    private String height = "";
    private String weight = "";
    private String bloodType = "";
    private String marriage = "-1";
    private String profession = "";
    private String remark;
    private Customer customer = new Customer();
    private UserInfoApplication userinfoApplication;
    private RelativeLayout customerDetailBirthdayRelativeLayout;
    private TextView customerDetailBirthdayText;
    private View afterCustomerDetailBirthdayDivideView;
    private RelativeLayout customerDetailHeightRelativeLayout;
    private TextView customerDetailHeightText;
    private View afterCustomerDetailHeightDivideView;
    private RelativeLayout customerDetailWeightRelativeLayout;
    private TextView customerDetailWeightText;
    private View afterCustomerDetailWeightDivideView;
    private RelativeLayout customerDetailBloodTypeRelativeLayout;
    private TextView customerDetailBloodTypeText;
    private View afterCustomerDetailBloodTypeDivideView;
    private RelativeLayout customerDetailMarriageRelativeLayout;
    private TextView customerDetailMarriageText;
    private View afterCustomerDetailMarriageDivideView;
    private RelativeLayout customerDetailProfessionRelativeLayout;
    private TextView customerDetailProfessionText;
    private TextView customerDetailRemarkText;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_detail);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class CustomerDetailActivityHandler extends Handler {
        private final CustomerDetailActivity customerDetailActivity;

        private CustomerDetailActivityHandler(CustomerDetailActivity activity) {
            WeakReference<CustomerDetailActivity> weakReference = new WeakReference<CustomerDetailActivity>(activity);
            customerDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (customerDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerDetailActivity.progressDialog != null) {
                customerDetailActivity.progressDialog.dismiss();
                customerDetailActivity.progressDialog = null;
            }
            if (customerDetailActivity.requestWebServiceThread != null) {
                customerDetailActivity.requestWebServiceThread.interrupt();
                customerDetailActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                if (customerDetailActivity.birthday != null && !(("").equals(customerDetailActivity.birthday))) {
                    customerDetailActivity.customerDetailBasicTableLayout.setVisibility(View.VISIBLE);
                    String[] birthDayArray = customerDetailActivity.birthday.split("-");
                    if (!birthDayArray[0].equals("2104"))
                        customerDetailActivity.customer.setBirthday(customerDetailActivity.birthday);
                    else
                        customerDetailActivity.customer.setBirthday(birthDayArray[1] + "-" + birthDayArray[2]);
                    customerDetailActivity.customerDetailBirthdayRelativeLayout.setVisibility(View.VISIBLE);
                    if (!birthDayArray[0].equals("2104"))
                        customerDetailActivity.customerDetailBirthdayText.setText(customerDetailActivity.birthday);
                    else
                        customerDetailActivity.customerDetailBirthdayText.setText(birthDayArray[1] + "-" + birthDayArray[2]);
                }
                if (customerDetailActivity.height != null && !(("").equals(customerDetailActivity.height)) && Float.valueOf(customerDetailActivity.height) != 0) {
                    customerDetailActivity.customerDetailBasicTableLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customer.setHeight(customerDetailActivity.height);
                    customerDetailActivity.afterCustomerDetailBirthdayDivideView.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailHeightRelativeLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailHeightText.setText(customerDetailActivity.height);
                }
                if (customerDetailActivity.weight != null && !(("").equals(customerDetailActivity.weight)) && Float.valueOf(customerDetailActivity.weight) != 0) {
                    customerDetailActivity.customerDetailBasicTableLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customer.setWeight(customerDetailActivity.weight);
                    customerDetailActivity.afterCustomerDetailHeightDivideView.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailWeightRelativeLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailWeightText.setText(customerDetailActivity.weight);
                }
                if (customerDetailActivity.bloodType != null && !(("").equals(customerDetailActivity.bloodType))) {
                    customerDetailActivity.customerDetailBasicTableLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customer.setBloodType(customerDetailActivity.bloodType);
                    customerDetailActivity.afterCustomerDetailWeightDivideView.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailBloodTypeRelativeLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailBloodTypeText.setText(customerDetailActivity.bloodType);
                }
                if (customerDetailActivity.marriage != null && !(("-1").equals(customerDetailActivity.marriage))) {
                    customerDetailActivity.customerDetailBasicTableLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customer.setMarriage(customerDetailActivity.marriage);
                    String marriageText = "";
                    if (("0").equals(customerDetailActivity.marriage)) {
                        marriageText = "未婚";
                    } else if (("1").equals(customerDetailActivity.marriage)) {
                        marriageText = "已婚";
                    }
                    customerDetailActivity.afterCustomerDetailBloodTypeDivideView.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailMarriageRelativeLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailMarriageText.setText(marriageText);
                }
                if (customerDetailActivity.profession != null && !(("").equals(customerDetailActivity.profession))) {
                    customerDetailActivity.customerDetailBasicTableLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customer.setProfession(customerDetailActivity.profession);
                    customerDetailActivity.afterCustomerDetailMarriageDivideView.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailProfessionRelativeLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customerDetailProfessionText.setText(customerDetailActivity.profession);
                }
                if (customerDetailActivity.remark != null && !(("").equals(customerDetailActivity.remark))) {
                    customerDetailActivity.customerDetailRemarkTableLayout.setVisibility(View.VISIBLE);
                    customerDetailActivity.customer.setRemark(customerDetailActivity.remark);
                    String remarkText = "";
                    if ("".equals(customerDetailActivity.remark))
                        remarkText = "无";
                    else
                        remarkText = customerDetailActivity.remark;
                    customerDetailActivity.customerDetailRemarkText.setText(remarkText);
                }
            } else if (message.what == 2)
                DialogUtil.createShortDialog(customerDetailActivity, "您的网络貌似不给力，请重试！");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerDetailActivity, customerDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerDetailActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerDetailActivity);
                customerDetailActivity.packageUpdateUtil = new PackageUpdateUtil(customerDetailActivity, customerDetailActivity.mHandler, fileCache, downloadFileUrl, false, customerDetailActivity.userinfoApplication);
                customerDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                customerDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = customerDetailActivity.getFileStreamPath(filename);
                file.getName();
                customerDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    // 初始化视图 向网络请求数据
    protected void initView() {
        customerDetailBasicTableLayout = (TableLayout) findViewById(R.id.customer_detail_basic_tablelayout);
        customerDetailRemarkTableLayout = (TableLayout) findViewById(R.id.customer_detail_remark_tablelayout);
        customerDetailBasicTableLayout.setVisibility(View.GONE);
        customerDetailRemarkTableLayout.setVisibility(View.GONE);
        customerDetailBirthdayRelativeLayout = (RelativeLayout) findViewById(R.id.customer_detail_birthday_relativelayout);
        customerDetailBirthdayText = (TextView) findViewById(R.id.customer_detail_birthday_text);
        afterCustomerDetailBirthdayDivideView = findViewById(R.id.after_customer_detail_birthday_divide_view);
        customerDetailHeightRelativeLayout = (RelativeLayout) findViewById(R.id.customer_detail_height_relativelayout);
        customerDetailHeightText = (TextView) findViewById(R.id.customer_detail_height_text);
        afterCustomerDetailHeightDivideView = findViewById(R.id.after_customer_detail_height_divide_view);
        customerDetailWeightRelativeLayout = (RelativeLayout) findViewById(R.id.customer_detail_weight_relativelayout);
        customerDetailWeightText = (TextView) findViewById(R.id.customer_detail_weight_text);
        afterCustomerDetailWeightDivideView = findViewById(R.id.after_customer_detail_weight_divide_view);
        customerDetailBloodTypeRelativeLayout = (RelativeLayout) findViewById(R.id.customer_detail_blood_type_relativelayout);
        customerDetailBloodTypeText = (TextView) findViewById(R.id.customer_detail_blood_text);
        afterCustomerDetailBloodTypeDivideView = findViewById(R.id.after_customer_detail_blood_divide_view);
        customerDetailMarriageRelativeLayout = (RelativeLayout) findViewById(R.id.customer_detail_marriage_relativelayout);
        customerDetailMarriageText = (TextView) findViewById(R.id.customer_detail_marriage_text);
        afterCustomerDetailMarriageDivideView = findViewById(R.id.after_cutomer_detail_marriage_divide_view);
        customerDetailProfessionRelativeLayout = (RelativeLayout) findViewById(R.id.customer_detail_profession_relativelayout);
        customerDetailProfessionText = (TextView) findViewById(R.id.customer_detail_profession_text);
        customerDetailRemarkText = (TextView) findViewById(R.id.customer_detail_remark_text);
        customerDetailEditBtn = (ImageButton) findViewById(R.id.customer_detail_edit_btn);
        int authAllCustomerContactInfoWrite = userinfoApplication.getAccountInfo().getAuthAllCustomerInfoWrite();
        if (authAllCustomerContactInfoWrite == 1 || userinfoApplication.getSelectedCustomerResponsiblePersonID() == userinfoApplication.getAccountInfo().getAccountId()) {
            customerDetailEditBtn.setVisibility(View.VISIBLE);
        } else {
            customerDetailEditBtn.setVisibility(View.GONE);
        }
        customerDetailEditBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                Intent destIntent = new Intent(CustomerDetailActivity.this, EditCustomerDetailActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("customerDetail", customer);
                destIntent.putExtras(bundle);
                startActivity(destIntent);
            }
        });
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getCustomerDetail";
                String endPoint = "customer";
                JSONObject customerDetailJsonParam = new JSONObject();
                int selectedCustomerID = userinfoApplication.getSelectedCustomerID();
                customer.setCustomerId(selectedCustomerID);
                try {
                    customerDetailJsonParam.put("CustomerID", selectedCustomerID);
                } catch (JSONException e) {

                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerDetailJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject customerDetailJsonObject = null;
                    try {
                        customerDetailJsonObject = new JSONObject(serverRequestResult);
                    } catch (JSONException e) {
                    }
                    JSONObject customerDetailJson = null;
                    try {
                        code = customerDetailJsonObject.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        try {
                            customerDetailJson = customerDetailJsonObject.getJSONObject("Data");
                            if (customerDetailJson.has("BirthDay") && !customerDetailJson.isNull("BirthDay"))
                                birthday = customerDetailJson.getString("BirthDay");
                            if (customerDetailJson.has("Height") && !customerDetailJson.isNull("Height"))
                                height = customerDetailJson.getString("Height");
                            if (customerDetailJson.has("Weight") && !customerDetailJson.isNull("Weight"))
                                weight = customerDetailJson.getString("Weight");
                            if (customerDetailJson.has("BloodType") && !customerDetailJson.isNull("BloodType"))
                                bloodType = customerDetailJson.getString("BloodType");
                            if (customerDetailJson.has("Marriage") && !customerDetailJson.isNull("Marriage"))
                                marriage = customerDetailJson.getString("Marriage");
                            if (customerDetailJson.has("Profession") && !customerDetailJson.isNull("Profession"))
                                profession = customerDetailJson.getString("Profession");
                            if (customerDetailJson.has("Remark") && !customerDetailJson.isNull("Remark"))
                                remark = customerDetailJson.getString("Remark");
                        } catch (JSONException e) {
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }

        };
        requestWebServiceThread.start();
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
}
