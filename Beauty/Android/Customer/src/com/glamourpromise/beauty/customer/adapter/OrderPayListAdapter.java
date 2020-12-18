package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.CommodityOrderDetailActivity;
import com.glamourpromise.beauty.customer.activity.OrderPayListActivity.ListItemClick;
import com.glamourpromise.beauty.customer.activity.ServcieOrderDetailActivity;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.OrderPayListInfo;
import com.glamourpromise.beauty.customer.bean.TGListInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.util.StatusUtil;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class OrderPayListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Activity mContext;
	private List<OrderPayListInfo> orderList;
	private List<Boolean> itemSelectFlag;
	private ListItemClick listItemClick;
	private int currentSelectCount;
	public OrderPayListAdapter(Activity context,
			List<OrderPayListInfo> orderList, ListItemClick listItemClick) {
		this.mContext = context;
		this.orderList = orderList;
		this.listItemClick = listItemClick;
		currentSelectCount = 0;
		layoutInflater = LayoutInflater.from(mContext);
		itemSelectFlag = new ArrayList<Boolean>();
		for (int i = 0; i < orderList.size(); i++)
			itemSelectFlag.add(false);
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
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		OrderItem orderItem = null;
		if (convertView == null) {
			orderItem = new OrderItem();
			convertView = layoutInflater.inflate(R.xml.order_pay_list_item,null);
			orderItem.relativelayout = (RelativeLayout)convertView.findViewById(R.id.order_pay_list_item_order_pay_list_relativelayout);
			orderItem.orderTime = (TextView) convertView.findViewById(R.id.order_pay_list_item_order_time_text);
			orderItem.productName = (TextView) convertView.findViewById(R.id.order_pay_list_item_order_product_name_text);
			orderItem.isPaid = (TextView) convertView.findViewById(R.id.order_pay_list_item_order_ispaid);
			orderItem.selectView = (ImageButton) convertView.findViewById(R.id.order_pay_list_item_order_item_select);
			orderItem.orderResponsiblePersonName = (TextView) convertView.findViewById(R.id.order_pay_list_item_order_responsible_person_name);
			orderItem.productCount = (TextView) convertView.findViewById(R.id.order_pay_list_item_order_product_count);
			orderItem.productPrice = (TextView) convertView.findViewById(R.id.order_pay_list_item_order_price);
			orderItem.orderDivider = (View) convertView.findViewById(R.id.order_pay_list_item_order_divider);
			orderItem.tglistView = (NoScrollListView) convertView.findViewById(R.id.order_pay_list_item_tg_list_view);
			convertView.setTag(orderItem);
		} else
			orderItem = (OrderItem) convertView.getTag();

		orderItem.orderTime.setText((String) orderList.get(position).getOrderTime());
		orderItem.productName.setText((String) orderList.get(position).getProductName());
		String productPriceResult = String.valueOf((Double.parseDouble(orderList.get(position).getTotalSalePrice()) - Double.parseDouble(orderList.get(position).getUnPayAmount())));
		orderItem.productPrice.setText(NumberFormatUtil.StringFormatToString(mContext, productPriceResult)+ " / "+ NumberFormatUtil.StringFormatToStringWithoutSingle(orderList.get(position).getTotalSalePrice()));
		orderItem.productCount.setText("X"+ orderList.get(position).getQuantity());
		orderItem.orderResponsiblePersonName.setText(orderList.get(position).getResponsiblePersonName());

		if (itemSelectFlag.get(position))
			orderItem.selectView.setBackgroundResource(R.drawable.one_select_icon);
		else
			orderItem.selectView.setBackgroundResource(R.drawable.one_unselect_icon);
		 if(orderList.get(position).getCardID()!=0)
			 orderItem.isPaid.setText(orderList.get(position).getBranchName()+"|"+orderList.get(position).getCardName());
		 else
			 orderItem.isPaid.setText(orderList.get(position).getBranchName());
		orderItem.orderDivider.setVisibility(View.GONE);
		orderItem.tglistView.setVisibility(View.GONE);
		final int finalPosition = position;
		orderItem.selectView.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				if (itemSelectFlag.get(finalPosition)) {
					currentSelectCount--;
					itemSelectFlag.set(finalPosition,false);
					view.setBackgroundResource(R.drawable.one_unselect_icon);
				} else {
					currentSelectCount++;
					itemSelectFlag.set(finalPosition,true);
					view.setBackgroundResource(R.drawable.one_select_icon);
				}
				OrderPayListAdapter.this.notifyDataSetChanged();
				listItemClick.itemOnClick(currentSelectCount);
			}
		});

		orderItem.relativelayout.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				OrderBaseInfo orderItem = new OrderBaseInfo();
				Intent destIntent = new Intent();
				Bundle bundle = new Bundle();
				orderItem.setProductType(String.valueOf(orderList.get(finalPosition).getProductType()));
				orderItem.setOrderID(String.valueOf(orderList.get(finalPosition).getOrderID()));
				orderItem.setOrderObjectID(String.valueOf(orderList.get(finalPosition).getOrderObjectID()));
				orderItem.setTotalSalePrice(orderList.get(finalPosition).getTotalSalePrice());
				if (orderList.get(finalPosition).getProductType() == 0)
					destIntent.setClass(mContext,ServcieOrderDetailActivity.class);
				else
					destIntent.setClass(mContext,CommodityOrderDetailActivity.class);
				bundle.putSerializable("OrderItem", orderItem);
				destIntent.putExtras(bundle);
				mContext.startActivity(destIntent);
			}

		});
		return convertView;
	}

	public List<Boolean> getSelectedFlag() {
		return itemSelectFlag;
	}

	public void setAllItemSelectStatus(Boolean status) {
		for (int i = 0; i < itemSelectFlag.size(); i++) {
			itemSelectFlag.set(i, status);
		}
		if (status)
			currentSelectCount = itemSelectFlag.size();
		else
			currentSelectCount = 0;
	}

	public final class OrderItem {
		public TextView orderTime;
		public TextView orderResponsiblePersonName;
		public TextView productName;
		public TextView productQuantity;
		public TextView productPrice;
		public TextView productCount;
		public TextView isPaid;
		public ImageButton selectView;
		public RelativeLayout relativelayout;
		public View orderDivider;
		public NoScrollListView tglistView;
		public TGListAdapter arrAdapter;

	}

	public class TGListAdapter extends BaseAdapter {
		private Context mContext;
		private List<TGListInfo> mTGList = new ArrayList<TGListInfo>();
		private LayoutInflater inflater;

		TGListAdapter(Context context, List<TGListInfo> tgList) {
			this.mContext = context;
			this.mTGList = tgList;
			inflater = LayoutInflater.from(context);
		}

		@Override
		public int getCount() {
			return mTGList.size();
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
		public View getView(int position, View convertView, ViewGroup parent) {
			TGListItem listItem = null;
			if (convertView == null) {
				listItem = new TGListItem();
				convertView = inflater.inflate(R.xml.order_pay_list_of_tg_list_item, null);
				listItem.orderServicePIC = (TextView) convertView.findViewById(R.id.order_servicepic);
				listItem.orderStatus = (TextView) convertView.findViewById(R.id.order_status);
				convertView.setTag(listItem);
			} else
				listItem = (TGListItem) convertView.getTag();
			listItem.orderServicePIC.setText(mTGList.get(position).getServicePICName());
			listItem.orderStatus.setText(StatusUtil.OrderStatusUtil(mContext,mTGList.get(position).getStatus())+ "|"+ mTGList.get(position).getStartTime());
			return convertView;
		}
	}

	public final class TGListItem {
		TextView orderServicePIC;
		TextView orderStatus;
	}

}
