package com.GlamourPromise.Beauty.bean;

public class EmarketingInfo {
	private  int    fromUserID;//发送者ID
	private  String fromUserName;//发送者姓名
	private  int    messageID;//信息ID
	private  String messageContent;//信息内容
	private  String sendTime;//发送时间
	private  int    sendCount;//发送的总人数
	private  int    receiveCount;//已经接受人数
	private  String toUserName;//发送的目标人
	public int getFromUserID() {
		return fromUserID;
	}
	public String getFromUserName() {
		return fromUserName;
	}
	public int getMessageID() {
		return messageID;
	}
	public String getMessageContent() {
		return messageContent;
	}
	public String getSendTime() {
		return sendTime;
	}
	public int getSendCount() {
		return sendCount;
	}
	public int getReceiveCount() {
		return receiveCount;
	}
	public String getToUserName() {
		return toUserName;
	}
	public void setFromUserID(int fromUserID) {
		this.fromUserID = fromUserID;
	}
	public void setFromUserName(String fromUserName) {
		this.fromUserName = fromUserName;
	}
	public void setMessageID(int messageID) {
		this.messageID = messageID;
	}
	public void setMessageContent(String messageContent) {
		this.messageContent = messageContent;
	}
	public void setSendTime(String sendTime) {
		this.sendTime = sendTime;
	}
	public void setSendCount(int sendCount) {
		this.sendCount = sendCount;
	}
	public void setReceiveCount(int receiveCount) {
		this.receiveCount = receiveCount;
	}
	public void setToUserName(String toUserName) {
		this.toUserName = toUserName;
	}
}
