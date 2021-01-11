package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.UnpaidOrderListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo.OrderListConditionBuilder;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.manager.OrderManager;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import java.io.File;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class CustomerUnpaidOrderActivity extends BaseActivity implements OnClickListener, OnItemClickListener {
    private CustomerUnpaidOrderActivityHandler mHandler = new CustomerUnpaidOrderActivityHandler(this);
    private List<OrderInfo> customerUnpaidOrderList;
    private ListView customerUnpaidOrderListView;
    private Button payForUnpaidOrderBtn;
    private ImageView allOrderSelectCheckBox;
    private ImageView customerUnpaidOrderCustomerConvert;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UnpaidOrderListAdapter unpaidOrderListAdapter;
    private UserInfoApplication userinfoApplication;
    public Boolean isAllItemSelect;//全选标记
    private ListItemClick listItemClick;
    private int fromSource, customerID = 0;
    String customerName;
    private TextView customerUnpaidOrderCustomerNameText;
    private OrderManager orderManager;
    private PackageUpdateUtil packageUpdateUtil;
    private int branchID;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_unpaid_order);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        fromSource = getIntent().getIntExtra("FromSource", Constant.USER_ROLE_CUSTOMER);
        branchID = getIntent().getIntExtra("BranchID", 0);
        initView();
    }

    private static class CustomerUnpaidOrderActivityHandler extends Handler {
        private final CustomerUnpaidOrderActivity customerUnpaidOrderActivity;

        private CustomerUnpaidOrderActivityHandler(CustomerUnpaidOrderActivity activity) {
            WeakReference<CustomerUnpaidOrderActivity> weakReference = new WeakReference<CustomerUnpaidOrderActivity>(activity);
            customerUnpaidOrderActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (customerUnpaidOrderActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerUnpaidOrderActivity.progressDialog != null) {
                customerUnpaidOrderActivity.progressDialog.dismiss();
                customerUnpaidOrderActivity.progressDialog = null;
            }
            if (message.what == 1) {
                customerUnpaidOrderActivity.customerUnpaidOrderList = (ArrayList<OrderInfo>) message.obj;
                customerUnpaidOrderActivity.unpaidOrderListAdapter = new UnpaidOrderListAdapter(customerUnpaidOrderActivity, customerUnpaidOrderActivity.customerUnpaidOrderList, customerUnpaidOrderActivity.listItemClick);
                customerUnpaidOrderActivity.customerUnpaidOrderListView.setAdapter(customerUnpaidOrderActivity.unpaidOrderListAdapter);
            } else if (message.what == 2)
                DialogUtil.createShortDialog(customerUnpaidOrderActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerUnpaidOrderActivity, customerUnpaidOrderActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerUnpaidOrderActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerUnpaidOrderActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerUnpaidOrderActivity);
                customerUnpaidOrderActivity.packageUpdateUtil = new PackageUpdateUtil(customerUnpaidOrderActivity, customerUnpaidOrderActivity.mHandler, fileCache, downloadFileUrl, false, customerUnpaidOrderActivity.userinfoApplication);
                customerUnpaidOrderActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                customerUnpaidOrderActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = customerUnpaidOrderActivity.getFileStreamPath(filename);
                file.getName();
                customerUnpaidOrderActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (customerUnpaidOrderActivity.requestWebServiceThread != null) {
                customerUnpaidOrderActivity.requestWebServiceThread.interrupt();
                customerUnpaidOrderActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        customerUnpaidOrderListView = (ListView) findViewById(R.id.customer_unpaid_order_list);
        customerUnpaidOrderListView.setOnItemClickListener(this);
        payForUnpaidOrderBtn = (Button) findViewById(R.id.pay_for_unpaid_order_btn);
        customerUnpaidOrderCustomerConvert = (ImageView) findViewById(R.id.customer_unpaid_order_customer_convert);
        customerUnpaidOrderCustomerConvert.setOnClickListener(this);
        if (fromSource == Constant.USER_ROLE_BUSINESS)
            customerName = getIntent().getStringExtra("CustomerName");
        else if (fromSource == Constant.USER_ROLE_CUSTOMER)
            customerName = userinfoApplication.getSelectedCustomerName();
        customerUnpaidOrderCustomerNameText = (TextView) findViewById(R.id.customer_unpaid_order_customer_name_text);
        customerUnpaidOrderCustomerNameText.setText("(" + customerName + ")");
        allOrderSelectCheckBox = (ImageView) findViewById(R.id.select_all_unpaid_order);
        payForUnpaidOrderBtn.setOnClickListener(this);
        allOrderSelectCheckBox.setOnClickListener(this);
        allOrderSelectCheckBox.setBackgroundResource(R.drawable.no_select_all_btn);
        isAllItemSelect = false;
        listItemClick = new ListItemClick() {
            @Override
            public void onClick(View item, View widget, int position, int which) {

            }

            @Override
            public void allOrderSelectProcess(int currentSelectCount) {
                // TODO Auto-generated method stub
                // 判断是否全选，若全部已选择则更新全选按钮的图标
                if (currentSelectCount == customerUnpaidOrderList.size()) {
                    allOrderSelectCheckBox.setBackgroundResource(R.drawable.select_all_btn);
                    isAllItemSelect = true;
                } else {
                    allOrderSelectCheckBox.setBackgroundResource(R.drawable.no_select_all_btn);
                    isAllItemSelect = false;
                }
            }
        };
        if (fromSource == Constant.USER_ROLE_CUSTOMER) {
            if (userinfoApplication.getSelectedCustomerID() == 0) {
                DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
            } else {
                requestWebService();
            }
        } else if (fromSource == Constant.USER_ROLE_BUSINESS) {
            requestWebService();
        }
    }

    private void requestWebService() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        orderManager = new OrderManager();
        OrderListConditionBuilder orderListConditionBuilder = new OrderListConditionBuilder();
        //从左侧结账列表页跳转过来
        if (fromSource == Constant.USER_ROLE_BUSINESS) {
            customerID = getIntent().getIntExtra("CustomerID", 0);
        }
        //从右侧选中顾客后查看其结账列表页
        else if (fromSource == Constant.USER_ROLE_CUSTOMER) {
            customerID = userinfoApplication.getSelectedCustomerID();
        }
        orderListConditionBuilder
                .setCustomerID(customerID);
        orderManager.getUnPaidOrderList(mHandler, orderListConditionBuilder.create(), userinfoApplication, branchID);
    }

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        switch (view.getId()) {
            case R.id.pay_for_unpaid_order_btn:
                Intent destIntent = new Intent(this, PaymentActionActivity.class);
                List<OrderInfo> paidOrderList = unpaidOrderListAdapter.getPaidOrderList();
                //判断是否有部分支付的订单
                boolean hasPartPayOrder = false;
                if (paidOrderList.size() > 1) {
                    for (OrderInfo orderInfo : paidOrderList) {
                        if (orderInfo.getPaymentStatus() == 3 || orderInfo.getPaymentStatus() == 2) {
                            hasPartPayOrder = true;
                            break;
                        }
                    }
                }
                //选择的订单数量为0时
                if (paidOrderList.size() == 0)
                    DialogUtil.createShortDialog(this, "请选择要支付的订单");
                else if (hasPartPayOrder) {
                    DialogUtil.createShortDialog(this, "部分支付的订单不能和其他订单一起支付!");
                } else {
                    int paidOrderCount = paidOrderList.size();
                    destIntent.putExtra("CUSTOMER_ID", customerID);
                    destIntent.putExtra("PAID_ORDER_COUNT", paidOrderCount);
                    destIntent.putExtra("userRole", fromSource);
                    destIntent.putExtra("paidOrderList", (Serializable) paidOrderList);
                    startActivity(destIntent);
                }
                break;
            case R.id.customer_unpaid_order_customer_convert:
                List<OrderInfo> convertOrderList = unpaidOrderListAdapter.getPaidOrderList();
                boolean hasPaidOrder = false;
                if (convertOrderList.size() > 1) {
                    for (OrderInfo orderInfo : convertOrderList) {
                        if (orderInfo.getPaymentStatus() != 1) {
                            hasPaidOrder = true;
                            break;
                        }
                    }
                }
                if (convertOrderList == null || convertOrderList.size() == 0) {
                    DialogUtil.createShortDialog(this, "请选择要转换的订单！");
                } else if (hasPaidOrder) {
                    DialogUtil.createShortDialog(this, "已支付的订单不能进行转换！");
                } else {
                    //顾客转换
                    destIntent = new Intent(this, CustomerActivity.class);
                    //表示我当前的动作是跳转到顾客列表页要进行订单转换
                    destIntent.putExtra("fromSource", 3);
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("convertOrderList", (Serializable) convertOrderList);
                    destIntent.putExtras(bundle);
                    startActivity(destIntent);
                }
                break;
            case R.id.select_all_unpaid_order:
                //全选
                if (isAllItemSelect) {
                    view.setBackgroundResource(R.drawable.no_select_all_btn);
                    unpaidOrderListAdapter.setAllUnpaidOrderUnSelect();
                    isAllItemSelect = false;
                }
                //取消全选
                else {
                    view.setBackgroundResource(R.drawable.select_all_btn);
                    unpaidOrderListAdapter.setAllUnpaidOrderSelect();
                    isAllItemSelect = true;
                }
                unpaidOrderListAdapter.notifyDataSetChanged();
                break;
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            mHandler = null;
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

    public interface ListItemClick {
        void onClick(View item, View widget, int position, int which);

        void allOrderSelectProcess(int currentSelectCount);
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position,
                            long id) {
        // TODO Auto-generated method stub
        OrderInfo orderInfo = customerUnpaidOrderList.get(position);
        Bundle bundle = new Bundle();
        bundle.putSerializable("orderInfo", orderInfo);
        Intent destIntent = new Intent(this, OrderDetailActivity.class);
        destIntent.putExtra("userRole", fromSource);
        destIntent.putExtra("FromOrderList", true);
        destIntent.putExtras(bundle);
        startActivity(destIntent);
    }
}
