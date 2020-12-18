package com.GlamourPromise.Beauty.manager;
import android.os.Handler;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OpportunityListBaseConditionInfo;
import com.GlamourPromise.Beauty.implementation.GetOpportunityListTaskImpl;
public class OpportunityManager {
	private GetOpportunityListTaskImpl       opportunityTask;
	private GetBackendServerDataByJsonThread opportunityListThread;
	/**
	 * 
	 * @param handler
	 * @param opportunityListBaseCondition
	 */
	public void getOpportunityList(Handler handler,OpportunityListBaseConditionInfo opportunityListBaseCondition,UserInfoApplication userInfoApplication){
		opportunityTask = new GetOpportunityListTaskImpl(handler,opportunityListBaseCondition,userInfoApplication);
		opportunityListThread = new GetBackendServerDataByJsonThread(opportunityTask);
		opportunityListThread.start();
	}
}
