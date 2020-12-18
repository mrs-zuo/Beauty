package com.glamourpromise.beauty.customer.adapter;

import java.text.NumberFormat;
import java.util.List;
import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.CardBalanceHistoryInfo;
import com.glamourpromise.beauty.customer.util.ImageLoader;

public class EcardHistoryListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<CardBalanceHistoryInfo> ecardHistoryInformationList;
	public ImageLoader imageLoader;
	private NumberFormat nf;

	public EcardHistoryListAdapter(Context context,
			List<CardBalanceHistoryInfo> ecardHistoryInformationList) {
		this.mContext = context;
		this.ecardHistoryInformationList = ecardHistoryInformationList;
		nf = NumberFormat.getInstance();
		nf.setMaximumFractionDigits(2);
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return ecardHistoryInformationList.size();
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

	@SuppressLint("ResourceAsColor")
	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		EcardHistoryItem ecardHistoryItem = null;
		if (convertView == null) {
			ecardHistoryItem = new EcardHistoryItem();
			convertView = layoutInflater.inflate(R.xml.ecard_history_list_item,
					null);
			ecardHistoryItem.cellLayout = (RelativeLayout) convertView
					.findViewById(R.id.cell_layout);
			ecardHistoryItem.typeName = (TextView) convertView
					.findViewById(R.id.ecard_history_type_name);
			ecardHistoryItem.createTime = (TextView) convertView
					.findViewById(R.id.ecard_trading_create_time);
			convertView.setTag(ecardHistoryItem);
		} else {
			ecardHistoryItem = (EcardHistoryItem) convertView.getTag();
		}

		ecardHistoryItem.typeName.setText(ecardHistoryInformationList.get(position).getChangeTypeName());
		ecardHistoryItem.createTime.setText(ecardHistoryInformationList.get(position).getCreateTime());
		return convertView;
	}

	public final class EcardHistoryItem {
		public RelativeLayout cellLayout;
		public TextView typeName;
		public TextView createTime;
	}
}
