package com.GlmourPromise.Beauty.interfaces;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.WebDataObject;

public interface IGetBackendServerDataTask {
	/*获取方法名*/
	public String getmethodName();
	/*获取.asmx文件名*/
	public String getmethodParentName();
	/*获取参数*/
	public Object getParamObject();
	/*返回结果处理*/
	public void handleResult(WebDataObject resultObject);
	/*获得Application对象*/
	public UserInfoApplication getApplication();
}
