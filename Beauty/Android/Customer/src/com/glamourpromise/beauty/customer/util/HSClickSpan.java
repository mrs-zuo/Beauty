package com.glamourpromise.beauty.customer.util;

import com.glamourpromise.beauty.customer.R;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.text.Spannable;
import android.text.TextPaint;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.TextView;

public class HSClickSpan extends ClickableSpan {
	TextView textView;
	Context  mContext;
	int      linkType;//1:网址跳转  2：电话跳转
	public HSClickSpan(TextView text, Context context,int linkType) {
		this.textView = text;
		this.mContext = context;
		this.linkType=linkType;
	}
	@Override
	public void updateDrawState(TextPaint ds) {
		// TODO Auto-generated method stub
		super.updateDrawState(ds);
		ds.setUnderlineText(false);
		ds.setColor(Color.BLACK);
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		CharSequence text = textView.getText();
		if (text instanceof Spannable) {
			int end = text.length();
			Spannable sp = (Spannable) text;
			URLSpan[] urls = sp.getSpans(0,end,URLSpan.class);
			for (URLSpan url : urls) {
				final String urlString=url.getURL();
				if(linkType==1){
					Dialog dialog = new AlertDialog.Builder(mContext)
							.setTitle("温馨提示")
							.setMessage("是否跳转该网址?")
							.setPositiveButton(mContext.getString(R.string.confirm),
									new DialogInterface.OnClickListener() {
										@Override
										public void onClick(DialogInterface dialog,
												int which) {
											dialog.dismiss();
											Intent intent = new Intent();        
											intent.setAction("android.intent.action.VIEW");    
											Uri url = Uri.parse(urlString);   
											intent.setData(url);  
											mContext.startActivity(intent);
										}
									})
							.setNegativeButton(mContext.getString(R.string.cancel),
									new DialogInterface.OnClickListener() {
										@Override
										public void onClick(DialogInterface dialog,int which) {
											dialog.dismiss();
											dialog = null;
										}
									}).create();
					dialog.show();
					dialog.setCancelable(false);
				}
				else if(linkType==2){
					Dialog dialog = new AlertDialog.Builder(mContext)
					.setTitle("温馨提示")
					.setMessage("是否拨打该电话?")
					.setPositiveButton(mContext.getString(R.string.confirm),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									dialog.dismiss();
									Intent intent = new Intent(Intent.ACTION_CALL,Uri.parse("tel:"+urlString));
									mContext.startActivity(intent);
								}
							})
					.setNegativeButton(mContext.getString(R.string.cancel),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,int which) {
									dialog.dismiss();
									dialog = null;
								}
							}).create();
			dialog.show();
			dialog.setCancelable(false);
				}
			}
		}
	}
}