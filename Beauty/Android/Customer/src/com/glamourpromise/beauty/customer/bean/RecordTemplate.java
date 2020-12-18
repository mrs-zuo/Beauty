/**
 * RecordTemplate.java
 * com.GlamourPromise.Beauty.bean
 * tim.zhang@bizapper.com
 * 2015年5月22日 下午1:57:44
 * @version V1.0
 */
package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 *RecordTemplate
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年5月22日 下午1:57:44
 * 专业信息或者咨询记录的模板对象
 */
public class RecordTemplate {
	private int     recordTemplateID;//模板主键
	private int     groupID;
	private String  recordTemplateTitle;//模板标题
	private String  recordTemplateUpdateTime;//模板最后客户答的时间
	private String  recordTemplateResponsibleName;//模板作答的美丽顾问姓名
	public static ArrayList<RecordTemplate> parseListByJson(String src){
		ArrayList<RecordTemplate> list = new ArrayList<RecordTemplate>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			RecordTemplate item;
			for(int i = 0; i < count; i++){
				item = new RecordTemplate();
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
			if (src.has("PaperID")) {
				recordTemplateID= src.getInt("PaperID");
			}
			if (src.has("GroupID")) {
				groupID= src.getInt("GroupID");
			}
			if (src.has("Title")) {
				recordTemplateTitle = src.getString("Title");
			}
			if (src.has("ResponsiblePersonName")) {
				recordTemplateResponsibleName = src.getString("ResponsiblePersonName");
			}
			if (src.has("UpdateTime")) {
				recordTemplateUpdateTime = src.getString("UpdateTime");
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	public int getRecordTemplateID() {
		return recordTemplateID;
	}
	public void setRecordTemplateID(int recordTemplateID) {
		this.recordTemplateID = recordTemplateID;
	}
	public String getRecordTemplateTitle() {
		return recordTemplateTitle;
	}
	public void setRecordTemplateTitle(String recordTemplateTitle) {
		this.recordTemplateTitle = recordTemplateTitle;
	}
	public String getRecordTemplateUpdateTime() {
		return recordTemplateUpdateTime;
	}
	public void setRecordTemplateUpdateTime(String recordTemplateUpdateTime) {
		this.recordTemplateUpdateTime = recordTemplateUpdateTime;
	}
	public String getRecordTemplateResponsibleName() {
		return recordTemplateResponsibleName;
	}
	public void setRecordTemplateResponsibleName(String recordTemplateResponsibleName) {
		this.recordTemplateResponsibleName = recordTemplateResponsibleName;
	}
	public int getGroupID() {
		return groupID;
	}
	public void setGroupID(int groupID) {
		this.groupID = groupID;
	}
}
