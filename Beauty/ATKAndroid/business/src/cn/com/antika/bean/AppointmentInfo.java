package cn.com.antika.bean;

import java.io.Serializable;

/*
 * 预约列表信息
 * */
public class AppointmentInfo implements Serializable {
	
	private String responsiblePersonName;
	private String customerName;
	private String taskName;
	private String taskScdlStartTime;
	private long    taskID;
	private int    taskStatus;
	private int    taskType;
	
	private int    ResponsiblePersonID;
	private String ResponsiblePersonMobile;
	private String BranchName;
	
	public int getResponsiblePersonID() {
		return ResponsiblePersonID;
	}
	public void setResponsiblePersonID(int responsiblePersonID) {
		ResponsiblePersonID = responsiblePersonID;
	}
	public String getResponsiblePersonMobile() {
		return ResponsiblePersonMobile;
	}
	public void setResponsiblePersonMobile(String responsiblePersonMobile) {
		ResponsiblePersonMobile = responsiblePersonMobile;
	}
	public String getBranchName() {
		return BranchName;
	}
	public void setBranchName(String branchName) {
		BranchName = branchName;
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
	public String getTaskName() {
		return taskName;
	}
	public void setTaskName(String taskName) {
		this.taskName = taskName;
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
	public int getTaskStatus() {
		return taskStatus;
	}
	public void setTaskStatus(int taskStatus) {
		this.taskStatus = taskStatus;
	}
	public int getTaskType() {
		return taskType;
	}
	public void setTaskType(int taskType) {
		this.taskType = taskType;
	}
	
	

}
