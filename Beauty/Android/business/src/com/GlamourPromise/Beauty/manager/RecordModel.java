package com.GlamourPromise.Beauty.manager;

import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AdvancedSearchCondition;
import com.GlamourPromise.Beauty.implementation.DownloadRecordListTask;
import com.GlamourPromise.Beauty.manager.NetUtil.onModelListener;

import java.lang.ref.WeakReference;

public class RecordModel {
	private static AdvancedSearchCondition sAdvancedCondition;
	private NetUtil netUtil;
	private onModelListener mGetListListener;
	private int mCompanyID;
	private int mBranchID;
	private int mAccountID;
	private int mCustomerID;
	private RecordModelHandler mHandler;
	public RecordModel(Context context, onModelListener listener, int companyID, int branchID, int accountID, int customerID){
		netUtil = NetUtil.getNetUtil();
		mGetListListener = listener;
		mCompanyID = companyID;
		mBranchID = branchID;
		mAccountID = accountID;
		mCustomerID = customerID;
		mHandler = new RecordModelHandler(this);
	}

	private   static class RecordModelHandler extends Handler {
		private final RecordModel recordModel;
		private RecordModelHandler(RecordModel activity) {
			WeakReference<RecordModel> weakReference = new WeakReference<RecordModel>(activity);
			recordModel = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {

			if(recordModel.mGetListListener != null){
				recordModel.mGetListListener.handleResult(msg);
			}
		}
	}
	
	public void asyGetRecordList(int recordID, int currentPageIndex, int pageCount, String tagIDs,UserInfoApplication userInfoApplication){
		DownloadRecordListTask downloadTask = new DownloadRecordListTask(mCompanyID, mBranchID, mAccountID, mCustomerID, mHandler,userInfoApplication);
		//每次都需要修改的信息
		downloadTask.setAdvancedCondition(sAdvancedCondition);//设置高级筛选条件
		downloadTask.setPageIndex(currentPageIndex);//当前的页数
		downloadTask.setPageSize(pageCount);//总页数
		downloadTask.setRecordID(recordID);//当前页的列表的第一个记录的ID
		downloadTask.setTagIDs(tagIDs);//标签
		netUtil.submitDownloadTask(downloadTask);
	}

	public static AdvancedSearchCondition getAdvancedCondition() {
		return sAdvancedCondition;
	}

	public static void setAdvancedCondition(
			AdvancedSearchCondition advancedCondition) {
		sAdvancedCondition = advancedCondition;
	}
	public Handler getHandler(){
			return mHandler;
	}
	
}
