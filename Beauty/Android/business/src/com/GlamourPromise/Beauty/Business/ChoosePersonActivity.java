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
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.SearchView;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.adapter.ChoosePersonListAdapter;
import com.GlamourPromise.Beauty.adapter.LabelListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.Customer;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.LabelInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.GetTagListTaskImpl;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.EmployeeComparator;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil.AdvancedFilterFlag;
import com.GlamourPromise.Beauty.view.RefreshListView;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

@SuppressLint("ResourceType")
public class ChoosePersonActivity extends BaseActivity implements OnClickListener, OnQueryTextListener, OnCheckedChangeListener {
    private ChoosePersonActivityHandler mHandler = new ChoosePersonActivityHandler(this);
    private SearchView choosePersonSearchView;
    private ImageButton searchBtn;
    private ImageButton filterBtn;
    private RefreshListView choosePersonListView;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private List<Customer> personList;
    private Button chooseMakeSureBtn;
    private String personRole = "";
    private String checkModel = "";
    private PopupWindow popupWindow;
    private ImageButton selectAllPersonCheckbox;
    private ChoosePersonListAdapter choosePersonListAdapter;
    private String messageType = "";
    private int screenWidth;
    private UserInfoApplication userinfoApplication;
    private boolean isSelectAll;
    private int checkMode;// 0:单选 1：多选
    private TextView choosePersonTitleText;
    //mustSelectOne是否必须选择一个
    private boolean getSubAccount, mustSelectOne = false;
    private ImageButton backButton, groupFilterBtn;
    private PackageUpdateUtil packageUpdateUtil;
    private String selectPersonIDs;
    private Dialog groupFilterDialog;
    private GetBackendServerDataByJsonThread getDataThread;
    private GetTagListTaskImpl getTagListTask;
    private ArrayList<Integer> lastSelectGroup;
    private int customerID;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_choose_person);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class ChoosePersonActivityHandler extends Handler {
        private final ChoosePersonActivity choosePersonActivity;

        private ChoosePersonActivityHandler(ChoosePersonActivity activity) {
            WeakReference<ChoosePersonActivity> weakReference = new WeakReference<ChoosePersonActivity>(activity);
            choosePersonActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (choosePersonActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (choosePersonActivity.progressDialog != null) {
                choosePersonActivity.progressDialog.dismiss();
                choosePersonActivity.progressDialog = null;
            }
            if (choosePersonActivity.requestWebServiceThread != null) {
                choosePersonActivity.requestWebServiceThread.interrupt();
                choosePersonActivity.requestWebServiceThread = null;
            }
            if (choosePersonActivity.getDataThread != null) {
                choosePersonActivity.getDataThread.interrupt();
                choosePersonActivity.getDataThread = null;
            }
            if (message.what == 1) {
                JSONArray selectPersonArray = null;
                try {
                    if (choosePersonActivity.selectPersonIDs != null && !(("").equals(choosePersonActivity.selectPersonIDs)))
                        selectPersonArray = new JSONArray(choosePersonActivity.selectPersonIDs);
                } catch (JSONException e) {
                }
                //对选择的账户进行排序
                if (selectPersonArray != null && selectPersonArray.length() > 0) {
                    for (int j = 0; j < choosePersonActivity.personList.size(); j++) {
                        for (int i = 0; i < selectPersonArray.length(); i++) {
                            int selectPersonID = 0;
                            try {
                                selectPersonID = selectPersonArray.getInt(i);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            if (selectPersonID == choosePersonActivity.personList.get(j).getCustomerId())
                                choosePersonActivity.personList.get(j).setIsSelected(1);

                        }
                    }
                    Collections.sort(choosePersonActivity.personList, new EmployeeComparator());
                }
                choosePersonActivity.choosePersonListAdapter = new ChoosePersonListAdapter(choosePersonActivity, choosePersonActivity.personList, choosePersonActivity.checkMode, choosePersonActivity.selectPersonIDs);
                choosePersonActivity.choosePersonListView.setAdapter(choosePersonActivity.choosePersonListAdapter);
            } else if (message.what == 2)
                DialogUtil.createShortDialog(choosePersonActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(choosePersonActivity, choosePersonActivity.getString(R.string.login_error_message));
                choosePersonActivity.userinfoApplication.exitForLogin(choosePersonActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + choosePersonActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(choosePersonActivity);
                choosePersonActivity.packageUpdateUtil = new PackageUpdateUtil(choosePersonActivity, choosePersonActivity.mHandler, fileCache, downloadFileUrl, false, choosePersonActivity.userinfoApplication);
                choosePersonActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                choosePersonActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //获得分组列表并显示选择分组列表对话框
            else if (message.what == 6) {
                ArrayList<LabelInfo> labelList = (ArrayList<LabelInfo>) message.obj;
                LayoutInflater inflater = choosePersonActivity.getLayoutInflater();
                View groupFilterDialogLayout = inflater.inflate(R.xml.group_filter_dialog, null);
                ListView groupListView = (ListView) groupFilterDialogLayout.findViewById(R.id.group_listview);
                String lastSelectString = choosePersonActivity.getConditionFromSharePre();
                if (lastSelectString != null && !"".equals(lastSelectString)) {
                    choosePersonActivity.lastSelectGroup = new ArrayList<Integer>();
                    String[] lastSelectGroups = lastSelectString.split("\\|");
                    for (int i = 0; i < lastSelectGroups.length; i++) {
                        if (lastSelectGroups[i] != null && !"".equals(lastSelectGroups[i]))
                            choosePersonActivity.lastSelectGroup.add(Integer.parseInt(lastSelectGroups[i]));
                    }
                }
                final LabelListAdapter labellistAdapter = new LabelListAdapter(choosePersonActivity, labelList, choosePersonActivity.lastSelectGroup, 10);
                groupListView.setAdapter(labellistAdapter);
                choosePersonActivity.groupFilterDialog = new AlertDialog.Builder(choosePersonActivity, R.style.CustomerAlertDialog).setTitle(choosePersonActivity.getString(R.string.group_filter))
                        .setView(groupListView).setPositiveButton(choosePersonActivity.getString(R.string.confirm),
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface arg0, int arg1) {
                                        HashMap<Integer, LabelInfo> selectLabelInfoHashMap = labellistAdapter.getSelectLabelHashMap();
                                        StringBuffer selectLabelStr = new StringBuffer();
                                        for (int i = 0; i < selectLabelInfoHashMap.size(); i++) {
                                            LabelInfo labelInfo = selectLabelInfoHashMap.get(i);
                                            selectLabelStr.append("|" + labelInfo.getID() + "|");
                                        }
                                        choosePersonActivity.personList = new ArrayList<Customer>();
                                        //请求分组筛选的员工列表
                                        choosePersonActivity.createDoctorThread(selectLabelStr.toString());
                                        choosePersonActivity.saveConditionToSharePre(selectLabelStr.toString());
                                        choosePersonActivity.requestWebServiceThread.start();
                                    }
                                })
                        .setNegativeButton(choosePersonActivity.getString(R.string.cancel), new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).setNeutralButton("清除", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                if (choosePersonActivity.lastSelectGroup != null && choosePersonActivity.lastSelectGroup.size() > 0)
                                    choosePersonActivity.lastSelectGroup.clear();
                                choosePersonActivity.saveConditionToSharePre("");
                                choosePersonActivity.createDoctorThread("");
                                choosePersonActivity.requestWebServiceThread.start();
                                //labellistAdapter.notifyDataSetChanged();
                            }
                        }).create();
                choosePersonActivity.groupFilterDialog.setCancelable(false);
                choosePersonActivity.groupFilterDialog.show();
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = choosePersonActivity.getFileStreamPath(filename);
                file.getName();
                choosePersonActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    //将筛选分组条件记忆在本地文件
    private void saveConditionToSharePre(String tagIDs) {
        // TODO Auto-generated method stub
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.BusinessGroupFlag);
        sharePreUtil.putAdvancedFilter(key, tagIDs);
    }

    private String getConditionFromSharePre() {
        String tagIDs = "";
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.BusinessGroupFlag);
        tagIDs = sharePreUtil.getValue(key);
        return tagIDs;
    }

    protected void initView() {
        choosePersonTitleText = (TextView) findViewById(R.id.choose_person_text);
        choosePersonSearchView = (SearchView) findViewById(R.id.choose_person_search);
        choosePersonSearchView.setOnQueryTextListener(this);
        choosePersonSearchView.setVisibility(View.GONE);
        selectAllPersonCheckbox = (ImageButton) findViewById(R.id.select_all_person_checkbox);
        selectAllPersonCheckbox.setVisibility(View.GONE);
        selectAllPersonCheckbox.setOnClickListener(this);
        searchBtn = (ImageButton) findViewById(R.id.search_btn);
        searchBtn.setOnClickListener(this);
        filterBtn = (ImageButton) findViewById(R.id.filter_btn);
        filterBtn.setOnClickListener(this);
        chooseMakeSureBtn = (Button) findViewById(R.id.choose_make_sure_btn);
        chooseMakeSureBtn.setOnClickListener(this);
        groupFilterBtn = (ImageButton) findViewById(R.id.group_filter_btn);
        groupFilterBtn.setOnClickListener(this);
        isSelectAll = false;
        choosePersonListView = (RefreshListView) findViewById(R.id.choose_person_list_view);
        personList = new ArrayList<Customer>();
        backButton = (ImageButton) findViewById(R.id.btn_main_back_menu);
        backButton.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View arg0) {
                ChoosePersonActivity.this.finish();
            }
        });
        screenWidth = userinfoApplication.getScreenWidth();
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        Intent intent = getIntent();
        Bundle bundle = intent.getExtras();
        personRole = bundle.getString("personRole");
        checkModel = bundle.getString("checkModel");
        messageType = bundle.getString("messageType");
        mustSelectOne = bundle.getBoolean("mustSelectOne");
        selectPersonIDs = bundle.getString("selectPersonIDs");
        //是否列出当前账号的下级
        getSubAccount = intent.getBooleanExtra("getSubAccount", false);
        if (personRole == null) {
            return;
        }
        if (("Doctor").equals(personRole)) {
            if (null == checkModel) {
                return;
            }
            filterBtn.setVisibility(View.GONE);
            createDoctorThread(getConditionFromSharePre());
            if (("Single").equals(checkModel)) {
                boolean setSales = intent.getBooleanExtra("setSales", false);
                boolean getCustomerResponsible = intent.getBooleanExtra("getCustomerResponsiblePerson", false);
                //选择销售顾问
                if (setSales)
                    choosePersonTitleText.setText("选择顾问");
                else if (getCustomerResponsible)
                    choosePersonTitleText.setText("选择顾问");
                else
                    choosePersonTitleText.setText("选择顾问");
                checkMode = 0;
            } else if (("Multi").equals(checkModel)) {
                boolean setBenefitPerson = intent.getBooleanExtra("setBenefitPerson", false);
                boolean getCustomerResponsible = intent.getBooleanExtra("getCustomerResponsiblePerson", false);
                if (setBenefitPerson)
                    choosePersonTitleText.setText("选择业绩参与者");
                else if (getCustomerResponsible)
                    choosePersonTitleText.setText("选择顾问");
                else
                    choosePersonTitleText.setText("选择顾问");
                checkMode = 1;
                selectAllPersonCheckbox.setVisibility(View.VISIBLE);
            }
        } else if (("Customer").equals(personRole) && null != checkModel && ("Multi").equals(checkModel)) {
            groupFilterBtn.setVisibility(View.GONE);
            filterBtn.setVisibility(View.VISIBLE);
            choosePersonTitleText.setText("选择顾客");
            if (messageType.equals("OrderFilter"))
                checkMode = 0;
            else {
                checkMode = 1;
                selectAllPersonCheckbox.setVisibility(View.VISIBLE);
            }
            createCustomerThread();
        }

        requestWebServiceThread.start();
    }

    private void createCustomerThread() {
        if (personList == null)
            personList = new ArrayList<Customer>();
        else
            personList.clear();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "getCustomerList";
                String endPoint = "Customer";
                JSONObject customerListJsonParam = new JSONObject();
                try {
                    customerListJsonParam.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                    customerListJsonParam.put("CompanyID", userinfoApplication.getAccountInfo().getCompanyId());
                    customerListJsonParam.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                    customerListJsonParam.put("ObjectType", 0);
                    customerListJsonParam.put("LevelID", "");
                    customerListJsonParam.put("RegistFrom", -1);
                    customerListJsonParam.put("SourceType", -1);
                    if (screenWidth == 720) {
                        customerListJsonParam.put("ImageWidth", "100");
                        customerListJsonParam.put("ImageHeight", "100");
                    } else if (screenWidth == 480 || screenWidth == 540) {
                        customerListJsonParam.put("ImageWidth", "60");
                        customerListJsonParam.put("ImageHeight", "60");
                    } else if (screenWidth == 1536) {
                        customerListJsonParam.put("ImageWidth", "180");
                        customerListJsonParam.put("ImageHeight", "180");
                    }
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerListJsonParam.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
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
                    }
                    if (code == 1) {
                        JSONArray customerListJsonArray = null;
                        try {
                            customerListJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        parseWebserviceResultForCustomer(customerListJsonArray);
                        mHandler.sendEmptyMessage(1);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        mHandler.sendEmptyMessage(2);
                    }
                }
            }
        };
    }

    private void createDoctorThread(final String tagIDs) {
        customerID = getIntent().getIntExtra("customerID", 0);
        if (personList == null)
            personList = new ArrayList<Customer>();
        else
            personList.clear();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getAccountList";
                String endPoint = "account";
                JSONObject getAccountListJsonParam = new JSONObject();
                try {
                    if (getSubAccount)
                        getAccountListJsonParam.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                    else if (!getSubAccount)
                        getAccountListJsonParam.put("AccountID", 0);
                    if (customerID != 0)
                        getAccountListJsonParam.put("CustomerID", customerID);
                    if (screenWidth == 720) {
                        getAccountListJsonParam.put("ImageWidth", "100");
                        getAccountListJsonParam.put("ImageHeight", "100");
                    } else if (screenWidth == 480 || screenWidth == 540) {
                        getAccountListJsonParam.put("ImageWidth", "60");
                        getAccountListJsonParam.put("ImageHeight", "60");
                    } else if (screenWidth == 1536) {
                        getAccountListJsonParam.put("ImageWidth", "180");
                        getAccountListJsonParam.put("ImageHeight", "180");
                    }
                    getAccountListJsonParam.put("TagIDs", tagIDs);
                } catch (JSONException e) {

                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getAccountListJsonParam.toString(), userinfoApplication);
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
                    JSONArray docotorArray = null;
                    if (code == 1) {
                        try {
                            docotorArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        parseWebserviceResultForDoctor(docotorArray);
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
    }

    private void showPopupWindow() {
        View view = null;
        Button myPersonBtn = null;
        Button allPersonBtn = null;
        Button cancelBtn = null;
        if (null != personRole && ("Doctor").equals(personRole) && null != checkModel && ("Single").equals(checkModel)) {
            view = (LinearLayout) LayoutInflater.from(this).inflate(R.xml.doctor_popup_menu, null);
            myPersonBtn = (Button) view.findViewById(R.id.my_doctor_btn);
            allPersonBtn = (Button) view.findViewById(R.id.all_doctor_btn);
            cancelBtn = (Button) view.findViewById(R.id.cancel_btn);
            myPersonBtn.setOnClickListener(this);
            allPersonBtn.setOnClickListener(this);
            cancelBtn.setOnClickListener(this);
        } else if (null != personRole && ("Customer").equals(personRole) && null != checkModel && ("Multi").equals(checkModel)) {
            view = (LinearLayout) LayoutInflater.from(this).inflate(R.xml.filter_person_popup_menu, null);
            Button myCustomerBtn = (Button) view.findViewById(R.id.my_customer_btn);
            Button branchCustomerBtn = (Button) view.findViewById(R.id.branch_customer_btn);
            Button allCustomerBtn = (Button) view.findViewById(R.id.all_customer_btn);
            Button cancelCustomerBtn = (Button) view.findViewById(R.id.cancel_btn);
            myCustomerBtn.setOnClickListener(this);
            allCustomerBtn.setOnClickListener(this);
            cancelCustomerBtn.setOnClickListener(this);
            branchCustomerBtn.setOnClickListener(this);
        }
        if (popupWindow == null) {
            popupWindow = new PopupWindow(this);
            popupWindow.setTouchable(true); // 设置PopupWindow可触摸
            popupWindow.setOutsideTouchable(true); // 设置非PopupWindow区域可触摸
            popupWindow.setContentView(view);
            popupWindow.setWidth(LayoutParams.MATCH_PARENT);
            popupWindow.setHeight(LayoutParams.WRAP_CONTENT);
        }
        popupWindow.showAtLocation(filterBtn, Gravity.BOTTOM, 0, 0);
        popupWindow.update();
    }

    //获得分组列表
    private void getGroupData() {
        if (getDataThread == null) {
            getDataThread = new GetBackendServerDataByJsonThread(getBackendServerDataTask());
            getDataThread.start();
        }
    }

    private GetTagListTaskImpl getBackendServerDataTask() {
        if (getTagListTask == null) {
            getTagListTask = new GetTagListTaskImpl(mHandler, userinfoApplication, 2);
        }
        return getTagListTask;
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.search_btn:
                if (choosePersonSearchView.getVisibility() == View.GONE) {
                    choosePersonSearchView.setVisibility(View.VISIBLE);
                } else {
                    choosePersonSearchView.setVisibility(View.GONE);
                }
                break;
            case R.id.choose_make_sure_btn:
                boolean flag = ("Doctor").equals(personRole) && ("Multi").equals(checkModel);
                if (mustSelectOne) {
                    String tipMessage = "";
                    if (personRole.equals("Doctor")) {
                        tipMessage = "请选择一个美丽顾问";
                    } else if (personRole.equals("Customer")) {
                        tipMessage = "请选择一个顾客";
                    }
                    if (choosePersonListAdapter.checkedPerson == null || choosePersonListAdapter.checkedPerson.size() == 0)
                        DialogUtil.createShortDialog(this, tipMessage);
                    else {
                        handleResult();
                    }
                } else {
                    handleResult();
                }
                break;
            case R.id.filter_btn:
                if (choosePersonSearchView.getVisibility() == View.VISIBLE) {
                    choosePersonSearchView.setQuery("", false);
                    choosePersonSearchView.setVisibility(View.GONE);
                }
                showPopupWindow();
                break;
            case R.id.my_customer_btn:
                personList = new ArrayList<Customer>();
                progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.show();
                personList = new ArrayList<Customer>();
                requestWebServiceThread = new Thread() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        String methodName = "getCustomerList";
                        String endPoint = "Customer";
                        JSONObject customerListJsonParam = new JSONObject();
                        try {
                            customerListJsonParam.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                            customerListJsonParam.put("CompanyID", userinfoApplication.getAccountInfo().getCompanyId());
                            customerListJsonParam.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                            customerListJsonParam.put("ObjectType", 0);
                            customerListJsonParam.put("LevelID", "");
                            customerListJsonParam.put("RegistFrom", -1);
                            customerListJsonParam.put("SourceType", -1);
                            if (screenWidth == 720) {
                                customerListJsonParam.put("ImageWidth", "100");
                                customerListJsonParam.put("ImageHeight", "100");
                            } else if (screenWidth == 480 || screenWidth == 540) {
                                customerListJsonParam.put("ImageWidth", "60");
                                customerListJsonParam.put("ImageHeight", "60");
                            } else if (screenWidth == 1536) {
                                customerListJsonParam.put("ImageWidth", "180");
                                customerListJsonParam.put("ImageHeight", "180");
                            }
                        } catch (JSONException e) {
                        }
                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerListJsonParam.toString(), userinfoApplication);
                        JSONObject resultJson = null;
                        try {
                            resultJson = new JSONObject(serverRequestResult);
                        } catch (JSONException e) {
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
                                // TODO Auto-generated catch block
                                code = 0;
                            }
                            if (code == 1) {
                                JSONArray customerListJsonArray = null;
                                try {
                                    customerListJsonArray = resultJson.getJSONArray("Data");
                                } catch (JSONException e) {
                                }
                                parseWebserviceResultForCustomer(customerListJsonArray);
                                mHandler.sendEmptyMessage(1);
                            } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                mHandler.sendEmptyMessage(code);
                            else {
                                mHandler.sendEmptyMessage(2);
                            }
                        }
                    }
                };
                requestWebServiceThread.start();
                if (choosePersonSearchView.getVisibility() == View.VISIBLE) {
                    choosePersonSearchView.setVisibility(View.GONE);
                }
                popupWindow.dismiss();
                break;
            case R.id.branch_customer_btn:
                personList = new ArrayList<Customer>();
                progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.show();
                personList = new ArrayList<Customer>();
                requestWebServiceThread = new Thread() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        String methodName = "getCustomerList";
                        String endPoint = "Customer";
                        JSONObject customerListJsonParam = new JSONObject();
                        try {
                            customerListJsonParam.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                            customerListJsonParam.put("CompanyID", userinfoApplication.getAccountInfo().getCompanyId());
                            customerListJsonParam.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                            customerListJsonParam.put("ObjectType", 2);
                            customerListJsonParam.put("LevelID", "");
                            customerListJsonParam.put("RegistFrom", -1);
                            customerListJsonParam.put("SourceType", -1);
                            if (screenWidth == 720) {
                                customerListJsonParam.put("ImageWidth", "100");
                                customerListJsonParam.put("ImageHeight", "100");
                            } else if (screenWidth == 480 || screenWidth == 540) {
                                customerListJsonParam.put("ImageWidth", "60");
                                customerListJsonParam.put("ImageHeight", "60");
                            } else if (screenWidth == 1536) {
                                customerListJsonParam.put("ImageWidth", "180");
                                customerListJsonParam.put("ImageHeight", "180");
                            }
                        } catch (JSONException e) {

                        }
                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerListJsonParam.toString(), userinfoApplication);
                        JSONObject resultJson = null;
                        try {
                            resultJson = new JSONObject(serverRequestResult);
                        } catch (JSONException e) {
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
                            }
                            if (code == 1) {
                                JSONArray customerListJsonArray = null;
                                try {
                                    customerListJsonArray = resultJson.getJSONArray("Data");
                                } catch (JSONException e) {
                                    // TODO Auto-generated catch block
                                }
                                parseWebserviceResultForCustomer(customerListJsonArray);
                                mHandler.sendEmptyMessage(1);
                            } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                                mHandler.sendEmptyMessage(code);
                            else {
                                mHandler.sendEmptyMessage(2);
                            }
                        }
                    }
                };
                requestWebServiceThread.start();
                if (choosePersonSearchView.getVisibility() == View.VISIBLE) {
                    choosePersonSearchView.setVisibility(View.GONE);
                }
                popupWindow.dismiss();
                break;
            case R.id.all_customer_btn:
                personList = new ArrayList<Customer>();
                progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.show();
                requestWebServiceThread = new Thread() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        String methodName = "getCustomerList";
                        String endPoint = "Customer";
                        JSONObject customerListJsonParam = new JSONObject();
                        try {
                            customerListJsonParam.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                            customerListJsonParam.put("CompanyID", userinfoApplication.getAccountInfo().getCompanyId());
                            customerListJsonParam.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                            customerListJsonParam.put("ObjectType", 1);
                            customerListJsonParam.put("LevelID", "");
                            customerListJsonParam.put("RegistFrom", -1);
                            customerListJsonParam.put("SourceType", -1);
                            if (screenWidth == 720) {
                                customerListJsonParam.put("ImageWidth", "100");
                                customerListJsonParam.put("ImageHeight", "100");
                            } else if (screenWidth == 480 || screenWidth == 540) {
                                customerListJsonParam.put("ImageWidth", "60");
                                customerListJsonParam.put("ImageHeight", "60");
                            } else if (screenWidth == 1536) {
                                customerListJsonParam.put("ImageWidth", "180");
                                customerListJsonParam.put("ImageHeight", "180");
                            }
                        } catch (JSONException e) {

                        }
                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerListJsonParam.toString(), userinfoApplication);
                        JSONObject resultJson = null;
                        try {
                            resultJson = new JSONObject(serverRequestResult);
                        } catch (JSONException e) {
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
                            }
                            if (code == 1) {
                                JSONArray customerListJsonArray = null;
                                try {
                                    customerListJsonArray = resultJson.getJSONArray("Data");
                                } catch (JSONException e) {
                                }
                                parseWebserviceResultForCustomer(customerListJsonArray);
                                mHandler.sendEmptyMessage(1);
                            } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                                mHandler.sendEmptyMessage(code);
                            else {
                                mHandler.sendEmptyMessage(2);
                            }
                        }
                    }
                };
                requestWebServiceThread.start();
                if (choosePersonSearchView.getVisibility() == View.VISIBLE) {
                    choosePersonSearchView.setVisibility(View.GONE);
                }
                popupWindow.dismiss();
                break;
            case R.id.select_all_person_checkbox:
                if (isSelectAll == false) {
                    choosePersonListAdapter.checkedPerson.removeAll(choosePersonListAdapter.checkedPerson);
                    for (int i = 0; i < choosePersonListAdapter.personList.size(); i++) {
                        ChoosePersonListAdapter.getIsSelected().put(i, 1);
                        choosePersonListAdapter.checkedPerson.add(choosePersonListAdapter.personList.get(i));
                    }
                    isSelectAll = true;
                } else {
                    for (int i = 0; i < choosePersonListAdapter.personList.size(); i++) {
                        ChoosePersonListAdapter.getIsSelected().put(i, 0);
                        choosePersonListAdapter.checkedPerson.remove(choosePersonListAdapter.personList.get(i));
                    }
                    isSelectAll = false;
                }
                choosePersonListAdapter.notifyDataSetChanged();
                break;
            case R.id.cancel_btn:
                if (choosePersonSearchView.getVisibility() == View.VISIBLE) {
                    choosePersonSearchView.setVisibility(View.GONE);
                }
                popupWindow.dismiss();
                break;
            //点击分组过滤
            case R.id.group_filter_btn:
                getGroupData();
                break;
        }
    }

    /**
     * 可以选择对个美丽顾问
     */
    private void handleBenefitPersonSelect() {
        // TODO Auto-generated method stub
        Intent reslutData = new Intent();
        JSONArray personId = new JSONArray();
        StringBuilder personName = new StringBuilder("");
        final List<Customer> selectPersonList = choosePersonListAdapter.checkedPerson;
        if (selectPersonList != null && selectPersonList.size() > 0) {
            final int count = selectPersonList.size();
            int id;
            String name;
            for (int i = 0; i < count; i++) {
                id = selectPersonList.get(i).getCustomerId();
                name = selectPersonList.get(i).getCustomerName();
                personId.put(id);
                personName.append(name);
                if (i < count - 1)
                    personName.append("、");
            }
        }
        reslutData.putExtra("personId", personId.toString());
        reslutData.putExtra("personName", personName.toString());
        setResult(RESULT_OK, reslutData);
        finish();
    }

    /*
     * 将值传递给跳转进来的界面
     * */
    private void handleResult() {
        Intent data = null;
        if (null != personRole && ("Doctor").equals(personRole)) {
            if (("Single").equals(checkModel)) {
                handleSingleDoctorSelect();
            } else if (("Multi").equals(checkModel)) {
                handleBenefitPersonSelect();
            }

        } else if (null != personRole && ("Customer").equals(personRole) && null != checkModel && ("Multi").equals(checkModel) && null != messageType && !("OrderFilter").equals(messageType)) {
            StringBuilder toUsersName = new StringBuilder();
            StringBuilder toUsersID = new StringBuilder();
            for (int i = 0; i < choosePersonListAdapter.checkedPerson.size(); i++) {
                toUsersID.append(choosePersonListAdapter.checkedPerson.get(i).getCustomerId() + ",");
                toUsersName.append(choosePersonListAdapter.checkedPerson.get(i).getCustomerName() + ",");
            }
            if (messageType.equals("Emarketing")) {
                data = new Intent();
                data.putExtra("toUsersName", toUsersName.toString());
                data.putExtra("toUsersID", toUsersID.toString());
                setResult(RESULT_OK, data);
            } else if (messageType.equals("FlyMessage")) {
                data = new Intent(this, FlyMessageDetailActivity.class);
                data.putExtra("toUsersName", toUsersName.toString());
                data.putExtra("toUsersID", toUsersID.toString());
                data.putExtra("Des", "Send");
                startActivity(data);
            }
        } else if (null != personRole && ("Customer").equals(personRole) && null != messageType && ("OrderFilter").equals(messageType)) {
            int personId = 0;
            String personName = "";
            List<Customer> selectPersonList = choosePersonListAdapter.checkedPerson;
            if (selectPersonList == null || selectPersonList.size() == 0) {
                personId = 0;
                personName = "";
            } else {
                personId = selectPersonList.get(0).getCustomerId();
                personName = selectPersonList.get(0).getCustomerName();
            }
            data = new Intent();
            data.putExtra("personId", personId);
            data.putExtra("personName", personName);
            setResult(RESULT_OK, data);
        }
        if (data != null)
            this.finish();
    }

    /**
     * 只能选择一个美丽顾问
     */
    private void handleSingleDoctorSelect() {
        Intent reslutData = null;
        int personId = 0;
        String personName = "";
        final List<Customer> selectPersonList = choosePersonListAdapter.checkedPerson;
        if (selectPersonList != null && selectPersonList.size() != 0) {
            personId = selectPersonList.get(0).getCustomerId();
            personName = selectPersonList.get(0).getCustomerName();
            reslutData = new Intent();
            reslutData.putExtra("personId", personId);
            reslutData.putExtra("personName", personName);
        } else {
            reslutData = new Intent();
            reslutData.putExtra("personId", 0);
            reslutData.putExtra("personName", "");
        }
        setResult(RESULT_OK, reslutData);
        finish();
    }

    private List<Customer> searchPerson(String name) {
        List<Customer> newPersonList = new ArrayList<Customer>();
        for (Customer person : personList) {
            if (person.getPinYin().contains(name.toLowerCase()) || person.getCustomerName().toLowerCase().contains(name.toLowerCase())) {
                newPersonList.add(person);
            }
        }
        return newPersonList;
    }

    @Override
    public boolean onQueryTextChange(String newText) {
        // TODO Auto-generated method stub
        List<Customer> queryResult = new ArrayList<Customer>();
        queryResult = searchPerson(newText);
        choosePersonListAdapter = new ChoosePersonListAdapter(this, queryResult, checkMode, selectPersonIDs);
        choosePersonListView.setAdapter(choosePersonListAdapter);
        return false;
    }

    @Override
    public boolean onQueryTextSubmit(String newText) {
        return false;
    }

    private void parseWebserviceResultForDoctor(JSONArray docotorArray) {
        if (docotorArray != null && docotorArray.length() != 0) {
            for (int i = 0; i < docotorArray.length(); i++) {
                JSONObject doctorJson = null;
                try {
                    doctorJson = docotorArray.getJSONObject(i);
                } catch (JSONException e) {
                }
                String accountId = "";
                String accountName = "";
                String accountCode = "";
                String department = "";
                String title = "";
                String expert = "";
                String headImage = "";
                String pinYin = "";
                int accountType = 2;
                try {
                    if (doctorJson.has("AccountID") && !doctorJson.isNull("AccountID"))
                        accountId = doctorJson.getString("AccountID");
                    if (doctorJson.has("AccountName") && !doctorJson.isNull("AccountName"))
                        accountName = doctorJson.getString("AccountName");
                    if (doctorJson.has("AccountCode") && !doctorJson.isNull("AccountCode"))
                        accountCode = doctorJson.getString("AccountCode");
                    if (doctorJson.has("Department") && !doctorJson.isNull("Department"))
                        department = doctorJson.getString("Department");
                    if (doctorJson.has("Title") && !doctorJson.isNull("Title"))
                        title = doctorJson.getString("Title");
                    if (doctorJson.has("Expert") && !doctorJson.isNull("Expert"))
                        expert = doctorJson.getString("Expert");
                    if (doctorJson.has("HeadImageURL") && !doctorJson.isNull("HeadImageURL"))
                        headImage = doctorJson.getString("HeadImageURL");
                    if (doctorJson.has("PinYin") && !doctorJson.isNull("PinYin"))
                        pinYin = doctorJson.getString("PinYin");
                    if (doctorJson.has("AccountType") && !doctorJson.isNull("AccountType"))
                        accountType = doctorJson.getInt("AccountType");
                } catch (JSONException e) {
                }
                Customer person = new Customer();
                person.setCustomerId(Integer.parseInt(accountId));
                person.setCustomerName(accountName);
                person.setAccountCode(accountCode);
                person.setDepartment(department);
                person.setTitle(title);
                person.setExpert(expert);
                person.setHeadImageUrl(headImage);
                person.setPinYin(pinYin);
                person.setAccountType(accountType);
                personList.add(person);
            }
        }
    }

    private void parseWebserviceResultForCustomer(JSONArray customerListJsonArray) {
        for (int i = 0; i < customerListJsonArray.length(); i++) {
            Customer customer = new Customer();
            int customerId = 0;
            String customerName = "";
            String headImage = "";
            String pinYin = "";
            String loginMobile = "";
            boolean isMyCustomer = false;
            String phone = "";
            try {
                JSONObject customerJson = customerListJsonArray.getJSONObject(i);

                if (customerJson.has("CustomerID")) {
                    customerId = customerJson.getInt("CustomerID");
                }
                if (customerJson.has("CustomerName")) {
                    customerName = customerJson.getString("CustomerName");
                }
                if (customerJson.has("HeadImageURL")) {
                    headImage = customerJson.getString("HeadImageURL");
                }
                if (customerJson.has("PinYin")) {
                    pinYin = customerJson.getString("PinYin");
                }
                if (customerJson.has("LoginMobile")) {
                    loginMobile = customerJson.getString("LoginMobile");
                }
                if (customerJson.has("IsMyCustomer")) {
                    isMyCustomer = customerJson.getBoolean("IsMyCustomer");
                }
                if (customerJson.has("Phone")) {
                    phone = customerJson.getString("Phone");
                }
            } catch (JSONException e) {

            }
            customer.setCustomerId(customerId);
            customer.setCustomerName(customerName);
            customer.setHeadImageUrl(headImage);
            customer.setPinYin(pinYin);
            customer.setLoginMobile(loginMobile);
            customer.setIsMyCustomer(isMyCustomer);
            customer.setPhone(phone);
            personList.add(customer);
        }
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        // TODO Auto-generated method stub
        if (isChecked) {
            for (int i = 0; i < personList.size(); i++) {
                ChoosePersonListAdapter.getIsSelected().put(i, 1);
            }
            choosePersonListAdapter.notifyDataSetChanged();
        } else if (!isChecked) {
            for (int i = 0; i < personList.size(); i++) {
                ChoosePersonListAdapter.getIsSelected().put(i, 0);
            }
            choosePersonListAdapter.notifyDataSetChanged();
        }
    }

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
        if (getDataThread != null) {
            getDataThread.interrupt();
            getDataThread = null;
        }
    }

}
