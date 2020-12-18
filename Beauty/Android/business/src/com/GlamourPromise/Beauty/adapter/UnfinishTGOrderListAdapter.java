package com.GlamourPromise.Beauty.adapter;
import java.util.ArrayList;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.Business.UnfishTGListActivity.ListItemClick;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.OrderOperationUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

/*
 * author:zts
 * */
public class UnfinishTGOrderListAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<OrderInfo> orderInfoList;
	private List<OrderInfo> unfinishTgOrderList;
	private int currentSelectCount;
	private boolean[] checks; //用于保存checkBox的选择状态  
	private ListItemClick listItemClick;
	private int        authAllOrderWrite;
	public UnfinishTGOrderListAdapter(Context context, List<OrderInfo> orderInfoList, ListItemClick listItemClick) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.orderInfoList = orderInfoList;
		this.listItemClick = listItemClick;
		checks=new boolean[orderInfoList.size()];
		currentSelectCount = 0;
		unfinishTgOrderList = new ArrayList<OrderInfo>();
		authAllOrderWrite=UserInfoApplication.getInstance().getAccountInfo().getAuthAllOrderWrite();
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
		UnfinishTGOrderItem unfinishTGOrderItem = null;
		if (convertView == null) {
			unfinishTGOrderItem = new UnfinishTGOrderItem();
			convertView = layoutInflater.inflate(R.xml.unfinish_order_list_item, null);
			unfinishTGOrderItem.orderProductNameText = (TextView) convertView.findViewById(R.id.unfinish_order_product_name_text);
			unfinishTGOrderItem.orderPaymentStatusText = (TextView) convertView.findViewById(R.id.unfinish_order_payment_status_text);
			unfinishTGOrderItem.orderProductStatusText = (TextView) convertView.findViewById(R.id.unfinish_order_product_status_text);
			unfinishTGOrderItem.orderPersonNameText = (TextView) convertView.findViewById(R.id.unfinish_order_person_name);
			unfinishTGOrderItem.orderTimeText=(TextView) convertView.findViewById(R.id.unfinish_order_time_text);
			unfinishTGOrderItem.orderCompleteCheckBox=(ImageView) convertView.findViewById(R.id.select_unfinish_order);
			convertView.setTag(unfinishTGOrderItem);
		} else {
			unfinishTGOrderItem = (UnfinishTGOrderItem)convertView.getTag();
		}
		final int finalPosition = position;
		unfinishTGOrderItem.orderCompleteCheckBox
				.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						int  orderResponsibleID=orderInfoList.get(finalPosition).getResponsiblePersonID();
						if(authAllOrderWrite==0 && orderResponsibleID!=UserInfoApplication.getInstance().getAccountInfo().getAccountId()){
							DialogUtil.createShortDialog(mContext,"您无权限处理该笔订单");
						}
						else{
							if(checks[finalPosition]){
								currentSelectCount--;
								checks[finalPosition] = false;
								view.setBackgroundResource(R.drawable.no_select_btn);
								unfinishTgOrderList.remove(orderInfoList.get(finalPosition));
							}else{
								currentSelectCount++;
								checks[finalPosition] = true;
								view.setBackgroundResource(R.drawable.select_btn);
								unfinishTgOrderList.add(orderInfoList.get(finalPosition));
							}
							
							listItemClick.allOrderSelectProcess(currentSelectCount);
							UnfinishTGOrderListAdapter.this.notifyDataSetChanged();
						}
					}
				});
		unfinishTGOrderItem.orderProductNameText.setText(orderInfoList.get(position).getProductName());
		unfinishTGOrderItem.orderPaymentStatusText.setText(OrderOperationUtil.getOrderPayemntStatus(orderInfoList.get(position).getPaymentStatus()));
		int finishCount=orderInfoList.get(position).getCompleteCount();
		int totalCount=orderInfoList.get(position).getTotalCount();
		int productType=orderInfoList.get(position).getProductType();
		String productStatusString="";
		if(productType==Constant.SERVICE_TYPE){
			if(totalCount==0){
				productStatusString="服务1次/不限次";
			}
			else{
				productStatusString="服务1次/共"+totalCount+"次";
			}
		}
		else if(productType==Constant.COMMODITY_TYPE){
			productStatusString="交付"+finishCount+"件/共"+totalCount+"件";
		}
		unfinishTGOrderItem.orderProductStatusText.setText(productStatusString);
		unfinishTGOrderItem.orderPersonNameText.setText(orderInfoList.get(position).getCustomerName()+"|"+orderInfoList.get(position).getResponsiblePersonName());
		unfinishTGOrderItem.orderTimeText.setText(orderInfoList.get(position).getOrderTime());
		if(checks[position])
			unfinishTGOrderItem.orderCompleteCheckBox.setBackgroundResource(R.drawable.select_btn);
		else
			unfinishTGOrderItem.orderCompleteCheckBox.setBackgroundResource(R.drawable.no_select_btn);
		return convertView;
	}
	
	public List<OrderInfo> getUnFinishTgOrderList(){
		return unfinishTgOrderList;
	}
	//全选所有订单
	public void setAllUnfinshTgOrderSelect(){
		for(int p = 0; p < checks.length; p++){
			if(!checks[p]){
				checks[p] = true;
				unfinishTgOrderList.add(orderInfoList.get(p));
			}
		}
		currentSelectCount = orderInfoList.size();
	}
	//取消全选
	public void setAllUnfinshTgOrderUnSelect(){
		for(int p = 0; p < checks.length; p++){
			checks[p] = false;
		}
		currentSelectCount = 0;
		unfinishTgOrderList.clear();
	}
	public List<OrderInfo> getOrderInfoData(){
		return orderInfoList;
	}
	public final class UnfinishTGOrderItem {
		public TextView    orderProductNameText;//产品名称
		public TextView    orderPaymentStatusText;//支付状态
		public TextView    orderProductStatusText;//已完成多少共多少
		public TextView    orderPersonNameText;//顾客和服务顾问的名字
		public TextView    orderTimeText;//时间
		public ImageView   orderCompleteCheckBox;//选择框
	}
}
