package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.Branch;
public  class BranchListAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private ArrayList<Branch> mBranchList;
	public BranchListAdapter(Context context, ArrayList<Branch> branchList)
	{
		this.mBranchList=branchList;
		layoutInflater=LayoutInflater.from(context);
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mBranchList.size();
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
		branchItem branchItem=null;
		if(convertView==null)
		{
			branchItem=new branchItem();
			convertView=layoutInflater.inflate(R.xml.branch_list_item,null);
			branchItem.branchText=(TextView)convertView.findViewById(R.id.branchname_text);
			branchItem.addressText=(TextView)convertView.findViewById(R.id.branchaddress_text);
			branchItem.distanceText=(TextView)convertView.findViewById(R.id.branch_distance_text);
			convertView.setTag(branchItem);
		}
		else
		{
			branchItem=(branchItem)convertView.getTag();
		}
		branchItem.branchText.setText(mBranchList.get(position).getName());
		branchItem.addressText.setText(mBranchList.get(position).getAddress());
		if(mBranchList.get(position).getDistance().equals("-1"))
			branchItem.distanceText.setText("未知");
		else	
			branchItem.distanceText.setText(mBranchList.get(position).getDistance()+"km");
		return convertView;
	}
	public final class branchItem
	{
		public TextView  branchText;
		public TextView  addressText;
		public TextView  distanceText;
	}
	
}
