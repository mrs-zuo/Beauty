package com.glamourpromise.beauty.customer.activity;

import org.json.JSONException;
import org.json.JSONObject;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.TreatmentDetail;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.StatusUtil;

public class TreatmentDetailActivity extends BaseActivity implements
		IConnectTask {
	private static final String CATEGORY_NAME = "Order";
	private static final String GET_TREATMENT_DETAIL = "GetTreatmentDetail";
	private TreatmentDetail tmDetail = new TreatmentDetail();
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_service_treatment_detail);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("TreatmentID", getIntent().getIntExtra("TreatmentID", 0));
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_TREATMENT_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_TREATMENT_DETAIL, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				tmDetail.parseByJson(response.getStringData());
				initView();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}

	}

	@Override
	public void parseData(WebApiResponse response) {
	}

	private void initView() {
		TextView treatmentID = (TextView) findViewById(R.id.treatment_serial_number);
		TextView status = (TextView) findViewById(R.id.treatment_status);
		TextView startTime = (TextView) findViewById(R.id.start_time_content);
		TextView endTime = (TextView) findViewById(R.id.end_time_content);
		RelativeLayout endTimeLayout = (RelativeLayout) findViewById(R.id.activity_service_treatment_detail_end_time_layout);
		treatmentID.setText(tmDetail.getID());
		status.setText(StatusUtil.TGStatusUtil(this, tmDetail.getStatus()));
		startTime.setText(tmDetail.getStartTime());
		if (tmDetail.getStatus() == 2 || tmDetail.getStatus() == 5) {
			endTimeLayout.setVisibility(View.VISIBLE);
			endTime.setText(tmDetail.getFinishTime());
		} else
			endTimeLayout.setVisibility(View.GONE);
		super.dismissProgressDialog();

	}
}
