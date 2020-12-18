package com.glamourpromise.beauty.customer.repository;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class ServiceRepository extends BaseRepository{
	private static final String CATEGORY_NAME = "Service";
	private static final String GET_SERVICE_LIST = "getServiceListByCompanyID";
	private static final String GET_SERVICE_LIST_BY_CATEGORY = "getServiceListByCategoryID";
	
	private String mBranchID;
	private String mCustomerID;
	private int mScreenWidth;
	private UserInfoApplication mApp;
	
	public interface ServiceListCallback{
		public void onServiceListLoaded(ArrayList<ServiceInformation> services);
		public void onError(String message);
		public void onHttpError(int httpCode, int httpMessageCode);
	}
	
	public ServiceRepository(String branchID, String customerID, int screenWidth, UserInfoApplication app) {
		super();
		mBranchID = branchID;
		mCustomerID = customerID;
		mScreenWidth = screenWidth;
		mApp = app;
	}
	
	public void getServiceList(String categoryID, ServiceListCallback callback){		
		WebApiRequest request = getWebApiRequest(categoryID);
		WebApiResponse response = (WebApiResponse) super.get(CATEGORY_NAME, request.getParameters(), request.getHeader(), mApp.getHttpClient());
		if (response.getHttpCode() == 200) {
			String message = "";
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				ArrayList<ServiceInformation> orderList = ServiceInformation.parseListByJson(response.getStringData());
				callback.onServiceListLoaded(orderList);
				return;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				message = response.getMessage();
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				message = Constant.NET_ERR_PROMPT;
				break;
			default:
				message = Constant.NET_ERR_PROMPT;
				break;
			}
			callback.onError(message);
		} else{
			int httpErrorMessage = 0;
			if (response.getHttpCode() == 401) {
					httpErrorMessage = Integer.valueOf(response.getHttpErrorMessage());
			}
			callback.onHttpError(response.getHttpCode(), httpErrorMessage);
		}
		
	}
	private WebApiRequest getWebApiRequest(String categoryID){
		String methodName = "";
		JSONObject para = new JSONObject();
		if (categoryID.equals("0")) {
			methodName = GET_SERVICE_LIST;
		}else{
			methodName = GET_SERVICE_LIST_BY_CATEGORY;
		}
		
		try {
			para.put("CategoryID", categoryID);
			para.put("ImageWidth", String.valueOf(180));
			para.put("ImageHeight", String.valueOf(180));
		} catch (JSONException e) {
			e.printStackTrace();
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, methodName, para.toString(), header);
		return request;
	}

}
