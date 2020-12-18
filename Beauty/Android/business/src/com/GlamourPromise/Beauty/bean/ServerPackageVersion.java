package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class ServerPackageVersion implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String packageVersion;//服务器 android包的版本信息
	private boolean  mustUpdate;//是否是强制升级  false:非强制升级  true:强制升级
	private long   requestStartTime;//请求服务器android包的版本信息开始时间
	public String getPackageVersion() {
		return packageVersion;
	}
	public void setPackageVersion(String packageVersion) {
		this.packageVersion = packageVersion;
	}
	public boolean isMustUpdate() {
		return mustUpdate;
	}
	public void setMustUpdate(boolean mustUpdate) {
		this.mustUpdate = mustUpdate;
	}
	public long getRequestStartTime() {
		return requestStartTime;
	}
	public void setRequestStartTime(long requestStartTime) {
		this.requestStartTime = requestStartTime;
	}
}
