package com.glamourpromise.beauty.customer.activity;

import org.json.JSONException;
import org.json.JSONObject;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.TGDetail;
import com.glamourpromise.beauty.customer.bean.TreatmentInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.StatusUtil;

public class ServiceOrderTreatmentServiceDetailActivity extends BaseActivity
		implements OnClickListener, IConnectTask {
	private TreatmentInformation treatmentInformation;
	private static final String CATEGORY_NAME = "Order";
	private static final String GET_TG_DETAIL = "GetTGDetail";
	private TGDetail tgDetail = new TGDetail();
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_service_order_treatment_detail);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	@Override
	protected void onResume() {
		super.onResume();
	}

	private void initView() {
		TextView branchName = (TextView) findViewById(R.id.branch_name);
		TextView treatmentCodeView = (TextView) findViewById(R.id.treatment_code);
		TextView treatmentStatus = (TextView) findViewById(R.id.treatment_status);
		TextView startTime = (TextView) findViewById(R.id.start_time);
		TextView endTime = (TextView) findViewById(R.id.end_time);
		RelativeLayout endTimeLayout = (RelativeLayout) findViewById(R.id.activity_service_order_treatment_detail_end_time_layout);
		TableLayout remark = (TableLayout) findViewById(R.id.activity_service_order_treatment_remark_layout);
		TextView remarkContent = (TextView) findViewById(R.id.activity_service_order_treatment_remark);

		treatmentCodeView.setText(tgDetail.getGroupNo());
		branchName.setText(getIntent().getStringExtra("BranchName"));
		treatmentStatus.setText(StatusUtil.TGStatusUtil(this,
				tgDetail.getTGStatus()));
		startTime.setText(tgDetail.getTGStartTime());
		if (tgDetail.getTGStatus() == 2 || tgDetail.getTGStatus() == 5) {
			endTimeLayout.setVisibility(View.VISIBLE);
			endTime.setText(tgDetail.getTGEndTime());

		} else
			endTimeLayout.setVisibility(View.GONE);

		if (!tgDetail.getRemark().equals("")
				&& !tgDetail.getRemark().equals("anyType{}")) {
			remark.setVisibility(View.VISIBLE);
			remarkContent.setText(tgDetail.getRemark());
		} else {
			remark.setVisibility(View.GONE);
		}
		
		super.dismissProgressDialog();
		// treamentCodeView.setText(treatmentInformation.getTreatmentCode());
		//
		// if(!treatmentInformation.getTime().equals("") ||
		// !treatmentInformation.getTime().equals("anyType{}")){
		// contactTime.setText(treatmentInformation.getTime());
		// }
		//
		// TextView contactStatus = (TextView)
		// findViewById(R.id.treatment_status);
		// if (treatmentInformation.getIsComplete()==0 ) {
		// contactStatus.setText(this.getString(R.string.order_status_1));
		// } else if (treatmentInformation.getIsComplete()==1 ||
		// treatmentInformation.getIsComplete()==4) {
		// contactStatus.setText(this.getString(R.string.order_status_2));
		// }else if(treatmentInformation.getIsComplete()==2) {
		// contactStatus.setText(this.getString(R.string.order_status_4));
		// }
		//
		// if (!treatmentInformation.getRemark().equals("") &&
		// !treatmentInformation.getRemark().equals("anyType{}")) {
		// TextView remark = (TextView) findViewById(R.id.treatment_remark);
		// remark.setText(treatmentInformation.getRemark());
		// }
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("GroupNo", getIntent().getStringExtra("GroupNo"));
			para.put("OrderID", getIntent().getIntExtra("OrderID", 0));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(
				CATEGORY_NAME, GET_TG_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_TG_DETAIL,
				para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				tgDetail.parseByJson(response.getStringData());
				initView();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),
						response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),
						Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}

		
	}

	@Override
	public void parseData(WebApiResponse response) {

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
//		switch (v.getId()) {
//		case R.id.btn_main_left_menu:
//			leftMenu.getMenu().toggle();
//			break;
//		case R.id.btn_main_back:
//			finish();
//			break;
//		default:
//			break;
//		}
	}

}
