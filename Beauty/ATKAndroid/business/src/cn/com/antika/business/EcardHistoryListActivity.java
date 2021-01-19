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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.EcardHistroyListItemAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardHistroy;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.minterface.RefreshListViewWithWebservice;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.RefreshListView;
import cn.com.antika.webservice.WebServiceUtil;

public class EcardHistoryListActivity extends BaseActivity implements
        OnItemClickListener {
    private EcardHistoryListActivityHandler mHandler = new EcardHistoryListActivityHandler(this);
    private RefreshListView ecardHistoryListView;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private EcardInfo ecardInfo;
    private List<EcardHistroy> ecardHistroyList;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_ecard_history_list);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class EcardHistoryListActivityHandler extends Handler {
        private final EcardHistoryListActivity ecardHistoryListActivity;

        private EcardHistoryListActivityHandler(EcardHistoryListActivity activity) {
            WeakReference<EcardHistoryListActivity> weakReference = new WeakReference<EcardHistoryListActivity>(activity);
            ecardHistoryListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (ecardHistoryListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (ecardHistoryListActivity.progressDialog != null) {
                ecardHistoryListActivity.progressDialog.dismiss();
                ecardHistoryListActivity.progressDialog = null;
            }
            if (ecardHistoryListActivity.requestWebServiceThread != null) {
                ecardHistoryListActivity.requestWebServiceThread.interrupt();
                ecardHistoryListActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                ecardHistoryListActivity.ecardHistoryListView.setAdapter(new EcardHistroyListItemAdapter(ecardHistoryListActivity, ecardHistoryListActivity.ecardHistroyList, ecardHistoryListActivity.ecardInfo.getUserEcardType()));
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(ecardHistoryListActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(ecardHistoryListActivity, ecardHistoryListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(ecardHistoryListActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + ecardHistoryListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(ecardHistoryListActivity);
                ecardHistoryListActivity.packageUpdateUtil = new PackageUpdateUtil(ecardHistoryListActivity, ecardHistoryListActivity.mHandler, fileCache, downloadFileUrl, false, ecardHistoryListActivity.userinfoApplication);
                ecardHistoryListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                ecardHistoryListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = ecardHistoryListActivity.getFileStreamPath(filename);
                file.getName();
                ecardHistoryListActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        ecardHistoryListView = (RefreshListView) findViewById(R.id.ecard_history_list_view);
        ecardHistoryListView.setOnItemClickListener(this);
        progressDialog = new ProgressDialog(this,
                R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        ecardHistoryListView.setOnRefreshListener(new RefreshListViewWithWebservice() {

            @Override
            public Object refreshing() {
                // TODO Auto-generated method stub
                String returncode = "ok";
                if (requestWebServiceThread == null) {
                    requestWebService();
                }
                return returncode;
            }

            @Override
            public void refreshed(Object obj) {
                // TODO Auto-generated method stub

            }
        });
        requestWebService();
    }

    private void requestWebService() {
        ecardHistroyList = new ArrayList<EcardHistroy>();
        ecardInfo = (EcardInfo) getIntent().getSerializableExtra("ecardInfo");
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "GetCardBalanceByUserCardNo";
                String endPoint = "ECard";
                JSONObject balanceHistoryJsonParam = new JSONObject();
                try {
                    balanceHistoryJsonParam.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    balanceHistoryJsonParam.put("UserCardNo", ecardInfo.getUserEcardNo());
                    balanceHistoryJsonParam.put("CardType", ecardInfo.getUserEcardType());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, balanceHistoryJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    JSONArray historyArray = null;
                    int code = 0;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        try {
                            historyArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        for (int i = 0; i < historyArray.length(); i++) {
                            JSONObject historyJson = null;
                            try {
                                historyJson = historyArray.getJSONObject(i);
                            } catch (JSONException e) {
                            }
                            int balanceID = 0;
                            int actionMode = 0;
                            String amount = "";
                            String balance = "";
                            String actionModeName = "";//充值或者支出的具体动作名称
                            String createTime = "";//充值或者支出的时间
                            int actionType = 0;//0.账户进钱   1.账户出钱
                            int changeType = 0;
                            try {
                                if (historyJson.has("BalanceID") && !historyJson.isNull("BalanceID"))
                                    balanceID = historyJson.getInt("BalanceID");
                                if (historyJson.has("ActionMode") && !historyJson.isNull("ActionMode"))
                                    actionMode = historyJson.getInt("ActionMode");
                                if (historyJson.has("Amount") && !historyJson.isNull("Amount"))
                                    amount = historyJson.getString("Amount");
                                if (historyJson.has("Balance") && !historyJson.isNull("Balance"))
                                    balance = historyJson.getString("Balance");
                                if (historyJson.has("ActionModeName") && !historyJson.isNull("ActionModeName"))
                                    actionModeName = historyJson.getString("ActionModeName");
                                if (historyJson.has("CreateTime") && !historyJson.isNull("CreateTime"))
                                    createTime = historyJson.getString("CreateTime");
                                if (historyJson.has("ActionType") && !historyJson.isNull("ActionType"))
                                    actionType = historyJson.getInt("ActionType");
                                if (historyJson.has("ChangeType") && !historyJson.isNull("ChangeType"))
                                    changeType = historyJson.getInt("ChangeType");
                            } catch (JSONException e) {
                            }
                            EcardHistroy ecardHistroy = new EcardHistroy();
                            ecardHistroy.setBalanceID(balanceID);
                            ecardHistroy.setActionMode(actionMode);
                            ecardHistroy.setAmount(amount);
                            ecardHistroy.setBalance(balance);
                            ecardHistroy.setActionModeName(actionModeName);
                            ecardHistroy.setCreateTime(createTime);
                            ecardHistroy.setActionType(actionType);
                            ecardHistroy.setChangeType(changeType);
                            ecardHistroyList.add(ecardHistroy);
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

    // 查看消费
    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position,
                            long id) {
        // TODO Auto-generated method stub
        if (position != 0) {
            if (position != 0) {
                int balanceID = ecardHistroyList.get(position - 1).getBalanceID();
                int cardType = ecardInfo.getUserEcardType();
                int changeType = ecardHistroyList.get(position - 1).getChangeType();
                Intent destIntent = new Intent(this, EcardHistoryDetailActivity.class);
                destIntent.putExtra("balanceID", balanceID);
                destIntent.putExtra("cardType", cardType);
                destIntent.putExtra("changeType", changeType);
                startActivity(destIntent);
            }
        }
    }
}
