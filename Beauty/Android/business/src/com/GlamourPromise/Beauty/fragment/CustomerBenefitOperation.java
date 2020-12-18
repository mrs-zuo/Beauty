package com.GlamourPromise.Beauty.fragment;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.CustomerBenefit;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

public class CustomerBenefitOperation {
	public  List<CustomerBenefit> getCustomerBenefitListData(final int  benefitType,Thread requestWebServiceThread,final Handler mHandler,final UserInfoApplication userinfoApplication) {
		final List<CustomerBenefit> customerBenefitsList = new ArrayList<CustomerBenefit>();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetCustomerBenefitList";
				String endPoint = "ECard";
				JSONObject customerBenefitJsonParam = new JSONObject();
				try {
					customerBenefitJsonParam.put("CustomerID",userinfoApplication.getSelectedCustomerID());
					customerBenefitJsonParam.put("Type",benefitType);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,customerBenefitJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson =null;
					int code = 0;
					String msg="";
					JSONArray customerBenefitArray=null;
					try {
						resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						msg=resultJson.getString("Message");
					} catch (JSONException e) {
					}
					if (code == 1) {
						try {
							customerBenefitArray = resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						if (customerBenefitArray != null) {
							for (int i = 0; i < customerBenefitArray.length(); i++) {
								CustomerBenefit  cb=new CustomerBenefit();				
								JSONObject customerBenefitJson = null;
								String benefitID="";
								String benefitName="";
								String benefitRule="";
								String prcode="";
								double prValue1=0;
								double prValue2=0;
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
									
									if(!customerBenefitJson.isNull("PRCode") && customerBenefitJson.has("PRCode"))
										prcode=customerBenefitJson.getString("PRCode");
									
									if(!customerBenefitJson.isNull("PRValue1") && customerBenefitJson.has("PRValue1"))
										prValue1=customerBenefitJson.getDouble("PRValue1");
									
									if(!customerBenefitJson.isNull("PRValue2") && customerBenefitJson.has("PRValue2"))
										prValue2=customerBenefitJson.getDouble("PRValue2");
								} catch (JSONException e) {
									
								}
								cb.setBenefitID(benefitID);
								cb.setBenefitName(benefitName);
								cb.setBenefitRule(benefitRule);
								cb.setPrcode(prcode);
								cb.setPrValue1(prValue1);
								cb.setPrValue2(prValue2);
								customerBenefitsList.add(cb);
							}
						}
						mHandler.sendEmptyMessage(1);
					} else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						Message message=new Message();
						message.what=0;
						message.obj=msg;
						mHandler.sendMessage(message);
					}
				}
			}
		};
		requestWebServiceThread.start();
		return customerBenefitsList;
	}
	public  CustomerBenefit getCustomerBenefitDetailData(final String benefitID,Thread requestWebServiceThread,final Handler mHandler,final UserInfoApplication userinfoApplication) {
		final CustomerBenefit customerBenefit = new CustomerBenefit();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetCustomerBenefitDetail";
				String endPoint = "ECard";
				JSONObject customerBenefitJsonParam = new JSONObject();
				try {
					customerBenefitJsonParam.put("CustomerID",userinfoApplication.getSelectedCustomerID());
					customerBenefitJsonParam.put("BenefitID",benefitID);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,customerBenefitJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson =null;
					int code = 0;
					String msg="";
					JSONObject customerBenefitJson=null;
					try {
						resultJson = new JSONObject(serverRequestResult);
						code = resultJson.getInt("Code");
						msg=resultJson.getString("Message");
					} catch (JSONException e) {
					}
					String benefitName="";
					String benefitRule="";
					String benefitDescription="";
					String grantDate="";
					String validDate="";
					List<BranchInfo> branchList=null;
					if (code == 1) {
						try {
							customerBenefitJson = resultJson.getJSONObject("Data");
						} catch (JSONException e) {
						}
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
									branchList=new ArrayList<BranchInfo>();
									JSONArray branchJsonArray=customerBenefitJson.getJSONArray("BranchList");
									for(int i=0;i<branchJsonArray.length();i++){
										BranchInfo branch=new BranchInfo();
										JSONObject branchJson=branchJsonArray.getJSONObject(i);
										if(!branchJson.isNull("BranchID") && branchJson.has("BranchID")){
											branch.setId(branchJson.getString("BranchID"));
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
						mHandler.sendEmptyMessage(1);
					} else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						Message message=new Message();
						message.what=0;
						message.obj=msg;
						mHandler.sendMessage(message);
					}
				}
			}
		};
		requestWebServiceThread.start();
		return customerBenefit;
	}
}
