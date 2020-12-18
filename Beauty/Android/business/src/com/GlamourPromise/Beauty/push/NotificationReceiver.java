/*
 * Copyright (C) 2010 Moduad Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.GlamourPromise.Beauty.push;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

/** 
 * Broadcast receiver that handles push notification messages from the server.
 * This should be registered as receiver in AndroidManifest.xml. 
 * 
 * @author Sehwan Noh (devnoh@gmail.com)
 */
public final class NotificationReceiver extends BroadcastReceiver {

    private static final String LOGTAG = LogUtil
            .makeLogTag(NotificationReceiver.class);

    private Context mContext;
    private SharedPreferences sharedPrefs;
    //    private NotificationService notificationService;

    public NotificationReceiver(Context context) {
    	 this.mContext = context;
    }

    //    public NotificationReceiver(NotificationService notificationService) {
    //        this.notificationService = notificationService;
    //    }

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(LOGTAG, "NotificationReceiver.onReceive()...");
        Log.v("ReceviceContext", context.getClass().getName());
        String action = intent.getAction();
        Log.d(LOGTAG, "action=" + action);

        if (Constants.ACTION_SHOW_NOTIFICATION.equals(action)) {
            String notificationId = intent
                    .getStringExtra(Constants.NOTIFICATION_ID);
            String notificationApiKey = intent
                    .getStringExtra(Constants.NOTIFICATION_API_KEY);
            String notificationTitle = intent
                    .getStringExtra(Constants.NOTIFICATION_TITLE);
            String notificationMessage = intent
                    .getStringExtra(Constants.NOTIFICATION_MESSAGE);
            String notificationUri = intent
                    .getStringExtra(Constants.NOTIFICATION_URI);

            Log.d(LOGTAG, "notificationId=" + notificationId);
            Log.d(LOGTAG, "notificationApiKey=" + notificationApiKey);
            Log.d(LOGTAG, "notificationTitle=" + notificationTitle);
            Log.d(LOGTAG, "notificationMessage=" + notificationMessage);
            Log.d(LOGTAG, "notificationUri=" + notificationUri);

            
            sharedPrefs = context.getSharedPreferences(Constants.SHARED_PREFERENCE_NAME,
                    Context.MODE_PRIVATE);
            
            if(sharedPrefs.getString(Constants.CONTACT_LIST_ACTIVITY_STATUS, "").equals("false") ||  sharedPrefs.getString(Constants.CHAT_LIST_ACTIVITY_STATUS, "").equals("false")){
            	Notifier notifier = new Notifier(context);
                notifier.notify(notificationId, notificationApiKey,
                        notificationTitle, notificationMessage, notificationUri);
                Log.v("contact_list_activity_status", sharedPrefs.getString(Constants.CONTACT_LIST_ACTIVITY_STATUS, ""));
            }
            
            
            //������ϵ��id�㲥
            if(sharedPrefs.getString(Constants.CONTACT_LIST_ACTIVITY_STATUS, "").equals("true")){
            	Intent intent_contact=new Intent("android.intent.action.newmessage");
                intent_contact.putExtra("sendID", String.valueOf(notificationTitle));
                intent_contact.putExtra("messageContent", notificationMessage);
                context.sendBroadcast(intent_contact);
            }
            
            if(sharedPrefs.getString(Constants.CHAT_LIST_ACTIVITY_STATUS, "").equals("true")){
            	Intent intent_chatlist=new Intent("android.intent.action.newchatmessage");
                intent_chatlist.putExtra("newMessageContent", notificationMessage);
                context.sendBroadcast(intent_chatlist);
            }
            
//            ActivityManager am = (ActivityManager)mContext.getSystemService(Context.ACTIVITY_SERVICE);
//            am.getRunningTasks(2);

            Log.v("NotificationReceiver", "ok");
        }

        //        } else if (Constants.ACTION_NOTIFICATION_CLICKED.equals(action)) {
        //            String notificationId = intent
        //                    .getStringExtra(Constants.NOTIFICATION_ID);
        //            String notificationApiKey = intent
        //                    .getStringExtra(Constants.NOTIFICATION_API_KEY);
        //            String notificationTitle = intent
        //                    .getStringExtra(Constants.NOTIFICATION_TITLE);
        //            String notificationMessage = intent
        //                    .getStringExtra(Constants.NOTIFICATION_MESSAGE);
        //            String notificationUri = intent
        //                    .getStringExtra(Constants.NOTIFICATION_URI);
        //
        //            Log.e(LOGTAG, "notificationId=" + notificationId);
        //            Log.e(LOGTAG, "notificationApiKey=" + notificationApiKey);
        //            Log.e(LOGTAG, "notificationTitle=" + notificationTitle);
        //            Log.e(LOGTAG, "notificationMessage=" + notificationMessage);
        //            Log.e(LOGTAG, "notificationUri=" + notificationUri);
        //
        //            Intent detailsIntent = new Intent();
        //            detailsIntent.setClass(context, NotificationDetailsActivity.class);
        //            detailsIntent.putExtras(intent.getExtras());
        //            //            detailsIntent.putExtra(Constants.NOTIFICATION_ID, notificationId);
        //            //            detailsIntent.putExtra(Constants.NOTIFICATION_API_KEY, notificationApiKey);
        //            //            detailsIntent.putExtra(Constants.NOTIFICATION_TITLE, notificationTitle);
        //            //            detailsIntent.putExtra(Constants.NOTIFICATION_MESSAGE, notificationMessage);
        //            //            detailsIntent.putExtra(Constants.NOTIFICATION_URI, notificationUri);
        //            detailsIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        //            detailsIntent.setFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
        //
        //            try {
        //                context.startActivity(detailsIntent);
        //            } catch (ActivityNotFoundException e) {
        //                Toast toast = Toast.makeText(context,
        //                        "No app found to handle this request",
        //                        Toast.LENGTH_LONG);
        //                toast.show();
        //            }
        //
        //        } else if (Constants.ACTION_NOTIFICATION_CLEARED.equals(action)) {
        //            //
        //        }

    }

}
