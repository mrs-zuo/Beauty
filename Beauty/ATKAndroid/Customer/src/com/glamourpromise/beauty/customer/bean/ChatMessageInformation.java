package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ChatMessageInformation {
	
	private String messageID;
	private String messageContent;
	private String sendTime;
	private String sendOrReceiveFlag;
	private String isNewMessage;
	private String isSendSuccess;
	private int newMessageID;
	
	public ChatMessageInformation()
	{
		newMessageID = 0;
		messageContent = "";
	}
	
	public static ArrayList<ChatMessageInformation> parseListByJson(String src){
		ArrayList<ChatMessageInformation> list = new ArrayList<ChatMessageInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			ChatMessageInformation item;
			for(int i = 0; i < count; i++){
				item = new ChatMessageInformation();
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
			if(src.has("MessageID")){
				setMessageID(src.getString("MessageID"));
			}
			if(src.has("MessageContent")){
				setMessageContent(src.getString("MessageContent"));
			}
			if(src.has("SendTime")){
				setSendTime(src.getString("SendTime"));
			}
			if(src.has("SendOrReceiveFlag")){
				setSendOrReceiveFlag(src.getString("SendOrReceiveFlag"));
			}
			setIsNewMessage("0");
			setIsSendSuccess("1");
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return false;
	}
	
	public void setMessageID(String messageID){
		this.messageID = messageID;
	}
	public String getMessageID(){
		return this.messageID;
	}
	
	public void setMessageContent(String messageContent){
		this.messageContent = messageContent;
	}
	public String getMessageContent(){
		return this.messageContent;
	}
	
	public int getNewMessageID() {
		return newMessageID;
	}

	public void setNewMessageID(int newMessageID) {
		this.newMessageID = newMessageID;
	}

	public void setSendTime(String sendTime){
		this.sendTime = sendTime;
	}
	public String getSendTime(){
		return this.sendTime;
	}
	
	public void setSendOrReceiveFlag(String sendOrReceiveFlag){
		this.sendOrReceiveFlag = sendOrReceiveFlag;
	}
	public String getSendOrReceiveFlag(){
		return this.sendOrReceiveFlag;
	}
	
	public void setIsNewMessage(String isNewMessage){
		this.isNewMessage = isNewMessage;
	}
	public String getIsNewMessage(){
		return isNewMessage;
	}
	
	public void setIsSendSuccess(String isSendSuccess){
		this.isSendSuccess = isSendSuccess;
	}
	
	public String getIsSendSuccess(){
		return isSendSuccess;
	}
}
