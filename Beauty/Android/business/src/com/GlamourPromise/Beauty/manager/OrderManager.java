package com.GlamourPromise.Beauty.manager;

import android.os.Handler;
import android.os.HandlerThread;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo;
import com.GlamourPromise.Beauty.implementation.GetOrderListByCustomerIDTaskImpl;
import com.GlamourPromise.Beauty.implementation.GetOrderListTaskImpl;
import com.GlamourPromise.Beauty.implementation.GetUnpaidOrderListTaskImpl;
public class OrderManager {
	private GetOrderListTaskImpl orderTask;
	private GetBackendServerDataByJsonThread orderListThread;
	private GetOrderListByCustomerIDTaskImpl orderTaskByCustomer;
	private HandlerThread handlerThread = new HandlerThread("");
	
	private GetUnpaidOrderListTaskImpl unPaidTask;
	
	/**
	 * 
	 * @param handler
	 * @param orderSelectCondition
	 */
	public void getOrderList(Handler handler, OrderListBaseConditionInfo orderSelectCondition,UserInfoApplication userInfoApplication){
		orderTask = new GetOrderListTaskImpl(handler, orderSelectCondition,userInfoApplication);
		orderListThread = new GetBackendServerDataByJsonThread(orderTask);
		orderListThread.start();
	}
	public void getOrderByCustomer(Handler handler, String customerName, OrderListBaseConditionInfo orderSelectCondition,UserInfoApplication userInfoApplication){
		orderTaskByCustomer = new GetOrderListByCustomerIDTaskImpl(handler, customerName, orderSelectCondition,userInfoApplication);
		orderListThread = new GetBackendServerDataByJsonThread(orderTaskByCustomer);
		orderListThread.start();
	}
	public void getUnPaidOrderList(Handler handler, OrderListBaseConditionInfo orderSelectCondition,UserInfoApplication userInfoApplication,int branchID){
		unPaidTask = new GetUnpaidOrderListTaskImpl(handler,orderSelectCondition,userInfoApplication,branchID);
		orderListThread = new GetBackendServerDataByJsonThread(unPaidTask);
		orderListThread.start();
	}
}
