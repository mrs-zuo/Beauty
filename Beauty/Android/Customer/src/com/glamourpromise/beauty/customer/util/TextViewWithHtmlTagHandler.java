package com.glamourpromise.beauty.customer.util;

import org.xml.sax.XMLReader;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.text.Editable;
import android.text.Html.TagHandler;
import android.text.Spanned;
import android.text.style.ClickableSpan;
import android.text.style.ImageSpan;
import android.view.View;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.ChatMessageListActivity;
import com.glamourpromise.beauty.customer.bean.RemindInformation;

public class TextViewWithHtmlTagHandler implements TagHandler{
	private Context context;
	private RemindInformation remindInformation;
	private String excutorPersonIcon;
	
	public TextViewWithHtmlTagHandler(Context context, RemindInformation remindInformation) {
		this.context = context;
		this.remindInformation = remindInformation;
		String.valueOf(R.drawable.remind_feiyu_responser_person_icon);
		excutorPersonIcon = String.valueOf(R.drawable.remind_feiyu_icon);
	}
	
	@SuppressLint("DefaultLocale")
	@Override
	public void handleTag(boolean opening, String tag, Editable output, XMLReader xmlReader) {
		// TODO Auto-generated method stub

		// 处理标签<img>
		if (tag.toLowerCase().equals("img")) {
			// 获取长度
			int len = output.length();
			// 获取图片地址
			ImageSpan[] images = output.getSpans(len-1, len, ImageSpan.class);
			String accountID = images[0].getSource();
			// 使图片可点击并监听点击事件
			output.setSpan(new ImageClick(context, accountID), len-1, len, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		}
	}
	
	private class ImageClick extends ClickableSpan {

		private String iconID;
		private String accountID;
		private String accountName;
		private String thumbnailImageURL;
		private boolean flyMessageAuthority;
		private Context context;
		
		public ImageClick(Context context, String iconID) {
			this.context = context;
			this.iconID = iconID;
		}
		
		@Override
		public void onClick(View widget) {
			accountName = remindInformation.getResponserPerson();
			accountID = remindInformation.getResponserPersonID();
			thumbnailImageURL = remindInformation.getResponserPersonHeadImageURL();
			flyMessageAuthority = remindInformation.isResponserflyMessageAuthority();
			Intent destIntent = new Intent(context, ChatMessageListActivity.class);
			destIntent.putExtra("AccountName", accountName);
			destIntent.putExtra("AccountID", accountID);
			destIntent.putExtra("thumbnailImageURL",thumbnailImageURL);
			if(flyMessageAuthority)
				destIntent.putExtra("flyMessageAuthority",1);
			else
				destIntent.putExtra("flyMessageAuthority",0);
			context.startActivity(destIntent);
		}
		
	}
}
