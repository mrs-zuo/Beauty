package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.BalanceInfo;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class EcardBalanceInfoListAdapter extends BaseAdapter {
	private List<BalanceInfo> mBalanceInfo;
	private Activity mContext;
	private LayoutInflater inflater;

	public EcardBalanceInfoListAdapter(Activity context,
			List<BalanceInfo> balanceInfo) {
		this.mContext = context;
		this.mBalanceInfo = balanceInfo;
		inflater = LayoutInflater.from(context);
	}

	@Override
	public int getCount() {
		return mBalanceInfo.size();
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
			convertView = inflater.inflate(R.xml.ecard_balance_info_list_item,null);
			listItem.titleLayout = (RelativeLayout) convertView.findViewById(R.id.balance_detail_info_list_layout);
			listItem.titleText = (TextView) convertView.findViewById(R.id.balance_detail_info_list_title);
			listItem.balanceCardInfoListView = (NoScrollListView) convertView.findViewById(R.id.balance_card_list_view);
			convertView.setTag(listItem);
		} else
			listItem = (ListItem) convertView.getTag();

		listItem.arrAdapter = new EcardBalanceCardInfoListAdapter(mContext, mBalanceInfo.get(position).getBalanceCardList());
		listItem.balanceCardInfoListView.setAdapter(listItem.arrAdapter);
		listItem.titleText.setText(mBalanceInfo.get(position).getActionModeName());
		return convertView;
	}

	public final class ListItem {
		RelativeLayout titleLayout;
		TextView titleText;
		NoScrollListView balanceCardInfoListView;
		EcardBalanceCardInfoListAdapter arrAdapter;
	}

}
