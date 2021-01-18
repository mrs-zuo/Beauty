package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EvaluateServiceInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.TreatmentReview;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 服务评价
 * */
public class TreatmentGroupReviewActivity extends BaseActivity {
    private TreatmentGroupReviewActivityHandler mHandler = new TreatmentGroupReviewActivityHandler(this);
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;

    String groupNo;
    private TextView evaluateServiceNameText, evaluateServiceTime, evaluateServiceNum;
    EvaluateServiceInfo evaluateServiceInfo;
    LinearLayout listTMLinearLayout;
    LayoutInflater layoutInflater;
    TableLayout listTMTablelayout;
    RatingBar ratingbar;
    EditText evaluateServiceRemarkEdit;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.evaluate_service_detail);
        Intent it = getIntent();
        groupNo = it.getStringExtra("GroupNo");
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class TreatmentGroupReviewActivityHandler extends Handler {
        private final TreatmentGroupReviewActivity treatmentGroupReviewActivity;

        private TreatmentGroupReviewActivityHandler(TreatmentGroupReviewActivity activity) {
            WeakReference<TreatmentGroupReviewActivity> weakReference = new WeakReference<TreatmentGroupReviewActivity>(activity);
            treatmentGroupReviewActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (treatmentGroupReviewActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (treatmentGroupReviewActivity.progressDialog != null) {
                treatmentGroupReviewActivity.progressDialog.dismiss();
                treatmentGroupReviewActivity.progressDialog = null;
            }
            if (treatmentGroupReviewActivity.requestWebServiceThread != null) {
                treatmentGroupReviewActivity.requestWebServiceThread.interrupt();
                treatmentGroupReviewActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                treatmentGroupReviewActivity.initData();
            } else if (message.what == 0)
                DialogUtil.createShortDialog(treatmentGroupReviewActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(treatmentGroupReviewActivity, treatmentGroupReviewActivity.getString(R.string.login_error_message));
                treatmentGroupReviewActivity.userinfoApplication.exitForLogin(treatmentGroupReviewActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + treatmentGroupReviewActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(treatmentGroupReviewActivity);
                treatmentGroupReviewActivity.packageUpdateUtil = new PackageUpdateUtil(treatmentGroupReviewActivity, treatmentGroupReviewActivity.mHandler, fileCache, downloadFileUrl, false, treatmentGroupReviewActivity.userinfoApplication);
                treatmentGroupReviewActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                treatmentGroupReviewActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = treatmentGroupReviewActivity.getFileStreamPath(filename);
                file.getName();
                treatmentGroupReviewActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void initView() {
        evaluateServiceNameText = (TextView) findViewById(R.id.evaluate_service_name);
        evaluateServiceTime = (TextView) findViewById(R.id.evaluate_service_time);
        //evaluateServiceResponsibleNameText=(TextView)findViewById(R.id.evaluate_service_responsible_name_text);
        evaluateServiceNum = (TextView) findViewById(R.id.evaluate_service_num);
        listTMLinearLayout = (LinearLayout) findViewById(R.id.list_tm_linearlayout);
        listTMTablelayout = (TableLayout) findViewById(R.id.list_tm_tablelayout);
        evaluateServiceRemarkEdit = (EditText) findViewById(R.id.evaluate_service_remark_edit);
        ratingbar = (RatingBar) findViewById(R.id.ratingbarId);
        ratingbar.setEnabled(false);
        evaluateServiceRemarkEdit.setTextColor(Color.BLACK);
        evaluateServiceRemarkEdit.setEnabled(false);
//		ratingbar.setOnRatingBarChangeListener(new OnRatingBarChangeListener() {
//			@Override
//			public void onRatingChanged(RatingBar ratingBar, float rating,
//					boolean fromUser) {
//				if((int)rating==0){
//					ratingbar.setRating(1);
//				}
//			}
//		});
        layoutInflater = LayoutInflater.from(this);
        getReviewDetail();
    }

    private void initData() {
        evaluateServiceNameText.setText(evaluateServiceInfo.getServiceName());
        evaluateServiceTime.setText(evaluateServiceInfo.getTgEndTime());
        //evaluateServiceResponsibleNameText.setText(evaluateServiceInfo.getResponsiblePersonName());
        ratingbar.setRating(evaluateServiceInfo.getSatisfaction());
        if (evaluateServiceInfo.getTgTotalCount() == 0) {
            evaluateServiceNum.setText("服务" + evaluateServiceInfo.getTgFinishedCount() + "次/不限次");
        } else {
            evaluateServiceNum.setText("服务" + evaluateServiceInfo.getTgFinishedCount() + "次/" + "共" + evaluateServiceInfo.getTgTotalCount() + "次");
        }
        if (evaluateServiceInfo.getComment() != null && !(("").equals(evaluateServiceInfo.getComment())) && !(("null").equals(evaluateServiceInfo.getComment()))) {
            evaluateServiceRemarkEdit.setText(evaluateServiceInfo.getComment());
        } else {
            evaluateServiceRemarkEdit.setHint("");
        }
        if (evaluateServiceInfo.getListTM() != null && evaluateServiceInfo.getListTM().size() > 0) {
            listTMTablelayout.setVisibility(View.VISIBLE);
            int listTMSize = evaluateServiceInfo.getListTM().size();
            for (int i = 0; i < listTMSize; i++) {
                final int pos = i;
                View evaluateServiceDetailTM = layoutInflater.inflate(R.xml.evaluate_service_detail_tm, null);
                TextView evaluateServiceTMNameText = (TextView) evaluateServiceDetailTM.findViewById(R.id.evaluate_service_tm_name_text);
                evaluateServiceTMNameText.setText(evaluateServiceInfo.getListTM().get(i).getSubServiceName());
                EditText evaluateServiceTmRemark = (EditText) evaluateServiceDetailTM.findViewById(R.id.evaluate_service_tm_remark);
                evaluateServiceTmRemark.setEnabled(false);
                evaluateServiceTmRemark.setTextColor(Color.BLACK);
                if (evaluateServiceInfo.getListTM().get(i).getComment() != null && !(("").equals(evaluateServiceInfo.getListTM().get(i).getComment())) && !(("null").equals(evaluateServiceInfo.getComment()))) {
                    evaluateServiceTmRemark.setText(evaluateServiceInfo.getListTM().get(i).getComment());
                } else {
                    evaluateServiceRemarkEdit.setHint("");
                }
                RatingBar evaluateServiceTMRatingbar = (RatingBar) evaluateServiceDetailTM.findViewById(R.id.evaluate_service_tm_ratingbar);
                evaluateServiceTMRatingbar.setEnabled(false);
                evaluateServiceTMRatingbar.setRating(evaluateServiceInfo.getListTM().get(i).getSatisfaction());
//					evaluateServiceTMRatingbar.setOnRatingBarChangeListener(new OnRatingBarChangeListener() {
//						@Override
//						public void onRatingChanged(RatingBar ratingBar, float rating,
//								boolean fromUser) {
//							if((int)rating==0){
//								evaluateServiceTMRatingbar.setRating(1);
//							}
//							evaluateServiceInfo.getListTM().get(pos).setSatisfaction((int)rating);
//						}
//					});
                listTMLinearLayout.addView(evaluateServiceDetailTM);
            }
        } else {
            listTMTablelayout.setVisibility(View.GONE);
        }
    }

    private void getReviewDetail() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String endPoint = "Review";
                String methodName = "GetReviewDetail";
                JSONObject treatmentReviewJsonParam = new JSONObject();
                try {
                    treatmentReviewJsonParam.put("GroupNo", groupNo);
                } catch (JSONException e) {
                }

                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, treatmentReviewJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(0);
                else {
                    int code = 0;
                    JSONObject resultJson = null;
                    JSONObject evaluateServiceObject = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        try {
                            evaluateServiceObject = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                        }
                        ArrayList<TreatmentReview> listTM = new ArrayList<TreatmentReview>();
                        evaluateServiceInfo = new EvaluateServiceInfo();
                        try {
                            if (evaluateServiceObject != null) {
                                if (evaluateServiceObject.has("ServiceName")) {
                                    evaluateServiceInfo.setServiceName(evaluateServiceObject.getString("ServiceName"));
                                }
                                if (evaluateServiceObject.has("Satisfaction")) {
                                    evaluateServiceInfo.setSatisfaction(evaluateServiceObject.getInt("Satisfaction"));
                                }
                                if (evaluateServiceObject.has("TGEndTime")) {
                                    evaluateServiceInfo.setTgEndTime(evaluateServiceObject.getString("TGEndTime"));
                                }
                                if (evaluateServiceObject.has("TGFinishedCount")) {
                                    evaluateServiceInfo.setTgFinishedCount(evaluateServiceObject.getInt("TGFinishedCount"));
                                }
                                if (evaluateServiceObject.has("TGTotalCount")) {
                                    evaluateServiceInfo.setTgTotalCount(evaluateServiceObject.getInt("TGTotalCount"));
                                }
                                if (evaluateServiceObject.has("ResponsiblePersonName")) {
                                    evaluateServiceInfo.setResponsiblePersonName(evaluateServiceObject.getString("ResponsiblePersonName"));
                                }
                                if (evaluateServiceObject.has("Comment")) {
                                    evaluateServiceInfo.setComment(evaluateServiceObject.getString("Comment"));
                                }
                                if (evaluateServiceObject.has("GroupNo")) {
                                    evaluateServiceInfo.setGroupNo(evaluateServiceObject.getLong("GroupNo"));
                                }
                                if (evaluateServiceObject.has("listTM") && !evaluateServiceObject.isNull("listTM")) {
                                    JSONArray listTMArray = new JSONArray();
                                    listTMArray = evaluateServiceObject.getJSONArray("listTM");
                                    if (listTMArray.length() > 0) {
                                        for (int i = 0; i < listTMArray.length(); i++) {
                                            JSONObject listTMObject = null;
                                            listTMObject = (JSONObject) listTMArray.get(i);
                                            TreatmentReview evaluateServiceListTMInfo = new TreatmentReview();
                                            if (listTMObject.has("TMExectorName")) {
                                                evaluateServiceListTMInfo.setTmExectorName(listTMObject.getString("TMExectorName"));
                                            }
                                            if (listTMObject.has("SubServiceName")) {
                                                evaluateServiceListTMInfo.setSubServiceName(listTMObject.getString("SubServiceName"));
                                            }
                                            if (listTMObject.has("Comment")) {
                                                evaluateServiceListTMInfo.setComment(listTMObject.getString("Comment"));
                                            }
                                            if (listTMObject.has("Satisfaction")) {
                                                evaluateServiceListTMInfo.setSatisfaction(listTMObject.getInt("Satisfaction"));
                                            }
                                            if (listTMObject.has("TreatmentID")) {
                                                evaluateServiceListTMInfo.setTreatmentID(listTMObject.getInt("TreatmentID"));
                                            }
                                            listTM.add(evaluateServiceListTMInfo);
                                        }
                                        evaluateServiceInfo.setListTM(listTM);
                                    }
                                }

                            }
                        } catch (JSONException e) {
                        }
                        Message message = new Message();
                        message.what = 1;
                        mHandler.sendMessage(message);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    protected void onDestroy() {
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
