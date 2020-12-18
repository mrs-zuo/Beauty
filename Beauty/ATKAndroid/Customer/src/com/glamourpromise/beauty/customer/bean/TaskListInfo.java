package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TaskListInfo {

	private boolean responsiblePersonChat_Use;
	private String taskScdlStartTime;
	private int    taskStatus;
	private String taskID;
	private String taskName;
	private String customerName;
	private String branchName;
	private String responsiblePersonMobile;
	private String responsiblePersonName;
	private int responsiblePersonID;

	public TaskListInfo() {

	}

	public static ArrayList<TaskListInfo> parseListByJson(String src) {
		ArrayList<TaskListInfo> list = new ArrayList<TaskListInfo>();
		try {
			JSONObject tmp = new JSONObject(src);
			JSONArray jarrList = tmp.getJSONArray("TaskList");
			int count = jarrList.length();
			TaskListInfo item;
			for (int i = 0; i < count; i++) {
				item = new TaskListInfo();
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
			if (jsSrc.has("ResponsiblePersonID"))
				setResponsiblePersonID(jsSrc.getInt("ResponsiblePersonID"));
			if (jsSrc.has("ResponsiblePersonName"))
				setResponsiblePersonName(jsSrc
						.getString("ResponsiblePersonName"));
			if (jsSrc.has("ResponsiblePersonMobile"))
				setResponsiblePersonMobile(jsSrc
						.getString("ResponsiblePersonMobile"));
			if (jsSrc.has("BranchName"))
				setBranchName(jsSrc.getString("BranchName"));
			if (jsSrc.has("CustomerName"))
				setCustomerName(jsSrc.getString("CustomerName"));
			if (jsSrc.has("TaskName"))
				setTaskName(jsSrc.getString("TaskName"));
			if (jsSrc.has("TaskID"))
				setTaskID(jsSrc.getString("TaskID"));
			if (jsSrc.has("TaskStatus"))
				setTaskStatus(jsSrc.getInt("TaskStatus"));
			if (jsSrc.has("TaskScdlStartTime"))
				setTaskScdlStartTime(jsSrc.getString("TaskScdlStartTime"));
			if (jsSrc.has("ResponsiblePersonChat_Use"))
				setResponsiblePersonChat_Use(jsSrc
						.getBoolean("ResponsiblePersonChat_Use"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setResponsiblePersonID(int responsiblePersonID) {
		this.responsiblePersonID = responsiblePersonID;
	}

	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}

	public void setResponsiblePersonMobile(String responsiblePersonMobile) {
		this.responsiblePersonMobile = responsiblePersonMobile;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}

	public void setTaskID(String taskID) {
		this.taskID = taskID;
	}

	public void setTaskStatus(int taskStatus) {
		this.taskStatus = taskStatus;
	}

	public void setTaskScdlStartTime(String taskScdlStartTime) {
		this.taskScdlStartTime = taskScdlStartTime;
	}

	public void setResponsiblePersonChat_Use(boolean responsiblePersonChat_Use) {
		this.responsiblePersonChat_Use = responsiblePersonChat_Use;
	}

	public int getResponsiblePersonID() {
		return responsiblePersonID;
	}

	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}

	public String getResponsiblePersonMobile() {
		return responsiblePersonMobile;
	}

	public String getBranchName() {
		return branchName;
	}

	public String getCustomerName() {
		return customerName;
	}

	public String getTaskName() {
		return taskName;
	}

	public String getTaskID() {
		return taskID;
	}

	public int getTaskStatus() {
		return taskStatus;
	}

	public String getTaskScdlStartTime() {
		return taskScdlStartTime;
	}

	public boolean getResponsiblePersonChat_Use() {
		return responsiblePersonChat_Use;
	}

}
