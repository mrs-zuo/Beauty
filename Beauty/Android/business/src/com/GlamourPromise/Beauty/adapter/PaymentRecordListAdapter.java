package com.GlamourPromise.Beauty.adapter;

import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.PaymentRecord;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class PaymentRecordListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<PaymentRecord> paymentRecordList;
	private String              currency;
	public PaymentRecordListAdapter(Context context,List<PaymentRecord> paymentRecordList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.paymentRecordList = paymentRecordList;
		currency=UserInfoApplication.getInstance().getAccountInfo().getCurrency();
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return paymentRecordList.size();
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

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		PaymentRecordItem paymentRecordItem = null;
		if (convertView == null) {
			paymentRecordItem = new PaymentRecordItem();
			convertView = layoutInflater.inflate(R.xml.payment_record_list_item, null);
			paymentRecordItem.paymentRecordTitleText = (TextView) convertView.findViewById(R.id.payment_record_title_text);
			paymentRecordItem.paymentRecordRemarkIcon = (ImageView) convertView.findViewById(R.id.payment_record_remark_icon);
			paymentRecordItem.paymentRecordTimeText = (TextView) convertView.findViewById(R.id.payment_record_time_text);
			paymentRecordItem.paymentRecordAmountText = (TextView) convertView.findViewById(R.id.payment_record_amount_text);
			paymentRecordItem.paymentRecordPaymentModelCash = (ImageView) convertView.findViewById(R.id.payment_record_paymentmode_crash);
			paymentRecordItem.paymentRecordPaymentModelBankCard = (ImageView) convertView.findViewById(R.id.payment_record_paymentmode_bank_card);
			paymentRecordItem.paymentRecordPaymentModelOther = (ImageView) convertView.findViewById(R.id.payment_record_paymentmode_other);
			paymentRecordItem.paymentRecordPaymentModelEcard = (ImageView) convertView.findViewById(R.id.payment_record_paymentmode_e_card);
			paymentRecordItem.paymentRecordPaymentModelWeiXin=(ImageView) convertView.findViewById(R.id.payment_record_paymentmode_weixin);
			paymentRecordItem.paymentRecordArrowhead = (ImageView) convertView.findViewById(R.id.payment_record_arrowhead);
			convertView.setTag(paymentRecordItem);
		} else {
			paymentRecordItem = (PaymentRecordItem) convertView.getTag();
		}
		paymentRecordItem.paymentRecordTitleText.setText(paymentRecordList.get(position).getPaymentRecordTitle());
		boolean paymentRecordRemark = paymentRecordList.get(position).isPaymentRecordHasRemark();
		if (paymentRecordRemark) {
			paymentRecordItem.paymentRecordRemarkIcon.setVisibility(View.VISIBLE);
		} else {
			paymentRecordItem.paymentRecordRemarkIcon.setVisibility(View.GONE);
		}
		String paymentModel = paymentRecordList.get(position).getPaymentRecordModel();
		if(paymentModel.contains("|8|")){
			paymentRecordItem.paymentRecordPaymentModelWeiXin.setVisibility(View.VISIBLE);
		}
		else{
			paymentRecordItem.paymentRecordPaymentModelWeiXin.setVisibility(View.GONE);
			if (paymentModel.contains("|0|")) {
				paymentRecordItem.paymentRecordPaymentModelCash.setVisibility(View.VISIBLE);
			} else {
				paymentRecordItem.paymentRecordPaymentModelCash.setVisibility(View.GONE);
			}
			if (paymentModel.contains("|2|")) {
				paymentRecordItem.paymentRecordPaymentModelBankCard.setVisibility(View.VISIBLE);
			} else {
				paymentRecordItem.paymentRecordPaymentModelBankCard.setVisibility(View.GONE);
			}
			if (paymentModel.contains("|1|")) {
				paymentRecordItem.paymentRecordPaymentModelEcard.setVisibility(View.VISIBLE);
			} else {
				paymentRecordItem.paymentRecordPaymentModelEcard.setVisibility(View.GONE);
			}
			if (paymentModel.contains("|3|")) {
				paymentRecordItem.paymentRecordPaymentModelOther.setVisibility(View.VISIBLE);
			} else {
				paymentRecordItem.paymentRecordPaymentModelOther.setVisibility(View.GONE);
			}
		}
		paymentRecordItem.paymentRecordTimeText.setText(paymentRecordList.get(position).getPaymentRecordTime());
		paymentRecordItem.paymentRecordAmountText.setText(currency+NumberFormatUtil.currencyFormat(paymentRecordList.get(position).getPaymentRecordAmount()));
		return convertView;
	}

	public final class PaymentRecordItem {
		public TextView paymentRecordTitleText;
		public ImageView paymentRecordRemarkIcon;
		public TextView paymentRecordTimeText;
		public TextView paymentRecordAmountText;
		public ImageView paymentRecordPaymentModelCash;
		public ImageView paymentRecordPaymentModelBankCard;
		public ImageView paymentRecordPaymentModelOther;
		public ImageView paymentRecordPaymentModelEcard;
		public ImageView paymentRecordPaymentModelWeiXin;
		public ImageView paymentRecordArrowhead;
	}
}
