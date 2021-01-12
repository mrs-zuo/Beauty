package com.GlamourPromise.Beauty.Business;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Display;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageButton;

import com.GlamourPromise.Beauty.Thread.GetCompanyListForAccountThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AccountInfo;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.util.RSAUtil;

import org.json.JSONArray;

import java.io.File;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.util.ArrayList;

import cn.jpush.android.api.JPushInterface;

/*
 * 登陆页面
 * */
public class LoginActivity extends Activity implements OnClickListener {
    private LoginActivityHandler mHandler = new LoginActivityHandler(this);
    public static final String TAG = "LoginActivity";
    private EditText userNameText;
    private EditText passwordText;
    private ImageButton loginBtn;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UserInfoApplication userInfoApplication;
    private int loginTimes = 0;
    private SharedPreferences accountInfoSharedPreferences;
    private PackageUpdateUtil packageUpdateUtil;
    public static boolean isForeground = false;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_login);
        userNameText = (EditText) findViewById(R.id.login_username_edit_text);
        passwordText = (EditText) findViewById(R.id.login_password_edit_text);
        accountInfoSharedPreferences = getSharedPreferences("AccountInfo", Context.MODE_PRIVATE);
        userNameText.setText(accountInfoSharedPreferences.getString("lastLoginAccount", ""));
        loginBtn = (ImageButton) findViewById(R.id.login_btn);
        loginBtn.setOnClickListener(this);
        userInfoApplication = UserInfoApplication.getInstance();
        getScreenInfo();
        isForeground = true;
    }

    @Override
    protected void onPause() {
        super.onPause();
        JPushInterface.onPause(this);
    }

    @Override
    protected void onResume() { // 当用户使程序恢复为前台显示时执行onResume()方法,在其中判断是否超时.
        // TODO Auto-generated method stub
        super.onResume();
        JPushInterface.onResume(this);
        isForeground = true;
    }

    private static class LoginActivityHandler extends Handler {
        private final LoginActivity loginActivity;

        private LoginActivityHandler(LoginActivity activity) {
            // 初期化 弱引用 获取对象实例
            WeakReference<LoginActivity> activityWeakReference = new WeakReference<LoginActivity>(activity);
            loginActivity = activityWeakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (loginActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (loginActivity.progressDialog != null) {
                loginActivity.progressDialog.dismiss();
                loginActivity.progressDialog = null;
            }
            if (loginActivity.requestWebServiceThread != null) {
                loginActivity.requestWebServiceThread.interrupt();
                loginActivity.requestWebServiceThread = null;
            }
            if (message.what == 0) {
                if (loginActivity.loginTimes == 1) {
                    Constant.formalFlag = 1;// 表示demo用户
                    loginActivity.loginAction_2_0_1();
                } else if (loginActivity.loginTimes == 2) {
                    Constant.formalFlag = 2;// 表示测试用户
                    loginActivity.loginAction_2_0_1();
                } else {
                    Constant.formalFlag = 0;// 表示正式用户
                    loginActivity.loginTimes = 0;
                    DialogUtil.createMakeSureDialog(loginActivity, "登陆提示", "账户或密码错误，请重新输入！");
                }
            } else if (message.what == 1) {
                @SuppressWarnings("unchecked")
                ArrayList<AccountInfo> accountInfoList = (ArrayList<AccountInfo>) message.obj;
                // 保存登陆信息List信息
                JSONArray jsonArray = new JSONArray();
                for (AccountInfo accountInfo : accountInfoList) {
                    jsonArray.put(accountInfo.getInfoJason());
                }
                loginActivity.userInfoApplication.setRsaUserName(loginActivity.rsaUserName);
                loginActivity.userInfoApplication.setRsaPassword(loginActivity.rsaPassWord);
                loginActivity.userInfoApplication.setAccountInfoList(jsonArray);
                loginActivity.userInfoApplication.setConstantFlag();
                loginActivity.userInfoApplication.setNormalLogin(true);
                ArrayList<ArrayList<BranchInfo>> branchInfoList = loginActivity.userInfoApplication.getLoginBranchList();
                int branchListCount = 0;
                if (branchInfoList != null && branchInfoList.size() > 0)
                    branchListCount = branchInfoList.get(0).size();
                Bundle mBundle;
                // 只有一个账号 只属于一家分店
                if (accountInfoList != null && accountInfoList.size() == 1 && branchListCount == 1) {
                    accountInfoList.get(0).setLoginMobile(loginActivity.userNameText.getText().toString());
                    Intent intent = new Intent(loginActivity, HomePageActivity.class);
                    loginActivity.userInfoApplication.setNeedUpdateLoginInfo(true);
                    mBundle = new Bundle();
                    mBundle.putSerializable("AccountInfo", (Serializable) accountInfoList.get(0));
                    intent.putExtras(mBundle);
                    loginActivity.startActivity(intent);
                }
                // 属于多家分店
                else {
                    Intent intent = new Intent(loginActivity, CompanySelectActivity.class);
                    mBundle = new Bundle();
                    mBundle.putSerializable("AccountInfoList", (Serializable) accountInfoList);
                    mBundle.putSerializable("BranchInfoList", (Serializable) branchInfoList);
                    intent.putExtras(mBundle);
                    intent.putExtra("LoginMobile", loginActivity.userNameText.getText().toString());
                    intent.putExtra("SRC_ACTIVITY", LoginActivity.TAG);
                    loginActivity.startActivity(intent);
                }

                Editor editor = loginActivity.accountInfoSharedPreferences.edit();// 获取编辑器
                editor.putString("lastLoginAccount", loginActivity.userNameText.getText().toString());
                editor.commit();
                loginActivity.finish();
            } else if (message.what == -2) {
                if (loginActivity.loginTimes == 1) {
                    Constant.formalFlag = 1;// 表示demo用户
                    loginActivity.loginAction_2_0_1();
                } else if (loginActivity.loginTimes == 2) {
                    Constant.formalFlag = 2;// 表示测试用户
                    loginActivity.loginAction_2_0_1();
                } else {
                    Constant.formalFlag = 0;// 表示正式用户
                    loginActivity.loginTimes = 0;
                    DialogUtil.createMakeSureDialog(loginActivity, "温馨提示", "用户名或密码错误，请重试。");
                }
            } else if (message.what == -1) {
                DialogUtil.createMakeSureDialog(loginActivity, "温馨提示", message.obj.toString());
            }
            //登陆获取到需要强制升级
            else if (message.what == -3) {
                String downloadFileUrl = Constant.SERVER_URL + loginActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(loginActivity);
                loginActivity.packageUpdateUtil = new PackageUpdateUtil(loginActivity, loginActivity.mHandler, fileCache, downloadFileUrl, false, loginActivity.userInfoApplication);
                loginActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                loginActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = loginActivity.getFileStreamPath(filename);
                file.getName();
                loginActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    String userNameStr = "";
    String passwordStr = "";
    String rsaUserName = "";
    String rsaPassWord = "";

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        if (ProgressDialogUtil.isFastClick()) {
            return;
        }
        userNameStr = userNameText.getText().toString();
        passwordStr = passwordText.getText().toString();
        if (null == userNameStr || ("").equals(userNameStr)) {
            DialogUtil.createMakeSureDialog(this, "登录提示", "请输入登录帐号");
        } else if (null == passwordStr || ("").equals(passwordStr)) {
            DialogUtil.createMakeSureDialog(this, "登录提示", "请输入密码");
        } else {
            loginAction_2_0_1();
        }
    }

    protected void loginAction_2_0_1() {
        loginTimes++;
        progressDialog = ProgressDialogUtil.createProgressDialog(LoginActivity.this);
        rsaUserName = RSAUtil.encrypt(userNameStr);
        rsaPassWord = RSAUtil.encrypt(passwordStr);
        requestWebServiceThread = new GetCompanyListForAccountThread("getCompanyList", "Login", mHandler, rsaUserName, rsaPassWord, userInfoApplication.getScreenWidth(), userInfoApplication.getScreenHeight(), userInfoApplication);
        requestWebServiceThread.start();
    }

    protected void getScreenInfo() {
        Display mDisplay = getWindowManager().getDefaultDisplay();
        int screenWidth = mDisplay.getWidth();
        int screenHeight = mDisplay.getHeight();
        userInfoApplication.setCodeTextSize(18);
        userInfoApplication.setScreenWidth(screenWidth);
        userInfoApplication.setScreenHeight(screenHeight);
    }


    @Override
    protected void onRestart() {
        // TODO Auto-generated method stub
        super.onRestart();
        passwordText.setText("");
        isForeground = true;
    }

    //事件分发机制  捕获当前的点击位置是否是文本框位置，文本框以外的则隐藏掉键盘
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            View v = getCurrentFocus();
            if (isShouldHideInput(v, ev)) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                if (imm != null) {
                    imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                }
            }
            return super.dispatchTouchEvent(ev);
        }
        // 必不可少，否则所有的组件都不会有TouchEvent了
        if (getWindow().superDispatchTouchEvent(ev)) {
            return true;
        }
        return onTouchEvent(ev);
    }

    public boolean isShouldHideInput(View v, MotionEvent event) {
        if (v != null && (v instanceof EditText)) {
            int[] leftTop = {0, 0};
            //获取输入框当前的location位置  
            v.getLocationInWindow(leftTop);
            int left = leftTop[0];
            int top = leftTop[1];
            int bottom = top + v.getHeight();
            int right = left + v.getWidth();
            if (event.getX() > left && event.getX() < right
                    && event.getY() > top && event.getY() < bottom) {
                // 点击的是输入框区域，保留点击EditText的事件  
                return false;
            } else {
                return true;
            }
        }
        return false;
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
        isForeground = false;
    }
}
