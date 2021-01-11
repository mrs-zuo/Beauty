package com.GlamourPromise.Beauty.Business;

import java.io.Serializable;
import java.util.List;

import cn.jpush.android.api.JPushInterface;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

public class BaseActivity extends Activity {
    private static SharedPreferences sharedPreferences;
    private static boolean isLeave = false;
    private UserInfoApplication userInfoApplication;
    private SharedPreferences appExpiredSharedPreferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        sharedPreferences = getSharedPreferences("timeoutcheck", Context.MODE_PRIVATE);
        appExpiredSharedPreferences = getSharedPreferences("AppExpiredValue", Context.MODE_PRIVATE);
        userInfoApplication = UserInfoApplication.getInstance();
        //性能分析
        //Debug.startMethodTracing("BPT");
    }

    @Override
    protected void onUserLeaveHint() { // 当用户按Home键等操作使程序进入后台时即开始计时
        // TODO Auto-generated method stub
        super.onUserLeaveHint();
        if (!isLeave) {
            isLeave = true;
            saveStartTime();
        }
    }

    @Override
    protected void onResume() { // 当用户使程序恢复为前台显示时执行onResume()方法,在其中判断是否超时.
        // TODO Auto-generated method stub
        super.onResume();
        JPushInterface.onResume(this);
		/*if(JPushInterface.isPushStopped(getApplicationContext())){
			JPushInterface.resumePush(getApplicationContext());
			String uuid = com.GlamourPromise.Beauty.Jpush.RandomUUID.getRandomUUID(this, sharedPreferences.getString("lastLoginAccount", ""));
			JPushInterface.init(getApplicationContext());
			JPushInterface.setAlias(getApplicationContext(), uuid, null);
		}*/
        if (isLeave) {
            isLeave = false;
            timeOutCheck();
        }
    }

    @Override
    protected void onPause() {
        // TODO Auto-generated method stub
        super.onPause();
        JPushInterface.onPause(this);
        if (!isLeave) {
            isLeave = true;
            saveStartTime();
        }
    }

    public void timeOutCheck() {
        long endtime = System.currentTimeMillis();
        //app超时时间根据账户设置的时间进行设置
        int appExpiredTime = appExpiredSharedPreferences.getInt("APP_EXPIRED_VALUE", 30);
        //超时时间不为0并且登陆界面不是在最活动状态
        if (appExpiredTime != 0 && !LoginActivity.isForeground) {
            if (endtime - getStartTime() >= appExpiredTime * 60 * 1000) {
                DialogUtil.createShortDialog(this, "登录超时,请重新登录！");
                userInfoApplication.setAccountInfo(null);
                userInfoApplication.setSelectedCustomerID(0);
                userInfoApplication.setSelectedCustomerName("");
                userInfoApplication.setSelectedCustomerHeadImageURL("");
                userInfoApplication.setSelectedCustomerLoginMobile("");
                userInfoApplication.setOrderInfo(null);
                userInfoApplication.setAccountNewMessageCount(0);
                userInfoApplication.setAccountNewRemindCount(0);
                userInfoApplication.exit(this);
                Constant.formalFlag = 0;
                Intent destIntent = new Intent(this, LoginActivity.class);
                startActivity(destIntent);
            }
        }
    }

    public void saveStartTime() {
        sharedPreferences.edit()
                .putLong("starttime", System.currentTimeMillis()).commit();
    }

    public long getStartTime() {
        return sharedPreferences.getLong("starttime", 0);

    }

    @Override
    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        String isExit = intent.getStringExtra("exit");
        if (isExit != null && isExit.equals("1")) {
            clearLoginInfo();
            ActivityManager manager = (ActivityManager) this.getSystemService(Context.ACTIVITY_SERVICE);
            List<ActivityManager.RunningTaskInfo> tasks = manager.getRunningTasks(1);
            ComponentName baseActivity = tasks.get(0).baseActivity;
            finish();
        }
        //商家切换时执行
        else if (isExit != null && isExit.equals("2")) {
            Intent destIntent = new Intent(this, CompanySelectActivity.class);
            Bundle mBundle = new Bundle();
            mBundle.putSerializable("AccountInfoList", (Serializable) (Serializable) userInfoApplication.getAccountInfoList());
            mBundle.putSerializable("BranchInfoList", (Serializable) userInfoApplication.getLoginBranchList());
            destIntent.putExtras(mBundle);
            destIntent.putExtra("LoginMobile", userInfoApplication.getAccountInfo().getLoginMobile());
            destIntent.putExtra("SRC_ACTIVITY", SettingActivity.TAG);
            startActivity(destIntent);
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        //Debug.stopMethodTracing();//停止数据采集
        System.gc();
    }

    //事件分发机制  捕获当前的点击位置是否是文本框位置，文本框以外的则隐藏掉键盘
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            View v = getCurrentFocus();
            if (isShouldHideInput(v, ev)) {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                if (imm != null) {
                    imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                }
            }
            return super.dispatchTouchEvent(ev);
        }
        // 必不可少，否则所有的组件都不会有TouchEvent了
        if (getWindow().superDispatchTouchEvent(ev)) {
            return true;
        }
        return onTouchEvent(ev);
    }

    //判断点击的当前视图需要隐藏键盘
    public boolean isShouldHideInput(View v, MotionEvent event) {
        if (v != null && (v instanceof EditText)) {
            int[] leftTop = {0, 0};
            //获取输入框当前的location位置  
            v.getLocationInWindow(leftTop);
            int left = leftTop[0];
            int top = leftTop[1];
            int bottom = top + v.getHeight();
            int right = left + v.getWidth();
            if (event.getX() > left && event.getX() < right && event.getY() > top && event.getY() < bottom) {
                // 点击的是输入框区域，保留点击EditText的事件  
                return false;
            } else {
                return true;
            }
        }
        return false;
    }

    private void clearLoginInfo() {
        userInfoApplication.setAccountInfo(null);
        userInfoApplication.setSelectedCustomerID(0);
        userInfoApplication.setSelectedCustomerName("");
        userInfoApplication.setSelectedCustomerHeadImageURL("");
        userInfoApplication.setSelectedCustomerLoginMobile("");
        userInfoApplication.setOrderInfo(null);
        userInfoApplication.setAccountNewMessageCount(0);
        userInfoApplication.setAccountInfoPosition(0, 0);
        Constant.formalFlag = 0;
    }
}
