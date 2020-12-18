package com.GlamourPromise.Beauty.Business;
import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.ContextMenu;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView.AdapterContextMenuInfo;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;
import com.GlamourPromise.Beauty.adapter.NotesListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.NoteInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.manager.NetUtil.onModelListener;
import com.GlamourPromise.Beauty.manager.NoteModel;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.XListView;
import com.GlamourPromise.Beauty.view.XListView.IXListViewListener;
public class NotepadListActivity extends BaseActivity implements IXListViewListener, onModelListener{
	private static final String BUSSINESS_TITLE = "与我相关的笔记";
	private static final String CUSTOMER_TITLE = "笔记";
	private static final int ADVANCED_CONDITION_REQUEST_CODE = 3;
	private static final int FIRST_PAGE = 1;
	private static final int NEW_PAGE = 2;
	private static final int OLD_PAGE = 3;
	private StringBuilder mStrTitle;
	private Boolean isRefresh;
	private Boolean isByCustomerID;//是根据customerID，还是accountID取数据
	private ImageButton  mBtnAdvancedSearch;
	private TextView mTvTitle;
	private XListView notesListView;
	private ArrayList<NoteInfo> notesList;
	private NotesListAdapter notesListAdapter;
	private UserInfoApplication userInfo;
	private ProgressDialog progressDialog;
	private NoteModel noteModel;
    private int pageCount=0;//全部订单的页数
	private int pageIndex=1;
	private int getOrderListFlag;//1:取最初的数据；2：取最新的数据；3：取老数据
	private PackageUpdateUtil packageUpdateUtil;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_notepad_list);
		isByCustomerID =getIntent().getBooleanExtra("isByCustomerID",false);
		mBtnAdvancedSearch = (ImageButton) findViewById(R.id.advanced_search_btn);
		notesListView = (XListView) findViewById(R.id.notes_listview);
		notesList = new ArrayList<NoteInfo>();
		notesListAdapter = new NotesListAdapter(this, notesList);
		notesListView.setAdapter(notesListAdapter);
		notesListView.setXListViewListener(this);
		notesListView.setPullLoadEnable(true);
		isRefresh = false;
		initActivity();
		getData(FIRST_PAGE);
	}
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		isByCustomerID =intent.getBooleanExtra("isByCustomerID", false);
		initActivity();
		if(isByCustomerID){
			int  authAllCustomerInfoWrite=userInfo.getAccountInfo().getAuthAllCustomerInfoWrite();
			if(authAllCustomerInfoWrite==1 || userInfo.getSelectedCustomerResponsiblePersonID()==userInfo.getAccountInfo().getAccountId()){
				getData(FIRST_PAGE);
			}
			else{
				DialogUtil.createShortDialog(this,"你无权限查看笔记!");
			}
		}
		else{
			getData(FIRST_PAGE);
		}
	}
	//初始化数据
	protected void initActivity(){
		userInfo = (UserInfoApplication) getApplication();
		noteModel = new NoteModel(this,userInfo.getAccountInfo().getCompanyId(), userInfo.getAccountInfo().getBranchId());
		NoteModel.setAdvancedCondition(null);
		mTvTitle = (TextView)findViewById(R.id.notepad_list_title_text);
		LayoutParams lp=new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT);
		if(isByCustomerID){
			initCustomerView();
			lp.setMargins(10, 0,10,130);
			notesListView.setLayoutParams(lp);
			//从顾客资料页进来的笔记可以长按删除
			registerForContextMenu(notesListView);
		}else{
			lp.setMargins(10,0,10,0);
			notesListView.setLayoutParams(lp);
			initBussinessView();
		}
		
	}
	private void initBussinessView() {
		mStrTitle = new StringBuilder(BUSSINESS_TITLE);
		setTitle(mStrTitle.toString());
		((ImageView) findViewById(R.id.add_new_note_icon)).setVisibility(View.GONE);
		mBtnAdvancedSearch.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				startAdvancedFilterActivity(false);
			}
		});
		findViewById(R.id.note_pad_list_head_layout).setVisibility(View.VISIBLE);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
	}
	private void setTitle(String title) {
		mTvTitle.setText(title);
	}
	private void initCustomerView() {
		int  authAllCustomerInfoWrite=userInfo.getAccountInfo().getAuthAllCustomerInfoWrite();
		if(authAllCustomerInfoWrite==1 || userInfo.getSelectedCustomerResponsiblePersonID()==userInfo.getAccountInfo().getAccountId())
			((ImageView) findViewById(R.id.add_new_note_icon)).setVisibility(View.VISIBLE);
		else
			((ImageView) findViewById(R.id.add_new_note_icon)).setVisibility(View.GONE);
		mStrTitle = new StringBuilder(CUSTOMER_TITLE);
		setTitle(mStrTitle.toString());
		((ImageView) findViewById(R.id.add_new_note_icon)).setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(NotepadListActivity.this, AddNoteActivity.class);
				startActivity(intent);
			}
		});
		mBtnAdvancedSearch.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				startAdvancedFilterActivity(true);
			}
		});
		findViewById(R.id.note_pad_list_head_layout).setVisibility(View.GONE);
	}
	
	private void startAdvancedFilterActivity(boolean isByCustomer) {
		Intent destIntent = new Intent(NotepadListActivity.this, OrderAdvancedSearchActivity.class);
		destIntent.putExtra("ConditionFlag", OrderAdvancedSearchActivity.NOTE_CONDITION);
		destIntent.putExtra("AccountID", userInfo.getAccountInfo().getAccountId());
		destIntent.putExtra("IsByCustomer", isByCustomer);
		startActivityForResult(destIntent, ADVANCED_CONDITION_REQUEST_CODE);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode != RESULT_OK){
			return;
		}
		
		if(requestCode == ADVANCED_CONDITION_REQUEST_CODE){
			getData(1);
		}
	}
	private Handler mHandler;
	private void getData(int flag){
		if(isRefresh){
			return;
		}
		// 取老数据时，已经取完数据不在调用后台
		if (flag == 3 && pageIndex > pageCount) {
			DialogUtil.createShortDialog(this,"没有更多数据了!");
			stopLoadMore();
			return;
		}
		isRefresh = true;
		getOrderListFlag = flag;//当前调用数据的类型
		//取最初数据时，显示
		if (flag == 1) {
			showProgressDialog();
		}
		if(getOrderListFlag == 1 || getOrderListFlag == 2){
			initPageIndex();
		}
		int id = getUserID();
		int noteID = getFirstNoteID();
		if(isByCustomerID){
			if(userInfo.getSelectedCustomerID()==0){
				DialogUtil.createMakeSureDialog(this,"温馨提示","您未选中顾客，不能进行操作");
			}else{
				noteModel.setTaskType(1);
				noteModel.getNewNoteListByCustomerID(userInfo.getSelectedCustomerID(), id, noteID, pageIndex);
			}
		}else{
			noteModel.setTaskType(1);
			noteModel.getNewNoteList(id, noteID, pageIndex);
		}
		mHandler=noteModel.getHandler();
	}
	private int getUserID() {
		int id;
		if(isByCustomerID){
			id = userInfo.getSelectedCustomerID();
		}else{
			id = userInfo.getAccountInfo().getAccountId();
		}
		return id;
	}
	
	private int getFirstNoteID() {
		int noteID = 0;
		if(notesList != null && notesList.size() > 0){
			noteID = notesList.get(0).getNoteID();
		}
		return noteID;
	}
	
	/**
	 * 取最新数据和最初数据时，初始化页面索引
	 */
	private void initPageIndex() {
		// TODO Auto-generated method stub
		pageIndex = 1;
	}
	
	/**
	 * 取老数据时，增加页面索引
	 */
	private void addPageIndex(){
		pageIndex++;
	}
	
	private void showProgressDialog(){
		if(progressDialog == null){
			progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
			progressDialog.setMessage(getString(R.string.please_wait));
            progressDialog.setCancelable(false);
		}
		progressDialog.show();
	}
	
	private void dismissProgressDialog(){
		if (progressDialog != null) {
			progressDialog.dismiss();
		}
	}

	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
		if(notesList != null && notesList.size() > 0){
			getData(NEW_PAGE);
		}else if(notesList == null || notesList.size() == 0){
			getData(NEW_PAGE);
		}else{
			stopRefresh();
		}
	}

	@Override
	public void onLoadMore() {
		// TODO Auto-generated method stub
		if(notesList != null && notesList.size() > 0){
			getData(OLD_PAGE);
		}else{
			stopLoadMore();
		}
	}
	@Override
	public void handleResult(Message msg) {
		// TODO Auto-generated method stub
		int resultCode = msg.what;
		dismissProgressDialog();
		isRefresh = false;
		if (resultCode == Constant.GET_WEB_DATA_TRUE) {
			@SuppressWarnings("unchecked")
			ArrayList<NoteInfo> noteList = (ArrayList<NoteInfo>)msg.obj;
			int pageCount = msg.arg2;
			handleDownloadTrue(noteList, pageCount);
		}else if (resultCode == Constant.GET_WEB_DATA_FALSE || resultCode == Constant.GET_WEB_DATA_EXCEPTION) {
			String message = (String) msg.obj;
			handleDownloadError(message);
		}else if(resultCode == Constant.GET_DATA_NULL || resultCode == Constant.PARSING_ERROR){
			handleDownloadError("您的网络貌似不给力，请重试！");
		}
		else if(resultCode==Constant.LOGIN_ERROR){
			DialogUtil.createShortDialog(this,getString(R.string.login_error_message));
			UserInfoApplication.getInstance().exitForLogin(this);
		}
		else if(msg.what==Constant.APP_VERSION_ERROR){
			String downloadFileUrl= Constant.SERVER_URL + getString(R.string.download_apk_address);
			FileCache fileCache=new FileCache(this);
			packageUpdateUtil=new PackageUpdateUtil(this,mHandler,fileCache,downloadFileUrl,false,userInfo);
			packageUpdateUtil.getPackageVersionInfo();
			ServerPackageVersion serverPackageVersion=new ServerPackageVersion();
			serverPackageVersion.setPackageVersion((String)msg.obj);
			packageUpdateUtil.mustUpdate(serverPackageVersion);
		}
		//包进行下载安装升级
		else if (msg.what == 5) {
			((DownloadInfo)msg.obj).getUpdateDialog().cancel();
			String filename = "com.glamourpromise.beauty.business.apk";
			File file = getFileStreamPath(filename);
			file.getName();
			packageUpdateUtil.showInstallDialog();
		} else if (msg.what == -5) {
			((DownloadInfo)msg.obj).getUpdateDialog().cancel();
		}
		else if(msg.what == 7){
			int downLoadFileSize=((DownloadInfo)msg.obj).getDownloadApkSize();
			((DownloadInfo)msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
		}
		else if(msg.what==8){
			noteModel.setTaskType(1);
			getData(FIRST_PAGE);
		}
	}
	/**
	 * 下载数据失败处理
	 * @param message
	 */
	private void handleDownloadError(String message) {
		if (getOrderListFlag == FIRST_PAGE || getOrderListFlag == NEW_PAGE) {
			notesList.clear();
			notesListAdapter.notifyDataSetChanged();
			stopRefresh();
		}else if(getOrderListFlag == OLD_PAGE){
			stopLoadMore();
		}
		
		if(notesList.size() == 0){
			notesListView.hideFooterView();
		}
		DialogUtil.createShortDialog(this,message);
	}
	
	
	private void handleDownloadTrue(ArrayList<NoteInfo> tmpNoteList, int pageCount) {
		// TODO Auto-generated method stub
		this.pageCount = pageCount;
		int recordSize;
		if(tmpNoteList == null){
			recordSize = 0;
		}else{
			recordSize = tmpNoteList.size();
		}
		if (recordSize > 0) {
			addPageIndex();
		}
		
		changeTitle(pageCount);
		if(getOrderListFlag == FIRST_PAGE || getOrderListFlag == NEW_PAGE){
			notesList.clear();
			notesListView.hideFooterView();
			if (recordSize == 0) {
				DialogUtil.createShortDialog(this,"没有更多数据了!");
			} else if (recordSize < 10 && recordSize > 0 && pageIndex >=pageCount){
				notesList.addAll(tmpNoteList);
			} else if (recordSize == 10 && pageIndex <= pageCount) {
				notesList.addAll(tmpNoteList);
				notesListView.showFooterView();
			}else if(recordSize == 10 && pageIndex > pageCount){
				notesList.addAll(tmpNoteList);
			}
			stopRefresh();
		}else if(getOrderListFlag == OLD_PAGE){
			if(recordSize > 0){
				notesList.addAll(notesList.size(), tmpNoteList);
				if((recordSize < 10) || (recordSize == 10 && pageIndex >pageCount)){
					DialogUtil.createShortDialog(this,"没有更多数据了!");
					notesListView.hideFooterView();
				}
			}else if(recordSize == 0){
				DialogUtil.createShortDialog(this,"没有更多数据了!");
				notesListView.hideFooterView();	
			}
			stopLoadMore();
		}
		notesListAdapter.notifyDataSetChanged();
	}
	private void changeTitle(int pageCount) {
		mStrTitle.replace(0,mStrTitle.length(),"");
		if(isByCustomerID){
			mStrTitle.append(CUSTOMER_TITLE);
		}else{
			mStrTitle.append(BUSSINESS_TITLE);
		}
		if(pageCount!=0){
			mStrTitle.append("(第");
			mStrTitle.append(pageIndex-1);
			mStrTitle.append("/");
			mStrTitle.append(pageCount);
			mStrTitle.append("页)");
		}
		setTitle(mStrTitle.toString());
	}
	
	private void stopRefresh() {
		notesListView.stopRefresh();
		notesListView.setRefreshTime(new Date().toLocaleString());
	}
	private void stopLoadMore(){
		notesListView.stopLoadMore();
	}
	@Override
	public void onCreateContextMenu(ContextMenu menu, View v,ContextMenuInfo menuInfo) {
		// TODO Auto-generated method stub
		menu.add(0,1,0,"删除该条笔记");
		super.onCreateContextMenu(menu,v,menuInfo);
	}
	@Override
	public boolean onMenuItemSelected(int featureId,MenuItem item) {
		// TODO Auto-generated method stub
		int selectedPosition = ((AdapterContextMenuInfo)item.getMenuInfo()).position;
		if(item.getItemId()==1){
			noteModel.setTaskType(2);
			noteModel.deleteNote(getUserID(),notesList.get(selectedPosition-1).getNoteID());
		}
		return super.onMenuItemSelected(featureId,item);
	}
}
