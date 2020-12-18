package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.NoticeInfo;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class NoticeListAdapter extends BaseAdapter{
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<NoticeInfo> noticelist;
	private StringBuilder timeBuilder;
	
	public NoticeListAdapter(Context context,List<NoticeInfo> noticelist)
	{
		this.mContext=context;
		this.noticelist=noticelist;
		layoutInflater=LayoutInflater.from(mContext);
		timeBuilder = new StringBuilder();
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return noticelist.size();
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int arg0) {
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
		noticeItem.noticetitle.setText((String)noticelist.get(position).getNoticeTitle());
		
		timeBuilder.delete(0, timeBuilder.length());
		timeBuilder.append(noticelist.get(position).getNoticeStartTime());
		timeBuilder.append("~");
		timeBuilder.append(noticelist.get(position).getNoticeEndTime());
		noticeItem.createtime.setText(timeBuilder);
		return convertView;
	}

	public final class NoticeItem
	{
		public TextView noticetitle;
		public TextView  createtime;
	}
}
