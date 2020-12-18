package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EcardHistoryOrderListAdapter extends BaseAdapter {

	private LayoutInflater layoutInflater;
	private Activity mContext;
	private List<OrderBaseInfo> orderList;
	public EcardHistoryOrderListAdapter(Activity context, List<OrderBaseInfo> orderList) {
		this.mContext = context;
		this.orderList = orderList;
		layoutInflater = LayoutInflater.from(mContext);
	}
	
	public EcardHistoryOrderListAdapter(Activity context, List<OrderBaseInfo> orderList, Boolean isOnClick) {
		this.mContext = context;
		this.orderList = orderList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return orderList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		// return null;
		return orderList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		OrderItem orderItem = null;
		if (convertView == null) {
			orderItem = new OrderItem();
			convertView = layoutInflater.inflate(R.xml.ecard_history_order_list_item, null);
			orderItem.orderTime = (TextView) convertView
					.findViewById(R.id.order_time_text);
			orderItem.orderResponsiblePersonName = (TextView) convertView
					.findViewById(R.id.order_responsible_person_name);
			orderItem.orderStatus = (TextView) convertView
					.findViewById(R.id.order_status);
			orderItem.productName = (TextView) convertView
					.findViewById(R.id.order_product_name_text);
			orderItem.productCount = (TextView) convertView
					.findViewById(R.id.order_product_count);
			orderItem.productPrice = (TextView) convertView
					.findViewById(R.id.order_price);

			convertView.setTag(orderItem);
		} else {
			orderItem = (OrderItem) convertView.getTag();
		}
		
		orderItem.orderTime.setText((String) orderList.get(position)
				.getOrderTime());
		orderItem.productName.setText((String) orderList.get(position)
				.getProductName());
		orderItem.productCount.setText("X"
				+ orderList.get(position).getQuantity());
		if (orderList.get(position).getQuantity().equals("")) {
			orderItem.productCount.setText("X0");
		}
		orderItem.productPrice.setText(NumberFormatUtil
				.StringFormatToString(mContext, orderList.get(position)
						.getTotalSalePrice()));
		orderItem.orderResponsiblePersonName.setText(orderList.get(position)
				.getResponsiblePersonName());

		String orderStatus = "";
		if (orderList.get(position).getOrderStatus().equals("0")) {

			if (orderList.get(position).getPaymentStatus()==0) {
				orderStatus = mContext.getString(R.string.order_status_1) + "|"
						+ mContext.getString(R.string.order_ispaid_1);
			} else {
				orderStatus = mContext.getString(R.string.order_status_1) + "|"
						+ mContext.getString(R.string.order_ispaid_2);
			}
		} else if (orderList.get(position).getOrderStatus().equals("1")) {
			if (orderList.get(position).getPaymentStatus()==0) {
				orderStatus = mContext.getString(R.string.order_status_2) + "|"
						+ mContext.getString(R.string.order_ispaid_1);
			} else {
				orderStatus = mContext.getString(R.string.order_status_2) + "|"
						+ mContext.getString(R.string.order_ispaid_2);
			}
		} else if (orderList.get(position).getOrderStatus().equals("2")) {
			if (orderList.get(position).getPaymentStatus()==0) {
				orderStatus = mContext.getString(R.string.order_status_3) + "|"
						+ mContext.getString(R.string.order_ispaid_1);
			} else {
				orderStatus = mContext.getString(R.string.order_status_3) + "|"
						+ mContext.getString(R.string.order_ispaid_2);
			}
		}
		//待确认
		else{
			if (orderList.get(position).getPaymentStatus()==0) {
				orderStatus = mContext.getString(R.string.order_status_1) + "|"
						+ mContext.getString(R.string.order_ispaid_1);
			} else {
				orderStatus = mContext.getString(R.string.order_status_1) + "|"
						+ mContext.getString(R.string.order_ispaid_2);
			}
		}
		orderItem.orderStatus.setText(orderStatus);

		return convertView;
	}

	public final class OrderItem {
		public TextView orderTime;
		public TextView orderResponsiblePersonName;
		public TextView orderStatus;
		public TextView productName;
		public TextView productCount;
		public TextView productQuantity;
		public TextView productPrice;
	}
}
