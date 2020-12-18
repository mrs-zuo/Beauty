package com.glamourpromise.beauty.customer.activity;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.AccountInformation;
import com.glamourpromise.beauty.customer.bean.CustomerInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.squareup.picasso.Picasso;

public class PersonMessageActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGROY_NAME="Customer";
	private static final String GET_CUSTOMER_BASIC="getCustomerBasic";
	private CustomerInfo  customer;
	private LayoutInflater layoutInflater;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_person_message);
		super.setTitle(getString(R.string.person_message));
		findViewById(R.id.person_message_edit_btn).setOnClickListener(this);
		layoutInflater=LayoutInflater.from(this);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject jsonParam=new JSONObject();
		try {
			jsonParam.put("ImageWidth",60);
			jsonParam.put("ImageHeight",60);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGROY_NAME,GET_CUSTOMER_BASIC,jsonParam.toString());
		WebApiRequest request = new WebApiRequest(CATEGROY_NAME,GET_CUSTOMER_BASIC,jsonParam.toString(),header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				customer = CustomerInfo.parseCustomerInfoByJson(response.getStringData());
				refreshView();
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
	protected void refreshView(){
		ImageView headImageView=(ImageView) findViewById(R.id.head_iamge);
		if(customer.getHeadImageUrl()==null || customer.getHeadImageUrl().equals(""))
			headImageView.setBackgroundResource(R.drawable.head_image_null);
		else
			Picasso.with(this).load(customer.getHeadImageUrl()).error(R.drawable.head_image_null).into(headImageView);
		((TextView)findViewById(R.id.person_message_name_text)).setText(customer.getCustomerName());
		if(customer.getGender()==0)
			((TextView)findViewById(R.id.person_message_gender_text)).setText("女");
		else if(customer.getGender()==1)
			((TextView)findViewById(R.id.person_message_gender_text)).setText("男");
		((TextView)findViewById(R.id.person_message_login_mobile_text)).setText(customer.getLoginMobile());
		LinearLayout personMessageResponsiblePersonLinearLayout=(LinearLayout)findViewById(R.id.person_message_responsible_person_linearLayout);
		personMessageResponsiblePersonLinearLayout.removeAllViews();
		for(final AccountInformation account:customer.getAccountInformationList()){
			View accountView=layoutInflater.inflate(R.xml.responsible_person_list_item,null);
			TextView branchNameText=(TextView) accountView.findViewById(R.id.branch_name);
			TextView accountNameText=(TextView) accountView.findViewById(R.id.responsible_person_name);
			branchNameText.setText(account.getBranch().getName());
			accountNameText.setText(account.getAccountName());
			accountView.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					Intent destIntent=new Intent(PersonMessageActivity.this,AccountDetailActivity.class);
					destIntent.putExtra("AccountID",account.getAccountID());
					startActivity(destIntent);
				}
			});
			personMessageResponsiblePersonLinearLayout.addView(layoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			personMessageResponsiblePersonLinearLayout.addView(accountView);
		}
	}
	@Override
	protected void onResume() {
		super.onResume();
	}
	
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		return super.onKeyDown(keyCode, event);
	}
	
	@Override
	protected void onRestart() {
		super.onRestart();
		super.asyncRefrshView(this);
	}	
	@Override
	public void onClick(View v) {
		super.onClick(v);
		switch (v.getId()) {
		case R.id.person_message_edit_btn:
			Intent destIntent=new Intent(this,EditPersonMessageActivity.class);
			destIntent.putExtra("customerID",customer.getCustomerID());
			destIntent.putExtra("customerName",customer.getCustomerName());
			destIntent.putExtra("customerHeadImage",customer.getHeadImageUrl());
			destIntent.putExtra("customerGender",customer.getGender());
			startActivity(destIntent);
			break;
		}
	}
}
