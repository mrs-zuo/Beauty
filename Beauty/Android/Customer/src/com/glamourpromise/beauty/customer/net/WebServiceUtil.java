package com.glamourpromise.beauty.customer.net;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.protocol.HTTP;
import android.util.Log;
public class WebServiceUtil {
	private WebServiceUtil() {

	}
	/*
	 * HTTPS协议访问 Json数据格式
	 */
	public static String requestWebApiAction(String categoryName, String jsonStrParam, WebApiHttpHead header) {
		StringBuilder url;
		// 正式用户
		if (header.getFormalFlag() == 0) {
			url = new StringBuilder("https://capi.beauty.glamise.com/");
			//url = new StringBuilder("http://10.0.0.109:8888/");
		}
		// demo用户
		else if (header.getFormalFlag() == 1) {
			url = new StringBuilder("https://capi.beauty.glamourpromise.com/");
		} else {
			url = new StringBuilder("https://capi.Test.beauty.glamise.com/");
		}
		url.append(categoryName);
		url.append("/");
		url.append(header.getMethodName());
		HttpPost httpPost=new HttpPost(url.toString());
		httpPost.setHeader("Accept", "application/json");
		httpPost.setHeader("Content-type", "application/json");
		httpPost.setHeader("Accept-Encoding", "gzip");
		String tmp;
		//可选
		tmp = header.getCompanyID();
		httpPost.addHeader("CO", tmp);
		tmp = header.getBranchID();
		httpPost.addHeader("BR", tmp);
		tmp = header.getUserID();
		httpPost.addHeader("US", tmp);
		tmp = header.getGUID();
		httpPost.addHeader("GU", tmp);
		tmp = header.getAuthorization();
		httpPost.addHeader("Authorization", tmp);
		//必填
		tmp = header.getClient();
		httpPost.addHeader("CT", tmp);
		tmp = header.getDeviceType();
		httpPost.addHeader("DT", tmp);
		tmp = header.getAppVersion();
		httpPost.addHeader("AV", tmp);
		tmp = header.getMethodName();
		httpPost.addHeader("ME", tmp);
		tmp = header.getActionTime();
		httpPost.addHeader("TI", tmp);
	    try {
			httpPost.setEntity(new StringEntity(jsonStrParam, HTTP.UTF_8));
		} catch (UnsupportedEncodingException e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
			return "";
		}
        HttpClient  httpClient=ConnectionManager.getNewHttpClient();
        HttpResponse httpResponse=null;
		try {
			httpResponse = httpClient.execute(httpPost);
		} catch (ClientProtocolException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
			return "";
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			return "";
		}
		
		// 发送请求并获取反馈  
        String resultString="";
        // 解析返回的内容  
        if (httpResponse.getStatusLine().getStatusCode() == 200) // StatusCode为200表示与服务端连接成功  
        {  
            StringBuilder builder = new StringBuilder();
            BufferedReader bufferedReader2;
			try {
				bufferedReader2 = new BufferedReader(  
				        new InputStreamReader(httpResponse.getEntity()  
				                .getContent(), "UTF-8"));
				for (String s = bufferedReader2.readLine(); s != null; s = bufferedReader2.readLine()) {  
	                builder.append(s);  
	            } 
			} catch (IllegalStateException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            resultString=builder.toString();

        }
        Log.d("getStatusCode", String.valueOf(httpResponse.getStatusLine().getStatusCode()));
        Log.d("resultString", resultString);
		return resultString;
	}
	
	/*
	 * HTTPS协议访问 Json数据格式
	 */
	public static HttpResponse requestWebApiAction_2(String categoryName, String jsonStrParam, WebApiHttpHead header, HttpClient client) {
		StringBuilder url;
		if(header == null || categoryName == null || jsonStrParam == null){
			return null;
		}
		// 正式用户
		if (header.getFormalFlag() == 0) {
			url = new StringBuilder("https://capi.beauty.glamise.com/");	
			//url = new StringBuilder("http://10.0.0.109:8888/");
		}
		// demo用户
		else if (header.getFormalFlag() == 1) {
			url = new StringBuilder("https://capi.beauty.glamourpromise.com/");
		} else {

			url = new StringBuilder("https://capi.Test.beauty.glamise.com/");
		}
		
		url.append(categoryName);
		url.append("/");
		url.append(header.getMethodName());
		
		Log.d("url", url.toString());
		Log.d("header", header.getJson());
		
		HttpPost httpPost=new HttpPost(url.toString());
		
		httpPost.setHeader("Accept", "application/json");
		httpPost.setHeader("Content-type", "application/json");
		httpPost.setHeader("Accept-Encoding", "gzip");
		
		String tmp;
		//可选
		tmp = header.getCompanyID();
		httpPost.addHeader("CO", tmp);
		
		tmp = header.getBranchID();
		httpPost.addHeader("BR", tmp);
		
		tmp = header.getUserID();
		httpPost.addHeader("US", tmp);
		
		tmp = header.getGUID();
		httpPost.addHeader("GU", tmp);
		
		tmp = header.getAuthorization();
		httpPost.addHeader("Authorization", tmp);
		//必填
		tmp = header.getClient();
		httpPost.addHeader("CT", tmp);
		
		tmp = header.getDeviceType();
		httpPost.addHeader("DT", tmp);
		
		tmp = header.getAppVersion();
		httpPost.addHeader("AV", tmp);
		
		tmp = header.getMethodName();
		httpPost.addHeader("ME", tmp);
		
		tmp = header.getActionTime();
		httpPost.addHeader("TI", tmp);
		Header[] tmpHeader = httpPost.getAllHeaders();
		StringBuffer strheader = new StringBuffer();
		for(int i = 0 ; i < tmpHeader.length;i++){
			strheader.append(tmpHeader[i].getName());
			strheader.append(":");
			strheader.append(tmpHeader[i].getValue());
			strheader.append("\n");
		}
		Log.d("header", strheader.toString());
		
	    try {
			httpPost.setEntity(new StringEntity(jsonStrParam, HTTP.UTF_8));
		} catch (UnsupportedEncodingException e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
			return null;
		}
	    
       
        HttpClient  httpClient=client;
        HttpResponse httpResponse=null;
		try {
			httpResponse = httpClient.execute(httpPost);
		} catch (ClientProtocolException e1) {
			e1.printStackTrace();
			return null;
		} catch (IOException e1) {
			return null;
		} // 发送请求并获取反馈  
		return httpResponse;
	}

}
