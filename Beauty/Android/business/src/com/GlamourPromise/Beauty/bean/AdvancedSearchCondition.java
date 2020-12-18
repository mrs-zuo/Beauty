package com.GlamourPromise.Beauty.bean;

import android.annotation.SuppressLint;

import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/*
 * 订单高级筛选条件
 * */
public class AdvancedSearchCondition {
	private String  responsiblePersonIDs;//美丽顾问ID
	private String responsiblePersonName;
	private int  customerID;//顾客ID
	private String customerName;
	private int filterByTimeFlag;
	private String startDate;//开始日期
	private String endDate;//结束日期
	private HashMap<String, Integer> startTimeList;
	private HashMap<String, Integer> endTimeList;
	
	private HashMap<Integer, LabelInfo> mArrLabel;
	private String mStrLabelName="";
	private String mStrLabelID="";
	
	public String getStringValue(){
		JSONObject tmp = new JSONObject();
		try {
			tmp.put("responsiblePersonID",responsiblePersonIDs);
			tmp.put("responsiblePersonName", responsiblePersonName);
			tmp.put("customerID", customerID);
			tmp.put("customerName", customerName);
			tmp.put("filterByTimeFlag", filterByTimeFlag);
			tmp.put("startDate", startDate);
			tmp.put("endDate", endDate);
			
			
			if(startTimeList != null){
				JSONObject startTime = new JSONObject();
				startTime.put("Year", startTimeList.get("Year"));
				startTime.put("Month", startTimeList.get("Month"));
				startTime.put("Day", startTimeList.get("Day"));
				tmp.put("StartTimeList", startTime);
			}
			
			
			if(endTimeList != null){
				JSONObject endTime = new JSONObject();
				endTime.put("Year", endTimeList.get("Year"));
				endTime.put("Month", endTimeList.get("Month"));
				endTime.put("Day", endTimeList.get("Day"));
				tmp.put("EndTimeList", endTime);
			}
			
			if(mArrLabel != null && mArrLabel.size() > 0){
				JSONArray labelName = new JSONArray();
				JSONArray labelID = new JSONArray();
				for(int i = 0; i < mArrLabel.size(); i++){
					labelName.put(mArrLabel.get(i).getLabelName());
					labelID.put(mArrLabel.get(i).getID());
				}
				tmp.put("LabelName", labelName.toString());
				tmp.put("LabelID", labelID.toString());
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		}
		return tmp.toString();
	}
	
	@SuppressLint({ "UseSparseArrays", "NewApi" })
	public void initAsJson(JSONObject value){
		if(value == null){
			return;
		}
		try {
			if(value.has("responsiblePersonID"))
			   responsiblePersonIDs = value.getString("responsiblePersonID");
			if(value.has("responsiblePersonName"))
				responsiblePersonName = value.getString("responsiblePersonName");
			if(value.has("customerID"))
				customerID = value.getInt("customerID");
			if(value.has("customerName"))
				customerName = value.getString("customerName");
			if(value.has("filterByTimeFlag"))
				filterByTimeFlag = value.getInt("filterByTimeFlag");
			if(filterByTimeFlag==1){
				startDate = value.getString("startDate");
				endDate = value.getString("endDate");
			}
			//解析时间
			startTimeList = new HashMap<String, Integer>(5);
			endTimeList = new HashMap<String, Integer>(5);
			if(value.has("StartTimeList")){
				JSONObject tmp = value.getJSONObject("StartTimeList");
				startTimeList.put("Year", (Integer) tmp.get("Year"));
				startTimeList.put("Month", (Integer) tmp.get("Month"));
				startTimeList.put("Day", (Integer) tmp.get("Day"));
			}
			
			if(value.has("EndTimeList")){
				JSONObject tmp = value.getJSONObject("EndTimeList");
				endTimeList.put("Year", (Integer) tmp.get("Year"));
				endTimeList.put("Month", (Integer) tmp.get("Month"));
				endTimeList.put("Day", (Integer) tmp.get("Day"));
			}
			
			if(value.has("LabelName")){
				//解析标签
				JSONArray labelName = new JSONArray(value.getString("LabelName"));
				JSONArray labelID = new JSONArray(value.getString("LabelID"));
				LabelInfo tmpLabel;
				HashMap<Integer, LabelInfo> arrLabel = new HashMap<Integer, LabelInfo>(5);
				for(int i = 0; i < labelName.length(); i++){
					tmpLabel = new LabelInfo();
					tmpLabel.setID(labelID.getString(i));
					tmpLabel.setLabelName(labelName.getString(i));
					arrLabel.put(i, tmpLabel);
				}
				setArrLabel(arrLabel);
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			
		}
		
	}
	
	public String getResponsiblePersonID() {
		return responsiblePersonIDs;
	}
	public void setResponsiblePersonID(String responsiblePersonIDs) {
		this.responsiblePersonIDs = responsiblePersonIDs;
	}
	public int getCustomerID() {
		return customerID;
	}
	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}
	
	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}
	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}
	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
	public int getFilterByTimeFlag() {
		return filterByTimeFlag;
	}
	public void setFilterByTimeFlag(int filterByTimeFlag) {
		this.filterByTimeFlag = filterByTimeFlag;
	}
	public String getStartDate() {
		return startDate;
	}
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}
	public String getEndDate() {
		return endDate;
	}
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	
	public HashMap<String, Integer> getStartTimeList() {
		return startTimeList;
	}
	public void setStartTimeList(HashMap<String, Integer> startTimeList) {
		this.startTimeList = startTimeList;
	}
	public HashMap<String, Integer> getEndTimeList() {
		return endTimeList;
	}
	public void setEndTimeList(HashMap<String, Integer> endTimeList) {
		this.endTimeList = endTimeList;
	}

	public HashMap<Integer, LabelInfo> getArrLabel() {
		return mArrLabel;
	}
	public void setArrLabel(HashMap<Integer, LabelInfo> arrLabel) {
		mArrLabel = arrLabel;
		if (mArrLabel != null) {

			LabelInfo labelInfo;
			StringBuilder tmp = new StringBuilder();
			StringBuilder tmpID = new StringBuilder();
			tmpID.append("|");
			for (int i = 0; i < mArrLabel.size(); i++) {
				labelInfo = mArrLabel.get(i);
				tmp.append(labelInfo.getLabelName());
				tmpID.append(labelInfo.getID());
				tmpID.append("|");
				if (i != mArrLabel.size() - 1)
					tmp.append("、");
			}
			mStrLabelName = tmp.toString();
			mStrLabelID = tmpID.toString();
		}else{
			mStrLabelName = "";
		}
	}
	
	public String getLabelString(){
		return mStrLabelName;
	}
	

	public String getStrLabelID() {
		return mStrLabelID;
	}


	public static class OrderAdvancedSearchConditionBuilder{
		private AdvancedSearchCondition advancedSearchCondition;
		
		public OrderAdvancedSearchConditionBuilder(){
			advancedSearchCondition = new AdvancedSearchCondition();
			advancedSearchCondition.responsiblePersonIDs ="";
			advancedSearchCondition.customerID = 0;
			advancedSearchCondition.responsiblePersonName = "";
			advancedSearchCondition.customerName = "";
			advancedSearchCondition.filterByTimeFlag = 0;
			advancedSearchCondition.startDate = "";
			advancedSearchCondition.endDate = "";
		}
		
		public void setResponsiblePersonID(String responsiblePersonIDs) {
			advancedSearchCondition.responsiblePersonIDs =responsiblePersonIDs;
		}
		public void setCustomerID(int customerID) {
			advancedSearchCondition.customerID = customerID;
		}
		
		public void setFilterByTimeFlag(int filterByTimeFlag) {
			advancedSearchCondition.filterByTimeFlag = filterByTimeFlag;
		}
		public void setResponsiblePersonName(String responsiblePersonName) {
			advancedSearchCondition.responsiblePersonName = responsiblePersonName;
		}
		public void setCustomerName(String customerName) {
			advancedSearchCondition.customerName = customerName;
		}
		public void setStartDate(String startDate) {
			advancedSearchCondition.startDate = startDate;
		}
		public void setEndDate(String endDate) {
			advancedSearchCondition.endDate = endDate;
		}
		public void setStartTimeList(HashMap<String, Integer> startTimeList) {
			advancedSearchCondition.startTimeList = startTimeList;
		}
		public void setEndTimeList(HashMap<String, Integer> endTimeList) {
			advancedSearchCondition.endTimeList = endTimeList;
		}
		public void setLabelList(HashMap<Integer, LabelInfo> arrLabel) {
			advancedSearchCondition.setArrLabel(arrLabel);
		}
		public AdvancedSearchCondition create() {
			return advancedSearchCondition;
		}
	}
}
