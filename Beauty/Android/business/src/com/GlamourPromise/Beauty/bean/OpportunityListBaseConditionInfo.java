package com.GlamourPromise.Beauty.bean;
import java.io.Serializable;
import java.util.HashMap;
import org.json.JSONException;
import org.json.JSONObject;

public class OpportunityListBaseConditionInfo implements Serializable {
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int customerID;
	private int productType;//-1：全部  0:服务  1:商品
	private String createTime;
	private int pageIndex;
	private int pageSize;
	private String responsiblePersonIDs;// 美丽顾问ID
	private String responsiblePersonName;
	private String customerName;
	private int filterByTimeFlag;
	private String startDate;// 开始日期
	private String endDate;// 结束日期
	private HashMap<String, Integer> startTimeList;
	private HashMap<String, Integer> endTimeList;
	/**
	 *OpportunityListBaseConditionInfo
	 *@param 
	 *
	 */
	public OpportunityListBaseConditionInfo() {
		super();
		productType=-1;
	}

	public String getStringValue() {
		JSONObject jsonValue = new JSONObject();
		try {
			jsonValue.put("productType",getProductType());
			jsonValue.put("responsiblePersonID",getResponsiblePersonIDs());
			jsonValue.put("responsiblePersonName",getResponsiblePersonName());
			jsonValue.put("customerID",getCustomerID());
			jsonValue.put("customerName",getCustomerName());
			jsonValue.put("filterByTimeFlag",getFilterByTimeFlag());
			jsonValue.put("startDate",getStartDate());
			jsonValue.put("endDate",getEndDate());
			if (startTimeList != null) {
				JSONObject startTime = new JSONObject();
				startTime.put("Year", startTimeList.get("Year"));
				startTime.put("Month", startTimeList.get("Month"));
				startTime.put("Day", startTimeList.get("Day"));
				jsonValue.put("StartTimeList", startTime);
			}
			if (endTimeList != null) {
				JSONObject endTime = new JSONObject();
				endTime.put("Year", endTimeList.get("Year"));
				endTime.put("Month", endTimeList.get("Month"));
				endTime.put("Day", endTimeList.get("Day"));
				jsonValue.put("EndTimeList", endTime);
			}
		} catch (JSONException e) {
			return "";
		}
		return jsonValue.toString();
	}
	public int getCustomerID() {
		return customerID;
	}

	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}

	public int getProductType() {
		return productType;
	}

	public void setProductType(int productType) {
		this.productType = productType;
	}
	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public int getPageIndex() {
		return pageIndex;
	}

	public void setPageIndex(int pageIndex) {
		this.pageIndex = pageIndex;
	}

	public int getPageSize() {
		return pageSize;
	}

	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}

	public String getResponsiblePersonIDs() {
		return responsiblePersonIDs;
	}

	public void setResponsiblePersonID(String responsiblePersonIDs) {
		this.responsiblePersonIDs = responsiblePersonIDs;
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
	/**
	 * 将对象转换为Json格式
	 * 
	 * @return
	 */
	public JSONObject convertToJson() {
		JSONObject jsonObject = new JSONObject();
		try {
			jsonObject.put("ProductType", productType);
			jsonObject.put("CreateTime",createTime);
			jsonObject.put("PageIndex", pageIndex);
			jsonObject.put("PageSize", pageSize);
			if (responsiblePersonIDs!=null && !responsiblePersonIDs.equals(""))
				jsonObject.put("ResponsiblePersonIDs",responsiblePersonIDs);
			if (customerID !=0)
				jsonObject.put("CustomerID", customerID);
			if (filterByTimeFlag == 1) {
				jsonObject.put("StartTime", startDate);
				jsonObject.put("EndTime", endDate);
			}
		} catch (JSONException e) {

		}

		return jsonObject;
	}

	public static class OpportunityListConditionBuilder {
		OpportunityListBaseConditionInfo orderCondition;
		public OpportunityListConditionBuilder() {
			orderCondition = new OpportunityListBaseConditionInfo();
		}
		public OpportunityListConditionBuilder setCustomerID(int customerID) {
			orderCondition.customerID = customerID;
			return this;
		}

		public OpportunityListConditionBuilder setProductType(int productType) {
			orderCondition.productType = productType;
			return this;
		}

		public OpportunityListConditionBuilder setCreateTime(String createTime) {
			orderCondition.createTime = createTime;
			return this;
		}

		public OpportunityListConditionBuilder setPageIndex(int pageIndex) {
			orderCondition.pageIndex = pageIndex;
			return this;
		}

		public OpportunityListConditionBuilder setPageSize(int pageSize) {
			orderCondition.pageSize = pageSize;
			return this;
		}

		public OpportunityListConditionBuilder setResponsibleID(String responsibleIDs) {
			orderCondition.responsiblePersonIDs = responsibleIDs;
			return this;
		}

		public OpportunityListConditionBuilder setFilterByTimeFlag(int filterByTimeFlag) {
			orderCondition.filterByTimeFlag = filterByTimeFlag;
			return this;
		}

		public OpportunityListConditionBuilder setStartDate(String startDate) {
			orderCondition.startDate = startDate;
			return this;
		}

		public OpportunityListConditionBuilder setEndDate(String endDate) {
			orderCondition.endDate = endDate;
			return this;
		}
		public OpportunityListBaseConditionInfo create() {
			return orderCondition;
		}
	}
	
	public void initAsJson(JSONObject value){
		if(value == null){
			return;
		}
		try {
			if(value.has("productType"))
				productType=value.getInt("productType");
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
		   }
			
		} catch (JSONException e) {
		}
		
	}
}
