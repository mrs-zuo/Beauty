package com.GlamourPromise.Beauty.adapter;
import java.util.Date;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DateUtil;
import com.GlamourPromise.Beauty.util.OrderOperationUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class TodayServiceInfoListAdapter extends BaseAdapter{
	private LayoutInflater      layoutInflater;
	private Context             mContext;
	private List<OrderInfo>     todayServiceList;
	public TodayServiceInfoListAdapter(Context context,List<OrderInfo> todayServiceList)
	{
		this.mContext=context;
		this.todayServiceList=todayServiceList;
		layoutInflater=LayoutInflater.from(mContext);
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return todayServiceList.size();
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		TodayServiceItem todayServiceItem=null;
		if(convertView==null)
		{
			todayServiceItem=new TodayServiceItem();
			convertView=layoutInflater.inflate(R.xml.today_service_list_item,null);
			todayServiceItem.serviceNameText=(TextView)convertView.findViewById(R.id.servicing_product_name);
			todayServiceItem.serviceDateTimeText=(TextView) convertView.findViewById(R.id.servicing_service_date_time);
			todayServiceItem.customerNameText=(TextView) convertView.findViewById(R.id.servicing_customer_name);
			todayServiceItem.serviceStatusText=(TextView) convertView.findViewById(R.id.servicing_service_status);
			todayServiceItem.serviceOrderStatusText=(TextView)convertView.findViewById(R.id.servicing_order_status);
			convertView.setTag(todayServiceItem);
		}
		else{
			todayServiceItem=(TodayServiceItem)convertView.getTag();
		}
		todayServiceItem.serviceNameText.setText(todayServiceList.get(position).getProductName());
		todayServiceItem.serviceDateTimeText.setText(DateUtil.getFormateDateByString2(todayServiceList.get(position).getOrderTime()));
		todayServiceItem.customerNameText.setText(todayServiceList.get(position).getCustomerName());
		String totalCountStr="";
		int    productType=todayServiceList.get(position).getProductType();
		int    totalCount=todayServiceList.get(position).getTotalCount();
		if(productType==Constant.SERVICE_TYPE){
			if(totalCount==0)
				totalCountStr="不限次";
			else
				totalCountStr="共"+totalCount+"次";
			todayServiceItem.serviceStatusText.setText("服务1次/"+totalCountStr);
		}
		else if(productType==Constant.COMMODITY_TYPE){
			totalCountStr="共"+totalCount+"件";
			todayServiceItem.serviceStatusText.setText("交付"+todayServiceList.get(position).getCompleteCount()+"件/"+totalCountStr);
		}
		
		todayServiceItem.serviceOrderStatusText.setText(OrderOperationUtil.getTGStatus(todayServiceList.get(position).getUnfinshTgStatus())+"|"+OrderOperationUtil.getOrderPayemntStatus(todayServiceList.get(position).getPaymentStatus()));
		return convertView;
	}
	public final class TodayServiceItem
	{	
		public TextView   serviceNameText;
		public TextView   serviceDateTimeText;
		public TextView   customerNameText;
		public TextView   serviceStatusText;
		public TextView   serviceOrderStatusText;
	}
}
