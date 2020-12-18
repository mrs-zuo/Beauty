package cn.com.antika.manager;
import android.os.Handler;

import cn.com.antika.Thread.GetBackendServerDataByJsonThread;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OpportunityListBaseConditionInfo;
import cn.com.antika.implementation.GetOpportunityListTaskImpl;

public class OpportunityManager {
	private GetOpportunityListTaskImpl opportunityTask;
	private GetBackendServerDataByJsonThread opportunityListThread;
	/**
	 * 
	 * @param handler
	 * @param opportunityListBaseCondition
	 */
	public void getOpportunityList(Handler handler, OpportunityListBaseConditionInfo opportunityListBaseCondition, UserInfoApplication userInfoApplication){
		opportunityTask = new GetOpportunityListTaskImpl(handler,opportunityListBaseCondition,userInfoApplication);
		opportunityListThread = new GetBackendServerDataByJsonThread(opportunityTask);
		opportunityListThread.start();
	}
}
