package cn.com.antika.business;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.TreatmentGroup;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.OrderOperationUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.webservice.WebServiceUtil;

public class TreatmentGroupDetailActivity extends BaseActivity implements
        OnClickListener {
    private TreatmentGroupDetailActivityHandler mHandler = new TreatmentGroupDetailActivityHandler(this);
    private TextView treatmentGroupDetailStartTime;
    private TextView treatmentGroupDetailEndTime;
    private TextView treatmentGroupDetailStatus;
    private EditText treatmentGroupDetailRemark;
    private TreatmentGroup treatmentGroup;
    private UserInfoApplication userinfoApplication;
    private Button editTreatmentGroupDetailBtn;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private int orderID;
    private ImageLoader imageLoader;
    private DisplayImageOptions displayImageOptions;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_treatment_group_detail);
        initView();
    }

    protected void initView() {
        Intent intent = getIntent();
        int orderEditFlag = intent.getIntExtra("orderEditFlag", 0);
        String treatmentGroupNo = intent.getStringExtra("GroupNo");
        orderID = intent.getIntExtra("OrderID", 0);
        treatmentGroup = new TreatmentGroup();
        treatmentGroupDetailStatus = (TextView) findViewById(R.id.treatment_group_detail_status);
        treatmentGroupDetailRemark = (EditText) findViewById(R.id.treatment_group_detail_remark_text);
        editTreatmentGroupDetailBtn = (Button) findViewById(R.id.edit_treatment_group_detail_make_sure_btn);
        editTreatmentGroupDetailBtn.setOnClickListener(this);
        treatmentGroupDetailStartTime = (TextView) findViewById(R.id.treatment_group_detail_start_time);
        treatmentGroupDetailEndTime = (TextView) findViewById(R.id.treatment_group_detail_end_time);
        userinfoApplication = UserInfoApplication.getInstance();
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
        if (orderEditFlag == 0)
            treatmentGroupDetailRemark.setEnabled(false);
        else if (orderEditFlag == 1) {
            treatmentGroupDetailRemark.setOnFocusChangeListener(new OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (hasFocus)
                        treatmentGroupDetailRemark.setCursorVisible(true);
                }
            });
            treatmentGroupDetailRemark.addTextChangedListener(new TextWatcher() {
                @Override
                public void onTextChanged(CharSequence newText, int start, int before, int count) {
                    editTreatmentGroupDetailBtn.setVisibility(View.VISIBLE);
                }

                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                }

                @Override
                public void afterTextChanged(Editable s) {

                }
            });
        }
        getTreatmentGroupDetail(treatmentGroupNo);
    }

    protected void getTreatmentGroupDetail(final String treatmentGroupNo) {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetTGDetail";
                String endPoint = "order";
                JSONObject getTreatmentGroupDetailJsonParam = new JSONObject();
                try {
                    getTreatmentGroupDetailJsonParam.put("GroupNo", treatmentGroupNo);
                    getTreatmentGroupDetailJsonParam.put("OrderID", orderID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getTreatmentGroupDetailJsonParam.toString(), userinfoApplication);
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
                        JSONObject treatmentGroupDetailJson = null;
                        try {
                            treatmentGroupDetailJson = resultJson.getJSONObject("Data");
                            if (treatmentGroupDetailJson.has("GroupNo"))
                                treatmentGroup.setTreatmentGroupID(treatmentGroupDetailJson.getLong("GroupNo"));
                            if (treatmentGroupDetailJson.has("Remark"))
                                treatmentGroup.setRemark(treatmentGroupDetailJson.getString("Remark"));
                            if (treatmentGroupDetailJson.has("TGStartTime"))
                                treatmentGroup.setStartTime(treatmentGroupDetailJson.getString("TGStartTime"));
                            if (treatmentGroupDetailJson.has("TGEndTime"))
                                treatmentGroup.setEndTime(treatmentGroupDetailJson.getString("TGEndTime"));
                            if (treatmentGroupDetailJson.has("TGStatus"))
                                treatmentGroup.setStatus(treatmentGroupDetailJson.getInt("TGStatus"));
                            if (treatmentGroupDetailJson.has("BranchName"))
                                treatmentGroup.setBranchName(treatmentGroupDetailJson.getString("BranchName"));
                            if (treatmentGroupDetailJson.has("ThumbnailURL") && !treatmentGroupDetailJson.isNull("ThumbnailURL"))
                                treatmentGroup.setSignImageUrl(treatmentGroupDetailJson.getString("ThumbnailURL"));
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

    private static class TreatmentGroupDetailActivityHandler extends Handler {
        private final TreatmentGroupDetailActivity treatmentGroupDetailActivity;

        private TreatmentGroupDetailActivityHandler(TreatmentGroupDetailActivity activity) {
            WeakReference<TreatmentGroupDetailActivity> weakReference = new WeakReference<TreatmentGroupDetailActivity>(activity);
            treatmentGroupDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (treatmentGroupDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 1) {
                treatmentGroupDetailActivity.treatmentGroupDetailRemark.setCursorVisible(false);
                treatmentGroupDetailActivity.editTreatmentGroupDetailBtn.setVisibility(View.GONE);
                DialogUtil.createShortDialog(treatmentGroupDetailActivity, "服务记录更新成功！");
            } else if (msg.what == 0) {
                DialogUtil.createShortDialog(treatmentGroupDetailActivity, "服务记录更新失败，请重试!");
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(treatmentGroupDetailActivity, "您的网络貌似不给力，请重试");
                //获取操作的详情
            else if (msg.what == 3) {
                ((TextView) treatmentGroupDetailActivity.findViewById(R.id.treatment_group_code_text)).setText(String.valueOf(treatmentGroupDetailActivity.treatmentGroup.getTreatmentGroupID()));
                ((TextView) treatmentGroupDetailActivity.findViewById(R.id.treatment_service_detail_branch_name)).setText(treatmentGroupDetailActivity.treatmentGroup.getBranchName());
                treatmentGroupDetailActivity.treatmentGroupDetailStartTime.setText(treatmentGroupDetailActivity.treatmentGroup.getStartTime());
                int status = treatmentGroupDetailActivity.treatmentGroup.getStatus();
                //服务组状态不是进行中时，才有结束时间
                if (status != 1)
                    treatmentGroupDetailActivity.treatmentGroupDetailEndTime.setText(treatmentGroupDetailActivity.treatmentGroup.getEndTime());
                treatmentGroupDetailActivity.treatmentGroupDetailStatus.setText(OrderOperationUtil.getTGStatus(status));
                treatmentGroupDetailActivity.treatmentGroupDetailRemark.setText(treatmentGroupDetailActivity.treatmentGroup.getRemark());
                //顾客签字
                if (treatmentGroupDetailActivity.treatmentGroup.getSignImageUrl() != null && !"".equals(treatmentGroupDetailActivity.treatmentGroup.getSignImageUrl())) {
                    treatmentGroupDetailActivity.findViewById(R.id.treatment_service_detail_sign_image_tablelayout).setVisibility(View.VISIBLE);
                    ImageView signImage = (ImageView) treatmentGroupDetailActivity.findViewById(R.id.treatment_group_sign_image);
                    treatmentGroupDetailActivity.imageLoader.displayImage(treatmentGroupDetailActivity.treatmentGroup.getSignImageUrl().split("&")[0], signImage, treatmentGroupDetailActivity.displayImageOptions);
                } else {
                    treatmentGroupDetailActivity.findViewById(R.id.treatment_service_detail_sign_image_tablelayout).setVisibility(View.GONE);
                }
            } else if (msg.what == 4)
                DialogUtil.createShortDialog(treatmentGroupDetailActivity, (String) msg.obj);
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(treatmentGroupDetailActivity, treatmentGroupDetailActivity.getString(R.string.login_error_message));
                treatmentGroupDetailActivity.userinfoApplication.exitForLogin(treatmentGroupDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + treatmentGroupDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(treatmentGroupDetailActivity);
                treatmentGroupDetailActivity.packageUpdateUtil = new PackageUpdateUtil(treatmentGroupDetailActivity, treatmentGroupDetailActivity.mHandler, fileCache, downloadFileUrl, false, treatmentGroupDetailActivity.userinfoApplication);
                treatmentGroupDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                treatmentGroupDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = treatmentGroupDetailActivity.getFileStreamPath(filename);
                file.getName();
                treatmentGroupDetailActivity.packageUpdateUtil.showInstallDialog();
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
                String methodName = "UpdateTGRemark";
                String endPoint = "order";
                JSONObject updateTreatmentGroupRemarkJsonParam = new JSONObject();
                try {
                    updateTreatmentGroupRemarkJsonParam.put("GroupNo", String.valueOf(treatmentGroup.getTreatmentGroupID()));
                    updateTreatmentGroupRemarkJsonParam.put("Remark", treatmentGroupDetailRemark.getText().toString());
                    updateTreatmentGroupRemarkJsonParam.put("OrderID", orderID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, updateTreatmentGroupRemarkJsonParam.toString(), userinfoApplication);
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
                        treatmentGroup.setRemark(treatmentGroupDetailRemark.getText().toString());
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
