package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnGroupClickListener;
import android.widget.ExpandableListView.OnGroupCollapseListener;
import android.widget.ExpandableListView.OnGroupExpandListener;
import android.widget.ImageView;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;

import cn.com.antika.Thread.GetBackendServerDataByJsonThread;
import cn.com.antika.adapter.CustomerVocationListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CustomerVocation;
import cn.com.antika.bean.CustomerVocationEditAnswer;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.RecordTemplate;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

public class CustomerRecordActivity extends BaseActivity implements OnClickListener{
	private CustomerRecordActivityHandler mHandler = new CustomerRecordActivityHandler(this);
	private ExpandableListView          mLvRecord;
	private Thread        		        requestWebServiceThread;
	private ArrayList<CustomerVocation> mCustomerVocationList;
	private ArrayList<ArrayList<CustomerVocationEditAnswer>> mCustomerVocationEditAnswerList;
	private CustomerVocationListAdapter mAdpterRecordItem;
	private ProgressDialog progressDialog;
	private UserInfoApplication userinfoApplication;
	private GetBackendServerDataByJsonThread mTheadDownRecordList;
	private PackageUpdateUtil packageUpdateUtil;
	private ImageView         customerVocationEditStatusIcon,customerVocationExpandStatusIcon;
	private boolean           isCustomerVocationEditable,isPaperEditable,isCustomerVocationExpandAll;//题目是否处于编辑状态和该模板是否是可编辑状态
	private RecordTemplate recordTemplate;
	private TextView          recordTitleText;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_customer_record);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class CustomerRecordActivityHandler extends Handler {
		private final CustomerRecordActivity customerRecordActivity;

		private CustomerRecordActivityHandler(CustomerRecordActivity activity) {
			WeakReference<CustomerRecordActivity> weakReference = new WeakReference<CustomerRecordActivity>(activity);
			customerRecordActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (customerRecordActivity.progressDialog != null) {
				customerRecordActivity.progressDialog.dismiss();
				customerRecordActivity.progressDialog = null;
			}
			if (customerRecordActivity.requestWebServiceThread != null) {
				customerRecordActivity.requestWebServiceThread.interrupt();
				customerRecordActivity.requestWebServiceThread = null;
			}
			if (customerRecordActivity.mTheadDownRecordList != null) {
				customerRecordActivity.mTheadDownRecordList.interrupt();
				customerRecordActivity.mTheadDownRecordList = null;
			}
			int resultCode = msg.what;
			if (resultCode == 2)
				DialogUtil.createShortDialog(customerRecordActivity, "您的网络貌似不给力，请重试");
			else if (resultCode == Constant.GET_WEB_DATA_TRUE) {
				customerRecordActivity.mAdpterRecordItem = new CustomerVocationListAdapter(customerRecordActivity, customerRecordActivity.mCustomerVocationList, customerRecordActivity.mCustomerVocationEditAnswerList);
				customerRecordActivity.mLvRecord.setAdapter(customerRecordActivity.mAdpterRecordItem);
			} else if (resultCode == Constant.GET_WEB_DATA_FALSE || resultCode == Constant.GET_WEB_DATA_EXCEPTION) {
				String message = (String) msg.obj;
				DialogUtil.createShortDialog(customerRecordActivity, message);
			} else if (resultCode == Constant.GET_DATA_NULL || resultCode == Constant.PARSING_ERROR) {
				DialogUtil.createShortDialog(customerRecordActivity, "您的网络貌似不给力，请重试！");
			} else if (resultCode == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(customerRecordActivity, customerRecordActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(customerRecordActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + customerRecordActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(customerRecordActivity);
				customerRecordActivity.packageUpdateUtil = new PackageUpdateUtil(customerRecordActivity, customerRecordActivity.mHandler, fileCache, downloadFileUrl, false, customerRecordActivity.userinfoApplication);
				customerRecordActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				customerRecordActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = customerRecordActivity.getFileStreamPath(filename);
				file.getName();
				customerRecordActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
		}
	}
	
	/**
	 * 初始化
	 */
	private void initView() {
		//初始化问题处于不可编辑状态
		isCustomerVocationEditable=false;
		isCustomerVocationExpandAll=false;
		customerVocationEditStatusIcon=(ImageView) findViewById(R.id.customer_vocation_edit_status_icon);
		customerVocationEditStatusIcon.setBackgroundResource(R.drawable.customer_vocation_edit_status_icon);
		customerVocationExpandStatusIcon=(ImageView) findViewById(R.id.customer_vocation_expand_status_icon);
		customerVocationExpandStatusIcon.setBackgroundResource(R.drawable.expand_all_icon);
		customerVocationExpandStatusIcon.setOnClickListener(this);
		recordTitleText=(TextView) findViewById(R.id.customer_record_title_text);
		mLvRecord = (ExpandableListView)findViewById(R.id.record_list_view);
		mLvRecord.setGroupIndicator(null);
		mLvRecord.setOnChildClickListener(null);
		//监听大的Group展开
		mLvRecord.setOnGroupExpandListener(new OnGroupExpandListener() {
			
			@Override
			public void onGroupExpand(int groupPosition) {
				// TODO Auto-generated method stub
				boolean isExpandAll=true;
				for(int i=0;i<mAdpterRecordItem.getGroupCount();i++){
					if(!mLvRecord.isGroupExpanded(i)){
						isExpandAll=false;
						break;
					}
				}
				//如果没有全部展开，则设置当前标识是可以展开的 并且设置全部展开图标是可以展开的图标
				if(!isExpandAll){
					isCustomerVocationExpandAll=false;
					customerVocationExpandStatusIcon.setBackgroundResource(R.drawable.expand_all_icon);
				}
				else if(isExpandAll){
					isCustomerVocationExpandAll=true;
					customerVocationExpandStatusIcon.setBackgroundResource(R.drawable.call_back_all_icon);
				}
			}
		});
		//监听大的Group收缩
		mLvRecord.setOnGroupCollapseListener(new OnGroupCollapseListener() {
			
			@Override
			public void onGroupCollapse(int groupPosition) {
				// TODO Auto-generated method stub
				boolean isExpandAll=true;
				for(int i=0;i<mAdpterRecordItem.getGroupCount();i++){
					if(!mLvRecord.isGroupExpanded(i)){
						isExpandAll=false;
						break;
					}
				}
				//如果没有全部展开，则设置当前标识是可以展开的 并且设置全部展开图标是可以展开的图标
				if(!isExpandAll){
					isCustomerVocationExpandAll=false;
					customerVocationExpandStatusIcon.setBackgroundResource(R.drawable.expand_all_icon);
				}
				else if(isExpandAll){
					isCustomerVocationExpandAll=true;
					customerVocationExpandStatusIcon.setBackgroundResource(R.drawable.call_back_all_icon);
				}
			}
		});
		mLvRecord.setOnGroupClickListener(new OnGroupClickListener() {
			
			@Override
			public boolean onGroupClick(ExpandableListView parent, View v,int groupPosition, long id) {
				// TODO Auto-generated method stub
				if(!isCustomerVocationEditable)
					return false;
				else{
					Intent destIntent=new Intent(CustomerRecordActivity.this,EditCustomerVocationActivity.class);
					Bundle bundle=new Bundle();
					bundle.putSerializable("question",mCustomerVocationList.get(groupPosition));
					ArrayList<CustomerVocationEditAnswer> cveList=mCustomerVocationEditAnswerList.get(groupPosition);
					Iterator<CustomerVocationEditAnswer> it=cveList.iterator();
					while(it.hasNext()){
						if(it.next().getIsQuestionDescription()==1)
							it.remove();
					}
					bundle.putSerializable("answer",cveList);
					bundle.putSerializable("recordTemplate",recordTemplate);
					destIntent.putExtras(bundle);
					//destIntent.putExtra("paperName",recordTemplate.getRecordTemplateTitle());
					//destIntent.putExtra("groupID",recordTemplate.getGroupID());
					//destIntent.putExtra("paperID",recordTemplate.getRecordTemplateID());
					startActivity(destIntent);
					return true;
				}	
			}
		});
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this,bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		mCustomerVocationList = new ArrayList<CustomerVocation>();
		mCustomerVocationEditAnswerList=new ArrayList<ArrayList<CustomerVocationEditAnswer>>();
		Intent intent=getIntent();
		recordTemplate=(RecordTemplate)intent.getSerializableExtra("recordTemplate");
		isPaperEditable=recordTemplate.isRecordTemplateIsEditable();
		recordTitleText.setText(recordTemplate.getRecordTemplateTitle());
		//模板是可以编辑的并且有编辑顾客咨询记录的权限，则可以编辑
		if(isPaperEditable){
			customerVocationEditStatusIcon.setOnClickListener(this);
		}
		else{
			customerVocationEditStatusIcon.setVisibility(View.GONE);
			customerVocationEditStatusIcon.setOnClickListener(null);
		}
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName ="GetPaperDetail";
				String endPoint = "Paper";
				JSONObject getPaperJson = new JSONObject();
				try {
					getPaperJson.put("PaperID",recordTemplate.getRecordTemplateID());
					getPaperJson.put("GroupID",recordTemplate.getGroupID());
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,getPaperJson.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson = null;
					try {
						resultJson = new JSONObject(serverRequestResult);
					} catch (JSONException e2) {
					}
					int    code =    0;
					try {
						code = resultJson.getInt("Code");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1) {
						JSONArray pagerDetailJsonArray= null;
						try {
							pagerDetailJsonArray = resultJson.getJSONArray("Data");
						} catch (JSONException e) {
							e.printStackTrace();
						}
						if (pagerDetailJsonArray!= null) {
							for (int i = 0; i < pagerDetailJsonArray.length();i++) {
								JSONObject   paperDetailJson=null;
								try {
									paperDetailJson=(JSONObject)pagerDetailJsonArray.get(i);
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
						mHandler.sendEmptyMessage(1);
					}
					else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else
						mHandler.sendEmptyMessage(2);
				}
			}
		};
		requestWebServiceThread.start();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
	}
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		if(v.getId()==R.id.customer_vocation_edit_status_icon){
			if(isCustomerVocationEditable){
				customerVocationEditStatusIcon.setBackgroundResource(R.drawable.customer_vocation_edit_status_icon);
				isCustomerVocationEditable=false;
			}
			else{
				customerVocationEditStatusIcon.setBackgroundResource(R.drawable.customer_vocation_is_not_edit_status_icon);
				isCustomerVocationEditable=true;
			}
			mAdpterRecordItem.setCustomerVocationEditStatus(isCustomerVocationEditable);
		}
		else if(v.getId()==R.id.customer_vocation_expand_status_icon){
			if(isCustomerVocationExpandAll){
				customerVocationExpandStatusIcon.setBackgroundResource(R.drawable.expand_all_icon);
				isCustomerVocationExpandAll=false;
				//收回所有
				if(mCustomerVocationList!=null && mCustomerVocationList.size()>0){
					for(int i=0;i<mCustomerVocationList.size();i++){
						mLvRecord.collapseGroup(i);
					}
				}
			}
			else{
				customerVocationExpandStatusIcon.setBackgroundResource(R.drawable.call_back_all_icon);
				isCustomerVocationExpandAll=true;
				//展开所有
				if(mCustomerVocationList!=null && mCustomerVocationList.size()>0){
					for(int i=0;i<mCustomerVocationList.size();i++){
						mLvRecord.expandGroup(i);
					}
				}
			}
		}
	}
}
