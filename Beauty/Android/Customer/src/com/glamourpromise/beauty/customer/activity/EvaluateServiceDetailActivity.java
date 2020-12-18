package com.glamourpromise.beauty.customer.activity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RatingBar;
import android.widget.RatingBar.OnRatingBarChangeListener;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.EvaluateServiceInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

import android.view.View.OnClickListener;

public class EvaluateServiceDetailActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String REVIEW_NAME = "Review";
	private static final String GET_REVIEW_DETAIL = "GetReviewDetail";
	private static final String GET_REVIEW_DETAIL_TG = "GetReviewDetailForTG";
	private static final String GET_EDIT_REVIEW = "EditReview";
	private static final int GET_REVIEW_DETAIL_FLAG=1;
	private static final int GET_EDIT_REVIEW_FLAG=2;
	int flag;
	private TextView evaluateServiceNameText,evaluateServiceTime,evaluateServiceResponsibleNameText,evaluateServiceNum;
	EvaluateServiceInfo evaluateServiceInfo;
	long groupNo;
	LinearLayout listTMLinearLayout;
	LayoutInflater layoutInflater;
	TableLayout listTMTablelayout;
	RatingBar ratingbar;
	EditText evaluateServiceRemarkEdit;
	int fromSource;
	RelativeLayout headLayout;
	Button evaluateServiceSubmit;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.evaluate_service_detail);
		layoutInflater = LayoutInflater.from(this);
		Intent it = getIntent();
		groupNo=it.getLongExtra("GroupNo", 0);
		fromSource=it.getIntExtra("FROM_SOURCE", 0);
		initView();
	}
	
	private void initView(){
		headLayout=(RelativeLayout) findViewById(R.id.head_layout);
		evaluateServiceSubmit = (Button) findViewById(R.id.evaluate_service_submit);
		evaluateServiceSubmit.setOnClickListener(this);
		evaluateServiceNameText=(TextView) findViewById(R.id.evaluate_service_name);
		evaluateServiceTime=(TextView)findViewById(R.id.evaluate_service_time);
		evaluateServiceNum=(TextView) findViewById(R.id.evaluate_service_num);
		listTMLinearLayout = (LinearLayout) findViewById(R.id.list_tm_linearlayout);
		listTMTablelayout=(TableLayout) findViewById(R.id.list_tm_tablelayout);
		evaluateServiceRemarkEdit = (EditText) findViewById(R.id.evaluate_service_remark_edit);
		
		ratingbar=(RatingBar) findViewById(R.id.ratingbarId);
		ScrollView evaluateDetailScrollView=((ScrollView)findViewById(R.id.appointment_detail_scroll_view));
		LayoutParams layoutParams=(LayoutParams)evaluateDetailScrollView.getLayoutParams();
		if(fromSource!=1){
			((TextView)findViewById(R.id.navigation_title_text)).setText("发表评价");
			ratingbar.setOnRatingBarChangeListener(new OnRatingBarChangeListener() {
			@Override
			public void onRatingChanged(RatingBar ratingBar, float rating,
					boolean fromUser) {
				if((int)rating==0){
					ratingbar.setRating(1);
				}
			}
			});
			findViewById(R.id.btn_main_back).setOnClickListener(this);
			findViewById(R.id.btn_main_home).setOnClickListener(this);
			layoutParams.setMargins(0,0,0,5);
		}
		if(fromSource==1){
			ratingbar.setIsIndicator(true);
			
			headLayout.setVisibility(View.GONE);
			evaluateServiceSubmit.setVisibility(View.GONE);
			evaluateServiceRemarkEdit.setTextColor(Color.BLACK);
			evaluateServiceRemarkEdit.setEnabled(false);
			layoutParams.setMargins(0,0,0,120);
		}
		evaluateDetailScrollView.setLayoutParams(layoutParams);
		flag=GET_REVIEW_DETAIL_FLAG;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	private void initData(){
	    evaluateServiceNameText.setText(evaluateServiceInfo.getServiceName());
		evaluateServiceTime.setText(evaluateServiceInfo.getTgEndTime());
		if(evaluateServiceInfo.getTgTotalCount()==0){
			evaluateServiceNum.setText("服务"+evaluateServiceInfo.getTgFinishedCount()+"次/不限次");
		}else{
		    evaluateServiceNum.setText("服务"+evaluateServiceInfo.getTgFinishedCount()+"次/"+"共"+evaluateServiceInfo.getTgTotalCount()+"次");
		}
		if(evaluateServiceInfo.getComment()!=null && !(("").equals(evaluateServiceInfo.getComment())) && !(("null").equals(evaluateServiceInfo.getComment()))){
			evaluateServiceRemarkEdit.setText(evaluateServiceInfo.getComment());
		}else{
			evaluateServiceRemarkEdit.setHint("请输入评价");
		}
		if(fromSource==1){
			ratingbar.setRating(evaluateServiceInfo.getSatisfaction());
			evaluateServiceRemarkEdit.setHint("");
		}
		if(evaluateServiceInfo.getListTM()!=null && evaluateServiceInfo.getListTM().size()>0){
			listTMTablelayout.setVisibility(View.VISIBLE);
			int listTMSize = evaluateServiceInfo.getListTM().size();
			for(int i=0; i<listTMSize; i++){
				final int pos=i;
				View evaluateServiceDetailTM=layoutInflater.inflate(R.xml.evaluate_service_detail_tm,null);
				TextView evaluateServiceTMNameText=(TextView) evaluateServiceDetailTM.findViewById(R.id.evaluate_service_tm_name_text);
				evaluateServiceTMNameText.setText(evaluateServiceInfo.getListTM().get(i).getSubServiceName());
				final RatingBar evaluateServiceTMRatingbar=(RatingBar) evaluateServiceDetailTM.findViewById(R.id.evaluate_service_tm_ratingbar);
				EditText evaluateServiceTmRemark=(EditText) evaluateServiceDetailTM.findViewById(R.id.evaluate_service_tm_remark);
				if(evaluateServiceInfo.getListTM().get(i).getComment()!=null && !(("").equals(evaluateServiceInfo.getListTM().get(i).getComment())) && !(("null").equals(evaluateServiceInfo.getComment()))){
					evaluateServiceTmRemark.setText(evaluateServiceInfo.getListTM().get(i).getComment());
				}else{
					evaluateServiceTmRemark.setHint("请输入评价");
				}
				if(fromSource==1){
					evaluateServiceTmRemark.setTextColor(Color.BLACK);
					evaluateServiceTMRatingbar.setRating(evaluateServiceInfo.getListTM().get(i).getSatisfaction());
					evaluateServiceTMRatingbar.setIsIndicator(true);
					evaluateServiceTmRemark.setEnabled(false);
					evaluateServiceTmRemark.setHint("");
				}else{
					evaluateServiceInfo.getListTM().get(pos).setSatisfaction(5);
				}
				
				evaluateServiceTMRatingbar.setOnRatingBarChangeListener(new OnRatingBarChangeListener() {
					@Override
					public void onRatingChanged(RatingBar ratingBar, float rating,
							boolean fromUser) {
						if((int)rating==0){
							evaluateServiceTMRatingbar.setRating(1);
						}
						evaluateServiceInfo.getListTM().get(pos).setSatisfaction((int)rating);
					}
				});
				
				listTMLinearLayout.addView(evaluateServiceDetailTM);
			}
		}else{
			listTMTablelayout.setVisibility(View.GONE);
		}
	}
	
	@Override
	protected void onResume() {
		super.onResume();
	}
		
	@Override
	public void onClick(View v) {
		super.onClick(v);
		switch (v.getId()) {
        case R.id.evaluate_service_submit:
        	flag=GET_EDIT_REVIEW_FLAG;
    		super.asyncRefrshView(this);
        	break;
		default:
			break;
		}
	}
	

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		String methodName = "";
		if(flag==GET_REVIEW_DETAIL_FLAG){
			if(fromSource==1){
				methodName=GET_REVIEW_DETAIL_TG;
			}else{
				methodName=GET_REVIEW_DETAIL;
			}
			try {
				para.put("GroupNo",groupNo);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}else if(flag==GET_EDIT_REVIEW_FLAG){
			methodName=GET_EDIT_REVIEW;
			JSONObject editReviewObject = new JSONObject();
			JSONArray listTMArray = new JSONArray();
			try {
				editReviewObject.put("GroupNo", evaluateServiceInfo.getGroupNo());
				editReviewObject.put("Satisfaction", ratingbar.getRating());
				editReviewObject.put("Comment", evaluateServiceRemarkEdit.getText().toString());
			} catch (JSONException e) {
				e.printStackTrace();
			}
			if(evaluateServiceInfo.getListTM()!=null && evaluateServiceInfo.getListTM().size()>0){
				int listTMSize = evaluateServiceInfo.getListTM().size();
				for(int i=0; i<listTMSize; i++){
					JSONObject tMObject = new JSONObject();
					try {
						tMObject.put("TreatmentID", evaluateServiceInfo.getListTM().get(i).getTreatmentID());
						tMObject.put("Satisfaction", ((RatingBar)listTMLinearLayout.getChildAt(i).findViewById(R.id.evaluate_service_tm_ratingbar)).getRating());
						tMObject.put("Comment", ((EditText)listTMLinearLayout.getChildAt(i).findViewById(R.id.evaluate_service_tm_remark)).getText().toString());
					} catch (JSONException e) {
						e.printStackTrace();
					}
					listTMArray.put(tMObject);
				}
			}
			try {
				para.put("mTGReview", editReviewObject);
				para.put("listTMReview", listTMArray);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(REVIEW_NAME, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(REVIEW_NAME, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(flag==GET_REVIEW_DETAIL_FLAG){
					evaluateServiceInfo=EvaluateServiceInfo.parseListTMByJson(response.getStringData());
					initData();
				}else if(flag==GET_EDIT_REVIEW_FLAG){
					AlertDialog paymentDialog = new AlertDialog.Builder(this)
					.setTitle("评价成功")
					.setPositiveButton(this.getString(R.string.confirm),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface arg0, int arg1) {
									Intent it=new Intent();
									setResult(RESULT_OK, it);
									finish();
								}
							})
					.show();
			    paymentDialog.setCancelable(false);
					
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			}
		}
	}
}
