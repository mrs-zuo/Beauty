package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.DiscountInfo;

public class EcardDiscountInfoAdapter extends BaseAdapter{
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<DiscountInfo> mDiscountInfoList;
	
	public EcardDiscountInfoAdapter(Context context, List<DiscountInfo> discountInfoList){
		mContext = context;
		mDiscountInfoList = discountInfoList;
		layoutInflater = LayoutInflater.from(mContext);
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mDiscountInfoList.size();
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
		DiscountItem discountItem = null;
		if (convertView == null) {
			discountItem = new DiscountItem();
			convertView = layoutInflater.inflate(R.xml.discount_info_item, null);
			discountItem.discountName = (TextView) convertView.findViewById(R.id.discount_name);
			discountItem.discountAmount = (TextView) convertView.findViewById(R.id.discount_amount);
			convertView.setTag(discountItem);
		} else {
			discountItem = (DiscountItem) convertView.getTag();
		}

		discountItem.discountName.setText(mDiscountInfoList.get(position).getName());
		discountItem.discountName.setTextColor(mContext.getResources().getColor(R.color.black));
		discountItem.discountAmount.setText(mDiscountInfoList.get(position).getDiscount());
		return convertView;
	}
	public final class DiscountItem {
		public TextView discountName;
		public TextView discountAmount;
	}
}
