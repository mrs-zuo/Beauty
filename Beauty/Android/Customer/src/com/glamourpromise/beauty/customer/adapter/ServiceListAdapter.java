package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.app.Activity;
import android.graphics.Paint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.squareup.picasso.Picasso;

public class ServiceListAdapter extends BaseAdapter {
	private Activity mContext;
	private List<ServiceInformation> mServiceList;
	private String tmpDiscountPrice;
	private String tmpUnitPrice;
	private LayoutInflater layoutInflater;
	
	public ServiceListAdapter(Activity context, List<ServiceInformation> serviceList){
		mContext = context;
		mServiceList = serviceList;
		layoutInflater = LayoutInflater.from(mContext);
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
		ServiceItem serviceItem = null;
		if (convertView == null) {
			serviceItem = new ServiceItem();
			convertView = layoutInflater.inflate(R.xml.commodity_list_item,null);
			serviceItem.serviceName = (TextView) convertView.findViewById(R.id.commodity_name);
			serviceItem.servicePromotionPrice = (TextView) convertView.findViewById(R.id.commodity_promotion_price);
			serviceItem.serviceUnitPrice = (TextView) convertView.findViewById(R.id.commodity_unit_price);
			serviceItem.serviceThumbnail = (ImageView) convertView.findViewById(R.id.commodity_thumbnail);
			serviceItem.serviceDiscountIcon = (ImageView) convertView.findViewById(R.id.commodity_discount_icon);
			convertView.setTag(serviceItem);
		} else
			serviceItem = (ServiceItem) convertView.getTag();
		
		serviceItem.serviceName.setText(mServiceList.get(position).getName());
		
		if(mServiceList.get(position).getThumbnail().equals("")){
			serviceItem.serviceThumbnail.setImageResource(R.drawable.beauty_default_customer);
		}else{
			Picasso.with(mContext.getApplicationContext()).load(mServiceList.get(position).getThumbnail()).error(R.drawable.beauty_default_customer).into(serviceItem.serviceThumbnail);
		}
		tmpDiscountPrice = mServiceList.get(position).getDiscountPrice();
		tmpUnitPrice = mServiceList.get(position).getUnitPrice();
		if(mServiceList.get(position).getMarketingPolicy() == 0 || tmpDiscountPrice.equals("0.00") || (tmpDiscountPrice.equals(tmpUnitPrice))){
			//没有折扣
			serviceItem.serviceUnitPrice.setVisibility(View.GONE);
			serviceItem.servicePromotionPrice.setText(NumberFormatUtil.StringFormatToString(mContext, tmpUnitPrice));
		}else{
			//有折扣
			serviceItem.serviceUnitPrice.setVisibility(View.VISIBLE);
			serviceItem.serviceUnitPrice.setText(tmpUnitPrice);
			serviceItem.serviceUnitPrice.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);
			serviceItem.servicePromotionPrice.setText(NumberFormatUtil.StringFormatToString(mContext, tmpDiscountPrice));
		}
		// 设置折扣价
		if (mServiceList.get(position).getMarketingPolicy() == 0 || tmpDiscountPrice.equals("0.00") || (tmpDiscountPrice.equals(tmpUnitPrice))) {
			serviceItem.serviceDiscountIcon.setVisibility(View.GONE);
		} else if (mServiceList.get(position).getMarketingPolicy() == 1) {
			// 按折扣率打折
			serviceItem.serviceDiscountIcon.setVisibility(View.VISIBLE);
			serviceItem.serviceDiscountIcon.setBackgroundResource(R.drawable.discount);
		} else if (mServiceList.get(position).getMarketingPolicy() == 2){
			serviceItem.serviceDiscountIcon.setVisibility(View.VISIBLE);
			serviceItem.serviceDiscountIcon.setBackgroundResource(R.drawable.promotion);
		}
		return convertView;
	}
	
	public final class ServiceItem {
		public ImageView serviceThumbnail;
		public TextView serviceName;
		public TextView serviceUnitPrice;
		public TextView servicePromotionPrice;
		public ImageView serviceDiscountIcon;
		public ImageButton serviceSelectCheckbox;
	}

}
