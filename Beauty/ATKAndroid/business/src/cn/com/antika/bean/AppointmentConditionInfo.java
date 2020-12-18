package cn.com.antika.bean;

import java.io.Serializable;
import java.util.HashMap;
/*
 * 预约列表信息
 * */
public class AppointmentConditionInfo implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int    branchID;
	private int    status[];//1：待确认 2：已确认 3：已执行 4：已取消
	private int    filterByTimeFlag;
	private String startTime;
	private String endTime;
	private int    pageIndex;
	private int    pageSize;
	private String responsiblePersonIDs;
	private int    customerID;
	private String taskScdlStartTime;//每页最后一条的 TaskScdlStartTime时间,分页用 非第一页的时候必须传
	private int    taskType;//1:服务预约 2:订单回访 3:联系任务 4:生日回访
	private HashMap<String, Integer> startTimeList;
	private HashMap<String, Integer> endTimeList;
	private String  taskTypeArray;
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
	public int getBranchID() {
		return branchID;
	}
	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}
	public int[] getStatus() {
		return status;
	}
	public void setStatus(int[] status) {
		this.status = status;
	}
	public int getFilterByTimeFlag() {
		return filterByTimeFlag;
	}
	public void setFilterByTimeFlag(int filterByTimeFlag) {
		this.filterByTimeFlag = filterByTimeFlag;
	}
	public String getStartTime() {
		return startTime;
	}
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}
	public String getEndTime() {
		return endTime;
	}
	public void setEndTime(String endTime) {
		this.endTime = endTime;
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
	public void setResponsiblePersonIDs(String responsiblePersonIDs) {
		this.responsiblePersonIDs = responsiblePersonIDs;
	}
	public int getCustomerID() {
		return customerID;
	}
	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}
	public String getTaskScdlStartTime() {
		return taskScdlStartTime;
	}
	public void setTaskScdlStartTime(String taskScdlStartTime) {
		this.taskScdlStartTime = taskScdlStartTime;
	}
	public int getTaskType() {
		return taskType;
	}
	public void setTaskType(int taskType) {
		this.taskType = taskType;
	}
	public String getTaskTypeArray() {
		return taskTypeArray;
	}
	public void setTaskTypeArray(String taskTypeArray) {
		this.taskTypeArray = taskTypeArray;
	}
}
