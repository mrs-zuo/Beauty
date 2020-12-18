package cn.com.antika.implementation;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import cn.com.antika.bean.AdvancedSearchCondition;
import cn.com.antika.bean.NoteInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.com.antika.manager.BaseDownloadDataTask;

/**
 * 
 * @author hongchuan.du
 *
 */

public class DownloadNoteListTask extends BaseDownloadDataTask{
	public static final int START_DATA_FLAG = 1;
	public static final int OLD_DATA_FLAG = 2;
	public static final int NEW_DATA_FLAG = 3;
	private boolean isByCustomer;
	private int mCustomerID;
	private int mAccountID;
	private int mPageIndex;
	private int mNoteID,deleteNoteID;
	private String mTagsID;
	private Handler mHandler;
	private AdvancedSearchCondition mAdvancedCondition;
	private int     taskType;//任务类型  1：获取笔记列表  2：删除笔记
	public DownloadNoteListTask(int accountID, int noteId, int pageIndex, Handler handler,int taskType) {
		super("GetNotepadList","Notepad");
		init(accountID, noteId, pageIndex, handler);
		isByCustomer = false;
		this.taskType=taskType;
	}
	public DownloadNoteListTask(int accountID,int noteId,Handler handler,int taskType) {
		super("deleteNotepad","Notepad");
		init(accountID, noteId,0, handler);
		this.deleteNoteID=noteId;
		this.taskType=taskType;
	}
	public DownloadNoteListTask(Boolean isByCustomer, int customerID,int accountID, int noteId, int pageIndex, Handler handler,int taskType) {
		super("GetNotepadList", "Notepad");
		init(accountID, noteId, pageIndex, handler);
		this.isByCustomer = isByCustomer;
		mCustomerID = customerID;
		this.taskType=taskType;
	}
	
	private void init(int accountID, int noteId, int pageIndex, Handler handler) {
		mAccountID = accountID;
		mNoteID = noteId;
		mHandler = handler;
		mPageIndex = pageIndex;
	}
	@Override
	protected Object getParamObject() {
		// TODO Auto-generated method stub
		JSONObject paramJsonObject = new JSONObject();
		
		try {
			if(taskType==1){
				paramJsonObject.put("AccountID", mAccountID);
				paramJsonObject.put("RecordID", mNoteID);
				paramJsonObject.put("PageIndex",mPageIndex);
				paramJsonObject.put("PageSize",10);
				//左侧只有高级筛选有CustomerID时才传，右侧都有CustomerID侧
				//多加这个判断是因为，当没有高级筛选时，右侧笔记也要添加CustomerID条件
				if(isByCustomer){
					paramJsonObject.put("CustomerID", mCustomerID);
					paramJsonObject.put("IsShowAll",true);
				}
				//高级筛选条件
				if(mAdvancedCondition != null){
					if(mAdvancedCondition.getResponsiblePersonID()!=null && !("").equals(mAdvancedCondition.getResponsiblePersonID()))
						paramJsonObject.put("ResponsiblePersonIDs",new JSONArray(mAdvancedCondition.getResponsiblePersonID()));
					paramJsonObject.put("FilterByTimeFlag", mAdvancedCondition.getFilterByTimeFlag());
					paramJsonObject.put("StartTime", mAdvancedCondition.getStartDate());
					paramJsonObject.put("EndTime", mAdvancedCondition.getEndDate());
					paramJsonObject.put("CustomerID", mAdvancedCondition.getCustomerID());
					mTagsID = mAdvancedCondition.getStrLabelID();
					paramJsonObject.put("TagIDs", mTagsID);
				}
			}
			else if(taskType==2){
				paramJsonObject.put("ID",deleteNoteID);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return paramJsonObject;
	}

	@Override
	protected void handleResult(WebDataObject webData) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = webData.code;
		if(webData.code == Constant.GET_WEB_DATA_TRUE){
			//获取笔记列表成功
			if(taskType==1){
				try {
					JSONObject resultJsonObject = (JSONObject) webData.result;
					msg.arg1 = resultJsonObject.getInt("RecordCount");
					msg.arg2 = resultJsonObject.getInt("PageCount");
					if(resultJsonObject.get("NotepadList").equals(null))
						msg.obj  = new ArrayList<NoteInfo>();
					else
						msg.obj = handleSoapObjectResult(resultJsonObject.getJSONArray("NotepadList"));
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					msg.what = Constant.PARSING_ERROR;
				}
			}
			//删除笔记成功
			else if(taskType==2){
				msg.what=8;
			}
		}else if(webData.code == Constant.GET_WEB_DATA_EXCEPTION || webData.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = webData.result;
		}
		else if(webData.code==Constant.APP_VERSION_ERROR || webData.code==Constant.LOGIN_ERROR){
			msg.what=webData.code;
		}
		msg.sendToTarget();
	}
	
	private ArrayList<NoteInfo> handleSoapObjectResult(JSONArray contentJsonObject){
		ArrayList<NoteInfo> notesList = null;
		if(contentJsonObject.length() >0){
			notesList = new ArrayList<NoteInfo>();
			JSONObject JsonItem;
			NoteInfo noteItem;
			try {
				for (int i = 0; i < contentJsonObject.length(); i++) {
					JsonItem = contentJsonObject.getJSONObject(i);
					noteItem = new NoteInfo();
					noteItem.setNoteID(JsonItem.getInt("ID"));
					noteItem.setContent(JsonItem.getString("Content"));
					noteItem.setCreateTime(JsonItem.getString("CreateTime"));
					noteItem.setCreateName(JsonItem.getString("CreatorName"));
					String customerName="";
					if(JsonItem.has("CustomerName") && !JsonItem.isNull("CustomerName"))
						customerName=JsonItem.getString("CustomerName");
					noteItem.setCustomerName(customerName);
					if(JsonItem.has("TagName")){
						noteItem.setLabel(JsonItem.getString("TagName"));
					}
					if(JsonItem.has("TagIDs")){
						noteItem.setTagIDs(JsonItem.getString("TagIDs"));
					}
					notesList.add(noteItem);
				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return notesList;
		
	}

	public void setAdvancedCondition(AdvancedSearchCondition advancedCondition) {
		mAdvancedCondition = advancedCondition;
	}
}
