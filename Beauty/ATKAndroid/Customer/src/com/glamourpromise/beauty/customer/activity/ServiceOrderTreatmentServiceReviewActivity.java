package com.glamourpromise.beauty.customer.activity;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class ServiceOrderTreatmentServiceReviewActivity extends BaseActivity
		implements OnClickListener,IConnectTask {
	private final static String UPDATE_REVIEW_PROMPT = "正在更新最新评论...";
	private final static String INPUT_REVIEW_PROMPT = "请输入评论";
	
	private static final String CATEGORY_NAME = "Review";
	private static final String GET_REVIEW = "getReviewDetailForTM";
	private static final String Add_REVIEW = "addReview";
	private static final String UPDATE_REVIEW = "updateReview";
	
	private static final int GET_REVIEW_FLAG = 1;
	private static final int ADD_REVIEW_FLAG = 2;
	private static final int UPDATE_REVIEW_FLAG = 3;
	
	private int taskFlag;

	
	private int treatmentID;
	private String reviewID;
	private String satisfaction = "0";
	private String comment = "";

	private String newSatisfaction = "0";
	private String newComment = "";

	private boolean hasComment = false;// 是否已经评论
	private boolean isEdit = true;// 是否允许编辑，默认允许

	private EditText commentEditText;
	private TextView inputCount;
	private ImageButton editButton;
	private ImageButton reviewCancel;
	private ImageButton reviewconfirm;
	private ImageButton firstStar;
	private ImageButton secondStar;
	private ImageButton thirdStar;
	private ImageButton fourthStar;
	private ImageButton fifthStar;
	private ProgressDialog progressDialog;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_service_order_treatment_review);
		treatmentID = getIntent().getIntExtra("TreatmentID", 0);
		getIntent().getStringExtra("OrderID");
		commentEditText = (EditText) findViewById(R.id.comment_edit);
		inputCount = (TextView) findViewById(R.id.text_count);
		editButton = (ImageButton) findViewById(R.id.review_edit_icon);
		reviewCancel = (ImageButton) findViewById(R.id.review_cancel);
		reviewconfirm = (ImageButton) findViewById(R.id.review_confirm);
		firstStar = (ImageButton) findViewById(R.id.review_star_1);
		secondStar = (ImageButton) findViewById(R.id.review_star_2);
		thirdStar = (ImageButton) findViewById(R.id.review_star_3);
		fourthStar = (ImageButton) findViewById(R.id.review_star_4);
		fifthStar = (ImageButton) findViewById(R.id.review_star_5);
		editButton.setVisibility(View.GONE);
		editButton.setOnClickListener(this);
		reviewCancel.setOnClickListener(this);
		reviewconfirm.setOnClickListener(this);
		commentEditText.setEnabled(false);
		commentEditText.setTextColor(Color.BLACK);
		commentEditText.setText("暂无评论！");
		inputCount.setVisibility(View.GONE);	
		submitTask(GET_REVIEW_FLAG);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.review_edit_icon:
			if (!isEdit) {
				changeEditStatus(true);
				commentEditText.setFocusableInTouchMode(true);
				commentEditText.setFocusable(true);
				commentEditText.requestFocus();
			}
			break;
		case R.id.review_cancel:
			if (hasComment) {
				showCommentDetail();
			} else {
				showCommentDetail();
				changeEditStatus(false);
			}

			break;
		case R.id.review_confirm:
			newComment = String.valueOf(commentEditText.getText());
			if (hasComment) {
				submitTask(UPDATE_REVIEW_FLAG);
			} else {
				if(newComment.equals("") && newSatisfaction.equals("0") && satisfaction.equals("0"))
					DialogUtil.createShortDialog(this, INPUT_REVIEW_PROMPT);
				else
					submitTask(ADD_REVIEW_FLAG);
			}

			break;
		case R.id.review_star_1:
			if (isEdit) {
				newSatisfaction = "1";
				firstStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				secondStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
				thirdStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
				fourthStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
				fifthStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			}
			break;
		case R.id.review_star_2:
			if (isEdit) {
				newSatisfaction = "2";
				firstStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				secondStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				thirdStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
				fourthStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
				fifthStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			}
			break;
		case R.id.review_star_3:
			if (isEdit) {
				newSatisfaction = "3";
				firstStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				secondStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				thirdStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				fourthStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
				fifthStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			}
			break;
		case R.id.review_star_4:
			if (isEdit) {
				newSatisfaction = "4";
				firstStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				secondStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				thirdStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				fourthStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				fifthStar
						.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			}
			break;
		case R.id.review_star_5:
			if (isEdit) {
				newSatisfaction = "5";
				firstStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				secondStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				thirdStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				fourthStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
				fifthStar
						.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
			}
			break;
		default:
			break;
		}
	}
	
	private void submitTask(int flag){
		taskFlag = flag;
		if(taskFlag == GET_REVIEW_FLAG){
			super.showProgressDialog();
		}else if(taskFlag == ADD_REVIEW_FLAG || taskFlag == UPDATE_REVIEW_FLAG){
			progressDialog = new ProgressDialog(this);
			progressDialog.setMessage(UPDATE_REVIEW_PROMPT);
			progressDialog.show();
			progressDialog.setCancelable(false);
		}
		super.asyncRefrshView(this);
	}

	private void changeEditStatus(boolean isOpen) {
		if (isOpen) {
			isEdit = true;
			reviewCancel.setVisibility(View.VISIBLE);
			reviewconfirm.setVisibility(View.VISIBLE);
		} else {
			reviewCancel.setVisibility(View.GONE);
			reviewconfirm.setVisibility(View.GONE);
			isEdit = false;
		}
	}

	private void showCommentDetail() {
		// 如果已经评论，默认隐藏编辑按钮
		/*if (hasComment) {
			changeEditStatus(false);
		}*/

		inputCount.setText(String.valueOf(comment.length()) + "/200");
		if (!comment.equals("anyType{}")) {
			commentEditText.setText(comment);
		} else {
			commentEditText.setText("");
		}

		commentEditText.setFocusable(false);
		commentEditText.setFocusableInTouchMode(false);

		int starCount = Integer.valueOf(satisfaction);

		Log.v("satisfaction", satisfaction);

		if (starCount > 0) {
			firstStar
					.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
		}
		if (starCount > 1) {
			secondStar
					.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
		}
		if (starCount > 2) {
			thirdStar
					.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
		}
		if (starCount > 3) {
			fourthStar
					.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
		}
		if (starCount > 4) {
			fifthStar
					.setBackgroundResource(R.drawable.evaluate_selected_big_icon);
		}
		if (starCount == 0) {
			firstStar
					.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			secondStar
					.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			thirdStar
					.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			fourthStar
					.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
			fifthStar
					.setBackgroundResource(R.drawable.evaluate_unselected_big_icon);
		}
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String catoryName = CATEGORY_NAME;
		String methodName = "";
		JSONObject para = new JSONObject();
		if(taskFlag == GET_REVIEW_FLAG){
			methodName = GET_REVIEW;
			try {
				para.put("TreatmentID", treatmentID);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if(taskFlag == UPDATE_REVIEW_FLAG){
			methodName = UPDATE_REVIEW;
			try {
				para.put("ReviewID", reviewID);
				para.put("Satisfaction", Integer.valueOf(newSatisfaction));
				para.put("Comment", newComment);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}else if(taskFlag == ADD_REVIEW_FLAG){
			methodName = Add_REVIEW;
			try {
				para.put("TreatmentID", treatmentID);
				para.put("Satisfaction", newSatisfaction);
				para.put("Comment", newComment);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(progressDialog != null){
			progressDialog.dismiss();
		}
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				
				if(taskFlag == GET_REVIEW_FLAG){
					try {
						JSONObject data = new JSONObject(response.getStringData());
						if(data.has("ReviewID")){
							hasComment = true;
							reviewID = data.getString("ReviewID");
						}
						if(data.has("Satisfaction")){
							satisfaction = data.getString("Satisfaction");
							newSatisfaction = satisfaction;
						}
						if(data.has("Comment")){
							comment = data.getString("Comment");
						}
						showCommentDetail();
						
					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}else if(taskFlag == UPDATE_REVIEW_FLAG){
					comment = newComment;
					satisfaction = newSatisfaction;
					hasComment = true;
					DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
					showCommentDetail();
				}else if(taskFlag == ADD_REVIEW_FLAG){
					comment = newComment;
					satisfaction = newSatisfaction;
					hasComment = true;
					reviewID = response.getStringData();
					DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
					showCommentDetail();
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
		
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}
}
