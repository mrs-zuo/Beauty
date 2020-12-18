package com.glamourpromise.beauty.customer.adapter;
import java.util.List;

import android.app.Activity;
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

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.AppointmentCreateActivity;
import com.glamourpromise.beauty.customer.activity.ServiceDetailActivity;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.squareup.picasso.Picasso;

public class RecommendBouthServiceListAdapter extends BaseAdapter {
	private Activity mContext;
	private List<ServiceInformation> mServiceList;
	private LayoutInflater layoutInflater;
	private String   branchName;
	private String   branchID;
	private int      type;
	//type 2:推荐  4：已买
	public RecommendBouthServiceListAdapter(Activity context,List<ServiceInformation> serviceList,String branchID,String branchName,int type){
		mContext = context;
		mServiceList = serviceList;
		layoutInflater = LayoutInflater.from(mContext);
		this.branchID=branchID;
		this.branchName=branchName;
		this.type=type;
	}
	@Override
	public int getCount() {
		return mServiceList.size();
	}

	@Override
	public Object getItem(int arg0) {
		return null;
	}

	@Override
	public long getItemId(int arg0) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		final int pos=position;
		ServiceItem serviceItem = null;
		if (convertView == null) {
			serviceItem = new ServiceItem();
			convertView = layoutInflater.inflate(R.xml.recommend_bought_service_list_item,null);
			serviceItem.serviceName = (TextView) convertView.findViewById(R.id.service_name);
			serviceItem.serviceUnitPrice = (TextView) convertView.findViewById(R.id.service_unit_price);
			serviceItem.serviceThumbnail = (ImageView) convertView.findViewById(R.id.service_thumbnail);
			serviceItem.serviceDetailBtn=(Button)convertView.findViewById(R.id.service_detail_button);
			serviceItem.appointmentBtn=(Button)convertView.findViewById(R.id.appointment_service_button);
			convertView.setTag(serviceItem);
		} else
			serviceItem = (ServiceItem) convertView.getTag();
		if(mServiceList.get(position).getThumbnail().equals("")){
			serviceItem.serviceThumbnail.setImageResource(R.drawable.commodity_image_null);
		}else{
			Picasso.with(mContext.getApplicationContext()).load(mServiceList.get(position).getThumbnail()).error(R.drawable.commodity_image_null).into(serviceItem.serviceThumbnail);
		}
		serviceItem.serviceName.setText(mServiceList.get(position).getName());
		serviceItem.serviceUnitPrice.setText(NumberFormatUtil.StringFormatToString(mContext,mServiceList.get(position).getUnitPrice()));
		serviceItem.serviceDetailBtn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				Intent detailIntent=new Intent();
				detailIntent.setClass(mContext,ServiceDetailActivity.class);
				detailIntent.putExtra("serviceCode",mServiceList.get(pos).getCode());
				mContext.startActivity(detailIntent);
			}
		});
		serviceItem.appointmentBtn.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				Intent appointmentIt =new Intent(mContext,AppointmentCreateActivity.class);
				appointmentIt.putExtra("branchID",branchID);
				appointmentIt.putExtra("branchName",branchName);
				appointmentIt.putExtra("taskSourceType",type);
				Bundle bu = new Bundle();
				bu.putInt("serviceID", mServiceList.get(pos).getID());
				bu.putString("serviceName",mServiceList.get(pos).getName());
				bu.putString("serviceCode",mServiceList.get(pos).getCode());
				bu.putBoolean("isOldOrder", false);
				appointmentIt.putExtras(bu);
				mContext.startActivity(appointmentIt);
			}
		});
		return convertView;
	}
	
	public final class ServiceItem {
		public ImageView serviceThumbnail;
		public TextView serviceName;
		public TextView serviceUnitPrice;
		public Button   serviceDetailBtn,appointmentBtn;
	}
}
