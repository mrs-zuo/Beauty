package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;
import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.CardBalanceHistoryInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class CardBalanceHistoryListAdapter extends BaseAdapter {
	private Activity context;
	private List<CardBalanceHistoryInfo> cardList = new ArrayList<CardBalanceHistoryInfo>();
	private LayoutInflater inflater;

	public CardBalanceHistoryListAdapter(Activity mContext,List<CardBalanceHistoryInfo> mCardList) {
		this.context = mContext;
		this.cardList = mCardList;
		inflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		return cardList.size();
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
		CardInfo cardInfo = null;
		if (convertView == null) {
			cardInfo = new CardInfo();
			convertView = inflater.inflate(R.xml.card_balance_history_list_item, null);
			cardInfo.actionMode = (TextView) convertView.findViewById(R.id.card_action_mode_title);
			cardInfo.amount = (TextView) convertView.findViewById(R.id.card_action_amount_title);
			cardInfo.createTime = (TextView) convertView.findViewById(R.id.card_create_time_title);
			cardInfo.balance = (TextView) convertView.findViewById(R.id.card_balance_title);
			convertView.setTag(cardInfo);

		} else
			cardInfo = (CardInfo) convertView.getTag();
		cardInfo.actionMode.setText(cardList.get(position).getActionModeName());
		if (cardList.get(position).isAmountPositive()) {
			cardInfo.amount.setText("+"+ NumberFormatUtil.FloatFormatToStringWithoutSingle(Float.valueOf(cardList.get(position).getAmount())));
			// setDarkGreen
			cardInfo.amount.setTextColor(context.getResources().getColor(R.color.dark_green));
		} else {
			cardInfo.amount.setText(NumberFormatUtil.FloatFormatToStringWithoutSingle(Float.valueOf(cardList.get(position).getAmount())));
			cardInfo.amount.setTextColor(context.getResources().getColor(R.color.red));
		}
		cardInfo.createTime.setText(cardList.get(position).getCreateTime());
		if (cardList.get(position).getCardType() != 2)
			cardInfo.balance.setText(NumberFormatUtil.StringFormatToString(context, cardList.get(position).getBalance()));
		else
			cardInfo.balance.setText(NumberFormatUtil.FloatFormatToStringWithoutSingle(Float.valueOf(cardList.get(position).getBalance())));
		return convertView;
	}

	public final class CardInfo {
		TextView actionMode;
		TextView amount;
		TextView createTime;
		TextView balance;
	}

}
