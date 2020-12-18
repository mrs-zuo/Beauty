package com.glamourpromise.beauty.customer.adapter;
import java.util.ArrayList;
import java.util.List;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.AppointmentCreateActivity;
import com.glamourpromise.beauty.customer.activity.EvaluateServiceDetailActivity;
import com.glamourpromise.beauty.customer.activity.ServcieOrderDetailActivity;
import com.glamourpromise.beauty.customer.bean.EvaluateServiceInfo;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.ServiceOrderInfo;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class UnFinishOrderListAdapter extends BaseAdapter {
	private LayoutInflater     layoutInflater;
	private Context            mContext;
	private List<OrderBaseInfo>    unFinishOrderInfoList = new ArrayList<OrderBaseInfo>();
	private String  branchID,branchName;
	public UnFinishOrderListAdapter(Context context,List<OrderBaseInfo>    unFinishOrderInfoList,String branchID,String branchName) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.unFinishOrderInfoList=unFinishOrderInfoList;
		this.branchID=branchID;
		this.branchName=branchName;
	}
	@Override
	public int getCount() {
		return unFinishOrderInfoList.size();
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
		UnFinishOrderItem unfinishOrderItem = null;
		if (convertView == null) {
			unfinishOrderItem = new UnFinishOrderItem();
			convertView = layoutInflater.inflate(R.xml.unfinish_order_list_item,null);
			unfinishOrderItem.orderNameText=(TextView)convertView.findViewById(R.id.unfinish_order_name_text);
			unfinishOrderItem.orderTime=(TextView)convertView.findViewById(R.id.unfinish_order_time);
			unfinishOrderItem.orderResponsibleNameText=(TextView)convertView.findViewById(R.id.unfinish_order_responsible_name_text);
			unfinishOrderItem.orderNum=(TextView) convertView.findViewById(R.id.unfinish_order_num);
			unfinishOrderItem.orderAppointmentButton=(Button) convertView.findViewById(R.id.unfinish_order_appointment_button);
			convertView.setTag(unfinishOrderItem);
		} else {
			unfinishOrderItem = (UnFinishOrderItem)convertView.getTag();
		}
		unfinishOrderItem.orderAppointmentButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent it =new Intent(mContext,AppointmentCreateActivity.class);
				it.putExtra("branchID",branchID);
				it.putExtra("branchName",branchName);
				it.putExtra("taskSourceType",3);
				Bundle bu = new Bundle();
				bu.putInt("serviceID",Integer.parseInt(unFinishOrderInfoList.get(pos).getOrderID()));
				bu.putString("serviceName",unFinishOrderInfoList.get(pos).getProductName());
				bu.putString("serviceCode","0");
				bu.putInt("objectID",Integer.parseInt(unFinishOrderInfoList.get(pos).getOrderObjectID()));
				bu.putBoolean("isOldOrder",true);
				it.putExtras(bu);
				mContext.startActivity(it);
			}
		});
		unfinishOrderItem.orderNameText.setText(unFinishOrderInfoList.get(position).getProductName());
		unfinishOrderItem.orderTime.setText(unFinishOrderInfoList.get(position).getOrderTime());
		unfinishOrderItem.orderResponsibleNameText.setText(unFinishOrderInfoList.get(position).getResponsiblePersonName());
		if(unFinishOrderInfoList.get(position).getTotalCount()==0){
			unfinishOrderItem.orderNum.setText("服务"+unFinishOrderInfoList.get(position).getFinishedCount()+"次/不限次");
		}else{
			unfinishOrderItem.orderNum.setText("服务"+unFinishOrderInfoList.get(position).getFinishedCount()+"次/"+"共"+unFinishOrderInfoList.get(position).getTotalCount()+"次");
		}
		return convertView;
	}
	public final class  UnFinishOrderItem {
		public TextView  orderNameText;
		public TextView  orderTime;
		public TextView  orderResponsibleNameText;
		public TextView  orderNum;
		public Button    orderAppointmentButton;
	}
}
