package com.glamourpromise.beauty.customer.adapter;
import java.util.List;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.Branch;

public class BranchSelectAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<Branch> branchList;

	public BranchSelectAdapter(Context context,List<Branch> branchList) {
		this.mContext = context;
		this.branchList = branchList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return branchList.size();
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
		BranchSelectItem branchSelectItem = null;
		if (convertView == null) {
			branchSelectItem = new BranchSelectItem();
			convertView = layoutInflater.inflate(R.xml.branch_select_item,null);
			branchSelectItem.branchName = (TextView) convertView.findViewById(R.id.branch_name);
			convertView.setTag(branchSelectItem);
		} else {
			branchSelectItem = (BranchSelectItem)convertView.getTag();
		}
		branchSelectItem.branchName.setText(branchList.get(position).getName());
		return convertView;
	}

	public final class BranchSelectItem {
		public TextView branchName;
	}

}
