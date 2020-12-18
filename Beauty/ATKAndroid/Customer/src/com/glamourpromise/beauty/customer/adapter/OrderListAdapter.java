package com.glamourpromise.beauty.customer.adapter;

import java.io.Serializable;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.CommodityOrderDetailActivity;
import com.glamourpromise.beauty.customer.activity.ServcieOrderDetailActivity;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.util.StatusUtil;

public class OrderListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Activity mContext;
	private List<OrderBaseInfo> orderList;
	private Boolean mIsOnClick;
	public OrderListAdapter(Activity context, List<OrderBaseInfo> orderList) {
		this.mContext = context;
		this.orderList = orderList;
		layoutInflater = LayoutInflater.from(context);
	}
	@Override
	public int getCount() {
		return orderList.size();
	}

	@Override
	public Object getItem(int position) {
		return orderList.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		OrderListItem orderItem = null;
		if (convertView == null) {
			orderItem = new OrderListItem();
			convertView = layoutInflater.inflate(R.xml.order_list_item, null);
			orderItem.orderDetailBtn = (TableLayout) convertView.findViewById(R.id.order_list_item_to_order_detail_table_layout_btn);
			orderItem.orderTime = (TextView) convertView.findViewById(R.id.order_list_item_left_child_cell_order_time_text);
			orderItem.productName = (TextView) convertView.findViewById(R.id.order_list_item_left_child_cell_product_name_text);
			orderItem.productPrice = (TextView) convertView.findViewById(R.id.order_list_item_left_child_cell_order_price);
			orderItem.orderResponsiblePersonName = (TextView) convertView.findViewById(R.id.order_list_item_right_child_cell_responsible_person_name);
			orderItem.productCount = (TextView) convertView.findViewById(R.id.order_list_item_right_child_cell_order_product_count);
			orderItem.orderStatus = (TextView) convertView.findViewById(R.id.order_list_item_right_child_cell_order_status);

			convertView.setTag(orderItem);
		} else {
			orderItem = (OrderListItem) convertView.getTag();
		}
		orderItem.orderTime.setText(orderList.get(position).getOrderTime());
		orderItem.productName.setText(orderList.get(position).getProductName());
		StringBuilder tmp = new StringBuilder();
		if (orderList.get(position).getQuantity().equals("")) {
			orderItem.productCount.setText("X0");
		} else {
			tmp.append("X");
			tmp.append(orderList.get(position).getQuantity());
			orderItem.productCount.setText(tmp.toString());
		}
		orderItem.productPrice.setText(NumberFormatUtil.StringFormatToString(mContext, orderList.get(position).getTotalSalePrice()));
		orderItem.orderResponsiblePersonName.setText(orderList.get(position).getResponsiblePersonName());

		orderItem.orderStatus.setText(StatusUtil.OrderAndPaymentStatusTextUtil(mContext, orderList.get(position).getOrderStatus(), orderList.get(position).getPaymentStatus()));

		final int finalPosition = position;
		orderItem.orderDetailBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent destIntent = null;

				if (orderList.get(finalPosition).getProductType().equals("1")) {
					destIntent = new Intent(mContext,CommodityOrderDetailActivity.class);

				} else if (orderList.get(finalPosition).getProductType().equals("0")) {
					destIntent = new Intent(mContext,ServcieOrderDetailActivity.class);
				}
				Bundle mBundle = new Bundle();
				mBundle.putSerializable("OrderItem",(Serializable) orderList.get(finalPosition));
				destIntent.putExtras(mBundle);
				mContext.startActivity(destIntent);
			}
		});
		return convertView;
	}

	public class OrderListItem {
		public TableLayout orderDetailBtn;
		public TextView orderTime;
		public TextView productName;
		public TextView productPrice;
		public TextView orderResponsiblePersonName;
		public TextView productCount;
		public TextView orderStatus;
	}

}
