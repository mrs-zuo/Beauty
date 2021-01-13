package cn.com.antika.business;

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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.EMarketingMessageTemplateItemAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.FlyMessage;
import cn.com.antika.bean.MessageTemplate;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.RefreshListView;
import cn.com.antika.webservice.WebServiceUtil;

public class SendMarketingTemplateActivity extends BaseActivity implements
        OnClickListener, OnItemClickListener {
    private SendMarketingTemplateActivityHandler mHandler = new SendMarketingTemplateActivityHandler(this);
    private RefreshListView emarketingMessageTemplateList;
    private ImageButton addEmarketingMessageTemplate;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private List<MessageTemplate> messageTemplateList;
    private UserInfoApplication userinfoApplication;
    private String fromSource;
    private FlyMessage flyMessage;
    private String des;
    private String toUsersID;
    private String toUserName;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_send_marketing_template);
        initView();
        fromSource = getIntent().getStringExtra("FROMSOURCE");
        userinfoApplication = UserInfoApplication.getInstance();
    }

    private static class SendMarketingTemplateActivityHandler extends Handler {
        private final SendMarketingTemplateActivity sendMarketingTemplateActivity;

        private SendMarketingTemplateActivityHandler(SendMarketingTemplateActivity activity) {
            WeakReference<SendMarketingTemplateActivity> weakReference = new WeakReference<SendMarketingTemplateActivity>(activity);
            sendMarketingTemplateActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (sendMarketingTemplateActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (message.what == 1) {
                if (sendMarketingTemplateActivity.progressDialog != null) {
                    sendMarketingTemplateActivity.progressDialog.dismiss();
                    sendMarketingTemplateActivity.progressDialog = null;
                }
                if (sendMarketingTemplateActivity.messageTemplateList != null && sendMarketingTemplateActivity.messageTemplateList.size() != 0) {
                    sendMarketingTemplateActivity.emarketingMessageTemplateList.setAdapter(new EMarketingMessageTemplateItemAdapter(sendMarketingTemplateActivity, sendMarketingTemplateActivity.messageTemplateList, sendMarketingTemplateActivity.fromSource, sendMarketingTemplateActivity.flyMessage, sendMarketingTemplateActivity.des, sendMarketingTemplateActivity.toUsersID, sendMarketingTemplateActivity.toUserName));
                }
            } else if (message.what == 2)
                DialogUtil.createShortDialog(sendMarketingTemplateActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(sendMarketingTemplateActivity, sendMarketingTemplateActivity.getString(R.string.login_error_message));
                sendMarketingTemplateActivity.userinfoApplication.exitForLogin(sendMarketingTemplateActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + sendMarketingTemplateActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(sendMarketingTemplateActivity);
                sendMarketingTemplateActivity.packageUpdateUtil = new PackageUpdateUtil(sendMarketingTemplateActivity, sendMarketingTemplateActivity.mHandler, fileCache, downloadFileUrl, false, sendMarketingTemplateActivity.userinfoApplication);
                sendMarketingTemplateActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                sendMarketingTemplateActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = sendMarketingTemplateActivity.getFileStreamPath(filename);
                file.getName();
                sendMarketingTemplateActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (sendMarketingTemplateActivity.requestWebServiceThread != null) {
                sendMarketingTemplateActivity.requestWebServiceThread.interrupt();
                sendMarketingTemplateActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        emarketingMessageTemplateList = (RefreshListView) findViewById(R.id.emarketing_message_template_list);
        emarketingMessageTemplateList.setDividerHeight(20);
        emarketingMessageTemplateList.setOnItemClickListener(this);
        addEmarketingMessageTemplate = (ImageButton) findViewById(R.id.add_new_emarketing_message_template);
        addEmarketingMessageTemplate.setOnClickListener(this);
        Intent intent = getIntent();
        flyMessage = (FlyMessage) intent.getSerializableExtra("flyMessage");
        des = intent.getStringExtra("Des");
        toUsersID = intent.getStringExtra("toUsersID");
        toUserName = intent.getStringExtra("toUsersName");
        progressDialog = new ProgressDialog(this,
                R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        messageTemplateList = new ArrayList<MessageTemplate>();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "getTemplateList";
                String endPoint = "Template";
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, "", userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    JSONArray templateArray = null;
                    int code = 0;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {

                    }
                    if (code == 1) {
                        try {
                            templateArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (templateArray != null) {
                            for (int i = 0; i < templateArray.length(); i++) {
                                JSONObject templateJson = null;
                                try {
                                    templateJson = templateArray.getJSONObject(i);
                                } catch (JSONException e) {
                                }
                                String templateID = "0";
                                String templateContent = "";
                                String templateSubject = "";
                                String creatorName = "";
                                String time = "";
                                String templateType = "0";
                                String lastEditName = "";
                                try {
                                    if (templateJson.has("TemplateID") && !templateJson.isNull("TemplateID"))
                                        templateID = templateJson.getString("TemplateID");

                                    if (templateJson.has("TemplateContent") && !templateJson.isNull("TemplateContent"))
                                        templateContent = templateJson.getString("TemplateContent");

                                    if (templateJson.has("Subject") && !templateJson.isNull("Subject"))
                                        templateSubject = templateJson.getString("Subject");

                                    if (templateJson.has("CreatorName") && !templateJson.isNull("CreatorName"))
                                        creatorName = templateJson.getString("CreatorName");

                                    if (templateJson.has("OperateTime") && !templateJson.isNull("OperateTime"))
                                        time = templateJson.getString("OperateTime");

                                    if (templateJson.has("TemplateType") && !templateJson.isNull("TemplateType"))
                                        templateType = templateJson.getString("TemplateType");

                                    if (templateJson.has("UpdaterName") && !templateJson.isNull("UpdaterName"))
                                        lastEditName = templateJson.getString("UpdaterName");
                                } catch (JSONException e) {

                                }
                                MessageTemplate messageTemplate = new MessageTemplate();
                                messageTemplate.setTemplateID(Integer
                                        .parseInt(templateID));
                                messageTemplate.setTemplateContent(templateContent);
                                messageTemplate.setSubject(templateSubject);
                                messageTemplate.setCreatorName(creatorName);
                                messageTemplate.setTime(time);
                                messageTemplate.setTemplateType(Integer.parseInt(templateType));
                                messageTemplate.setLastEditName(lastEditName);
                                messageTemplateList.add(messageTemplate);
                            }
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        if (view.getId() == R.id.add_new_emarketing_message_template) {
            Intent destIntent = new Intent(this,
                    AddMessageTemplateActivity.class);
            Bundle bundle = new Bundle();
            bundle.putSerializable("flyMessage", flyMessage);
            destIntent.putExtras(bundle);
            destIntent.putExtra("Des", des);
            destIntent.putExtra("FROMSOURCE", fromSource);
            destIntent.putExtra("toUsersID", toUsersID);
            destIntent.putExtra("toUsersName", toUserName);
            startActivity(destIntent);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view,
                            int position, long id) {
        // TODO Auto-generated method stub
        if (position != 0) {
            MessageTemplate messageTemplate = messageTemplateList
                    .get(position - 1);
            Intent destIntent = null;
            if (fromSource.equals("FLYMESSAGE")) {
                destIntent = new Intent(this, FlyMessageDetailActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("flyMessage", flyMessage);
                destIntent.putExtras(bundle);
                destIntent.putExtra("Des", des);
                destIntent.putExtra("toUsersID", toUsersID);
                destIntent.putExtra("toUsersName", toUserName);
            } else if (fromSource.equals("EMARKETING")) {
                destIntent = new Intent(this,
                        SendNewEmarketingMessageActivity.class);
                destIntent.putExtra("toUsersID", toUsersID);
                destIntent.putExtra("toUsersName", toUserName);
            }
            String templateContent = messageTemplate.getTemplateContent();
            destIntent.putExtra("templateContent", templateContent);
            startActivity(destIntent);
            this.finish();
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
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
