package com.glamourpromise.beauty.customer.repository;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.LeftMenuBean;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class LeftMenuRepository extends BaseRepository {
	private static final String CATEGORY_NAME = "customer";
	private static final String GET_NEW_COUNT_METHOD = "getCartAndNewMessageCount";
	
	public interface MenuPromptInfoCallback{
		public void onLoaded(LeftMenuBean leftmenuCount);
	}
	
	private MenuPromptInfoCallback mCallback;
	private String mCustomerID;
	private UserInfoApplication mApp;
	
	private WebApiRequest mRequest;
	
	private SharedPreferences mPre;
	private LeftMenuBean mLeftmenuCount;
	
	
	
	public LeftMenuRepository(String customerID, UserInfoApplication app) {
		mCustomerID = customerID;
		mApp = app;
		mPre = mApp.getSharedPreferences();
		mLeftmenuCount = new LeftMenuBean();
	}

	public void getMenuPromptCount(MenuPromptInfoCallback callback){
		mCallback = callback;
		WebApiRequest request =  getWebApiRequest();
		WebApiResponse response = super.get(CATEGORY_NAME, request.getParameters(), request.getHeader(), mApp.getHttpClient());
		handleRepose(response);
	}

	private void handleRepose(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				mLeftmenuCount.parseByJson(response.getStringData());
				storeCount(mLeftmenuCount);
				break;
			default:
				mLeftmenuCount.setCartCount(mPre.getString("cartCount", "0"));
				mLeftmenuCount.setNewMessageCount(mPre.getString("newMessageCount", "0"));
				mLeftmenuCount.setPromotionCount(mPre.getString("promotionCount", "0"));
				mLeftmenuCount.setRemindCount(mPre.getString("remindCount", "0"));
				mLeftmenuCount.setUnconfirmedOrderCount(mPre.getString("unconfirmOrderCount", "0"));
				mLeftmenuCount.setUnpaidOrderCount(mPre.getString("unpaidOrderCount", "0"));
				break;
			}
		}
		mCallback.onLoaded(mLeftmenuCount);
	}
	
	private WebApiRequest getWebApiRequest(){
		if(mRequest == null){
			JSONObject para = new JSONObject();
			try {
				para.put("CustomerID", mCustomerID);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_NEW_COUNT_METHOD, para.toString());
			mRequest = new WebApiRequest(CATEGORY_NAME, GET_NEW_COUNT_METHOD, para.toString(), header);
		}
		return mRequest;
	}
	
	/**
	 * 
	 * @param data
	 */
	private void storeCount(LeftMenuBean data) {
		Editor editor = mPre.edit();// 获取编辑器
		editor.putString("newMessageCount", data.getNewMessageCount());
		editor.putString("cartCount", data.getCartCount());
		editor.putString("promotionCount", data.getPromotionCount());
		editor.putString("remindCount", data.getRemindCount());
		editor.putString("unpaidOrderCount", data.getUnpaidOrderCount());
		editor.putString("unconfirmOrderCount", data.getUnconfirmedOrderCount());
		editor.commit();// 提交修改
	}

}
