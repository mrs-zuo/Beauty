package com.GlamourPromise.Beauty.adapter;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.StringUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

/*
 * author:zts
 * */
public class EcardHistroyOrderListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<OrderInfo> ecardHistroyOrderInfoList;
	public EcardHistroyOrderListAdapter(Context context, List<OrderInfo> ecardHistroyOrderInfoList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.ecardHistroyOrderInfoList = ecardHistroyOrderInfoList;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return ecardHistroyOrderInfoList.size();
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
			convertView = layoutInflater.inflate(R.xml.ecard_histroy_order_list_item, null);
			orderItem.orderTimeText = (TextView) convertView.findViewById(R.id.ecard_histroy_order_time_text);
			orderItem.orderServiceNameText = (TextView) convertView.findViewById(R.id.ecard_histroy_order_product_name_text);
			orderItem.orderPriceText = (TextView) convertView.findViewById(R.id.ecard_histroy_order_price);
			orderItem.orderCustomerNameText=(TextView)convertView.findViewById(R.id.ecard_histroy_order_customer_name);
			orderItem.orderResponsiblePersonNameText=(TextView) convertView.findViewById(R.id.ecard_histroy_order_responsible_person_name);
			orderItem.orderProductQuantityText=(TextView)convertView.findViewById(R.id.ecard_histroy_order_product_quantity);
			orderItem.orderStatusText = (TextView) convertView.findViewById(R.id.ecard_histroy_order_status);
			orderItem.orderDetailArrowhead = (ImageView) convertView.findViewById(R.id.arrowhead);
			convertView.setTag(orderItem);
		} else {
			orderItem = (OrderItem) convertView.getTag();
		}
		orderItem.orderTimeText.setText(ecardHistroyOrderInfoList.get(position)
				.getOrderTime());
		orderItem.orderServiceNameText.setText(ecardHistroyOrderInfoList.get(position).getProductName());
		orderItem.orderCustomerNameText.setText(ecardHistroyOrderInfoList.get(position).getCustomerName()+"|");
		orderItem.orderResponsiblePersonNameText.setText(ecardHistroyOrderInfoList.get(position).getResponsiblePersonName());
		orderItem.orderProductQuantityText.setText("x"+ecardHistroyOrderInfoList.get(position).getQuantity());
		orderItem.orderPriceText.setText(String.valueOf(UserInfoApplication.getInstance().getAccountInfo().getCurrency()+NumberFormatUtil.currencyFormat(ecardHistroyOrderInfoList.get(
				position).getTotalSalePrice())));
		int orderStatus = ecardHistroyOrderInfoList.get(position).getStatus();
		int paymentStatus=ecardHistroyOrderInfoList.get(position).getPaymentStatus();
		String orderStatusString="";
		String paymentStatusString="已支付";
		switch (orderStatus) {
		case 0:
			orderStatusString="未完成";
			break;
		case 1:
			orderStatusString="已完成";
			break;
		case 2:
			orderStatusString="已取消";
			break;
		default:
			orderStatusString="未完成";
			break;
		/*//商品订单 商品等待客户确认状态
		case 3:
			orderStatusString="待确认";
			break;*/
		}
		switch (paymentStatus) {
		case 0:
			paymentStatusString="未支付";
			break;
		case 1:
			paymentStatusString="部分支付";
			break;
		case 2:
			paymentStatusString="已支付";
			break;
		}
		orderItem.orderStatusText.setText(orderStatusString+"|"+paymentStatusString);
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
	}
}
