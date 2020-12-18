package com.GlamourPromise.Beauty.bean;
import java.io.Serializable;
import java.util.HashMap;
import org.json.JSONException;
import org.json.JSONObject;

public class OrderListBaseConditionInfo implements Serializable {
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int branchID;
	private int customerID;
	private int accountID;
	private int orderSource;
	private int productType;
	private int status;
	private int paymentStatus;
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
	private int isBusiness;// 0:Customer 1:Business
	private boolean isAllTheBranch;//是否读取本店订单的权限
    private String  searchWord;//搜索关键字  订单号或者服务商品名称
	/**
	 *OrderListBaseConditionInfo
	 *@param 
	 *
	 */
	public OrderListBaseConditionInfo() {
		super();
		productType=-1;
		status=-1;
		paymentStatus=-1;
	}

	public String getStringValue() {
		JSONObject tmp = new JSONObject();
		try {
			tmp.put("orderSource",getOrderSource());
			tmp.put("productType",getProductType());
			tmp.put("status", getStatus());
			tmp.put("paymentStatus",getPaymentStatus());
			tmp.put("accountID",getAccountID());
			tmp.put("responsiblePersonID", getResponsiblePersonID());
			tmp.put("responsiblePersonName",getResponsiblePersonName());
			tmp.put("customerID",getCustomerID());
			tmp.put("customerName",getCustomerName());
			tmp.put("filterByTimeFlag",getFilterByTimeFlag());
			tmp.put("startDate",getStartDate());
			tmp.put("endDate",getEndDate());
         
			if (startTimeList != null) {
				JSONObject startTime = new JSONObject();
				startTime.put("Year", startTimeList.get("Year"));
				startTime.put("Month", startTimeList.get("Month"));
				startTime.put("Day", startTimeList.get("Day"));
				tmp.put("StartTimeList", startTime);
			}

			if (endTimeList != null) {
				JSONObject endTime = new JSONObject();
				endTime.put("Year", endTimeList.get("Year"));
				endTime.put("Month", endTimeList.get("Month"));
				endTime.put("Day", endTimeList.get("Day"));
				tmp.put("EndTimeList", endTime);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		}
		return tmp.toString();
	}

	public int getBranchID() {
		return branchID;
	}

	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}

	public int getAccountID() {
		return accountID;
	}

	public void setAccountID(int accountID) {
		this.accountID = accountID;
	}

	public int getCustomerID() {
		return customerID;
	}

	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}
	

	public int getOrderSource() {
		return orderSource;
	}

	public void setOrderSource(int orderSource) {
		this.orderSource = orderSource;
	}

	public int getProductType() {
		return productType;
	}

	public void setProductType(int productType) {
		this.productType = productType;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public int getPaymentStatus() {
		return paymentStatus;
	}

	public void setPaymentStatus(int paymentStatus) {
		this.paymentStatus = paymentStatus;
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

	public int getIsBusiness() {
		return isBusiness;
	}

	public void setIsBusiness(int isBusiness) {
		this.isBusiness = isBusiness;
	}

	public String getResponsiblePersonID() {
		return responsiblePersonIDs;
	}

	public void setResponsiblePersonIDs(String responsiblePersonIDs) {
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
	public boolean getIsAllTheBranch() {
		return isAllTheBranch;
	}

	public void setIsAllTheBranch(boolean isAllTheBranch) {
		this.isAllTheBranch = isAllTheBranch;
	}
	

	public String getSearchWord() {
		return searchWord;
	}

	public void setSearchWord(String searchWord) {
		this.searchWord = searchWord;
	}

	/**
	 * 将对象转换为Json格式
	 * 
	 * @return
	 */
	public JSONObject convertToJson() {
		JSONObject object = new JSONObject();
		try {
			object.put("BranchID", branchID);
			object.put("AccountID", accountID);
			object.put("OrderSource",orderSource);
			object.put("ProductType", productType);
			object.put("Status", status);
			object.put("PaymentStatus", paymentStatus);
			object.put("CreateTime",createTime);
			object.put("PageIndex", pageIndex);
			object.put("PageSize", pageSize);
			object.put("IsShowAll",isAllTheBranch);
			object.put("IsBusiness", isBusiness);
			if (responsiblePersonIDs!=null && !("").equals(responsiblePersonIDs))
				object.put("ResponsiblePersonID",responsiblePersonIDs);
			if (customerID !=0)
				object.put("CustomerID",customerID);
			if (filterByTimeFlag == 1) {
				object.put("StartTime", startDate);
				object.put("EndTime", endDate);
			}
		} catch (JSONException e) {

		}

		return object;
	}

	public static class OrderListConditionBuilder {
		OrderListBaseConditionInfo orderCondition;

		public OrderListConditionBuilder() {
			orderCondition = new OrderListBaseConditionInfo();
			orderCondition.paymentStatus = 0;
		}

		public OrderListConditionBuilder setBranchID(int branchID) {
			orderCondition.branchID = branchID;
			return this;
		}

		public OrderListConditionBuilder setAccountID(int accountID) {
			orderCondition.accountID = accountID;
			return this;
		}

		public OrderListConditionBuilder setCustomerID(int customerID) {
			orderCondition.customerID = customerID;
			return this;
		}
		public OrderListConditionBuilder setOrderSource(int orderSource) {
			orderCondition.orderSource = orderSource;
			return this;
		}
		public OrderListConditionBuilder setProductType(int productType) {
			orderCondition.productType = productType;
			return this;
		}

		public OrderListConditionBuilder setStatus(int status) {
			orderCondition.status = status;
			return this;
		}

		public OrderListConditionBuilder setPaymentStatus(int paymentStatus) {
			orderCondition.paymentStatus = paymentStatus;
			return this;
		}

		public OrderListConditionBuilder setCreateTime(String createTime) {
			orderCondition.createTime = createTime;
			return this;
		}

		public OrderListConditionBuilder setPageIndex(int pageIndex) {
			orderCondition.pageIndex = pageIndex;
			return this;
		}

		public OrderListConditionBuilder setPageSize(int pageSize) {
			orderCondition.pageSize = pageSize;
			return this;
		}

		public OrderListConditionBuilder setIsBusiness(int isBusiness) {
			orderCondition.isBusiness = isBusiness;
			return this;
		}

		public OrderListConditionBuilder setResponsibleID(String responsibleIDs) {
			orderCondition.responsiblePersonIDs = responsibleIDs;
			return this;
		}

		public OrderListConditionBuilder setFilterByTimeFlag(
				int filterByTimeFlag) {
			orderCondition.filterByTimeFlag = filterByTimeFlag;
			return this;
		}

		public OrderListConditionBuilder setStartDate(String startDate) {
			orderCondition.startDate = startDate;
			return this;
		}

		public OrderListConditionBuilder setEndDate(String endDate) {
			orderCondition.endDate = endDate;
			return this;
		}
		public OrderListConditionBuilder setIsAllBranchOrder(boolean  isAllBranchOrder) {
			orderCondition.isAllTheBranch = isAllBranchOrder;
			return this;
		}
		public OrderListConditionBuilder setSerchWord(String  searchWord) {
			orderCondition.searchWord = searchWord;
			return this;
		}
		public OrderListBaseConditionInfo create() {
			return orderCondition;
		}
	}
	
	public void initAsJson(JSONObject value){
		if(value == null){
			return;
		}
		try {
			if(value.has("orderSource"))
				orderSource=value.getInt("orderSource");
			if(value.has("productType"))
				productType=value.getInt("productType");
			if(value.has("status"))
				status=value.getInt("status");
			if(value.has("paymentStatus"))
				paymentStatus=value.getInt("paymentStatus");
			if(value.has("responsiblePersonID"))
				responsiblePersonIDs = value.getString("responsiblePersonID");
			if(value.has("responsiblePersonName"))
				responsiblePersonName = value.getString("responsiblePersonName");
			if(value.has("customerID"))
				customerID = value.getInt("customerID");
		    if(value.has("customerName"))
		    	customerName = value.getString("customerName");
		    if(value.has("accountID"))
		    	accountID=value.getInt("accountID");
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
			// TODO Auto-generated catch block
			e.printStackTrace();
			
		}
		
	}
}
