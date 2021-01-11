package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByWebserviceThread;
import com.GlamourPromise.Beauty.adapter.AccountListAdapter;
import com.GlamourPromise.Beauty.adapter.LabelListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AccountDetailInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.LabelInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.GetServerAccountListDataTaskImpl;
import com.GlamourPromise.Beauty.implementation.GetTagListTaskImpl;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil.AdvancedFilterFlag;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;

@SuppressLint("ResourceType")
public class AccountListActivity extends BaseActivity implements OnItemClickListener, OnClickListener {
    private AccountListActivityHandler mHandler = new AccountListActivityHandler(this);
    public static final String COMPANY_ACCOUNT_LIST_FLAG = "1", BRANCH_ACCOUNT_LIST_FLAG = "2";
    private Thread getAccountListDataThread;
    private UserInfoApplication userInfoApplication;
    private ProgressDialog progressDialog;
    private ListView AccountListView;
    private ArrayList<AccountDetailInfo> accountList;
    private AccountListAdapter accountListAdapter;
    private GetServerAccountListDataTaskImpl getAccountListTask;
    private GetBackendServerDataByJsonThread getDataThread;
    private GetTagListTaskImpl getTagListTask;
    private String flag, branchID;
    private PackageUpdateUtil packageUpdateUtil;
    private ImageButton groupFilterBtn;
    private Dialog groupFilterDialog;
    private ArrayList<Integer> lastSelectGroup;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AccountListActivityHandler extends Handler {
        private final AccountListActivity accountListActivity;

        private AccountListActivityHandler(AccountListActivity activity) {
            WeakReference<AccountListActivity> weakReference = new WeakReference<AccountListActivity>(activity);
            accountListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (accountListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            accountListActivity.dismissProgressDialog();
            if (accountListActivity.getAccountListDataThread != null) {
                accountListActivity.getAccountListDataThread.interrupt();
                accountListActivity.getAccountListDataThread = null;
            }
            if (accountListActivity.getDataThread != null) {
                accountListActivity.getDataThread.interrupt();
                accountListActivity.getDataThread = null;
            }
            if (accountListActivity.getAccountListTask != null) {
                accountListActivity.getAccountListTask = null;
            }
            if (msg.what == Constant.GET_DATA_NULL
                    || msg.what == Constant.PARSING_ERROR) {
                DialogUtil.createShortDialog(accountListActivity, "您的网络貌似不给力，请重试");
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION
                    || msg.what == Constant.GET_WEB_DATA_FALSE) {
                DialogUtil.createShortDialog(accountListActivity, (String) msg.obj);
            } else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
                accountListActivity.accountList.clear();
                accountListActivity.accountList.addAll((ArrayList<AccountDetailInfo>) msg.obj);
                accountListActivity.accountListAdapter.notifyDataSetChanged();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(accountListActivity, accountListActivity.getString(R.string.login_error_message));
                accountListActivity.userInfoApplication.exitForLogin(accountListActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + accountListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(accountListActivity);
                accountListActivity.packageUpdateUtil = new PackageUpdateUtil(accountListActivity, accountListActivity.mHandler, fileCache, downloadFileUrl, false, accountListActivity.userInfoApplication);
                accountListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                accountListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = accountListActivity.getFileStreamPath(filename);
                file.getName();
                accountListActivity.packageUpdateUtil.showInstallDialog();
            }
            //获得分组列表并显示选择分组列表对话框
            else if (msg.what == 6) {

                ArrayList<LabelInfo> labelList = (ArrayList<LabelInfo>) msg.obj;
                LayoutInflater inflater = accountListActivity.getLayoutInflater();
                View groupFilterDialogLayout = inflater.inflate(R.xml.group_filter_dialog, null);
                ListView groupListView = (ListView) groupFilterDialogLayout.findViewById(R.id.group_listview);
                String lastSelectString = accountListActivity.getConditionFromSharePre();
                if (lastSelectString != null && !"".equals(lastSelectString)) {
                    accountListActivity.lastSelectGroup = new ArrayList<Integer>();
                    String[] lastSelectGroups = lastSelectString.split("\\|");
                    for (int i = 0; i < lastSelectGroups.length; i++) {
                        if (lastSelectGroups[i] != null && !"".equals(lastSelectGroups[i]))
                            accountListActivity.lastSelectGroup.add(Integer.parseInt(lastSelectGroups[i]));
                    }
                }
                final LabelListAdapter labellistAdapter = new LabelListAdapter(accountListActivity, labelList, accountListActivity.lastSelectGroup, 10);

                groupListView.setAdapter(labellistAdapter);
                accountListActivity.groupFilterDialog = new AlertDialog.Builder(accountListActivity, R.style.CustomerAlertDialog).setTitle(accountListActivity.getString(R.string.group_filter))
                        .setView(groupListView).setPositiveButton(accountListActivity.getString(R.string.confirm),
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface arg0, int arg1) {
                                        HashMap<Integer, LabelInfo> selectLabelInfoHashMap = labellistAdapter.getSelectLabelHashMap();
                                        StringBuffer selectLabelStr = new StringBuffer();
                                        for (int i = 0; i < selectLabelInfoHashMap.size(); i++) {
                                            LabelInfo labelInfo = selectLabelInfoHashMap.get(i);
                                            selectLabelStr.append("|" + labelInfo.getID() + "|");
                                        }
                                        //请求分组筛选的员工列表
                                        accountListActivity.getAccountListData(selectLabelStr.toString());
                                        accountListActivity.saveConditionToSharePre(selectLabelStr.toString());
                                    }
                                })
                        .setNegativeButton(accountListActivity.getString(R.string.cancel), new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).setNeutralButton("清除", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                if (accountListActivity.lastSelectGroup != null && accountListActivity.lastSelectGroup.size() > 0)
                                    accountListActivity.lastSelectGroup.clear();
                                accountListActivity.saveConditionToSharePre("");
                                accountListActivity.getAccountListData("");
                                //labellistAdapter.notifyDataSetChanged();
                            }
                        }).create();
                accountListActivity.groupFilterDialog.setCancelable(false);
                accountListActivity.groupFilterDialog.show();
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
        setContentView(R.layout.activity_account_list);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        flag = getIntent().getStringExtra("Flag");
        branchID = getIntent().getStringExtra("BranchID");
        ((TextView) findViewById(R.id.branch_list_title_text)).setText(getIntent().getStringExtra("BranchName") + getString(R.string.account_list_title));
        userInfoApplication = (UserInfoApplication) getApplication();
        AccountListView = (ListView) findViewById(R.id.account_listview);
        AccountListView.setOnItemClickListener(this);
        accountList = new ArrayList<AccountDetailInfo>();
        accountListAdapter = new AccountListAdapter(this, accountList);
        AccountListView.setAdapter(accountListAdapter);
        //按组筛选按钮
        groupFilterBtn = (ImageButton) findViewById(R.id.group_filter_btn);
        groupFilterBtn.setOnClickListener(this);
        getAccountListData(getConditionFromSharePre());
    }

    //将筛选分组条件记忆在本地文件
    private void saveConditionToSharePre(String tagIDs) {
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userInfoApplication.getAccountInfo().getAccountId(), userInfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.BusinessGroupFlag);
        sharePreUtil.putAdvancedFilter(key, tagIDs);
    }

    private String getConditionFromSharePre() {
        String tagIDs = "";
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userInfoApplication.getAccountInfo().getAccountId(), userInfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.BusinessGroupFlag);
        tagIDs = sharePreUtil.getValue(key);
        return tagIDs;
    }

    private void getAccountListData(final String tagIDs) {
        if (getAccountListDataThread == null) {
            showProgressDialog();
            createGetAccountListTask(tagIDs);
            getAccountListDataThread = new GetBackendServerDataByWebserviceThread(getAccountListTask, true);
            getAccountListDataThread.start();
        }
    }

    private void createGetAccountListTask(final String tagIDs) {
        if (getAccountListTask == null) {
            JSONObject accountListJsonParam = new JSONObject();
            try {
                accountListJsonParam.put("CompanyID", String.valueOf(userInfoApplication.getAccountInfo().getCompanyId()));
                if (flag.equals(COMPANY_ACCOUNT_LIST_FLAG)) {
                    accountListJsonParam.put("BranchID", "0");
                } else if (flag.equals(BRANCH_ACCOUNT_LIST_FLAG)) {
                    accountListJsonParam.put("BranchID", branchID);
                }
                accountListJsonParam.put("CustomerID", "0");
                accountListJsonParam.put("Flag", flag);
                if (userInfoApplication.getScreenWidth() == 720) {
                    accountListJsonParam.put("ImageWidth", String.valueOf(100));
                    accountListJsonParam.put("ImageHeight", String.valueOf(100));
                } else if (userInfoApplication.getScreenWidth() == 480) {
                    accountListJsonParam.put("ImageWidth", String.valueOf(66));
                    accountListJsonParam.put("ImageHeight", String.valueOf(66));
                } else if (userInfoApplication.getScreenWidth() == 1080) {
                    accountListJsonParam.put("ImageWidth", String.valueOf(150));
                    accountListJsonParam.put("ImageHeight", String.valueOf(150));
                } else if (userInfoApplication.getScreenWidth() == 1536) {
                    accountListJsonParam.put("ImageWidth", String.valueOf(183));
                    accountListJsonParam.put("ImageHeight", String.valueOf(183));
                } else {
                    accountListJsonParam.put("ImageWidth", String.valueOf(80));
                    accountListJsonParam.put("ImageHeight", String.valueOf(80));
                }
                accountListJsonParam.put("TagIDs", tagIDs);
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            getAccountListTask = new GetServerAccountListDataTaskImpl(accountListJsonParam, mHandler, userInfoApplication);
        }
    }

    private void showProgressDialog() {
        if (progressDialog == null) {
            progressDialog = ProgressDialogUtil.createProgressDialog(this);
        }
    }

    private void dismissProgressDialog() {
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
    }

    //获得分组列表
    private void getGroupData() {
        if (getDataThread == null) {
            getDataThread = new GetBackendServerDataByJsonThread(getBackendServerDataTask());
            getDataThread.start();
        }
    }

    private GetTagListTaskImpl getBackendServerDataTask() {
        if (getTagListTask == null) {
            getTagListTask = new GetTagListTaskImpl(mHandler, userInfoApplication, 2);
        }
        return getTagListTask;
    }

    @Override
    public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
        // TODO Auto-generated method stub
        Intent intent = new Intent(this, AccountDetailActivity.class);
        intent.putExtra("AccountID", accountList.get(arg2).getAccountID());
        startActivity(intent);
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.group_filter_btn) {
            getGroupData();
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            mHandler = null;
        }
        dismissProgressDialog();
        if (getAccountListDataThread != null) {
            getAccountListDataThread.interrupt();
            getAccountListDataThread = null;
        }
        if (getDataThread != null) {
            getDataThread.interrupt();
            getDataThread = null;
        }
        if (getAccountListTask != null) {
            getAccountListTask = null;
        }
    }
}
