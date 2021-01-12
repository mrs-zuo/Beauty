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
import android.widget.ImageButton;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.OpportunityListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.Opportunity;
import com.GlamourPromise.Beauty.bean.OpportunityListBaseConditionInfo;
import com.GlamourPromise.Beauty.bean.OpportunityListBaseConditionInfo.OpportunityListConditionBuilder;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.manager.OpportunityManager;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.XListView;
import com.GlamourPromise.Beauty.view.XListView.IXListViewListener;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class OpportunityListActivity extends BaseActivity implements OnClickListener, OnItemClickListener, IXListViewListener {
    private OpportunityListActivityHandler mHandler = new OpportunityListActivityHandler(this);
    private ProgressDialog progressDialog;
    private XListView opportunityListView;
    private List<Opportunity> opportunityList;
    private ImageButton opportunityAdvancedFilterBtn;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private OpportunityListBaseConditionInfo opportunityListBaseConditionInfo;
    private int pageCount = 1;// 全部商机的页数
    private int pageIndex;
    private Boolean isRefresh = false;
    private int getOpportunityListFlag;// 1:取最初的数据；2：取最新的数据；3：取老数据
    private OpportunityManager opportunityManager;
    private OpportunityListAdapter opportunityListAdapter;
    private TextView opportunityListPageInfoText;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_opportunity_list);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class OpportunityListActivityHandler extends Handler {
        private final OpportunityListActivity opportunityListActivity;

        private OpportunityListActivityHandler(OpportunityListActivity activity) {
            WeakReference<OpportunityListActivity> weakReference = new WeakReference<OpportunityListActivity>(activity);
            opportunityListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (opportunityListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            opportunityListActivity.dismissDialog();
            opportunityListActivity.isRefresh = false;
            switch (message.what) {
                case Constant.GET_WEB_DATA_TRUE:
                    @SuppressWarnings("unchecked")
                    ArrayList<Opportunity> tmpList = (ArrayList<Opportunity>) message.obj;
                    opportunityListActivity.pageCount = message.arg2;
                    //总页数不为0时显示
                    if (opportunityListActivity.pageCount != 0) {
                        opportunityListActivity.opportunityListPageInfoText.setText("(第" + opportunityListActivity.pageIndex + "/" + opportunityListActivity.pageCount + "页)");
                    }
                    //总页数为0时，则将订单页数信息置空
                    else {
                        opportunityListActivity.opportunityListPageInfoText.setText("");
                    }
                    // 有老数据时，当前页数加一
                    if (tmpList.size() > 0) {
                        //设置订单列表页数信息
                        opportunityListActivity.pageIndex += 1;
                    }
                    if (opportunityListActivity.getOpportunityListFlag == 1 || opportunityListActivity.getOpportunityListFlag == 2) {
                        opportunityListActivity.opportunityList.clear();
                        opportunityListActivity.opportunityList.addAll(tmpList);
                    } else if (opportunityListActivity.getOpportunityListFlag == 3 && tmpList != null && tmpList.size() > 0) {
                        opportunityListActivity.opportunityList.addAll(opportunityListActivity.opportunityList.size(), tmpList);
                    } else if (opportunityListActivity.getOpportunityListFlag == 3 && (tmpList == null || tmpList.size() == 0)) {
                        opportunityListActivity.opportunityListView.hideFooterView();
                        DialogUtil.createShortDialog(opportunityListActivity, "没有更早的商机了！");
                    }
                    opportunityListActivity.opportunityListAdapter.notifyDataSetChanged();
                    break;
                case Constant.GET_WEB_DATA_EXCEPTION:
                    break;
                case Constant.GET_WEB_DATA_FALSE:
                    if (opportunityListActivity.getOpportunityListFlag == 1 || opportunityListActivity.getOpportunityListFlag == 2) {
                        opportunityListActivity.opportunityList.clear();
                        opportunityListActivity.opportunityListAdapter.notifyDataSetChanged();
                    }
                    String msg = (String) message.obj;
                    DialogUtil.createShortDialog(opportunityListActivity, msg);
                    break;
                default:
                    if (opportunityListActivity.getOpportunityListFlag == 1 || opportunityListActivity.getOpportunityListFlag == 2) {
                        opportunityListActivity.opportunityList.clear();
                        opportunityListActivity.opportunityListAdapter.notifyDataSetChanged();
                    }
                    DialogUtil.createShortDialog(opportunityListActivity, "您的网络貌似不给力，请重试");
                    break;
                case 4:
                    opportunityListActivity.refreshList(1);
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(opportunityListActivity, opportunityListActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(opportunityListActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + opportunityListActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(opportunityListActivity);
                    opportunityListActivity.packageUpdateUtil = new PackageUpdateUtil(opportunityListActivity, opportunityListActivity.mHandler, fileCache, downloadFileUrl, false, opportunityListActivity.userinfoApplication);
                    opportunityListActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) message.obj);
                    opportunityListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                    String filename = "com.glamourpromise.beauty.business.apk";
                    File file = opportunityListActivity.getFileStreamPath(filename);
                    file.getName();
                    opportunityListActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                    ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
            }
            opportunityListActivity.onLoad();
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        opportunityListView = (XListView) findViewById(R.id.opportunity_list);
        opportunityAdvancedFilterBtn = (ImageButton) findViewById(R.id.opportunity_advanced_filter_icon);
        opportunityAdvancedFilterBtn.setOnClickListener(this);
        opportunityListPageInfoText = (TextView) findViewById(R.id.opportunity_page_info_text);
        opportunityListView.setXListViewListener(this);
        opportunityListView.setOnItemClickListener(this);
        opportunityList = new ArrayList<Opportunity>();
        opportunityManager = new OpportunityManager();
        opportunityListAdapter = new OpportunityListAdapter(this, opportunityList);
        opportunityListView.setAdapter(opportunityListAdapter);
        opportunityListView.setPullLoadEnable(true);
        opportunityListBaseConditionInfo = new OpportunityListBaseConditionInfo();
        opportunityListBaseConditionInfo.setProductType(-1);
        opportunityListBaseConditionInfo.setFilterByTimeFlag(0);
        opportunityListBaseConditionInfo.setProductType(-1);
        opportunityListBaseConditionInfo.setResponsiblePersonID("");
        opportunityListBaseConditionInfo.setCustomerID(0);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        initPageIndex();
        refreshList(1);
    }

    private void initPageIndex() {
        pageIndex = 1;
    }

    private void refreshList(int flag) {
        // 上一次取数据任务还没有完成，不在调用后台
        if (isRefresh)
            return;
        // 取老数据时，已经取完数据不在调用后台
        if (flag == 3 && (pageIndex > pageCount || opportunityList.size() < 10)) {
            DialogUtil.createShortDialog(this, "没有更早的商机了！");
            onLoad();
            opportunityListView.hideFooterView();
            return;
        } else {
            opportunityListView.setPullLoadEnable(true);
        }
        isRefresh = true;
        getOpportunityListFlag = flag;
        if (flag == 1) {
            if (progressDialog == null) {
                progressDialog = new ProgressDialog(OpportunityListActivity.this, R.style.CustomerProgressDialog);
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.setCancelable(false);
            }
            progressDialog.show();
        }
        OpportunityListConditionBuilder opportunityListConditionBuilder = new OpportunityListBaseConditionInfo.OpportunityListConditionBuilder();
        int currentPageIndex = 1;
        String createTime = "";
        if (getOpportunityListFlag == 3) {
            currentPageIndex = pageIndex;
            // 传商机列表的第一个CreateTime
            if (currentPageIndex >= 1)
                createTime = opportunityList.get(0).getCreatTime();
        } else if (getOpportunityListFlag == 2) {
            initPageIndex();
        }
        opportunityListConditionBuilder.setCreateTime(createTime).setPageIndex(currentPageIndex).setPageSize(10)
                .setProductType(opportunityListBaseConditionInfo.getProductType()).setResponsibleID(opportunityListBaseConditionInfo.getResponsiblePersonIDs())
                .setCustomerID(opportunityListBaseConditionInfo.getCustomerID())
                .setFilterByTimeFlag(opportunityListBaseConditionInfo.getFilterByTimeFlag()).setStartDate(opportunityListBaseConditionInfo.getStartDate()).setEndDate(opportunityListBaseConditionInfo.getEndDate());
        opportunityManager.getOpportunityList(mHandler, opportunityListConditionBuilder.create(), userinfoApplication);
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.opportunity_advanced_filter_icon:
                Intent destIntent = new Intent(this, OpportunityAdvancedSearchActivity.class);
                startActivityForResult(destIntent, 1);
                break;
        }
    }

    protected void dismissDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        if (requestCode == 1 && resultCode == 1) {
            opportunityListBaseConditionInfo = (OpportunityListBaseConditionInfo) data.getSerializableExtra("baseCondition");
            initPageIndex();
            refreshList(1);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view,
                            int position, long id) {
        if (position != 0) {
            // 点击查看需求的详细
            Opportunity opportunity = opportunityList.get(position - 1);
            Intent destIntent = new Intent(this, OpportunityDetailMainActivity.class);
            Bundle bundle = new Bundle();
            bundle.putSerializable("opportunity", opportunity);
            destIntent.putExtra("opportunityID", opportunity.getOpportunityID());
            destIntent.putExtra("productType", opportunity.getProductType());
            destIntent.putExtra("opportunityCustomerName", opportunity.getCustomerName());
            destIntent.putExtra("opportunityResponsiblePersonName", opportunity.getResponsiblePersonName());
            destIntent.putExtra("opportunityIsAvailable", opportunity.isAvailable());
            destIntent.putExtras(bundle);
            startActivity(destIntent);
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
        dismissDialog();
    }

    private void onLoad() {
        opportunityListView.stopRefresh();
        opportunityListView.stopLoadMore();
        opportunityListView.setRefreshTime(new Date().toLocaleString());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        String isExit = intent.getStringExtra("exit");
        if (isExit != null && isExit.equals("1")) {
            userinfoApplication.setAccountInfo(null);
            userinfoApplication.setSelectedCustomerID(0);
            userinfoApplication.setSelectedCustomerName("");
            userinfoApplication.setSelectedCustomerHeadImageURL("");
            userinfoApplication.setSelectedCustomerLoginMobile("");
            userinfoApplication.setAccountNewMessageCount(0);
            userinfoApplication.setAccountNewRemindCount(0);
            userinfoApplication.setOrderInfo(null);
            Constant.formalFlag = 0;
            finish();
        } else {
            initPageIndex();
            opportunityListView.setPullLoadEnable(true);
            opportunityList.clear();
            if (opportunityListBaseConditionInfo == null)
                opportunityListBaseConditionInfo = new OpportunityListBaseConditionInfo();
            opportunityListBaseConditionInfo.setProductType(-1);
            opportunityListBaseConditionInfo.setFilterByTimeFlag(0);
            opportunityListBaseConditionInfo.setProductType(-1);
            opportunityListBaseConditionInfo.setResponsiblePersonID("");
            opportunityListBaseConditionInfo.setCustomerID(0);
            refreshList(1);
        }
    }

    @Override
    public void onRefresh() {
        // TODO Auto-generated method stub
        refreshList(2);
    }

    @Override
    public void onLoadMore() {
        // TODO Auto-generated method stub
        refreshList(3);
    }
}
