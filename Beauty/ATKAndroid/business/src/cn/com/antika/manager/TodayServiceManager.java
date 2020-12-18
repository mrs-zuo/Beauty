package cn.com.antika.manager;

import android.os.Handler;

import cn.com.antika.Thread.GetBackendServerDataByJsonThread;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderListBaseConditionInfo;
import cn.com.antika.implementation.GetTodayServiceListTaskImpl;

public class TodayServiceManager {
	private GetTodayServiceListTaskImpl getTodayServiceTask;
	private GetBackendServerDataByJsonThread todayServiceListThread;
	public void getTodayServiceList(Handler handler, OrderListBaseConditionInfo otodayServiceSelectCondition, UserInfoApplication userInfoApplication){
		getTodayServiceTask = new GetTodayServiceListTaskImpl(handler,otodayServiceSelectCondition,userInfoApplication);
		todayServiceListThread = new GetBackendServerDataByJsonThread(getTodayServiceTask);
		todayServiceListThread.start();
	}
}
