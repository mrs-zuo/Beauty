package com.glamourpromise.beauty.customer.util;
import com.glamourpromise.beauty.customer.R;

import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Toast;

public class DialogUtil {
	public static void createMakeSureDialog(Context  context,String title,String message)
	{
		new AlertDialog.Builder(context).setMessage(message).setPositiveButton("确认",null).create().show();
	}
	public static void createShortDialog(Context  context,String message)
	{
		Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
	}
	
	public static ProgressDialog createUpdateApkDialog(Context  context){
		ProgressDialog updateApkDialog = new ProgressDialog(context);
		updateApkDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		updateApkDialog.setTitle(context.getString(R.string.updating_title));
		updateApkDialog.setMessage(context.getString(R.string.wait));
		updateApkDialog.setProgressNumberFormat("");
		updateApkDialog.show();
		updateApkDialog.setCancelable(false);
		return updateApkDialog;
	}
	
	public static AlertDialog showInstallDialog(Context  context, DialogInterface.OnClickListener onClickListener){
		AlertDialog installApkdialog = new AlertDialog.Builder(context)
		.setTitle(context.getString(R.string.install_software_title))
		.setMessage(context.getString(R.string.install_software_content))
		.setPositiveButton(context.getString(R.string.confirm), onClickListener).create();
		installApkdialog.setCancelable(false);
		return installApkdialog;
	}
}
