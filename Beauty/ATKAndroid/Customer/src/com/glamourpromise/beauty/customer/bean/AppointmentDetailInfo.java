package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import org.json.JSONException;
import org.json.JSONObject;
/*
 * 预约详细信息
 * */
public class AppointmentDetailInfo implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String taskScdlStartTime;
	private long    taskID;
	private String taskOwnerName;
	private int    branchID;
	private long   productCode;
	private int    accountID;
	private String remark;
	private int    taskType;
	private String   orderNumber;
	private String taskDescription;
	private String taskResult;
	private int    taskStatus;
	private String createTime;
	private String executeStartTime;
	private OrderBaseInfo orderBaseInfo;

	public OrderBaseInfo getOrderBaseInfo() {
		return orderBaseInfo;
	}
	public void setOrderBaseInfo(OrderBaseInfo orderBaseInfo) {
		this.orderBaseInfo = orderBaseInfo;
	}
	public String getCreateTime() {
		return createTime;
	}
	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}
	public String getExecuteStartTime() {
		return executeStartTime;
	}
	public void setExecuteStartTime(String executeStartTime) {
		this.executeStartTime = executeStartTime;
	}
	public int getTaskStatus() {
		return taskStatus;
	}
	public void setTaskStatus(int taskStatus) {
		this.taskStatus = taskStatus;
	}
    public int getBranchID() {
		return branchID;
	}
	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}
	public String getTaskOwnerName() {
		return taskOwnerName;
	}
	public void setTaskOwnerName(String taskOwnerName) {
		this.taskOwnerName = taskOwnerName;
	}
	public long getProductCode() {
		return productCode;
	}
	public void setProductCode(long productCode) {
		this.productCode = productCode;
	}
	public int getAccountID() {
		return accountID;
	}
	public void setAccountID(int accountID) {
		this.accountID = accountID;
	}
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
	public String getOrderNumber() {
		return orderNumber;
	}
	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}
	public String getTaskDescription() {
		return taskDescription;
	}
	public void setTaskDescription(String taskDescription) {
		this.taskDescription = taskDescription;
	}
	public String getTaskResult() {
		return taskResult;
	}
	public void setTaskResult(String taskResult) {
		this.taskResult = taskResult;
	}
	public String getTaskScdlStartTime() {
		return taskScdlStartTime;
	}
	public void setTaskScdlStartTime(String taskScdlStartTime) {
		this.taskScdlStartTime = taskScdlStartTime;
	}
	public long getTaskID() {
		return taskID;
	}
	public void setTaskID(long taskID) {
		this.taskID = taskID;
	}
	public int getTaskType() {
		return taskType;
	}
	public void setTaskType(int taskType) {
		this.taskType = taskType;
	}
	public static AppointmentDetailInfo parseListByJson(String stringJson){
		JSONObject appointmentObject = null;
		AppointmentDetailInfo appointmentDetailInfo = null;
		try {
			appointmentObject = new JSONObject(stringJson);
		} catch (JSONException e) {
		}
		if (appointmentObject != null) {
			appointmentDetailInfo=new AppointmentDetailInfo();
			OrderBaseInfo orderBaseInfo=new OrderBaseInfo();
			try{
				if(appointmentObject.has("TaskID") && !appointmentObject.isNull("TaskID")){
					appointmentDetailInfo.setTaskID(appointmentObject.getLong("TaskID"));
				}
				if(appointmentObject.has("TaskOwnerID") && !appointmentObject.isNull("TaskOwnerID")){
					orderBaseInfo.setOrderCreatorID(String.valueOf(appointmentObject.getInt("TaskOwnerID")));
				}
				if(appointmentObject.has("TaskOwnerName") && !appointmentObject.isNull("TaskOwnerName")){
					appointmentDetailInfo.setTaskOwnerName(appointmentObject.getString("TaskOwnerName"));
				}
				if(appointmentObject.has("BranchName") && !appointmentObject.isNull("BranchName")){
					orderBaseInfo.setBranchName(appointmentObject.getString("BranchName"));
				}
				if(appointmentObject.has("BranchID") && !appointmentObject.isNull("BranchID")){
					appointmentDetailInfo.setBranchID(appointmentObject.getInt("BranchID"));
				}
				if(appointmentObject.has("TaskScdlStartTime") && !appointmentObject.isNull("TaskScdlStartTime")){
					appointmentDetailInfo.setTaskScdlStartTime(appointmentObject.getString("TaskScdlStartTime"));
				}
				if(appointmentObject.has("ProductCode") && !appointmentObject.isNull("ProductCode")){
					appointmentDetailInfo.setProductCode(appointmentObject.getLong("ProductCode"));
				}
				if(appointmentObject.has("ProductName") && !appointmentObject.isNull("ProductName")){
					orderBaseInfo.setProductName(appointmentObject.getString("ProductName"));
				}
				if(appointmentObject.has("AccountID") && !appointmentObject.isNull("AccountID")){
					appointmentDetailInfo.setAccountID(appointmentObject.getInt("AccountID"));
				}
				if(appointmentObject.has("AccountName") && !appointmentObject.isNull("AccountName")){
					orderBaseInfo.setResponsiblePersonName(appointmentObject.getString("AccountName"));
				}
				if(appointmentObject.has("Remark") && !appointmentObject.isNull("Remark")){
					appointmentDetailInfo.setRemark(appointmentObject.getString("Remark"));
				}
				if(appointmentObject.has("TaskType") && !appointmentObject.isNull("TaskType")){
					orderBaseInfo.setProductType(String.valueOf(appointmentObject.getInt("TaskType")));
				}
				if(appointmentObject.has("OrderID") && !appointmentObject.isNull("OrderID")){
					orderBaseInfo.setOrderID(String.valueOf(appointmentObject.getInt("OrderID")));
				}
				if(appointmentObject.has("OrderObjectID") && !appointmentObject.isNull("OrderObjectID")){
					orderBaseInfo.setOrderObjectID(String.valueOf(appointmentObject.getInt("OrderObjectID")));
					orderBaseInfo.setOrderObjectIDInt(appointmentObject.getInt("OrderObjectID"));
				}
				if(appointmentObject.has("OrderNumber") && !appointmentObject.isNull("OrderNumber")){
					appointmentDetailInfo.setOrderNumber(appointmentObject.getString("OrderNumber"));
					orderBaseInfo.setOrderNumber(appointmentObject.getString("OrderNumber"));
				}
				if(appointmentObject.has("TotalSalePrice") && !appointmentObject.isNull("TotalSalePrice")){
					orderBaseInfo.setTotalSalePrice(appointmentObject.getString("TotalSalePrice"));
				}
				if(appointmentObject.has("TaskDescription") && !appointmentObject.isNull("TaskDescription")){
					appointmentDetailInfo.setTaskDescription(appointmentObject.getString("TaskDescription"));
				}
				if(appointmentObject.has("TaskResult") && !appointmentObject.isNull("TaskResult")){
					appointmentDetailInfo.setTaskResult(appointmentObject.getString("TaskResult"));
				}
				if(appointmentObject.has("OrderCreateTime") && !appointmentObject.isNull("OrderCreateTime")){
					orderBaseInfo.setOrderTime(appointmentObject.getString("OrderCreateTime"));
				}
				if(appointmentObject.has("TaskStatus") && !appointmentObject.isNull("TaskStatus")){
					appointmentDetailInfo.setTaskStatus(appointmentObject.getInt("TaskStatus"));
				}
				orderBaseInfo.setProductType("0");
			} catch (JSONException e) {
				
			}
			appointmentDetailInfo.setOrderBaseInfo(orderBaseInfo);
		}
		return appointmentDetailInfo;
	}

}
