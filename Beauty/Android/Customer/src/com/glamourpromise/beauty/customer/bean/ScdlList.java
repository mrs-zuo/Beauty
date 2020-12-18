package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ScdlList {

	private long   taskID;
	private String responsiblePersonName;
	private String taskScdlStartTime;

	public ScdlList() {
	}

	public static ArrayList<ScdlList> parseListByJson(String src) {
		ArrayList<ScdlList> list = new ArrayList<ScdlList>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			ScdlList item;
			for (int i = 0; i < count; i++) {
				item = new ScdlList();
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
				setTaskID(jsSrc.getLong("TaskID"));
			if (jsSrc.has("ResponsiblePersonName"))
				setResponsiblePersonName(jsSrc
						.getString("ResponsiblePersonName"));
			if (jsSrc.has("TaskScdlStartTime"))
				setTaskScdlStartTime(jsSrc.getString("TaskScdlStartTime"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	

	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
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

	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}

	public String getTaskScdlStartTime() {
		return taskScdlStartTime;
	}
}
