package com.glamourpromise.beauty.customer.presenter;

import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.LeftMenuBean;
import com.glamourpromise.beauty.customer.repository.LeftMenuRepository;
import com.glamourpromise.beauty.customer.util.ThreadExecutor;

public class LeftMenuPresenter implements Runnable, LeftMenuRepository.MenuPromptInfoCallback{
	
	private static LeftMenuPresenter mInstance;
	
	private UserInfoApplication mApp;
	private onRefreshListener mLisrener;
	private String mCustomerID;
	private SharedPreferences mPre;
	
	private LeftMenuBean mLastMenu;
	private boolean isRefresh;
	
	private LeftMenuRepository mRepo;
	private ThreadExecutor mExecutor;
	private Handler mHandler = new Handler(Looper.getMainLooper()){

		@Override
		public void handleMessage(Message msg) {
			notifyDataChange();
			isRefresh = false;
		}
	};
	
	public interface onRefreshListener{
		public void onHandleResponse(LeftMenuBean data);
	}
	
	public static LeftMenuPresenter getInstace(UserInfoApplication app){
		if(mInstance == null){
			mInstance = new LeftMenuPresenter(app);
		}
		return mInstance;
	}
	
	public static void reset(){
		mInstance = null;
	}

	private LeftMenuPresenter(UserInfoApplication app) {
		isRefresh = false;
		mApp = app;
		mPre = mApp.getSharedPreferences();
		mExecutor = app.getThreadExecutor();
	}
	
	@Override
	public void run() {
		if(mRepo == null){
			mRepo = new LeftMenuRepository(mCustomerID, mApp);
		}
		mRepo.getMenuPromptCount(this);
	}

	public void refresh(onRefreshListener listener){
		mLisrener = listener;
		if(!isRefresh){
			isRefresh = true;
			mExecutor.run(this);
		}else{
			notifyDataChange();
		}
	}
	
	public void register(onRefreshListener listener){
		mLisrener = listener;
	}
	
	public void unRegister(onRefreshListener listener){
		mLisrener = null;
	}
	
	public void addCartCount(int count){
		if(mLastMenu != null){
			int currentCount = Integer.valueOf(mLastMenu.getCartCount());
			currentCount += count;
			mLastMenu.setCartCount(String.valueOf(currentCount));
			notifyDataChange();
			Editor editor = mPre.edit();// 获取编辑器
			editor.putString("cartCount", mLastMenu.getCartCount());
			editor.commit();// 提交修改
		}
	}
	
	public void addUnpaymentOrderCount(int count){
		if(mLastMenu != null){
			int currentCount = Integer.valueOf(mLastMenu.getUnpaidOrderCount());
			currentCount += count;
			mLastMenu.setUnpaidOrderCount(String.valueOf(currentCount));
			notifyDataChange();
			Editor editor = mPre.edit();// 获取编辑器
			editor.putString("unpaidOrderCount", mLastMenu.getUnpaidOrderCount());
			editor.commit();// 提交修改
		}
	}
	
	public void addUnComfirmOrderCount(int count){
		if(mLastMenu != null){
			int currentCount = Integer.valueOf(mLastMenu.getUnconfirmedOrderCount());
			currentCount += count;
			mLastMenu.setUnconfirmedOrderCount(String.valueOf(currentCount));
			notifyDataChange();
			Editor editor = mPre.edit();// 获取编辑器
			editor.putString("unconfirmOrderCount", mLastMenu.getUnconfirmedOrderCount());
			editor.commit();// 提交修改
		}
	}

	private void notifyDataChange() {
		if(mLisrener != null && mLastMenu != null){
			mLisrener.onHandleResponse(mLastMenu);
		}
	}

	@Override
	public void onLoaded(LeftMenuBean leftmenuCount) {
		mLastMenu = leftmenuCount;
		mHandler.obtainMessage(1).sendToTarget();
	}
}
