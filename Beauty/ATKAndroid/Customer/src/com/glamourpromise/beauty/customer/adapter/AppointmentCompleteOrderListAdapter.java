package com.glamourpromise.beauty.customer.adapter;
import java.util.ArrayList;
import java.util.List;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class AppointmentCompleteOrderListAdapter extends BaseAdapter {
	private LayoutInflater     layoutInflater;
	private Context            mContext;
	private List<OrderBaseInfo>    mOrderList = new ArrayList<OrderBaseInfo>();
	public AppointmentCompleteOrderListAdapter(Context context,List<OrderBaseInfo> orderList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		mOrderList=orderList;
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
		int completeCount=mOrderList.get(position).getFinishedCount();
		int totalCount=mOrderList.get(position).getTotalCount();
		if(totalCount!=0)
			dispenseCompleteOrderItem.orderStatusText.setText("完成"+completeCount+"次/"+"共"+totalCount+"次");
		else
			dispenseCompleteOrderItem.orderStatusText.setText("完成"+completeCount+"次/"+"不限次");
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
