package com.GlamourPromise.Beauty.adapter;
import java.util.List;

import com.GlamourPromise.Beauty.Business.OrderDetailActivity;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
/*
 * 待开单界面的适配器
 * */
@SuppressLint("ResourceType")
public class DispenseOrderListAdapter extends BaseAdapter {
	private LayoutInflater     layoutInflater;
	private Context            mContext;
	private List<OrderProduct> mOrderProductList;
	public DispenseOrderListAdapter(Context context,List<OrderProduct> orderProductList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		mOrderProductList=orderProductList;
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mOrderProductList.size();
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
		DispenseOrderItem dispenseOrderItem = null;
		final  int pos=position;
		if (convertView == null) {
			dispenseOrderItem = new DispenseOrderItem();
			convertView = layoutInflater.inflate(R.xml.dispense_order_list_item, null);
			dispenseOrderItem.orderProductNameText = (TextView) convertView.findViewById(R.id.dispense_order_product_name_text);
			dispenseOrderItem.orderPriceText = (TextView) convertView.findViewById(R.id.dispense_order_price);
			dispenseOrderItem.orderDeleteIcon = (ImageView) convertView.findViewById(R.id.delete_order_product_icon);
			convertView.setTag(dispenseOrderItem);
		} else {
			dispenseOrderItem = (DispenseOrderItem)convertView.getTag();
		}
		boolean isOldOrder=mOrderProductList.get(position).isOldOrder();
		dispenseOrderItem.orderProductNameText.setText(mOrderProductList.get(position).getProductName());
		if(isOldOrder)
			dispenseOrderItem.orderPriceText.setText(mOrderProductList.get(position).getResponsiblePersonName());
		else
			dispenseOrderItem.orderPriceText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency()+NumberFormatUtil.currencyFormat(mOrderProductList.get(position).getTotalPrice()));
		dispenseOrderItem.orderDeleteIcon.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Dialog dialog = new AlertDialog.Builder(mContext,R.style.CustomerAlertDialog)
						.setTitle(mContext.getString(R.string.delete_dialog_title))
						.setMessage(R.string.delete_prepare_order)
						.setPositiveButton(mContext.getString(R.string.delete_confirm),new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog,int which) {
								dialog.dismiss();
								if (mOrderProductList!=null && mOrderProductList.size() > pos){
									mOrderProductList.remove(mOrderProductList.get(pos));
									DispenseOrderListAdapter.this.notifyDataSetChanged();
								}
								((TextView) ((Activity) mContext).findViewById(R.id.tab_prepare_order_title)).setText("待开(" + (mOrderProductList != null ? mOrderProductList.size() : 0) + ")");
							}
						})
						.setNegativeButton(mContext.getString(R.string.delete_cancel),
								new DialogInterface.OnClickListener() {
									@Override
									public void onClick(DialogInterface dialog,int which) {
										dialog.dismiss();
										dialog = null;
									}
								}).create();
				dialog.show();
				dialog.setCancelable(false);
			}
		});
		return convertView;
	}
	public final class  DispenseOrderItem {
		public TextView  orderProductNameText;
		public TextView  orderPriceText;
		public ImageView orderDeleteIcon;
	}
}
