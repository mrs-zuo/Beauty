package cn.com.antika.bean;

import java.io.Serializable;
/*
 * 
 * 子服务
 */
public class SubService implements Serializable {
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int    subServiceID;//子服务的ID
	private String subServiceName;//子服务名称
	private int    subServiceSpendTime;//子服务服务时间
	private int ExecutorID;
	
	public int getExecutorID() {
		return ExecutorID;
	}
	public void setExecutorID(int executorID) {
		ExecutorID = executorID;
	}
	public int getSubServiceID() {
		return subServiceID;
	}
	public void setSubServiceID(int subServiceID) {
		this.subServiceID = subServiceID;
	}
	public String getSubServiceName() {
		return subServiceName;
	}
	public void setSubServiceName(String subServiceName) {
		this.subServiceName = subServiceName;
	}
	public int getSubServiceSpendTime() {
		return subServiceSpendTime;
	}
	public void setSubServiceSpendTime(int subServiceSpendTime) {
		this.subServiceSpendTime = subServiceSpendTime;
	}
}
