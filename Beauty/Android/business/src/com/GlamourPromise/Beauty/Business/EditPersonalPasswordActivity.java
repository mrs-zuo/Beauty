package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.RSAUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

public class EditPersonalPasswordActivity extends BaseActivity implements
        OnClickListener {
    private EditPersonalPasswordActivityHandler mHandler = new EditPersonalPasswordActivityHandler(this);
    private EditText oldPasswordText;
    private EditText newPasswordText;
    private EditText newPasswordConfirmText;
    private Button editPersonalPasswordMakeSureBtn;
    private ProgressDialog progressDialog;
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
        setContentView(R.layout.activity_edit_personal_password);
        oldPasswordText = (EditText) findViewById(R.id.input_old_password);
        newPasswordText = (EditText) findViewById(R.id.input_new_password);
        newPasswordConfirmText = (EditText) findViewById(R.id.input_new_password_again);
        editPersonalPasswordMakeSureBtn = (Button) findViewById(R.id.edit_personal_password_make_sure_btn);
        editPersonalPasswordMakeSureBtn.setOnClickListener(this);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
    }

    private static class EditPersonalPasswordActivityHandler extends Handler {
        private final EditPersonalPasswordActivity editPersonalPasswordActivity;

        private EditPersonalPasswordActivityHandler(EditPersonalPasswordActivity activity) {
            WeakReference<EditPersonalPasswordActivity> weakReference = new WeakReference<EditPersonalPasswordActivity>(activity);
            editPersonalPasswordActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (editPersonalPasswordActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editPersonalPasswordActivity.progressDialog != null) {
                editPersonalPasswordActivity.progressDialog.dismiss();
                editPersonalPasswordActivity.progressDialog = null;
            }
            if (editPersonalPasswordActivity.requestWebServiceThread != null) {
                editPersonalPasswordActivity.requestWebServiceThread.interrupt();
                editPersonalPasswordActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                DialogUtil.createShortDialog(editPersonalPasswordActivity, "密码修改成功！");
            } else if (message.what == 0) {
                String returnMessage = (String) message.obj;
                DialogUtil.createShortDialog(editPersonalPasswordActivity, returnMessage);
            } else if (message.what == -1) {
                String returnMessage = (String) message.obj;
                DialogUtil.createShortDialog(editPersonalPasswordActivity, returnMessage);
            } else if (message.what == 2)
                DialogUtil.createShortDialog(editPersonalPasswordActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editPersonalPasswordActivity, editPersonalPasswordActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editPersonalPasswordActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editPersonalPasswordActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editPersonalPasswordActivity);
                editPersonalPasswordActivity.packageUpdateUtil = new PackageUpdateUtil(editPersonalPasswordActivity, editPersonalPasswordActivity.mHandler, fileCache, downloadFileUrl, false, editPersonalPasswordActivity.userinfoApplication);
                editPersonalPasswordActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                editPersonalPasswordActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = editPersonalPasswordActivity.getFileStreamPath(filename);
                file.getName();
                editPersonalPasswordActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        final String oldPassword = oldPasswordText.getText().toString();
        final String newPassword = newPasswordText.getText().toString();
        String newPasswordConfirm = newPasswordConfirmText.getText().toString();
        switch (view.getId()) {
            case R.id.edit_personal_password_make_sure_btn:
                if (oldPassword == null || ("").equals(oldPassword.trim()))
                    DialogUtil.createMakeSureDialog(this, "提示信息", "旧密码不能为空!");
                else if (oldPassword.trim().length() < 6 || oldPassword.trim().length() > 20)
                    DialogUtil.createMakeSureDialog(this, "提示信息", "旧密码长度应大于6位并小于20位!");
                else if (newPassword == null || ("").equals(newPassword.trim()))
                    DialogUtil.createMakeSureDialog(this, "提示信息", "新密码不能为空!");
                else if (newPassword.trim().length() < 6 || newPassword.trim().length() > 20)
                    DialogUtil.createMakeSureDialog(this, "提示信息", "新密码长度应大于6位并小于20位!");
                else if (newPasswordConfirm == null || ("").equals(newPasswordConfirm.trim()))
                    DialogUtil.createMakeSureDialog(this, "提示信息", "确认密码不能为空！");
                else if (newPasswordConfirm.length() < 6 || newPasswordConfirm.length() > 20)
                    DialogUtil.createMakeSureDialog(this, "提示信息", "确认密码长度应大于6位并小于20位!");
                else if (!(newPassword.equals(newPasswordConfirm)))
                    DialogUtil.createMakeSureDialog(this, "提示信息", "新密码两次输入不一致！");
                else {
                    progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                    progressDialog.setMessage(getString(R.string.please_wait));
                    progressDialog.show();
                    requestWebServiceThread = new Thread() {
                        public void run() {
                            String methodName = "updateUserPassword";
                            String endPoint = "login";
                            JSONObject updateUserPasswordJsonParam = new JSONObject();
                            try {
                                updateUserPasswordJsonParam.put("OldPassword", RSAUtil.encrypt(oldPassword));
                                updateUserPasswordJsonParam.put("NewPassword", RSAUtil.encrypt(newPassword));
                            } catch (JSONException e) {

                            }
                            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, updateUserPasswordJsonParam.toString(), userinfoApplication);
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
                                Message msg = new Message();
                                if (code == 1) {
                                    msg.what = 1;
                                } else if (code == 0) {
                                    String returnMessage = "";
                                    try {
                                        returnMessage = resultJson.getString("Message");
                                    } catch (JSONException e) {

                                    }
                                    msg.obj = returnMessage;
                                    msg.what = 0;
                                } else if (code == -1) {
                                    String returnMessage = "";
                                    try {
                                        returnMessage = resultJson.getString("Message");
                                    } catch (JSONException e) {
                                    }
                                    msg.obj = returnMessage;
                                    msg.what = -1;
                                } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                    mHandler.sendEmptyMessage(code);
                                mHandler.sendMessage(msg);
                            }
                        }

                        ;
                    };
                    requestWebServiceThread.start();
                }
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
    }
}
