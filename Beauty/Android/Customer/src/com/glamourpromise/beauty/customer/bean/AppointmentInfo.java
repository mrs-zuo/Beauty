package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
/*
 * 预约列表信息
 * */
public class AppointmentInfo implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
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
	
	public static ArrayList<AppointmentInfo> parseListByJson(String stringJson){
		ArrayList<AppointmentInfo> appointmentList=new ArrayList<AppointmentInfo>();
		JSONObject appointmentObject = null;
		try {
			appointmentObject = new JSONObject(stringJson);
		} catch (JSONException e) {
		}
		if (appointmentObject != null) {
			try{
			if(appointmentObject.has("TaskList") && !appointmentObject.isNull("TaskList")){
				JSONArray taskListaArray=new JSONArray();
				taskListaArray=appointmentObject.getJSONArray("TaskList");
				if(taskListaArray.length()>0){
					for (int i = 0; i < taskListaArray.length(); i++) {
						JSONObject taskjson = null;
							taskjson = (JSONObject) taskListaArray.get(i);
							AppointmentInfo appointmentInfo = new AppointmentInfo();
							if (taskjson.has("ResponsiblePersonName")) {
								appointmentInfo.setResponsiblePersonName(taskjson.getString("ResponsiblePersonName"));
							}
							if (taskjson.has("CustomerName")) {
								appointmentInfo.setCustomerName(taskjson.getString("CustomerName"));
							}
							if (taskjson.has("TaskName")) {
								appointmentInfo.setTaskName(taskjson.getString("TaskName"));
							}
							if (taskjson.has("TaskID")) {
								appointmentInfo.setTaskID(taskjson.getLong("TaskID"));
							}
							if(taskjson.has("TaskStatus") && taskjson.has("TaskStatus")){
								appointmentInfo.setTaskStatus(taskjson.getInt("TaskStatus"));
							}
							if(taskjson.has("TaskType") && taskjson.has("TaskType")){
								appointmentInfo.setTaskType(taskjson.getInt("TaskType"));
							}
							if(taskjson.has("TaskScdlStartTime") && taskjson.has("TaskScdlStartTime")){
								appointmentInfo.setTaskScdlStartTime(taskjson.getString("TaskScdlStartTime"));
							}
							if(taskjson.has("ResponsiblePersonID") && taskjson.has("ResponsiblePersonID")){
								appointmentInfo.setResponsiblePersonID(taskjson.getInt("ResponsiblePersonID"));
							}
							if(taskjson.has("ResponsiblePersonMobile") && taskjson.has("ResponsiblePersonMobile")){
								appointmentInfo.setResponsiblePersonMobile(taskjson.getString("ResponsiblePersonMobile"));
							}
							if(taskjson.has("BranchName") && taskjson.has("BranchName")){
								appointmentInfo.setBranchName(taskjson.getString("BranchName"));
							}
							appointmentList.add(appointmentInfo);
					  }
				   }
			    }
             }catch(JSONException e){
		   }
		}
		return appointmentList;
	}

}
