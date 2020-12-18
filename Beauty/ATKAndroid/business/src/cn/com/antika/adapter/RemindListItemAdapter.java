package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.RemindInfo;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class RemindListItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<RemindInfo> remindList;

	public RemindListItemAdapter(Context context, List<RemindInfo> remindList) {
		this.mContext = context;
		this.remindList = remindList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return remindList.size();
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
		RemindItem remindItem = null;
		if (convertView == null) {
			remindItem = new RemindItem();
			convertView = layoutInflater.inflate(R.xml.remind_list_item, null);
			RelativeLayout remindIconRelativeLayou = (RelativeLayout) convertView.findViewById(R.id.remind_icon_relativelayout);
			remindItem.remindServiceIcon = (ImageView) remindIconRelativeLayou.findViewById(R.id.remind_service_icon);
			remindItem.remindBackIcon = (ImageView) remindIconRelativeLayou.findViewById(R.id.remind_back_icon);
			remindItem.remindBirthdayIcon = (ImageView) remindIconRelativeLayou.findViewById(R.id.remind_birthday_icon);
			RelativeLayout remindContentRelativeLayou = (RelativeLayout) convertView.findViewById(R.id.remind_content_relativelayout);
			remindItem.scheduleTimeText = (TextView) remindContentRelativeLayou.findViewById(R.id.remind_schedule_time);
			remindItem.scheduleTypeText = (TextView) remindContentRelativeLayou.findViewById(R.id.remind_schedule_type);
			remindItem.remindContentText = (TextView) remindContentRelativeLayou.findViewById(R.id.remind_content);
			convertView.setTag(remindItem);
		} else {
			remindItem = (RemindItem) convertView.getTag();
		}
		int scheduleType = remindList.get(position).getScheduleType();
		String scheduleTypeStr = "";
		if (scheduleType == 0) {
			remindItem.remindServiceIcon.setVisibility(View.VISIBLE);
			remindItem.remindBackIcon.setVisibility(View.GONE);
			remindItem.remindBirthdayIcon.setVisibility(View.GONE);
			scheduleTypeStr = "服务";
		} else if (scheduleType == 1) {
			remindItem.remindBackIcon.setVisibility(View.VISIBLE);
			remindItem.remindServiceIcon.setVisibility(View.GONE);
			remindItem.remindBirthdayIcon.setVisibility(View.GONE);
			scheduleTypeStr = "回访";
		} else if (scheduleType == 2) {
			remindItem.remindBirthdayIcon.setVisibility(View.VISIBLE);
			remindItem.remindBackIcon.setVisibility(View.GONE);
			remindItem.remindServiceIcon.setVisibility(View.GONE);
			scheduleTypeStr = "生日";
		}
		remindItem.scheduleTimeText.setText(remindList.get(position).getScheduleTime());
		remindItem.scheduleTypeText.setText(scheduleTypeStr);
		remindItem.remindContentText.setText(remindList.get(position).getRemindContent());
		return convertView;
	}

	public final class RemindItem {
		public TextView scheduleTimeText;
		public TextView scheduleTypeText;
		public TextView remindContentText;
		public ImageView remindServiceIcon;
		public ImageView remindBackIcon;
		public ImageView remindBirthdayIcon;
	}
}
