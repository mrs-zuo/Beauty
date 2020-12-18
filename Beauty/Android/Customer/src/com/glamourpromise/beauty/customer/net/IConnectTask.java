package com.glamourpromise.beauty.customer.net;


public interface IConnectTask {
	public WebApiRequest getRequest();
	public void parseData(WebApiResponse response);
	public void onHandleResponse(WebApiResponse response);
}
