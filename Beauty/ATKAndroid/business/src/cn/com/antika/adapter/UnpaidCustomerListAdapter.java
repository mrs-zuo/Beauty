package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.UnpaidCustomerInfo;
import cn.com.antika.business.R;

/*
 * author:zts
 * */

@SuppressLint("ResourceType")
public class UnpaidCustomerListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context 	   mContext;
	private List<UnpaidCustomerInfo> unpaidCustomerInfoList;
	public UnpaidCustomerListAdapter(Context context,List<UnpaidCustomerInfo> unpaidCustomerInfoList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.unpaidCustomerInfoList =unpaidCustomerInfoList;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return unpaidCustomerInfoList.size();
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
		UnpaidCustomerItem unpaidCustomerItem = null;
		if (convertView == null) {
			unpaidCustomerItem = new UnpaidCustomerItem();
			convertView = layoutInflater.inflate(R.xml.unpaid_customer_list_item, null);
			unpaidCustomerItem.unpaidCustomerNameText = (TextView) convertView.findViewById(R.id.unpaid_customer_name_text);
			unpaidCustomerItem.unpaidCustomerLoginMobileText = (TextView) convertView.findViewById(R.id.unpaid_customer_login_mobile_text);
			unpaidCustomerItem.unpaidCustomerOrderCountText=(TextView)convertView.findViewById(R.id.unpaid_customer_order_count_text);
			convertView.setTag(unpaidCustomerItem);
		} else {
			unpaidCustomerItem =(UnpaidCustomerItem) convertView.getTag();
		}
		unpaidCustomerItem.unpaidCustomerNameText.setText(unpaidCustomerInfoList.get(position).getCustomerName());
		unpaidCustomerItem.unpaidCustomerOrderCountText.setText(unpaidCustomerInfoList.get(position).getUnPaidOrderCount()+"笔待支付");
		unpaidCustomerItem.unpaidCustomerLoginMobileText.setText(unpaidCustomerInfoList.get(position).getCustomerLoginMobileShow());
		return convertView;
	}
	public final class UnpaidCustomerItem{
		public TextView unpaidCustomerNameText;
		public TextView unpaidCustomerLoginMobileText;
		public TextView unpaidCustomerOrderCountText;
	}
}
