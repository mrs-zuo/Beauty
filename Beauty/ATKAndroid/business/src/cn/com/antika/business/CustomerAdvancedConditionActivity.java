package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CustomerAdvancedCondition;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.SourceType;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 顾客高级的搜索
 * */
@SuppressLint("ResourceType")
public class CustomerAdvancedConditionActivity extends BaseActivity implements OnClickListener {
    private CustomerAdvancedConditionActivityHandler mHandler = new CustomerAdvancedConditionActivityHandler(this);
    // 顾客，电话
    private RelativeLayout searchCustomerNameLayout, searchCustomerTelLayout;
    private EditText searchCustomerName, searchCustomerTel;
    private ImageButton backButton;
    private Spinner customerRegistFromSpinner, customerTypeConditionSpinner, ecardConditionSpinner, customerRegistDatSpinner, customerStatesSpinner;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private List<EcardInfo> ecardInfoList;
    private UserInfoApplication userinfoApplication;
    private View customerAdvancedResponsibleDivideView, firstVisitDateTimeview;
    private RelativeLayout customerAdvancedResponsibleRelativelayout, firstVisitDateTimeRelativelayout;
    private EditText customerAdvancedResponsibleText;
    private TextView firstVisitDateTimeText;
    private String accountIDs, firstVisitDateTime, firstVisitDateTimeDialog;
    private PackageUpdateUtil packageUpdateUtil;
    private SharedPreferences accountInfoSharePreferences;
    private Button customerAdvancedMakeSureButton, customerAdvancedSearchResetButton;
    private List<SourceType> sourceTypeList;
    private Spinner customerSourceTypeSpinner;
    private DatePickerDialog dialogFirstVisitDate;
    private StringBuffer strFirstVisitDate;
    private String firstVisitDateTimeYear, firstVisitDateTimeMonth, firstVisitDateTimeDay;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_advanced_condition);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class CustomerAdvancedConditionActivityHandler extends Handler {
        private final CustomerAdvancedConditionActivity customerAdvancedConditionActivity;

        private CustomerAdvancedConditionActivityHandler(CustomerAdvancedConditionActivity activity) {
            WeakReference<CustomerAdvancedConditionActivity> weakReference = new WeakReference<CustomerAdvancedConditionActivity>(activity);
            customerAdvancedConditionActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (customerAdvancedConditionActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerAdvancedConditionActivity.progressDialog != null) {
                customerAdvancedConditionActivity.progressDialog.dismiss();
                customerAdvancedConditionActivity.progressDialog = null;
            }
            if (customerAdvancedConditionActivity.requestWebServiceThread != null) {
                customerAdvancedConditionActivity.requestWebServiceThread.interrupt();
                customerAdvancedConditionActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                if (customerAdvancedConditionActivity.ecardInfoList.size() > 0) {
                    String[] customerEcardArray = new String[customerAdvancedConditionActivity.ecardInfoList.size()];
                    for (int i = 0; i < customerAdvancedConditionActivity.ecardInfoList.size(); i++) {
                        customerEcardArray[i] = customerAdvancedConditionActivity.ecardInfoList.get(i).getUserEcardName();
                    }
                    ArrayAdapter<String> ecardLevelNameAdapter = new ArrayAdapter<String>(customerAdvancedConditionActivity, R.xml.spinner_checked_text, customerEcardArray);
                    ecardLevelNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    customerAdvancedConditionActivity.ecardConditionSpinner.setAdapter(ecardLevelNameAdapter);
                    customerAdvancedConditionActivity.ecardConditionSpinner.setSelection(0);
                }
                customerAdvancedConditionActivity.getSourceTypeList();
            } else if (msg.what == 8) {
                // 顾客来源
                if (customerAdvancedConditionActivity.sourceTypeList.size() > 0) {
                    String[] sourceTypeNameArray = new String[customerAdvancedConditionActivity.sourceTypeList.size()];
                    for (int i = 0; i < customerAdvancedConditionActivity.sourceTypeList.size(); i++) {
                        sourceTypeNameArray[i] = customerAdvancedConditionActivity.sourceTypeList.get(i).getSourceTypeName();
                    }
                    ArrayAdapter<String> sourceTypeNameAdapter = new ArrayAdapter<String>(customerAdvancedConditionActivity, R.xml.spinner_checked_text, sourceTypeNameArray);
                    sourceTypeNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    customerAdvancedConditionActivity.customerSourceTypeSpinner.setAdapter(sourceTypeNameAdapter);
                    customerAdvancedConditionActivity.customerSourceTypeSpinner.setSelection(0);
                }
            } else if (msg.what == 3)
                DialogUtil.createShortDialog(customerAdvancedConditionActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == 6)
                DialogUtil.createShortDialog(customerAdvancedConditionActivity, (String) msg.obj);
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerAdvancedConditionActivity, customerAdvancedConditionActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerAdvancedConditionActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerAdvancedConditionActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerAdvancedConditionActivity);
                customerAdvancedConditionActivity.packageUpdateUtil = new PackageUpdateUtil(customerAdvancedConditionActivity, customerAdvancedConditionActivity.mHandler, fileCache, downloadFileUrl, false, customerAdvancedConditionActivity.userinfoApplication);
                customerAdvancedConditionActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerAdvancedConditionActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = customerAdvancedConditionActivity.getFileStreamPath(filename);
                file.getName();
                customerAdvancedConditionActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 99) {
                DialogUtil.createShortDialog(customerAdvancedConditionActivity, "服务器异常，请重试");
            }
        }
    }

    private void initView() {
        searchCustomerName = (EditText) findViewById(R.id.search_customer_name);
        searchCustomerTel = (EditText) findViewById(R.id.search_customer_tel);
        backButton = (ImageButton) findViewById(R.id.btn_main_back_menu);
        customerAdvancedMakeSureButton = (Button) findViewById(R.id.customer_advanced_search_make_sure_btn);
        customerAdvancedMakeSureButton.setOnClickListener(this);
        customerAdvancedSearchResetButton = (Button) findViewById(R.id.customer_advanced_search_reset_btn);
        customerAdvancedSearchResetButton.setOnClickListener(this);
        // 顾客来源
        sourceTypeList = new ArrayList<SourceType>();
        SourceType defaultSourceType = new SourceType();
        defaultSourceType.setSourceTypeID(-1);
        defaultSourceType.setSourceTypeName("全部");
        sourceTypeList.add(defaultSourceType);
        customerSourceTypeSpinner = (Spinner) findViewById(R.id.customer_source_spinner);
        String[] sourceTypeNameArray = new String[1];
        sourceTypeNameArray[0] = sourceTypeList.get(0).getSourceTypeName();
        ArrayAdapter<String> sourceTypeNameAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, sourceTypeNameArray);
        sourceTypeNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        customerSourceTypeSpinner.setAdapter(sourceTypeNameAdapter);
        customerSourceTypeSpinner.setSelection(0);
        // 注册时间
        customerRegistDatSpinner = (Spinner) findViewById(R.id.customer_regist_date_spinner);
        String[] customerRegistDateArray = new String[]{"全部", "当日", "自定义"};
        ArrayAdapter<String> customerRegistDatAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, customerRegistDateArray);
        customerRegistDatAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        customerRegistDatSpinner.setAdapter(customerRegistDatAdapter);
        customerRegistDatSpinner.setSelection(0);
        strFirstVisitDate = new StringBuffer("");
        customerRegistDatSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                // TODO Auto-generated method stub
                if (position == 2) {
                    firstVisitDateTimeview.setVisibility(View.VISIBLE);
                    firstVisitDateTimeRelativelayout.setVisibility(View.VISIBLE);
                } else {
                    firstVisitDateTimeview.setVisibility(View.GONE);
                    firstVisitDateTimeRelativelayout.setVisibility(View.GONE);
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> arg0) {
                // TODO Auto-generated method stub
            }
        });
        firstVisitDateTimeview = findViewById(R.id.first_visit_dateTime_view);
        firstVisitDateTimeRelativelayout = (RelativeLayout) findViewById(R.id.first_visit_dateTime_relativelayout);
        firstVisitDateTimeText = (TextView) findViewById(R.id.first_visit_dateTime_text);
        firstVisitDateTimeText.setOnClickListener(this);
        // 顾客状态
        customerStatesSpinner = (Spinner) findViewById(R.id.customer_states_spinner);
        String[] customerStatesArray = new String[]{"全部", "有效", "无效(一年以上未上门)"};
        ArrayAdapter<String> customerStatesAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, customerStatesArray);
        customerStatesAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        customerStatesSpinner.setAdapter(customerStatesAdapter);
        customerStatesSpinner.setSelection(0);
        backButton.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                CustomerAdvancedConditionActivity.this.finish();
            }
        });
        //注册方式
        customerRegistFromSpinner = (Spinner) findViewById(R.id.customer_regist_from_spinner);
        String[] customerRegitsFromArray = new String[]{"全部", "商家注册", "顾客导入", "自助注册(T站)"};
        ArrayAdapter<String> customerRegitsFromAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, customerRegitsFromArray);
        customerRegitsFromAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        customerRegistFromSpinner.setAdapter(customerRegitsFromAdapter);
        customerRegistFromSpinner.setSelection(0);
        customerTypeConditionSpinner = (Spinner) findViewById(R.id.customer_type_condition_spinner);
        // 顾客类型
        String[] customerTypeArray = null;
        int authAllCustomerRead = userinfoApplication.getAccountInfo().getAuthAllCustomerRead();
        if (authAllCustomerRead == 1)
            customerTypeArray = new String[]{"我的顾客", "门店顾客", "所有顾客"};
        else if (authAllCustomerRead == 0)
            customerTypeArray = new String[]{"我的顾客"};
        ArrayAdapter<String> customerTypeAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, customerTypeArray);
        customerTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        customerTypeConditionSpinner.setAdapter(customerTypeAdapter);
        int customerType = getIntent().getIntExtra("customerType", 0);
        // 所有顾客
        if (customerType == 1)
            customerTypeConditionSpinner.setSelection(2);
            // 门店顾客
        else if (customerType == 2)
            customerTypeConditionSpinner.setSelection(1);
        customerTypeConditionSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

                // TODO Auto-generated method stub
                if (position == 0) {
                    String customerTypeFileterStr = accountInfoSharePreferences.getString("CustomerTypeFilter", "");
                    StringBuilder customerTypeFileterID = new StringBuilder();
                    customerTypeFileterID.append(userinfoApplication.getAccountInfo().getCompanyId());
                    customerTypeFileterID.append("-");
                    customerTypeFileterID.append(userinfoApplication.getAccountInfo().getBranchId());
                    customerTypeFileterID.append("-");
                    customerTypeFileterID.append(userinfoApplication.getAccountInfo().getAccountId());
                    JSONObject customerFilterJson = null;
                    try {
                        customerFilterJson = new JSONObject(customerTypeFileterStr);
                    } catch (JSONException e) {
                    }
                    String accountNames = "";
                    try {
                        if (customerFilterJson != null) {
                            accountIDs = customerFilterJson.getString(customerTypeFileterID.toString() + "-accountIDs");
                            accountNames = customerFilterJson.getString(customerTypeFileterID.toString() + "-accountNames");
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    if (accountNames == null || "".equals(accountNames)) {
                        accountIDs = new JSONArray().put(userinfoApplication.getAccountInfo().getAccountId()).toString();
                        customerAdvancedResponsibleText.setText(userinfoApplication.getAccountInfo().getAccountName());
                    } else {
                        customerAdvancedResponsibleText.setText(accountNames);
                    }
                    customerAdvancedResponsibleDivideView.setVisibility(View.VISIBLE);
                    customerAdvancedResponsibleRelativelayout.setVisibility(View.VISIBLE);
                } else {
                    accountIDs = "[]";
                    customerAdvancedResponsibleText.setText("");
                    customerAdvancedResponsibleDivideView.setVisibility(View.GONE);
                    customerAdvancedResponsibleRelativelayout.setVisibility(View.GONE);
                }

                if (position == 2) {
                    // 所有顾客
                    searchCustomerNameLayout.setVisibility(View.VISIBLE);
                    searchCustomerTelLayout.setVisibility(View.VISIBLE);
                } else {
                    searchCustomerNameLayout.setVisibility(View.GONE);
                    searchCustomerTelLayout.setVisibility(View.GONE);
                }

            }

            @Override
            public void onNothingSelected(AdapterView<?> arg0) {
                // TODO Auto-generated method stub
            }
        });
        searchCustomerNameLayout = (RelativeLayout) findViewById(R.id.search_customer_name_layout);
        searchCustomerTelLayout = (RelativeLayout) findViewById(R.id.search_customer_tel_layout);
        ecardInfoList = new ArrayList<EcardInfo>();
        EcardInfo defaultEcardInfo = new EcardInfo();
        defaultEcardInfo.setUserEcardName("全部");
        defaultEcardInfo.setUserEcardCode("");
        ecardInfoList.add(defaultEcardInfo);
        ecardConditionSpinner = (Spinner) findViewById(R.id.ecard_condition_spinner);
        String[] customerEcardArray = new String[1];
        customerEcardArray[0] = ecardInfoList.get(0).getUserEcardName();
        ArrayAdapter<String> ecardLevelNameAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, customerEcardArray);
        ecardLevelNameAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        ecardConditionSpinner.setAdapter(ecardLevelNameAdapter);
        ecardConditionSpinner.setSelection(0);
        customerAdvancedResponsibleDivideView = findViewById(R.id.customer_advanced_responsible_person_divide_view);
        customerAdvancedResponsibleRelativelayout = (RelativeLayout) findViewById(R.id.customer_advanced_responsible_person_relativelayout);
        customerAdvancedResponsibleText = (EditText) findViewById(R.id.customer_advanced_responsible_person_edit_text);
        customerAdvancedResponsibleText.setInputType(InputType.TYPE_NULL);
        customerAdvancedResponsibleText.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                Intent intent = new Intent(CustomerAdvancedConditionActivity.this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Doctor");
                intent.putExtra("checkModel", "Multi");
                intent.putExtra("selectPersonIDs", accountIDs);
                intent.putExtra("getSubAccount", true);
                intent.putExtra("getCustomerResponsiblePerson", true);
                startActivityForResult(intent, 400);
            }
        });
        if (accountInfoSharePreferences == null)
            accountInfoSharePreferences = getSharedPreferences("GlmourPromiseCustomerTypeFilter", MODE_PRIVATE);
        String customerTypeFileterStr = accountInfoSharePreferences.getString("CustomerTypeFilter", "");
        int registFrom = -1;
        String cardCode = "";
        int sourceTypeID = -1;
        int firstVisitType = 0;
        int customerStates = 0;
        if (customerTypeFileterStr != null && !("").equals(customerTypeFileterStr)) {
            StringBuilder customerTypeFileterID = new StringBuilder();
            customerTypeFileterID.append(userinfoApplication.getAccountInfo().getCompanyId());
            customerTypeFileterID.append("-");
            customerTypeFileterID.append(userinfoApplication.getAccountInfo().getBranchId());
            customerTypeFileterID.append("-");
            customerTypeFileterID.append(userinfoApplication.getAccountInfo().getAccountId());
            JSONObject customerFilterJson = null;
            try {
                customerFilterJson = new JSONObject(customerTypeFileterStr);
            } catch (JSONException e) {
            }

            String accountNames = "";
            try {
                accountIDs = customerFilterJson.getString(customerTypeFileterID.toString() + "-accountIDs");
                accountNames = customerFilterJson.getString(customerTypeFileterID.toString() + "-accountNames");
                cardCode = customerFilterJson.getString(customerTypeFileterID.toString() + "-cardCode");
                registFrom = customerFilterJson.getInt(customerTypeFileterID.toString() + "-registFrom");
                sourceTypeID = customerFilterJson.getInt(customerTypeFileterID.toString() + "-sourceType");
                firstVisitType = customerFilterJson.getInt(customerTypeFileterID.toString() + "-FirstVisitType");
                customerStates = customerFilterJson.getInt(customerTypeFileterID.toString() + "-EffectiveCustomerType");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            if (accountNames == null || ("").equals(accountNames)) {
                //将当前筛选的专属顾问默认为当前登录账号
                accountIDs = new JSONArray().put(userinfoApplication.getAccountInfo().getAccountId()).toString();
                customerAdvancedResponsibleText.setText(userinfoApplication.getAccountInfo().getAccountName());
            } else
                customerAdvancedResponsibleText.setText(accountNames);
        }
        requestEcardList();
    }

    private void requestEcardList() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetBranchCardList";
                String endPoint = "ECard";
                JSONObject getEcardListJsonParam = new JSONObject();
                try {
                    getEcardListJsonParam.put("isOnlyMoneyCard", true);
                    getEcardListJsonParam.put("isShowAll", true);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getEcardListJsonParam.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
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
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        JSONArray ecardJsonArray = null;
                        try {
                            ecardJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (ecardJsonArray != null) {
                            for (int i = 0; i < ecardJsonArray.length(); i++) {
                                JSONObject ecardJson = null;
                                try {
                                    ecardJson = (JSONObject) ecardJsonArray.get(i);
                                } catch (JSONException e1) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                String cardCode = "";
                                String userEcardName = "";
                                try {
                                    if (ecardJson.has("CardCode") && !ecardJson.isNull("CardCode"))
                                        cardCode = ecardJson.getString("CardCode");
                                    if (ecardJson.has("CardName") && !ecardJson.isNull("CardName"))
                                        userEcardName = ecardJson.getString("CardName");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                EcardInfo customerEcardInfo = new EcardInfo();
                                customerEcardInfo.setUserEcardCode(cardCode);
                                customerEcardInfo.setUserEcardName(userEcardName);
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

    protected void getSourceTypeList() {
        progressDialog = ProgressDialogUtil.createProgressDialog(this);
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetCustomerSourceType";
                String endPoint = "customer";
                JSONObject getSourceTypeJsonParam = new JSONObject();
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getSourceTypeJsonParam.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        JSONArray customerSourceTypeJsonArray = null;
                        try {
                            customerSourceTypeJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (customerSourceTypeJsonArray != null) {
                            for (int i = 0; i < customerSourceTypeJsonArray.length(); i++) {
                                JSONObject sourceTypeJson = null;
                                try {
                                    sourceTypeJson = customerSourceTypeJsonArray.getJSONObject(i);
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                int sourceTypeID = 0;
                                String sourceTypeName = "";
                                try {
                                    if (sourceTypeJson.has("ID") && !sourceTypeJson.isNull("ID"))
                                        sourceTypeID = sourceTypeJson.getInt("ID");
                                    if (sourceTypeJson.has("Name") && !sourceTypeJson.isNull("Name"))
                                        sourceTypeName = sourceTypeJson.getString("Name");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                SourceType customerSourceType = new SourceType();
                                customerSourceType.setSourceTypeID(sourceTypeID);
                                customerSourceType.setSourceTypeName(sourceTypeName);
                                sourceTypeList.add(customerSourceType);
                            }
                        }
                        mHandler.sendEmptyMessage(8);
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
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            this.finish();
        }
        return super.onKeyUp(keyCode, event);
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
        System.gc();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        // 选择美丽顾问成功返回
        if (resultCode == RESULT_OK) {
            String newResponsiblePersonIDs = data.getStringExtra("personId");
            String personName = data.getStringExtra("personName");
            if (newResponsiblePersonIDs != null && !("").equals(newResponsiblePersonIDs))
                customerTypeConditionSpinner.setSelection(0);
            accountIDs = newResponsiblePersonIDs;
            customerAdvancedResponsibleText.setText(personName);
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        // 点击确定查询的按钮
        switch (view.getId()) {
            case R.id.customer_advanced_search_make_sure_btn:
                int registFrom = -1;
                int customerType = 0;
                int customerRegistFromSelectedPosition = customerRegistFromSpinner.getSelectedItemPosition();
                int customerTypeSelectedPosition = customerTypeConditionSpinner.getSelectedItemPosition();
                if (customerRegistFromSelectedPosition == 1)
                    registFrom = 0;
                else if (customerRegistFromSelectedPosition == 2)
                    registFrom = 1;
                else if (customerRegistFromSelectedPosition == 3)
                    registFrom = 2;
                // 我的顾客
                if (customerTypeSelectedPosition == 0)
                    customerType = 0;
                // 门店顾客
                if (customerTypeSelectedPosition == 1)
                    customerType = 2;
                // 所有顾客
                if (customerTypeSelectedPosition == 2)
                    customerType = 1;
                // 闪退对应（ecard未选中的情况）
                if (ecardConditionSpinner.getSelectedItemPosition() == -1) {
                    if (ecardConditionSpinner.getAdapter() != null && ecardConditionSpinner.getAdapter().getCount() > 0) {
                        ecardConditionSpinner.setSelection(0);
                    }
                }
                // 闪退对应（SourceType未选中的情况）
                if (customerSourceTypeSpinner.getSelectedItemPosition() == -1) {
                    if (customerSourceTypeSpinner.getAdapter() != null && customerSourceTypeSpinner.getAdapter().getCount() > 0) {
                        customerSourceTypeSpinner.setSelection(0);
                    }
                }
                String cardCode = null;
                int sourceTypeID = 0;
                if (ecardConditionSpinner.getSelectedItemPosition() != -1) {
                    cardCode = ecardInfoList.get(ecardConditionSpinner.getSelectedItemPosition()).getUserEcardCode();
                }
                if (customerSourceTypeSpinner.getSelectedItemPosition() != -1) {
                    sourceTypeID = sourceTypeList.get(customerSourceTypeSpinner.getSelectedItemPosition()).getSourceTypeID();
                }
                //顾客状态
                int effectiveCustomerType = 0;
                int customerStatesSelectedPosition = customerStatesSpinner.getSelectedItemPosition();
                if (customerStatesSelectedPosition == 1)
                    effectiveCustomerType = 1;
                if (customerStatesSelectedPosition == 2)
                    effectiveCustomerType = 2;
                //注册时间
                int firstVisitType = 0;
                firstVisitDateTime = "";
                int firstVisitTypeSelectedPosition = customerRegistDatSpinner.getSelectedItemPosition();
                if (firstVisitTypeSelectedPosition == 1)
                    firstVisitType = 1;
                if (firstVisitTypeSelectedPosition == 2) {
                    firstVisitType = 2;
                    firstVisitDateTime = firstVisitDateTimeDialog;
                }
                CustomerAdvancedCondition customerAdvancedCondition = new CustomerAdvancedCondition();
                Intent data = new Intent();
                String customerName = searchCustomerName.getText().toString().trim();
                // 顾客姓名
                if (!TextUtils.isEmpty(customerName)) {
                    customerAdvancedCondition.setCustomerName(customerName);
                }
                // 顾客电话
                String customerTel = searchCustomerTel.getText().toString().trim();
                if (!TextUtils.isEmpty(customerTel)) {
                    customerAdvancedCondition.setCustomerTel(customerTel);
                }
                customerAdvancedCondition.setCustomerType(customerType);
                customerAdvancedCondition.setCardCode(cardCode);
                customerAdvancedCondition.setAccountIDs(accountIDs);
                customerAdvancedCondition.setRegistFrom(registFrom);
                customerAdvancedCondition.setSourceTypeID(sourceTypeID);
                customerAdvancedCondition.setEffectiveCustomerType(effectiveCustomerType);
                customerAdvancedCondition.setFirstVisitType(firstVisitType);
                boolean isCondition = true;
                //按时间筛选,时间必须满足的条件
                if (firstVisitTypeSelectedPosition == 2) {
                    if (firstVisitDateTime == null) {
                        DialogUtil.createShortDialog(this, "自定义日期不能为空！");
                        isCondition = false;
                    } else {
                        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        Date date = new Date(System.currentTimeMillis());
                        String systemdate = simpleDateFormat.format(date);
                        Date dt1 = null;
                        Date dt2 = null;
                        try {
                            dt1 = simpleDateFormat.parse(firstVisitDateTime);
                            dt2 = simpleDateFormat.parse(systemdate);
                        } catch (ParseException e) {
                            e.printStackTrace();
                        }
                        if (dt1.getTime() > dt2.getTime()) {
                            DialogUtil.createShortDialog(this, "自定义日期不能大于当日！");
                            isCondition = false;
                        } else {
                            customerAdvancedCondition.setFirstVisitDateTime(firstVisitDateTime);
                        }
                    }
                } else {
                    customerAdvancedCondition.setFirstVisitDateTime(firstVisitDateTime);
                }
                if (isCondition) {
                    setCustomerTypeFilter(customerAdvancedCondition);
                    data.putExtra("customerAdvancedCondition", customerAdvancedCondition);
                    setResult(100, data);
                    this.finish();
                }
                break;
            case R.id.customer_advanced_search_reset_btn:
                if (customerRegistFromSpinner.getAdapter() != null && customerRegistFromSpinner.getAdapter().getCount() > 0) {
                    customerRegistFromSpinner.setSelection(0);
                }
                if (customerSourceTypeSpinner.getAdapter() != null && customerSourceTypeSpinner.getAdapter().getCount() > 0) {
                    customerSourceTypeSpinner.setSelection(0);
                }
                // 顾客类型
                if (customerTypeConditionSpinner.getAdapter() != null) {
                    if (customerTypeConditionSpinner.getAdapter().getCount() > 1) {
                        customerTypeConditionSpinner.setSelection(1);
                    } else if (customerTypeConditionSpinner.getAdapter().getCount() > 0) {
                        customerTypeConditionSpinner.setSelection(0);
                    }
                }
                if (ecardConditionSpinner.getAdapter() != null && ecardConditionSpinner.getAdapter().getCount() > 0) {
                    ecardConditionSpinner.setSelection(0);
                }
                if (customerStatesSpinner.getAdapter() != null && customerStatesSpinner.getAdapter().getCount() > 0) {
                    customerStatesSpinner.setSelection(0);
                }
                if (customerRegistDatSpinner.getAdapter() != null && customerRegistDatSpinner.getAdapter().getCount() > 0) {
                    customerRegistDatSpinner.setSelection(0);
                }
                accountIDs = new JSONArray().put(userinfoApplication.getAccountInfo().getAccountId()).toString();
                //customerAdvancedResponsibleText.setText("");
                searchCustomerName.setText("");
                searchCustomerTel.setText("");
                break;
            case R.id.first_visit_dateTime_text:
                showfirstVisitDateDialog();
                break;
        }
    }

    //保存顾客高级筛选条件
    private void setCustomerTypeFilter(CustomerAdvancedCondition cav) {
        if (accountInfoSharePreferences == null)
            accountInfoSharePreferences = getSharedPreferences("GlmourPromiseCustomerTypeFilter", MODE_PRIVATE);
        String customerTypeFileterStr = accountInfoSharePreferences.getString("CustomerTypeFilter", "");
        JSONObject customerTypeFileterJson = null;
        if (customerTypeFileterStr.equals("")) {
            customerTypeFileterJson = new JSONObject();
        } else {
            try {
                customerTypeFileterJson = new JSONObject(customerTypeFileterStr);
            } catch (JSONException e) {
                customerTypeFileterJson = new JSONObject();
            }
        }
        StringBuilder customerTypeFileterID = new StringBuilder();
        customerTypeFileterID.append(userinfoApplication.getAccountInfo().getCompanyId());
        customerTypeFileterID.append("-");
        customerTypeFileterID.append(userinfoApplication.getAccountInfo().getBranchId());
        customerTypeFileterID.append("-");
        customerTypeFileterID.append(userinfoApplication.getAccountInfo().getAccountId());
        try {
            customerTypeFileterJson.put(customerTypeFileterID.toString(), cav.getCustomerType());
            customerTypeFileterJson.put(customerTypeFileterID.toString() + "-cardCode", cav.getCardCode());
            customerTypeFileterJson.put(customerTypeFileterID.toString() + "-registFrom", cav.getRegistFrom());
            customerTypeFileterJson.put(customerTypeFileterID.toString() + "-sourceType", cav.getSourceTypeID());
            customerTypeFileterJson.put(customerTypeFileterID.toString() + "-accountNames", customerAdvancedResponsibleText.getText().toString());
            customerTypeFileterJson.put(customerTypeFileterID.toString() + "-EffectiveCustomerType", cav.getEffectiveCustomerType());
            customerTypeFileterJson.put(customerTypeFileterID.toString() + "-FirstVisitType", cav.getFirstVisitType());
            customerTypeFileterJson.put(customerTypeFileterID.toString() + "-FirstVisitDateTime", cav.getFirstVisitDateTime());
            if (cav.getAccountIDs() != null)
                customerTypeFileterJson.put(customerTypeFileterID.toString() + "-accountIDs", new JSONArray(cav.getAccountIDs()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        accountInfoSharePreferences.edit().putString("CustomerTypeFilter", customerTypeFileterJson.toString()).commit();
    }

    private void showfirstVisitDateDialog() {
        Calendar calendarStart = Calendar.getInstance();
        firstVisitDateTimeDialog = null;
        if (dialogFirstVisitDate == null) {
            dialogFirstVisitDate = new DatePickerDialog(this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                @Override
                public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                    strFirstVisitDate.replace(0, strFirstVisitDate.length(), "");
                    strFirstVisitDate.append(year);
                    strFirstVisitDate.append("年");
                    strFirstVisitDate.append(monthOfYear + 1);
                    strFirstVisitDate.append("月");
                    strFirstVisitDate.append(dayOfMonth);
                    strFirstVisitDate.append("日");
                    firstVisitDateTimeYear = String.valueOf(year);
                    firstVisitDateTimeMonth = String.format("%02d", monthOfYear + 1);
                    firstVisitDateTimeDay = String.format("%02d", dayOfMonth);
                    firstVisitDateTimeText.setText(strFirstVisitDate.toString());
                    firstVisitDateTimeDialog = firstVisitDateTimeYear + "-" + firstVisitDateTimeMonth + "-" + firstVisitDateTimeDay;
                }
            }, calendarStart.get(Calendar.YEAR),
                    calendarStart.get(Calendar.MONTH),
                    calendarStart.get(Calendar.DAY_OF_MONTH));
        }
        dialogFirstVisitDate.show();
    }

}
