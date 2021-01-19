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
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.ReportListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ReportListBean;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

public class ReportListActivity extends BaseActivity implements OnItemClickListener {
    private ReportListActivityHandler mHandler = new ReportListActivityHandler(this);
    private TextView reportListTitleText;
    private ListView reportListView;
    private int cycleType;
    private int objectType;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private List<ReportListBean> reportListBeanList;
    private int reportType;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_report_list);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        reportListTitleText = (TextView) findViewById(R.id.report_list_title_text);
        reportListView = (ListView) findViewById(R.id.report_list);
        reportListView.setOnItemClickListener(this);
        Intent intent = getIntent();
        reportType = intent.getIntExtra("REPORT_TYPE", 0);
        //员工报表
        if (reportType == Constant.EMPLOYEE_REPORT) {
            objectType = 0;
            reportListTitleText.setText(R.string.employee_report_text);
        }
        //分组报表
        else if (reportType == Constant.GROUP_REPORT) {
            objectType = 3;
            reportListTitleText.setText(R.string.group_report_text);
        }
        reportListView = (ListView) findViewById(R.id.report_list);
        cycleType = 0;
        requestWebService(cycleType, objectType);
    }

    private void requestWebService(int cycleType, int objectType) {
        final int ct = cycleType;
        final int ot = objectType;
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getReportList_1_7_2";
                String endPoint = "report";
                JSONObject reportListJsonParam = new JSONObject();
                try {
                    reportListJsonParam.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                    reportListJsonParam.put("CycleType", ct);
                    reportListJsonParam.put("ObjectType", ot);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, reportListJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject reportListJson = null;
                    int code = 0;
                    try {
                        reportListJson = new JSONObject(serverRequestResult);
                        code = reportListJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    reportListBeanList = new ArrayList<ReportListBean>();
                    if (code == 1) {
                        JSONArray reportListJsonArray = null;
                        try {
                            reportListJsonArray = reportListJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        if (reportListJsonArray != null) {
                            for (int i = 0; i < reportListJsonArray.length(); i++) {
                                ReportListBean rlb = new ReportListBean();
                                String objectName = "";
                                int objectID = 0;
                                try {
                                    JSONObject reportJsonObject = reportListJsonArray.getJSONObject(i);
                                    if (reportJsonObject.has("ObjectName") && !reportJsonObject.isNull("ObjectName"))
                                        objectName = reportJsonObject.getString("ObjectName");
                                    if (reportJsonObject.has("ObjectID") && !reportJsonObject.isNull("ObjectID"))
                                        objectID = reportJsonObject.getInt("ObjectID");
                                } catch (JSONException e) {
                                }
                                rlb.setObjectID(objectID);
                                rlb.setObjectName(objectName);
                                reportListBeanList.add(rlb);
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

    private static class ReportListActivityHandler extends Handler {
        private final ReportListActivity reportListActivity;

        private ReportListActivityHandler(ReportListActivity activity) {
            WeakReference<ReportListActivity> weakReference = new WeakReference<ReportListActivity>(activity);
            reportListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (reportListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (reportListActivity.progressDialog != null) {
                reportListActivity.progressDialog.dismiss();
                reportListActivity.progressDialog = null;
            }
            if (reportListActivity.requestWebServiceThread != null) {
                reportListActivity.requestWebServiceThread.interrupt();
                reportListActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                reportListActivity.reportListView.setAdapter(new ReportListAdapter(reportListActivity, reportListActivity.reportListBeanList));
            } else if (message.what == 2)
                DialogUtil.createShortDialog(reportListActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(reportListActivity, reportListActivity.getString(R.string.login_error_message));
                reportListActivity.userinfoApplication.exitForLogin(reportListActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + reportListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(reportListActivity);
                reportListActivity.packageUpdateUtil = new PackageUpdateUtil(reportListActivity, reportListActivity.mHandler, fileCache, downloadFileUrl, false, reportListActivity.userinfoApplication);
                reportListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                reportListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = reportListActivity.getFileStreamPath(filename);
                file.getName();
                reportListActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view,
                            int position, long id) {
        // TODO Auto-generated method stub
        Intent destIntent = new Intent(this, ReportByDateActivity.class);
        destIntent.putExtra("REPORT_TYPE", reportType);
        destIntent.putExtra("OBJECT_ID", reportListBeanList.get(position).getObjectID());
        destIntent.putExtra("CYCLE_TYPE", cycleType);
        startActivity(destIntent);
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
