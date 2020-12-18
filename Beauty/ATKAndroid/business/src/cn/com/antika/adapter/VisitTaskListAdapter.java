package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.TextView;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;

import cn.com.antika.bean.AppointmentInfo;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class VisitTaskListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<AppointmentInfo> visitTaskList;
	public VisitTaskListAdapter(Context context, List<AppointmentInfo> visitTaskList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.visitTaskList = visitTaskList;
	}

	@Override
	public int getCount() {
		return visitTaskList.size();
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
		TaskItem taskItem = null;
		if (convertView == null) {
			taskItem = new TaskItem();
			convertView = layoutInflater.inflate(R.xml.visit_task_list_item, null);
			taskItem.taskItemStatusBtn=(Button)convertView.findViewById(R.id.task_item_status_btn);
			taskItem.taskItemTypeText=(TextView)convertView.findViewById(R.id.task_item_type_text);
			taskItem.taskItemTime=(TextView)convertView.findViewById(R.id.task_item_time);
			taskItem.taskItemProductName=(TextView)convertView.findViewById(R.id.task_item_product_name);
			taskItem.taskItemCustomer=(TextView)convertView.findViewById(R.id.task_item_customer);
			convertView.setTag(taskItem);
		} else {
			taskItem = (TaskItem) convertView.getTag();
		}
		//已完成
		if(visitTaskList.get(position).getTaskStatus()==3)
			taskItem.taskItemStatusBtn.setBackgroundColor(Color.parseColor("#3EBEFF"));
		//待回访
		else if(visitTaskList.get(position).getTaskStatus()==2)
			taskItem.taskItemStatusBtn.setBackgroundColor(Color.parseColor("#E96800"));
		taskItem.taskItemStatusBtn.setText(getVistTaskStatus(visitTaskList.get(position).getTaskStatus()));
		if(visitTaskList.get(position).getTaskStatus()==2)
			taskItem.taskItemTime.setTextColor(mContext.getResources().getColor(R.color.gray));
		else if(visitTaskList.get(position).getTaskStatus()==3)
			taskItem.taskItemTime.setTextColor(mContext.getResources().getColor(R.color.black));
		taskItem.taskItemTime.setText(setSimpleDateFormat(visitTaskList.get(position).getTaskScdlStartTime()));
		taskItem.taskItemProductName.setText(visitTaskList.get(position).getTaskName());
		taskItem.taskItemTypeText.setText(getTaskType(visitTaskList.get(position).getTaskType()));
		taskItem.taskItemCustomer.setText(visitTaskList.get(position).getCustomerName());
		return convertView;
	}
	
	public String getTaskType(int taskType) {
		String taskTypeString = "未知";
		switch (taskType) {
		case 2:
			taskTypeString = "订单";
			break;
		case 4:
			taskTypeString = "生日";
			break;
		}
		return taskTypeString;
	}
	
	public String getVistTaskStatus(int taskStatus) {
		String taskStatusString = "";
		switch (taskStatus) {
		case 2:
			taskStatusString = "待回访";
			break;
		case 3:
			taskStatusString = "已完成";
			break;
		}
		return taskStatusString;
	}
	public final class   TaskItem {
		public Button   taskItemStatusBtn;
		public TextView taskItemTypeText;
		public TextView taskItemTime;
		public TextView taskItemCustomer;
		public TextView taskItemProductName;
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
