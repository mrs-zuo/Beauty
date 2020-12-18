package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

import cn.com.antika.bean.BranchInfo;
import cn.com.antika.business.R;


@SuppressLint("ResourceType")
public class BranchListAdapter extends BaseAdapter{
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private ArrayList<BranchInfo> mBranchList;
	
	public BranchListAdapter(Context context, ArrayList<BranchInfo> branchList){
		mBranchList = branchList;
		mContext = context;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mBranchList.size();
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
		branchItem branchItem=null;
		if(convertView==null)
		{
			branchItem=new branchItem();
			convertView=layoutInflater.inflate(R.xml.branch_list_item,null);
			branchItem.companyIcon=(ImageView)convertView.findViewById(R.id.companyname_icon);
			branchItem.branchText=(TextView)convertView.findViewById(R.id.branchname_text);
			branchItem.addressIcon=(ImageView)convertView.findViewById(R.id.companyaddress_icon);
			branchItem.addressText=(TextView)convertView.findViewById(R.id.branchaddress_text);
			convertView.setTag(branchItem);
		}
		else
		{
			branchItem=(branchItem)convertView.getTag();
		}
		branchItem.branchText.setText(mBranchList.get(position).getName());
		branchItem.addressText.setText(mBranchList.get(position).getAddress());
		return convertView;
	}

	public final class branchItem
	{
		public ImageView companyIcon;
		public TextView  branchText;
		public ImageView addressIcon;
		public TextView  addressText;
	}
	
}
