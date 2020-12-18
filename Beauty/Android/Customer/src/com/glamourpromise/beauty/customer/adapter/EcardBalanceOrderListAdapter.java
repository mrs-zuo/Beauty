package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EcardBalanceOrderListAdapter extends BaseAdapter {

	private Activity mContext;
	private List<OrderBaseInfo> mOrderList;
	private LayoutInflater inflater;

	public EcardBalanceOrderListAdapter(Activity context,
			List<OrderBaseInfo> orderList) {
		this.mContext = context;
		this.mOrderList = orderList;
		inflater = LayoutInflater.from(context);

	}

	@Override
	public int getCount() {
		return mOrderList.size();
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
			convertView = inflater.inflate(R.xml.ecard_balance_order_list_info_item, null);

			listItem.orderListTableLayout = (TableLayout) convertView.findViewById(R.id.ecard_balance_order_list_info_table_layout);
			listItem.orderListInfoRelativeLayout = (RelativeLayout) convertView.findViewById(R.id.ecard_balance_order_list_info_relative_layout);
			listItem.orderListImg = (ImageView) convertView.findViewById(R.id.ecard_balance_order_list_info_arrow_btn);
			listItem.cellLinearLayout = (LinearLayout) convertView.findViewById(R.id.ecard_order_cell_linearlayout);
			listItem.orderNumRelativeLayout = (RelativeLayout) convertView.findViewById(R.id.ecard_order_number_relative_layout);
			listItem.ecardOrderNumTitle = (TextView) convertView.findViewById(R.id.ecard_order_number_title);
			listItem.ecardOrderNumContent = (TextView) convertView.findViewById(R.id.ecard_order_number_content);
			listItem.cellProductName_PriceLayout = (LinearLayout) convertView
					.findViewById(R.id.ecard_order_cell_product_name_and_price_layout);
			listItem.productNameRelativeLayout = (RelativeLayout) convertView
					.findViewById(R.id.ecard_product_name_relative_layout);
			listItem.ecardProductNameTitle = (TextView) convertView
					.findViewById(R.id.ecard_product_name__title);
			listItem.totalSalePriceRelativeLayout = (RelativeLayout) convertView
					.findViewById(R.id.ecard_total_sale_price_relative_layout);
			listItem.totalSalePriceTitle = (TextView) convertView
					.findViewById(R.id.total_sale_price_title);
			listItem.totalSalePriceContent = (TextView) convertView
					.findViewById(R.id.total_sale_price_content);

			convertView.setTag(listItem);
		} else
			listItem = (ListItem) convertView.getTag();

		listItem.ecardOrderNumContent.setText(mOrderList.get(position)
				.getOrderNumber());
		listItem.ecardProductNameTitle.setText(mOrderList.get(position)
				.getProductName());
		listItem.totalSalePriceContent.setText(NumberFormatUtil
				.StringFormatToString(mContext, mOrderList.get(position)
						.getTotalSalePrice()));
		return convertView;
	}

	public final class ListItem {
		TableLayout orderListTableLayout;
		RelativeLayout orderListInfoRelativeLayout;
		ImageView orderListImg;
		LinearLayout cellLinearLayout;
		RelativeLayout orderNumRelativeLayout;
		TextView ecardOrderNumTitle;
		TextView ecardOrderNumContent;
		LinearLayout cellProductName_PriceLayout;
		RelativeLayout productNameRelativeLayout;
		TextView ecardProductNameTitle;
		RelativeLayout totalSalePriceRelativeLayout;
		TextView totalSalePriceTitle;
		TextView totalSalePriceContent;
	}

}
