package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.Branch;
import com.glamourpromise.beauty.customer.bean.CustomerBenefit;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DateUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;

import android.os.Bundle;
import android.widget.TextView;

public class CustomerBenefitDetailActivity extends BaseActivity implements IConnectTask{
	private static final String CATEGORY_NAME="ECard";
	private static final String METHOD_NAME="GetCustomerBenefitDetail";
	private CustomerBenefit   customerBenefit;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.setTitle("福利详情");
		super.baseSetContentView(R.layout.activity_customer_benefit_detail);
		customerBenefit=new CustomerBenefit();
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para=new JSONObject();
		try {
			para.put("BenefitID",getIntent().getStringExtra("benefitID"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,METHOD_NAME,para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,METHOD_NAME,para.toString(), header);
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
				JSONObject customerBenefitJson=null;
				try {
					customerBenefitJson=new JSONObject(response.getStringData());
				} catch (JSONException e) {
				}
				String benefitName="";
				String benefitRule="";
				String benefitDescription="";
				String grantDate="";
				String validDate="";
				List<Branch> branchList=null;
				try {
					if (customerBenefitJson != null) {
						//券名称
						if(!customerBenefitJson.isNull("PolicyName") && customerBenefitJson.has("PolicyName"))
							benefitName=customerBenefitJson.getString("PolicyName");
						//券规则内容
						if(!customerBenefitJson.isNull("PolicyDescription") && customerBenefitJson.has("PolicyDescription"))
							benefitRule=customerBenefitJson.getString("PolicyDescription");
						//券细则说明
						if(!customerBenefitJson.isNull("PolicyComments") && customerBenefitJson.has("PolicyComments"))
							benefitDescription=customerBenefitJson.getString("PolicyComments");
						if(!customerBenefitJson.isNull("GrantDate") && customerBenefitJson.has("GrantDate"))
							grantDate=customerBenefitJson.getString("GrantDate");
						if(!customerBenefitJson.isNull("ValidDate") && customerBenefitJson.has("ValidDate"))
							validDate=customerBenefitJson.getString("ValidDate");
						if(!customerBenefitJson.isNull("BranchList") && customerBenefitJson.has("BranchList")){
							branchList=new ArrayList<Branch>();
							JSONArray branchJsonArray=customerBenefitJson.getJSONArray("BranchList");
							for(int i=0;i<branchJsonArray.length();i++){
								Branch branch=new Branch();
								JSONObject branchJson=branchJsonArray.getJSONObject(i);
								if(!branchJson.isNull("BranchID") && branchJson.has("BranchID")){
									branch.setID(branchJson.getString("BranchID"));
								}
								if(!branchJson.isNull("BranchName") && branchJson.has("BranchName")){
									branch.setName(branchJson.getString("BranchName"));
								}
								branchList.add(branch);
							}
						}
					}
				} catch (JSONException e) {
					
				}
				customerBenefit.setBenefitName(benefitName);
				customerBenefit.setBenefitRule(benefitRule);
				customerBenefit.setBenefitDescription(benefitDescription);
				customerBenefit.setGrantDate(grantDate);
				customerBenefit.setValidDate(validDate);
				customerBenefit.setBranchList(branchList);
				initView();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case 2:
				DialogUtil.createShortDialog(this,response.getMessage());
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(this,response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(this,Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}
	private void initView(){
		((TextView)findViewById(R.id.customer_benefit_detail_name_text)).setText(customerBenefit.getBenefitName());
		((TextView)findViewById(R.id.customer_benefit_detail_date_text)).setText(DateUtil.getFormateDateByString(customerBenefit.getGrantDate())+"\t至\t"+DateUtil.getFormateDateByString(customerBenefit.getValidDate()));
		((TextView)findViewById(R.id.customer_benefit_detail_rule_content_text)).setText(customerBenefit.getBenefitRule());
		((TextView)findViewById(R.id.customer_benefit_detail_description_content_text)).setText(customerBenefit.getBenefitDescription());
		List<Branch> branchList=customerBenefit.getBranchList();
		StringBuffer branchNameString=new StringBuffer();
		if(branchList!=null && branchList.size()>0){
			for(int i=0;i<branchList.size();i++){
				if(i==branchList.size()-1){
					branchNameString.append(branchList.get(i).getName());
				}
				else{
					branchNameString.append(branchList.get(i).getName()+"\r\n");
				}
			}
		}
		((TextView)findViewById(R.id.customer_benefit_detail_branch_content_text)).setText(branchNameString.toString());
	}
}
