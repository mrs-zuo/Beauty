package com.GlamourPromise.Beauty.manager;

import android.os.Handler;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo;
import com.GlamourPromise.Beauty.implementation.GetTodayServiceListTaskImpl;
public class TodayServiceManager {
	private GetTodayServiceListTaskImpl      getTodayServiceTask;
	private GetBackendServerDataByJsonThread todayServiceListThread;
	public void getTodayServiceList(Handler handler, OrderListBaseConditionInfo otodayServiceSelectCondition,UserInfoApplication userInfoApplication){
		getTodayServiceTask = new GetTodayServiceListTaskImpl(handler,otodayServiceSelectCondition,userInfoApplication);
		todayServiceListThread = new GetBackendServerDataByJsonThread(getTodayServiceTask);
		todayServiceListThread.start();
	}
}
