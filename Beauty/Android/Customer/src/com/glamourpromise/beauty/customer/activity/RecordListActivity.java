package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.ExpandableListView;
import android.widget.PopupWindow;
import android.widget.ExpandableListView.OnGroupCollapseListener;
import android.widget.ExpandableListView.OnGroupExpandListener;
import android.widget.PopupWindow.OnDismissListener;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CustomerVocationListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CustomerVocation;
import com.glamourpromise.beauty.customer.bean.CustomerVocationEditAnswer;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.CreateLayoutInTableLayout;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.IntentUtil;

public class RecordListActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Paper";
	private static final String GET_RECORD_LIST ="GetPaperDetail";
	private String   paperName;
	private int      paperID,groupID;
	private ArrayList<CustomerVocation> mCustomerVocationList;
	private ArrayList<ArrayList<CustomerVocationEditAnswer>> mCustomerVocationEditAnswerList;
	private ExpandableListView recordListView;
	private boolean            			 isCustomerVocationExpandAll;
	private CustomerVocationListAdapter  customerVocationListAdapter;
	private PopupWindow 				 recordFilterPopupWindow;
	private View 			recordFilterView;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.hiddenHead();
		super.baseSetContentView(R.layout.activity_record_list);
		new CreateLayoutInTableLayout();
		if (savedInstanceState == null) {
			initView();
		}
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
	}
	protected void initView() {
		Intent intent=getIntent();
		paperID=intent.getIntExtra("paperID",0);
		groupID=intent.getIntExtra("groupID",0);
		paperName=intent.getStringExtra("paperName");
		recordListView=(ExpandableListView)findViewById(R.id.record_list_view);
		recordListView.setGroupIndicator(null);
		mCustomerVocationList=new ArrayList<CustomerVocation>();
		mCustomerVocationEditAnswerList=new ArrayList<ArrayList<CustomerVocationEditAnswer>>();
		((TextView)findViewById(R.id.record_list_title_text)).setText(paperName);
		findViewById(R.id.record_filter).setOnClickListener(this);
		findViewById(R.id.record_main_back).setOnClickListener(this);
		isCustomerVocationExpandAll=false;
		//监听大的Group展开
		recordListView.setOnGroupExpandListener(new OnGroupExpandListener() {
					
					@Override
					public void onGroupExpand(int groupPosition) {
						// TODO Auto-generated method stub
						boolean isExpandAll=true;
						for(int i=0;i<customerVocationListAdapter.getGroupCount();i++){
							if(!recordListView.isGroupExpanded(i)){
								isExpandAll=false;
								break;
							}
						}
						//如果没有全部展开，则设置当前标识是可以展开的 并且设置全部展开图标是可以展开的图标
						if(!isExpandAll){
							isCustomerVocationExpandAll=false;
							if(recordFilterView!=null)
								((TextView)recordFilterView.findViewById(R.id.record_expand_btn)).setText("全部展开");
						}
						else if(isExpandAll){
							isCustomerVocationExpandAll=true;
							if(recordFilterView!=null)
								((TextView)recordFilterView.findViewById(R.id.record_expand_btn)).setText("全部收缩");
						}
					}
				});
				//监听大的Group收缩
		recordListView.setOnGroupCollapseListener(new OnGroupCollapseListener() {
					
					@Override
					public void onGroupCollapse(int groupPosition) {
						// TODO Auto-generated method stub
						boolean isExpandAll=true;
						for(int i=0;i<customerVocationListAdapter.getGroupCount();i++){
							if(!recordListView.isGroupExpanded(i)){
								isExpandAll=false;
								break;
							}
						}
						//如果没有全部展开，则设置当前标识是可以展开的 并且设置全部展开图标是可以展开的图标
						if(!isExpandAll){
							isCustomerVocationExpandAll=false;
							if(recordFilterView!=null)
								((TextView)recordFilterView.findViewById(R.id.record_expand_btn)).setText("全部展开");
						}
						else if(isExpandAll){
							isCustomerVocationExpandAll=true;
							if(recordFilterView!=null)
								((TextView)recordFilterView.findViewById(R.id.record_expand_btn)).setText("全部收缩");
						}
					}
				});
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	public void onClick(View v) {
		super.onClick(v);
		if(v.getId()==R.id.record_main_back){
			this.finish();
		}
		else if(v.getId()==R.id.record_filter){
			showPopupWindow(findViewById(R.id.record_list_title));
		}
	}
	private void showPopupWindow(View parentView) {
        if(recordFilterPopupWindow!=null && recordFilterPopupWindow.isShowing()){
        	recordFilterPopupWindow.dismiss();
        	recordFilterPopupWindow=null;
        }
        else{
        	//专业全部展开和全部收缩布局
    		LayoutInflater inflater = getLayoutInflater();
    		recordFilterView= inflater.inflate(R.xml.record_filter_dialog, null);
    		recordFilterView.findViewById(R.id.home_page_rl).setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					IntentUtil.assignToDefault(RecordListActivity.this);
				}
			});
    		if(!isCustomerVocationExpandAll){
    			((TextView)recordFilterView.findViewById(R.id.record_expand_btn)).setText("全部展开");
    		}
    		else{
    			((TextView)recordFilterView.findViewById(R.id.record_expand_btn)).setText("全部收缩");
    		}
    		recordFilterView.findViewById(R.id.record_expand_rl).setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					if(!isCustomerVocationExpandAll){
						for(int i=0;i<customerVocationListAdapter.getGroupCount();i++){
							recordListView.expandGroup(i);
						}
					}
					else{
						for(int i=0;i<customerVocationListAdapter.getGroupCount();i++){
							recordListView.collapseGroup(i);
						}
					}
				}
			});
    		//取消
    		recordFilterView.findViewById(R.id.record_expand_cancel_rl).setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					 if(recordFilterPopupWindow!=null && recordFilterPopupWindow.isShowing()){
						 recordFilterPopupWindow.dismiss();
						 recordFilterPopupWindow=null;
				        }
				}
			});
    		recordFilterPopupWindow= new PopupWindow(recordFilterView,LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, true);
    		recordFilterPopupWindow.setBackgroundDrawable(new BitmapDrawable());
    		//窗体的透明值
    		WindowManager.LayoutParams lp = getWindow().getAttributes();  
    		lp.alpha = 0.9f; 
            getWindow().setAttributes(lp);
        	// 设置好参数之后再show
            recordFilterPopupWindow.showAsDropDown(parentView);
            recordFilterPopupWindow.setOnDismissListener(new OnDismissListener() {
				@Override
				public void onDismiss() {
					// TODO Auto-generated method stub
					resetWindow();
				}
			});
        }
    }
	protected void resetWindow(){
		//恢复窗体的透明值
    	WindowManager.LayoutParams lp = getWindow().getAttributes();  
		lp.alpha = 1.0f; 
        getWindow().setAttributes(lp);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject getRecordListParamJson = new JSONObject();
		try {
			getRecordListParamJson.put("PaperID",paperID);
			getRecordListParamJson.put("GroupID",groupID);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,GET_RECORD_LIST,getRecordListParamJson.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_RECORD_LIST,getRecordListParamJson.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				JSONArray paperDetailJsonArray=null;
				try {
					paperDetailJsonArray=new JSONArray(response.getStringData());
				} catch (JSONException e) {
					
				}
				if (paperDetailJsonArray!= null) {
					for (int i = 0; i < paperDetailJsonArray.length();i++) {
						JSONObject   paperDetailJson=null;
						try {
							paperDetailJson=(JSONObject)paperDetailJsonArray.get(i);
							} 
						catch (JSONException e1) {
						}
						int    questionID=0;
						String questionName="";
						int    questionType=0;
						String questionContent="";
						String questionDescription="";
						int    answerID=0;
						String answerContent="";
						try {
							if (paperDetailJson.has("QuestionID")) {
								questionID= paperDetailJson.getInt("QuestionID");
							}
							if (paperDetailJson.has("QuestionName")) {
								questionName= paperDetailJson.getString("QuestionName");
							}
							if (paperDetailJson.has("QuestionType")) {
								questionType = paperDetailJson.getInt("QuestionType");
							}
							if (paperDetailJson.has("QuestionContent")) {
								questionContent =paperDetailJson.getString("QuestionContent");
							}
							if (paperDetailJson.has("QuestionDescription")) {
								questionDescription = paperDetailJson.getString("QuestionDescription");
							}
							if (paperDetailJson.has("AnswerID")) {
								answerID = paperDetailJson.getInt("AnswerID");
							}
							if(paperDetailJson.has("AnswerContent"))
								answerContent=paperDetailJson.getString("AnswerContent");
						} catch (JSONException e) {
							
						}
						CustomerVocation cv=new CustomerVocation();
						cv.setQuestionId(questionID);
						cv.setQuestionType(questionType);
						cv.setQuestionName(questionName);
						cv.setQuestionDescription(questionDescription);
						cv.setAnswerId(answerID);
						String[] answerContentarray=questionContent.split("\\|");
						ArrayList<CustomerVocationEditAnswer> cveaList=new ArrayList<CustomerVocationEditAnswer>();
						if(cv.getQuestionDescription()!=null && !("").equals(cv.getQuestionDescription())){
							CustomerVocationEditAnswer cvea=new CustomerVocationEditAnswer();
							cvea.setIsQuestionDescription(1);
							cvea.setAnswerContent(cv.getQuestionDescription());
							cveaList.add(cvea);
						}
						if(questionType==0){
							CustomerVocationEditAnswer cvea=new CustomerVocationEditAnswer();
							cvea.setAnswerContent(answerContent);
							cvea.setIsAnswer(1);
							cvea.setIsQuestionDescription(0);
							cveaList.add(cvea);
						}
						else{
							if(answerContent!=null && !("").equals(answerContent)){
								String[] isAnswerArray=answerContent.split("\\|");
								for(int j=0;j<answerContentarray.length;j++){
									CustomerVocationEditAnswer cvea=new CustomerVocationEditAnswer();
									cvea.setAnswerContent(answerContentarray[j]);
									try {
										cvea.setIsAnswer(Integer.parseInt(isAnswerArray[j]));
									} catch (NumberFormatException e) {
										cvea.setIsAnswer(0);
									}
									cvea.setIsQuestionDescription(0);
									cveaList.add(cvea);
								}
							}
							else{
								for(int j=0;j<answerContentarray.length;j++){
									CustomerVocationEditAnswer cvea=new CustomerVocationEditAnswer();
									cvea.setAnswerContent(answerContentarray[j]);
									cvea.setIsAnswer(0);
									cvea.setIsQuestionDescription(0);
									cveaList.add(cvea);
								}
							}
							
						}
						mCustomerVocationEditAnswerList.add(cveaList);
						mCustomerVocationList.add(cv);
					}
				}
				customerVocationListAdapter=new CustomerVocationListAdapter(this,mCustomerVocationList,mCustomerVocationEditAnswerList); 
				recordListView.setAdapter(customerVocationListAdapter);
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}    
		}
		
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}
}
