package cn.com.antika.util;


import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;

import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class ProgressDialogUtil {
    //防止按钮重复点击事件 在500毫秒之内不能连续两次点击按钮
    private static long lastClickTime;

    public synchronized static boolean isFastClick() {
        long time = System.currentTimeMillis();
        if (time - lastClickTime < 500) {
            return true;
        }
        lastClickTime = time;
        return false;
    }

    //展示不可退出的对话框
    public static ProgressDialog createProgressDialog(Context mContext) {
        ProgressDialog progressDialog = null;
        if (mContext != null) {
            progressDialog = new ProgressDialog(mContext, R.style.CustomerProgressDialog);
            progressDialog.setMessage(mContext.getString(R.string.please_wait));
            progressDialog.setCanceledOnTouchOutside(false);
            progressDialog.show();
        }
        return progressDialog;
    }
}
