package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;

public class RecordImage implements Serializable{
	private static final long serialVersionUID = 1L;
	private String  recordImageID;
	private String recordImageTag;
	private String recordImageUrl;
	public String getRecordImageID() {
		return recordImageID;
	}
	public void setRecordImageID(String recordImageID) {
		this.recordImageID = recordImageID;
	}
	public String getRecordImageTag() {
		return recordImageTag;
	}
	public void setRecordImageTag(String recordImageTag) {
		this.recordImageTag = recordImageTag;
	}
	public String getRecordImageUrl() {
		return recordImageUrl;
	}
	public void setRecordImageUrl(String recordImageUrl) {
		this.recordImageUrl = recordImageUrl;
	}
}
