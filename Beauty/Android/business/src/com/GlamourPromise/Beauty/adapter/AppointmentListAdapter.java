package com.GlamourPromise.Beauty.adapter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.AppointmentInfo;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;


public class AppointmentListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<AppointmentInfo> appointmentInfoList;
	private String fromSource;
	public AppointmentListAdapter(Context context, List<AppointmentInfo> appointmentInfoList,String fromSource) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.appointmentInfoList = appointmentInfoList;
		this.fromSource=fromSource;
	}

	@Override
	public int getCount() {
		return appointmentInfoList.size();
	}

	@Override
	public Object getItem(int position) {
		return null;
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		OrderItem orderItem = null;
		if (convertView == null) {
			orderItem = new OrderItem();
			if(fromSource.equals("MENU_RIGHT")){
				convertView = layoutInflater.inflate(R.xml.appointment_customer_list_item, null);
				orderItem.appointmentItemDesignatedResponsiblePerson=(TextView) convertView.findViewById(R.id.appointment_item_designated_responsible_person);
			}else{
				convertView = layoutInflater.inflate(R.xml.appointment_task_list_item, null);
			}
			orderItem.appointmentItemTime = (TextView) convertView.findViewById(R.id.appointment_item_time);
			orderItem.appointmentItemCustomer = (TextView) convertView.findViewById(R.id.appointment_item_customer);
			if(fromSource.equals("MENU_RIGHT")){
				orderItem.appointmentItemStatus = (TextView) convertView.findViewById(R.id.appointment_item_status);
			}
			orderItem.appointmentItemOrderProductName=(TextView)convertView.findViewById(R.id.appointment_item_order_product_name);
			convertView.setTag(orderItem);
		} else {
			orderItem = (OrderItem) convertView.getTag();
		}
		orderItem.appointmentItemTime.setText(setSimpleDateFormat(appointmentInfoList.get(position).getTaskScdlStartTime()));
		orderItem.appointmentItemCustomer.setText(appointmentInfoList.get(position).getCustomerName());
		if(fromSource.equals("MENU_RIGHT")){
			if(appointmentInfoList.get(position).getResponsiblePersonID()>0){
				orderItem.appointmentItemDesignatedResponsiblePerson.setText(appointmentInfoList.get(position).getResponsiblePersonName());
			}else{
				orderItem.appointmentItemDesignatedResponsiblePerson.setText("到店指定");
			}
			orderItem.appointmentItemStatus.setText(getTaskStatus(appointmentInfoList.get(position).getTaskStatus()));
		}
		/*else{
			orderItem.appointmentItemStatus.setText(getTaskType(appointmentInfoList.get(position).getTaskType()));
		}*/
		orderItem.appointmentItemOrderProductName.setText(appointmentInfoList.get(position).getTaskName());
		return convertView;
	}
	
	public String getTaskType(int taskType) {
		String taskTypeString = "未知状态";
		switch (taskType) {
		case 1:
			taskTypeString = "服务预约";
			break;
		case 2:
			taskTypeString = "订单回访";
			break;
		case 4:
			taskTypeString = "生日回访";
			break;
		}
		return taskTypeString;
	}
	
	public String getTaskStatus(int taskStatus) {
		String taskStatusString = "未知状态";
		switch (taskStatus) {
		case 1:
			taskStatusString = "待确认";
			break;
		case 2:
			taskStatusString = "已确认";
			break;
		case 3:
			taskStatusString = "已开单";
			break;
		case 4:
			taskStatusString = "已取消";
			break;
		}
		return taskStatusString;
	}
	public final class OrderItem {
		public TextView appointmentItemTime;
		public TextView appointmentItemCustomer;
		public TextView appointmentItemStatus;
		public TextView appointmentItemDesignatedResponsiblePerson;
		public TextView appointmentItemOrderProductName;
	}
	private String setSimpleDateFormat(String dataString){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		SimpleDateFormat newSdf=new SimpleDateFormat("yyyy-MM-dd HH:mm");
		try {
			dataString=newSdf.format(sdf.parse(dataString));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return dataString;
	}
}
