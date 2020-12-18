package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class RemindInformation {
	private String scheduleTime;
	private String serviceName;
	private String excutorPersonHeadImageURL;
	private String responserPerson;
	private String responserPersonID;
	private boolean responserflyMessageAuthority;
	private String  branchName;
	private String  branchPhone;
	private String ResponserPersonHeadImageURL;
    
	public RemindInformation() {
		
	}
	
	public static ArrayList<RemindInformation> parseListByJson(String src){
		ArrayList<RemindInformation> list = new ArrayList<RemindInformation>();
		try {
			JSONArray jarrList = new JSONObject(src).getJSONArray("TaskList");
			int count = jarrList.length();
			RemindInformation item;
			for(int i = 0; i < count; i++){
				item = new RemindInformation();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
	
	public boolean parseByJson(String src){
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
			if(jsSrc.has("TaskScdlStartTime")){
				setScheduleTime(jsSrc.getString("TaskScdlStartTime"));
			}
			if (jsSrc.has("TaskName")) {
				setServiceName(jsSrc.getString("TaskName"));
			}
			if (jsSrc.has("ResponsiblePersonChat_Use")) {
				setResponserflyMessageAuthority(jsSrc.getBoolean("ResponsiblePersonChat_Use"));
			}
			if(jsSrc.has("ResponsiblePersonName")){
				setResponserPerson(jsSrc.getString("ResponsiblePersonName"));
			}
			if (jsSrc.has("ResponsiblePersonID")) {
				setResponserPersonID(jsSrc.getString("ResponsiblePersonID"));
			}
			if (jsSrc.has("HeadImageURL")) {
				setResponserPersonHeadImageURL(jsSrc.getString("HeadImageURL"));
			}
			if (jsSrc.has("BranchName")) {
				setBranchName(jsSrc.getString("BranchName"));
			}
			if (jsSrc.has("BranchPhone")) {
				setBranchPhone(jsSrc.getString("BranchPhone"));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String getScheduleTime() {
		return scheduleTime;
	}

	public void setScheduleTime(String scheduleTime) {
		this.scheduleTime = scheduleTime;
	}

	public String getServiceName() {
		return serviceName;
	}

	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public String getExcutorPersonHeadImageURL() {
		return excutorPersonHeadImageURL;
	}

	public void setExcutorPersonHeadImageURL(String excutorPersonHeadImageURL) {
		this.excutorPersonHeadImageURL = excutorPersonHeadImageURL;
	}

	public String getResponserPerson() {
		return responserPerson;
	}

	public void setResponserPerson(String responserPerson) {
		this.responserPerson = responserPerson;
	}

	public String getResponserPersonID() {
		return responserPersonID;
	}

	public void setResponserPersonID(String responserPersonID) {
		this.responserPersonID = responserPersonID;
	}

	public boolean isResponserflyMessageAuthority() {
		return responserflyMessageAuthority;
	}

	public void setResponserflyMessageAuthority(boolean responserflyMessageAuthority) {
		this.responserflyMessageAuthority = responserflyMessageAuthority;
	}

	public String getBranchPhone() {
		return branchPhone;
	}

	public void setBranchPhone(String branchPhone) {
		this.branchPhone = branchPhone;
	}

	public String getResponserPersonHeadImageURL() {
		return ResponserPersonHeadImageURL;
	}

	public void setResponserPersonHeadImageURL(String responserPersonHeadImageURL) {
		ResponserPersonHeadImageURL = responserPersonHeadImageURL;
	}

	public String getBranchName() {
		return branchName;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}	
	
}
