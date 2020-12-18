package cn.com.antika.manager;
import android.os.Handler;
import cn.com.antika.Thread.GetBackendServerDataByJsonThread;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.RecordTemplateListBaseConditionInfo;
import cn.com.antika.implementation.GetRecordTemplateListTaskImpl;

public class RecordTemplateManager {
	private GetRecordTemplateListTaskImpl recordTemplateTask;
	private GetBackendServerDataByJsonThread recordTemplateListThread;
	public void getRecordTemplateList(Handler handler, RecordTemplateListBaseConditionInfo recordTemplateListBaseConditionInfo, UserInfoApplication userInfoApplication){
		recordTemplateTask = new GetRecordTemplateListTaskImpl(handler,recordTemplateListBaseConditionInfo,userInfoApplication);
		recordTemplateListThread = new GetBackendServerDataByJsonThread(recordTemplateTask);
		recordTemplateListThread.start();
	}
}
