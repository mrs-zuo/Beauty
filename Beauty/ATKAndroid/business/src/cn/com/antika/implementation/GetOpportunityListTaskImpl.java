/**
 * GetOpportunityListTaskImpl.java
 * cn.com.antika.implementation
 * tim.zhang@bizapper.com
 * 2015年5月14日 下午3:37:52
 * @version V1.0
 */
package cn.com.antika.implementation;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Handler;
import android.os.Message;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.Opportunity;
import cn.com.antika.bean.OpportunityListBaseConditionInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

/**
 * GetOpportunityListTaskImpl TODO
 * 
 * @author tim.zhang@bizapper.com 2015年5月14日 下午3:37:52
 */
public class GetOpportunityListTaskImpl implements IGetBackendServerDataTask {
	private static final String METHOD_NAME = "getOpportunityList";
	private static final String METHOD_PARENT_NAME = "opportunity";
	private OpportunityListBaseConditionInfo mOpportunityBaseParam;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;

	/**
	 * GetOpportunityListTaskImpl
	 * 
	 * @param
	 * 
	 */
	public GetOpportunityListTaskImpl(Handler handler,OpportunityListBaseConditionInfo opportunityBaseParam,UserInfoApplication userinfoApplication) {
		mHandler = handler;
		mOpportunityBaseParam = opportunityBaseParam;
		this.userinfoApplication = userinfoApplication;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @return
	 * 
	 * @see
	 * com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#getmethodName
	 * ()
	 */
	@Override
	public String getmethodName() {
		// TODO Auto-generated method stub
		return METHOD_NAME;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @return
	 * 
	 * @see com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#
	 * getmethodParentName()
	 */
	@Override
	public String getmethodParentName() {
		// TODO Auto-generated method stub
		return METHOD_PARENT_NAME;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @return
	 * 
	 * @see
	 * com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#getParamObject
	 * ()
	 */
	@Override
	public Object getParamObject() {
		// TODO Auto-generated method stub
		JSONObject param = new JSONObject();
		try {
			// 基本条件
			param.put("ProductType", mOpportunityBaseParam.getProductType());
			param.put("CreateTime", mOpportunityBaseParam.getCreateTime());
			param.put("PageIndex", mOpportunityBaseParam.getPageIndex());
			param.put("PageSize", mOpportunityBaseParam.getPageSize());
			if(mOpportunityBaseParam.getResponsiblePersonIDs()!=null && !("").equals(mOpportunityBaseParam.getResponsiblePersonIDs()))
				param.put("ResponsiblePersonIDs",new JSONArray(mOpportunityBaseParam.getResponsiblePersonIDs()));
			param.put("FilterByTimeFlag",mOpportunityBaseParam.getFilterByTimeFlag());
			param.put("StartTime", mOpportunityBaseParam.getStartDate());
			param.put("EndTime", mOpportunityBaseParam.getEndDate());
			param.put("CustomerID", mOpportunityBaseParam.getCustomerID());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return param;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @param resultObject
	 * 
	 * @see
	 * com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#handleResult
	 * (cn.com.antika.bean.WebDataObject)
	 */
	@Override
	public void handleResult(WebDataObject resultObject) {
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		if (resultObject.code == Constant.GET_WEB_DATA_TRUE) {
			JSONObject resultJsonObject = (JSONObject) resultObject.result;
			msg.obj = handleJsonObjectResult(resultJsonObject);
			try {
				msg.arg1 = resultJsonObject.getInt("RecordCount");
				msg.arg2 = resultJsonObject.getInt("PageCount");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		} else if (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION
				|| resultObject.code == Constant.GET_WEB_DATA_FALSE) {
			msg.obj = resultObject.result;
		} else if (resultObject.code == Constant.LOGIN_ERROR
				|| resultObject.code == Constant.APP_VERSION_ERROR) {
			msg.what = resultObject.code;
		}
		msg.sendToTarget();

	}

	private ArrayList<Opportunity> handleJsonObjectResult(
			JSONObject contentJsonObject) {
		ArrayList<Opportunity> opportunityList = new ArrayList<Opportunity>();
		JSONArray opportunityArray = null;
		try {
			opportunityArray = contentJsonObject.getJSONArray("OpportunityList");
		} catch (JSONException e1) {
			return opportunityList;
		}
		int opportunityListCount = opportunityArray.length();
		if (opportunityListCount > 0) {
			JSONObject opportunityJson=null;
			for (int i = 0; i < opportunityListCount; i++) {
				try {
					opportunityJson=(JSONObject) opportunityArray.get(i);
					} 
				catch (JSONException e1) {
				}
				String customerName = "";
				int customerID = 0;
				int opportunityID = 0;
				String productName = "";
				long productCode = 0;
				int productID = 0;
				int productType = 0;
				String progressRate = "";
				int responsiblePersonID = 0;
				String expirationDate = "";
				String creatTime = "";
				String responsiblePersonName = "";
				boolean isAvailable = true;
				try {
					if (opportunityJson.has("CustomerName")) {
						customerName = opportunityJson
								.getString("CustomerName");
					}
					if (opportunityJson.has("CustomerID")) {
						customerID = opportunityJson.getInt("CustomerID");
					}
					if (opportunityJson.has("OpportunityID")) {
						opportunityID = opportunityJson.getInt("OpportunityID");
					}
					if (opportunityJson.has("ProductName")) {
						productName = opportunityJson.getString("ProductName");
					}
					if (opportunityJson.has("ProductID")) {
						productID = opportunityJson.getInt("ProductID");
					}
					if (opportunityJson.has("ProductType")) {
						productType = opportunityJson.getInt("ProductType");
					}
					if (opportunityJson.has("ProgressRate")) {
						progressRate = opportunityJson
								.getString("ProgressRate");
					}
					if (opportunityJson.has("ResponsiblePersonID")) {
						responsiblePersonID = opportunityJson
								.getInt("ResponsiblePersonID");
					}
					if (opportunityJson.has("ProductCode")) {
						productCode = opportunityJson.getLong("ProductCode");
					}
					if (opportunityJson.has("CreateTime")) {
						creatTime = opportunityJson.getString("CreateTime");
					}
					if (opportunityJson.has("ExpirationTime")) {
						expirationDate = opportunityJson
								.getString("ExpirationTime");
					}
					if (opportunityJson.has("ResponsiblePersonName")) {
						responsiblePersonName = opportunityJson
								.getString("ResponsiblePersonName");
					}
					if (opportunityJson.has("Available")) {
						isAvailable = opportunityJson.getBoolean("Available");
					}
				} catch (JSONException e) {
					
				}
				Opportunity opportunity = new Opportunity();
				opportunity.setCustomerName(customerName);
				opportunity.setCustomerID(customerID);
				opportunity.setOpportunityID(opportunityID);
				opportunity.setProductName(productName);
				opportunity.setProductID(productID);
				opportunity.setProductType(productType);
				opportunity.setResponsiblePersonID(responsiblePersonID);
				opportunity.setProductCode(productCode);
				opportunity.setExpirationDate(expirationDate);
				opportunity.setCreatTime(creatTime);
				opportunity.setProgressRate(progressRate);
				opportunity.setResponsiblePersonName(responsiblePersonName);
				opportunity.setAvailable(isAvailable);
				opportunityList.add(opportunity);
			}
		}
		return opportunityList;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @return
	 * 
	 * @see
	 * com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#getApplication
	 * ()
	 */
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}

}
