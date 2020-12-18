package com.glamourpromise.beauty.customer.fragment;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.CustomerBenefitDetailActivity;
import com.glamourpromise.beauty.customer.base.BaseFragment;
import com.glamourpromise.beauty.customer.bean.CustomerBenefit;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;
/**
 */
public class UnUsedBenefitsFragment extends BaseFragment implements OnClickListener,IConnectTask,OnItemClickListener {
	private static final String CATEGORY_NAME ="ECard";
	private static final String GET_CUSTOMER_BENEFIT_LIST ="GetCustomerBenefitList";
	private LinearLayout  customerBenefitListLinearLayout;
	private List<CustomerBenefit> customerBenefitsList;
	private LayoutInflater  layoutInflater;
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreateView(inflater, container, savedInstanceState);
		View  benefitsListView=inflater.inflate(R.xml.customer_benefits_fragment_layout,container,false);
		customerBenefitListLinearLayout=(LinearLayout)benefitsListView.findViewById(R.id.benefits_list_linearlayout);
		super.asyncRefrshView(this);
		return benefitsListView;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
		customerBenefitsList=new ArrayList<CustomerBenefit>();
		super.asyncRefrshView(this);
	}
	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para=new JSONObject();
		try {
			para.put("Type",1);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,GET_CUSTOMER_BENEFIT_LIST,para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_CUSTOMER_BENEFIT_LIST,para.toString(),header);
		return request;	
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				JSONArray customerBenefitArray=null;
				try {
					customerBenefitArray = new JSONArray(response.getStringData());
				} catch (JSONException e1) {
					
				}
				if(customerBenefitArray!=null && customerBenefitArray.length()>0){
					for (int i = 0; i < customerBenefitArray.length(); i++) {
						CustomerBenefit  cb=new CustomerBenefit();				
						JSONObject customerBenefitJson = null;
						String benefitID="";
						String benefitName="";
						String benefitRule="";
						try {
							customerBenefitJson=customerBenefitArray.getJSONObject(i);
							if(!customerBenefitJson.isNull("BenefitID") && customerBenefitJson.has("BenefitID"))
								benefitID=customerBenefitJson.getString("BenefitID");
							//券名称
							if(!customerBenefitJson.isNull("PolicyName") && customerBenefitJson.has("PolicyName"))
								benefitName=customerBenefitJson.getString("PolicyName");
							//券规则内容
							if(!customerBenefitJson.isNull("PolicyDescription") && customerBenefitJson.has("PolicyDescription"))
								benefitRule=customerBenefitJson.getString("PolicyDescription");
						} catch (JSONException e) {
							
						}
						cb.setBenefitID(benefitID);
						cb.setBenefitName(benefitName);
						cb.setBenefitRule(benefitRule);
						customerBenefitsList.add(cb);
				}
					}
				initCustomerBenefitListView();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case 2:
				DialogUtil.createShortDialog(getActivity(),response.getMessage());
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getActivity(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getActivity(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		
	}	
	private void initCustomerBenefitListView(){
		if(customerBenefitsList.size()>0){
			customerBenefitListLinearLayout.removeAllViews();
			for(int i=0;i<customerBenefitsList.size();i++){
				layoutInflater=LayoutInflater.from(getActivity());
				final CustomerBenefit customerBenefit=customerBenefitsList.get(i);
				View customerBenefitListItem=layoutInflater.inflate(R.xml.customer_benefit_list_item,null);
				LinearLayout   benefitlayout=(LinearLayout)customerBenefitListItem.findViewById(R.id.benefit_layout);
				TextView benefitNameText = (TextView) customerBenefitListItem.findViewById(R.id.benefit_name);
				TextView benefitRuleText = (TextView) customerBenefitListItem.findViewById(R.id.benefit_rule);
				benefitNameText.setText(customerBenefit.getBenefitName());
				benefitRuleText.setText(customerBenefit.getBenefitRule());
				benefitlayout.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent=new Intent();
						destIntent.setClass(getActivity(),CustomerBenefitDetailActivity.class);
						destIntent.putExtra("benefitID",customerBenefit.getBenefitID());
						getActivity().startActivity(destIntent);
					}
				});
				customerBenefitListLinearLayout.addView(customerBenefitListItem);
			}
		}
	}
}
