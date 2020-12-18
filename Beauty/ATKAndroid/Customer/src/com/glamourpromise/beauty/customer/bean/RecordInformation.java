package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class RecordInformation 
{
	private String strCreatorName;
	private String strCreatorID;
	private String strRecordID;
	private String strRecordTime;
	private String strProblem;
	private String strSuggestion;
	
	public static ArrayList<RecordInformation> parseListByJson(String src){
		ArrayList<RecordInformation> list = new ArrayList<RecordInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			RecordInformation item;
			for(int i = 0; i < count; i++){
				item = new RecordInformation();
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
			if(jsSrc.has("CreatorID")){
				setCreatorID(jsSrc.getString("CreatorID"));
			}
			if (jsSrc.has("CreatorName")) {
				setCreatorName(jsSrc.getString("CreatorName"));
			}
			if (jsSrc.has("Problem")) {
				setProblem(jsSrc.getString("Problem"));
			}
			if (jsSrc.has("RecordID")) {
				setRecordID(jsSrc.getString("RecordID"));
			}
			if (jsSrc.has("RecordTime")) {
				setRecordTime(jsSrc.getString("RecordTime"));
			}
			if (jsSrc.has("Suggestion")) {
				setSuggestion(jsSrc.getString("Suggestion"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public String getCreatorName() 
	{
		return strCreatorName;
	}
	public void setCreatorName(String strCreatorName) 
	{
		this.strCreatorName = strCreatorName;
	}
	
	public String getCreatorID() 
	{
		return strCreatorID;
	}
	public void setCreatorID(String strCreatorID) 
	{
		this.strCreatorID = strCreatorID;
	}
	
	public String getRecordID() 
	{
		return strRecordID;
	}
	public void setRecordID(String strRecordID) 
	{
		this.strRecordID = strRecordID;
	}
	
	public String getRecordTime() 
	{
		return strRecordTime;
	}
	public void setRecordTime(String strRecordTime) 
	{
		this.strRecordTime = strRecordTime;
	}
	
	public String getProblem() 
	{
		return strProblem;
	}
	public void setProblem(String strProblem) 
	{
		this.strProblem = strProblem;
	}
	
	public String getSuggestion() 
	{
		return strSuggestion;
	}
	public void setSuggestion(String strSuggestion) 
	{
		this.strSuggestion = strSuggestion;
	}
}
