package com.glamourpromise.beauty.customer.broadcastreceiver;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class ReplaceBroadcastReceiver extends BroadcastReceiver{
	@Override
	public void onReceive(Context arg0, Intent intent) {
		String action = intent.getAction();
		String packageName = intent.getData().getSchemeSpecificPart();
		Log.d("packageName", packageName);
		if (Intent.ACTION_PACKAGE_ADDED.equals(action)) {
//			DialogUtil.createMakeSureDialog(SplashActivity.this, "添加了新的应用", packageName);
//			PackageManager pm = context.getPackageManager();
			Log.d("packageName", packageName);
//			Intent intent1 = new Intent();
//			try {
//				intent1 = pm.getLaunchIntentForPackage(packageName);
//			} catch (NameNotFoundException e) {
//				// TODO Auto-generated catch block
//				e.printStackTrace();
//			}
//			intent1.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//			context.startActivity(intent1);
		} else if (Intent.ACTION_PACKAGE_REPLACED.equals(action)){
//			DialogUtil.createMakeSureDialog(SplashActivity.this, "添加了新的应用", packageName);
//			PackageManager pm = context.getPackageManager();
			Log.d("ACTION_PACKAGE_REPLACED", packageName);
		}
	}
}
