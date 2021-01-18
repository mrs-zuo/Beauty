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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.RecordTemplateListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.RecordTemplate;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

public class ChooseCustomerRecordTemplateActivity extends BaseActivity implements OnItemClickListener, RecordTemplateListAdapter.Callback {
    private ChooseCustomerRecordTemplateActivityHandler mHandler = new ChooseCustomerRecordTemplateActivityHandler(this);
    private List<RecordTemplate> recordTemplateList;
    private ListView recordTemplateListView;
    private UserInfoApplication userinfoApplication;
    private ProgressDialog progressDialog;
    private PackageUpdateUtil packageUpdateUtil;
    private Thread requestWebServiceThread;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_choose_customer_record_template);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class ChooseCustomerRecordTemplateActivityHandler extends Handler {
        private final ChooseCustomerRecordTemplateActivity chooseCustomerRecordTemplateActivity;

        private ChooseCustomerRecordTemplateActivityHandler(ChooseCustomerRecordTemplateActivity activity) {
            WeakReference<ChooseCustomerRecordTemplateActivity> weakReference = new WeakReference<ChooseCustomerRecordTemplateActivity>(activity);
            chooseCustomerRecordTemplateActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (chooseCustomerRecordTemplateActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (chooseCustomerRecordTemplateActivity.progressDialog != null) {
                chooseCustomerRecordTemplateActivity.progressDialog.dismiss();
                chooseCustomerRecordTemplateActivity.progressDialog = null;
            }
            if (chooseCustomerRecordTemplateActivity.requestWebServiceThread != null) {
                chooseCustomerRecordTemplateActivity.requestWebServiceThread.interrupt();
                chooseCustomerRecordTemplateActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                chooseCustomerRecordTemplateActivity.recordTemplateListView.setAdapter(new RecordTemplateListAdapter(chooseCustomerRecordTemplateActivity, chooseCustomerRecordTemplateActivity.recordTemplateList, true, chooseCustomerRecordTemplateActivity));
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(chooseCustomerRecordTemplateActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(chooseCustomerRecordTemplateActivity, chooseCustomerRecordTemplateActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(chooseCustomerRecordTemplateActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + chooseCustomerRecordTemplateActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(chooseCustomerRecordTemplateActivity);
                chooseCustomerRecordTemplateActivity.packageUpdateUtil = new PackageUpdateUtil(chooseCustomerRecordTemplateActivity, chooseCustomerRecordTemplateActivity.mHandler, fileCache, downloadFileUrl, false, chooseCustomerRecordTemplateActivity.userinfoApplication);
                chooseCustomerRecordTemplateActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                chooseCustomerRecordTemplateActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = chooseCustomerRecordTemplateActivity.getFileStreamPath(filename);
                file.getName();
                chooseCustomerRecordTemplateActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void initView() {
        recordTemplateListView = (ListView) findViewById(R.id.customer_record_template_list_view);
        recordTemplateListView.setOnItemClickListener(this);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetPaperList";
                String endPoint = "Paper";
                JSONObject getPaperJson = new JSONObject();
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getPaperJson.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                    } catch (JSONException e2) {
                    }
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        JSONArray recordTemplateJsonArray = null;
                        try {
                            recordTemplateJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        if (recordTemplateJsonArray != null) {
                            recordTemplateList = new ArrayList<RecordTemplate>();
                            for (int i = 0; i < recordTemplateJsonArray.length(); i++) {
                                JSONObject recordTemplateJson = null;
                                try {
                                    recordTemplateJson = (JSONObject) recordTemplateJsonArray.get(i);
                                } catch (JSONException e1) {
                                }
                                int recordTemplateID = 0;
                                String recordTemplateTitle = "";
                                String recordTemplateUpdateTime = "";
                                boolean recordTemplateIsVisible = false;
                                boolean recordTemplateIsEditable = false;
                                try {
                                    if (recordTemplateJson.has("PaperID")) {
                                        recordTemplateID = recordTemplateJson.getInt("PaperID");
                                    }
                                    if (recordTemplateJson.has("Title")) {
                                        recordTemplateTitle = recordTemplateJson.getString("Title");
                                    }
                                    if (recordTemplateJson.has("IsVisible")) {
                                        recordTemplateIsVisible = recordTemplateJson.getBoolean("IsVisible");
                                    }
                                    if (recordTemplateJson.has("CanEditAnswer")) {
                                        recordTemplateIsEditable = recordTemplateJson.getBoolean("CanEditAnswer");
                                    }
                                    if (recordTemplateJson.has("CreateTime")) {
                                        recordTemplateUpdateTime = recordTemplateJson.getString("CreateTime");
                                    }
                                } catch (JSONException e) {

                                }
                                RecordTemplate rt = new RecordTemplate();
                                rt.setRecordTemplateID(recordTemplateID);
                                rt.setRecordTemplateTitle(recordTemplateTitle);
                                rt.setRecordTemplateIsVisible(recordTemplateIsVisible);
                                rt.setRecordTemplateIsEditable(recordTemplateIsEditable);
                                rt.setRecordTemplateUpdateTime(recordTemplateUpdateTime);
                                recordTemplateList.add(rt);
                            }
                        }
                        mHandler.sendEmptyMessage(1);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else
                        mHandler.sendEmptyMessage(2);
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // TODO Auto-generated method stub
        Intent destIntent = new Intent(this, AddNewCustomerVocationActivity.class);
        Bundle bundle = new Bundle();
        bundle.putSerializable("recordTemplate", recordTemplateList.get(position));
        destIntent.putExtras(bundle);
        startActivity(destIntent);
    }

    @Override
    public void click(View v) {
        // TODO Auto-generated method stub

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
