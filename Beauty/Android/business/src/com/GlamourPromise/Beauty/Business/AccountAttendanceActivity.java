package com.GlamourPromise.Beauty.Business;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

/*
 * 员工考勤界面
 * */
public class AccountAttendanceActivity extends BaseActivity implements OnClickListener {
    private AccountAttendanceActivityHandler mHandler = new AccountAttendanceActivityHandler(this);
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_account_attendance);
        initView();
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        findViewById(R.id.punch_the_clock_icon).setOnClickListener(this);
        findViewById(R.id.attendance_code_icon).setOnClickListener(this);
        userinfoApplication = (UserInfoApplication) getApplication();
        //具有展示考勤码的权限
        int authAttendanceCode = userinfoApplication.getAccountInfo().getAuthAttendanceCode();
        if (authAttendanceCode == 1)
            findViewById(R.id.attendance_code_icon).setVisibility(View.VISIBLE);
        else
            findViewById(R.id.attendance_code_icon).setVisibility(View.GONE);
    }

    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        String qrCode = intent.getStringExtra("code");
        if (qrCode != null && !"".equals(qrCode)) {
            attendanceByAccount(qrCode);
        } else if ((Intent.FLAG_ACTIVITY_CLEAR_TOP & intent.getFlags()) != 0) {
            finish();
        }
    }

    private void attendanceByAccount(final String qrcode) {
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "AttendanceByAccount";
                String endPoint = "account";
                JSONObject attendanceByAccountJson = new JSONObject();
                try {
                    attendanceByAccountJson.put("Prama", qrcode);
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, attendanceByAccountJson.toString(), userinfoApplication);
                if (serverResult == null || ("").equals(serverResult))
                    mHandler.sendEmptyMessage(0);
                else {
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverResult);
                    } catch (JSONException e) {
                    }
                    int code = 0;
                    String serverMessage = "";
                    try {
                        code = resultJson.getInt("Code");
                        serverMessage = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        Message msg = new Message();
                        msg.what = 1;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 2;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    private static class AccountAttendanceActivityHandler extends Handler {
        private final AccountAttendanceActivity accountAttendanceActivity;

        private AccountAttendanceActivityHandler(AccountAttendanceActivity activity) {
            WeakReference<AccountAttendanceActivity> accountAttendanceActivityWeakReference = new WeakReference<AccountAttendanceActivity>(activity);
            accountAttendanceActivity = accountAttendanceActivityWeakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (accountAttendanceActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (accountAttendanceActivity.requestWebServiceThread != null) {
                accountAttendanceActivity.requestWebServiceThread.interrupt();
                accountAttendanceActivity.requestWebServiceThread = null;
            }
            if (msg.what == 0) {
                DialogUtil.createShortDialog(accountAttendanceActivity, "您的网络貌似不给力，请重试！");
            } else if (msg.what == 1) {
                DialogUtil.createShortDialog(accountAttendanceActivity, (String) msg.obj);
            } else if (msg.what == 2) {
                DialogUtil.createShortDialog(accountAttendanceActivity, (String) msg.obj);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(accountAttendanceActivity, accountAttendanceActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(accountAttendanceActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + accountAttendanceActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(accountAttendanceActivity);
                accountAttendanceActivity.packageUpdateUtil = new PackageUpdateUtil(accountAttendanceActivity, accountAttendanceActivity.mHandler, fileCache, downloadFileUrl, false, accountAttendanceActivity.userinfoApplication);
                accountAttendanceActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                accountAttendanceActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = accountAttendanceActivity.getFileStreamPath(filename);
                file.getName();
                accountAttendanceActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        Intent destIntent = new Intent();
        //打卡
        if (view.getId() == R.id.punch_the_clock_icon) {
            destIntent.setClass(this, DecodeQRCodeActivity.class);
            destIntent.putExtra("sourceType", 3);
        }
        //考勤二维码
        else if (view.getId() == R.id.attendance_code_icon) {
            destIntent.setClass(this, AccountAttendanceCodeActivity.class);
        }
        startActivity(destIntent);
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
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
