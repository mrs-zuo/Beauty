package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.ksoap2.serialization.PropertyInfo;
import org.ksoap2.serialization.SoapObject;

public class NoticeInformation {
	private String noticeTitle="";
	private String noticeCreateTime="";
	private String NoticeContent="";
	private String NoticeStartTime="";
	private String NoticeEndTime="";
	
	public NoticeInformation(){
		
	}
	
	public static ArrayList<NoticeInformation> parseListByJson(String src){
		ArrayList<NoticeInformation> list = new ArrayList<NoticeInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			NoticeInformation item;
			for(int i = 0; i < count; i++){
				item = new NoticeInformation();
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
			if(jsSrc.has("NoticeTitle")){
				setNoticeTitle(jsSrc.getString("NoticeTitle"));
			}
			if (jsSrc.has("CreateTime")) {
				setNoticeCreateTime(jsSrc.getString("CreateTime"));
			}
			if (jsSrc.has("NoticeContent")) {
				setNoticeContent(jsSrc.getString("NoticeContent"));
			}
			if (jsSrc.has("StartDate")) {
				setNoticeStartTime(jsSrc.getString("StartDate"));
			}
			if (jsSrc.has("EndDate")) {
				setNoticeEndTime(jsSrc.getString("EndDate"));
			}
			
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String getNoticeTitle() {
		return noticeTitle;
	}

	public void setNoticeTitle(String noticeTitle) {
		this.noticeTitle = noticeTitle;
	}

	public String getNoticeCreateTime() {
		return noticeCreateTime;
	}

	public void setNoticeCreateTime(String noticeCreateTime) {
		this.noticeCreateTime = noticeCreateTime;
	}

	public String getNoticeContent() {
		return NoticeContent;
	}

	public void setNoticeContent(String noticeContent) {
		NoticeContent = noticeContent;
	}

	public String getNoticeStartTime() {
		return NoticeStartTime;
	}

	public void setNoticeStartTime(String noticeStartTime) {
		NoticeStartTime = noticeStartTime;
	}

	public String getNoticeEndTime() {
		return NoticeEndTime;
	}

	public void setNoticeEndTime(String noticeEndTime) {
		NoticeEndTime = noticeEndTime;
	}
	public void setInfoBySoapObject(SoapObject contentObject){
		PropertyInfo propertyInfo = new PropertyInfo();
		String propertyName;
		String propertyValue;
		for(int i = 0; i < contentObject.getPropertyCount(); i++){
			contentObject.getPropertyInfo(i, propertyInfo);
			propertyName = propertyInfo.getName();
			propertyValue = String.valueOf(propertyInfo.getValue());
			if(propertyName.equals("NoticeTitle")){
				noticeTitle = propertyValue;
			}else if(propertyName.equals("CreateTime")){
				noticeCreateTime = propertyValue;
			}else if(propertyName.equals("StartDate")){
				NoticeStartTime = propertyValue;
			}else if(propertyName.equals("EndDate")){
				NoticeEndTime = propertyValue;
			}else if(propertyName.equals("NoticeContent")){
				NoticeContent = propertyValue;
			}
		}
	}
}
