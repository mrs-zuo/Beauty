package cn.com.antika.business;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.Treatment;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.OrderOperationUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.webservice.WebServiceUtil;

public class TreatmentServiceDetailActivity extends BaseActivity implements
        OnClickListener {
    private TreatmentServiceDetailActivityHandler mHandler = new TreatmentServiceDetailActivityHandler(this);
    private TextView treatmentServiceDetailStartTime;
    private TextView treatmentServiceDetailEndTime;
    private TextView treatmentServiceDetailStatus;
    private EditText treatmentServiceDetailRemark;
    private Treatment treatment;
    private UserInfoApplication userinfoApplication;
    private Button editTreatmentServiceDetailBtn;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        setContentView(R.layout.activity_treatment_service_detail);
        initView();
    }

    protected void initView() {
        treatment = (Treatment) getIntent().getSerializableExtra("treatment");
        int orderEditFlag = getIntent().getIntExtra("orderEditFlag", 0);
        treatmentServiceDetailStatus = (TextView) findViewById(R.id.treatment_service_detail_status);
        treatmentServiceDetailRemark = (EditText) findViewById(R.id.treatment_service_detail_remark_text);
        editTreatmentServiceDetailBtn = (Button) findViewById(R.id.edit_treatment_service_detail_make_sure_btn);
        editTreatmentServiceDetailBtn.setOnClickListener(this);
        treatmentServiceDetailStartTime = (TextView) findViewById(R.id.treatment_service_detail_start_time);
        treatmentServiceDetailEndTime = (TextView) findViewById(R.id.treatment_service_detail_end_time);
        userinfoApplication = UserInfoApplication.getInstance();
        if (orderEditFlag == 0)
            treatmentServiceDetailRemark.setEnabled(false);
        else if (orderEditFlag == 1) {
            treatmentServiceDetailRemark.setOnFocusChangeListener(new OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (hasFocus)
                        treatmentServiceDetailRemark.setCursorVisible(true);
                }
            });
            treatmentServiceDetailRemark.addTextChangedListener(new TextWatcher() {
                @Override
                public void onTextChanged(CharSequence newText, int start, int before, int count) {
                    editTreatmentServiceDetailBtn.setVisibility(View.VISIBLE);
                }

                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                }

                @Override
                public void afterTextChanged(Editable s) {

                }
            });
        }
        getTreatmentDetail();
    }

    protected void getTreatmentDetail() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetTreatmentDetail";
                String endPoint = "order";
                JSONObject getTreatmentDetailJsonParam = new JSONObject();
                try {
                    getTreatmentDetailJsonParam.put("TreatmentID", treatment.getId());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getTreatmentDetailJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    int code = 0;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        JSONObject treatmentDetailJson = null;
                        try {
                            treatmentDetailJson = resultJson.getJSONObject("Data");
                            if (treatmentDetailJson.has("ID")) {
                                //treatment.setId(treatmentDetailJson.getInt("ID"));
                                treatment.setTreatmentCode(treatmentDetailJson.getString("ID"));
                            }
                            if (treatmentDetailJson.has("Status"))
                                treatment.setIsCompleted(treatmentDetailJson.getInt("Status"));
                            if (treatmentDetailJson.has("StartTime"))
                                treatment.setStartTime(treatmentDetailJson.getString("StartTime"));
                            if (treatmentDetailJson.has("FinishTime"))
                                treatment.setEndTime(treatmentDetailJson.getString("FinishTime"));
                            if (treatmentDetailJson.has("Remark"))
                                treatment.setRemark(treatmentDetailJson.getString("Remark"));
                        } catch (JSONException e) {
                        }
                        mHandler.sendEmptyMessage(3);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message message = new Message();
                        message.what = 4;
                        try {
                            message.obj = resultJson.getString("Message");
                        } catch (JSONException e) {
                            message.obj = "";
                        }
                        mHandler.sendMessage(message);
                    }

                }
            }
        };
        requestWebServiceThread.start();
    }

    private static class TreatmentServiceDetailActivityHandler extends Handler {
        private final TreatmentServiceDetailActivity treatmentServiceDetailActivity;

        private TreatmentServiceDetailActivityHandler(TreatmentServiceDetailActivity activity) {
            WeakReference<TreatmentServiceDetailActivity> weakReference = new WeakReference<TreatmentServiceDetailActivity>(activity);
            treatmentServiceDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (treatmentServiceDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 1) {
                treatmentServiceDetailActivity.treatmentServiceDetailRemark.setCursorVisible(false);
                treatmentServiceDetailActivity.editTreatmentServiceDetailBtn.setVisibility(View.GONE);
                DialogUtil.createShortDialog(treatmentServiceDetailActivity, "操作记录更新成功！");
            } else if (msg.what == 0) {
                DialogUtil.createShortDialog(treatmentServiceDetailActivity, "操作记录更新失败，请重试!");
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(treatmentServiceDetailActivity, "您的网络貌似不给力，请重试");
                //获取操作的详情
            else if (msg.what == 3) {
                ((TextView) treatmentServiceDetailActivity.findViewById(R.id.treatment_service_code_text)).setText(treatmentServiceDetailActivity.treatment.getTreatmentCode());
                treatmentServiceDetailActivity.treatmentServiceDetailStartTime.setText(treatmentServiceDetailActivity.treatment.getStartTime());
                int treatmentStatus = treatmentServiceDetailActivity.treatment.getIsCompleted();
                if (treatmentStatus != 1)
                    treatmentServiceDetailActivity.treatmentServiceDetailEndTime.setText(treatmentServiceDetailActivity.treatment.getEndTime());
                treatmentServiceDetailActivity.treatmentServiceDetailStatus.setText(OrderOperationUtil.getTreatmentStatus(treatmentStatus));
                treatmentServiceDetailActivity.treatmentServiceDetailRemark.setText(treatmentServiceDetailActivity.treatment.getRemark());
            } else if (msg.what == 4)
                DialogUtil.createShortDialog(treatmentServiceDetailActivity, (String) msg.obj);
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(treatmentServiceDetailActivity, treatmentServiceDetailActivity.getString(R.string.login_error_message));
                treatmentServiceDetailActivity.userinfoApplication.exitForLogin(treatmentServiceDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + treatmentServiceDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(treatmentServiceDetailActivity);
                treatmentServiceDetailActivity.packageUpdateUtil = new PackageUpdateUtil(treatmentServiceDetailActivity, treatmentServiceDetailActivity.mHandler, fileCache, downloadFileUrl, false, treatmentServiceDetailActivity.userinfoApplication);
                treatmentServiceDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                treatmentServiceDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = treatmentServiceDetailActivity.getFileStreamPath(filename);
                file.getName();
                treatmentServiceDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    public void onClick(View view) {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "updateTreatmentRemark";
                String endPoint = "order";
                JSONObject updateTreatmentRemarkJsonParam = new JSONObject();
                try {
                    updateTreatmentRemarkJsonParam.put("TreatmentID", treatment.getId());
                    updateTreatmentRemarkJsonParam.put("Remark", treatmentServiceDetailRemark.getText().toString());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, updateTreatmentRemarkJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    int code = 0;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        treatment.setRemark(treatmentServiceDetailRemark.getText().toString());
                        mHandler.sendEmptyMessage(1);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else
                        mHandler.sendEmptyMessage(0);
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            this.finish();
        }
        return super.onKeyDown(keyCode, event);
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
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
