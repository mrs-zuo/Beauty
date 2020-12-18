package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.Customer;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class ChoosePersonLeftAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<Customer> servicePersonList;
	private int            selectedPosition=-1;
	public ChoosePersonLeftAdapter(Context context,List<Customer> servicePersonList) {
		this.mContext = context;
		this.servicePersonList =servicePersonList;
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
	public void setSelectedPosition(int selectedPosition)
	{
		this.selectedPosition=selectedPosition;
	}
	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		ServicePersonItem servicePersonItem = null;
		if (convertView == null) {
			servicePersonItem = new ServicePersonItem();
			convertView = layoutInflater.inflate(R.xml.choose_person_left_list_item,null);
			servicePersonItem.servicePersonCheck = (ImageButton) convertView.findViewById(R.id.choose_person_select);
			servicePersonItem.servicePersonNameText = (TextView) convertView.findViewById(R.id.person_name_text);
			convertView.setTag(servicePersonItem);
		} else {
			servicePersonItem = (ServicePersonItem) convertView.getTag();
		}
		servicePersonItem.servicePersonNameText.setText(servicePersonList.get(position).getCustomerName());
		if(position==selectedPosition)
			servicePersonItem.servicePersonCheck.setBackgroundResource(R.drawable.select_btn);
		else
			servicePersonItem.servicePersonCheck.setBackgroundResource(R.drawable.no_select_btn);
		return convertView;
	}

	public final class ServicePersonItem {
		public ImageButton  servicePersonCheck;
		public TextView servicePersonNameText;
	}
}
