package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.CustomerStatistics;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class CustomerStatisticsListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<CustomerStatistics> customerStatisticsList;
	private int    mObjectType;
	public CustomerStatisticsListAdapter(Context context,List<CustomerStatistics> customerStatisticsList,int objectType) {
		this.mContext = context;
		this.customerStatisticsList = customerStatisticsList;
		layoutInflater = LayoutInflater.from(mContext);
		this.mObjectType=objectType;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return customerStatisticsList.size();
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
		CustomerStatisticsListItem csItem = null;
		if (convertView == null) {
			csItem = new CustomerStatisticsListItem();
			convertView = layoutInflater.inflate(R.xml.report_detail_list_item, null);
			csItem.objectName = (TextView) convertView.findViewById(R.id.report_detail_list_object_name);
			csItem.objectCount = (TextView) convertView.findViewById(R.id.report_detail_list_sales_amount);
			convertView.setTag(csItem);
		} else {
			csItem = (CustomerStatisticsListItem) convertView.getTag();
		}
		//csItem.objectName.setTextColor(mContext.getResources().getColor(R.color.black));
		csItem.objectName.setText(position+1+"    "+customerStatisticsList.get(position).getObjectName());
		if(mObjectType==0)
			csItem.objectCount.setText(customerStatisticsList.get(position).getObjectCount()+"次");
		if(mObjectType==1)
			csItem.objectCount.setText(customerStatisticsList.get(position).getObjectCount()+"件");
		return convertView;
	}

	public final class CustomerStatisticsListItem {
		public TextView objectName;
		public TextView objectCount;
	}

}
