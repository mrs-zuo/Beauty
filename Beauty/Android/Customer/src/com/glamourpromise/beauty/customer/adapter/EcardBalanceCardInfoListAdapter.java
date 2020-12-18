package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.BalanceCardInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EcardBalanceCardInfoListAdapter extends BaseAdapter {
	private List<BalanceCardInfo> mBalanceCardInfo;
	private Activity mContext;
	private LayoutInflater inflater;

	public EcardBalanceCardInfoListAdapter(Activity context,
			List<BalanceCardInfo> balanceCardInfo) {
		this.mContext = context;
		this.mBalanceCardInfo = balanceCardInfo;
		inflater = LayoutInflater.from(context);
	}

	@Override
	public int getCount() {
		return mBalanceCardInfo.size();
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
			convertView = inflater.inflate(
					R.xml.ecard_balance_card_info_list_item, null);
			listItem.balanceCardInfoLayout = (TableLayout) convertView
					.findViewById(R.id.card_info_list_table_layout);
			listItem.balanceTradingLayout = (RelativeLayout) convertView
					.findViewById(R.id.card_trading_amount_layout);
			listItem.cardNameTitle = (TextView) convertView
					.findViewById(R.id.card_name_title);
			listItem.nonCardAmount = (TextView) convertView
					.findViewById(R.id.not_card_payment_amount);
			listItem.tradingAmount = (TextView) convertView
					.findViewById(R.id.card_trading_amount);
			listItem.cardBalanceLayout = (RelativeLayout) convertView
					.findViewById(R.id.card_balance_layout);
			listItem.cardBalanceTitle = (TextView) convertView
					.findViewById(R.id.card_balance_title);
			listItem.cardBalanceContent = (TextView) convertView
					.findViewById(R.id.card_balance_content);

			convertView.setTag(listItem);
		} else
			listItem = (ListItem) convertView.getTag();

		listItem.cardNameTitle.setText(mBalanceCardInfo.get(position).getCardName());
		int actionMode=mBalanceCardInfo.get(position).getActionMode();
		if(actionMode==1 || actionMode==9 || actionMode==11){
			// 非储值卡
			if (mBalanceCardInfo.get(position).getCardType() != 1) {
				listItem.nonCardAmount.setVisibility(View.VISIBLE);
				// 现金券
				if (mBalanceCardInfo.get(position).getCardType() != 2) {
					if (!mBalanceCardInfo.get(position).getAmount().equals(""))
						listItem.nonCardAmount.setText(NumberFormatUtil.StringFormatToString(mContext, mBalanceCardInfo.get(position).getAbsCardPaidAmount())+ "抵");
					listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToString(mContext,mBalanceCardInfo.get(position).getAbsAmount()));

				}
				// 积分
				else {
					if (!mBalanceCardInfo.get(position).getAmount().equals(""))
						listItem.nonCardAmount.setText(NumberFormatUtil.StringFormatToStringWithoutSingle(mBalanceCardInfo.get(position).getAbsCardPaidAmount())+ "抵");
						listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToString(mContext, mBalanceCardInfo.get(position).getAbsAmount()));
						
				}

			}
			// 储值卡
			else {
				listItem.nonCardAmount.setVisibility(View.GONE);
				listItem.tradingAmount.setText(NumberFormatUtil
						.StringFormatToString(mContext,
								mBalanceCardInfo.get(position).getAbsAmount()));

			}
		}
		else if(actionMode==3){
			listItem.nonCardAmount.setVisibility(View.GONE);
			// 非储值卡
			if (mBalanceCardInfo.get(position).getCardType() != 1) {
			// 现金券
			if (mBalanceCardInfo.get(position).getCardType() != 2) {
					listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToString(mContext, mBalanceCardInfo.get(position).getAbsAmount()));
				}
			// 积分
			else {
					if (!mBalanceCardInfo.get(position).getAmount().equals(""))
						listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToStringWithoutSingle(mBalanceCardInfo.get(position).getAbsAmount()));
									
					}
				}
			// 储值卡
			else {			
				listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToString(mContext,mBalanceCardInfo.get(position).getAbsAmount()));
				}
		}
		else {
			listItem.nonCardAmount.setVisibility(View.GONE);
			// 非储值卡
			if (mBalanceCardInfo.get(position).getCardType() != 1) {
			// 现金券
			if (mBalanceCardInfo.get(position).getCardType() != 2) {
					listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToString(mContext, mBalanceCardInfo.get(position).getAbsCardPaidAmount()));
				}
			// 积分
			else {
					if (!mBalanceCardInfo.get(position).getAmount().equals(""))
						listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToStringWithoutSingle(mBalanceCardInfo.get(position).getAbsCardPaidAmount()));
									
					}
				}
			// 储值卡
			else {			
				listItem.tradingAmount.setText(NumberFormatUtil.StringFormatToString(mContext,mBalanceCardInfo.get(position).getAbsAmount()));
				}
		}

		if (mBalanceCardInfo.get(position).getCardType() != 2) {
			listItem.cardBalanceContent.setText(NumberFormatUtil
					.StringFormatToString(mContext,
							mBalanceCardInfo.get(position).getBalance()));
		} else {
			listItem.cardBalanceContent.setText(NumberFormatUtil
					.StringFormatToStringWithoutSingle(mBalanceCardInfo.get(
							position).getBalance()));
		}

		return convertView;
	}

	public final class ListItem {
		TableLayout balanceCardInfoLayout;
		RelativeLayout balanceTradingLayout;
		TextView cardNameTitle;
		TextView nonCardAmount;
		TextView tradingAmount;
		RelativeLayout cardBalanceLayout;
		TextView cardBalanceTitle;
		TextView cardBalanceContent;
	}
}
