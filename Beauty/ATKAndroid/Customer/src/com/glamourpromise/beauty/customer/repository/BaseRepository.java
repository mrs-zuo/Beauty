package com.glamourpromise.beauty.customer.repository;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;

import android.util.Log;

import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.net.WebServiceUtil;

public abstract class BaseRepository{
	
	
	protected WebApiResponse get(String categoryName, String para, WebApiHttpHead header, HttpClient httpClient) {
		WebApiResponse response = handleWebApiRequestTask(categoryName, para, header, httpClient);//处理任务
		return response;
	} 
		
	private WebApiResponse handleWebApiRequestTask(String categoryName, String para, WebApiHttpHead header, HttpClient httpClient){
		HttpResponse httpResponse = WebServiceUtil.requestWebApiAction_2(categoryName, para, header,httpClient);
		
		WebApiResponse response = new WebApiResponse();
		if(httpResponse == null){
			response.setCode(WebApiResponse.GET_DATA_NULL);
		}else{
			int httpCode = httpResponse.getStatusLine().getStatusCode();
			response.setHttpCode(httpCode);
			switch (httpCode) {
			case 200:
				// 解析返回的内容  
			    String resultString="";
				StringBuilder builder = new StringBuilder();
				BufferedReader bufferedReader2 = null;
				InputStreamReader inputReader;
				try {
					inputReader = new InputStreamReader(httpResponse.getEntity().getContent(), "UTF-8");
					bufferedReader2 = new BufferedReader(inputReader);
					for (String s = bufferedReader2.readLine(); s != null; s = bufferedReader2.readLine()) {
						builder.append(s);
					}
					bufferedReader2.close();
					inputReader.close();
				} catch (IllegalStateException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
				resultString = builder.toString();
				response.setByJson(resultString);
				Log.d("resultString", resultString);
				break;
			case 500:
				break;
			case 401:
				Header responseHeader = httpResponse.getFirstHeader("errorMessage");
				String httpErrorMessage = responseHeader.getValue();
				response.setHttpErrorMessage(httpErrorMessage);
				break;

			default:
				break;
			}
		}
		return response;
	}

}
