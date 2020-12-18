package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

import android.os.Parcel;
import android.os.Parcelable;

public class FlyMessage implements Serializable{
	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么) 
	 */
	private static final long serialVersionUID = 1L;
	private int    newMessageCount;
	private int    available;
	private int    customerID;
	private String customerName;
	private String lastMessageContent;
	private String lastSendTime;
	private String headImageUrl;
	public  FlyMessage(){
		
	}
	public int getNewMessageCount() {
		return newMessageCount;
	}
	public int getAvailable() {
		return available;
	}
	public int getCustomerID() {
		return customerID;
	}
	public String getCustomerName() {
		return customerName;
	}
	public String getLastMessageContent() {
		return lastMessageContent;
	}
	public String getLastSendTime() {
		return lastSendTime;
	}
	public String getHeadImageUrl() {
		return headImageUrl;
	}
	public void setNewMessageCount(int newMessageCount) {
		this.newMessageCount = newMessageCount;
	}
	public void setAvailable(int available) {
		this.available = available;
	}
	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
	public void setLastMessageContent(String lastMessageContent) {
		this.lastMessageContent = lastMessageContent;
	}
	public void setLastSendTime(String lastSendTime) {
		this.lastSendTime = lastSendTime;
	}
	public void setHeadImageUrl(String headImageUrl) {
		this.headImageUrl = headImageUrl;
	}
	/*@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}
	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		dest.writeInt(newMessageCount);
		dest.writeInt(available);
		dest.writeInt(customerID);
		dest.writeString(customerName);
		dest.writeString(lastMessageContent);
		dest.writeString(lastSendTime);
		dest.writeString(headImageUrl);
	}
	public static final Parcelable.Creator<FlyMessage> CREATOR = new Parcelable.Creator<FlyMessage>() {
		public FlyMessage createFromParcel(Parcel in) {
			return new FlyMessage(in);
		}

		public FlyMessage[] newArray(int size) {
			return new FlyMessage[size];
		}
	};

	private FlyMessage(Parcel in) {
		newMessageCount=in.readInt();
		available=in.readInt();
		customerID=in.readInt();
		customerName=in.readString();
		lastMessageContent=in.readString();
		lastSendTime=in.readString();
		headImageUrl=in.readString();
	}*/
}
