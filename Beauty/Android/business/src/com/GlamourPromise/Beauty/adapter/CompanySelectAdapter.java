package com.GlamourPromise.Beauty.adapter;

import java.util.ArrayList;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.AccountInfo;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.TextView;
public class CompanySelectAdapter extends BaseExpandableListAdapter{
	private ArrayList<ArrayList<BranchInfo>> mBranchSelectList;
	private ArrayList<AccountInfo> mAccountInfoList;
	private LayoutInflater layoutInflater;
	private Context mContext;
	private CompanyItem companyItem;
	private BranchItem branchItem;
	public CompanySelectAdapter(Context context, ArrayList<AccountInfo> accountInfoList, ArrayList<ArrayList<BranchInfo>> BranchInfoList){
		mAccountInfoList = accountInfoList;
		mContext = context;
		layoutInflater = LayoutInflater.from(mContext);
		mBranchSelectList = BranchInfoList;
	}
	@Override
	public Object getChild(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return mBranchSelectList.get(arg0).get(arg1);
	}
	@Override
	public long getChildId(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return 0;
	}
	@Override
	public View getChildView(int groupPosition, int childPosition,  
            boolean isLastChild, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		convertView = layoutInflater.inflate(R.xml.branch_select_item, null);
		branchItem = new BranchItem();
		branchItem.branchName = (TextView) convertView.findViewById(R.id.branch_name);
		//子项集合不为空
		if(mBranchSelectList.get(groupPosition)!=null && mBranchSelectList.get(groupPosition).size()>0)
				branchItem.branchName.setText(mBranchSelectList.get(groupPosition).get(childPosition).getName());
		return convertView;
	}
	@Override
	public int getChildrenCount(int arg0) {
		// TODO Auto-generated method stub
		int childrenCount=0;
		if(mBranchSelectList.get(arg0)!=null && mBranchSelectList.get(arg0).size()>0)
			childrenCount=mBranchSelectList.get(arg0).size();
		return childrenCount;
	}
	@Override
	public Object getGroup(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}
	@Override
	public int getGroupCount() {
		// TODO Auto-generated method stub
		return mAccountInfoList.size();
	}
	@Override
	public long getGroupId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
	}
	@Override
	public View getGroupView(int groupPosition, boolean isExpanded,  View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		convertView = layoutInflater.inflate(R.xml.company_select_item, null);
		companyItem = new CompanyItem();
		companyItem.companyName = (TextView) convertView.findViewById(R.id.company_name);
		companyItem.companyName.setText(mAccountInfoList.get(groupPosition).getCompanyAbbreviation());
		return convertView;
	}
	@Override
	public boolean hasStableIds() {
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public boolean isChildSelectable(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return true;
	}
	public final class CompanyItem {
		public TextView companyName;
	}
	public final class BranchItem {
		public TextView branchName;
	}
}
