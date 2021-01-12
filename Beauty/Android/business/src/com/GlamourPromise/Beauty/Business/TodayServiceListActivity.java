package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.TodayServiceInfoListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo.OrderListConditionBuilder;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.manager.TodayServiceManager;
import com.GlamourPromise.Beauty.util.DateUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.XListView;
import com.GlamourPromise.Beauty.view.XListView.IXListViewListener;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@SuppressLint("ResourceType")
public class TodayServiceListActivity extends BaseActivity implements OnItemClickListener, OnClickListener, IXListViewListener {
    private TodayServiceListActivityHandler mHandler = new TodayServiceListActivityHandler(this);
    private List<OrderInfo> todayServiceList;
    private UserInfoApplication userInfoApplication;
    private XListView todayServiceListView;
    private PackageUpdateUtil packageUpdateUtil;
    private ImageView todayServiceFilterIcon;
    private TodayServiceManager todayServiceManager;
    private OrderListBaseConditionInfo orderBaseConditionInfo;
    private TodayServiceInfoListAdapter todayServiceInfoListAdapter;
    private int pageCount = 1;// 全部订单的页数
    private int pageIndex;
    private Boolean isRefresh = false;
    private int getTodayServiceListFlag;// 1:取最初的数据；2：取最新的数据；3：取老数据
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_today_service_list);
        initView();
    }

    private static class TodayServiceListActivityHandler extends Handler {
        private final TodayServiceListActivity todayServiceListActivity;

        private TodayServiceListActivityHandler(TodayServiceListActivity activity) {
            WeakReference<TodayServiceListActivity> weakReference = new WeakReference<TodayServiceListActivity>(activity);
            todayServiceListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (todayServiceListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            todayServiceListActivity.isRefresh = false;
            if (message.what == 1) {
                ArrayList<OrderInfo> tmpList = (ArrayList<OrderInfo>) message.obj;
                todayServiceListActivity.pageCount = message.arg2;
                //总页数不为0时显示
                TextView todayServicePageInfoText = (TextView) todayServiceListActivity.findViewById(R.id.today_service_page_info_text);
                if (todayServiceListActivity.pageCount != 0) {
                    todayServicePageInfoText.setText("(第" + todayServiceListActivity.pageIndex + "/" + todayServiceListActivity.pageCount + "页)");
                }
                //总页数为0时，则将订单页数信息置空
                else {
                    todayServicePageInfoText.setText("");
                }
                // 有老数据时，当前页数加一
                if (tmpList.size() > 0) {
                    //设置订单列表页数信息
                    todayServiceListActivity.pageIndex += 1;
                }
                if (todayServiceListActivity.getTodayServiceListFlag == 1 || todayServiceListActivity.getTodayServiceListFlag == 2) {
                    todayServiceListActivity.todayServiceList.clear();
                    todayServiceListActivity.todayServiceList.addAll(tmpList);
                } else if (todayServiceListActivity.getTodayServiceListFlag == 3 && tmpList != null && tmpList.size() > 0) {
                    todayServiceListActivity.todayServiceList.addAll(todayServiceListActivity.todayServiceList.size(), tmpList);
                } else if (todayServiceListActivity.getTodayServiceListFlag == 3 && (tmpList == null || tmpList.size() == 0)) {
                    todayServiceListActivity.todayServiceListView.hideFooterView();
                    DialogUtil.createShortDialog(todayServiceListActivity, "没有更早的服务！");
                }
                todayServiceListActivity.todayServiceInfoListAdapter.notifyDataSetChanged();
            } else if (message.what == 0) {
                if (todayServiceListActivity.getTodayServiceListFlag == 1 || todayServiceListActivity.getTodayServiceListFlag == 2) {
                    todayServiceListActivity.todayServiceList.clear();
                    todayServiceListActivity.todayServiceInfoListAdapter.notifyDataSetChanged();
                }
                String msg = (String) message.obj;
                DialogUtil.createShortDialog(todayServiceListActivity, msg);
            } else if (message.what == 2) {
                if (todayServiceListActivity.getTodayServiceListFlag == 1 || todayServiceListActivity.getTodayServiceListFlag == 2) {
                    todayServiceListActivity.todayServiceList.clear();
                    todayServiceListActivity.todayServiceInfoListAdapter.notifyDataSetChanged();
                }
                DialogUtil.createShortDialog(todayServiceListActivity, "您的网络貌似不给力，请重试");
            } else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(todayServiceListActivity, todayServiceListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(todayServiceListActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + todayServiceListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(todayServiceListActivity);
                todayServiceListActivity.packageUpdateUtil = new PackageUpdateUtil(todayServiceListActivity, todayServiceListActivity.mHandler, fileCache, downloadFileUrl, false, todayServiceListActivity.userInfoApplication);
                todayServiceListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                todayServiceListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = todayServiceListActivity.getFileStreamPath(filename);
                file.getName();
                todayServiceListActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            todayServiceListActivity.onLoad();
        }
    }

    protected void initView() {
        todayServiceListView = (XListView) findViewById(R.id.today_service_list_view);
        todayServiceListView.setOnItemClickListener(this);
        todayServiceFilterIcon = (ImageView) findViewById(R.id.today_service_search_new_btn);
        todayServiceFilterIcon.setOnClickListener(this);
        userInfoApplication = (UserInfoApplication) getApplication();
        todayServiceList = new ArrayList<OrderInfo>();
        todayServiceManager = new TodayServiceManager();
        orderBaseConditionInfo = new OrderListBaseConditionInfo();
        orderBaseConditionInfo.setProductType(-1);
        orderBaseConditionInfo.setStatus(-1);
        orderBaseConditionInfo.setAccountID(userInfoApplication.getAccountInfo().getAccountId());
        orderBaseConditionInfo.setCustomerID(0);
        orderBaseConditionInfo.setFilterByTimeFlag(1);
        orderBaseConditionInfo.setStartDate(DateUtil.getNowFormateDate2());
        orderBaseConditionInfo.setEndDate(DateUtil.getNowFormateDate2());
        todayServiceListView.setXListViewListener(this);
        todayServiceInfoListAdapter = new TodayServiceInfoListAdapter(this, todayServiceList);
        todayServiceListView.setAdapter(todayServiceInfoListAdapter);
        todayServiceListView.setPullLoadEnable(true);
        todayServiceList.clear();
        getLayoutInflater().inflate(R.xml.up_pull_load_more, null);
        initPageIndex();
        refreshList(1);
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // TODO Auto-generated method stub
        if (position != 0) {
            Intent destIntent = new Intent(this, OrderDetailActivity.class);
            OrderInfo orderInfo = todayServiceList.get(position - 1);
            Bundle bundle = new Bundle();
            bundle.putSerializable("orderInfo", orderInfo);
            destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
            destIntent.putExtra("FromOrderList", true);
            destIntent.putExtras(bundle);
            startActivity(destIntent);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        if (resultCode != 1)
            return;
        else {
            orderBaseConditionInfo = (OrderListBaseConditionInfo) data.getSerializableExtra("baseCondition");
            initPageIndex();
            refreshList(1);
        }
    }

    private void initPageIndex() {
        pageIndex = 1;
    }

    private void refreshList(int flag) {
        // 上一次取数据任务还没有完成，不在调用后台
        if (isRefresh)
            return;
        // 取老数据时，已经取完数据不在调用后台
        if (flag == 3 && (pageIndex > pageCount || todayServiceList.size() < 10)) {
            DialogUtil.createShortDialog(this, "没有更早的服务！");
            onLoad();
            todayServiceListView.hideFooterView();
            return;
        } else {
            todayServiceListView.setPullLoadEnable(true);
        }
        isRefresh = true;
        getTodayServiceListFlag = flag;
        OrderListConditionBuilder orderListConditionBuilder = new OrderListBaseConditionInfo.OrderListConditionBuilder();
        int currentPageIndex = 1;
        String createTime = "";
        if (getTodayServiceListFlag == 3) {
            currentPageIndex = pageIndex;
            //传服务列表的第一个创建时间
            if (currentPageIndex >= 1)
                createTime = todayServiceList.get(0).getOrderTime();
        } else if (getTodayServiceListFlag == 2) {
            initPageIndex();
        }
        orderListConditionBuilder.setAccountID(orderBaseConditionInfo.getAccountID())
                .setBranchID(0).setCreateTime(createTime).setPageIndex(currentPageIndex).setPageSize(10)
                .setProductType(orderBaseConditionInfo.getProductType())
                .setStatus(orderBaseConditionInfo.getStatus()).setCustomerID(orderBaseConditionInfo.getCustomerID()).setCreateTime(createTime)
                .setFilterByTimeFlag(orderBaseConditionInfo.getFilterByTimeFlag()).setStartDate(orderBaseConditionInfo.getStartDate()).setEndDate(orderBaseConditionInfo.getEndDate());
        todayServiceManager.getTodayServiceList(mHandler, orderListConditionBuilder.create(), userInfoApplication);
    }

    @SuppressWarnings("deprecation")
    private void onLoad() {
        todayServiceListView.stopRefresh();
        todayServiceListView.stopLoadMore();
        todayServiceListView.setRefreshTime(new Date().toLocaleString());
    }

    /**
     * 取最新数据
     */
    @Override
    public void onRefresh() {
        refreshList(2);
    }

    /**
     * 取老数据
     */
    @Override
    public void onLoadMore() {
        refreshList(3);
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        //今日服务的高级筛选
        if (view.getId() == R.id.today_service_search_new_btn) {
            Intent destIntent = new Intent(this, TodayServiceSearchActivity.class);
            getParent().startActivityForResult(destIntent, 2);
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
    }
}
