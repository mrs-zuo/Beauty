package cn.com.antika.manager;

import android.os.Handler;
import android.os.HandlerThread;

import cn.com.antika.Thread.GetBackendServerDataByJsonThread;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderListBaseConditionInfo;
import cn.com.antika.implementation.GetOrderListByCustomerIDTaskImpl;
import cn.com.antika.implementation.GetOrderListTaskImpl;
import cn.com.antika.implementation.GetUnpaidOrderListTaskImpl;

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
	public void getOrderList(Handler handler, OrderListBaseConditionInfo orderSelectCondition, UserInfoApplication userInfoApplication){
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
