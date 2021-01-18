package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Date;

public class SendNewEmarketingMessageActivity extends BaseActivity implements
        OnClickListener {
    private SendNewEmarketingMessageActivityHandler mHandler = new SendNewEmarketingMessageActivityHandler(this);
    private TextView sendEmarketingMessageTime;
    private EditText sendEmarketingMessageContent;
    private RelativeLayout sendEmarketingMessageToUserRelativeLayout;
    private RelativeLayout sendEmarketingMessageContentTemplateRelativeLayout;
    private TextView sendEmarketingMessageToUserText;
    private String toUserIds = "";
    private String toUserNames = "";
    private Button sendEmarketingMessageMakeSure;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class SendNewEmarketingMessageActivityHandler extends Handler {
        private final SendNewEmarketingMessageActivity sendNewEmarketingMessageActivity;

        private SendNewEmarketingMessageActivityHandler(SendNewEmarketingMessageActivity activity) {
            WeakReference<SendNewEmarketingMessageActivity> weakReference = new WeakReference<SendNewEmarketingMessageActivity>(activity);
            sendNewEmarketingMessageActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (sendNewEmarketingMessageActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (sendNewEmarketingMessageActivity.progressDialog != null) {
                sendNewEmarketingMessageActivity.progressDialog.dismiss();
                sendNewEmarketingMessageActivity.progressDialog = null;
            }
            if (sendNewEmarketingMessageActivity.requestWebServiceThread != null) {
                sendNewEmarketingMessageActivity.requestWebServiceThread.interrupt();
                sendNewEmarketingMessageActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                DialogUtil.createShortDialog(sendNewEmarketingMessageActivity, "发送成功！");
                Intent destIntent = new Intent(sendNewEmarketingMessageActivity, EMarketingActivity.class);
                sendNewEmarketingMessageActivity.startActivity(destIntent);
            } else if (message.what == 2)
                DialogUtil.createShortDialog(sendNewEmarketingMessageActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(sendNewEmarketingMessageActivity, sendNewEmarketingMessageActivity.getString(R.string.login_error_message));
                sendNewEmarketingMessageActivity.userinfoApplication.exitForLogin(sendNewEmarketingMessageActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + sendNewEmarketingMessageActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(sendNewEmarketingMessageActivity);
                sendNewEmarketingMessageActivity.packageUpdateUtil = new PackageUpdateUtil(sendNewEmarketingMessageActivity, sendNewEmarketingMessageActivity.mHandler, fileCache, downloadFileUrl, false, sendNewEmarketingMessageActivity.userinfoApplication);
                sendNewEmarketingMessageActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                sendNewEmarketingMessageActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = sendNewEmarketingMessageActivity.getFileStreamPath(filename);
                file.getName();
                sendNewEmarketingMessageActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else {
                DialogUtil.createShortDialog(
                        sendNewEmarketingMessageActivity, "发送营销消息失败！");
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_send_new_emarketing_message);
        initView();
        userinfoApplication = UserInfoApplication.getInstance();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        sendEmarketingMessageTime = (TextView) findViewById(R.id.send_marketing_time);
        sendEmarketingMessageToUserRelativeLayout = (RelativeLayout) findViewById(R.id.send_marketing_message_to_user_relativelayout);
        sendEmarketingMessageToUserText = (TextView) findViewById(R.id.send_marketing_message_to_user_text);
        sendEmarketingMessageContent = (EditText) findViewById(R.id.send_marketing_message_content_text);
        sendEmarketingMessageContentTemplateRelativeLayout = (RelativeLayout) findViewById(R.id.send_marketing_message_content_relativelayout);
        sendEmarketingMessageToUserRelativeLayout.setOnClickListener(this);
        sendEmarketingMessageContentTemplateRelativeLayout.setOnClickListener(this);
        sendEmarketingMessageMakeSure = (Button) findViewById(R.id.send_marketing_message_make_sure_btn);
        sendEmarketingMessageMakeSure.setOnClickListener(this);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        String sendMarketingMessageTime = sdf.format(new Date());
        sendEmarketingMessageTime.setText(sendMarketingMessageTime);
        Intent intent = getIntent();
        toUserNames = intent.getStringExtra("toUsersName");
        if (toUserNames != null && !toUserNames.equals("")) {
            String[] userNameArray = toUserNames.split(",");
            int toUserNumber = userNameArray.length;
            if (toUserNumber > 1) {
                String showUserNameText = userNameArray[0] + ","
                        + userNameArray[1];
                sendEmarketingMessageToUserText.setText(showUserNameText + "等"
                        + toUserNumber + "人");
            } else if (toUserNumber == 1) {
                String showUserNameText = userNameArray[0];
                sendEmarketingMessageToUserText.setText(showUserNameText);
            }
            toUserIds = intent.getStringExtra("toUsersID");
        }
        sendEmarketingMessageContent.setText(intent
                .getStringExtra("templateContent"));

    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        Intent destIntent = null;
        switch (view.getId()) {
            case R.id.send_marketing_message_to_user_relativelayout:
                destIntent = new Intent(this, ChoosePersonActivity.class);
                Bundle bundle = new Bundle();
                bundle.putString("personRole", "Customer");
                bundle.putString("checkModel", "Multi");
                bundle.putString("messageType", "Emarketing");
                destIntent.putExtra("mustSelectOne", true);
                destIntent.putExtras(bundle);
                if (toUserIds != null && !("").equals(toUserIds)) {
                    String[] toUserIdArray = toUserIds.split(",");
                    JSONArray customerJsonArray = new JSONArray();
                    for (String userId : toUserIdArray) {
                        customerJsonArray.put(Integer.parseInt(userId));
                    }
                    destIntent.putExtra("selectPersonIDs", customerJsonArray.toString());
                }
                startActivityForResult(destIntent, 100);
                break;
            case R.id.send_marketing_message_content_relativelayout:
                destIntent = new Intent(this, SendMarketingTemplateActivity.class);
                destIntent.putExtra("toUsersID", toUserIds);
                destIntent.putExtra("toUsersName", toUserNames);
                destIntent.putExtra("FROMSOURCE", "EMARKETING");
                startActivity(destIntent);
                break;
            case R.id.send_marketing_message_make_sure_btn:
                if (toUserIds.equals(""))
                    DialogUtil.createShortDialog(this, "请选择营销对象人员！");
                else if (sendEmarketingMessageContent.getText().toString() == null || ("").equals(sendEmarketingMessageContent.getText().toString()))
                    DialogUtil.createShortDialog(this, "请输入营销内容！");
                else {
                    progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                    progressDialog.setMessage(getString(R.string.please_wait));
                    progressDialog.show();
                    requestWebServiceThread = new Thread() {
                        @Override
                        public void run() {
                            String methodName = "addMessage";
                            String endPoint = "Message";
                            JSONObject addMessageJsonParam = new JSONObject();
                            try {
                                addMessageJsonParam.put("FromUserID", userinfoApplication.getAccountInfo().getAccountId());
                                addMessageJsonParam.put("ToUserIDs", toUserIds);
                                addMessageJsonParam.put("MessageContent", sendEmarketingMessageContent.getText().toString());
                                addMessageJsonParam.put("MessageType", 1);
                                if (toUserIds.split(",").length > 1)
                                    addMessageJsonParam.put("GroupFlag", 1);
                                else
                                    addMessageJsonParam.put("GroupFlag", 0);
                            } catch (JSONException e) {

                            }
                            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addMessageJsonParam.toString(), userinfoApplication);
                            if (serverRequestResult == null || serverRequestResult.equals(""))
                                mHandler.sendEmptyMessage(2);
                            else {
                                int code = 0;
                                try {
                                    JSONObject result = new JSONObject(serverRequestResult);
                                    code = result.getInt("Code");
                                } catch (JSONException e) {

                                }
                                if (code == 1)
                                    mHandler.sendEmptyMessage(1);
                                else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                                    mHandler.sendEmptyMessage(code);
                                else
                                    mHandler.sendEmptyMessage(0);
                            }
                        }
                    };
                    requestWebServiceThread.start();
                }
                break;
        }
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
            toUserNames = intent.getStringExtra("toUsersName");
            if (toUserNames != null && !toUserNames.equals("")) {
                String[] userNameArray = toUserNames.split(",");
                int toUserNumber = userNameArray.length;
                if (toUserNumber > 1) {
                    String showUserNameText = userNameArray[0] + ","
                            + userNameArray[1];
                    sendEmarketingMessageToUserText.setText(showUserNameText + "等"
                            + toUserNumber + "人");
                } else if (toUserNumber == 1) {
                    String showUserNameText = userNameArray[0];
                    sendEmarketingMessageToUserText.setText(showUserNameText);
                }
                toUserIds = intent.getStringExtra("toUsersID");
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            toUserNames = data.getStringExtra("toUsersName");
            String[] userNameArray = toUserNames.split(",");
            int toUserNumber = userNameArray.length;
            if (toUserNumber > 1) {
                String showUserNameText = userNameArray[0] + ","
                        + userNameArray[1];
                sendEmarketingMessageToUserText.setText(showUserNameText + "等"
                        + toUserNumber + "人");
            } else if (toUserNumber == 1) {
                String showUserNameText = userNameArray[0];
                sendEmarketingMessageToUserText.setText(showUserNameText);
            }
            toUserIds = data.getStringExtra("toUsersID");
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
