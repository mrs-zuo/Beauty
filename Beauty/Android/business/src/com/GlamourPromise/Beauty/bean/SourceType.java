package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
/*
 * 顾客来源
 * */
public class SourceType implements  Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int sourceTypeID;
	private String  sourceTypeName;
	public int getSourceTypeID() {
		return sourceTypeID;
	}
	public void setSourceTypeID(int sourceTypeID) {
		this.sourceTypeID = sourceTypeID;
	}
	public String getSourceTypeName() {
		return sourceTypeName;
	}
	public void setSourceTypeName(String sourceTypeName) {
		this.sourceTypeName = sourceTypeName;
	}
}
