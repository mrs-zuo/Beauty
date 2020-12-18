package com.glamourpromise.beauty.customer.repository;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;

import android.content.AsyncTaskLoader;
import android.content.Context;
import android.util.Log;

import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.net.WebServiceUtil;

public abstract class BaseLoader extends AsyncTaskLoader<WebApiResponse> {
	private HttpClient mHttpClient;

	public BaseLoader(Context context, HttpClient httpClient) {
		super(context);
		mHttpClient = httpClient;
	}

	@Override
	protected void onStartLoading() {
		forceLoad();
	}

	@Override
	public void deliverResult(WebApiResponse data) {
		super.deliverResult(data);
	}

	@Override
	public WebApiResponse loadInBackground() {
		WebApiRequest request = getRequest();
		WebApiResponse data = connectWebApi(request);
		return data;
	}
		
	protected abstract Object parseData(String resultString);
	
	protected abstract WebApiRequest getRequest();
	
	private WebApiResponse connectWebApi(WebApiRequest request) {
		WebApiHttpHead header = request.getHeader();
		String para = request.getParameters();
		String categoryName = request.getCategoryName();
		HttpResponse httpResponse = WebServiceUtil.requestWebApiAction_2(categoryName, para, header, mHttpClient);
		
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
				response.mData = parseData(response.getStringData());
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
