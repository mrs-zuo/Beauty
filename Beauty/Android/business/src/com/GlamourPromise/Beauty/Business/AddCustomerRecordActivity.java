package com.GlamourPromise.Beauty.Business;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.LabelInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
import com.GlamourPromise.Beauty.util.DateButton;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.LabelView;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Timer;

/*
 * 我的顾客--增加新的记录
 * */
public class AddCustomerRecordActivity extends BaseActivity implements
        OnClickListener {
    private AddCustomerRecordActivityHandler mHandler = new AddCustomerRecordActivityHandler(this);
    private EditText recordTimeText, recordProblemText, recordSuggestionText;
    private RelativeLayout changeCustomerScanStatusLayout;
    private ImageButton customerScanStatusBtn, addCustomerRecordBtn;
    private int customerScanStatus, userRole;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userInfoApplication;
    private Timer dialogTimer;
    private HashMap<Integer, LabelInfo> labelViewList;
    private LinearLayout labelContainer;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_add_customer_record);
        recordTimeText = (EditText) findViewById(R.id.new_record_time);
        recordTimeText.setOnClickListener(this);
        recordTimeText.setInputType(InputType.TYPE_NULL);
        recordProblemText = (EditText) findViewById(R.id.new_record_problem);
        recordSuggestionText = (EditText) findViewById(R.id.new_record_suggestion);
        addCustomerRecordBtn = (ImageButton) findViewById(R.id.add_customer_record_make_sure_btn);
        // 用户查看权限
        customerScanStatusBtn = (ImageButton) findViewById(R.id.customer_scan_status_image);
        customerScanStatusBtn.setOnClickListener(this);
        changeCustomerScanStatusLayout = (RelativeLayout) findViewById(R.id.change_customer_scan_status_layout);
        changeCustomerScanStatusLayout.setOnClickListener(this);
        customerScanStatusBtn
                .setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
        customerScanStatus = 0;
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userRole = getIntent().getIntExtra("USER_ROLE", 0);
        addCustomerRecordBtn.setOnClickListener(this);
        userInfoApplication = UserInfoApplication.getInstance();
        //添加标签
        ((ImageView) findViewById(R.id.add_label_icon)).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                // addLabel();
                Intent intent = new Intent(AddCustomerRecordActivity.this, LabelListActivity.class);
                intent.putExtra(LabelListActivity.LIMIT_NUM_FLAG, true);
                ArrayList<Integer> ids = new ArrayList<Integer>();
                if (labelViewList != null && labelViewList.size() > 0) {
                    for (int i = 0; i < labelViewList.size(); i++) {
                        ids.add(Integer.valueOf(labelViewList.get(i).getID()));
                    }
                }
                intent.putExtra(LabelListActivity.SELECT_LABEL_LIST_ID, ids);
                startActivityForResult(intent, 4);
            }
        });
        labelContainer = (LinearLayout) findViewById(R.id.label_container);
    }

    @SuppressWarnings("unchecked")
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == 4 && resultCode == RESULT_OK) {
            labelViewList = (HashMap<Integer, LabelInfo>) data.getSerializableExtra(LabelListActivity.LABEL_CONTENT_LIST);
            if (labelViewList != null) {
                labelContainer.removeAllViews();
                LabelView labelView;
                LabelInfo labelInfo;
                LinearLayout.LayoutParams rlp = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
                rlp.setMargins(10, 5, 10, 5);
                for (int i = 0; i < labelViewList.size(); i++) {
                    labelInfo = labelViewList.get(i);
                    labelView = new LabelView(this);
                    labelView.setLabelContent(labelInfo.getLabelName());
                    final int pos = i;
                    labelView.setTag(String.valueOf(i));
                    labelView.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View arg0) {
                            // TODO Auto-generated method stub
                            deleteLabel(pos);
                        }
                    });
                    labelContainer.addView(labelView, rlp);
                }
            }
        }
    }

    //删除标签
    private void deleteLabel(final int postion) {
        AlertDialog paymentDialog = new AlertDialog.Builder(this)
                .setTitle("是否删除该标签？")
                .setPositiveButton(getString(R.string.confirm),
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface parent, int arg1) {
                                // TODO Auto-generated method stub
                                labelViewList.remove(postion);
                                LabelView tmp;
                                for (int i = 0; i < labelContainer.getChildCount(); i++) {
                                    if (((String) labelContainer.getChildAt(i).getTag()).equals(String.valueOf(postion))) {
                                        tmp = (LabelView) labelContainer.getChildAt(i);
                                        labelContainer.removeView(tmp);
                                        ;
                                    }
                                }
                            }
                        })
                .setNegativeButton(getString(R.string.cancel), null).show();
        paymentDialog.setCancelable(false);
    }

    private static class AddCustomerRecordActivityHandler extends Handler {
        private final AddCustomerRecordActivity addCustomerRecordActivity;

        public AddCustomerRecordActivityHandler(AddCustomerRecordActivity activity) {
            WeakReference<AddCustomerRecordActivity> weakReference = new WeakReference<AddCustomerRecordActivity>(activity);
            addCustomerRecordActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (addCustomerRecordActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (addCustomerRecordActivity.progressDialog != null) {
                addCustomerRecordActivity.progressDialog.dismiss();
                addCustomerRecordActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(addCustomerRecordActivity, "提示信息", "顾客咨询记录添加成功！");
                alertDialog.show();
                Intent intent = new Intent(addCustomerRecordActivity, CustomerRecordActivity.class);
                intent.putExtra("USER_ROLE", addCustomerRecordActivity.userRole);
                addCustomerRecordActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, addCustomerRecordActivity.dialogTimer, addCustomerRecordActivity, intent);
                addCustomerRecordActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 0)
                DialogUtil.createMakeSureDialog(addCustomerRecordActivity, "提示信息", "操作失败，请重试");
            else if (msg.what == 2)
                DialogUtil.createShortDialog(addCustomerRecordActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(addCustomerRecordActivity, addCustomerRecordActivity.getString(R.string.login_error_message));
                addCustomerRecordActivity.userInfoApplication.exitForLogin(addCustomerRecordActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + addCustomerRecordActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(addCustomerRecordActivity);
                addCustomerRecordActivity.packageUpdateUtil = new PackageUpdateUtil(addCustomerRecordActivity, addCustomerRecordActivity.mHandler, fileCache, downloadFileUrl, false, addCustomerRecordActivity.userInfoApplication);
                addCustomerRecordActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                addCustomerRecordActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = addCustomerRecordActivity.getFileStreamPath(filename);
                file.getName();
                addCustomerRecordActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (addCustomerRecordActivity.requestWebServiceThread != null) {
                addCustomerRecordActivity.requestWebServiceThread.interrupt();
                addCustomerRecordActivity.requestWebServiceThread = null;
            }
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.change_customer_scan_status_layout:
                if (customerScanStatus == 1) {
                    customerScanStatus = 0;
                    customerScanStatusBtn
                            .setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
                } else {
                    customerScanStatus = 1;
                    customerScanStatusBtn
                            .setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
                }
                break;
            case R.id.customer_scan_status_image:
                if (customerScanStatus == 1) {
                    customerScanStatus = 0;
                    customerScanStatusBtn
                            .setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
                } else {
                    customerScanStatus = 1;
                    customerScanStatusBtn
                            .setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
                }
                break;
            case R.id.add_customer_record_make_sure_btn:
                if (userInfoApplication.getSelectedCustomerID() == 0) {
                    DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
                } else {
                    if (recordTimeText.getText().toString() == null
                            || ("").equals(recordTimeText.getText().toString())) {
                        DialogUtil.createMakeSureDialog(this, "提示信息", "请输入记录时间");
                    } else if (recordProblemText.getText().toString() == null
                            || ("").equals(recordProblemText.getText().toString())) {
                        DialogUtil.createMakeSureDialog(this, "提示信息", "请输入咨询信息");
                    } else {
                        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                        progressDialog.setMessage(getString(R.string.please_wait));
                        progressDialog.show();
                        requestWebServiceThread = new Thread() {
                            @Override
                            public void run() {
                                // TODO Auto-generated method stub
                                String methodName = "addRecord";
                                String endPoint = "Record";
                                JSONObject addRecordJsonParam = new JSONObject();
                                try {
                                    addRecordJsonParam.put("CustomerID", String.valueOf(userInfoApplication.getSelectedCustomerID()));
                                    addRecordJsonParam.put("RecordTime", recordTimeText.getText().toString());
                                    addRecordJsonParam.put("Problem", recordProblemText.getText().toString());
                                    addRecordJsonParam.put("Suggestion", recordSuggestionText.getText().toString());
                                    if (customerScanStatus == 1)
                                        addRecordJsonParam.put("IsVisible", true);
                                    else if (customerScanStatus == 0)
                                        addRecordJsonParam.put("IsVisible", false);
                                    StringBuilder tagIDs = new StringBuilder("");
                                    if (labelViewList != null && labelViewList.size() > 0) {
                                        for (int i = 0; i < labelViewList.size(); i++) {
                                            tagIDs.append("|");
                                            tagIDs.append(labelViewList.get(i).getID());
                                        }
                                        tagIDs.append("|");
                                    }
                                    addRecordJsonParam.put("TagIDs", tagIDs.toString());
                                } catch (JSONException e) {
                                }
                                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addRecordJsonParam.toString(), userInfoApplication);
                                if (serverRequestResult == null || serverRequestResult.equals(""))
                                    mHandler.sendEmptyMessage(2);
                                else {
                                    int code = 0;
                                    JSONObject resultJson = null;
                                    try {
                                        resultJson = new JSONObject(serverRequestResult);
                                        code = resultJson.getInt("Code");
                                    } catch (JSONException e) {
                                        code = 0;
                                    }
                                    if (code == 1) {
                                        mHandler.sendEmptyMessage(1);
                                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                        mHandler.sendEmptyMessage(code);
                                    else {
                                        mHandler.sendEmptyMessage(0);
                                    }
                                }
                            }
                        };
                        requestWebServiceThread.start();
                    }
                }
                break;
            case R.id.new_record_time:
                DateButton dateButton = new DateButton(this, (EditText) view, Constant.DATE_DIALOG_SHOW_TYPE_DEFAULT, null);
                dateButton.datePickerDialog();
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
            mHandler = null;
        }
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
        System.gc();
    }
}
