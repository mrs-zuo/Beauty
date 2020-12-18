package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.OrderPaymentInfo;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class OrderPaymentDetailAdapter extends BaseAdapter {
	private ArrayList<OrderPaymentInfo> mOrderPaymentInfoList;
	private String mCurrencySymbols;
	private String mOrderPrice;
	private Context mContext;
	private LayoutInflater layoutInflater;

	public OrderPaymentDetailAdapter(Context content,
			ArrayList<OrderPaymentInfo> orderPaymentInfoList,
			String orderPrice, String currencySymbols) {
		mContext = content;
		mOrderPrice = orderPrice;
		mCurrencySymbols = currencySymbols;
		mOrderPaymentInfoList = orderPaymentInfoList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mOrderPaymentInfoList.size();
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
		OrderPaymentDetailItem orderPaymentItem = null;
		if (convertView == null) {
			orderPaymentItem = new OrderPaymentDetailItem();
			convertView = layoutInflater.inflate(R.xml.order_payment_list_item,
					null);
			orderPaymentItem.OrderPayCodeView = (TextView) convertView
					.findViewById(R.id.payment_code);
			orderPaymentItem.OrderPayTimeView = (TextView) convertView
					.findViewById(R.id.payment_time);
			orderPaymentItem.OrderOperatorView = (TextView) convertView
					.findViewById(R.id.operator);
			orderPaymentItem.OrderTotalAmountView = (TextView) convertView
					.findViewById(R.id.payment_amount);
			orderPaymentItem.OrderBranchDivider = (View) convertView
					.findViewById(R.id.order_payment_list_branch_name_divider);
			orderPaymentItem.OrderBranchLayout = (RelativeLayout) convertView
					.findViewById(R.id.order_payment_list_branch_name_layout);
			orderPaymentItem.OrderBranchNameView = (TextView) convertView
					.findViewById(R.id.order_branch_name_content);
			orderPaymentItem.paymentDetailListView = (NoScrollListView) convertView
					.findViewById(R.id.payment_detail_list_view);
			orderPaymentItem.listAdapter = new OrderPaymentDetailPaymentAdapter(
					mContext, mOrderPaymentInfoList.get(position)
							.getPaymentDetailList(), mCurrencySymbols);

			// orderPaymentItem.OrderBankAmountView = (TextView) convertView
			// .findViewById(R.id.bank_card_payment_amount);
			// orderPaymentItem.OrderEcardAmountView = (TextView) convertView
			// .findViewById(R.id.ecard_payment_amount);
			// orderPaymentItem.OrderCarshAmountView = (TextView) convertView
			// .findViewById(R.id.crash_payment_amount);
			// orderPaymentItem.OrderOtherAmountView = (TextView) convertView
			// .findViewById(R.id.other_payment_amount);
			// orderPaymentItem.OrderRemarkView = (TextView) convertView
			// .findViewById(R.id.remark_content);
			convertView.setTag(orderPaymentItem);
		} else
			orderPaymentItem = (OrderPaymentDetailItem) convertView.getTag();

		orderPaymentItem.OrderPayCodeView.setText(mOrderPaymentInfoList.get(
				position).getPaymentCode());
		orderPaymentItem.OrderPayTimeView.setText(mOrderPaymentInfoList.get(
				position).getPaymentTime());
		orderPaymentItem.OrderOperatorView.setText(mOrderPaymentInfoList.get(
				position).getOperator());

		if (mOrderPaymentInfoList.get(position).getBranchName().equals("")){
			orderPaymentItem.OrderBranchLayout.setVisibility(View.GONE);
			orderPaymentItem.OrderBranchDivider.setVisibility(View.GONE);
		}
		else {
			orderPaymentItem.OrderBranchDivider.setVisibility(View.VISIBLE);
			orderPaymentItem.OrderBranchLayout.setVisibility(View.VISIBLE);
			orderPaymentItem.OrderBranchNameView.setText(mOrderPaymentInfoList
					.get(position).getBranchName());
		}
		orderPaymentItem.OrderTotalAmountView.setText(mCurrencySymbols
				+ mOrderPaymentInfoList.get(position).getTotalPrice());

		if (mOrderPaymentInfoList.get(position).getPaymentDetailList().size() > 0) {
			orderPaymentItem.paymentDetailListView.setVisibility(View.VISIBLE);
			orderPaymentItem.paymentDetailListView
					.setAdapter(orderPaymentItem.listAdapter);
		} else
			orderPaymentItem.paymentDetailListView.setVisibility(View.GONE);

		// if(mOrderPaymentInfoList.get(position).getOrderNumber() > 1){
		// orderPaymentItem.OrderTotalAmountView.setText(mCurrencySymbols +
		// mOrderPrice);
		// }else{
		// orderPaymentItem.OrderTotalAmountView.setText(mCurrencySymbols +
		// mOrderPaymentInfoList.get(position).getTotalAmount());
		// }
		//
		// if(mOrderPaymentInfoList.get(position).getBankCardAmount().equals("")
		// ||
		// mOrderPaymentInfoList.get(position).getBankCardAmount().equals("0.00")){
		// convertView.findViewById(R.id.bank_card_layout_above_line).setVisibility(View.GONE);
		// convertView.findViewById(R.id.bank_card_layout).setVisibility(View.GONE);
		// }else if(mOrderPaymentInfoList.get(position).getOrderNumber() > 1){
		// orderPaymentItem.OrderBankAmountView.setText(mCurrencySymbols +
		// mOrderPrice);
		// }else {
		// orderPaymentItem.OrderBankAmountView.setText(mCurrencySymbols +
		// mOrderPaymentInfoList.get(position).getBankCardAmount());
		// }
		//
		// if(mOrderPaymentInfoList.get(position).getEcardAmount().equals("")||
		// mOrderPaymentInfoList.get(position).getEcardAmount().equals("0.00")){
		// convertView.findViewById(R.id.ecard_card_layout_above_line).setVisibility(View.GONE);
		// convertView.findViewById(R.id.ecard_card_layout).setVisibility(View.GONE);
		// }else if(mOrderPaymentInfoList.get(position).getOrderNumber() > 1){
		// orderPaymentItem.OrderEcardAmountView.setText(mCurrencySymbols +
		// mOrderPrice);
		// }else{
		// orderPaymentItem.OrderEcardAmountView.setText(mCurrencySymbols +
		// mOrderPaymentInfoList.get(position).getEcardAmount());
		// }
		//
		// if(mOrderPaymentInfoList.get(position).getCashAmount().equals("")||
		// mOrderPaymentInfoList.get(position).getCashAmount().equals("0.00")){
		// convertView.findViewById(R.id.carsh_layout_above_line).setVisibility(View.GONE);
		// convertView.findViewById(R.id.carsh_layout).setVisibility(View.GONE);
		// }else if(mOrderPaymentInfoList.get(position).getOrderNumber() > 1){
		// orderPaymentItem.OrderCarshAmountView.setText(mCurrencySymbols +
		// mOrderPrice);
		// }else{
		// orderPaymentItem.OrderCarshAmountView.setText(mCurrencySymbols +
		// mOrderPaymentInfoList.get(position).getCashAmount());
		// }
		//
		// if(mOrderPaymentInfoList.get(position).getOtherAmount().equals("")||
		// mOrderPaymentInfoList.get(position).getOtherAmount().equals("0.00")){
		// convertView.findViewById(R.id.other_layout_above_line).setVisibility(View.GONE);
		// convertView.findViewById(R.id.other_layout).setVisibility(View.GONE);
		// }else if(mOrderPaymentInfoList.get(position).getOrderNumber() > 1){
		// orderPaymentItem.OrderOtherAmountView.setText(mCurrencySymbols +
		// mOrderPrice);
		// }else{
		// orderPaymentItem.OrderOtherAmountView.setText(mCurrencySymbols +
		// mOrderPaymentInfoList.get(position).getOtherAmount());
		// }

		// if(mOrderPaymentInfoList.get(position).getRemark().equals("")){
		// convertView.findViewById(R.id.remark_card_layout_above_line).setVisibility(View.GONE);
		// convertView.findViewById(R.id.remark_card_layout).setVisibility(View.GONE);
		// }else{
		// orderPaymentItem.OrderRemarkView.setText(mOrderPaymentInfoList.get(position).getRemark());
		// }
		//
		return convertView;
	}

	public final class OrderPaymentDetailItem {
		public TextView OrderPayCodeView;
		public TextView OrderPayTimeView;
		public TextView OrderOperatorView;
		public TextView OrderTotalAmountView;
		public View OrderBranchDivider;
		public RelativeLayout OrderBranchLayout;
		public TextView OrderBranchNameView;
		public NoScrollListView paymentDetailListView;
		public OrderPaymentDetailPaymentAdapter listAdapter;
		// public TextView OrderBankAmountView;
		// public TextView OrderEcardAmountView;
		// public TextView OrderCarshAmountView;
		// public TextView OrderOtherAmountView;
		// public TextView OrderRemarkView;
	}

}
