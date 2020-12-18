package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.CustomerCardInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EcardDetailListAdapter extends BaseAdapter {
	private List<CustomerCardInfo> cardList = new ArrayList<CustomerCardInfo>();
	private LayoutInflater inflater;
	private Activity mContext;

	public EcardDetailListAdapter(Activity mContext,
			List<CustomerCardInfo> mCardList) {
		this.cardList = mCardList;
		this.mContext = mContext;
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
		ListItem listItem = null;

		if (convertView == null) {
			if (position == cardList.size() - 1) {
				listItem = new ListItem();
				convertView = inflater.inflate(R.xml.ecard_detail_list_item,
						null);
				;
				listItem.tableLayout = (RelativeLayout) convertView
						.findViewById(R.id.ecard_cell_table_layout);
				listItem.cardName = (TextView) convertView
						.findViewById(R.id.card_name_txt);
				listItem.cardBalance = (TextView) convertView
						.findViewById(R.id.card_balance_txt);
				listItem.defaultCardImg = (ImageView) convertView
						.findViewById(R.id.default_card_img);
			}

			else {
				listItem = new ListItem();
				convertView = inflater.inflate(R.xml.ecard_detail_list_item,
						null);
				;
				listItem.tableLayout = (RelativeLayout) convertView
						.findViewById(R.id.ecard_cell_table_layout);
				listItem.cardName = (TextView) convertView
						.findViewById(R.id.card_name_txt);
				listItem.cardBalance = (TextView) convertView
						.findViewById(R.id.card_balance_txt);
				listItem.defaultCardImg = (ImageView) convertView
						.findViewById(R.id.default_card_img);
			}
			convertView.setTag(listItem);

		} else
			listItem = (ListItem) convertView.getTag();

		if (position == cardList.size() - 1) {
			switch (position % 3) {
			case 0:
				listItem.tableLayout
						.setBackgroundResource(R.drawable.table_card_list_last_item_shape);
				break;
			case 1:
				listItem.tableLayout
						.setBackgroundResource(R.drawable.table_card_list_last_item_shape_red);
				break;
			case 2:
				listItem.tableLayout
						.setBackgroundResource(R.drawable.table_card_list_last_item_shape_purple);
				break;
			}
			;
		} else {

			switch (position % 3) {
			case 0:
				listItem.tableLayout
						.setBackgroundResource(R.drawable.table_card_list_cornershape);
				break;
			case 1:
				listItem.tableLayout
						.setBackgroundResource(R.drawable.table_card_list_cornershape_red);
				break;
			case 2:
				listItem.tableLayout
						.setBackgroundResource(R.drawable.table_card_list_cornershape_purple);
				break;
			}
			;

		}
		if (cardList.get(position).getIsDefault())
			listItem.defaultCardImg.setVisibility(View.VISIBLE);
		else
			listItem.defaultCardImg.setVisibility(View.INVISIBLE);
		listItem.cardName.setText(cardList.get(position).getCardName());
		listItem.cardBalance.setText(mContext
				.getString(R.string.title_ecard_balance)
				+ " : "
				+ NumberFormatUtil.StringFormatToString(mContext,
						cardList.get(position).getBalance()));

		return convertView;
	}

	public final class ListItem {
		RelativeLayout tableLayout;
		TextView cardName;
		TextView cardBalance;
		ImageView defaultCardImg;
	}

}
