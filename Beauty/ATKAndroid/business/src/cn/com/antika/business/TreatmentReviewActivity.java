package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.Treatment;
import cn.com.antika.bean.TreatmentReview;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 操作评价
 * */
public class TreatmentReviewActivity extends BaseActivity {
	private TreatmentReviewActivityHandler mHandler = new TreatmentReviewActivityHandler(this);
	private ProgressDialog progressDialog;
	private Thread requestWebServiceThread;
	private Treatment treatment;
	private TextView treatmentReviewContentText;
	private ImageButton reviewStar1, reviewStar2, reviewStar3, reviewStar4,reviewStar5;
	private UserInfoApplication userinfoApplication;
	private PackageUpdateUtil packageUpdateUtil;
	int fromSource;
	String  treatmentGroupNo;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_treatment_review);
		Intent it=getIntent();
		treatment = (Treatment) it.getSerializableExtra("treatment");
		treatmentGroupNo=it.getStringExtra("GroupNo");
		fromSource=it.getIntExtra("FROM_SOURCE", 0);
		treatmentReviewContentText = (TextView) findViewById(R.id.treatment_review_content_text);
		reviewStar1 = (ImageButton) findViewById(R.id.review_star_1);
		reviewStar2 = (ImageButton) findViewById(R.id.review_star_2);
		reviewStar3 = (ImageButton) findViewById(R.id.review_star_3);
		reviewStar4 = (ImageButton) findViewById(R.id.review_star_4);
		reviewStar5 = (ImageButton) findViewById(R.id.review_star_5);
		userinfoApplication=UserInfoApplication.getInstance();
		initView();
	}

	private static class TreatmentReviewActivityHandler extends Handler {
		private final TreatmentReviewActivity treatmentReviewActivity;

		private TreatmentReviewActivityHandler(TreatmentReviewActivity activity) {
			WeakReference<TreatmentReviewActivity> weakReference = new WeakReference<TreatmentReviewActivity>(activity);
			treatmentReviewActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (treatmentReviewActivity.progressDialog != null) {
				treatmentReviewActivity.progressDialog.dismiss();
				treatmentReviewActivity.progressDialog = null;
			}
			if (message.what == 1) {
				TreatmentReview treatmentReview = (TreatmentReview) message.obj;
				if (treatmentReview != null) {
					if (treatmentReview.getSatisfaction() > 0) {
						int Satisfaction = treatmentReview.getSatisfaction();
						switch (Satisfaction) {
							case 1:
								treatmentReviewActivity.reviewStar1.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								break;
							case 2:
								treatmentReviewActivity.reviewStar1.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar2.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								break;
							case 3:
								treatmentReviewActivity.reviewStar1.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar2.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar3.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								break;
							case 4:
								treatmentReviewActivity.reviewStar1.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar2.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar3.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar4.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								break;
							case 5:
								treatmentReviewActivity.reviewStar1.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar2.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar3.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar4.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								treatmentReviewActivity.reviewStar5.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
								break;
						}
					}
					if (!(("").equals(treatmentReview.getComment()))) {
						treatmentReviewActivity.treatmentReviewContentText.setText(treatmentReview.getComment());
					} else {
						treatmentReviewActivity.treatmentReviewContentText.setText("顾客暂时没有评价");
					}
				} else {
					treatmentReviewActivity.treatmentReviewContentText.setText("顾客暂时没有评价");
				}
			} else if (message.what == 0)
				DialogUtil.createShortDialog(treatmentReviewActivity, "您的网络貌似不给力，请重试");
			else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(treatmentReviewActivity, treatmentReviewActivity.getString(R.string.login_error_message));
				treatmentReviewActivity.userinfoApplication.exitForLogin(treatmentReviewActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + treatmentReviewActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(treatmentReviewActivity);
				treatmentReviewActivity.packageUpdateUtil = new PackageUpdateUtil(treatmentReviewActivity, treatmentReviewActivity.mHandler, fileCache, downloadFileUrl, false, treatmentReviewActivity.userinfoApplication);
				treatmentReviewActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				treatmentReviewActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = treatmentReviewActivity.getFileStreamPath(filename);
				file.getName();
				treatmentReviewActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (treatmentReviewActivity.requestWebServiceThread != null) {
				treatmentReviewActivity.requestWebServiceThread.interrupt();
				treatmentReviewActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "";
				String endPoint =  "Review";
				JSONObject treatmentReviewJsonParam=new JSONObject();
				if(fromSource==TreatmentGroupDetailTabActivity.TREATEMENT_TG){
					methodName = "GetReviewDetail";
					try {
						treatmentReviewJsonParam.put("GroupNo",Long.parseLong(treatmentGroupNo));
					} catch (JSONException e) {
					}
				}else if(fromSource==TreatmentDetailActivity.TREATEMENT_TM){
					methodName = "GetReviewDetailForTM";
					try {
						treatmentReviewJsonParam.put("TreatmentID",treatment.getId());
					} catch (JSONException e) {
					}
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,treatmentReviewJsonParam.toString(),userinfoApplication);
				if(serverRequestResult==null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else{
					int code=0;
					JSONObject resultJson=null;
					JSONObject dataJson=null;
					try {
						resultJson=new JSONObject(serverRequestResult);
						code=resultJson.getInt("Code");
					} catch (JSONException e) {
					}
					if(code==1){
						try {
							dataJson=resultJson.getJSONObject("Data");
						} catch (JSONException e) {
						}
						int satisfaction = 0;
						String reviewContent = "";
						try {
							if(dataJson!=null){
								if (dataJson.has("Satisfaction") && !dataJson.isNull("Satisfaction"))
									satisfaction = dataJson.getInt("Satisfaction");
								if (dataJson.has("Comment") && !dataJson.isNull("Comment"))
									reviewContent = dataJson.getString("Comment");
							}
						} catch (JSONException e) {
						}
						TreatmentReview treatmentReview = new TreatmentReview();
						treatmentReview.setSatisfaction(satisfaction);
						treatmentReview.setComment(reviewContent);
						Message message = new Message();
						message.obj = treatmentReview;
						message.what = 1;
						mHandler.sendMessage(message);
					}
					else
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
		if(progressDialog!=null){
			progressDialog.dismiss();
			progressDialog=null;
		}
	}
}
