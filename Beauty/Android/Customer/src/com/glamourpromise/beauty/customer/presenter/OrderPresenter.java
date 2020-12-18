package com.glamourpromise.beauty.customer.presenter;

import java.util.ArrayList;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.repository.OrderRepository;
import com.glamourpromise.beauty.customer.util.ThreadExecutor;
import com.glamourpromise.beauty.customer.view.IOrderListView;

public class OrderPresenter{
	private ThreadExecutor mExecutor;
	private OrderRepository mOrderRepo;
	private ArrayList<OrderBaseInfo> mCusrrentServiceOrders;
	private ArrayList<OrderBaseInfo> mLastServiceOrders;
	private IOrderListView mOrderListView;
	
	private OrderRepository.OrderListCallback mRepoListCallback = new OrderRepository.OrderListCallback() {
		
		@Override
		public void onOrderListLoaded(ArrayList<OrderBaseInfo> serviceOrders) {
			mCusrrentServiceOrders = serviceOrders;
			mHandler.sendEmptyMessage(1);
		}

		@Override
		public void onLoadedError(String message) {
			mHandler.sendMessage(mHandler.obtainMessage(2, message));
		}

		@Override
		public void onHttpError(int httpCode, int httpMessage) {
			mHandler.sendMessage(mHandler.obtainMessage(3, httpCode, httpMessage));
		}
		
	};
	private Handler mHandler = new Handler(Looper.getMainLooper()){

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case 1:
				mLastServiceOrders = mCusrrentServiceOrders;
				mOrderListView.renderView(mLastServiceOrders);
				break;
			case 2:
				mOrderListView.renderError((String)msg.obj);
				break;
			case 3:
				int httpCode = msg.arg2;
				if(httpCode == 401){
					int httpErrorMessage = msg.arg2;
					switch (httpErrorMessage) {
					case 10001:
					case 10002:
					case 10003:
					case 10004:
					case 10005:
					case 10006:
					case 10007:
					case 10008:
					case 10009:
					case 10011:
					case 10012:
						mOrderListView.handleHttpError_401(httpCode);
						break;
					case 10010:
						// 版本过低
						mOrderListView.promptUpdate();
						break;

					case 10013:
						// 登陆异常
						mOrderListView.handleLoginException();
						break;
					}
				}else{
					mOrderListView.handleHttpError_401(httpCode);
				}
				break;
			}
		}
		
	};
	
	private OrderListRunnable orderListRunnable;
	
	public OrderPresenter(String customerID, UserInfoApplication app){
		mOrderRepo = new OrderRepository(customerID, app);
		orderListRunnable = new OrderListRunnable();
		mExecutor = new ThreadExecutor();
	}
	
	public void loadOrderList(int productType, int orderStatus, int orderPayStatus){
		orderListRunnable.productType = productType;
		orderListRunnable.orderStatus = orderStatus;
		orderListRunnable.orderPayStatus = orderPayStatus;
		mExecutor.run(orderListRunnable);
	}
	
	public void setOrderListView(IOrderListView orderListView){
		mOrderListView = orderListView;
	}
	
	private class OrderListRunnable implements Runnable{
		int productType;
		int orderStatus; 
		int orderPayStatus;
		@Override
		public void run() {
			mOrderRepo.getOrderList(productType, orderStatus, orderPayStatus, mRepoListCallback);
		}
	}

}
