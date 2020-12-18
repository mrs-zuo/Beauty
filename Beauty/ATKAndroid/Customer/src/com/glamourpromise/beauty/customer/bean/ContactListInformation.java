package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ContactListInformation {

	private String newMessageCount;
	private String accountID;
	private String accountName;
	private String messageContent;
	private String sendTime;
	private String headImage="";
	private int flyMessageAuthority;//飞语权限


	public ContactListInformation() {
		newMessageCount = "0";
		flyMessageAuthority = 1;
	}
	
	public static ArrayList<ContactListInformation> parseListByJson(String src){
		ArrayList<ContactListInformation> list = new ArrayList<ContactListInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			ContactListInformation item;
			for(int i = 0; i < count; i++){
				item = new ContactListInformation();
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
			if(jsSrc.has("AccountID")){
				setAccountID(jsSrc.getString("AccountID"));
			}
			if (jsSrc.has("AccountName")) {
				setAccountName(jsSrc.getString("AccountName"));
			}
			if (jsSrc.has("SendTime")) {
				String sendTime = jsSrc.getString("SendTime");
				if(!sendTime.equals("null"))
					setSendTime(sendTime);
			}
			if (jsSrc.has("MessageContent")) {
				setMessageContent(jsSrc.getString("MessageContent"));
			}
			if (jsSrc.has("NewMessageCount")) {
				setNewMeessageCount(jsSrc.getString("NewMessageCount"));
			}
			if (jsSrc.has("HeadImageURL")) {
				setHeadImage(jsSrc.getString("HeadImageURL"));
			}else{
				setHeadImage("");
			}
			if (jsSrc.has("Chat_Use")) {
				setFlyMessageAuthority(jsSrc.getInt("Chat_Use"));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setNewMeessageCount(String newMessageCount) {
		this.newMessageCount = newMessageCount;
	}

	public String getNewMeessageCount() {
		return this.newMessageCount;
	}

	public void setAccountID(String accountID) {
		this.accountID = accountID;
	}

	public String getAccountID() {
		return this.accountID;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public String getAccountName() {
		return this.accountName;
	}

	public void setMessageContent(String messageContent) {
		this.messageContent = messageContent;
	}

	public String getMessageContent() {
		return this.messageContent;
	}

	public void setSendTime(String sendTime) {
		this.sendTime = sendTime;
	}

	public String getSendTime() {
		return this.sendTime;
	}

	public void setHeadImage(String headImage) {
		this.headImage = headImage;
	}

	public String getHendImage() {
		return this.headImage;
	}

	public int getFlyMessageAuthority() {
		return flyMessageAuthority;
	}

	public void setFlyMessageAuthority(int flyMessageAuthority) {
		this.flyMessageAuthority = flyMessageAuthority;
	}

}
