package cn.com.antika.bean;

import java.io.Serializable;

import org.json.JSONException;
import org.json.JSONObject;

public class NoticeInfo implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private String noticeTitle;
	private String noticeCreateTime;
	private String NoticeContent;
	private String NoticeStartTime;
	private String NoticeEndTime;
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
	
	public void setInfoByJsonObject(JSONObject noticeJson){
			try {
				if(noticeJson.has("NoticeTitle") && !noticeJson.isNull("NoticeTitle"))
					noticeTitle = noticeJson.getString("NoticeTitle");
				if(noticeJson.has("CreateTime") && !noticeJson.isNull("CreateTime"))
					noticeCreateTime = noticeJson.getString("CreateTime");
				if(noticeJson.has("StartDate") && !noticeJson.isNull("StartDate"))
					NoticeStartTime = noticeJson.getString("StartDate");
				if(noticeJson.has("EndDate") && !noticeJson.isNull("EndDate"))
					NoticeEndTime = noticeJson.getString("EndDate");
				if(noticeJson.has("NoticeContent") && !noticeJson.isNull("NoticeContent"))
					NoticeContent = noticeJson.getString("NoticeContent");
			} catch (JSONException e) {
			}
	}
	
	
}
