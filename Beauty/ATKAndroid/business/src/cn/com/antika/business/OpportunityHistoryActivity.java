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

import cn.com.antika.adapter.OpportunityProgressHistoryListItemAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.Opportunity;
import cn.com.antika.bean.OpportunityProgressHistory;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.webservice.WebServiceUtil;

public class OpportunityHistoryActivity extends BaseActivity implements
        OnItemClickListener {
    private OpportunityHistoryActivityHandler mHandler = new OpportunityHistoryActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private ListView opportunityProgressListView;
    private List<OpportunityProgressHistory> opportunityProgressHistoryList;
    private int productType;
    private UserInfoApplication userinfoApplication;
    private int opportunityID;
    private PackageUpdateUtil packageUpdateUtil;
    private Opportunity opportunity;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_opportunity_history);
        initView();
        userinfoApplication = UserInfoApplication.getInstance();
    }

    private static class OpportunityHistoryActivityHandler extends Handler {
        private final OpportunityHistoryActivity opportunityHistoryActivity;

        private OpportunityHistoryActivityHandler(OpportunityHistoryActivity activity) {
            WeakReference<OpportunityHistoryActivity> weakReference = new WeakReference<OpportunityHistoryActivity>(activity);
            opportunityHistoryActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (opportunityHistoryActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (opportunityHistoryActivity.progressDialog != null) {
                opportunityHistoryActivity.progressDialog.dismiss();
                opportunityHistoryActivity.progressDialog = null;
            }
            if (opportunityHistoryActivity.requestWebServiceThread != null) {
                opportunityHistoryActivity.requestWebServiceThread.interrupt();
                opportunityHistoryActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                opportunityHistoryActivity.opportunityProgressListView
                        .setAdapter(new OpportunityProgressHistoryListItemAdapter(
                                opportunityHistoryActivity,
                                opportunityHistoryActivity.opportunityProgressHistoryList));
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(opportunityHistoryActivity,
                        "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(opportunityHistoryActivity, opportunityHistoryActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(opportunityHistoryActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + opportunityHistoryActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(opportunityHistoryActivity);
                opportunityHistoryActivity.packageUpdateUtil = new PackageUpdateUtil(opportunityHistoryActivity, opportunityHistoryActivity.mHandler, fileCache, downloadFileUrl, false, opportunityHistoryActivity.userinfoApplication);
                opportunityHistoryActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                opportunityHistoryActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = opportunityHistoryActivity.getFileStreamPath(filename);
                file.getName();
                opportunityHistoryActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void initView() {
        opportunityProgressListView = (ListView) findViewById(R.id.opportunity_progress_history_list);
        opportunityProgressListView.setOnItemClickListener(this);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        // 获得需求进度处理历史
        opportunity = (Opportunity) getIntent().getSerializableExtra("opportunity");
        opportunityID = getIntent().getIntExtra("opportunityID", 0);
        productType = getIntent().getIntExtra("productType", 0);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getProgressHistory";
                String endPoint = "opportunity";
                JSONObject opportunityHistroy = new JSONObject();
                try {
                    opportunityHistroy.put("OpportunityID", opportunityID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, opportunityHistroy.toString(), userinfoApplication);
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
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
                        JSONArray opportunityHistory = null;
                        try {
                            opportunityHistory = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (opportunityHistory != null) {
                            opportunityProgressHistoryList = new ArrayList<OpportunityProgressHistory>();
                            for (int i = 0; i < opportunityHistory.length(); i++) {
                                JSONObject oppHistory = null;
                                try {
                                    oppHistory = opportunityHistory.getJSONObject(i);
                                } catch (JSONException e) {
                                }
                                if (oppHistory != null) {
                                    int progressHistoryID = 0;
                                    int progress = 0;
                                    String description = "";
                                    String createTime = "";
                                    String stepContent = "";
                                    try {
                                        if (oppHistory.has("ProgressHistoryID"))
                                            progressHistoryID = oppHistory.getInt("ProgressHistoryID");
                                        if (oppHistory.has("Progress"))
                                            progress = oppHistory.getInt("Progress");
                                        if (oppHistory.has("Description"))
                                            description = oppHistory.getString("Description");
                                        if (oppHistory.has("CreateTime"))
                                            createTime = oppHistory.getString("CreateTime");
                                        if (oppHistory.has("StepContent"))
                                            stepContent = oppHistory.getString("StepContent");
                                    } catch (JSONException e) {

                                    }
                                    OpportunityProgressHistory oph = new OpportunityProgressHistory();
                                    oph.setProgressHistoryID(progressHistoryID);
                                    oph.setProgress(progress);
                                    String[] stepContentArray = stepContent.split("\\|");
                                    for (int j = 0; j < stepContentArray.length; j++) {
                                        if (j == (progress - 1)) {
                                            oph.setProgressName(stepContentArray[j]);
                                            break;
                                        }
                                    }
                                    oph.setDescription(description);
                                    oph.setCreateTime(createTime);
                                    opportunityProgressHistoryList.add(oph);
                                }
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
    public void onItemClick(AdapterView<?> adapterView, View view,
                            int position, long id) {
        // TODO Auto-generated method stub
        Intent intent = new Intent(this, EditProgressHistoryActivity.class);
        intent.putExtra("opportunityID", opportunityID);
        intent.putExtra("progressHistoryID", opportunityProgressHistoryList.get(position).getProgressHistoryID());
        intent.putExtra("progressHistoryName", opportunityProgressHistoryList.get(position).getProgressName());
        intent.putExtra("progressHistoryDescription", opportunityProgressHistoryList.get(position).getDescription());
        intent.putExtra("productType", productType);
        intent.putExtra("progressHistoryCreateTime", opportunityProgressHistoryList.get(position).getCreateTime());
        Bundle bundle = new Bundle();
        bundle.putSerializable("opportunity", opportunity);
        intent.putExtras(bundle);
        startActivity(intent);
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
