package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;

import cn.com.antika.Thread.GetBackendServerDataByWebserviceThread;
import cn.com.antika.adapter.NoticeListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.NoticeInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.implementation.GetServerNoticeListDataTaskImpl;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

public class NoticeListActivity extends BaseActivity implements OnItemClickListener {
    private NoticeListActivityHandler mHandler = new NoticeListActivityHandler(this);
    private Thread getNotcieListThread;
    private ListView noticeListView;
    private NoticeListAdapter noticeListAdapter;
    private ProgressDialog progressDialog;
    private UserInfoApplication userInfoApplication;
    private ArrayList<NoticeInfo> noticeList;
    private GetServerNoticeListDataTaskImpl getNoticeListTask;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class NoticeListActivityHandler extends Handler {
        private final NoticeListActivity noticeListActivity;

        private NoticeListActivityHandler(NoticeListActivity activity) {
            WeakReference<NoticeListActivity> weakReference = new WeakReference<NoticeListActivity>(activity);
            noticeListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (noticeListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            noticeListActivity.dismissProgressDialog();
            if (noticeListActivity.getNotcieListThread != null) {
                noticeListActivity.getNotcieListThread.interrupt();
                noticeListActivity.getNotcieListThread = null;
            }
            if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR) {
                DialogUtil.createShortDialog(noticeListActivity, "您的网络貌似不给力，请重试");
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
                DialogUtil.createShortDialog(noticeListActivity, (String) msg.obj);
            } else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
                ArrayList<NoticeInfo> newNoticeList = (ArrayList<NoticeInfo>) msg.obj;
                noticeListActivity.noticeList.clear();
                noticeListActivity.noticeList.addAll(newNoticeList);
                noticeListActivity.noticeListAdapter.notifyDataSetChanged();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(noticeListActivity, noticeListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(noticeListActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + noticeListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(noticeListActivity);
                noticeListActivity.packageUpdateUtil = new PackageUpdateUtil(noticeListActivity, noticeListActivity.mHandler, fileCache, downloadFileUrl, false, noticeListActivity.userInfoApplication);
                noticeListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                noticeListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = noticeListActivity.getFileStreamPath(filename);
                file.getName();
                noticeListActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_notice_list);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userInfoApplication = (UserInfoApplication) getApplication();
        noticeListView = (ListView) findViewById(R.id.notice_listview);
        noticeList = new ArrayList<NoticeInfo>();
        noticeListAdapter = new NoticeListAdapter(this, noticeList);
        noticeListView.setAdapter(noticeListAdapter);
        noticeListView.setOnItemClickListener(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        getNoticeListData();
    }

    private void getNoticeListData() {
        if (getNotcieListThread == null) {
            //showProgressDialog();
            createGetNoticeListTask();
            getNotcieListThread = new GetBackendServerDataByWebserviceThread(getNoticeListTask, true);
            getNotcieListThread.start();
        }
    }

    private void createGetNoticeListTask() {
        if (getNoticeListTask == null) {
            JSONObject noticeJsonParam = new JSONObject();
            getNoticeListTask = new GetServerNoticeListDataTaskImpl(noticeJsonParam, mHandler, userInfoApplication);
        }
    }

    private void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
        }
        progressDialog.show();
    }

    private void dismissProgressDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
    }

    @Override
    public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
        // TODO Auto-generated method stub
        Intent intent = new Intent(this, NoticeDetailActivity.class);
        Bundle bundle = new Bundle();
        bundle.putSerializable("NoticeInfo", noticeList.get(arg2));
        intent.putExtras(bundle);
        startActivity(intent);
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        dismissProgressDialog();
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (getNotcieListThread != null) {
            getNotcieListThread.interrupt();
            getNotcieListThread = null;
        }

    }
}
