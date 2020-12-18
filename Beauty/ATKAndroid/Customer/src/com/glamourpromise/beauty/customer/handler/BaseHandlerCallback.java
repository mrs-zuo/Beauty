package com.glamourpromise.beauty.customer.handler;

import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.ErrorHandler;

public class BaseHandlerCallback implements Handler.Callback{
	
	public interface IResultHandler{
		/**
		 * 
		 * @param resultObject
		 */
		public void handlerResult(Object resultObject);
	}
	
	private ErrorHandler mErrorHandler;
	private IResultHandler mResultHandler;
	
	/**
	 * 自定义错误处理
	 * @param resultHandler
	 * @param errorHandler
	 */
	public BaseHandlerCallback(IResultHandler resultHandler, ErrorHandler errorHandler){
		mResultHandler = resultHandler;
		mErrorHandler = errorHandler;
	}
	/**
	 * 使用默认的错误处理
	 * @param resultHandler
	 * @param context
	 */
	public BaseHandlerCallback(IResultHandler resultHandler, Context context){
		mResultHandler = resultHandler;
		mErrorHandler = new ErrorHandler(context);
	}

	@Override
	public boolean handleMessage(Message msg) {
		// TODO Auto-generated method stub
		WebApiResponse response = (WebApiResponse) msg.obj;
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				mResultHandler.handlerResult(response.getStringData());
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				mErrorHandler.handlerGetDataFalse(response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				mErrorHandler.handlerParsingError();
				break;
			default:
				break;
			}
		}else{
			mErrorHandler.handlerParsingError();
		}
		return true;
	}

}
