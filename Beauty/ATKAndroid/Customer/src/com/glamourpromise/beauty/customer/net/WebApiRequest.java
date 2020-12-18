package com.glamourpromise.beauty.customer.net;

public class WebApiRequest {
	
	private String mCategoryName;
	private String mMethodName;
	private String mParameters;
	private WebApiHttpHead mHeader;
	public WebApiRequest(String categoryName, String methodName, String parameters, WebApiHttpHead header) {
		mCategoryName = categoryName;
		mMethodName = methodName;
		mParameters = parameters;
		mHeader = header;
	}
	public String getCategoryName() {
		return mCategoryName;
	}
	public void setCategoryName(String categoryName) {
		mCategoryName = categoryName;
	}
	public String getMethodName() {
		return mMethodName;
	}
	public void setMethodName(String methodName) {
		mMethodName = methodName;
	}
	public String getParameters() {
		return mParameters;
	}
	public void setParameters(String parameters) {
		mParameters = parameters;
	}
	public WebApiHttpHead getHeader() {
		return mHeader;
	}
	public void setHeader(WebApiHttpHead header) {
		mHeader = header;
	}
	
	
}
