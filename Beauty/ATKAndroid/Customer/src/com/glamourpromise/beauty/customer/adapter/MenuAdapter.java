package com.glamourpromise.beauty.customer.adapter;
import java.util.List;

import android.content.Context;
import android.text.Html;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.MenuInformation;
public class MenuAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<MenuInformation> menuMap;
	public MenuAdapter(Context context,List<MenuInformation> menuMap)
	{
		this.mContext=context;
		this.menuMap=menuMap;
		layoutInflater=LayoutInflater.from(mContext);
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
		menuItem menuItem=null;
		if(convertView==null)
		{
			menuItem=new menuItem();
			convertView=layoutInflater.inflate(R.xml.menu_list_item,null);
			menuItem.menuIcon=(ImageView)convertView.findViewById(R.id.menu_icon);
			menuItem.menuText=(TextView)convertView.findViewById(R.id.menu_text);
			convertView.setTag(menuItem);
		}
		else
		{
			menuItem=(menuItem)convertView.getTag();
		}
		
		menuItem.menuIcon.setBackgroundResource((Integer)(menuMap.get(position).getMenuIcon()));
		menuItem.menuText.setText(Html.fromHtml(menuMap.get(position).getMenuItems()));
		menuItem.menuText.setTextSize(TypedValue.COMPLEX_UNIT_PX, mContext.getResources().getDimension(R.dimen.text_size_normal));
		
		return convertView;
	}
	public final class menuItem
	{
		public ImageView menuIcon;
		public TextView  menuText;
	}
}
