package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.Customer;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Timer;

/*
 * 编辑顾客详细信息
 * */
@SuppressLint({"NewApi", "ResourceType"})
public class EditCustomerDetailActivity extends BaseActivity implements OnClickListener {
    private EditCustomerDetailActivityHandler mHandler = new EditCustomerDetailActivityHandler(this);
    private Customer customer;
    private Button editCustomerDetailMakeSureBtn;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private EditText customerBirthdayEditText, customerHeightEditText, customerWeightEditText, customerProfessionEditText, customerRemarkEditText;
    private Spinner customerBloodSpinner, customerMarriageSpinner;
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_edit_customer_detail);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class EditCustomerDetailActivityHandler extends Handler {
        private final EditCustomerDetailActivity editCustomerDetailActivity;

        private EditCustomerDetailActivityHandler(EditCustomerDetailActivity activity) {
            WeakReference<EditCustomerDetailActivity> weakReference = new WeakReference<EditCustomerDetailActivity>(activity);
            editCustomerDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (editCustomerDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editCustomerDetailActivity.progressDialog != null) {
                editCustomerDetailActivity.progressDialog.dismiss();
                editCustomerDetailActivity.progressDialog = null;
            }
            if (editCustomerDetailActivity.requestWebServiceThread != null) {
                editCustomerDetailActivity.requestWebServiceThread.interrupt();
                editCustomerDetailActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(editCustomerDetailActivity, "提示信息", "顾客详细信息编辑成功！");
                alertDialog.show();
                Intent destIntent = new Intent(editCustomerDetailActivity, CustomerInfoActivity.class);
                destIntent.putExtra("current_tab", 1);
                editCustomerDetailActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editCustomerDetailActivity.dialogTimer, editCustomerDetailActivity, destIntent);
                editCustomerDetailActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 0) {
                DialogUtil.createMakeSureDialog(editCustomerDetailActivity, "提示信息", "编辑出错，请重试！");
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(editCustomerDetailActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editCustomerDetailActivity, editCustomerDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editCustomerDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editCustomerDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editCustomerDetailActivity);
                editCustomerDetailActivity.packageUpdateUtil = new PackageUpdateUtil(editCustomerDetailActivity, editCustomerDetailActivity.mHandler, fileCache, downloadFileUrl, false, editCustomerDetailActivity.userinfoApplication);
                editCustomerDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                editCustomerDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = editCustomerDetailActivity.getFileStreamPath(filename);
                file.getName();
                editCustomerDetailActivity.packageUpdateUtil.showInstallDialog();
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
        customerBirthdayEditText = (EditText) findViewById(R.id.customer_detail_birthday);
        customerHeightEditText = (EditText) findViewById(R.id.customer_detail_height);
        customerWeightEditText = (EditText) findViewById(R.id.customer_detail_weight);
        NumberFormatUtil.setPricePoint(customerHeightEditText, 1);
        NumberFormatUtil.setPricePoint(customerWeightEditText, 1);
        customerBloodSpinner = (Spinner) findViewById(R.id.customer_detail_blood);
        ArrayAdapter<String> bloodAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, new String[]{"未填", "A型", "B型", "AB型", "O型", "其他"});
        bloodAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        customerBloodSpinner.setAdapter(bloodAdapter);
        customerMarriageSpinner = (Spinner) findViewById(R.id.customer_detail_marriage);
        ArrayAdapter<String> marriageAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, new String[]{"未填", "未婚", "已婚"});
        marriageAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        customerMarriageSpinner.setAdapter(marriageAdapter);
        customerProfessionEditText = (EditText) findViewById(R.id.customer_detail_profession);
        customerRemarkEditText = (EditText) findViewById(R.id.customer_detail_remark);
        editCustomerDetailMakeSureBtn = (Button) findViewById(R.id.edit_customer_detail_make_sure_btn);
        editCustomerDetailMakeSureBtn.setOnClickListener(this);
        customer = (Customer) getIntent().getSerializableExtra("customerDetail");
        customerBirthdayEditText.setText(customer.getBirthday());
        customerHeightEditText.setText(customer.getHeight());
        customerWeightEditText.setText(customer.getWeight());
        String customerBlood = customer.getBloodType();
        int selectedCustomerBlood = 0;
        if (customerBlood != null && !(("").equals(customerBlood.trim()))) {
            if (customerBlood.equals("A型"))
                selectedCustomerBlood = 1;
            else if (customerBlood.equals("B型"))
                selectedCustomerBlood = 2;
            else if (customerBlood.equals("AB型"))
                selectedCustomerBlood = 3;
            else if (customerBlood.equals("O型"))
                selectedCustomerBlood = 4;
            else if (customerBlood.equals("其他"))
                selectedCustomerBlood = 5;
        }
        customerBloodSpinner.setSelection(selectedCustomerBlood);
        int customerMarriage = 0;
        try {
            customerMarriage = Integer.parseInt(customer.getMarriage()) + 1;
        } catch (NumberFormatException e) {
            customerMarriage = 0;
        }
        customerMarriageSpinner.setSelection(customerMarriage);
        customerProfessionEditText.setText(customer.getProfession());
        customerRemarkEditText.setText(customer.getRemark());
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
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.edit_customer_detail_make_sure_btn:
                String customerBirthday = customerBirthdayEditText.getText().toString().trim();
                if (customerBirthday != null && !"".equals(customerBirthday)) {
                    boolean convertSuccess = true;
                    String[] customerBirthdayArray = customerBirthday.split("-");
                    if (customerBirthdayArray.length < 3) {
                        customerBirthday = "2104-" + customerBirthday;
                    }
                    SimpleDateFormat simpleDateFormateYear = new SimpleDateFormat("yyyy-MM-dd");
                    try {
                        simpleDateFormateYear.setLenient(false);
                        simpleDateFormateYear.parse(customerBirthday);
                    } catch (Exception e) {
                        convertSuccess = false;
                    }
                    if (!convertSuccess)
                        DialogUtil.createShortDialog(this, "出生日期格式错误!");
                    else {
                        submitCustomerDetail(customerBirthday, convertSuccess);
                    }
                } else {
                    submitCustomerDetail(customerBirthday, true);
                }
                break;
        }
    }

    protected void submitCustomerDetail(final String customerBirthday, final boolean convertSuccess) {
        progressDialog = new ProgressDialog(EditCustomerDetailActivity.this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        final String customerHeight = customerHeightEditText.getText().toString();
        final String customerWeight = customerWeightEditText.getText().toString();
        final String customerBlood = customerBloodSpinner.getSelectedItem().toString();
        final int customerMarriage = customerMarriageSpinner.getSelectedItemPosition() - 1;
        final String customerProfession = customerProfessionEditText.getText().toString();
        final String customerRemark = customerRemarkEditText.getText().toString();
        // 与后台进行交互，更新客户的详细信息
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "updateCustomerDetail";
                String endPoint = "Customer";
                JSONObject updateCustomerDetailJson = new JSONObject();
                try {
                    updateCustomerDetailJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    if (customerHeight != null && !(("0.0").equals(customerHeight)))
                        updateCustomerDetailJson.put("Height", customerHeight);
                    if (customerWeight != null && !(("0.0").equals(customerWeight)))
                        updateCustomerDetailJson.put("Weight", customerWeight);
                    if (customerBlood != null && !(("未填").equals(customerBlood)))
                        updateCustomerDetailJson.put("BloodType", customerBlood);
                    else
                        updateCustomerDetailJson.put("BloodType", null);
                    if (customerBirthday != null && !(("").equals(customerBirthday)) && convertSuccess) {
                        updateCustomerDetailJson.put("Birthday", customerBirthday);
                    }
                    if (customerMarriage != -1)
                        updateCustomerDetailJson.put("Marriage", customerMarriage);
                    else
                        updateCustomerDetailJson.put("Marriage", null);
                    if (customerProfession != null && !(("").equals(customerProfession)))
                        updateCustomerDetailJson.put("Profession", customerProfession);
                    if (customerRemark != null && !(("").equals(customerRemark)))
                        updateCustomerDetailJson.put("Remark", customerRemark);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, updateCustomerDetailJson.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1)
                        mHandler.sendEmptyMessage(1);
                    else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else
                        mHandler.sendEmptyMessage(0);
                }
            }
        };
        requestWebServiceThread.start();
    }
}
