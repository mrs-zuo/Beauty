package cn.com.antika.implementation;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.LabelInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetTagListTaskImpl implements IGetBackendServerDataTask {
	private static final String METHOD_NAME = "getTagList";
	private static final String METHOD_PARENT_NAME = "Tag";
	private Handler mHandler;
	private UserInfoApplication userInfoApplication;
	private int     tagType;//1：咨询记录或者记事本的标签  2:Account的标签
	@Override
	public String getmethodName() {
		// TODO Auto-generated method stub
		return METHOD_NAME;
	}
	
	public GetTagListTaskImpl(Handler handler,UserInfoApplication userInfoApplication,int tagType){
		mHandler = handler;
		this.userInfoApplication=userInfoApplication;
		this.tagType=tagType;
	}

	@Override
	public String getmethodParentName() {
		// TODO Auto-generated method stub
		return METHOD_PARENT_NAME;
	}

	@Override
	public Object getParamObject() {
		// TODO Auto-generated method stub
		return getParamJsonObject();
	}
	
	protected JSONObject getParamJsonObject() {
		// TODO Auto-generated method stub
		JSONObject paramJsonObject = new JSONObject();
		try {
			paramJsonObject.put("Type",tagType);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return paramJsonObject;
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			if(tagType==1)
				msg.what = resultObject.code;
			else if(tagType==2)
				msg.what=6;
			JSONArray resultJsonObject = (JSONArray) resultObject.result;
			msg.obj = handleJsonObjectResult(resultJsonObject);
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = resultObject.result;
		}

		msg.sendToTarget();
	}
	private ArrayList<LabelInfo> handleJsonObjectResult(JSONArray contentJsonObject){
		ArrayList<LabelInfo> labelList = new ArrayList<LabelInfo>();
		JSONObject JsonItem;
		//咨询或者记事本的标签
		if(tagType==1){
			LabelInfo defaultLabelInfo=new LabelInfo();
			defaultLabelInfo.setID(String.valueOf(0));
			defaultLabelInfo.setLabelName("无");
			labelList.add(defaultLabelInfo);
		}
		LabelInfo labelItem;
		try {
			for (int i = 0; i < contentJsonObject.length(); i++) {
				JsonItem = contentJsonObject.getJSONObject(i);
				labelItem = new LabelInfo();
				labelItem.setID(JsonItem.getString("ID"));
				labelItem.setLabelName(JsonItem.getString("Name"));
				labelList.add(labelItem);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return labelList;
		
	}

	/* (non-Javadoc)
	 * @return
	 * @see com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#getApplication()
	 */
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userInfoApplication;
	}
}
