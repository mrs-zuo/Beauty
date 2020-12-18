package com.GlamourPromise.Beauty.manager;
import android.os.Handler;
import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.RecordTemplateListBaseConditionInfo;
import com.GlamourPromise.Beauty.implementation.GetRecordTemplateListTaskImpl;
public class RecordTemplateManager {
	private GetRecordTemplateListTaskImpl       recordTemplateTask;
	private GetBackendServerDataByJsonThread    recordTemplateListThread;
	public void getRecordTemplateList(Handler handler,RecordTemplateListBaseConditionInfo recordTemplateListBaseConditionInfo,UserInfoApplication userInfoApplication){
		recordTemplateTask = new GetRecordTemplateListTaskImpl(handler,recordTemplateListBaseConditionInfo,userInfoApplication);
		recordTemplateListThread = new GetBackendServerDataByJsonThread(recordTemplateTask);
		recordTemplateListThread.start();
	}
}
