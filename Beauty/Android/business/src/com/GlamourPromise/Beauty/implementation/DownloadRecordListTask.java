package com.GlamourPromise.Beauty.implementation;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AdvancedSearchCondition;
import com.GlamourPromise.Beauty.bean.CustomerRecord;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.manager.BaseDownloadDataTask;

public class DownloadRecordListTask extends BaseDownloadDataTask{
	private static final String METHOD_NAME = "getRecordListByAccountID";
	private static final String METHOD_PARENT_NAME = "record";
	private int mCompanyID;
	private int mBranchID;
	private int mAccountID;
	private int mCustomerID;
	private int mRecordID;
	private int mPageIndex;
	private int mPageSize;
	private String mTagIDs;
	private AdvancedSearchCondition mAdvancedCondition;
	private Handler mHandler;
	public DownloadRecordListTask(int companyID, int branchID, int accountID, int customerID, Handler handler,UserInfoApplication userinfoApplication) {
		super(METHOD_NAME, METHOD_PARENT_NAME);
		mCompanyID = companyID;
		mBranchID = branchID;
		mAccountID = accountID;
		mCustomerID = customerID;
		mHandler = handler;
	}

	public int getRecordID() {
		return mRecordID;
	}

	public void setRecordID(int recordID) {
		mRecordID = recordID;
	}

	public int getPageIndex() {
		return mPageIndex;
	}

	public void setPageIndex(int pageIndex) {
		mPageIndex = pageIndex;
	}

	public int getPageSize() {
		return mPageSize;
	}

	public void setPageSize(int pageSize) {
		mPageSize = pageSize;
	}

	public String getTagIDs() {
		return mTagIDs;
	}

	public void setTagIDs(String tagIDs) {
		mTagIDs = tagIDs;
	}

	public AdvancedSearchCondition getMdvancedCondition() {
		return mAdvancedCondition;
	}

	public void setAdvancedCondition(AdvancedSearchCondition mdvancedCondition) {
		this.mAdvancedCondition = mdvancedCondition;
	}

	@Override
	public Object getParamObject() {
		// TODO Auto-generated method stub
		JSONObject param = new JSONObject();
		try {
			//基本条件
			param.put("AccountID",mAccountID);
			param.put("RecordID",mRecordID);
			param.put("PageIndex",mPageIndex);
			param.put("PageSize",10);
			param.put("CustomerID", mCustomerID);
			//高级筛选条件
			if(mAdvancedCondition != null){
				param.put("ResponsiblePersonID",mAdvancedCondition.getResponsiblePersonID());
				param.put("FilterByTimeFlag", mAdvancedCondition.getFilterByTimeFlag());
				param.put("StartTime", mAdvancedCondition.getStartDate());
				param.put("EndTime", mAdvancedCondition.getEndDate());
				param.put("CustomerID", mAdvancedCondition.getCustomerID());
				param.put("TagIDs",mAdvancedCondition.getStrLabelID());
			}
		} catch (JSONException e) {
		}
		return param;
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			JSONObject resultJsonObject = (JSONObject) resultObject.result;
			msg.obj = handleSoapObjectResult(resultJsonObject);
			try {
				msg.arg1 = resultJsonObject.getInt("RecordCount");
				msg.arg2 = resultJsonObject.getInt("PageCount");
			} catch (JSONException e) {
				
			}
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = resultObject.result;
		}
		else if(resultObject.code==Constant.APP_VERSION_ERROR || resultObject.code==Constant.LOGIN_ERROR){
			msg.what=resultObject.code;
		}
		msg.sendToTarget();
	}
	private ArrayList<CustomerRecord> handleSoapObjectResult(JSONObject contentJsonObject){
		ArrayList<CustomerRecord> recordList = new ArrayList<CustomerRecord>();
		JSONArray recordListArray = null;
		try {
			recordListArray = contentJsonObject.getJSONArray("RecordList");
		} catch (JSONException e1) {
			return recordList;
		}
		int recordListCount = recordListArray.length();
		
		if(recordListCount > 0){
			JSONObject recordJsonObject;
			CustomerRecord recordItem;
			for(int i = 0; i < recordListCount; i++){
				try {
					recordJsonObject = recordListArray.getJSONObject(i);
					recordItem = new CustomerRecord();
					if (recordJsonObject.has("RecordID")) {
						recordItem.setRecordId(recordJsonObject.getString("RecordID"));
					}
					if (recordJsonObject.has("RecordTime")) {
						recordItem.setRecordTime(recordJsonObject.getString("RecordTime"));
					}
					if (recordJsonObject.has("Problem")) {
						recordItem.setProblem(recordJsonObject.getString("Problem"));
					}
					if (recordJsonObject.has("Suggestion")) {
						recordItem.setSuggestion(recordJsonObject.getString("Suggestion"));
					}
					if(recordJsonObject.has("TagName")){
						recordItem.setLabel(recordJsonObject.getString("TagName"));
					}
					if (recordJsonObject.has("CustomerID")) {
						recordItem.setCustomerID(recordJsonObject.getString("CustomerID"));
					}
					if (recordJsonObject.has("CustomerName")) {
						recordItem.setCustomerName(recordJsonObject.getString("CustomerName"));
					}
					if (recordJsonObject.has("ResponsiblePersonName")) {
						recordItem.setResponsiblePersonName(recordJsonObject.getString("ResponsiblePersonName"));
					}
					if (recordJsonObject.has("IsVisible")) {
						recordItem.setIsVisible(recordJsonObject.getString("IsVisible"));
					}
					recordList.add(recordItem);
				} catch (JSONException e) {
				}
			}
		}
		return recordList;
		
	}
}
