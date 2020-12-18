package com.glamourpromise.beauty.customer.bean;

public class NewMessageInformation {
	private String mCompanyID;
	private String mBranchID;
	private String mSenderID;
	private String mReceiverIDs;
	private String mMessageContent;
	private String mMessageType;
	private String mGroupFlag;
	
	public NewMessageInformation(){
		
	}

	public String getmCompanyID() {
		return mCompanyID;
	}

	public void setmCompanyID(String mCompanyID) {
		this.mCompanyID = mCompanyID;
	}

	public String getmBranchID() {
		return mBranchID;
	}

	public void setmBranchID(String mBranchID) {
		this.mBranchID = mBranchID;
	}

	public String getmSenderID() {
		return mSenderID;
	}

	public void setmSenderID(String mSenderID) {
		this.mSenderID = mSenderID;
	}

	public String getmReceiverIDs() {
		return mReceiverIDs;
	}

	public void setmReceiverIDs(String mReceiverIDs) {
		this.mReceiverIDs = mReceiverIDs;
	}

	public String getmMessageContent() {
		return mMessageContent;
	}

	public void setmMessageContent(String mMessageContent) {
		this.mMessageContent = mMessageContent;
	}

	public String getmMessageType() {
		return mMessageType;
	}

	public void setmMessageType(String mMessageType) {
		this.mMessageType = mMessageType;
	}

	public String getmGroupFlag() {
		return mGroupFlag;
	}

	public void setmGroupFlag(String mGroupFlag) {
		this.mGroupFlag = mGroupFlag;
	}
	
	
}
