package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

import cn.com.antika.bean.Customer;
import cn.com.antika.bean.PersonSchedule;
import cn.com.antika.business.R;
import cn.com.antika.util.BitmapUtils;

@SuppressLint("ResourceType")
public class PersonScheduleItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<Customer> servicePersonList;

	public PersonScheduleItemAdapter(Context context,
			List<Customer> servicePersonList) {
		this.mContext = context;
		this.servicePersonList = servicePersonList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return servicePersonList.size();
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
		PersonScheduleItem psesonScheduleItem = null;
		if (convertView == null) {
			psesonScheduleItem = new PersonScheduleItem();
			convertView = layoutInflater.inflate(R.xml.person_schedule_item,null);
			psesonScheduleItem.personScheduleLinearLayout = (LinearLayout) convertView.findViewById(R.id.person_schedule_linearlayout);
			convertView.setTag(psesonScheduleItem);
		} else {
			psesonScheduleItem = (PersonScheduleItem) convertView.getTag();
		}
		if (psesonScheduleItem.personScheduleLinearLayout.getChildCount() == 0) {
			List<PersonSchedule> personScheduleList = servicePersonList.get(position).getPersonScheduleList();
			
				for (int i = 0; i < 24; i++) {
					ImageView timeLinePointImage = new ImageView(mContext);
					for (PersonSchedule personSchedule : personScheduleList) {
						//预约从什么小时开始
						int startHour=0;
						//预约从什么分钟开始
						int startMinutes=0;
						int endHour=0;
						int endMinutes=0;
						try {
							startHour=new SimpleDateFormat("yyyy-MM-dd HH:mm").parse(personSchedule.getScdlStartTime()).getHours();
							startMinutes= new SimpleDateFormat("yyyy-MM-dd HH:mm").parse(personSchedule.getScdlStartTime()).getMinutes();
							endHour=new SimpleDateFormat("yyyy-MM-dd HH:mm").parse(personSchedule.getScdlEndTime()).getHours();
				            endMinutes=new SimpleDateFormat("yyyy-MM-dd HH:mm").parse(personSchedule.getScdlEndTime()).getMinutes();
						} catch (ParseException e) {
						}
						Bitmap bitMap = ((BitmapDrawable) mContext.getResources().getDrawable(R.drawable.time_line_point)).getBitmap();
						bitMap = BitmapUtils.personUsedSchedule(bitMap,startHour,startMinutes,endHour,endMinutes,i);
						timeLinePointImage.setImageBitmap(bitMap);
					}
					timeLinePointImage.setBackgroundResource(R.drawable.time_line_point);
					psesonScheduleItem.personScheduleLinearLayout.addView(timeLinePointImage);
				}		
		}
		return convertView;
	}

	public final class PersonScheduleItem {
		public LinearLayout personScheduleLinearLayout;
	}
}
