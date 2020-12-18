package com.GlamourPromise.Beauty.adapter;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.EmarketingInfo;
import com.GlamourPromise.Beauty.util.DateUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
/*
 * author:zts
 * */
public class EMarketingItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context        context;
	private List<EmarketingInfo> emarketingInfoList;
	public EMarketingItemAdapter(Context context, List<EmarketingInfo> emarketingInfoList) {
		this.context = context;
		layoutInflater = (LayoutInflater)this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);  
        this.emarketingInfoList=emarketingInfoList;
	}

	@Override
	public int getCount() {
		return emarketingInfoList.size();
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
		EMarketingItem emarketingItem = null;
		if (convertView == null) {
			emarketingItem = new EMarketingItem();
			convertView = layoutInflater
					.inflate(R.xml.emarketing_list_item, null);
			emarketingItem.toUserNameText = (TextView) convertView
					.findViewById(R.id.to_user_name);
			emarketingItem.fromUserNameText = (TextView) convertView
					.findViewById(R.id.from_user_name);
			emarketingItem.sendTimeText = (TextView) convertView
					.findViewById(R.id.send_time);
			emarketingItem.messageContentText = (TextView) convertView
					.findViewById(R.id.message_content);
			emarketingItem.sendStatusText = (TextView) convertView
					.findViewById(R.id.send_status);
			convertView.setTag(emarketingItem);
		} else {
			emarketingItem = (EMarketingItem) convertView.getTag();
		}
		String toUserName=emarketingInfoList.get(position).getToUserName();
		String[] toUserNameArray=toUserName.split(",");
		int  toUserNum=toUserNameArray.length;
		if(toUserNum>1)
		{
			emarketingItem.toUserNameText.setText("接收人："+toUserNameArray[0]+","+toUserNameArray[1]+"等"+toUserNum+"人");
		}
		else if(toUserNum==1)
		{
			emarketingItem.toUserNameText.setText("接收人："+toUserNameArray[0]);
		}
		emarketingItem.fromUserNameText.setText("发送人："+emarketingInfoList.get(position).getFromUserName());
		emarketingItem.sendTimeText.setText(emarketingInfoList.get(position).getSendTime());
		emarketingItem.messageContentText.setText(emarketingInfoList.get(position).getMessageContent());
		emarketingItem.sendStatusText.setText("已接收"+emarketingInfoList.get(position).getReceiveCount()+"人/"+"发送"+emarketingInfoList.get(position).getSendCount()+"人");
		return convertView;
	}

	public final class EMarketingItem {
		public TextView toUserNameText;
		public TextView fromUserNameText;
		public TextView sendTimeText;
		public TextView messageContentText;
		public TextView sendStatusText;
	}
}
