package com.GlamourPromise.Beauty.manager;

import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.bean.AdvancedSearchCondition;
import com.GlamourPromise.Beauty.implementation.DownloadNoteListTask;
import com.GlamourPromise.Beauty.manager.NetUtil.onModelListener;

import java.lang.ref.WeakReference;

public class NoteModel{
	private static AdvancedSearchCondition sAdvancedCondition;
	private NetUtil netUtil;
	private onModelListener mGetListListener;
	private NoteModelHandler mHandler;
	private int     taskType=1;
	public NoteModel(onModelListener listener, int companyID, int branchID){
		mGetListListener = listener;
		netUtil = NetUtil.getNetUtil();
		mHandler = new NoteModelHandler(this);
	}

	private static class NoteModelHandler extends Handler {
		private final NoteModel noteModel;

		private NoteModelHandler(NoteModel activity) {
			WeakReference<NoteModel> weakReference = new WeakReference<NoteModel>(activity);
			noteModel = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {

			if (noteModel.mGetListListener != null) {
				noteModel.mGetListListener.handleResult(msg);
			}
		}
	}
	
	public void getNewNoteList(int userID, int noteID, int pageIndex){
		DownloadNoteListTask getNotesListTask = new DownloadNoteListTask(userID, noteID, pageIndex, mHandler,taskType);
		getNotesListTask.setAdvancedCondition(sAdvancedCondition);
		netUtil.submitDownloadTask(getNotesListTask);
	}
	
	public void getNewNoteListByCustomerID(int customerID, int userID, int noteID, int pageIndex){
		DownloadNoteListTask getNotesListTask = new DownloadNoteListTask(true, customerID,userID, noteID, pageIndex, mHandler,taskType);
		getNotesListTask.setAdvancedCondition(sAdvancedCondition);
		netUtil.submitDownloadTask(getNotesListTask);
	}
	public void deleteNote(int userID,int noteID){
		DownloadNoteListTask deleteNoteTask= new DownloadNoteListTask(userID,noteID,mHandler,taskType);
		netUtil.submitDownloadTask(deleteNoteTask);
	}
	public static AdvancedSearchCondition getAdvancedCondition() {
		return sAdvancedCondition;
	}

	public static void setAdvancedCondition(AdvancedSearchCondition advancedCondition) {
		sAdvancedCondition = advancedCondition;
	}
	public void setTaskType(int taskType){
		this.taskType=taskType;
	}
	public Handler getHandler(){
		return mHandler;
	}
}
