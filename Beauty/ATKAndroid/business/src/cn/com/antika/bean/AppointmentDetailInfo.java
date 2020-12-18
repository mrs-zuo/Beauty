package cn.com.antika.bean;

import java.io.Serializable;

/*
 * 预约详细信息
 * */
public class AppointmentDetailInfo implements Serializable {
	
	private String taskScdlStartTime;
	private long    taskID;
//	private int    taskOwnerID;
//	private String taskOwnerName;
//	private String branchName;
	private long   productCode;
//	private String productName;
//	private int    accountID;
//	private String accountName;
	private String remark;
	private int    taskType;
//	private int    orderID;
//	private int    orderObjectID;
	private String   orderNumber;
//	private String  totalSalePrice;
	private String taskDescription;
	private String taskResult;
//	private String orderCreateTime;
	private int    taskStatus;
	private String createTime;
	
	private String executeStartTime;

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
	private OrderInfo orderInfo;
	
	public OrderInfo getOrderInfo() {
		return orderInfo;
	}
	public void setOrderInfo(OrderInfo orderInfo) {
		this.orderInfo = orderInfo;
	}
	public int getTaskStatus() {
		return taskStatus;
	}
	public void setTaskStatus(int taskStatus) {
		this.taskStatus = taskStatus;
	}
//	public int getTaskOwnerID() {
//		return taskOwnerID;
//	}
//	public void setTaskOwnerID(int taskOwnerID) {
//		this.taskOwnerID = taskOwnerID;
//	}
//	public String getTaskOwnerName() {
//		return taskOwnerName;
//	}
//	public void setTaskOwnerName(String taskOwnerName) {
//		this.taskOwnerName = taskOwnerName;
//	}
//	public String getBranchName() {
//		return branchName;
//	}
//	public void setBranchName(String branchName) {
//		this.branchName = branchName;
//	}
	public long getProductCode() {
		return productCode;
	}
	public void setProductCode(long productCode) {
		this.productCode = productCode;
	}
//	public String getProductName() {
//		return productName;
//	}
//	public void setProductName(String productName) {
//		this.productName = productName;
//	}
//	public int getAccountID() {
//		return accountID;
//	}
//	public void setAccountID(int accountID) {
//		this.accountID = accountID;
//	}
//	public String getAccountName() {
//		return accountName;
//	}
//	public void setAccountName(String accountName) {
//		this.accountName = accountName;
//	}
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
//	public int getOrderID() {
//		return orderID;
//	}
//	public void setOrderID(int orderID) {
//		this.orderID = orderID;
//	}
//	public int getOrderObjectID() {
//		return orderObjectID;
//	}
//	public void setOrderObjectID(int orderObjectID) {
//		this.orderObjectID = orderObjectID;
//	}
	public String getOrderNumber() {
		return orderNumber;
	}
	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}
//	public String getTotalSalePrice() {
//		return totalSalePrice;
//	}
//	public void setTotalSalePrice(String totalSalePrice) {
//		this.totalSalePrice = totalSalePrice;
//	}
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
//	public String getOrderCreateTime() {
//		return orderCreateTime;
//	}
//	public void setOrderCreateTime(String orderCreateTime) {
//		this.orderCreateTime = orderCreateTime;
//	}
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
	
	

}
