package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.ScdlList;

public class ScdlListAdapter extends BaseAdapter {
	private Context mContext;
	private List<ScdlList> mScdlList;
	private LayoutInflater inflater;

	public ScdlListAdapter(Context context, List<ScdlList> scdlList) {
		this.mContext = context;
		this.mScdlList = scdlList;
		inflater = LayoutInflater.from(context);
	}

	@Override
	public int getCount() {
		return mScdlList.size();
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
			convertView = inflater.inflate(R.xml.service_order_list_scdl_list_item, null);
			listItem.scdlLayout = (RelativeLayout) convertView.findViewById(R.id.service_order_list_scdl_responsible_persone_name_layout);
			listItem.responsislbePersonName = (TextView) convertView.findViewById(R.id.service_order_list_scdl_responsible_person_name);
			listItem.scdlArrow = (ImageView) convertView.findViewById(R.id.service_order_list_scdl__tg_detail_arrowhead);
			listItem.scdlTime = (TextView) convertView.findViewById(R.id.service_order_list_scdl_scdl_time);
			convertView.setTag(listItem);
		} else
			listItem = (ListItem) convertView.getTag();

		listItem.responsislbePersonName.setText(mScdlList.get(position).getResponsiblePersonName());
		listItem.scdlTime.setText(mScdlList.get(position).getTaskScdlStartTime());
		// 转预约详情
		return convertView;
	}

	public final class ListItem {
		RelativeLayout scdlLayout;
		TextView responsislbePersonName;
		ImageView scdlArrow;
		TextView scdlTime;
	}

}
