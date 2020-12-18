package com.glamourpromise.beauty.customer.util;

import android.content.Context;
import android.content.Intent;

public class IntentUtil {
	public static void assignToDefault(Context context){
		Intent defultIntent=new Intent();
		defultIntent.setAction("com.glamise.customer.default");
		context.startActivity(defultIntent);
	}
}
