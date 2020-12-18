package com.GlamourPromise.Beauty.adapter;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.Opportunity;
import com.GlamourPromise.Beauty.util.DateUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class OpportunityListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<Opportunity> opportunityList;
	public OpportunityListAdapter(Context context,
			List<Opportunity> opportunityList) {
		this.mContext = context;
		this.opportunityList = opportunityList;
		layoutInflater=LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return opportunityList.size();
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
		OpportunityItem opportunityListItem = null;
		if (convertView == null) {
			opportunityListItem = new OpportunityItem();
			convertView = layoutInflater.inflate(R.xml.opportunity_list_item,
					null);
			opportunityListItem.customerNameText = (TextView) convertView
					.findViewById(R.id.opportunity_customer_name);
			opportunityListItem.responsiblePersonNameText=(TextView)convertView.findViewById(R.id.opportunity_responsible_person_name);
			opportunityListItem.createTimeText=(TextView)convertView.findViewById(R.id.opportunity_create_time);
			opportunityListItem.productNameText = (TextView) convertView
					.findViewById(R.id.opportunity_product_name);
			opportunityListItem.progressRateText=(TextView)convertView.findViewById(R.id.opportunity_progress_rate);
			opportunityListItem.opportunityIsLoose=(ImageView)convertView.findViewById(R.id.opportunity_lose_icon);
			convertView.setTag(opportunityListItem);
		} else {
			opportunityListItem = (OpportunityItem) convertView.getTag();
		}
		opportunityListItem.customerNameText.setText(opportunityList.get(position).getCustomerName());
		opportunityListItem.responsiblePersonNameText.setText(opportunityList.get(position).getResponsiblePersonName());
		//将商机的创建时间格式化成 yyyy-MM-dd HH:mm格式
		opportunityListItem.createTimeText.setText(DateUtil.getFormateDateByString2(opportunityList.get(position).getCreatTime()));
		opportunityListItem.productNameText.setText(opportunityList.get(position).getProductName());
		opportunityListItem.progressRateText.setText("达成率"+opportunityList.get(position).getProgressRate());
		boolean isAvailable=opportunityList.get(position).isAvailable();
		if(!isAvailable)
			opportunityListItem.opportunityIsLoose.setVisibility(View.VISIBLE);
		else
			opportunityListItem.opportunityIsLoose.setVisibility(View.GONE);
		return convertView;
	}

	public final class OpportunityItem {
		public TextView customerNameText;
		public TextView responsiblePersonNameText;
		public TextView createTimeText;
		public TextView productNameText;
		public TextView progressRateText;
		public ImageView opportunityIsLoose;
	}
}
