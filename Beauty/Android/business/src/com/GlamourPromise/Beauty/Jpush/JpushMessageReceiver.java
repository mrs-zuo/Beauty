package com.GlamourPromise.Beauty.Jpush;
import org.json.JSONException;
import org.json.JSONObject;
import com.GlamourPromise.Beauty.Business.FlyMessageDetailActivity;
import com.GlamourPromise.Beauty.Business.FlyMessageListActivity;
import com.GlamourPromise.Beauty.Business.HomePageActivity;
import com.GlamourPromise.Beauty.Business.OrderListActivity;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.constant.Constant;
import cn.jpush.android.api.JPushInterface;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.widget.RemoteViews;
public class JpushMessageReceiver extends BroadcastReceiver {
	private static final String TAG = "JPush";
	private static int APP_ICON;
	private NotificationManager notificationManager;
	private static int pushID = 1;// 标识每一次的推送

	@Override
	public void onReceive(Context context, Intent intent) {
		try {
			PackageManager pm = context.getPackageManager();
			PackageInfo pi = null;
			pi = pm.getPackageInfo(context.getPackageName(), 0);
			Log.v(TAG + "packageName", pi.packageName);
			APP_ICON = pi.applicationInfo.icon;
		} catch (Exception e) {
			APP_ICON = 0; // failed, ignored
		}
		if (notificationManager == null)
			notificationManager = (NotificationManager) context.getSystemService(context.NOTIFICATION_SERVICE);
		Bundle bundle = intent.getExtras();
		Log.d(TAG, "[MyReceiver] onReceive - " + intent.getAction()+ ", extras: " + printBundle(bundle));
		if (JPushInterface.ACTION_REGISTRATION_ID.equals(intent.getAction())) {
			String regId = bundle.getString(JPushInterface.EXTRA_REGISTRATION_ID);
			Log.d(TAG, "[MyReceiver] 接收Registration Id : " + regId);
			// send the Registration Id to your server...

		} else if (JPushInterface.ACTION_MESSAGE_RECEIVED.equals(intent
				.getAction())) {
			Log.d(TAG,"[MyReceiver] 接收到推送下来的自定义消息: "+ bundle.getString(JPushInterface.EXTRA_MESSAGE));
			processCustomMessage(context, bundle);
		} else if (JPushInterface.ACTION_NOTIFICATION_RECEIVED.equals(intent.getAction())) {
			Log.d(TAG, "[MyReceiver] 接收到推送下来的通知");
			int notifactionId = bundle.getInt(JPushInterface.EXTRA_NOTIFICATION_ID);
			Log.d(TAG, "[MyReceiver] 接收到推送下来的通知的ID: " + notifactionId);
		} else if (JPushInterface.ACTION_NOTIFICATION_OPENED.equals(intent.getAction())) {
			Log.d(TAG, "[MyReceiver] 用户点击打开了通知");
			JPushInterface.reportNotificationOpened(context,bundle.getString(JPushInterface.EXTRA_MSG_ID));
			// 打开自定义的Activity
			Intent i = new Intent(context, FlyMessageListActivity.class);
			i.putExtras(bundle);
			i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			context.startActivity(i);
		} else if (JPushInterface.ACTION_RICHPUSH_CALLBACK.equals(intent
				.getAction())) {
			Log.d(TAG,"[MyReceiver] 用户收到到RICH PUSH CALLBACK: "+ bundle.getString(JPushInterface.EXTRA_EXTRA));
			// 在这里根据 JPushInterface.EXTRA_EXTRA 的内容处理代码，比如打开新的Activity，
			// 打开一个网页等..
		} else {
			Log.d(TAG, "[MyReceiver] Unhandled intent - " + intent.getAction());
		}
	}

	// 打印所有的 intent extra 数据
	private static String printBundle(Bundle bundle) {
		StringBuilder sb = new StringBuilder();
		for (String key : bundle.keySet()) {
			if (key.equals(JPushInterface.EXTRA_NOTIFICATION_ID)) {
				sb.append("\nkey:" + key + ", value:" + bundle.getInt(key));
			} else {
				sb.append("\nkey:" + key + ", value:" + bundle.getString(key));
			}
		}
		return sb.toString();
	}

	// send msg to MainActivity
	@SuppressWarnings("deprecation")
	private void processCustomMessage(Context context, Bundle bundle) {
		pushID++;
		if (pushID > 100)
			pushID = 1;
		String message = bundle.getString(JPushInterface.EXTRA_MESSAGE);
		String extras = bundle.getString(JPushInterface.EXTRA_EXTRA);
		String title = bundle.getString(JPushInterface.EXTRA_TITLE);
		JSONObject extraJson = null;
		int flag = -1;
		try {
			extraJson = new JSONObject(extras);
			flag = extraJson.getInt("pushType");
		} catch (JSONException e1) {

		}
		RemoteViews remoteView=new RemoteViews(context.getPackageName(),R.xml.customer_notification_layout);
		remoteView.setImageViewResource(R.id.image,R.drawable.ic_launcher);
		remoteView.setTextViewText(R.id.title,title);
		remoteView.setTextViewText(R.id.content,message);
		Notification notification = new Notification();
		//notification.icon = APP_ICON;
		notification.icon=R.drawable.ic_launcher;
		notification.defaults = Notification.DEFAULT_LIGHTS;
		notification.defaults |= Notification.DEFAULT_SOUND;
		notification.defaults |= Notification.DEFAULT_VIBRATE;
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.when = System.currentTimeMillis();
		notification.tickerText = message;
		if (flag == 2 && !OrderListActivity.isForeground) {
			Intent intent = new Intent(context, OrderListActivity.class);
			intent.putExtra("FromJpush", true);
			intent.putExtra("USER_ROLE", Constant.USER_ROLE_BUSINESS);
			PendingIntent contentIntent = PendingIntent.getActivity(context, 0,
					intent, PendingIntent.FLAG_UPDATE_CURRENT);
			notification.contentView=remoteView;
			notification.contentIntent=contentIntent;
			//notification.setLatestEventInfo(context, title, message,contentIntent);
			notificationManager.notify(pushID, notification);
		} else if (flag == 2 && OrderListActivity.isForeground) {
			Intent intent = new Intent(OrderListActivity.NEW_MESSAGE_BROADCAST_ACTION);
			intent.putExtra("USER_ROLE",Constant.USER_ROLE_BUSINESS);
			context.sendBroadcast(intent);
		} else if ((flag == 1) && !FlyMessageListActivity.isForeground && !FlyMessageDetailActivity.isForeground) {
			Intent msgIntent = new Intent(FlyMessageListActivity.MESSAGE_RECEIVED_ACTION);
			Intent intent = new Intent(context, FlyMessageListActivity.class);
			intent.putExtra("FromJpush", true);
			PendingIntent contentIntent = PendingIntent.getActivity(context, 0,intent, PendingIntent.FLAG_UPDATE_CURRENT);
			notification.contentView=remoteView;
			notification.contentIntent=contentIntent;
			notificationManager.notify(pushID, notification);
			context.sendBroadcast(msgIntent);
		} else if ((flag == 1) && FlyMessageDetailActivity.isForeground) {
			Intent intent = new Intent(FlyMessageDetailActivity.NEW_MESSAGE_BROADCAST_ACTION);
			context.sendBroadcast(intent);
		} else if ((flag == 1) && FlyMessageListActivity.isForeground) {
			Intent intent = new Intent(FlyMessageListActivity.NEW_MESSAGE_BROADCAST_ACTION);
			context.sendBroadcast(intent);
		} else {
			Intent intent = new Intent(context,HomePageActivity.class);
			PendingIntent contentIntent = PendingIntent.getActivity(context, 0,intent, PendingIntent.FLAG_UPDATE_CURRENT);
			notification.contentView=remoteView;
			notification.contentIntent=contentIntent;
			notificationManager.notify(pushID, notification);
		}
	}
}
