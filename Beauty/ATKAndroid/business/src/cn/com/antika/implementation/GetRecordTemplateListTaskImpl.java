/**
 * GetOpportunityListTaskImpl.java
 * cn.com.antika.implementation
 * tim.zhang@bizapper.com
 * 2015年5月14日 下午3:37:52
 * @version V1.0
 */
package cn.com.antika.implementation;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.RecordTemplate;
import cn.com.antika.bean.RecordTemplateListBaseConditionInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

/**
 * GetRecordTemplateListTaskImpl  获取已回答的专业信息的模板列表
 * 
 * @author tim.zhang@bizapper.com 2015年5月14日 下午3:37:52
 */
public class GetRecordTemplateListTaskImpl implements IGetBackendServerDataTask {
	private static final String METHOD_NAME = "GetAnswerPaperList";
	private static final String METHOD_PARENT_NAME = "Paper";
	private RecordTemplateListBaseConditionInfo mRecordTemplateListBaseParam;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;
	public GetRecordTemplateListTaskImpl(Handler handler,RecordTemplateListBaseConditionInfo recordTemplateListBaseParam,UserInfoApplication userinfoApplication) {
		mHandler = handler;
		mRecordTemplateListBaseParam =recordTemplateListBaseParam;
		this.userinfoApplication = userinfoApplication;
	}

	@Override
	public String getmethodName() {
		// TODO Auto-generated method stub
		return METHOD_NAME;
	}

	@Override
	public String getmethodParentName() {
		// TODO Auto-generated method stub
		return METHOD_PARENT_NAME;
	}
	@Override
	public Object getParamObject() {
		// TODO Auto-generated method stub
		JSONObject param = new JSONObject();
		try {
			// 基本条件
			param.put("UpdateTime",mRecordTemplateListBaseParam.getUpdateTime());
			param.put("PageIndex",mRecordTemplateListBaseParam.getPageIndex());
			param.put("PageSize",mRecordTemplateListBaseParam.getPageSize());
			param.put("FilterByTimeFlag",mRecordTemplateListBaseParam.getFilterByTimeFlag());
			param.put("StartTime",mRecordTemplateListBaseParam.getStartDate());
			param.put("EndTime",mRecordTemplateListBaseParam.getEndDate());
			param.put("CustomerID",mRecordTemplateListBaseParam.getCustomerID());
			param.put("IsShowAll",mRecordTemplateListBaseParam.isShowAll());
			if(mRecordTemplateListBaseParam.getResponsiblePersonID()!=null && !("").equals(mRecordTemplateListBaseParam.getResponsiblePersonID()))
				param.put("ResponsiblePersonIDs",new JSONArray(mRecordTemplateListBaseParam.getResponsiblePersonID()));
		} catch (JSONException e) {
		}
		return param;
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		if (resultObject.code == Constant.GET_WEB_DATA_TRUE) {
			JSONObject resultJsonObject = (JSONObject) resultObject.result;
			msg.obj = handleJsonObjectResult(resultJsonObject);
			try {
				msg.arg1 = resultJsonObject.getInt("RecordCount");
				msg.arg2 = resultJsonObject.getInt("PageCount");
			} catch (JSONException e) {
			}
		} else if (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE) {
			msg.obj = resultObject.result;
		} else if (resultObject.code == Constant.LOGIN_ERROR || resultObject.code == Constant.APP_VERSION_ERROR) {
			msg.what = resultObject.code;
		}
		msg.sendToTarget();
	}

	private ArrayList<RecordTemplate> handleJsonObjectResult(JSONObject contentJsonObject) {
		ArrayList<RecordTemplate> recordTemplateList = new ArrayList<RecordTemplate>();
		JSONArray recordTemplateArray = null;
		try {
			recordTemplateArray = contentJsonObject.getJSONArray("PaperList");
		} catch (JSONException e1) {
			return recordTemplateList;
		}
		//编辑顾客专业时，存储的草稿
		List<RecordTemplate> recordTemplateTempList=userinfoApplication.getCustomerRecordTemplateTempList();
		if(recordTemplateTempList!=null && recordTemplateTempList.size()>0){
			for(RecordTemplate rt:recordTemplateTempList){
				if(rt.getCustomerID()==userinfoApplication.getSelectedCustomerID()){
					rt.setTemp(true);
					recordTemplateList.add(rt);
				}	
			}
		}
		int recordTemplateListCount =recordTemplateArray.length();
		if (recordTemplateListCount>0) {
			JSONObject recordTemplateJson=null;
			for (int i = 0; i < recordTemplateListCount; i++) {
				try {
					recordTemplateJson=(JSONObject)recordTemplateArray.get(i);
					} 
				catch (JSONException e1) {
				}
				int     recordTemplateID=0;
				String  recordTemplateTitle="";
				String  recordTemplateUpdateTime="";
				String  recordTemplateCustomerName="";
				String  recordTemplateResponsibleName="";
				boolean recordTemplateIsVisible=false;
				boolean recordTemplateIsEditable=false;
				int     groupID=0;
				try {
					if (recordTemplateJson.has("PaperID")) {
						recordTemplateID= recordTemplateJson.getInt("PaperID");
					}
					if (recordTemplateJson.has("GroupID")) {
						groupID= recordTemplateJson.getInt("GroupID");
					}
					if (recordTemplateJson.has("Title")) {
						recordTemplateTitle = recordTemplateJson.getString("Title");
					}
					if (recordTemplateJson.has("IsVisible")) {
						recordTemplateIsVisible =recordTemplateJson.getBoolean("IsVisible");
					}
					if (recordTemplateJson.has("CanEditAnswer")) {
						recordTemplateIsEditable = recordTemplateJson.getBoolean("CanEditAnswer");
					}
					if (recordTemplateJson.has("ResponsiblePersonName")) {
						recordTemplateResponsibleName = recordTemplateJson.getString("ResponsiblePersonName");
					}
					if (recordTemplateJson.has("CustomerName")) {
						recordTemplateCustomerName = recordTemplateJson.getString("CustomerName");
					}
					if (recordTemplateJson.has("UpdateTime")) {
						recordTemplateUpdateTime = recordTemplateJson.getString("UpdateTime");
					}
				} catch (JSONException e) {
					
				}
				RecordTemplate  rt = new RecordTemplate();
				rt.setRecordTemplateID(recordTemplateID);
				rt.setRecordTemplateTitle(recordTemplateTitle);
				rt.setRecordTemplateResponsibleName(recordTemplateResponsibleName);
				rt.setRecordTemplateCustomerName(recordTemplateCustomerName);
				rt.setRecordTemplateIsVisible(recordTemplateIsVisible);
				rt.setRecordTemplateIsEditable(recordTemplateIsEditable);
				rt.setRecordTemplateUpdateTime(recordTemplateUpdateTime);
				rt.setTemp(false);
				rt.setGroupID(groupID);
				recordTemplateList.add(rt);
			}
		}
		return recordTemplateList;
	}

	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}

}
