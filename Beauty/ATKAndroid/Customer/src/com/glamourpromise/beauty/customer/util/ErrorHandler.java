package com.glamourpromise.beauty.customer.util;

import android.content.Context;

public class ErrorHandler {
	private Context mContext;
	
	public ErrorHandler(Context context) {
		mContext = context;
	}
	/**
	 * 获取数据失败
	 */
	public void handlerGetDataFalse(String message){
		DialogUtil.createShortDialog(mContext, message);
	}
	/**
	 * 后台异常
	 */
	public void handlerGetDataException(String message){
		DialogUtil.createShortDialog(mContext, message);
	}
	/**
	 * 本地解析错误
	 */
	public void handlerParsingError(){
		DialogUtil.createShortDialog(mContext, "您的网络貌似不给力，请重试");
	}
}
