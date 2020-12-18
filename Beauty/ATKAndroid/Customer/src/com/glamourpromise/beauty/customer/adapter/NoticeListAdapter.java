package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.NoticeInformation;
public  class NoticeListAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<NoticeInformation> noticelistMap;
	public NoticeListAdapter(Context context,List<NoticeInformation> noticelistMap)
	{
		this.mContext=context;
		this.noticelistMap=noticelistMap;
		layoutInflater=LayoutInflater.from(mContext);
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return noticelistMap.size();
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
		NoticeItem noticeItem=null;
		if(convertView==null)
		{
			noticeItem=new NoticeItem();
			convertView=layoutInflater.inflate(R.xml.notice_list_item,null);
			noticeItem.noticetitle=(TextView)convertView.findViewById(R.id.noticelist_title);
			noticeItem.createtime=(TextView)convertView.findViewById(R.id.noticelist_createtime);
			convertView.setTag(noticeItem);
		}
		else
		{
			noticeItem=(NoticeItem)convertView.getTag();
		}
		noticeItem.noticetitle.setText((String)noticelistMap.get(position).getNoticeTitle());
		
		String time = (String)noticelistMap.get(position).getNoticeStartTime() + "~" +(String)noticelistMap.get(position).getNoticeEndTime();
		noticeItem.createtime.setText(time);
		return convertView;
	}
	public final class NoticeItem
	{
		public TextView noticetitle;
		public TextView  createtime;
	}
	
}
