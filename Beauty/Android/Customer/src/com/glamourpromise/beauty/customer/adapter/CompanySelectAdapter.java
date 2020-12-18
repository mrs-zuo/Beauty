package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.LoginInformation;

public class CompanySelectAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<LoginInformation> loginInformationList;

	public CompanySelectAdapter(Context context,
			List<LoginInformation> loginInformationList) {
		this.mContext = context;
		this.loginInformationList = loginInformationList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		if(loginInformationList!=null && loginInformationList.size()>0)
			return loginInformationList.size();
		else
			return 0;
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
		CompanySelectItem companySelectItem = null;
		if (convertView == null) {
			companySelectItem = new CompanySelectItem();
			convertView = layoutInflater.inflate(R.xml.company_select_item,
					null);
			companySelectItem.companyName = (TextView) convertView
					.findViewById(R.id.company_name);
			convertView.setTag(companySelectItem);
		} else {
			companySelectItem = (CompanySelectItem) convertView.getTag();
		}
		
		Log.v("CompanyAbbreviation", loginInformationList.get(position).getCompanyAbbreviation());
		companySelectItem.companyName.setText(loginInformationList.get(position).getCompanyAbbreviation());
		return convertView;
	}

	public final class CompanySelectItem {
		public TextView companyName;
	}

}
