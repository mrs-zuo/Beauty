package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.ExpandableListView;
import android.widget.ImageButton;
import android.widget.PopupWindow;
import android.widget.SearchView;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import cn.com.antika.adapter.CustomerListItemAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AccountInfo;
import cn.com.antika.bean.Customer;
import cn.com.antika.bean.CustomerAdvancedCondition;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.minterface.RefreshListViewWithWebservice;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.HashList;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.AssortView;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 我的顾客信息列表
 * */
@SuppressLint("ResourceType")
public class CustomerActivity extends BaseActivity implements OnClickListener, OnQueryTextListener, OnScrollListener {
    private CustomerActivityHandler mHandler = new CustomerActivityHandler(this);
    private ExpandableListView customerListView;
    private Thread requestWebServiceThread;
    // 后台获取的顾客
    private List<Customer> customerList;
    // 顾客总数
    private Integer customerCnt = 0;
    // 加载状态
    private boolean loadFlg = false;
    private ProgressDialog progressDialog;
    private SearchView searchCustomerView;
    // 检索的key
    private String searchName;
    private ImageButton customerAdvancedFilterButton, addNewCustomerButton;
    private CustomerListItemAdapter customerListItemAdapter;
    private AccountInfo accountInfo;
    private int screenWidth;
    private UserInfoApplication userinfoApplication;
    private SharedPreferences accountInfoSharePreferences;
    private RefreshListViewWithWebservice refreshListViewWithWebService;
    private TextView customerTitleText;
    private CustomerAdvancedCondition customerAdvancedCondition;
    private TextView customerCountInfoText;
    private PackageUpdateUtil packageUpdateUtil;
    private AssortView assortView;// 右侧的字母列表
    private int fromSource;// 3：从顾客转换按钮点击过来
    private List<OrderInfo> convertOrderList;
    private String searchKeyWord;
    private SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss:SSS");
    private Integer pageIndexRollBack;
    // 加载更多
    private View mFooter;
    private View mFooterParent;
    private TextView mFooterText;
    private View mHeader;
    private View mHeaderParent;
    // 需要刷新标志
    private boolean mustRefreshFlg;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.mustRefreshFlg = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer);
        customerTitleText = (TextView) findViewById(R.id.customer_title_text);
        customerListView = (ExpandableListView) findViewById(R.id.customer_list_view);
        refreshListViewWithWebService = new RefreshListViewWithWebservice() {
            @Override
            public Object refreshing() {
                // TODO Auto-generated method stub
                String returncode = "ok";
                if (requestWebServiceThread == null) {
                    requestWebService(true);
                }
                return returncode;
            }

            @Override
            public void refreshed(Object obj) {

            }
        };
        searchCustomerView = (SearchView) findViewById(R.id.search_customer);
        userinfoApplication = UserInfoApplication.getInstance();
        accountInfo = userinfoApplication.getAccountInfo();
        addNewCustomerButton = (ImageButton) findViewById(R.id.add_newcustomer_btn);
        addNewCustomerButton.setOnClickListener(this);
        searchCustomerView.setVisibility(View.VISIBLE);
        searchCustomerView.setOnQueryTextListener(this);
        customerAdvancedFilterButton = (ImageButton) findViewById(R.id.customer_advanced_filter_btn);
        customerAdvancedFilterButton.setOnClickListener(this);
        customerCountInfoText = (TextView) findViewById(R.id.customer_count_info_text);
        assortView = (AssortView) findViewById(R.id.assort_view);
        // 加載更多
        // 头部
        mHeaderParent = getLayoutInflater().inflate(R.layout.load_more_page_up, null);
        mHeader = mHeaderParent.findViewById(R.id.mHeader);
        mHeader.setVisibility(View.GONE);
        customerListView.addHeaderView(mHeaderParent);
        // 底部
        mFooterParent = getLayoutInflater().inflate(R.layout.load_more, null);
        mFooter = mFooterParent.findViewById(R.id.mFooter);
        mFooter.setVisibility(View.GONE);
        customerListView.addFooterView(mFooterParent);
        mFooterText = (TextView) mFooter.findViewById(R.id.mFooterText);
        // 隐藏头部和底部的下划线
        customerListView.setHeaderDividersEnabled(false);
        customerListView.setFooterDividersEnabled(false);
        // 添加滑动监听
        customerListView.setOnScrollListener(this);
        // 屏蔽默认的箭头图标
        customerListView.setGroupIndicator(null);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        initView();
    }

    private static class CustomerActivityHandler extends Handler {
        private final CustomerActivity customerActivity;

        private CustomerActivityHandler(CustomerActivity activity) {
            // 初期化 弱引用 获取对象实例
            WeakReference<CustomerActivity> activityWeakReference = new WeakReference<CustomerActivity>(activity);
            customerActivity = activityWeakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            Log.i("CustomerActivity", "接收msg start：" + msg.what + ":" + customerActivity.sf.format(new Date()));
            if (customerActivity.progressDialog != null) {
                customerActivity.progressDialog.dismiss();
                customerActivity.progressDialog = null;
            }
            // 未获取到数据的情况
            if (customerActivity.loadFlg && msg.what != 1) {
                if (customerActivity.pageIndexRollBack != null) {
                    customerActivity.customerAdvancedCondition.setPageIndex(customerActivity.pageIndexRollBack);
                }
                // 隐藏头部和底部视图
                customerActivity.mFooter.setVisibility(View.GONE);
                customerActivity.mHeader.setVisibility(View.GONE);
            }
            if (msg.what == 1) {
                customerActivity.customerListItemAdapter = new CustomerListItemAdapter(customerActivity, customerActivity.customerList, customerActivity.fromSource, customerActivity.convertOrderList);
                customerActivity.customerListView.setAdapter(customerActivity.customerListItemAdapter);
                // 展开
                customerActivity.expandGroupAll(customerActivity.customerListItemAdapter);
                // 隐藏头部和底部视图
                customerActivity.mFooter.setVisibility(View.GONE);
                customerActivity.mHeader.setVisibility(View.GONE);
                // 暂无数据
                if (customerActivity.customerCnt == 0) {
                    customerActivity.mFooterText.setText(R.string.load_no_data);
                    customerActivity.mFooter.setVisibility(View.VISIBLE);
                }
                // 所有顾客 废除条件筛选
                if (customerActivity.customerAdvancedCondition.getCustomerType() == Constant.CUSTOMER_FILTER_TYPE_COMPANY) {
                    customerActivity.searchCustomerView.setVisibility(View.GONE);
                } else {
                    customerActivity.searchCustomerView.setVisibility(View.VISIBLE);
                }
                // 分页
                if (customerActivity.customerAdvancedCondition.isPageFlg()) {
                    // 是否还有更多
                    if (customerActivity.customerList.size() == 0 || customerActivity.customerList.size() < customerActivity.customerAdvancedCondition.getPageSize()
                            || (customerActivity.customerAdvancedCondition.getPageSize() * customerActivity.customerAdvancedCondition.getPageIndex()) >= customerActivity.customerCnt) {
                        customerActivity.customerAdvancedCondition.setLoadMoreFlg(false);
                        customerActivity.mFooterText.setText(R.string.load_more_no_data);
                        customerActivity.mFooter.setVisibility(View.VISIBLE);
                    } else {
                        customerActivity.customerAdvancedCondition.setLoadMoreFlg(true);
                    }
                } else {
                    customerActivity.customerAdvancedCondition.setLoadMoreFlg(false);
                }
                if (customerActivity.customerList.size() > 0) {
                    // 设置选中项
                    customerActivity.customerListView.setSelection(0);
                    // 自动滚动到已选择的顾客那一项
                    HashList<String, Customer> customerHashList = customerActivity.customerListItemAdapter.getAssort().getHashList();
                    int selectedGroup = -1;
                    int selectedChild = -1;
                    boolean flg = false;
                    for (int j = 0; j < customerHashList.size(); j++) {
                        if (flg) {
                            break;
                        }
                        List<Customer> customerList = customerHashList.getValueListIndex(j);
                        for (int a = 0; a < customerList.size(); a++) {
                            Customer customer = customerList.get(a);
                            if (customer.getCustomerId() == customerActivity.userinfoApplication.getSelectedCustomerID()) {
                                selectedGroup = j;
                                selectedChild = a;
                                flg = true;
                                break;
                            }
                        }
                    }
                    if (selectedGroup != -1) {
                        customerActivity.customerListView.setSelectedGroup(selectedGroup);
                        customerActivity.customerListView.setSelectedChild(selectedGroup, selectedChild, true);
                    }
                }
            } else if (msg.what == 0) {
                // DialogUtil.createMakeSureDialog(customerActivity, "温馨提示", "您的网络貌似不给力，请检查网络设置");
                DialogUtil.createShortDialog(customerActivity, "您的网络貌似不给力，请重试");
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(customerActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerActivity, customerActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerActivity);
                customerActivity.packageUpdateUtil = new PackageUpdateUtil(customerActivity, customerActivity.mHandler, fileCache, downloadFileUrl, false, customerActivity.userinfoApplication);
                customerActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = customerActivity.getFileStreamPath(filename);
                file.getName();
                customerActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 99) {
                DialogUtil.createShortDialog(customerActivity, "服务器异常，请重试");
            }
            if (customerActivity.requestWebServiceThread != null) {
                customerActivity.requestWebServiceThread.interrupt();
                customerActivity.requestWebServiceThread = null;
            }
            // 设置显示记录数
            customerActivity.setCustomerListDisplayTotal();
            // 数据加载完成
            customerActivity.loadFlg = false;
            Log.i("CustomerActivity", "接收msg end：" + msg.what + ":" + customerActivity.sf.format(new Date()));
        }
    }

    protected void initView() {
        fromSource = getIntent().getIntExtra("fromSource", 0);
        searchKeyWord = getIntent().getStringExtra("searchKeyWord");
        if (fromSource == 3) {
            convertOrderList = (List<OrderInfo>) getIntent().getSerializableExtra("convertOrderList");
        }
        customerList = new ArrayList<Customer>();
        customerListItemAdapter = new CustomerListItemAdapter(this, customerList, fromSource, convertOrderList);
        customerListView.setAdapter(customerListItemAdapter);
        // 右侧的按字母分组 字母按键回调
        assortView.setOnTouchAssortListener(new AssortView.OnTouchAssortListener() {
            View layoutView = LayoutInflater.from(CustomerActivity.this).inflate(R.xml.assort_alert_dialog_layout, null);
            TextView text = (TextView) layoutView.findViewById(R.id.letters_content);
            PopupWindow popupWindow;

            public void onTouchAssortListener(String str) {
                int index = customerListItemAdapter.getAssort().getHashList().indexOfKey(str);
                if (index != -1) {
                    customerListView.setSelectedGroup(index);
                }
                if (popupWindow != null) {
                    text.setText(str);
                } else {
                    popupWindow = new PopupWindow(layoutView, 100, 100, false);
                    // 显示在Activity的根视图中心
                    popupWindow.showAtLocation(getWindow().getDecorView(), Gravity.CENTER, 0, 0);
                }
                text.setText(str);
            }

            public void onTouchAssortUP() {
                if (popupWindow != null)
                    popupWindow.dismiss();
                popupWindow = null;
            }
        });
        screenWidth = userinfoApplication.getScreenWidth();
        getCustomerTypeFilter();
        requestWebService(true);
    }

    // 从本地XML获得上次筛选的顾客类型
    private void getCustomerTypeFilter() {
        customerAdvancedCondition = new CustomerAdvancedCondition();
        if (accountInfoSharePreferences == null)
            accountInfoSharePreferences = getSharedPreferences(
                    "GlmourPromiseCustomerTypeFilter", MODE_PRIVATE);
        String customerTypeFileterStr = accountInfoSharePreferences.getString(
                "CustomerTypeFilter", "");
        int authReadAllCustomer = userinfoApplication.getAccountInfo().getAuthAllCustomerRead();
        // 判断是否有读取全部顾客的权限
        if (authReadAllCustomer == 0) {
            customerAdvancedCondition.setCustomerType(Constant.CUSTOMER_FILTER_TYPE_MY);
        } else {
            // try {
            // JSONObject CustomerTypeFileterJson = new JSONObject(customerTypeFileterStr);
            // StringBuilder customerTypeFileterID = new StringBuilder();
            // customerTypeFileterID.append(userinfoApplication.getAccountInfo().getCompanyId());
            // customerTypeFileterID.append("-");
            // customerTypeFileterID.append(userinfoApplication.getAccountInfo().getBranchId());
            // customerTypeFileterID.append("-");
            // customerTypeFileterID.append(userinfoApplication.getAccountInfo().getAccountId());
            // int customerTypeFilter = (Integer)
            // CustomerTypeFileterJson.get(customerTypeFileterID.toString());
            // customerAdvancedCondition.setCustomerType(customerTypeFilter);
            // } catch (JSONException e) {
            // customerAdvancedCondition.setCustomerType(Constant.CUSTOMER_FILTER_TYPE_MY);
            // }
            customerAdvancedCondition.setCustomerType(Constant.CUSTOMER_FILTER_TYPE_BRANCH);
        }
        // 空代表所有顾客列出
        customerAdvancedCondition.setCardCode("");
        customerAdvancedCondition.setAccountIDs("");
        customerAdvancedCondition.setRegistFrom(-1);
        customerAdvancedCondition.setSourceTypeID(-1);
        // 查询时间点
        customerAdvancedCondition.setSearchDateTime(sf.format(new Date()));
    }

    private void setCustomerTypeFilter() {
        if (accountInfoSharePreferences == null)
            accountInfoSharePreferences = getSharedPreferences("GlmourPromiseCustomerTypeFilter", MODE_PRIVATE);
        String customerTypeFileterStr = accountInfoSharePreferences.getString("CustomerTypeFilter", "");
        JSONObject CustomerTypeFileterJson = null;
        if (customerTypeFileterStr.equals("")) {
            CustomerTypeFileterJson = new JSONObject();
        } else {
            try {
                CustomerTypeFileterJson = new JSONObject(customerTypeFileterStr);
            } catch (JSONException e) {
                CustomerTypeFileterJson = new JSONObject();
            }
        }
        StringBuilder customerTypeFileterID = new StringBuilder();
        customerTypeFileterID.append(userinfoApplication.getAccountInfo().getCompanyId());
        customerTypeFileterID.append("-");
        customerTypeFileterID.append(userinfoApplication.getAccountInfo().getBranchId());
        customerTypeFileterID.append("-");
        customerTypeFileterID.append(userinfoApplication.getAccountInfo().getAccountId());
        try {
            CustomerTypeFileterJson.put(customerTypeFileterID.toString(), customerAdvancedCondition.getCustomerType());
        } catch (JSONException e) {
            mHandler.sendEmptyMessage(99);
            return;
        }
        accountInfoSharePreferences.edit().putString("CustomerTypeFilter", CustomerTypeFileterJson.toString()).commit();
    }

    protected void requestWebService(boolean isNeedProgressDialog) {
        Log.i("CustomerActivity", "获取数据开始：" + customerAdvancedCondition.getPageIndex() + ":" + sf.format(new Date()));
        if (isNeedProgressDialog) {
            /*progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
            progressDialog.setCancelable(false);
            progressDialog.show();*/
            progressDialog = ProgressDialogUtil.createProgressDialog(this);
            if (customerAdvancedCondition.getCustomerType() == Constant.CUSTOMER_FILTER_TYPE_MY) {
                customerTitleText.setText(getString(R.string.my_customer_btn));
            } else if (customerAdvancedCondition.getCustomerType() == Constant.CUSTOMER_FILTER_TYPE_COMPANY) {
                customerTitleText.setText(getString(R.string.all_customer_btn));
            } else if (customerAdvancedCondition.getCustomerType() == Constant.CUSTOMER_FILTER_TYPE_BRANCH) {
                customerTitleText.setText(getString(R.string.branch_customer_btn));
            }
        }
        customerList.clear();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "getCustomerList";
                String endPoint = "Customer";
                JSONObject customerListJsonParam = new JSONObject();
                try {
                    if (customerAdvancedCondition.getAccountIDs() != null && !("").equals(customerAdvancedCondition.getAccountIDs()))
                        customerListJsonParam.put("AccountIDList", new JSONArray(customerAdvancedCondition.getAccountIDs()));
                    customerListJsonParam.put("CompanyID", String.valueOf(accountInfo.getCompanyId()));
                    customerListJsonParam.put("BranchID", String.valueOf(accountInfo.getBranchId()));
                    customerListJsonParam.put("ObjectType", String.valueOf(customerAdvancedCondition.getCustomerType()));
                    if (customerAdvancedCondition.getCardCode() == null || customerAdvancedCondition.getCardCode().equals(""))
                        customerListJsonParam.put("CardCode", "");
                    else
                        customerListJsonParam.put("CardCode", customerAdvancedCondition.getCardCode());
                    customerListJsonParam.put("RegistFrom", customerAdvancedCondition.getRegistFrom());
                    customerListJsonParam.put("SourceType", customerAdvancedCondition.getSourceTypeID());
                    customerListJsonParam.put("FirstVisitType", customerAdvancedCondition.getFirstVisitType());
                    if (customerAdvancedCondition.getFirstVisitDateTime() == null || customerAdvancedCondition.getFirstVisitDateTime().equals(""))
                        customerListJsonParam.put("FirstVisitDateTime", "");
                    else
                        customerListJsonParam.put("FirstVisitDateTime", customerAdvancedCondition.getFirstVisitDateTime());
                    customerListJsonParam.put("EffectiveCustomerType", customerAdvancedCondition.getEffectiveCustomerType());
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
                    // 所有顾客
                    if (customerAdvancedCondition.getCustomerType() == Constant.CUSTOMER_FILTER_TYPE_COMPANY) {
                        customerListJsonParam.put("PageFlg", true);
                        // customerListJsonParam.put("SearchDateTime", customerAdvancedCondition.getSearchDateTime());
                        customerListJsonParam.put("SearchDateTime", sf.format(new Date()));
                        customerListJsonParam.put("PageIndex", customerAdvancedCondition.getPageIndex());
                        customerListJsonParam.put("PageSize", customerAdvancedCondition.getPageSize());
                        customerListJsonParam.put("CustomerName", customerAdvancedCondition.getCustomerName());
                        customerListJsonParam.put("CustomerTel", customerAdvancedCondition.getCustomerTel());
                    } else {
                        customerListJsonParam.put("PageFlg", false);
                    }

                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerListJsonParam.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e1) {
                    // TODO Auto-generated catch block
                    // e1.printStackTrace();
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    try {
                        code = resultJson.getInt("Code");
                    } catch (JSONException e1) {
                        // TODO Auto-generated catch block
                        // e1.printStackTrace();
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        JSONArray customerListJsonArray = null;
                        // 查询数据总数
                        try {
                            customerCnt = resultJson.getInt("DataCnt");
                        } catch (JSONException e1) {
                            // TODO Auto-generated catch block
                            // e1.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        // 查询数据（若分页则返回分页数据）
                        try {
                            customerListJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e1) {
                            // TODO Auto-generated catch block
                            // e1.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        for (int i = 0; i < customerListJsonArray.length(); i++) {
                            Customer customer = new Customer();
                            int customerId = 0;
                            String customerName = "";
                            String headImage = "";
                            String pinYin = "";
                            String loginMobile = "";
                            boolean isMyCustomer = false;
                            String phone = "";
                            String cometime = "";
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
                                if (customerJson.has("ComeTime")) {
                                    cometime = customerJson.getString("ComeTime");
                                }
                            } catch (JSONException e) {
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                            customer.setCustomerId(customerId);
                            customer.setCustomerName(customerName);
                            customer.setHeadImageUrl(headImage);
                            customer.setPinYin(pinYin);
                            customer.setLoginMobile(loginMobile);
                            customer.setIsMyCustomer(isMyCustomer);
                            customer.setPhone(phone);
                            if (cometime.equals("") || cometime.equals(null)) {
                                customer.setComeTime("未上门");
                            } else {
                                customer.setComeTime("最后上门日期：" + cometime);
                            }
                            customerList.add(customer);
                        }

                        mHandler.sendEmptyMessage(1);

                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        mHandler.sendEmptyMessage(2);
                    }
                }
                Log.i("CustomerActivity", "获取数据结束：" + sf.format(new Date()));
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.add_newcustomer_btn:
                Intent destIntent = new Intent(this, AddNewCustomerActivity.class);
                startActivity(destIntent);
                this.finish();
                break;
            case R.id.customer_advanced_filter_btn:
                Intent customerAdvancedConditionIntent = new Intent(this, CustomerAdvancedConditionActivity.class);
                customerAdvancedConditionIntent.putExtra("customerType", customerAdvancedCondition.getCustomerType());
                startActivityForResult(customerAdvancedConditionIntent, 300);
                break;
            default:
                break;
        }
    }

    @Override
    public boolean onQueryTextChange(String newText) {
        // TODO Auto-generated method stub
        newText = newText.toLowerCase();
        searchName = newText;
        if (!TextUtils.isEmpty(newText)) {
            updateLayout(searchCustomer(searchName));
        } else {
            customerListView.setAdapter(customerListItemAdapter);
            expandGroupAll(customerListItemAdapter);
            customerListView.setSelection(0);
            setCustomerListDisplayTotal();
        }
        return false;
    }

    private List<Customer> searchCustomer(String searchKeyWord) {
        List<Customer> newCustomerList = new ArrayList<Customer>();
        if (!TextUtils.isEmpty(searchKeyWord)) {
            for (Customer customer : customerList) {
                if (customer.getPinYin().contains(searchKeyWord.toLowerCase())
                        || customer.getCustomerName().toLowerCase().contains(searchKeyWord.toLowerCase())
                        || customer.getOriginalLoginMobile().contains(searchKeyWord)
                        || customer.getPhone().contains(searchKeyWord)) {
                    newCustomerList.add(customer);
                }
            }
        }
        return newCustomerList;
    }

    @Override
    public boolean onQueryTextSubmit(String newText) {
        // TODO Auto-generated method stub
        return false;
    }

    private void updateLayout(List<Customer> customerList) {
        CustomerListItemAdapter customerListItemAdapterSearch = new CustomerListItemAdapter(this, customerList,
                fromSource, convertOrderList);
        customerListView.setAdapter(customerListItemAdapterSearch);
        expandGroupAll(customerListItemAdapterSearch);
        setCustomerListDisplayTotal();
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        System.gc();
    }

    // 接收选择筛选条件之后
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == 100) {
            customerCnt = 0;
            customerList.clear();
            customerListItemAdapter.notifyDataSetChanged();
            // 清除过滤
            searchCustomerView.setQuery(null, false);
            customerAdvancedCondition = (CustomerAdvancedCondition) data
                    .getSerializableExtra("customerAdvancedCondition");
            // 所有顾客 分页
            if (customerAdvancedCondition.getCustomerType() == Constant.CUSTOMER_FILTER_TYPE_COMPANY) {
                customerAdvancedCondition.setPageFlg(true);
            }
            // 设置查询点
            customerAdvancedCondition.setSearchDateTime(sf.format(new Date()));
            // 设置起始页
            customerAdvancedCondition.setPageIndex(1);
            setCustomerTypeFilter();
            requestWebService(true);
        }
    }

    @Override
    public void onScrollStateChanged(AbsListView view, int scrollState) {
        // TODO Auto-generated method stub
        switch (scrollState) {
            // 当不滚动时
            case OnScrollListener.SCROLL_STATE_IDLE:
                if (customerAdvancedCondition.isPageFlg() && !loadFlg) {
                    // 分页加载
                    if (view.getFirstVisiblePosition() == 0) {
                        // 顶部
                        if (customerAdvancedCondition.getPageIndex() > 1) {
                            // 上一页
                            loadData(false);
                        } else {
                            if (mustRefreshFlg) {
                                // 刷新数据
                                mHeader.setVisibility(View.VISIBLE);
                                refreshListViewWithWebService.refreshing();
                                mustRefreshFlg = false;
                                /*customerAdvancedCondition.setPageIndex(1);
                                requestWebService(true);*/
                            } else {
                                mustRefreshFlg = true;
                            }
                        }
                    } else if (view.getLastVisiblePosition() == (view.getCount() - 1)) {
                        // 底部
                        if (customerAdvancedCondition.isLoadMoreFlg()) {
                            // 下一页
                            loadData(true);
                        }
                    }
                }
                break;
        }
    }

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
        // TODO Auto-generated method stub
    }

    /**
     * 加载数据
     * loadMoreFlg(true:下一页,false:上一页)
     */
    private void loadData(boolean loadMoreFlg) {
        loadFlg = true;
        pageIndexRollBack = customerAdvancedCondition.getPageIndex();
        if (loadMoreFlg) {
            mFooterText.setText(R.string.load_more_run);
            mFooter.setVisibility(View.VISIBLE);
            customerAdvancedCondition.setPageIndex(customerAdvancedCondition.getPageIndex() + 1);
        } else {
            mHeader.setVisibility(View.VISIBLE);
            customerAdvancedCondition.setPageIndex(customerAdvancedCondition.getPageIndex() - 1);
        }
        requestWebService(true);
    }

    /**
     * 设置显示记录数
     */
    private void setCustomerListDisplayTotal() {
        String customerCountInfo = "";
        if (customerAdvancedCondition.isPageFlg() && customerCnt != 0) {
            Integer startPos = (customerAdvancedCondition.getPageIndex() - 1) * customerAdvancedCondition.getPageSize()
                    + 1;
            Integer endPos = customerAdvancedCondition.getPageIndex() * customerAdvancedCondition.getPageSize();
            if (!customerAdvancedCondition.isLoadMoreFlg()) {
                endPos = customerCnt;
            }
            if (startPos > endPos) {
                startPos = endPos;
            }
            customerCountInfo = "(共" + startPos + "-" + endPos + "/" + customerCnt + "位)";
        } else {
            customerCountInfo = "(共" + customerCnt + "位)";
        }
        customerCountInfoText.setText(customerCountInfo);
    }

    /**
     * 展开所有分类
     */
    private void expandGroupAll(CustomerListItemAdapter customerListItemAdapter) {
        for (int i = 0, length = customerListItemAdapter.getGroupCount(); i < length; i++) {
            customerListView.expandGroup(i);
        }
    }

}
