package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.RemindInformation;
import com.glamourpromise.beauty.customer.util.DateUtil;
import com.glamourpromise.beauty.customer.util.StringFormatTranslate;
import com.glamourpromise.beauty.customer.util.TextViewWithHtmlTagHandler;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Html.ImageGetter;
import android.text.method.LinkMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
public  class RemindListAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<RemindInformation> RemindList;
	public RemindListAdapter(Context context,List<RemindInformation> RemindList)
	{
		this.mContext=context;
		this.RemindList=RemindList;
		layoutInflater=LayoutInflater.from(mContext);
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return RemindList.size();
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
		NoticeItem remindItem=null;
		if(convertView==null)
		{
			remindItem=new NoticeItem();
			convertView=layoutInflater.inflate(R.xml.remind_list_item,null);
			remindItem.contentView=(TextView)convertView.findViewById(R.id.remind_content);
			convertView.setTag(remindItem);
		}
		else
		{
			remindItem=(NoticeItem)convertView.getTag();
		}
		
		ImageGetter imageGetter = new ImageGetter() {
			@Override
			public Drawable getDrawable(String source) {
				int id = Integer.parseInt(source);
				Drawable drawable = mContext.getResources().getDrawable(id);
				drawable.setBounds(0, 0, drawable.getIntrinsicWidth(),drawable.getIntrinsicHeight());
				return drawable;
			}
		};
		TextViewWithHtmlTagHandler textViewWithHtmlTagHandler = new TextViewWithHtmlTagHandler(mContext, RemindList.get(position));
		StringBuffer remindContent = new StringBuffer();
		remindContent.append("<font color=\"#717171\">");
		remindContent.append(mContext.getString(R.string.remind_string_1));
		remindContent.append("</font>");
		
		remindContent.append("<font color=\"#c30d23\">");
		remindContent.append(DateUtil.getFormateDateByString2(RemindList.get(position).getScheduleTime()));
		remindContent.append("</font>");
		
		remindContent.append("<font color=\"#717171\">");
		remindContent.append(mContext.getString(R.string.remind_string_2));
		remindContent.append("</font>");
		
		remindContent.append("<font color=\"#c30d23\">");
		remindContent.append(RemindList.get(position).getBranchName());
		remindContent.append("</font>");
		
		remindContent.append("<font color=\"#717171\">");
		remindContent.append(mContext.getString(R.string.remind_string_3));
		remindContent.append("</font>");
		
		remindContent.append("<font color=\"#c30d23\">");
		remindContent.append(RemindList.get(position).getServiceName());
		remindContent.append("</font>"+"<font color=\"#717171\">服务。</font>");
		if(!RemindList.get(position).getBranchPhone().equals("") || !RemindList.get(position).getResponserPerson().equals("")){
			remindContent.append("<font color=\"#717171\">");
			remindContent.append("如有疑问，");
			remindContent.append("</font>");
		}	
		if(!RemindList.get(position).getBranchPhone().equals("")){
			remindContent.append("<font color=\"#717171\">");
			remindContent.append("请拨打门店咨询电话");
			remindContent.append("</font>");
			
			remindContent.append(" <font color=\"#c30d23\">");
			remindContent.append(RemindList.get(position).getBranchPhone());
			remindContent.append("</font>");
			if(!RemindList.get(position).getResponserPerson().equals("")){
				remindContent.append("<font color=\"#717171\">"+mContext.getString(R.string.remind_string_6)+"</font>");
				remindContent.append("(<font color=\"#c30d23\">");
				remindContent.append(RemindList.get(position).getResponserPerson());
				remindContent.append("</font>");
				remindContent.append(" <img src='");
				remindContent.append(R.drawable.remind_feiyu_responser_person_icon);
				remindContent.append("'/>");
				remindContent.append(")");
			}
		}
		else{
			if(!RemindList.get(position).getResponserPerson().equals("")){
				remindContent.append("<font color=\"#717171\">");
				remindContent.append("请联系服务顾问");
				remindContent.append("</font>");
				remindContent.append("(<font color=\"#c30d23\">");
				remindContent.append(RemindList.get(position).getResponserPerson());
				remindContent.append("</font>");
				remindContent.append(" <img src='");
				remindContent.append(R.drawable.remind_feiyu_responser_person_icon);
				remindContent.append("'/> ");
				remindContent.append(")");
			}
		}
		if(!RemindList.get(position).getBranchPhone().equals("") || !RemindList.get(position).getResponserPerson().equals(""))
			remindContent.append(" 。");
		remindItem.contentView.setMovementMethod(LinkMovementMethod.getInstance());
		remindItem.contentView.setText(Html.fromHtml(StringFormatTranslate.ToDBC(remindContent.toString()), imageGetter, textViewWithHtmlTagHandler));
		return convertView;
	}
	public final class NoticeItem
	{
		public TextView  contentView;
	}
	
}
