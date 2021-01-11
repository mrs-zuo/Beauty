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
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableLayout.LayoutParams;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AppointmentDetailInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.SubService;
import com.GlamourPromise.Beauty.bean.Treatment;
import com.GlamourPromise.Beauty.bean.TreatmentGroup;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.sign.HandwritingActivity;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

@SuppressLint("ResourceType")
public class ProductAndOldOrderListActivity extends BaseActivity implements OnClickListener {
    private ProductAndOldOrderListActivityHandler mHandler = new ProductAndOldOrderListActivityHandler(this);
    private TextView prepareOrderCustomerText;
    private LinearLayout serviceOrderListView, commodityOrderListView;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private LayoutInflater layoutInflater;
    private PackageUpdateUtil packageUpdateUtil;
    private List<OrderInfo> serviceOrderList = new ArrayList<OrderInfo>();//服务订单
    private List<OrderInfo> commodityOrderList = new ArrayList<OrderInfo>();//商品订单
    private JSONArray orderListArray = new JSONArray();
    private ArrayList<String> listOrderId = new ArrayList<String>();
    private Button opportuityDispatchOrderBtn;
    private String childItem[] = new String[]{"选择员工", "指定", "删除"};
    private String item[] = new String[]{"选择顾问", "全部指定"};
    private List<OrderProduct> orderProductList;
    private int orderOperationIndex, orderTreatmentGroupOperationIndex, orderTreatmentOperationIndex;
    private List<OrderInfo> orderInfoList = new ArrayList<OrderInfo>();//保存的当期开单的集合
    int fromSource;
    long taskID;
    AppointmentDetailInfo appointmentOrderInfo;
    private boolean isTotalDesignated = false;
    private JSONArray orderProductArray;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_product_old_order_list);
        userinfoApplication = UserInfoApplication.getInstance();
        // 初始化数据信息
        initData();
        //开小单前获取信息
        Intent listOrderIdIntent = getIntent();
        listOrderId = (ArrayList<String>) listOrderIdIntent.getStringArrayListExtra("orderIdList");
        taskID = listOrderIdIntent.getLongExtra("TaskID", 0);
        appointmentOrderInfo = (AppointmentDetailInfo) listOrderIdIntent.getSerializableExtra("appointmentDetailInfo");
        requestNewestOrderInfo(listOrderId);
    }

    private static class ProductAndOldOrderListActivityHandler extends Handler {
        private final ProductAndOldOrderListActivity productAndOldOrderListActivity;

        private ProductAndOldOrderListActivityHandler(ProductAndOldOrderListActivity activity) {
            WeakReference<ProductAndOldOrderListActivity> weakReference = new WeakReference<ProductAndOldOrderListActivity>(activity);
            productAndOldOrderListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (productAndOldOrderListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (productAndOldOrderListActivity.progressDialog != null) {
                productAndOldOrderListActivity.progressDialog.dismiss();
                productAndOldOrderListActivity.progressDialog = null;
            }
            if (msg.what == 0) {
                String message = (String) msg.obj;
                DialogUtil.createMakeSureDialog(productAndOldOrderListActivity, "提示信息", message);
            } else if (msg.what == -1) {
                DialogUtil.createMakeSureDialog(productAndOldOrderListActivity, "提示信息", "您的网络貌似不给力，请重试！");
            }
            //下单成功
            else if (msg.what == 2) {
                DialogUtil.createShortDialog(productAndOldOrderListActivity, (String) msg.obj);
                if (productAndOldOrderListActivity.orderProductList != null && productAndOldOrderListActivity.orderProductList.size() > 0)
                    productAndOldOrderListActivity.orderProductList.clear();
                int orderCount = productAndOldOrderListActivity.orderInfoList.size();
                if (productAndOldOrderListActivity.orderInfoList.size() > 0 && productAndOldOrderListActivity.orderInfoList.get(0).getTreatmentGroupList() != null) {
                    for (int i = 0; i < productAndOldOrderListActivity.orderInfoList.get(0).getTreatmentGroupList().size(); i++) {
                        if (productAndOldOrderListActivity.orderInfoList.get(0).getTreatmentGroupList().get(i).getTreatmentList() != null) {
                            for (int j = productAndOldOrderListActivity.orderInfoList.get(0).getTreatmentGroupList().get(i).getTreatmentList().size() - 1; j >= 0; j--) {
                                if (productAndOldOrderListActivity.orderInfoList.get(0).getTreatmentGroupList().get(i).getTreatmentList().get(j).getDelflag() == 1) {
                                    productAndOldOrderListActivity.orderInfoList.get(0).getTreatmentGroupList().get(i).getTreatmentList().remove(j);
                                }
                            }
                        }
                    }
                }
                Intent destIntent = null;
                //单条订单跳转订单详细页
                if (orderCount == 1) {
                    destIntent = new Intent(productAndOldOrderListActivity, OrderDetailActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("orderInfo", productAndOldOrderListActivity.orderInfoList.get(0));
                    destIntent.putExtras(bundle);
                    destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                    destIntent.putExtra("FromOrderList", true);
                }
                //多个订单跳转订单结单页
                else if (orderCount > 1)
                    destIntent = new Intent(productAndOldOrderListActivity, UnfishTGListActivity.class);
                productAndOldOrderListActivity.startActivity(destIntent);
                productAndOldOrderListActivity.finish();
            }
            // 从服务器端成功获取最新商品和服务信息
            else if (msg.what == 3) {
                if (productAndOldOrderListActivity.orderInfoList.size() < 1) {
                    Dialog dialog = new AlertDialog.Builder(productAndOldOrderListActivity, R.style.CustomerAlertDialog)
                            .setTitle(productAndOldOrderListActivity.getString(R.string.delete_dialog_title))
                            .setMessage("服务次数已达到最大值！")
                            .setPositiveButton(productAndOldOrderListActivity.getString(R.string.delete_confirm), new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    productAndOldOrderListActivity.finish();
                                }
                            }).create();
                    dialog.show();
                    dialog.setCancelable(false);
                }
                productAndOldOrderListActivity.initView();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(productAndOldOrderListActivity, productAndOldOrderListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(productAndOldOrderListActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + productAndOldOrderListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(productAndOldOrderListActivity);
                productAndOldOrderListActivity.packageUpdateUtil = new PackageUpdateUtil(productAndOldOrderListActivity, productAndOldOrderListActivity.mHandler, fileCache, downloadFileUrl, false, productAndOldOrderListActivity.userinfoApplication);
                productAndOldOrderListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                productAndOldOrderListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = productAndOldOrderListActivity.getFileStreamPath(filename);
                file.getName();
                productAndOldOrderListActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (productAndOldOrderListActivity.requestWebServiceThread != null) {
                productAndOldOrderListActivity.requestWebServiceThread.interrupt();
                productAndOldOrderListActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void requestNewestOrderInfo(ArrayList<String> listOrderId) {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        for (int i = 0; i < listOrderId.size(); i++) {
            orderListArray.put(Integer.parseInt(listOrderId.get(i).toString()));
        }
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetOrderInfoList";
                String endPoint = "Order";
                JSONObject getProductInfoJson = new JSONObject();
                try {
                    getProductInfoJson.put("listOrderID", orderListArray);
                } catch (JSONException e) {

                }
                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getProductInfoJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e) {
                }
                if (serverResultResult == null || serverResultResult.equals(""))
                    mHandler.sendEmptyMessage(-1);
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
                        JSONArray productArray = null;
                        JSONArray subServiceArray = null;
                        try {
                            productArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {

                        }
                        if (productArray != null) {
                            for (int i = 0; i < productArray.length(); i++) {
                                JSONObject productjson = null;
                                try {
                                    productjson = (JSONObject) productArray.get(i);
                                } catch (JSONException e) {
                                }
                                try {
                                    OrderInfo orderInfo = new OrderInfo();
                                    if (productjson.has("OrderID")) {
                                        orderInfo.setOrderID(productjson.getInt("OrderID"));
                                    }
                                    if (productjson.has("OrderObjectID")) {
                                        orderInfo.setOrderObejctID(productjson.getInt("OrderObjectID"));
                                    }
                                    if (productjson.has("ProductType")) {
                                        orderInfo.setProductType(productjson.getInt("ProductType"));
                                    }
                                    if (productjson.has("ProductName")) {
                                        orderInfo.setProductName(productjson.getString("ProductName"));
                                    }
                                    if (productjson.has("SubServiceIDs")) {
                                        orderInfo.setSubServiceIDs(productjson.getString("SubServiceIDs"));
                                    }
                                    if (productjson.has("ExecutingCount")) {
                                        orderInfo.setExecutingCount(productjson.getInt("ExecutingCount"));
                                    }
                                    if (productjson.has("FinishedCount")) {
                                        orderInfo.setCompleteCount(productjson.getInt("FinishedCount"));
                                    }
                                    if (productjson.has("TotalCount")) {
                                        orderInfo.setTotalCount(productjson.getInt("TotalCount"));
                                    }
                                    if (productjson.has("SurplusCount")) {
                                        orderInfo.setSurplusCount(productjson.getInt("SurplusCount"));
                                    }
                                    if (productjson.has("Remark")) {
                                        orderInfo.setOrderRemark(productjson.getString("Remark"));
                                    }
                                    if (productjson.has("AccountName") && !productjson.isNull("AccountName")) {
                                        orderInfo.setResponsiblePersonName(productjson.getString("AccountName"));
                                    }
                                    if (productjson.has("AccountID")) {
                                        orderInfo.setResponsiblePersonID(productjson.getInt("AccountID"));
                                    }
                                    int isConfirmed = 0;
                                    if (productjson.has("IsConfirmed") && !productjson.isNull("IsConfirmed"))
                                        isConfirmed = productjson.getInt("IsConfirmed");
                                    orderInfo.setIsConfirmed(isConfirmed);
                                    if (productjson.has("SubServiceList") && !productjson.isNull("SubServiceList")) {
                                        try {
                                            JSONObject subServiceobj = (JSONObject) productArray.get(i);
                                            subServiceArray = subServiceobj.getJSONArray("SubServiceList");
                                        } catch (JSONException e) {

                                        }
                                        if (subServiceArray != null) {
                                            ArrayList<SubService> subServiceList = new ArrayList<SubService>();
                                            for (int j = 0; j < subServiceArray.length(); j++) {
                                                SubService subService = new SubService();
                                                JSONObject subServiceJson = null;
                                                try {
                                                    subServiceJson = (JSONObject) subServiceArray.get(j);
                                                } catch (JSONException e) {
                                                }
                                                if (subServiceJson.has("SubServiceID")) {
                                                    subService.setSubServiceID(subServiceJson.getInt("SubServiceID"));
                                                }
                                                if (subServiceJson.has("SubServiceName")) {
                                                    subService.setSubServiceName(subServiceJson.getString("SubServiceName"));
                                                }
                                                subServiceList.add(subService);

                                            }
                                            orderInfo.setSubServiceList(subServiceList);
                                        }
                                    }
                                    if (productjson.getInt("TotalCount") != 0) {
                                        if (productjson.getInt("SurplusCount") > 0) {
                                            if (productjson.getInt("ProductType") == 1) {
                                                commodityOrderList.add(orderInfo);
                                            } else {
                                                serviceOrderList.add(orderInfo);
                                            }
                                            orderInfoList.add(orderInfo);
                                        }
                                    } else {
                                        if (productjson.getInt("ProductType") == 1) {
                                            commodityOrderList.add(orderInfo);
                                        } else {
                                            serviceOrderList.add(orderInfo);
                                        }
                                        orderInfoList.add(orderInfo);
                                    }
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                        Message msg = new Message();
                        msg.what = 3;
                        mHandler.sendMessage(msg);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 0;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();

    }

    private void initData() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        opportuityDispatchOrderBtn = (Button) findViewById(R.id.opportunity_dispatch_order_make_sure_btn);
        opportuityDispatchOrderBtn.setOnClickListener(this);
        userinfoApplication = UserInfoApplication.getInstance();
        layoutInflater = LayoutInflater.from(this);
        prepareOrderCustomerText = (TextView) findViewById(R.id.prepare_order_customer_text);
        serviceOrderListView = (LinearLayout) findViewById(R.id.service_order_list_view);
        commodityOrderListView = (LinearLayout) findViewById(R.id.commodity_order_list_view);
        Intent intent = getIntent();
        prepareOrderCustomerText.setText(userinfoApplication.getSelectedCustomerName());
        if (userinfoApplication.getOrderInfo() != null) {
            orderProductList = userinfoApplication.getOrderInfo().getOrderProductList();
        }
    }

    protected void initView() {
        if (serviceOrderList != null && serviceOrderList.size() > 0) {
            serviceOrderListView.removeAllViews();

            for (int i = 0; i < serviceOrderList.size(); i++) {
                final int orderServicePos = i;
                final OrderInfo orderServiceInfo = serviceOrderList.get(i);
                String TotalCount = "不限";
                if (orderServiceInfo.getTotalCount() != 0) {
                    TotalCount = String.valueOf(orderServiceInfo.getTotalCount());
                    if (orderServiceInfo.getSurplusCount() > 0) {
                        final View prepareOrderProductView = layoutInflater.inflate(R.xml.product_old_order_list, null);
                        final TableLayout.LayoutParams orderProductTableLP = new LayoutParams();
                        orderProductTableLP.topMargin = 10;
                        final TableLayout orderProductTableLayout = (TableLayout) prepareOrderProductView.findViewById(R.id.order_product_tablelayout);
                        orderProductTableLayout.setLayoutParams(orderProductTableLP);
                        final LinearLayout subServiceListView = (LinearLayout) prepareOrderProductView.findViewById(R.id.product_old_order_subService_list_item);
                        TextView prepareOrderProductNameText = (TextView) prepareOrderProductView.findViewById(R.id.product_old_order_name);
                        TextView prepareOrderResponsiblePersonNameText = (TextView) prepareOrderProductView.findViewById(R.id.prepare_order_reaponsible_name);
                        prepareOrderResponsiblePersonNameText.setText(orderServiceInfo.getResponsiblePersonName());
                        EditText productOldOrderRemark = (EditText) prepareOrderProductView.findViewById(R.id.product_old_order_remark);
                        productOldOrderRemark.setText(orderServiceInfo.getOrderRemark());
                        TextView productOldOrderListCompleteOrtotal = (TextView) prepareOrderProductView.findViewById(R.id.product_old_order_list_completeOrtotal);
                        final TextView productOldOrderListSurplusCount = (TextView) prepareOrderProductView.findViewById(R.id.product_old_order_list_surpluscount);
                        //开单次数显示的优化20170930
                        productOldOrderListCompleteOrtotal.setText("进行中" + orderServiceInfo.getExecutingCount() + "次/完成" + orderServiceInfo.getCompleteCount() + "次/共" + TotalCount + "次");
                        productOldOrderListSurplusCount.setText("剩余" + orderServiceInfo.getSurplusCount() + "次");
                        final Button productOldOrderSubserviceAdd = (Button) prepareOrderProductView.findViewById(R.id.product_old_order_subservice_add);
                        addSubService(productOldOrderListSurplusCount, productOldOrderSubserviceAdd, subServiceListView, orderServiceInfo, orderProductTableLP, orderServicePos);
                        productOldOrderSubserviceAdd.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (taskID != 0) {
                                    DialogUtil.createShortDialog(ProductAndOldOrderListActivity.this, "一次预约只能做一次服务");
                                } else {
                                    if ((orderServiceInfo.getSurplusCount() - orderServiceInfo.getTreatmentGroupList().size()) != 0) {
                                        addSubService(productOldOrderListSurplusCount, productOldOrderSubserviceAdd, subServiceListView, orderServiceInfo, orderProductTableLP, orderServicePos);
                                    } else {
                                        DialogUtil.createShortDialog(ProductAndOldOrderListActivity.this, "服务次数已到达最大值！");
                                    }
                                }
                            }
                        });
                        prepareOrderProductNameText.setText(orderServiceInfo.getProductName());
                        serviceOrderListView.addView(prepareOrderProductView);
                    }
                } else {
                    final View prepareOrderProductView = layoutInflater.inflate(R.xml.product_old_order_list, null);
                    final TableLayout.LayoutParams orderProductTableLP = new LayoutParams();
                    orderProductTableLP.topMargin = 10;
                    final TableLayout orderProductTableLayout = (TableLayout) prepareOrderProductView.findViewById(R.id.order_product_tablelayout);
                    orderProductTableLayout.setLayoutParams(orderProductTableLP);
                    final LinearLayout subServiceListView = (LinearLayout) prepareOrderProductView.findViewById(R.id.product_old_order_subService_list_item);
                    TextView prepareOrderProductNameText = (TextView) prepareOrderProductView.findViewById(R.id.product_old_order_name);
                    TextView prepareOrderResponsiblePersonNameText = (TextView) prepareOrderProductView.findViewById(R.id.prepare_order_reaponsible_name);
                    prepareOrderResponsiblePersonNameText.setText(orderServiceInfo.getResponsiblePersonName());
                    EditText productOldOrderRemark = (EditText) prepareOrderProductView.findViewById(R.id.product_old_order_remark);
                    productOldOrderRemark.setText(orderServiceInfo.getOrderRemark());
                    TextView productOldOrderListCompleteOrtotal = (TextView) prepareOrderProductView.findViewById(R.id.product_old_order_list_completeOrtotal);
                    final TextView productOldOrderListSurplusCount = (TextView) prepareOrderProductView.findViewById(R.id.product_old_order_list_surpluscount);
                    productOldOrderListCompleteOrtotal.setText("完成" + orderServiceInfo.getCompleteCount() + "次/" + TotalCount + "次");
                    productOldOrderListSurplusCount.setVisibility(View.GONE);
                    final Button productOldOrderSubserviceAdd = (Button) prepareOrderProductView.findViewById(R.id.product_old_order_subservice_add);
                    addSubService(productOldOrderListSurplusCount, productOldOrderSubserviceAdd, subServiceListView, orderServiceInfo, orderProductTableLP, orderServicePos);
                    productOldOrderSubserviceAdd.setOnClickListener(new OnClickListener() {

                        @Override
                        public void onClick(View v) {
                            if (taskID != 0) {
                                DialogUtil.createShortDialog(ProductAndOldOrderListActivity.this, "一次预约只能做一次服务");
                            } else {
                                addSubService(productOldOrderListSurplusCount, productOldOrderSubserviceAdd, subServiceListView, orderServiceInfo, orderProductTableLP, orderServicePos);
                            }
                        }
                    });
                    prepareOrderProductNameText.setText(orderServiceInfo.getProductName());
                    serviceOrderListView.addView(prepareOrderProductView);
                }
            }
        }
        if (commodityOrderList != null && commodityOrderList.size() != 0) {
            commodityOrderListView.removeAllViews();
            for (int i = 0; i < commodityOrderList.size(); i++) {
                final View productOldOrderStoreView = layoutInflater.inflate(R.xml.product_old_order_store_list, null);
                final TableLayout.LayoutParams orderProductTableLP = new LayoutParams();
                orderProductTableLP.topMargin = 10;
                final TableLayout orderProductStoreTableLayout = (TableLayout) productOldOrderStoreView.findViewById(R.id.commodity_order_product_tablelayout);
                orderProductStoreTableLayout.setLayoutParams(orderProductTableLP);
                final OrderInfo orderStoreInfo = commodityOrderList.get(i);

                TextView prepareOrderProductCommodityNameText = (TextView) productOldOrderStoreView.findViewById(R.id.product_old_order_commodity_name);
                prepareOrderProductCommodityNameText.setText(orderStoreInfo.getProductName());

                TextView prepareOrderResponsiblePersonNameText = (TextView) productOldOrderStoreView.findViewById(R.id.prepare_order_reaponsible_name_commodity);
                prepareOrderResponsiblePersonNameText.setText(orderStoreInfo.getResponsiblePersonName());
                EditText productOldOrderRemark = (EditText) productOldOrderStoreView.findViewById(R.id.product_old_order_remark_commodity);
                productOldOrderRemark.setText(orderStoreInfo.getOrderRemark());
                TextView productOldOrderListCompleteOrtotal = (TextView) productOldOrderStoreView.findViewById(R.id.product_old_order_list_completeOrtotal);
                TextView productOldOrderListSurplusCount = (TextView) productOldOrderStoreView.findViewById(R.id.product_old_order_list_surpluscount);
                productOldOrderListCompleteOrtotal.setText("已交" + orderStoreInfo.getCompleteCount() + "件/共" + orderStoreInfo.getTotalCount() + "件");
                productOldOrderListSurplusCount.setText("剩余" + orderStoreInfo.getSurplusCount() + "件");
                final ImageButton productOldOrderStoreIsFinish = (ImageButton) productOldOrderStoreView.findViewById(R.id.product_old_order_store_isfinish);
                EditText productOldOrderStoreCount = (EditText) productOldOrderStoreView.findViewById(R.id.product_old_order_store_count);
                productOldOrderStoreCount.setText(String.valueOf(orderStoreInfo.getSurplusCount()));
                productOldOrderStoreIsFinish.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (orderStoreInfo.isPayment()) {
                            productOldOrderStoreIsFinish.setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
                            orderStoreInfo.setPayment(false);
                        } else {
                            productOldOrderStoreIsFinish.setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
                            orderStoreInfo.setPayment(true);
                        }
                    }
                });
                commodityOrderListView.addView(productOldOrderStoreView);
            }
        }
    }

    private void addSubService(final TextView productOldOrderListSurplusCount, final Button productOldOrderSubserviceAdd, final LinearLayout subServiceListView, final OrderInfo orderServiceInfo, TableLayout.LayoutParams orderProductTableLP, final int orderServicePos) {


        List<TreatmentGroup> treatmentGroupList = orderServiceInfo.getTreatmentGroupList();
        if (treatmentGroupList == null)
            treatmentGroupList = new ArrayList<TreatmentGroup>();
        final View prepareOrderProductItemView = layoutInflater.inflate(R.xml.product_old_order_list_item, null);
        final TableLayout productOldOrderTablelayout = (TableLayout) prepareOrderProductItemView.findViewById(R.id.product_old_order_tablelayout);
        productOldOrderTablelayout.setLayoutParams(orderProductTableLP);
        final LinearLayout productOldOrderListItemSubService = (LinearLayout) prepareOrderProductItemView.findViewById(R.id.product_old_order_list_item_subService1);
        RelativeLayout productOldOrderResponsiblePersonRelativelayout = (RelativeLayout) prepareOrderProductItemView.findViewById(R.id.product_old_order_responsible_relativelayout);
        final TextView productOldOrderSubserviceReaponsibleName = (TextView) prepareOrderProductItemView.findViewById(R.id.product_old_order_reaponsible_name);
        final TextView productOldSubServiceNum = (TextView) prepareOrderProductItemView.findViewById(R.id.product_old_subService_num);
        productOldOrderTablelayout.setTag(treatmentGroupList.size());
        final TreatmentGroup tg = new TreatmentGroup();
        if (appointmentOrderInfo != null) {
            tg.setServicePicID(appointmentOrderInfo.getOrderInfo().getResponsiblePersonID());
        } else
            tg.setServicePicID(orderServiceInfo.getResponsiblePersonID());
        serviceOrderList.get(orderServicePos).setTreatmentGroupList(treatmentGroupList);
        //开单次数显示的优化20170930
        productOldSubServiceNum.setText("新开单" + String.valueOf(treatmentGroupList.size() + 1));
        productOldOrderResponsiblePersonRelativelayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                final int subServiceSize = tg.getTreatmentList().size();
                int j = 0;
                for (int k = 0; k < subServiceSize; k++) {
                    if (tg.getTreatmentList().get(k).isDesignated()) {
                        j++;
                    }
                }
                if (subServiceSize == j) {
                    isTotalDesignated = true;
                } else {
                    isTotalDesignated = false;
                }
                if (isTotalDesignated) {
                    item[1] = "全部取消指定";
                } else {
                    item[1] = "全部指定";
                }
                orderOperationIndex = orderServicePos;
                Dialog dialog = new AlertDialog.Builder(ProductAndOldOrderListActivity.this, R.style.CustomerAlertDialog)
                        .setTitle(getString(R.string.delete_dialog_title))
                        .setItems(item, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                switch (which) {
                                    case 0:
                                        orderTreatmentGroupOperationIndex = (Integer) productOldOrderTablelayout.getTag();
                                        Intent intent = new Intent(ProductAndOldOrderListActivity.this, ChoosePersonActivity.class);
                                        intent.putExtra("personRole", "Doctor");
                                        intent.putExtra("checkModel", "Single");
                                        JSONArray responsiblePersonArray = new JSONArray();
                                        responsiblePersonArray.put(orderServiceInfo.getResponsiblePersonID());
                                        intent.putExtra("selectPersonIDs", responsiblePersonArray.toString());
                                        intent.putExtra("customerID", userinfoApplication.getSelectedCustomerID());
                                        startActivityForResult(intent, 300);
                                        break;
                                    case 1:
                                        if (isTotalDesignated) {
                                            isTotalDesignated = false;
                                            for (int k = 0; k < subServiceSize; k++) {
                                                tg.getTreatmentList().get(k).setDesignated(false);
                                                productOldOrderListItemSubService.getChildAt(k).findViewById(R.id.product_old_order_is_designated_icon).setVisibility(View.GONE);
                                            }
                                        } else {
                                            isTotalDesignated = true;
                                            int subServiceSize = tg.getTreatmentList().size();
                                            for (int k = 0; k < subServiceSize; k++) {
                                                tg.getTreatmentList().get(k).setDesignated(true);
                                                productOldOrderListItemSubService.getChildAt(k).findViewById(R.id.product_old_order_is_designated_icon).setVisibility(View.VISIBLE);
                                            }
                                        }
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }).create();
                dialog.show();

            }
        });
        //服务带有子服务的情况
        if (orderServiceInfo.getSubServiceList() != null) {
            productOldOrderTablelayout.setVisibility(View.VISIBLE);
            if (appointmentOrderInfo != null) {
                productOldOrderSubserviceReaponsibleName.setText(appointmentOrderInfo.getOrderInfo().getResponsiblePersonName());
            } else
                productOldOrderSubserviceReaponsibleName.setText(orderServiceInfo.getResponsiblePersonName());

            final ArrayList<Treatment> treatmentList = new ArrayList<Treatment>();

            for (int j = 0; j < orderServiceInfo.getSubServiceList().size(); j++) {
                final int subservicePos = j;
                final View productOldOrderListItemSubServiceView = layoutInflater.inflate(R.xml.product_old_order_list_item_subservice, null);
                final ImageView subServiceIsDesignated = (ImageView) productOldOrderListItemSubServiceView.findViewById(R.id.product_old_order_is_designated_icon);
                TextView productOrderReaponsibleChildName = (TextView) productOldOrderListItemSubServiceView.findViewById(R.id.product_order_reaponsible_child_name);
                TextView productOldOrderSubserviceName = (TextView) productOldOrderListItemSubServiceView.findViewById(R.id.product_old_order_subservice_name);
                final RelativeLayout productOldOrderSubserviceRelativelayout = (RelativeLayout) productOldOrderListItemSubServiceView.findViewById(R.id.product_old_order_subservice_relativelayout);
                if (appointmentOrderInfo != null) {
                    productOrderReaponsibleChildName.setText(appointmentOrderInfo.getOrderInfo().getResponsiblePersonName());
                } else
                    productOrderReaponsibleChildName.setText(orderServiceInfo.getResponsiblePersonName());
                productOldOrderSubserviceName.setText(orderServiceInfo.getSubServiceList().get(j).getSubServiceName());
                final Treatment treatment = new Treatment();
                if (appointmentOrderInfo != null) {
                    treatment.setExecutorID(appointmentOrderInfo.getOrderInfo().getResponsiblePersonID());
                } else
                    treatment.setExecutorID(orderServiceInfo.getResponsiblePersonID());
                treatment.setSubServiceId(orderServiceInfo.getSubServiceList().get(j).getSubServiceID());
                treatmentList.add(treatment);
                tg.setTreatmentList(treatmentList);
                productOldOrderSubserviceRelativelayout.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        int subsize = 0;
                        for (int x = 0; x < tg.getTreatmentList().size(); x++) {
                            subsize += tg.getTreatmentList().get(x).getDelflag();
                        }

                        if (subsize != tg.getTreatmentList().size() - 1) {
                            childItem = new String[]{"选择员工", "指定", "删除"};
                            if (tg.getTreatmentList().get(subservicePos).isDesignated()) {
                                childItem[1] = "取消指定";
                            } else {
                                childItem[1] = "指定";
                            }
                        } else {
                            childItem = new String[]{"选择员工", "指定"};
                            if (tg.getTreatmentList().get(subservicePos).isDesignated()) {
                                childItem[1] = "取消指定";
                            } else {
                                childItem[1] = "指定";
                            }
                        }
                        orderOperationIndex = orderServicePos;
                        orderTreatmentOperationIndex = subservicePos;
                        Dialog dialog = new AlertDialog.Builder(ProductAndOldOrderListActivity.this, R.style.CustomerAlertDialog)
                                .setTitle(getString(R.string.delete_dialog_title))
                                .setItems(childItem, new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int which) {
                                        switch (which) {
                                            case 0:

                                                orderTreatmentGroupOperationIndex = (Integer) productOldOrderTablelayout.getTag();
                                                Intent intent = new Intent(ProductAndOldOrderListActivity.this, ChoosePersonActivity.class);
                                                intent.putExtra("personRole", "Doctor");
                                                intent.putExtra("checkModel", "Single");
                                                JSONArray responsiblePersonArray = new JSONArray();
                                                responsiblePersonArray.put(orderServiceInfo.getResponsiblePersonID());
                                                intent.putExtra("selectPersonIDs", responsiblePersonArray.toString());
                                                intent.putExtra("customerID", userinfoApplication.getSelectedCustomerID());
                                                startActivityForResult(intent, 1);
                                                break;
                                            case 1:
                                                if (tg.getTreatmentList().get(subservicePos).isDesignated()) {
                                                    tg.getTreatmentList().get(subservicePos).setDesignated(false);
                                                    subServiceIsDesignated.setVisibility(View.GONE);
                                                } else {
                                                    tg.getTreatmentList().get(subservicePos).setDesignated(true);
                                                    subServiceIsDesignated.setVisibility(View.VISIBLE);
                                                }
                                                break;
                                            case 2:
                                                if (tg.getTreatmentList().size() > 1) {
                                                    LinearLayout.LayoutParams linearParams = (LinearLayout.LayoutParams) productOldOrderListItemSubServiceView.getLayoutParams();
                                                    linearParams.height = 1;// 控件的高设成1
                                                    productOldOrderListItemSubServiceView.setLayoutParams(linearParams);
//                                		productOldOrderListItemSubService.removeView(productOldOrderListItemSubServiceView);
                                                    treatmentList.get(orderTreatmentOperationIndex).setDelflag(1);
                                                }

                                                break;
                                            default:
                                                break;
                                        }
                                    }
                                }).create();
                        dialog.show();
                    }
                });
                productOldOrderListItemSubService.addView(productOldOrderListItemSubServiceView);
            }


        }
        //如果该订单没有子服务 则是套盒的情况
        else {
            productOldOrderTablelayout.setVisibility(View.VISIBLE);
            if (appointmentOrderInfo != null) {
                productOldOrderSubserviceReaponsibleName.setText(appointmentOrderInfo.getOrderInfo().getResponsiblePersonName());
            } else
                productOldOrderSubserviceReaponsibleName.setText(orderServiceInfo.getResponsiblePersonName());
            final ArrayList<Treatment> treatmentList = new ArrayList<Treatment>();
            final View productOldOrderListItemSubServiceView = layoutInflater.inflate(R.xml.product_old_order_list_item_subservice, null);
            final ImageView subServiceIsDesignated = (ImageView) productOldOrderListItemSubServiceView.findViewById(R.id.product_old_order_is_designated_icon);
            TextView productOrderReaponsibleChildName = (TextView) productOldOrderListItemSubServiceView.findViewById(R.id.product_order_reaponsible_child_name);
            TextView productOldOrderSubserviceName = (TextView) productOldOrderListItemSubServiceView.findViewById(R.id.product_old_order_subservice_name);
            final RelativeLayout productOldOrderSubserviceRelativelayout = (RelativeLayout) productOldOrderListItemSubServiceView.findViewById(R.id.product_old_order_subservice_relativelayout);
            productOrderReaponsibleChildName.setText(orderServiceInfo.getResponsiblePersonName());
            productOldOrderSubserviceName.setText("服务操作");
            Treatment treatment = new Treatment();
            if (appointmentOrderInfo != null) {
                treatment.setExecutorID(appointmentOrderInfo.getOrderInfo().getResponsiblePersonID());
            } else
                treatment.setExecutorID(orderServiceInfo.getResponsiblePersonID());
            treatment.setSubServiceId(0);
            treatmentList.add(treatment);
            productOldOrderSubserviceRelativelayout.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    childItem = new String[]{"选择员工", "指定"};
                    if (tg.getTreatmentList().get(0).isDesignated()) {
                        childItem[1] = "取消指定";
                    } else {
                        childItem[1] = "指定";
                    }
                    orderOperationIndex = orderServicePos;
                    orderTreatmentOperationIndex = 0;
                    Dialog dialog = new AlertDialog.Builder(ProductAndOldOrderListActivity.this, R.style.CustomerAlertDialog)
                            .setTitle(getString(R.string.delete_dialog_title))
                            .setItems(childItem, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    switch (which) {
                                        case 0:
                                            orderTreatmentGroupOperationIndex = (Integer) productOldOrderTablelayout.getTag();
                                            Intent intent = new Intent(ProductAndOldOrderListActivity.this, ChoosePersonActivity.class);
                                            intent.putExtra("personRole", "Doctor");
                                            intent.putExtra("checkModel", "Single");
                                            JSONArray responsiblePersonArray = new JSONArray();
                                            responsiblePersonArray.put(orderServiceInfo.getResponsiblePersonID());
                                            intent.putExtra("selectPersonIDs", responsiblePersonArray.toString());
                                            startActivityForResult(intent, 1);
                                            break;
                                        case 1:
                                            if (tg.getTreatmentList().get(0).isDesignated()) {
                                                tg.getTreatmentList().get(0).setDesignated(false);
                                                subServiceIsDesignated.setVisibility(View.GONE);
                                            } else {
                                                tg.getTreatmentList().get(0).setDesignated(true);
                                                subServiceIsDesignated.setVisibility(View.VISIBLE);
                                            }
                                            break;
                                        default:
                                            break;
                                    }
                                }
                            }).create();
                    dialog.show();
                }
            });
            productOldOrderListItemSubService.addView(productOldOrderListItemSubServiceView);
            tg.setTreatmentList(treatmentList);
        }
        int surplusCount = 0;
        treatmentGroupList.add(tg);
        subServiceListView.addView(prepareOrderProductItemView);
        Button prepareOrderReduceQuantityBtn = (Button) prepareOrderProductItemView.findViewById(R.id.prepare_order_reduce_quantity_btn);
        prepareOrderReduceQuantityBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (taskID != 0) {
                    DialogUtil.createShortDialog(ProductAndOldOrderListActivity.this, "此次服务不能删除！");
                } else {
                    subServiceListView.removeView(prepareOrderProductItemView);
                    orderServiceInfo.getTreatmentGroupList().remove(orderTreatmentGroupOperationIndex);
                    if (subServiceListView.getChildCount() != 0) {
                        for (int i = 0; i < subServiceListView.getChildCount(); i++) {
                            //开单次数显示的优化20170930
                            ((TextView) subServiceListView.getChildAt(i).findViewById(R.id.product_old_subService_num)).setText("新开单" + String.valueOf(i + 1));
                        }
                    } else productOldSubServiceNum.setText("新开单" + String.valueOf(1));

                    if (orderServiceInfo.getTotalCount() != 0) {
                        productOldOrderListSurplusCount.setVisibility(View.VISIBLE);
                        productOldOrderListSurplusCount.setText("剩余" + (orderServiceInfo.getSurplusCount() - orderServiceInfo.getTreatmentGroupList().size()) + "次");
                    }
                }
            }
        });
        if (orderServiceInfo.getTotalCount() != 0) {
            surplusCount = orderServiceInfo.getSurplusCount() - orderServiceInfo.getTreatmentGroupList().size();
            productOldOrderListSurplusCount.setText("剩余" + surplusCount + "次");
        }
    }

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        switch (view.getId()) {
            //确定
            case R.id.prepare_order_commit:
                Intent prepareAndOldOrderit = new Intent(ProductAndOldOrderListActivity.this, ProductAndOldOrderListActivity.class);
                startActivity(prepareAndOldOrderit);
                break;
            //下单
            case R.id.opportunity_dispatch_order_make_sure_btn:
                if (orderInfoList.size() < 1) {
                    DialogUtil.createShortDialog(ProductAndOldOrderListActivity.this, "请选择服务/商品！");
                } else {
                    orderProductArray = new JSONArray();
                    if (commodityOrderList != null && commodityOrderList.size() > 0) {
                        orderList(commodityOrderList, orderProductArray);
                    }
                    if (serviceOrderList != null && serviceOrderList.size() > 0) {
//					for(int i=0; i<serviceOrderList.get(0).getTreatmentGroupList().size(); i++){
//						if (serviceOrderList.get(0).getTreatmentGroupList().get(i).getTreatmentList() != null) {
//							for(int j=serviceOrderList.get(0).getTreatmentGroupList().get(i).getTreatmentList().size() -1;j>=0; j--){
//								if(serviceOrderList.get(0).getTreatmentGroupList().get(i).getTreatmentList().get(j).getDelflag()==1){
//									serviceOrderList.get(0).getTreatmentGroupList().get(i).getTreatmentList().remove(j);
//								}
//							}
//						}
//					}
                        orderList(serviceOrderList, orderProductArray);
                    }
                    if (orderProductArray.length() > 0) {
                        checkConfirmed();
                    } else {
//				 int orderCount=orderInfoList.size();
                        Intent destIntent = null;
//					if(orderCount==1){
                        destIntent = new Intent(ProductAndOldOrderListActivity.this, OrderDetailActivity.class);
                        Bundle bundle = new Bundle();
                        bundle.putSerializable("orderInfo", orderInfoList.get(0));
                        destIntent.putExtras(bundle);
                        destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                        destIntent.putExtra("FromOrderList", true);
                        startActivity(destIntent);
//					}else if(orderCount >1){
//						destIntent=new Intent(ProductAndOldOrderListActivity.this,UnfishTGListActivity.class);
//						startActivity(destIntent);
//					}
                        if (orderProductList != null && orderProductList.size() > 0)
                            orderProductList.clear();
                        ProductAndOldOrderListActivity.this.finish();
                    }
                }
                break;
        }
    }

    //检测当前开单的小单里面有商品订单并且是立即交付 需要签字确认的
    private void checkConfirmed() {
        boolean isNeedSign = false;
        if (commodityOrderList != null && commodityOrderList.size() > 0) {
            for (OrderInfo orderInfo : commodityOrderList) {
                if (orderInfo.isPayment() && orderInfo.getIsConfirmed() == 2) {
                    isNeedSign = true;
                    break;
                }
            }
        }
        //跳转到电子签画面
        if (isNeedSign) {
            Intent handWriteIntent = new Intent();
            handWriteIntent.setClass(this, HandwritingActivity.class);
            startActivityForResult(handWriteIntent, 100);
        } else {
            addTreatGroup(null);
        }
    }

    //将开完的小单提交服务器
    private void addTreatGroup(final String signPic) {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "AddTreatGroup";
                String endPoint = "Order";
                JSONObject prepareOrderJson = new JSONObject();
                try {
                    prepareOrderJson.put("TGDetailList", orderProductArray);
                    //电子签的图片流和格式
                    if (signPic != null && !"".equals(signPic)) {
                        prepareOrderJson.put("ImageFormat", ".JPEG");
                        prepareOrderJson.put("SignImg", signPic);
                    }
                } catch (JSONException e) {
                }
                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, prepareOrderJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e) {
                }
                if (serverResultResult == null || serverResultResult.equals(""))
                    mHandler.sendEmptyMessage(-1);
                else {
                    String code = "0";
                    String message = "";
                    try {
                        code = resultJson.getString("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = "0";
                    }
                    if (Integer.parseInt(code) == 1) {
                        Message msg = new Message();
                        msg.what = 2;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(Integer.parseInt(code));
                    else if (Integer.parseInt(code) == -2) {
                        Message msg = new Message();
                        msg.what = 4;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    } else {
                        Message msg = new Message();
                        msg.what = 0;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    private void orderList(List<OrderInfo> orderList, JSONArray orderProductArray) {
        if (orderList.size() > 0 && orderList.get(0).getTreatmentGroupList() != null) {
            for (int i = 0; i < orderList.get(0).getTreatmentGroupList().size(); i++) {
                if (orderList.get(0).getTreatmentGroupList().get(i).getTreatmentList() != null) {
                    for (int j = orderList.get(0).getTreatmentGroupList().get(i).getTreatmentList().size() - 1; j >= 0; j--) {
                        if (orderList.get(0).getTreatmentGroupList().get(i).getTreatmentList().get(j).getDelflag() == 1) {
                            orderList.get(0).getTreatmentGroupList().get(i).getTreatmentList().remove(j);
                        }
                    }
                }
            }
        }
        for (int i = 0; i < orderList.size(); i++) {
            OrderInfo orderInfo = orderList.get(i);
            if (orderInfo.getProductType() == 1) {
                String count = ((EditText) commodityOrderListView.getChildAt(i).findViewById(R.id.product_old_order_store_count)).getText().toString();
                if (count != null && !(("").equals(count)) && Float.valueOf(count) > 0) {
                    JSONObject commodityOrderJson = new JSONObject();
                    try {
                        commodityOrderJson.put("TaskID", taskID);
                        commodityOrderJson.put("OrderID", orderInfo.getOrderID());
                        // 如果有销售顾问功能并且销售顾问不等于美丽顾问
                        commodityOrderJson.put("OrderObjectID", orderInfo.getOrderObejctID());
                        commodityOrderJson.put("ProductType", orderInfo.getProductType());
                        commodityOrderJson.put("ServicePIC", orderInfo.getResponsiblePersonID());
                        String orderProductRemark = "";
                        orderProductRemark = ((EditText) commodityOrderListView.getChildAt(i).findViewById(R.id.product_old_order_remark_commodity)).getText().toString();
                        if (orderProductRemark != null && !(("").equals(orderProductRemark))) {
                            commodityOrderJson.put("Remark", orderProductRemark);
                        } else {
                            commodityOrderJson.put("Remark", "");
                        }
                        commodityOrderJson.put("Count", Integer.parseInt(count));
                        commodityOrderJson.put("IsFinish", orderInfo.isPayment());
                    } catch (JSONException e) {
                    }
                    orderProductArray.put(commodityOrderJson);
                }
            } else {
                if (orderInfo.getTreatmentGroupList() != null && orderInfo.getTreatmentGroupList().size() > 0) {

                    for (int j = 0; j < orderInfo.getTreatmentGroupList().size(); j++) {
                        JSONObject orderProductJson = new JSONObject();
                        try {
                            orderProductJson.put("TaskID", taskID);
                            orderProductJson.put("OrderID", orderInfo.getOrderID());
                            orderProductJson.put("OrderObjectID", orderInfo.getOrderObejctID());
                            orderProductJson.put("ProductType", orderInfo.getProductType());
                            orderProductJson.put("ServicePIC", orderInfo.getTreatmentGroupList().get(j).getServicePicID());
                            String orderProductRemark = "";
                            if (orderInfo.getProductType() == 1) {
                                orderProductRemark = ((EditText) commodityOrderListView.getChildAt(i).findViewById(R.id.product_old_order_remark_commodity)).getText().toString();
                                if (orderProductRemark != null && !(("").equals(orderProductRemark))) {
                                    orderProductJson.put("Remark", orderProductRemark);
                                } else {
                                    orderProductJson.put("Remark", "");
                                }
                                orderProductJson.put("IsFinish", orderInfo.isPayment());
                            } else {
                                orderProductRemark = ((EditText) serviceOrderListView.getChildAt(i).findViewById(R.id.product_old_order_remark)).getText().toString();
                                if (orderProductRemark != null && !(("").equals(orderProductRemark))) {
                                    orderProductJson.put("Remark", orderProductRemark);
                                } else {
                                    orderProductJson.put("Remark", "");
                                }
                                final JSONArray orderSubserviceArray = new JSONArray();
                                if (orderInfo.getTreatmentGroupList().size() != 0) {
                                    for (int k = 0; k < orderInfo.getTreatmentGroupList().get(j).getTreatmentList().size(); k++) {
                                        JSONObject orderSubserviceJson = new JSONObject();
//								if(orderInfo.getSubServiceList()!=null && orderInfo.getSubServiceList().size()>0)
//									orderSubserviceJson.put("SubServiceID",orderInfo.getSubServiceList().get(k).getSubServiceID());
//								else
//									orderSubserviceJson.put("SubServiceID",0);
                                        orderSubserviceJson.put("SubServiceID", orderInfo.getTreatmentGroupList().get(j).getTreatmentList().get(k).getSubServiceId());
                                        orderSubserviceJson.put("ExecutorID", orderInfo.getTreatmentGroupList().get(j).getTreatmentList().get(k).getExecutorID());
                                        orderSubserviceJson.put("IsDesignated", orderInfo.getTreatmentGroupList().get(j).getTreatmentList().get(k).isDesignated());
                                        orderSubserviceArray.put(orderSubserviceJson);
                                    }
                                    orderProductJson.put("TreatmentList", orderSubserviceArray);
                                }
                            }
                        } catch (JSONException e) {
                        }
                        orderProductArray.put(orderProductJson);
                    }
                }
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub

        View orderTableLayoutView = null;
        TableLayout orderTreatmentGroupRelativelayout = null;
        LinearLayout subserviceChildLinearLayout = null;
        View subserviceView = null;
        //选择服务顾问成功返回  并且判断不是电子签字成功返回
        if (requestCode != 100) {
            orderTableLayoutView = serviceOrderListView.getChildAt(orderOperationIndex);
            orderTreatmentGroupRelativelayout = (TableLayout) orderTableLayoutView.findViewWithTag(orderTreatmentGroupOperationIndex);
            subserviceChildLinearLayout = (LinearLayout) orderTreatmentGroupRelativelayout.findViewById(R.id.product_old_order_list_item_subService1);
            subserviceView = subserviceChildLinearLayout.getChildAt(orderTreatmentOperationIndex);
        }
        if (resultCode == RESULT_OK) {
            // 换TG服务顾问
            if (requestCode == 300) {
                final int newResponsiblePersonID = data.getIntExtra("personId", 0);
                String personName = data.getStringExtra("personName");
                if (newResponsiblePersonID == 0) {
                    ((TextView) orderTreatmentGroupRelativelayout.findViewById(R.id.product_old_order_reaponsible_name)).setText("");
                } else if (newResponsiblePersonID != 0) {
                    ((TextView) orderTreatmentGroupRelativelayout.findViewById(R.id.product_old_order_reaponsible_name)).setText(personName);
                }
                serviceOrderList.get(orderOperationIndex).getTreatmentGroupList().get(orderTreatmentGroupOperationIndex).setServicePicID(newResponsiblePersonID);
                serviceOrderList.get(orderOperationIndex).getTreatmentGroupList().get(orderTreatmentGroupOperationIndex).setServicePicName(personName);
                if (serviceOrderList.get(orderOperationIndex).getSubServiceList() != null) {
                    for (int j = 0; j < serviceOrderList.get(orderOperationIndex).getSubServiceList().size(); j++) {
                        serviceOrderList.get(orderOperationIndex).getTreatmentGroupList().get(orderTreatmentGroupOperationIndex).getTreatmentList().get(j).setExecutorID(newResponsiblePersonID);
                        View subserviceView1 = subserviceChildLinearLayout.getChildAt(j);
                        if (subserviceView1 != null)
                            ((TextView) subserviceView1.findViewById(R.id.product_order_reaponsible_child_name)).setText(personName);
                    }
                } else {
                    serviceOrderList.get(orderOperationIndex).getTreatmentGroupList().get(orderTreatmentGroupOperationIndex).getTreatmentList().get(orderTreatmentOperationIndex).setExecutorID(newResponsiblePersonID);
                    if (subserviceView != null)
                        ((TextView) subserviceView.findViewById(R.id.product_order_reaponsible_child_name)).setText(personName);
                }
            } else if (requestCode == 1) {
                final int newResponsiblePersonID = data.getIntExtra("personId", 0);
                serviceOrderList.get(orderOperationIndex).getTreatmentGroupList().get(orderTreatmentGroupOperationIndex).getTreatmentList().get(orderTreatmentOperationIndex).setExecutorID(newResponsiblePersonID);
                if (newResponsiblePersonID == 0) {
                    ((TextView) subserviceView.findViewById(R.id.product_order_reaponsible_child_name)).setText("");
                } else if (newResponsiblePersonID != 0) {
                    String personName = data.getStringExtra("personName");
                    ((TextView) subserviceView.findViewById(R.id.product_order_reaponsible_child_name)).setText(personName);
                }
            } else if (requestCode == 100) {
                String signPic = data.getStringExtra("signPic");
                addTreatGroup(signPic);
            }
        }
    }

    @Override
    protected void onDestroy() {
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
}
