package com.GlamourPromise.Beauty.adapter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.OrderOperationUtil;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
/*
 * 待结的订单和存单的适配器
 * */
public class AppointmentCompleteOrderListAdapter extends BaseAdapter {
	private LayoutInflater     layoutInflater;
	private Context            mContext;
	private List<OrderInfo>    mOrderList = new ArrayList<OrderInfo>();
	private UserInfoApplication userInfoApplication;
	public AppointmentCompleteOrderListAdapter(Context context,List<OrderInfo> orderList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		mOrderList=orderList;
		userInfoApplication = UserInfoApplication.getInstance();
	}
	@Override
	public int getCount() {
		return mOrderList.size();
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
		final int pos=position;
		DispenseCompleteOrderItem dispenseCompleteOrderItem = null;
		if (convertView == null) {
			dispenseCompleteOrderItem = new DispenseCompleteOrderItem();
			convertView = layoutInflater.inflate(R.xml.appointment_complete_order_list_item,null);
			dispenseCompleteOrderItem.orderProductNameText=(TextView)convertView.findViewById(R.id.dispense_complete_order_product_name_text);
			dispenseCompleteOrderItem.orderTimeText=(TextView)convertView.findViewById(R.id.dispense_complete_order_time);
			dispenseCompleteOrderItem.orderResponsiblePersonText=(TextView)convertView.findViewById(R.id.dispense_complete_order_responsible_person);
			dispenseCompleteOrderItem.orderStatusText=(TextView) convertView.findViewById(R.id.dispense_complete_order_status);
			dispenseCompleteOrderItem.orderExecutingStatusText=(TextView)convertView.findViewById(R.id.dispense_complete_order_executing_status);
			dispenseCompleteOrderItem.orderSelectIcon=(ImageView)convertView.findViewById(R.id.dispense_complete_order_select_icon);
			convertView.setTag(dispenseCompleteOrderItem);
		} else {
			dispenseCompleteOrderItem = (DispenseCompleteOrderItem)convertView.getTag();
		}
		dispenseCompleteOrderItem.orderProductNameText.setText(mOrderList.get(position).getProductName());
		dispenseCompleteOrderItem.orderTimeText.setText(mOrderList.get(position).getOrderTime());
		dispenseCompleteOrderItem.orderResponsiblePersonText.setText(mOrderList.get(position).getResponsiblePersonName());
		int completeCount=mOrderList.get(position).getCompleteCount();
		int totalCount=mOrderList.get(position).getTotalCount();
		if(mOrderList.get(position).getProductType()==Constant.SERVICE_TYPE){
			if(totalCount!=0)
				dispenseCompleteOrderItem.orderStatusText.setText("完成"+completeCount+"次/"+"共"+totalCount+"次");
			else
				dispenseCompleteOrderItem.orderStatusText.setText("完成"+completeCount+"次/"+"不限次");
		}
		else if(mOrderList.get(position).getProductType()==Constant.COMMODITY_TYPE){
			dispenseCompleteOrderItem.orderStatusText.setText("已交"+completeCount+"件/共"+totalCount+"件");
		}
		String paymentStatusStr="未知";
		int executingCount=mOrderList.get(position).getExecutingCount();
		paymentStatusStr="进行中"+executingCount+"次";
		dispenseCompleteOrderItem.orderExecutingStatusText.setText(paymentStatusStr);
		return convertView;
	}
	public final class  DispenseCompleteOrderItem {
		public TextView  orderProductNameText;
		public TextView  orderTimeText;
		public TextView  orderResponsiblePersonText;
		public TextView  orderStatusText;
		public TextView  orderExecutingStatusText;
		public ImageView orderSelectIcon;
	}
}
