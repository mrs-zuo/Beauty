package com.glamourpromise.beauty.customer.broadcastreceiver;

import org.json.JSONException;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.RemoteViews;
import cn.jpush.android.api.JPushInterface;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.ChatMessageListActivity;
import com.glamourpromise.beauty.customer.activity.NavigationNew;
import com.glamourpromise.beauty.customer.fragment.ContactListFragment;
import com.glamourpromise.beauty.customer.util.JpushUtil;
/**
 * 自定义接收器
 * 
 * 如果不定义这个 Receiver，则：
 * 1) 默认用户会打开主界面
 * 2) 接收不到自定义消息
 */
public class JpushReceiver extends BroadcastReceiver {
	private static final String TAG = "JPush";
	private static int id=1;
	private static int APP_ICON;
	private NotificationManager notificationManager;
	
	public JpushReceiver(){
		
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		APP_ICON = context.getApplicationInfo().icon;
		if(notificationManager == null)
			notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        Bundle bundle = intent.getExtras();
		Log.d(TAG, "[MyReceiver] onReceive - " + intent.getAction() + ", extras: " + printBundle(bundle));
        if (JPushInterface.ACTION_REGISTRATION_ID.equals(intent.getAction())) {
            String regId = bundle.getString(JPushInterface.EXTRA_REGISTRATION_ID);
            Log.d(TAG, "[MyReceiver] 接收Registration Id : " + regId);
            //send the Registration Id to your server...
                        
        } else if (JPushInterface.ACTION_MESSAGE_RECEIVED.equals(intent.getAction())) {
        	Log.d(TAG, "[MyReceiver] 接收到推送下来的自定义消息: " + bundle.getString(JPushInterface.EXTRA_MESSAGE));
        	processCustomMessage(context, bundle);
        
        } else if (JPushInterface.ACTION_NOTIFICATION_RECEIVED.equals(intent.getAction())) {
            Log.d(TAG, "[MyReceiver] 接收到推送下来的通知");
            int notifactionId = bundle.getInt(JPushInterface.EXTRA_NOTIFICATION_ID);
            Log.d(TAG, "[MyReceiver] 接收到推送下来的通知的ID: " + notifactionId);
        	
        } else if (JPushInterface.ACTION_NOTIFICATION_OPENED.equals(intent.getAction())) {
            Log.d(TAG, "[MyReceiver] 用户点击打开了通知");
            JPushInterface.reportNotificationOpened(context, bundle.getString(JPushInterface.EXTRA_MSG_ID));
        	//打开自定义的Activity
        	Intent i = new Intent(context,NavigationNew.class);
        	i.putExtras(bundle);
        	i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        	context.startActivity(i);
        	
        } else if (JPushInterface.ACTION_RICHPUSH_CALLBACK.equals(intent.getAction())) {
            Log.d(TAG, "[MyReceiver] 用户收到到RICH PUSH CALLBACK: " + bundle.getString(JPushInterface.EXTRA_EXTRA));
            //在这里根据 JPushInterface.EXTRA_EXTRA 的内容处理代码，比如打开新的Activity， 打开一个网页等..
        	
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
	
	//send msg to MainActivity
	@SuppressLint("NewApi")
	private void processCustomMessage(Context context, Bundle bundle) {
		id++;
		if(id > 10)
			id = 1;
		String message = bundle.getString(JPushInterface.EXTRA_MESSAGE);
		String extras = bundle.getString(JPushInterface.EXTRA_EXTRA);
		JSONObject extraJson = null;
		String title = bundle.getString(JPushInterface.EXTRA_TITLE);
		int flag = -1;
		try {
			extraJson = new JSONObject(extras);
			flag = extraJson.getInt("pushType");
		} catch (JSONException e1) {
			e1.printStackTrace();
			return;
		}
		RemoteViews remoteView = new RemoteViews(context.getPackageName(),R.xml.notification);  
		remoteView.setImageViewResource(R.id.image, R.drawable.ic_launcher);  
		remoteView.setTextViewText(R.id.title , title); 
		remoteView.setTextViewText(R.id.content, message);
		
		Notification notification = new Notification();
        notification.icon = APP_ICON;
		notification.defaults = Notification.DEFAULT_LIGHTS;
		notification.defaults |= Notification.DEFAULT_SOUND;
		notification.defaults |= Notification.DEFAULT_VIBRATE;
		notification.flags |= Notification.FLAG_AUTO_CANCEL;
		notification.when = System.currentTimeMillis();
		notification.tickerText = message;

		if (flag == 1 && !ContactListFragment.isForeground && !ChatMessageListActivity.isForeground) {
			Intent msgIntent = new Intent(ContactListFragment.MESSAGE_RECEIVED_ACTION);
			msgIntent.putExtra(ContactListFragment.KEY_MESSAGE, message);
			if (!JpushUtil.isEmpty(extras)) {
				if (null != extraJson && extraJson.length() > 0) {
					msgIntent.putExtra(ContactListFragment.KEY_EXTRAS, extras);
				    Intent intent = new Intent(context,NavigationNew.class);
				    intent.putExtra(ContactListFragment.NOTIFICATION_FLAG,ContactListFragment.NOTIFICATION_FLAG);
				    PendingIntent contentIntent = PendingIntent.getActivity(context, 0,intent, PendingIntent.FLAG_UPDATE_CURRENT);
				    notification.contentView = remoteView; 
				    notification.bigContentView = remoteView;
				    notification.contentIntent = contentIntent;
				    notificationManager.notify(id, notification);
				}
			}
			context.sendBroadcast(msgIntent);
		}else if(flag == 1 && ChatMessageListActivity.isForeground){
			Intent intent = new Intent(ChatMessageListActivity.NEW_MESSAGE_BROADCAST_ACTION);
			context.sendBroadcast(intent);
		}else if(flag == 1 && ContactListFragment.isForeground){
			Intent intent = new Intent(ContactListFragment.NEW_MESSAGE_BROADCAST_ACTION);
			context.sendBroadcast(intent);
		}else{ 
			Intent intent = new Intent(context,NavigationNew.class);
			PendingIntent contentIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
			notification.contentView = remoteView;
			notification.contentIntent = contentIntent;
			notificationManager.notify(id, notification);
		}
	}
}
