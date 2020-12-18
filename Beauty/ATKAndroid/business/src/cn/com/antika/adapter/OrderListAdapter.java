package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.business.R;
import cn.com.antika.util.DateUtil;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.OrderOperationUtil;

/*
 * author:zts
 * */

@SuppressLint("ResourceType")
public class OrderListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<OrderInfo> orderInfoList;
	private int userRole;
	public OrderListAdapter(Context context, List<OrderInfo> orderInfoList,int userRole) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.orderInfoList = orderInfoList;
		this.userRole=userRole;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return orderInfoList.size();
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
		OrderItem orderItem = null;
		if (convertView == null) {
			orderItem = new OrderItem();
			convertView = layoutInflater.inflate(R.xml.order_list_item, null);
			orderItem.orderTimeText = (TextView) convertView.findViewById(R.id.order_time_text);
			orderItem.orderServiceNameText = (TextView) convertView.findViewById(R.id.order_product_name_text);
			orderItem.orderPriceText = (TextView) convertView.findViewById(R.id.order_price);
			orderItem.orderCustomerNameText=(TextView)convertView.findViewById(R.id.order_customer_name);
			orderItem.orderResponsiblePersonNameText=(TextView) convertView.findViewById(R.id.order_responsible_person_name);
			orderItem.orderProductQuantityText=(TextView)convertView.findViewById(R.id.order_product_quantity);
			orderItem.orderStatusText = (TextView) convertView.findViewById(R.id.order_status);
			orderItem.newOrderIcon = (ImageView) convertView.findViewById(R.id.new_order_icon);
			orderItem.orderDetailArrowhead = (ImageView) convertView.findViewById(R.id.arrowhead);
			convertView.setTag(orderItem);
		} else {
			orderItem = (OrderItem) convertView.getTag();
		}
		orderItem.orderTimeText.setText(orderInfoList.get(position).getOrderTime());
		orderItem.orderServiceNameText.setText(orderInfoList.get(position).getProductName());
		orderItem.orderCustomerNameText.setText(orderInfoList.get(position).getCustomerName());
		orderItem.orderResponsiblePersonNameText.setText(orderInfoList.get(position).getResponsiblePersonName());
		orderItem.orderProductQuantityText.setText("x"+orderInfoList.get(position).getQuantity());
		orderItem.orderPriceText.setText(String.valueOf(UserInfoApplication.getInstance().getAccountInfo().getCurrency()+NumberFormatUtil.currencyFormat(orderInfoList.get(position).getTotalSalePrice())));
		int orderStatus = orderInfoList.get(position).getStatus();
		int payStatus=orderInfoList.get(position).getPaymentStatus();
		String orderStatusString=OrderOperationUtil.getOrderStatus(orderStatus);
		String payStatusString=OrderOperationUtil.getOrderPayemntStatus(payStatus);
		orderItem.orderStatusText.setText(orderStatusString+"|"+payStatusString);
		if(userRole!=-1)
			orderItem.orderDetailArrowhead.setBackgroundResource(R.drawable.join_in_arrowhead);
		if((orderInfoList.get(position).getOrderSource().equals("2") || orderInfoList.get(position).getOrderSource().equals("5"))&& DateUtil.compareDateEqual(orderInfoList.get(position).getOrderTime())){
			orderItem.newOrderIcon.setVisibility(View.VISIBLE);
		}else{
			orderItem.newOrderIcon.setVisibility(View.GONE);
		}
		return convertView;
	}
	public final class OrderItem {
		public TextView orderTimeText;
		public TextView orderServiceNameText;
		public TextView orderPriceText;
		public TextView orderProductQuantityText;
		public TextView orderCustomerNameText;
		public TextView orderResponsiblePersonNameText;
		public TextView orderStatusText;
		public ImageView orderDetailArrowhead;
		public ImageView newOrderIcon;
	}
}
