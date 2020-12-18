package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.AccountInformation;
import com.squareup.picasso.Picasso;

public class AccountListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<AccountInformation> accountListMap;
    int fromSource;
	public AccountListAdapter(Context context, List<AccountInformation> accountList , int fromSource) {
		this.mContext = context;
		this.accountListMap = accountList;
		layoutInflater = LayoutInflater.from(mContext);
		this.fromSource=fromSource;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return accountListMap.size();
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
		AccountItem accountItem = null;
		if (convertView == null) {
			accountItem = new AccountItem();
			convertView = layoutInflater.inflate(R.xml.account_list_item, null);
			accountItem.accountHeadImage = (ImageView) convertView.findViewById(R.id.account_headimage);
			accountItem.accountName = (TextView) convertView.findViewById(R.id.account_name);
			accountItem.accountTitle = (TextView) convertView.findViewById(R.id.account_title);
			accountItem.arrowHead = (ImageView) convertView.findViewById(R.id.arrowhead);
			convertView.setTag(accountItem);
		} else {
			accountItem = (AccountItem) convertView.getTag();
		}
		if(fromSource!=0){
			accountItem.arrowHead.setVisibility(View.GONE);
		}
		//设置Image
		String url = accountListMap.get(position).getHeadImageURL();
		if (!url.equals("")) {
			Picasso.with(mContext).load(url).error(R.drawable.head_image_null).into(accountItem.accountHeadImage);
		} else {
			accountItem.accountHeadImage.setImageResource(R.drawable.head_image_null);
		}
		//设置AccountName
		if (!accountListMap.get(position).getAccountName().equals("")) {
			accountItem.accountName.setText((String)accountListMap.get(position).getAccountName());
		}else{
			accountItem.accountName.setText("无");
		}
		//设置Title
		if (!accountListMap.get(position).getTitle().equals("")) {
			accountItem.accountTitle.setText((String)(accountListMap.get(position).getTitle()));
		}else{
			accountItem.accountTitle.setText("");
		}
		
		return convertView;
	}
	public List<AccountInformation> getAccountList(){
		return  accountListMap;
	}

	public final class AccountItem {
		public ImageView accountHeadImage;
		public TextView  accountName;
		public TextView  accountTitle;
		public ImageView arrowHead;
	}

}
