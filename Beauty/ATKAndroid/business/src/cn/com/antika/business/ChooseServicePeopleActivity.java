package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.Window;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import cn.com.antika.Thread.GetBackendServerDataByJsonThread;
import cn.com.antika.adapter.ChoosePersonLeftAdapter;
import cn.com.antika.adapter.LabelListAdapter;
import cn.com.antika.adapter.PersonScheduleItemAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.Customer;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.LabelInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.PersonSchedule;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.implementation.GetTagListTaskImpl;
import cn.com.antika.util.BitmapUtils;
import cn.com.antika.util.ChangeServiceExpirationDateListener;
import cn.com.antika.util.DateButton;
import cn.com.antika.util.DateUtil;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.SyncHorizontalScrollView;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class ChooseServicePeopleActivity extends BaseActivity implements
		OnClickListener, OnQueryTextListener, OnItemClickListener {
	private ChooseServicePeopleActivityHandler mHandler = new ChooseServicePeopleActivityHandler(this);
	private ListView servicePeopleListView;
	private ListView peopleScheduleListView;
	private Thread requestWebServiceThread;
	private ProgressDialog progressDialog;
	private List<Customer> servicePeopleList;
	private EditText personScheduleDateText;
	private LinearLayout _24HourTimeView;
	private LayoutInflater mLayoutInflater;
	private SyncHorizontalScrollView _24HourTimeHorizontalScrollView;
	private SyncHorizontalScrollView personScheduleHorizontalScrollView;
	private PopupWindow popupWindow;
	private Button chooseServicePersonBtn;
	private ChoosePersonLeftAdapter choosePersonLeftAdapter;
	private ImageButton reduceDateByDayBtn;
	private ImageButton plusDateByDayBtn;
	private int screenWidth;
	private ImageView clockIconImage;
	private TextView chooseServicePersonScheduleInfoText;
	private TextView chooseServicePersonNameText;
	private UserInfoApplication userinfoApplication;
	private int chooseServicePersonID;
	private int executorID;
	private String executorName;
	private Calendar calenDar;
	private String defaultScheduleTime;
	private PackageUpdateUtil packageUpdateUtil;
	private String tagIDs;
	private Builder           groupFilterDialog;
	private GetBackendServerDataByJsonThread getDataThread;
	private GetTagListTaskImpl getTagListTask;
	private ArrayList<Integer> lastSelectGroup;
	private ImageButton   groupFilterBtn;
	private OrderInfo addAppointmentOrderInfo;
	private int fromSource=0;
	/**预约*/
	private static final int APPOINTMENT=1;
	private ImageButton chooseServicePeopleHeadBtn;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_choose_service_people);
		DisplayMetrics dm = getResources().getDisplayMetrics();
		screenWidth = dm.widthPixels - 140;
		defaultScheduleTime = getIntent().getStringExtra("ScheduleTime");
		if (defaultScheduleTime == null || defaultScheduleTime.equals("")) {
			calenDar = Calendar.getInstance();
		} else {
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd hh:mm");
			Date date = null;
			try {
				date = sdf.parse(defaultScheduleTime);
			} catch (ParseException e) {
				date = new Date();
			}
			calenDar = Calendar.getInstance();
			calenDar.setTime(date);
		}
		int year = calenDar.get(Calendar.YEAR);// 得到年
		int month = calenDar.get(Calendar.MONTH) + 1;// 得到月，因为从0开始的，所以要加1
		int day = calenDar.get(Calendar.DAY_OF_MONTH);// 得到天
		String nowDate = year + "/" + month + "/" + day;
		initView(nowDate);
	}

	private static class ChooseServicePeopleActivityHandler extends Handler {
		private final ChooseServicePeopleActivity chooseServicePeopleActivity;

		private ChooseServicePeopleActivityHandler(ChooseServicePeopleActivity activity) {
			WeakReference<ChooseServicePeopleActivity> weakReference = new WeakReference<ChooseServicePeopleActivity>(activity);
			chooseServicePeopleActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (chooseServicePeopleActivity.progressDialog != null) {
				chooseServicePeopleActivity.progressDialog.dismiss();
				chooseServicePeopleActivity.progressDialog = null;
			}
			if (message.what == 0) {
				DialogUtil.createShortDialog(chooseServicePeopleActivity, (String) message.obj);
			} else if (message.what == 1) {
				chooseServicePeopleActivity.choosePersonLeftAdapter = new ChoosePersonLeftAdapter(chooseServicePeopleActivity, chooseServicePeopleActivity.servicePeopleList);
				chooseServicePeopleActivity.servicePeopleListView.setAdapter(chooseServicePeopleActivity.choosePersonLeftAdapter);
				chooseServicePeopleActivity.peopleScheduleListView.setAdapter(new PersonScheduleItemAdapter(chooseServicePeopleActivity, chooseServicePeopleActivity.servicePeopleList));
				Bitmap bitMap = ((BitmapDrawable) chooseServicePeopleActivity.getResources().getDrawable(R.drawable.clock_icon)).getBitmap();
				if (chooseServicePeopleActivity.servicePeopleList.size() != 0) {
					chooseServicePeopleActivity.clockIconImage = (ImageView) chooseServicePeopleActivity.findViewById(R.id.clock_icon_image);
					int screenWidth = chooseServicePeopleActivity.userinfoApplication.getScreenWidth();
					if (screenWidth == 480)
						bitMap = BitmapUtils.personScheduleClockIcon(bitMap, 800);
					else if (screenWidth == 540)
						bitMap = BitmapUtils.personScheduleClockIcon(bitMap, 1000);
					else if (screenWidth == 720)
						bitMap = BitmapUtils.personScheduleClockIcon(bitMap, 1750);
					else if (screenWidth == 1080)
						bitMap = BitmapUtils.personScheduleClockIcon(bitMap, 3500);
					else if (screenWidth == 1536)
						bitMap = BitmapUtils.personScheduleClockIcon(bitMap, 2950);
					else
						bitMap = BitmapUtils.personScheduleClockIcon(bitMap, 1850);
					BitmapDrawable bd = new BitmapDrawable(bitMap);
					chooseServicePeopleActivity.clockIconImage.setBackgroundDrawable(bd);
					chooseServicePeopleActivity.clockIconImage.setOnTouchListener(chooseServicePeopleActivity.movingEventListener);
					int defaultCheckServicePeoplePos = -1;
					for (int i = 0; i < chooseServicePeopleActivity.servicePeopleList.size(); i++) {
						if (chooseServicePeopleActivity.servicePeopleList.get(i).getCustomerId() == chooseServicePeopleActivity.executorID)
							defaultCheckServicePeoplePos = i;
					}
					if (defaultCheckServicePeoplePos != -1)
						chooseServicePeopleActivity.choosePersonLeftAdapter.setSelectedPosition(defaultCheckServicePeoplePos);
					chooseServicePeopleActivity.chooseServicePersonNameText.setText(chooseServicePeopleActivity.executorName);
				}
				int nowHour = chooseServicePeopleActivity.calenDar.get(Calendar.HOUR_OF_DAY);
				int nowMinutes = chooseServicePeopleActivity.calenDar.get(Calendar.MINUTE);
				final int intiScrollX = nowHour * 60 + nowMinutes;
				chooseServicePeopleActivity.mHandler.post((new Runnable() {
					@Override
					public void run() {
						chooseServicePeopleActivity._24HourTimeHorizontalScrollView
								.scrollTo(intiScrollX, 0);
					}
				}));
			} else if (message.what == 2) {
				List<Customer> searchResultList = (List<Customer>) message.obj;
				chooseServicePeopleActivity.choosePersonLeftAdapter = new ChoosePersonLeftAdapter(chooseServicePeopleActivity, searchResultList);
				chooseServicePeopleActivity.servicePeopleListView.setAdapter(chooseServicePeopleActivity.choosePersonLeftAdapter);
				chooseServicePeopleActivity.peopleScheduleListView.setAdapter(new PersonScheduleItemAdapter(chooseServicePeopleActivity, chooseServicePeopleActivity.servicePeopleList));
				int defaultCheckServicePeoplePos = -1;
				for (int i = 0; i < searchResultList.size(); i++) {
					if (searchResultList.get(i).getCustomerId() == chooseServicePeopleActivity.executorID)
						defaultCheckServicePeoplePos = i;
				}
				if (defaultCheckServicePeoplePos != -1)
					chooseServicePeopleActivity.choosePersonLeftAdapter
							.setSelectedPosition(defaultCheckServicePeoplePos);
				chooseServicePeopleActivity.chooseServicePersonNameText.setText(chooseServicePeopleActivity.executorName);
			} else if (message.what == 3)
				DialogUtil.createShortDialog(chooseServicePeopleActivity, "您的网络貌似不给力，请重试");
			else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(chooseServicePeopleActivity, chooseServicePeopleActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(chooseServicePeopleActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + chooseServicePeopleActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(chooseServicePeopleActivity);
				chooseServicePeopleActivity.packageUpdateUtil = new PackageUpdateUtil(chooseServicePeopleActivity, chooseServicePeopleActivity.mHandler, fileCache, downloadFileUrl, false, chooseServicePeopleActivity.userinfoApplication);
				chooseServicePeopleActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				chooseServicePeopleActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = chooseServicePeopleActivity.getFileStreamPath(filename);
				file.getName();
				chooseServicePeopleActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			}
			//获得分组列表并显示选择分组列表对话框
			else if (message.what == 6) {
				ArrayList<LabelInfo> labelList = (ArrayList<LabelInfo>) message.obj;
				LayoutInflater inflater = chooseServicePeopleActivity.getLayoutInflater();
				View groupFilterDialogLayout = inflater.inflate(R.xml.group_filter_dialog, null);
				ListView groupListView = (ListView) groupFilterDialogLayout.findViewById(R.id.group_listview);
				final LabelListAdapter labellistAdapter = new LabelListAdapter(chooseServicePeopleActivity, labelList, chooseServicePeopleActivity.lastSelectGroup, 10);
				groupListView.setAdapter(labellistAdapter);
				chooseServicePeopleActivity.groupFilterDialog = new AlertDialog.Builder(chooseServicePeopleActivity, R.style.CustomerAlertDialog).setTitle(chooseServicePeopleActivity.getString(R.string.group_filter)).setView(groupListView).setPositiveButton(chooseServicePeopleActivity.getString(R.string.confirm),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface arg0, int arg1) {
								String showDate = chooseServicePeopleActivity.personScheduleDateText.getText().toString();
								HashMap<Integer, LabelInfo> selectLabelInfoHashMap = labellistAdapter.getSelectLabelHashMap();
								StringBuffer selectLabelStr = new StringBuffer();
								chooseServicePeopleActivity.lastSelectGroup = new ArrayList<Integer>();
								for (int i = 0; i < selectLabelInfoHashMap.size(); i++) {
									LabelInfo labelInfo = selectLabelInfoHashMap.get(i);
									selectLabelStr.append("|" + labelInfo.getID() + "|");
									chooseServicePeopleActivity.lastSelectGroup.add(Integer.parseInt(labelInfo.getID()));
								}
								chooseServicePeopleActivity.tagIDs = selectLabelStr.toString();
								chooseServicePeopleActivity.requestWebServiceForData(chooseServicePeopleActivity.parseShowDateForWebService(showDate), chooseServicePeopleActivity.tagIDs);
							}
						})
						.setNegativeButton(chooseServicePeopleActivity.getString(R.string.cancel), new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int which) {
								dialog.dismiss();
							}
						}).setNeutralButton("清除", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int which) {
								if (chooseServicePeopleActivity.lastSelectGroup != null)
									chooseServicePeopleActivity.lastSelectGroup.clear();
							}
						});
				chooseServicePeopleActivity.groupFilterDialog.setCancelable(false);
				chooseServicePeopleActivity.groupFilterDialog.show();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			} else if (message.what == 8) {
				DialogUtil.createShortDialog(chooseServicePeopleActivity, (String) message.obj);
				chooseServicePeopleActivity.finish();
			}
			if (chooseServicePeopleActivity.requestWebServiceThread != null) {
				chooseServicePeopleActivity.requestWebServiceThread.interrupt();
				chooseServicePeopleActivity.requestWebServiceThread = null;
			}
			if (chooseServicePeopleActivity.getDataThread != null) {
				chooseServicePeopleActivity.getDataThread.interrupt();
				chooseServicePeopleActivity.getDataThread = null;
			}
		}
	}

	protected void initView(String date) {
		chooseServicePeopleHeadBtn=(ImageButton) findViewById(R.id.choose_service_people_head_btn);
		chooseServicePeopleHeadBtn.setOnClickListener(this);
//		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
//		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
//		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
//		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		
		userinfoApplication = UserInfoApplication.getInstance();
		reduceDateByDayBtn = (ImageButton) findViewById(R.id.reduce_date_by_day);
		reduceDateByDayBtn.setOnClickListener(this);
		plusDateByDayBtn = (ImageButton) findViewById(R.id.plus_date_by_day);
		plusDateByDayBtn.setOnClickListener(this);
		servicePeopleListView = (ListView) findViewById(R.id.service_people_list_view);
		servicePeopleListView.setOnItemClickListener(this);
		peopleScheduleListView = (ListView) findViewById(R.id.person_schedule_list_view);
		personScheduleDateText = (EditText) findViewById(R.id.person_schedule_date);
		chooseServicePersonScheduleInfoText = (TextView) findViewById(R.id.choose_service_person_schedule_info_text);
		personScheduleDateText.setOnClickListener(this);
		personScheduleDateText.setInputType(InputType.TYPE_NULL);
		mLayoutInflater = LayoutInflater.from(this);
		_24HourTimeView = (LinearLayout) findViewById(R.id.hour_24_time_linearlayout);
		_24HourTimeHorizontalScrollView = (SyncHorizontalScrollView) findViewById(R.id.hour_24_time_view);
		personScheduleHorizontalScrollView = (SyncHorizontalScrollView) findViewById(R.id.person_schedule_view);
		_24HourTimeHorizontalScrollView.setScrollView(personScheduleHorizontalScrollView, this);
		personScheduleHorizontalScrollView.setScrollView(_24HourTimeHorizontalScrollView, this);
		chooseServicePersonNameText = (TextView) findViewById(R.id.choose_service_person_name_info_text);
		for (int i = 0; i < 24; i++) {
			View timeLineView = mLayoutInflater.inflate(R.xml.time_line_24_item, null);
			TextView timeLineText = (TextView) timeLineView.findViewById(R.id.time_line_hour_text);
			timeLineText.setText(String.valueOf(i));
			_24HourTimeView.addView(timeLineView);
		}
		personScheduleDateText.setText(date);
		chooseServicePersonBtn = (Button)findViewById(R.id.choose_service_person_make_sure_btn);
		chooseServicePersonBtn.setOnClickListener(this);
		chooseServicePersonScheduleInfoText.setText(parseShowDateForWebService(personScheduleDateText.getText().toString())
						+ "\t"+ calenDar.get(Calendar.HOUR_OF_DAY)+ ":"+ calenDar.get(Calendar.MINUTE));
		Intent intent = getIntent();
		executorID = intent.getIntExtra("ExecutorID", 0);
		executorName = intent.getStringExtra("ExecutorName");
		groupFilterBtn=(ImageButton) findViewById(R.id.group_filter_btn);
		groupFilterBtn.setOnClickListener(this);
//		if (executorID == 0) {
//			executorID = userinfoApplication.getAccountInfo().getAccountId();
//			executorName = userinfoApplication.getAccountInfo().getAccountName();
//		}
		chooseServicePersonID = executorID;
		tagIDs="";
		fromSource=intent.getIntExtra("FROM_SOURCE",0);
		addAppointmentOrderInfo=(OrderInfo)intent.getSerializableExtra("orderInfo");
		requestWebServiceForData(parseShowDateForWebService(date),tagIDs);
		// 两个Listview同时滚动
		setListViewOnTouchAndScrollListener(servicePeopleListView,peopleScheduleListView);

	}

	private void requestWebServiceForData(String date,final String tagIDs) {
		servicePeopleList = new ArrayList<Customer>();
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		final String dateStr = date;
		String[] oldDateTime = chooseServicePersonScheduleInfoText.getText().toString().split("\t");
		if (oldDateTime.length == 2)
			chooseServicePersonScheduleInfoText.setText(dateStr + "\t"+ oldDateTime[1]);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				String methodName = "getAccountSchedule";
				String endPoint = "account";
				JSONObject accountScheduleParamJson = new JSONObject();
				try {
					accountScheduleParamJson.put("Date", dateStr);
					accountScheduleParamJson.put("TagIDs",tagIDs);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,accountScheduleParamJson.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverRequestResult);
				} catch (JSONException e) {
				}
				if (serverRequestResult == null
						|| serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int    code =0;
					String message = "";
					try {
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code == 1) {
						JSONArray accountScheduleArray = null;
						try {
							accountScheduleArray = resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						for (int i = 0; i < accountScheduleArray.length(); i++) {
							JSONObject accountDetail = null;
							try {
								accountDetail = accountScheduleArray.getJSONObject(i);
							} catch (JSONException e) {
							}
							int accountID = 0;
							String accountName = "";
							String accountCode = "";
							String department = "";
							String pinYin = "";
							String pinYinFirst = "";
							List<PersonSchedule> personScheduleList = null;
							try {
								if (accountDetail.has("AccountID"))
									accountID = accountDetail.getInt("AccountID");
								if (accountDetail.has("AccountName"))
									accountName = accountDetail.getString("AccountName");
								if (accountDetail.has("AccountCode"))
									accountCode = accountDetail.getString("AccountCode");
								if (accountDetail.has("Department"))
									department = accountDetail.getString("Department");
								if (accountDetail.has("PinYin"))
									pinYin = accountDetail.getString("PinYin");
								if (accountDetail.has("PinYinFirst"))
									pinYinFirst = accountDetail.getString("PinYinFirst");
								if (accountDetail.has("ScheduleList") && !accountDetail.isNull("ScheduleList")) {
									JSONArray scheduleArray = accountDetail.getJSONArray("ScheduleList");
									personScheduleList = new ArrayList<PersonSchedule>();
									for (int j = 0; j < scheduleArray.length(); j++) {
										JSONObject scheduleObject = scheduleArray.getJSONObject(j);
										PersonSchedule personSchedule = new PersonSchedule();
										String  scdlStartTime="";
										if(scheduleObject.has("ScdlStartTime"))
											scdlStartTime=scheduleObject.getString("ScdlStartTime");
										String  scdlEndTime ="";
										if(scheduleObject.has("ScdlEndTime"))
											scdlEndTime=scheduleObject.getString("ScdlEndTime");
										personSchedule.setScdlStartTime(scdlStartTime);
										personSchedule.setScdlEndTime(scdlEndTime);
										personScheduleList.add(personSchedule);
									}
								}
							} catch (JSONException e) {
							}
							Customer customer = new Customer();
							customer.setCustomerId(accountID);
							customer.setCustomerName(accountName);
							customer.setAccountCode(accountCode);
							customer.setDepartment(department);
							customer.setPinYin(pinYin);
							customer.setPersonScheduleList(personScheduleList);
							servicePeopleList.add(customer);
						}
						mHandler.sendEmptyMessage(1);
					}
					else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						mHandler.sendEmptyMessage(3);
					}
				}
			}
		};
		requestWebServiceThread.start();
	}
	@Override
	public void onClick(View view) {
		String showDate = personScheduleDateText.getText().toString();
		switch (view.getId()) {
		case R.id.choose_service_people_head_btn:
			this.finish();
			break;
		case R.id.reduce_date_by_day:
			String afterReduceDate = parseShowDate(showDate, -1);
			personScheduleDateText.setText(afterReduceDate);
			requestWebServiceForData(parseShowDateForWebService(afterReduceDate),tagIDs);
			break;
		case R.id.plus_date_by_day:
			String afterPlusDate = parseShowDate(showDate, +1);
			personScheduleDateText.setText(afterPlusDate);
			requestWebServiceForData(parseShowDateForWebService(afterPlusDate),tagIDs);
			break;
		case R.id.person_schedule_date:
			DateButton dateButton = new DateButton(this, (EditText)view,Constant.DATE_DIALOG_SHOW_TYPE_DEFAULT,changeServiceExpirationDateListener);
			dateButton.datePickerDialog();
			break;
		case R.id.choose_service_person_make_sure_btn:
//			if (chooseServicePersonID == 0)
//				DialogUtil.createMakeSureDialog(this, "温馨提示", "请选择服务人员");
//			else 
			if(!DateUtil.compareDateForAppointment(chooseServicePersonScheduleInfoText.getText().toString())){
				DialogUtil.createShortDialog(this,"预约时间早于当前时间");
			}
			else {
				if(fromSource==APPOINTMENT){
					Intent it=getIntent();
					Bundle bun=new Bundle();
					bun.putInt("ExecutorID", chooseServicePersonID);
					bun.putString("ExecutorName",chooseServicePersonNameText.getText().toString());
					bun.putString("TaskScdlStartTime", chooseServicePersonScheduleInfoText.getText().toString());
					it.putExtras(bun);
					setResult(RESULT_OK,it);
					ChooseServicePeopleActivity.this.finish();
				}else{
					//提交预约数据到后台
					addSchedule();
				}
			}
			break;
		case R.id.group_filter_btn:
			getGroupData();
			break;
		}
	}
	private void addSchedule(){
		final String chooseServicePersonSchedule = chooseServicePersonScheduleInfoText.getText().toString();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "AddSchedule";
				String endPoint = "Task";
				JSONObject appointmentJson = new JSONObject();
		    	try {
		    		appointmentJson.put("ExecutorID",chooseServicePersonID);
		    		appointmentJson.put("TaskType", 1);
			        appointmentJson.put("Remark", "");
			    	appointmentJson.put("TaskScdlStartTime",chooseServicePersonSchedule);
			    	appointmentJson.put("TaskOwnerID",addAppointmentOrderInfo.getCustomerID());
			    	appointmentJson.put("ReservedOrderID",addAppointmentOrderInfo.getOrderID());
				    appointmentJson.put("ReservedOrderServiceID",addAppointmentOrderInfo.getOrderObejctID());
				    appointmentJson.put("ReservedOrderType",1);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName, appointmentJson.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverResultResult);
				} catch (JSONException e) {
				}
				
				if (serverResultResult == null || serverResultResult.equals(""))
					mHandler.sendEmptyMessage(3);
				else {
					int    code=0;
					String message = "";
					try {
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					Message msg=new Message();
					if (code== 1) {
						msg.obj = message;
						msg.what = 8;
						mHandler.sendMessage(msg);
					}
					else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
						mHandler.sendEmptyMessage(code);
					else {
						msg.what = 0;
						msg.obj = message;
						mHandler.sendMessage(msg);
					}
				}
			}
		};
		 requestWebServiceThread.start();
	}
	//获得分组列表
	private void getGroupData(){
		if(getDataThread == null){
				getDataThread = new GetBackendServerDataByJsonThread(getBackendServerDataTask());
				getDataThread.start();
			}
	}
	private GetTagListTaskImpl getBackendServerDataTask(){
			if(getTagListTask == null){
				getTagListTask = new GetTagListTaskImpl(mHandler,userinfoApplication,2);
			}
			return getTagListTask;
		}
	private String parseShowDate(String showDate, int flag) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");
		Date newDate = null;
		try {
			newDate = sdf.parse(showDate);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(newDate);
		calendar.add(Calendar.DAY_OF_MONTH, flag);
		String newshowDateTime = sdf.format(calendar.getTime());
		return newshowDateTime;
	}
	
	private String parseShowDateForWebService(String showDate) {
		SimpleDateFormat oldSdf = new SimpleDateFormat("yyyy/MM/dd");
		SimpleDateFormat newSdf = new SimpleDateFormat("yyyy-MM-dd");
		Date newDate = null;
		try {
			newDate = oldSdf.parse(showDate);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(newDate);
		String newshowDateTime = newSdf.format(calendar.getTime());
		return newshowDateTime;
	}
	private String parseShowDateForWebService2(String showDate) {
		SimpleDateFormat oldSdf = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat newSdf = new SimpleDateFormat("yyyy/MM/dd");
		Date newDate = null;
		try {
			newDate = oldSdf.parse(showDate);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(newDate);
		String newshowDateTime = newSdf.format(calendar.getTime());
		return newshowDateTime;
	}

	private void searchServicePerson(String name) {
		List<Customer> searchResultList = new ArrayList<Customer>();
		for (Customer customer : servicePeopleList) {
			if (customer.getPinYin().contains(name)) {
				searchResultList.add(customer);
			}
		}
		Message message = new Message();
		message.obj = searchResultList;
		message.what = 2;
		mHandler.sendMessage(message);
	}

	@Override
	public boolean onQueryTextChange(String newText) {
		// TODO Auto-generated method stub
		searchServicePerson(newText);
		return false;
	}

	@Override
	public boolean onQueryTextSubmit(String newText) {
		// TODO Auto-generated method stub
		return false;
	}
	// 更改服务有效期Listener
	private ChangeServiceExpirationDateListener changeServiceExpirationDateListener = new ChangeServiceExpirationDateListener() {
			@Override
			public void changeServiceExpirationDate(String newExpirationDate) {
				newExpirationDate=parseShowDateForWebService2(newExpirationDate);
				personScheduleDateText.setText(newExpirationDate);
				personScheduleDateText.setText(newExpirationDate);
				requestWebServiceForData(parseShowDateForWebService(newExpirationDate),tagIDs);
			}
		};
	/*
	 * 时间刻度尺的拖拽左右移动
	 */
	public static int clockIconLeft;
	private OnTouchListener movingEventListener = new OnTouchListener() {
		int lastX, lastY;
		int dx, dy;

		@Override
		public boolean onTouch(View v, MotionEvent event) {
			switch (event.getAction()) {
			case MotionEvent.ACTION_DOWN:
				lastX = (int) event.getRawX();
				lastY = (int) event.getRawY();
				break;
			case MotionEvent.ACTION_MOVE:
				dx = (int) event.getRawX() - lastX;
				dy = (int) event.getRawY() - lastY;

				clockIconLeft = v.getLeft() + dx;
				int top = v.getTop() + dy;
				int right = v.getRight() + dx;
				int bottom = v.getBottom() + dy;
				// 设置不能出界
				if (clockIconLeft < 0) {
					clockIconLeft = 0;
					right = clockIconLeft + v.getWidth();
				}

				if (right > screenWidth) {
					right = screenWidth;
					clockIconLeft = right - v.getWidth();
				}

				if (top < 0) {
					top = 0;
					bottom = top + v.getHeight();
				}

				if (bottom > v.getHeight()) {
					bottom = v.getHeight();
					top = bottom - v.getHeight();
				}
				v.layout(clockIconLeft, top, right, bottom);
				lastX = (int) event.getRawX();
				lastY = (int) event.getRawY();
				int _24HourTimeScrollViewX = _24HourTimeHorizontalScrollView.getScrollX();
				int totalLeft = clockIconLeft;
				totalLeft = totalLeft + _24HourTimeScrollViewX;
				int hour = totalLeft / 60;
				int minutes = totalLeft % 60;
				String hourStr = "";
				String minutesStr = "";
				if (hour < 10)
					hourStr = "0" + hour;
				else
					hourStr = String.valueOf(hour);
				if (minutes < 10)
					minutesStr = "0" + minutes;
				else
					minutesStr = String.valueOf(minutes);
				String nowTime = hourStr + ":" + minutesStr;
				chooseServicePersonScheduleInfoText.setText(parseShowDateForWebService(personScheduleDateText.getText().toString()) + "\t" + nowTime);
				break;
			}
			return true;
		}
	};

	public void setListViewOnTouchAndScrollListener(final ListView listView1,
			final ListView listView2) {

		listView2.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {

				if (scrollState == 0 || scrollState == 1) {

					View subView = view.getChildAt(0);

					if (subView != null) {

						final int top = subView.getTop();

						final int top1 = listView1.getChildAt(0).getTop();

						final int position = view.getFirstVisiblePosition();

						if (top != top1) {

							listView1.setSelectionFromTop(position, top);

						}

					}

				}

			}

			public void onScroll(AbsListView view, final int firstVisibleItem,

			int visibleItemCount, int totalItemCount) {

				View subView = view.getChildAt(0);

				if (subView != null) {

					final int top = subView.getTop();

					int top1 = listView1.getChildAt(0).getTop();

					if (!(top1 - 7 < top && top < top1 + 7)) {

						listView1.setSelectionFromTop(firstVisibleItem, top);
						listView2.setSelectionFromTop(firstVisibleItem, top);

					}

				}

			}

		});

		listView1.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {

				if (scrollState == 0 || scrollState == 1) {

					View subView = view.getChildAt(0);

					if (subView != null) {

						final int top = subView.getTop();

						final int top1 = listView2.getChildAt(0).getTop();

						final int position = view.getFirstVisiblePosition();

						if (top != top1) {

							listView1.setSelectionFromTop(position, top);

							listView2.setSelectionFromTop(position, top);

						}

					}

				}

			}

			@Override
			public void onScroll(AbsListView view, final int firstVisibleItem,

			int visibleItemCount, int totalItemCount) {

				View subView = view.getChildAt(0);

				if (subView != null) {

					final int top = subView.getTop();

					listView1.setSelectionFromTop(firstVisibleItem, top);

					listView2.setSelectionFromTop(firstVisibleItem, top);
				}

			}

		});

	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		if(chooseServicePersonID==servicePeopleList.get(position).getCustomerId()){
			chooseServicePersonNameText.setText("");
			chooseServicePersonID=0;
			choosePersonLeftAdapter.setSelectedPosition(-1);
			choosePersonLeftAdapter.notifyDataSetInvalidated();
		}else{
			chooseServicePersonNameText.setText(servicePeopleList.get(position).getCustomerName());
			chooseServicePersonID = servicePeopleList.get(position).getCustomerId();
			choosePersonLeftAdapter.setSelectedPosition(position);
			choosePersonLeftAdapter.notifyDataSetInvalidated();
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			clockIconLeft = 0;
			this.finish();
		}
		return super.onKeyDown(keyCode, event);
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

}
