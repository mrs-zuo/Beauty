package com.GlamourPromise.Beauty.adapter;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchStatistics;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class BranchEmployeeBusinessListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<BranchStatistics> branchStatisticsList;
	private int    mObjectType;
	private UserInfoApplication userinfoApplication;
	public BranchEmployeeBusinessListAdapter(Context context,List<BranchStatistics> branchStatisticsList,int objectType,UserInfoApplication  userinfoApplication) {
		this.mContext = context;
		this.branchStatisticsList = branchStatisticsList;
		layoutInflater = LayoutInflater.from(mContext);
		this.mObjectType=objectType;
		this.userinfoApplication=userinfoApplication;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return branchStatisticsList.size();
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
		BranchStatisticsListItem bsItem = null;
		if (convertView == null) {
			bsItem = new BranchStatisticsListItem();
			convertView = layoutInflater.inflate(R.xml.branch_employee_business_list_item, null);
			bsItem.objectName = (TextView) convertView.findViewById(R.id.branch_employee_business_list_object_name);
			bsItem.objectCount = (TextView) convertView.findViewById(R.id.branch_employee_business_list_sales_amount);
			convertView.setTag(bsItem);
		} else {
			bsItem = (BranchStatisticsListItem) convertView.getTag();
		}
		bsItem.objectName.setTextColor(mContext.getResources().getColor(R.color.black));
		bsItem.objectName.setText(position+1+"    "+branchStatisticsList.get(position).getObjectName());
		if(mObjectType==1)
			bsItem.objectCount.setText(branchStatisticsList.get(position).getObjectCount()+"次");
		else if(mObjectType==2)
			bsItem.objectCount.setText(userinfoApplication.getAccountInfo().getCurrency()+NumberFormatUtil.currencyFormat(String.valueOf(branchStatisticsList.get(position).getConsumeAmount())));
		else if(mObjectType==3)
			bsItem.objectCount.setText(userinfoApplication.getAccountInfo().getCurrency()+NumberFormatUtil.currencyFormat(String.valueOf(branchStatisticsList.get(position).getRechargeAmount())));
		return convertView;
	}

	public final class BranchStatisticsListItem {
		public TextView objectName;
		public TextView objectCount;
	}

}
