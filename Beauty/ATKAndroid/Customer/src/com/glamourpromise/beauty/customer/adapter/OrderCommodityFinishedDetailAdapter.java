package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.TGListInfo;
import com.glamourpromise.beauty.customer.util.StatusUtil;

public class OrderCommodityFinishedDetailAdapter extends BaseAdapter {

	private List<TGListInfo> finishedTGList = new ArrayList<TGListInfo>();
	private List<String> counter = new ArrayList<String>();
	private Context context;
	private LayoutInflater inflater;

	public OrderCommodityFinishedDetailAdapter(Context mContext,
			List<TGListInfo> mFinishedTGList) {
		this.context = mContext;
		this.finishedTGList = mFinishedTGList;
		inflater = LayoutInflater.from(mContext);
		for (int i = 0; i < finishedTGList.size(); i++)
			counter.add(i, String.valueOf(i + 1) + ".");
	}

	@Override
	public int getCount() {
		return finishedTGList.size();
	}

	@Override
	public Object getItem(int position) {
		return position;
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ListItem listItem = null;
		if (convertView == null) {
			listItem = new ListItem();
			convertView = inflater.inflate(R.xml.commodity_finished_detail_list_item, null);
			listItem.counterDivider = (View) convertView.findViewById(R.id.counter_divider);
			listItem.finishedStatusLayout = (RelativeLayout) convertView.findViewById(R.id.finised_status_layout);
			listItem.finishedCount = (TextView) convertView.findViewById(R.id.finished_count);
			listItem.finishedTime = (TextView) convertView.findViewById(R.id.finished_time);
			listItem.statusDivider = (View) convertView.findViewById(R.id.status_divider);
			listItem.responsiblePersonLayout = (RelativeLayout) convertView.findViewById(R.id.responsible_persone_name_layout);
			listItem.responsiblePersonName = (TextView) convertView.findViewById(R.id.responsible_person_name);
			convertView.setTag(listItem);
		} else
			listItem = (ListItem) convertView.getTag();
		
		listItem.finishedCount.setText(StatusUtil.TGStatusUtil(context, finishedTGList.get(position).getStatus()) + "|" +context.getResources().getString(R.string.product_type_status_1_title)
				+ finishedTGList.get(position).getQuantity()
				+ context.getResources().getString(R.string.product_type_status_1_unit));
		listItem.finishedTime.setText(finishedTGList.get(position).getStartTime());
		listItem.responsiblePersonName.setText(finishedTGList.get(position).getServicePICName());

		return convertView;
	}

	public final class ListItem {
		View counterDivider;
		RelativeLayout finishedStatusLayout;
		TextView finishedCount;
		TextView finishedTime;
		View statusDivider;
		RelativeLayout responsiblePersonLayout;
		TextView responsiblePersonName;
	}

}
