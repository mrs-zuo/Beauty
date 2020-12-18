package cn.com.antika.bean;

import java.io.Serializable;

/*
 * 飞语详细信息
 * */
public class FlymessageDetail implements Serializable {

	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么)
	 */
	private static final long serialVersionUID = 1L;
	private int     messageID;
	private int     messageType;
	private boolean groupFlag;
	private String  messageContent;
	private String  sendTime;
	private int     sendOrReceiveFlag;
	public int getMessageID() {
		return messageID;
	}
	public int getMessageType() {
		return messageType;
	}
	public boolean isGroupFlag() {
		return groupFlag;
	}
	public String getMessageContent() {
		return messageContent;
	}
	public String getSendTime() {
		return sendTime;
	}
	public int getSendOrReceiveFlag() {
		return sendOrReceiveFlag;
	}
	public void setMessageID(int messageID) {
		this.messageID = messageID;
	}
	public void setMessageType(int messageType) {
		this.messageType = messageType;
	}
	public void setGroupFlag(boolean groupFlag) {
		this.groupFlag = groupFlag;
	}
	public void setMessageContent(String messageContent) {
		this.messageContent = messageContent;
	}
	public void setSendTime(String sendTime) {
		this.sendTime = sendTime;
	}
	public void setSendOrReceiveFlag(int sendOrReceiveFlag) {
		this.sendOrReceiveFlag = sendOrReceiveFlag;
	}
}
