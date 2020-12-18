package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class BranchJournalOut implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String outName;
	private double outAmount;
	private String outItemRatio;
	public String getOutName() {
		return outName;
	}
	public void setOutName(String outName) {
		this.outName = outName;
	}
	public double getOutAmount() {
		return outAmount;
	}
	public void setOutAmount(double outAmount) {
		this.outAmount = outAmount;
	}
	public String getOutItemRatio() {
		return outItemRatio;
	}
	public void setOutItemRatio(String outItemRatio) {
		this.outItemRatio = outItemRatio;
	}
	
}
