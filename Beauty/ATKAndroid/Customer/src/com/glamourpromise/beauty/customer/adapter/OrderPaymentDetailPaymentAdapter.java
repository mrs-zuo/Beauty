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
import com.glamourpromise.beauty.customer.bean.PaymentDetailInfo;

public class OrderPaymentDetailPaymentAdapter extends BaseAdapter {

	private Context context;
	private LayoutInflater inflater;
	private List<PaymentDetailInfo> paymentDetail = new ArrayList<PaymentDetailInfo>();
	private String currencySymbol;

	public OrderPaymentDetailPaymentAdapter(Context mContext,
			List<PaymentDetailInfo> mPaymentDetail, String mCurrencySymbol) {
		this.context = mContext;
		this.paymentDetail = mPaymentDetail;
		this.currencySymbol = mCurrencySymbol;
		inflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		return paymentDetail.size();
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
		AmountListItem listItem = null;
		if (convertView == null) {
			listItem = new AmountListItem();
			convertView = inflater.inflate(
					R.xml.order_payment_detail_list_item, null);
			listItem.divider = (View) convertView
					.findViewById(R.id.layout_divider);
			listItem.paymentdetailLayout = (RelativeLayout) convertView
					.findViewById(R.id.order_payment_detail_list_item_card_layout);
			listItem.cardTypeTitle = (TextView) convertView
					.findViewById(R.id.card_type_title);
			listItem.paymentAmount = (TextView) convertView
					.findViewById(R.id.card_payment_amount);
			listItem.bonus = (TextView) convertView
					.findViewById(R.id.order_payment_detail_list_item_payment_amount);

			convertView.setTag(listItem);
		} else
			listItem = (AmountListItem) convertView.getTag();

		listItem.cardTypeTitle.setText(paymentDetail.get(position)
				.getCardName());
		int cardType = paymentDetail.get(position).getCardType();
		listItem.bonus.setVisibility(View.VISIBLE);

		if (cardType != 2) {
			if (cardType == 1 || cardType == 0)
				listItem.bonus.setVisibility(View.INVISIBLE);
			else
				listItem.bonus
						.setText(currencySymbol
								+ paymentDetail.get(position)
										.getCardPaidAmount() + "抵");
		} else
			listItem.bonus.setText(paymentDetail.get(position)
					.getCardPaidAmount() + "抵");

		listItem.paymentAmount.setText(currencySymbol
				+ paymentDetail.get(position).getPaymentAmount());
		return convertView;
	}

	public final class AmountListItem {
		View divider;
		RelativeLayout paymentdetailLayout;
		TextView cardTypeTitle;
		TextView bonus;
		TextView paymentAmount;
	}

}
