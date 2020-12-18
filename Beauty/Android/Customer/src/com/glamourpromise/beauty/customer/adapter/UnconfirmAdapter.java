package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.CommodityOrderDetailActivity;
import com.glamourpromise.beauty.customer.activity.ServcieOrderDetailActivity;
import com.glamourpromise.beauty.customer.activity.UnconfirmActivity;
import com.glamourpromise.beauty.customer.activity.UnconfirmActivity.ListItemClick;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.UnfinishTGListInfo;
import com.glamourpromise.beauty.customer.util.StatusUtil;

public class UnconfirmAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private List<UnfinishTGListInfo> mUnconfirmList;
	private List<Boolean> ItemSelectFlag;
	private int currentSelectCount;
	private ListItemClick listItemClick;
	private ClickListener mClickListener;
	private Context mContext;
	private OrderBaseInfo orderInformation = new OrderBaseInfo();

	public UnconfirmAdapter(Context context,List<UnfinishTGListInfo> unconfirmList, ListItemClick listItemClick) {
		this.listItemClick = listItemClick;
		this.mContext = context;
		mUnconfirmList = unconfirmList;
		currentSelectCount = 0;
		layoutInflater = LayoutInflater.from(context);
		mClickListener = new ClickListener();
		ItemSelectFlag = new ArrayList<Boolean>();
		for (int i = 0; i < unconfirmList.size(); i++)
			ItemSelectFlag.add(false);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mUnconfirmList.size();
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
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		UnconfirmItem unconfirmItem = null;
		if (convertView == null) {
			unconfirmItem = new UnconfirmItem();
			convertView = layoutInflater.inflate(R.xml.unconfirm_list_item,null);
			unconfirmItem.unconfirmRelativeLayout = (RelativeLayout) convertView.findViewById(R.id.unconfirm_list_relative_layout);
			unconfirmItem.orderName = (TextView) convertView.findViewById(R.id.order_name_text);
			unconfirmItem.orderCount = (TextView) convertView.findViewById(R.id.order_count);
			unconfirmItem.orderTime = (TextView) convertView.findViewById(R.id.order_time);
			unconfirmItem.orderResponsiblePersonName = (TextView) convertView.findViewById(R.id.order_responsible_person_name);
			unconfirmItem.selectView = (ImageButton) convertView.findViewById(R.id.select_view);
			unconfirmItem.selectView.setOnClickListener(mClickListener);
			convertView.setTag(unconfirmItem);
		} else
			unconfirmItem = (UnconfirmItem) convertView.getTag();
		unconfirmItem.selectView.setTag(position);
		unconfirmItem.orderName.setText(mUnconfirmList.get(position).getProductName());
		unconfirmItem.orderCount.setText(StatusUtil.ProductTypeTextStringUtil(mContext, mUnconfirmList.get(position).getProductType(),mUnconfirmList.get(position).getFinishedCount(), mUnconfirmList.get(position).getTotalCount()));
		unconfirmItem.orderTime.setText(mUnconfirmList.get(position).getTGStartTime());
		unconfirmItem.orderResponsiblePersonName.setText(mUnconfirmList.get(position).getAccountName());
		if (ItemSelectFlag.get(position))
			unconfirmItem.selectView.setBackgroundResource(R.drawable.one_select_icon);
		else
			unconfirmItem.selectView.setBackgroundResource(R.drawable.one_unselect_icon);
		final int mPosition = position;
		unconfirmItem.unconfirmRelativeLayout.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View v) {
				Intent destIntent = new Intent();
				Bundle bundle = new Bundle();
				orderInformation.setOrderObjectID(String.valueOf(mUnconfirmList.get(mPosition).getOrderObjectID()));
				orderInformation.setProductType(String.valueOf(mUnconfirmList.get(mPosition).getProductType()));
				if (mUnconfirmList.get(mPosition).getProductType() == 0)
					destIntent.setClass(mContext,ServcieOrderDetailActivity.class);
				else
					destIntent.setClass(mContext,CommodityOrderDetailActivity.class);

				bundle.putSerializable("OrderItem",orderInformation);
				destIntent.putExtras(bundle);
				mContext.startActivity(destIntent);
			}
		});
		return convertView;
	}

	public List<Boolean> getItemSelectFlag() {
		return ItemSelectFlag;
	}

	public void setItemSelectFlag(List<Boolean> itemSelectFlag) {
		ItemSelectFlag = itemSelectFlag;
	}

	public void setAllItemSelectStatus(Boolean status) {
		for (int i = 0; i < ItemSelectFlag.size(); i++) {
			ItemSelectFlag.set(i, status);
		}
		if (status)
			currentSelectCount = ItemSelectFlag.size();
		else
			currentSelectCount = 0;
	}

	public class ClickListener implements OnClickListener {

		@Override
		public void onClick(View v) {
			int pos = (Integer) v.getTag();
			if (ItemSelectFlag.get(pos)) {
				currentSelectCount--;
				ItemSelectFlag.set(pos, false);
				v.setBackgroundResource(R.drawable.one_unselect_icon);
			} else {
				currentSelectCount++;
				ItemSelectFlag.set(pos, true);
				v.setBackgroundResource(R.drawable.one_select_icon);
			}
			UnconfirmAdapter.this.notifyDataSetChanged();
			listItemClick.allOrderSelectProcess(currentSelectCount);
		}

	}

	public final class UnconfirmItem {
		public RelativeLayout unconfirmRelativeLayout;
		public TextView orderName;
		public TextView orderCount;
		public TextView orderTime;
		public TextView orderResponsiblePersonName;
		public ImageButton selectView;
	}
}
