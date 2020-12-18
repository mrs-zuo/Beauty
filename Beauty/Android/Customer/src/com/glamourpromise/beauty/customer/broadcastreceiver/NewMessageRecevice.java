package com.glamourpromise.beauty.customer.broadcastreceiver;

import java.lang.ref.WeakReference;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class NewMessageRecevice extends BroadcastReceiver{
	public interface ReceiveCallback{
		public void onReceive();
	}
	
	private WeakReference<ReceiveCallback> mCallback;
	
	public NewMessageRecevice(ReceiveCallback callback) {
		super();
		mCallback = new WeakReference<NewMessageRecevice.ReceiveCallback>(callback);
	}

	@Override
	public void onReceive(Context arg0, Intent arg1) {
		if(mCallback != null && mCallback.get() != null)
			mCallback.get().onReceive();
	}
}
