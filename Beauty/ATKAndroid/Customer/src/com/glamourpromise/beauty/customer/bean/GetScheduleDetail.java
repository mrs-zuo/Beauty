package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class GetScheduleDetail {
	private int taskStatus;
	private String orderCreateTime;
	private String executeStartTime;
	private String taskResult;
	private String taskDescription;
	private String totalSalePrice;
	private String orderNumber;
	private int orderObjectID;
	private int orderID;
	private int taskType;
	private String remark;
	private String accountName;
	private String accountID;
	private String productName;
	private String productCode;
	private String taskScdlStartTime;
	private String branchName;
	private String taskOwnerName;
	private String taskOwnerID;
	private String taskID;

	public GetScheduleDetail() {
	}

	public static ArrayList<GetScheduleDetail> parseListByJson(String src) {
		ArrayList<GetScheduleDetail> list = new ArrayList<GetScheduleDetail>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			GetScheduleDetail item;
			for (int i = 0; i < count; i++) {
				item = new GetScheduleDetail();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	public boolean parseByJson(String src) {
		JSONObject jsSrc = null;
		try {
			jsSrc = new JSONObject(src);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return parseByJson(jsSrc);
	}

	public boolean parseByJson(JSONObject src) {
		try {
			JSONObject jsSrc = src;
			if (jsSrc.has("TaskID"))
				setTaskID(jsSrc.getString("TaskID"));
			if (jsSrc.has("TaskOwnerID"))
				setTaskOwnerID(jsSrc.getString("TaskOwnerID"));
			if (jsSrc.has("TaskOwnerName"))
				setTaskOwnerName(jsSrc.getString("TaskOwnerName"));
			if (jsSrc.has("BranchName"))
				setBranchName(jsSrc.getString("BranchName"));
			if (jsSrc.has("TaskScdlStartTime"))
				setTaskScdlStartTime(jsSrc.getString("TaskScdlStartTime"));
			if (jsSrc.has("ProductCode"))
				setProductCode(jsSrc.getString("ProductCode"));
			if (jsSrc.has("ProductName"))
				setProductName(jsSrc.getString("ProductName"));
			if (jsSrc.has("AccountID"))
				setAccountID(jsSrc.getString("AccountID"));
			if (jsSrc.has("AccountName"))
				setAccountName(jsSrc.getString("AccountName"));
			if (jsSrc.has("Remark"))
				setRemark(jsSrc.getString("Remark"));
			if (jsSrc.has("TaskType"))
				setTaskType(jsSrc.getInt("TaskType"));
			if (jsSrc.has("OrderID"))
				setOrderID(jsSrc.getInt("OrderID"));
			if (jsSrc.has("OrderObjectID"))
				setOrderObjectID(jsSrc.getInt("OrderObjectID"));
			if (jsSrc.has("OrderNumber"))
				setOrderNumber(jsSrc.getString("OrderNumber"));
			if (jsSrc.has("TotalSalePrice"))
				setTotalSalePrice(jsSrc.getString("TotalSalePrice"));
			if (jsSrc.has("TaskDescription"))
				setTaskDescription(jsSrc.getString("TaskDescription"));
			if (jsSrc.has("TaskResult"))
				setTaskResult(jsSrc.getString("TaskResult"));
			if (jsSrc.has("ExecuteStartTime"))
				setExecuteStartTime(jsSrc.getString("ExecuteStartTime"));
			if (jsSrc.has("OrderCreateTime"))
				setOrderCreateTime(jsSrc.getString("OrderCreateTime"));
			if (jsSrc.has("TaskStatus"))
				setTaskStatus(jsSrc.getInt("TaskStatus"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public int getTaskStatus() {
		return taskStatus;
	}

	public void setTaskStatus(int taskStatus) {
		this.taskStatus = taskStatus;
	}

	public void setTaskID(String taskID) {
		this.taskID = taskID;
	}

	public void setTaskOwnerID(String taskOwnerID) {
		this.taskOwnerID = taskOwnerID;
	}

	public void setTaskOwnerName(String taskOwnerName) {
		this.taskOwnerName = taskOwnerName;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}

	public void setTaskScdlStartTime(String taskScdlStartTime) {
		this.taskScdlStartTime = taskScdlStartTime;
	}

	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public void setAccountID(String accountID) {
		this.accountID = accountID;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public void setTaskType(int taskType) {
		this.taskType = taskType;
	}

	public void setOrderID(int orderID) {
		this.orderID = orderID;
	}

	public void setOrderObjectID(int orderObjectID) {
		this.orderObjectID = orderObjectID;
	}

	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}

	public void setTotalSalePrice(String totalSalePrice) {
		this.totalSalePrice = totalSalePrice;
	}

	public void setTaskDescription(String taskDescription) {
		this.taskDescription = taskDescription;
	}

	public void setTaskResult(String taskResult) {
		this.taskResult = taskResult;
	}

	public void setExecuteStartTime(String executeStartTime) {
		this.executeStartTime = executeStartTime;
	}

	public void setOrderCreateTime(String orderCreateTime) {
		this.orderCreateTime = orderCreateTime;
	}

	public String getTaskID() {
		return taskID;
	}

	public String getTaskOwnerID() {
		return taskOwnerID;
	}

	public String getTaskOwnerName() {
		return taskOwnerName;
	}

	public String getBranchName() {
		return branchName;
	}

	public String getTaskScdlStartTime() {
		return taskScdlStartTime;
	}

	public String getProductCode() {
		return productCode;
	}

	public String getProductName() {
		return productName;
	}

	public String getAccountID() {
		return accountID;
	}

	public String getAccountName() {
		return accountName;
	}

	public String getRemark() {
		return remark;
	}

	public int getTaskType() {
		return taskType;
	}

	public int getOrderID() {
		return orderID;
	}

	public int getOrderObjectID() {
		return orderObjectID;
	}

	public String getOrderNumber() {
		return orderNumber;
	}

	public String getTotalSalePrice() {
		return totalSalePrice;
	}

	public String getTaskDescription() {
		return taskDescription;
	}

	public String getTaskResult() {
		return taskResult;
	}

	public String getExecuteStartTime() {
		return executeStartTime;
	}

	public String getOrderCreateTime() {
		return orderCreateTime;
	}
}
