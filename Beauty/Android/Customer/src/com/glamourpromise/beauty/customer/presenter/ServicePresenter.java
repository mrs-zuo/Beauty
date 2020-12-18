package com.glamourpromise.beauty.customer.presenter;

import java.util.ArrayList;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.repository.ServiceRepository;
import com.glamourpromise.beauty.customer.util.ThreadExecutor;
import com.glamourpromise.beauty.customer.view.IServiceListView;

public class ServicePresenter {
	private static ServicePresenter mInstance;
	private ThreadExecutor mExecutor;
	private ServiceRepository mRepo;
	private IServiceListView mListView;
	private ArrayList<ServiceInformation> mCurrentList;
	private ServiceListRunnable mServiceListRunnable;
	private UserInfoApplication mApp;
	private ServiceRepository.ServiceListCallback mListCallBack = new ServiceRepository.ServiceListCallback() {
		
		@Override
		public void onServiceListLoaded(ArrayList<ServiceInformation> services) {
			mCurrentList = services;
			mHandler.sendEmptyMessage(1);
		}
		
		@Override
		public void onHttpError(int httpCode, int httpMessageCode) {
			mHandler.sendMessage(mHandler.obtainMessage(3, httpCode, httpMessageCode));
		}
		
		@Override
		public void onError(String message) {
			mHandler.sendMessage(mHandler.obtainMessage(2, message));
		}
	};
	
	private Handler mHandler = new Handler(Looper.getMainLooper()){

		@Override
		public void handleMessage(Message msg) {
			if(mListView == null){
				return;
			}
			switch (msg.what) {
			case 1:
				mListView.renderView(mCurrentList);
				break;
			case 2:
				mListView.renderError((String)msg.obj);
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
						mListView.handleHttpError_401(httpCode);
						break;
					case 10010:
						// 版本过低
						mListView.promptUpdate();
						break;

					case 10013:
						// 登陆异常
						mListView.handleLoginException();
						break;
					}
				}else{
					mListView.handleHttpError_401(httpCode);
				}
				break;
			}
		}
		
	};
	
	public static ServicePresenter getInsance(UserInfoApplication app){
		if(mInstance == null){
			mInstance = new ServicePresenter(app);
		}
		return mInstance;
	}
	
	public static void reset(){
		mInstance = null;
	}

	private ServicePresenter(UserInfoApplication app) {
		mApp = app;
		mExecutor = app.getThreadExecutor();
		mServiceListRunnable = new ServiceListRunnable();
	}
	
	public void loadServiceList(String categoryID){
		mServiceListRunnable.setCategoryID(categoryID);
		mExecutor.run(mServiceListRunnable);
	}
	
	public void setView(IServiceListView view){
		mListView = view;
	}



	private class ServiceListRunnable implements Runnable{
		String categoryID;


		public void setCategoryID(String categoryID) {
			this.categoryID = categoryID;
		}


		@Override
		public void run() {
			if(mRepo == null){
				mRepo = new ServiceRepository(mApp.getLoginInformation().getBranchID(), mApp.getLoginInformation().getCustomerID(), mApp.getScreenWidth(), mApp);
			}
			mRepo.getServiceList(categoryID, mListCallBack);
		}
	}
	
}
