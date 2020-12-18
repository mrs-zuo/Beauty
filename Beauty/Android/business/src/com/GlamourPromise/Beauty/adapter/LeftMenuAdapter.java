package com.GlamourPromise.Beauty.adapter;
import java.util.List;
import java.util.Map;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.Bitmap.Config;
import android.graphics.drawable.BitmapDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;

public class LeftMenuAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<Map<String, Object>> menuMap;
	private UserInfoApplication userInfo;
	public LeftMenuAdapter(Context context, List<Map<String, Object>> menuMap) {
		this.mContext = context;
		this.menuMap = menuMap;
		userInfo = UserInfoApplication.getInstance();
		layoutInflater = LayoutInflater.from(mContext);
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return menuMap.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		MenuItem menuItem = null;
		if (convertView == null) {
			menuItem = new MenuItem();
			convertView = layoutInflater.inflate(R.xml.left_menu_list_item, null);
			menuItem.menuIcon = (ImageView) convertView
					.findViewById(R.id.left_menu_icon);
			menuItem.menuText = (TextView) convertView
					.findViewById(R.id.left_menu_text);
			menuItem.newMessageCount = (ImageView) convertView
					.findViewById(R.id.left_menu_new_message_count);
			convertView.setTag(menuItem);
		} else {
			menuItem = (MenuItem) convertView.getTag();
		}
		int menuIcon = (Integer) (menuMap.get(position).get("menu_icon"));
		menuItem.menuIcon.setBackgroundResource(menuIcon);
		menuItem.menuText.setText((String) menuMap.get(position).get(
				"menu_text"));
		//设置新消息数字
		String menuText = (String) menuMap.get(position).get("menu_text");
		menuItem.newMessageCount.setVisibility(View.GONE);
		if(menuText.equals("飞语")){
			if(userInfo.getAccountNewMessageCount() > 0){
				menuItem.newMessageCount.setVisibility(View.VISIBLE);
				Bitmap bitmapNewMessageCount = ((BitmapDrawable)mContext.getResources()
						.getDrawable(R.drawable.new_message_count_menu))
						.getBitmap();
				if(userInfo.getAccountNewMessageCount()<100)
					bitmapNewMessageCount = generatorUnreadMessageCountIcon(bitmapNewMessageCount,String.valueOf(userInfo.getAccountNewMessageCount()));
				else
					bitmapNewMessageCount = generatorUnreadMessageCountIcon(bitmapNewMessageCount,"N");
				menuItem.newMessageCount.setImageBitmap(bitmapNewMessageCount);
			}
			else
				menuItem.newMessageCount.setVisibility(View.GONE);
		}
		if(menuText.equals("提醒")){
			if(userInfo.getAccountNewRemindCount() > 0){
				menuItem.newMessageCount.setVisibility(View.VISIBLE);
				Bitmap bitmapRemindCount = ((BitmapDrawable)mContext.getResources()
						.getDrawable(R.drawable.new_message_count_menu))
						.getBitmap();
				if(userInfo.getAccountNewRemindCount()<100)
					bitmapRemindCount = generatorUnreadMessageCountIcon(bitmapRemindCount,String.valueOf(userInfo.getAccountNewRemindCount()));
				else
					bitmapRemindCount = generatorUnreadMessageCountIcon(bitmapRemindCount,"N");
				menuItem.newMessageCount.setImageBitmap(bitmapRemindCount);
			}
			else
				menuItem.newMessageCount.setVisibility(View.GONE);
		}
		return convertView;
	}
	private Bitmap generatorUnreadMessageCountIcon(Bitmap icon, String count) {
		Bitmap contactIcon = Bitmap.createBitmap(icon.getWidth(),
				icon.getHeight(), Config.ARGB_8888);
		Canvas canvas = new Canvas(contactIcon);
		Paint iconPaint = new Paint();
		iconPaint.setDither(true);
		iconPaint.setFilterBitmap(true);
		Rect src = new Rect(0, 5, icon.getWidth(), icon.getHeight());
		Rect dst = new Rect(0, 5, icon.getWidth(), icon.getHeight());
		canvas.drawBitmap(icon, src, dst, iconPaint);
		Paint countPaint = new Paint(Paint.ANTI_ALIAS_FLAG
				| Paint.DEV_KERN_TEXT_FLAG);
		countPaint.setColor(Color.WHITE);
		int screenWidth=userInfo.getScreenWidth();
		if(screenWidth==1536)
			countPaint.setTextSize(35f);
		else if(screenWidth==480)
			countPaint.setTextSize(14f);
		else if(screenWidth==720 || screenWidth==540)
			countPaint.setTextSize(20f);
		else if(screenWidth==1080)
			countPaint.setTextSize(25f);
		else
			countPaint.setTextSize(20f);
		countPaint.setTypeface(Typeface.DEFAULT_BOLD);
		if (count.length()==1) {
			canvas.drawText(String.valueOf(count), (int)(icon.getHeight() /2.4),
					icon.getWidth() /2, countPaint);
		} else {
			canvas.drawText(String.valueOf(count), icon.getHeight() / 3,
					icon.getWidth() /2, countPaint);
		}

		return contactIcon;
	}
	public final class MenuItem {
		public ImageView menuIcon;
		public TextView menuText;
		public ImageView newMessageCount;
	}
}
