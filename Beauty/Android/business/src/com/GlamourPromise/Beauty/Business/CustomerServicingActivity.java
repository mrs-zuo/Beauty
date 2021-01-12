package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.CustomerServicingFragmentAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.FlyMessage;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.fragment.DispenseCompleteOrderFragment;
import com.GlamourPromise.Beauty.fragment.DispenseCustomerOldOrderFragment;
import com.GlamourPromise.Beauty.fragment.DispenseFavoriteListFragment;
import com.GlamourPromise.Beauty.fragment.DispenseOrderFragment;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.StringUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.menu.BusinessRightMenu;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/*
 * 顾客服务页面
 * */
public class CustomerServicingActivity extends FragmentActivity implements OnClickListener {
    private CustomerServicingActivityHandler mHandler = new CustomerServicingActivityHandler(this);
    private List<Fragment> fragmentList = new ArrayList<Fragment>();// 保存碎片的集合
    private ViewPager customerServicingOrderViewPager;// 显示顾客的待开 待结 存单
    private DispenseOrderFragment dispenseOrderFragment;// 待开
    private DispenseCompleteOrderFragment dispenseCompleteOrderFragment;// 待结
    private DispenseCustomerOldOrderFragment dispenseCustomerOldOrderFragment;// 存单
    private DispenseFavoriteListFragment dispenseFavoriteListFragment;// 收藏
    private CustomerServicingFragmentAdapter customerServicingFragmentAdapter;
    private TextView tabPrepareOrderTitle, tabCompleteOrderTitle, tabCustomerOldOrderTitle, tabFavoriteListTitle;
    private LinearLayout tabPrepareOrderll, tabCompleteOrderll, tabCustomerOldOrderll, tabFavoriteListll;
    private Button customerServicingCustomerPaidOrderBtn;
    private UserInfoApplication userinfoApplication;
    private ImageView customerServicingCustomerHeadImageView;
    private ImageLoader imageLoader;
    private DisplayImageOptions displayImageOptions;
    private int currentItem;
    private RelativeLayout customerServicingSelectedCustomerRelativelayout, customerServicingNoSelectedCustomerRelativelayout;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private ImageView customerServicingAddNewCustomerBtn, customerServicingSearchBtn;
    private EditText customerServicingSearchCustomerEditText;
    private int fromSource, customerScdlCount = 0, customerUnpaidCount = 0;
    private static final int CUSTOMER_SERVICE = 1;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_servicing);
        initView();
    }

    private static class CustomerServicingActivityHandler extends Handler {
        private final CustomerServicingActivity customerServicingActivity;

        private CustomerServicingActivityHandler(CustomerServicingActivity activity) {
            WeakReference<CustomerServicingActivity> weakReference = new WeakReference<CustomerServicingActivity>(activity);
            customerServicingActivity = weakReference.get();
        }

        @SuppressLint("Range")
        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (customerServicingActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerServicingActivity.requestWebServiceThread != null) {
                customerServicingActivity.requestWebServiceThread.interrupt();
                customerServicingActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                customerServicingActivity.imageLoader = ImageLoader.getInstance();
                int authAllCustomerContactInfoWrite = customerServicingActivity.userinfoApplication.getAccountInfo().getAuthAllCustomerContactInfoWrite();
                String loginMobile = customerServicingActivity.userinfoApplication.getSelectedCustomerLoginMobile();
                //如果有编辑所有顾客的联系信息权限或者是当前账号是该顾客的专属顾问
                if (authAllCustomerContactInfoWrite == 1 || (customerServicingActivity.userinfoApplication.getSelectedCustomerResponsiblePersonID() == customerServicingActivity.userinfoApplication.getAccountInfo().getAccountId())) {
                    ((TextView) customerServicingActivity.findViewById(R.id.customer_servicing_customer_login_mobile)).setText(loginMobile);
                } else {
                    ((TextView) customerServicingActivity.findViewById(R.id.customer_servicing_customer_login_mobile)).setText(StringUtil.replaceCustomerLoginMobile(loginMobile));
                }
                int authAllCustomerInfoWrite = customerServicingActivity.userinfoApplication.getAccountInfo().getAuthAllCustomerInfoWrite();
                if (authAllCustomerInfoWrite == 1 || (customerServicingActivity.userinfoApplication.getSelectedCustomerResponsiblePersonID() == customerServicingActivity.userinfoApplication.getAccountInfo().getAccountId())) {
                    customerServicingActivity.findViewById(R.id.customer_servicing_customer_detail).setOnClickListener(customerServicingActivity);
                } else {
                    ((ImageView) customerServicingActivity.findViewById(R.id.customer_servicing_customer_detail_icon)).setBackgroundResource(R.drawable.customer_servicing_customer_detail_icon_disabled);
                    ((TextView) customerServicingActivity.findViewById(R.id.customer_servicing_customer_detail)).setTextColor(customerServicingActivity.getResources().getColor(R.color.gray));
                    customerServicingActivity.findViewById(R.id.customer_servicing_customer_detail).setOnClickListener(null);
                }
                customerServicingActivity.displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
                ((TextView) customerServicingActivity.findViewById(R.id.customer_servicing_customer_name)).setText(customerServicingActivity.userinfoApplication.getSelectedCustomerName());
                customerServicingActivity.imageLoader.displayImage(customerServicingActivity.userinfoApplication.getSelectedCustomerHeadImageURL(), customerServicingActivity.customerServicingCustomerHeadImageView, customerServicingActivity.displayImageOptions);
                int authMyOrderRead = customerServicingActivity.userinfoApplication.getAccountInfo().getAuthMyOrderRead();
                ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_paid_order_btn)).setText("结账(" + customerServicingActivity.customerUnpaidCount + ")");
                ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_appointment_btn)).setText("预约(" + customerServicingActivity.customerScdlCount + ")");
                if (authMyOrderRead == 0) {
                    ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_appointment_btn)).getBackground().setAlpha(75);
                    ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_appointment_btn)).setOnClickListener(null);
                    ((ImageView) customerServicingActivity.findViewById(R.id.cutomer_servicing_photo)).getBackground().setAlpha(75);
                    ((ImageView) customerServicingActivity.findViewById(R.id.cutomer_servicing_photo)).setOnClickListener(null);
                } else {
                    ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_appointment_btn)).setOnClickListener(customerServicingActivity);
                    ((ImageView) customerServicingActivity.findViewById(R.id.cutomer_servicing_photo)).getBackground().setAlpha(-1);
                    ((ImageView) customerServicingActivity.findViewById(R.id.cutomer_servicing_photo)).setOnClickListener(customerServicingActivity);
                }
                int authPaymentUse = customerServicingActivity.userinfoApplication.getAccountInfo().getAuthPaymentUse();
                if (authPaymentUse == 0) {
                    ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_paid_order_btn)).getBackground().setAlpha(75);
                    ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_paid_order_btn)).setOnClickListener(null);
                } else
                    ((Button) customerServicingActivity.findViewById(R.id.customer_servicing_customer_paid_order_btn)).setOnClickListener(customerServicingActivity);

                BusinessRightMenu.createMenuContent();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerServicingActivity, customerServicingActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerServicingActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerServicingActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerServicingActivity);
                customerServicingActivity.packageUpdateUtil = new PackageUpdateUtil(customerServicingActivity, customerServicingActivity.mHandler, fileCache, downloadFileUrl, false, customerServicingActivity.userinfoApplication);
                customerServicingActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerServicingActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = customerServicingActivity.getFileStreamPath(filename);
                file.getName();
                customerServicingActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    // 初始化视图
    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        //判断没有查看顾客的e卡权限
        int authEcardRead = userinfoApplication.getAccountInfo().getAuthEcardRead();
        ((TextView) findViewById(R.id.customer_servicing_customer_ecard)).setOnClickListener(this);
        if (authEcardRead == 0) {
            ((TextView) findViewById(R.id.customer_servicing_customer_ecard)).setTextColor(getResources().getColor(R.color.gray));
            ((ImageView) findViewById(R.id.customer_servicing_customer_ecard_icon)).setBackgroundResource(R.drawable.customer_servicing_customer_ecard_icon_disabled);
            ((TextView) findViewById(R.id.customer_servicing_customer_ecard)).setOnClickListener(null);
        }
        ((TextView) findViewById(R.id.customer_servicing_customer_order)).setOnClickListener(this);
        //查看顾客的统计信息
        findViewById(R.id.customer_servicing_customer_statis).setOnClickListener(this);
        //使用飞语的权限
        int chatUse = userinfoApplication.getAccountInfo().getAuthChatUse();
        if (chatUse == 1) {
            ((ImageView) findViewById(R.id.cutomer_servicing_send_message)).setOnClickListener(this);
        } else if (chatUse == 0) {
            ((ImageView) findViewById(R.id.cutomer_servicing_send_message)).getBackground().setAlpha(75);
            ((ImageView) findViewById(R.id.cutomer_servicing_send_message)).setOnClickListener(null);
        }
        //显示顾客的头像
        customerServicingCustomerHeadImageView = (ImageView) findViewById(R.id.customer_servicing_cutomer_headimage);
        customerServicingOrderViewPager = (ViewPager) findViewById(R.id.customer_servicing_order_view_pager);

        customerServicingCustomerPaidOrderBtn = (Button) findViewById(R.id.customer_servicing_customer_paid_order_btn);
        customerServicingCustomerPaidOrderBtn.setOnClickListener(this);

        //顾客相册
        ((ImageView) findViewById(R.id.cutomer_servicing_photo)).setOnClickListener(this);
        //结账权限
        int authPaymentUse = userinfoApplication.getAccountInfo().getAuthPaymentUse();
        if (authPaymentUse == 0) {
            customerServicingCustomerPaidOrderBtn.getBackground().setAlpha(75);
            customerServicingCustomerPaidOrderBtn.setOnClickListener(null);
        } else if (authPaymentUse == 1) {
            customerServicingCustomerPaidOrderBtn.setVisibility(View.VISIBLE);
        }
        //查看顾客订单权限
        int authMyOrderRead = userinfoApplication.getAccountInfo().getAuthMyOrderRead();
        if (authMyOrderRead == 0) {
            //查看顾客的订单
            ((TextView) findViewById(R.id.customer_servicing_customer_order)).setTextColor(getResources().getColor(R.color.gray));
            ((ImageView) findViewById(R.id.customer_servicing_customer_order_icon)).setBackgroundResource(R.drawable.customer_servicing_customer_order_icon_disabled);
            ((TextView) findViewById(R.id.customer_servicing_customer_order)).setOnClickListener(null);
            //查看顾客的统计
            ((TextView) findViewById(R.id.customer_servicing_customer_statis)).setTextColor(getResources().getColor(R.color.gray));
            ((ImageView) findViewById(R.id.customer_servicing_customer_statis_icon)).setBackgroundResource(R.drawable.customer_servicing_customer_order_icon_disabled);
            ((TextView) findViewById(R.id.customer_servicing_customer_statis)).setOnClickListener(null);

        }
        customerServicingSelectedCustomerRelativelayout = (RelativeLayout) findViewById(R.id.customer_servicing_selected_customer_relativelayout);
        customerServicingNoSelectedCustomerRelativelayout = (RelativeLayout) findViewById(R.id.customer_servicing_no_selected_customer_relativelayout);
        customerServicingSearchCustomerEditText = (EditText) findViewById(R.id.customer_servicing_search_customer_search_edit_text);
        customerServicingAddNewCustomerBtn = (ImageView) findViewById(R.id.customer_servicing_add_new_customer_btn);
        customerServicingAddNewCustomerBtn.setOnClickListener(this);
        int authAllCustomerWrite = userinfoApplication.getAccountInfo().getAuthAllCustomerInfoWrite();
        if (authAllCustomerWrite == 0) {
            customerServicingAddNewCustomerBtn.setOnClickListener(null);
            customerServicingAddNewCustomerBtn.getBackground().setAlpha(75);
        }
        customerServicingSearchBtn = (ImageView) findViewById(R.id.customer_servicing_search_customer_btn);
        customerServicingSearchBtn.setOnClickListener(this);
        int authMyCustomerRead = userinfoApplication.getAccountInfo().getAuthMyCustomerRead();
        if (authMyCustomerRead == 0) {
            customerServicingSearchBtn.setOnClickListener(null);
            customerServicingSearchBtn.getBackground().setAlpha(75);
            customerServicingSearchCustomerEditText.setEnabled(false);
        }
        fromSource = getIntent().getIntExtra("fromSource", 0);
        resetView();
        dispenseOrderFragment = new DispenseOrderFragment();
        dispenseCompleteOrderFragment = new DispenseCompleteOrderFragment();
        dispenseCustomerOldOrderFragment = new DispenseCustomerOldOrderFragment();
        dispenseFavoriteListFragment = new DispenseFavoriteListFragment();
        fragmentList = new ArrayList<Fragment>();
        fragmentList.add(dispenseOrderFragment);
        fragmentList.add(dispenseCompleteOrderFragment);
        fragmentList.add(dispenseCustomerOldOrderFragment);
        fragmentList.add(dispenseFavoriteListFragment);
        currentItem = getIntent().getIntExtra("currentItem", 3);
        tabPrepareOrderTitle = (TextView) findViewById(R.id.tab_prepare_order_title);
        tabPrepareOrderll = (LinearLayout) findViewById(R.id.tab_prepare_order_ll);
        tabCompleteOrderTitle = (TextView) findViewById(R.id.tab_complete_order_title);
        tabCompleteOrderll = (LinearLayout) findViewById(R.id.tab_complete_order_ll);
        tabCustomerOldOrderTitle = (TextView) findViewById(R.id.tab_customer_old_order_title);
        tabCustomerOldOrderll = (LinearLayout) findViewById(R.id.tab_customer_old_order_ll);
        tabFavoriteListTitle = (TextView) findViewById(R.id.tab_favorite_title);
        tabFavoriteListll = (LinearLayout) findViewById(R.id.tab_favorite_ll);
        customerServicingFragmentAdapter = new CustomerServicingFragmentAdapter(this.getSupportFragmentManager(), fragmentList);
        customerServicingOrderViewPager.setAdapter(customerServicingFragmentAdapter);
        customerServicingOrderViewPager.setCurrentItem(currentItem);

        tabPrepareOrderTitle.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                customerServicingOrderViewPager.setCurrentItem(0, false);
            }
        });
        tabCompleteOrderTitle.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                customerServicingOrderViewPager.setCurrentItem(1, false);
            }
        });
        tabCustomerOldOrderTitle.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                customerServicingOrderViewPager.setCurrentItem(2, false);
            }
        });
        tabFavoriteListTitle.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                customerServicingOrderViewPager.setCurrentItem(3, false);
            }
        });
        customerServicingOrderViewPager
                .setOnPageChangeListener(new OnPageChangeListener() {
                    @Override
                    public void onPageSelected(int state) {
                        // TODO Auto-generated method stub
                    }

                    @Override
                    public void onPageScrolled(int position, float offset, int offsetPiexls) {
                        resetAllItem();
                        switch (position) {
                            case 0:
                                setCurrentItemBackground(tabPrepareOrderll, tabPrepareOrderTitle);
                                break;
                            case 1:
                                setCurrentItemBackground(tabCompleteOrderll, tabCompleteOrderTitle);
                                break;
                            case 2:
                                setCurrentItemBackground(tabCustomerOldOrderll, tabCustomerOldOrderTitle);
                                break;
                            case 3:
                                setCurrentItemBackground(tabFavoriteListll, tabFavoriteListTitle);
                                break;
                        }
                    }

                    @Override
                    public void onPageScrollStateChanged(int position) {
                        // TODO Auto-generated method stub
                    }
                });
        //如果选中了顾客
        if (userinfoApplication.getSelectedCustomerID() != 0)
            //获得顾客的最新信息
            getNewestCustomerInfo();
    }

    protected void getNewestCustomerInfo() {
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
                    }
                    if (code == 1) {
                        JSONObject customerBasicJson = null;
                        try {
                            customerBasicJson = customerBasicJsonObject.getJSONObject("Data");
                        } catch (JSONException e) {

                        }
                        String customerHeadImageURL = "";
                        String customerName = "";
                        String customerLoginMobile = "";
                        int responsiblePersonID = 0;
                        try {
                            if (customerBasicJson.has("HeadImageURL") && !customerBasicJson.isNull("HeadImageURL"))
                                customerHeadImageURL = customerBasicJson.getString("HeadImageURL");
                            if (customerBasicJson.has("CustomerName") && !customerBasicJson.isNull("CustomerName"))
                                customerName = customerBasicJson.getString("CustomerName");
                            if (customerBasicJson.has("LoginMobile") && !customerBasicJson.isNull("LoginMobile"))
                                customerLoginMobile = customerBasicJson.getString("LoginMobile");
                            if (customerBasicJson.has("ResponsiblePersonID") && !customerBasicJson.isNull("ResponsiblePersonID"))
                                responsiblePersonID = customerBasicJson.getInt("ResponsiblePersonID");
                            if (customerBasicJson.has("ScheduleCount") && !customerBasicJson.isNull("ScheduleCount"))
                                customerScdlCount = customerBasicJson.getInt("ScheduleCount");
                            if (customerBasicJson.has("ScheduleCount") && !customerBasicJson.isNull("ScheduleCount"))
                                customerScdlCount = customerBasicJson.getInt("ScheduleCount");
                            if (customerBasicJson.has("UnPaidCount") && !customerBasicJson.isNull("UnPaidCount"))
                                customerUnpaidCount = customerBasicJson.getInt("UnPaidCount");
                        } catch (JSONException e) {

                        }
                        userinfoApplication.setSelectedCustomerName(customerName);
                        userinfoApplication.setSelectedCustomerHeadImageURL(customerHeadImageURL);
                        userinfoApplication.setSelectedCustomerLoginMobile(customerLoginMobile);
                        userinfoApplication.setSelectedCustomerResponsiblePersonID(responsiblePersonID);
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void onRestart() {
        super.onRestart();
        if (userinfoApplication.getSelectedCustomerID() != 0)
            getNewestCustomerInfo();
    }

    ;

    protected void setCurrentItemBackground(LinearLayout currentItemLinearlayout, TextView currentItemText) {
        currentItemLinearlayout.setBackgroundColor(getResources().getColor(R.color.tab_title_text_color));
        currentItemText.setTextColor(Color.WHITE);
    }

    private void resetView() {
        //从菜单进来的  则显示新增和搜索
        if (fromSource == 1 || userinfoApplication.getSelectedCustomerID() == 0) {
            if (userinfoApplication.getSelectedCustomerID() == 0) {
                if (dispenseCompleteOrderFragment != null) {
                    dispenseCompleteOrderFragment.clearData();
                    tabCompleteOrderTitle.setText("待结(0)");
                }

                if (dispenseCustomerOldOrderFragment != null) {
                    dispenseCustomerOldOrderFragment.clearData();
                    tabCustomerOldOrderTitle.setText("存单(0)");
                }
            }
            customerServicingSelectedCustomerRelativelayout.setVisibility(View.GONE);
            customerServicingNoSelectedCustomerRelativelayout.setVisibility(View.VISIBLE);
        }
        //从菜单顾客姓名  订单详细  或者其他地方进  则显示顾客的详细信息
        else if (fromSource == 0 && userinfoApplication.getSelectedCustomerID() != 0) {
            customerServicingSelectedCustomerRelativelayout.setVisibility(View.VISIBLE);
            customerServicingNoSelectedCustomerRelativelayout.setVisibility(View.GONE);
        }
    }

    protected void resetAllItem() {
        tabPrepareOrderTitle.setTextColor(getResources().getColor(R.color.tab_title_text_color));
        tabPrepareOrderll.setBackgroundColor(getResources().getColor(R.color.white));
        tabCompleteOrderTitle.setTextColor(getResources().getColor(R.color.tab_title_text_color));
        tabCompleteOrderll.setBackgroundColor(getResources().getColor(R.color.white));
        tabCustomerOldOrderTitle.setTextColor(getResources().getColor(R.color.tab_title_text_color));
        tabCustomerOldOrderll.setBackgroundColor(getResources().getColor(R.color.white));
        tabFavoriteListTitle.setTextColor(getResources().getColor(R.color.tab_title_text_color));
        tabFavoriteListll.setBackgroundColor(getResources().getColor(R.color.white));
    }

    @Override
    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        fromSource = intent.getIntExtra("fromSource", 0);
        dispenseOrderFragment.setUserVisibleHint(true);
        resetView();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }

    //点击事件
    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        Intent destIntent = null;
        switch (view.getId()) {
            //结账
            case R.id.customer_servicing_customer_paid_order_btn:
                destIntent = new Intent(this, CustomerUnpaidOrderActivity.class);
                startActivity(destIntent);
                break;
            case R.id.customer_servicing_customer_detail:
                destIntent = new Intent(this, CustomerInfoActivity.class);
                startActivity(destIntent);
                break;
            case R.id.customer_servicing_add_new_customer_btn:
                destIntent = new Intent(this, AddNewCustomerActivity.class);
                destIntent.putExtra("fromSource", 1);
                startActivity(destIntent);
                break;
            case R.id.customer_servicing_search_customer_btn:
                destIntent = new Intent(this, CustomerActivity.class);
                String searchKeyWord = customerServicingSearchCustomerEditText.getText().toString();
                destIntent.putExtra("searchKeyWord", searchKeyWord);
                startActivity(destIntent);
                break;
            case R.id.customer_servicing_customer_ecard:
                destIntent = new Intent(this, CustomerEcardListActivity.class);
                startActivity(destIntent);
                break;
            case R.id.customer_servicing_customer_order:
                destIntent = new Intent(this, CustomerViewOrderActivity.class);
                startActivity(destIntent);
                break;
            case R.id.cutomer_servicing_send_message:
                Intent sendIntent = new Intent(this, FlyMessageDetailActivity.class);
                FlyMessage flyMessage = new FlyMessage();
                flyMessage.setCustomerID(userinfoApplication.getSelectedCustomerID());
                flyMessage.setCustomerName(userinfoApplication.getSelectedCustomerName());
                flyMessage.setAvailable(1);
                Bundle bundle = new Bundle();
                bundle.putSerializable("flyMessage", flyMessage);
                sendIntent.putExtras(bundle);
                sendIntent.putExtra("Des", "Detail");
                sendIntent.putExtra("Source", "Customer");
                startActivity(sendIntent);
                break;
            case R.id.customer_servicing_customer_appointment_btn:
                Intent appointmentIntent = new Intent(this, AppointmentListActivity.class);
                appointmentIntent.putExtra("customerID", userinfoApplication.getSelectedCustomerID());
                appointmentIntent.putExtra("customerName", userinfoApplication.getSelectedCustomerName());
                appointmentIntent.putExtra("FROM_SOURCE", "MENU_RIGHT");
                appointmentIntent.putExtra("SOURCE", CUSTOMER_SERVICE);
                startActivity(appointmentIntent);
                break;
            case R.id.customer_servicing_customer_statis:
                Intent customerStatisIntent = new Intent();
                customerStatisIntent.setClass(this, CustomerStatisticsMainActivity.class);
                startActivity(customerStatisIntent);
                break;
            case R.id.cutomer_servicing_photo:
                Intent customerPhotoIntent = new Intent();
                customerPhotoIntent.setClass(this, CustomerServicingPhotoActivity.class);
                startActivity(customerPhotoIntent);
                break;
        }
    }

    ;
}
