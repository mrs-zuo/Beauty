package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.business.CustomerUnpaidOrderActivity.ListItemClick;
import cn.com.antika.business.R;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.OrderOperationUtil;

/*
 * author:zts
 * */

@SuppressLint("ResourceType")
public class UnpaidOrderListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<OrderInfo> orderInfoList;
	private List<OrderInfo> paidOrderList;
	private int currentSelectCount;
	private boolean[] checks; //用于保存checkBox的选择状态  
	private ListItemClick listItemClick;
	private UserInfoApplication userinfoApplication= UserInfoApplication.getInstance();
	public UnpaidOrderListAdapter(Context context, List<OrderInfo> orderInfoList, ListItemClick listItemClick) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.orderInfoList = orderInfoList;
		this.listItemClick = listItemClick;
		checks=new boolean[orderInfoList.size()];
		currentSelectCount = 0;
		paidOrderList = new ArrayList<OrderInfo>();
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
			convertView = layoutInflater.inflate(R.xml.customer_unpaid_order_list_item, null);
			orderItem.orderTimeText = (TextView) convertView.findViewById(R.id.order_time_text);
			orderItem.orderServiceNameText = (TextView) convertView.findViewById(R.id.order_product_name_text);
			orderItem.orderPriceText = (TextView) convertView.findViewById(R.id.order_price);
			orderItem.unpaidOrderPriceText = (TextView) convertView.findViewById(R.id.unpaid_order_price);
			orderItem.orderResponsiblePersonNameText=(TextView) convertView.findViewById(R.id.order_responsible_person_name);
			orderItem.orderProductQuantityText = (TextView) convertView.findViewById(R.id.order_product_quantity);
			orderItem.orderStatusText = (TextView) convertView.findViewById(R.id.order_status);
			orderItem.orderPaidCheckBox = (ImageButton) convertView.findViewById(R.id.select_unpaid_order);
			orderItem.customerUnpaidOrderDivideView=convertView.findViewById(R.id.customer_unpaid_order_divide_view);
			orderItem.orderPriceCurrencyText=(TextView)convertView.findViewById(R.id.order_price_currency);
			orderItem.customerUnpaidOrderServiceListLinearLayout=(LinearLayout)convertView.findViewById(R.id.customer_unpaid_order_service_list);
			convertView.setTag(orderItem);
		} else {
			orderItem = (OrderItem) convertView.getTag();
		}
		final int finalPosition = position;
		orderItem.orderPaidCheckBox
				.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						if(checks[finalPosition]){
							currentSelectCount--;
							checks[finalPosition] = false;
							view.setBackgroundResource(R.drawable.no_select_btn);
							paidOrderList.remove(orderInfoList.get(finalPosition));
						}else{
							currentSelectCount++;
							checks[finalPosition] = true;
							view.setBackgroundResource(R.drawable.select_btn);
							paidOrderList.add(orderInfoList.get(finalPosition));
						}
						
						listItemClick.allOrderSelectProcess(currentSelectCount);
						UnpaidOrderListAdapter.this.notifyDataSetChanged();
					}
				});
		
		orderItem.orderTimeText.setText(orderInfoList.get(position).getOrderTime());
		orderItem.orderServiceNameText.setText(orderInfoList.get(position).getProductName());
		orderItem.orderResponsiblePersonNameText.setText(orderInfoList.get(position).getResponsiblePersonName());
		orderItem.orderProductQuantityText.setText("x"+ orderInfoList.get(position).getQuantity());
		orderItem.orderPriceText.setText(NumberFormatUtil.currencyFormat(orderInfoList.get(position).getTotalPrice()));
		orderItem.orderPriceCurrencyText.setText(userinfoApplication.getAccountInfo().getCurrency());
		orderItem.unpaidOrderPriceText.setText(NumberFormatUtil.currencyFormat(String.valueOf((Double.valueOf(orderInfoList.get(position).getTotalPrice())-Double.valueOf(orderInfoList.get(position).getUnpaidPrice())))));
		orderItem.orderStatusText.setText(OrderOperationUtil.getOrderPayemntStatus(orderInfoList.get(position).getPaymentStatus()));
		if(checks[position])
			orderItem.orderPaidCheckBox.setBackgroundResource(R.drawable.select_btn);
		else
			orderItem.orderPaidCheckBox.setBackgroundResource(R.drawable.no_select_btn);
		
		if(orderInfoList.get(position).getTreatmentGroupList().size()>0){
			orderItem.customerUnpaidOrderServiceListLinearLayout.removeAllViews();
			orderItem.customerUnpaidOrderDivideView.setVisibility(View.VISIBLE);
			for(int i=0;i<orderInfoList.get(position).getTreatmentGroupList().size();i++){
				View customerUnpaidOrderListItemChildView=layoutInflater.inflate(R.xml.customer_unpaid_order_list_item_child, null);
				TextView customerUnpaidOrderServiceName=(TextView) customerUnpaidOrderListItemChildView.findViewById(R.id.customer_unpaid_order_service_name);
				TextView customerUnpaidOrderServiceStatus=(TextView) customerUnpaidOrderListItemChildView.findViewById(R.id.customer_unpaid_order_service_status);
				TextView customerUnpaidOrderServiceTimeText=(TextView) customerUnpaidOrderListItemChildView.findViewById(R.id.customer_unpaid_order_service_time_text);
				customerUnpaidOrderServiceName.setText(orderInfoList.get(position).getTreatmentGroupList().get(i).getServicePicName());
				customerUnpaidOrderServiceStatus.setText(OrderOperationUtil.getTGStatus(orderInfoList.get(position).getTreatmentGroupList().get(i).getStatus()));
				customerUnpaidOrderServiceTimeText.setText(orderInfoList.get(position).getTreatmentGroupList().get(i).getStartTime());
				orderItem.customerUnpaidOrderServiceListLinearLayout.addView(customerUnpaidOrderListItemChildView);
			}
		}
		else{
			orderItem.customerUnpaidOrderDivideView.setVisibility(View.GONE);
			orderItem.customerUnpaidOrderServiceListLinearLayout.removeAllViews();
		}
		return convertView;
	}
	
	public List<OrderInfo> getPaidOrderList(){
		return paidOrderList;
	}
	//全选所有订单
	public void setAllUnpaidOrderSelect(){
		for(int p = 0; p < checks.length; p++){
			if(!checks[p]){
				checks[p] = true;
				paidOrderList.add(orderInfoList.get(p));
			}
		}
		currentSelectCount = orderInfoList.size();
	}
	//取消全选
	public void setAllUnpaidOrderUnSelect(){
		for(int p = 0; p < checks.length; p++){
			checks[p] = false;
		}
		currentSelectCount = 0;
		paidOrderList.clear();
	}
	public final class OrderItem {
		public TextView orderTimeText;
		public TextView orderServiceNameText;
		public TextView orderPriceCurrencyText;
		public TextView orderPriceText;
		public TextView unpaidOrderPriceText;
		public TextView orderProductQuantityText;
		public TextView orderResponsiblePersonNameText;
		public TextView orderStatusText;
		public ImageButton orderPaidCheckBox;
		public View        customerUnpaidOrderDivideView;
		public LinearLayout customerUnpaidOrderServiceListLinearLayout;
	}
}
