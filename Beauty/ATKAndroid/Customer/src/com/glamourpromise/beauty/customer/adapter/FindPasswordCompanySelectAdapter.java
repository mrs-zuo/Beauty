package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.UserInformation;

public class FindPasswordCompanySelectAdapter  extends BaseAdapter{
	private LayoutInflater layoutInflater;
	private List<UserInformation> usernformationList;
	private ArrayList<UserInformation> mArrSelect;
	private ArrayList<Boolean> mArrSelectFlag;
	private int mSelectCount;
	private onButtonClickListener mListener;
	
	public interface onButtonClickListener{
		public void onClick(boolean isAllselected);
	}

	public FindPasswordCompanySelectAdapter(Context context, List<UserInformation> usernformationList, onButtonClickListener listener){
		this.usernformationList = usernformationList;
		this.mListener = listener;
		layoutInflater = LayoutInflater.from(context);
		mArrSelectFlag = new ArrayList<Boolean>(5);
		mArrSelect = new ArrayList<UserInformation>(5);
		final int count = usernformationList.size();
		mSelectCount = 0;
		for(int i = 0; i < count; i++){
			mArrSelectFlag.add(false);
		}
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return usernformationList.size();
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
		if (convertView == null) {
			convertView = layoutInflater.inflate(R.xml.company_select_item,null);
		}
		CompanySelectItem.tvCompanyName = (TextView) convertView.findViewById(R.id.company_name);
		CompanySelectItem.btnSelect = (ImageButton) convertView.findViewById(R.id.company_select_button);
		
		CompanySelectItem.btnSelect.setVisibility(View.VISIBLE);
		final int finalPos = position;
		final View v = convertView;
		CompanySelectItem.btnSelect.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				changeSelectStatus(finalPos);
				changeStatus(finalPos, v);
			}
		});
		setIconBySelectStatus(mArrSelectFlag.get(position), v);
		CompanySelectItem.tvCompanyName.setText(usernformationList.get(position).getCompanyName());
		return convertView;
	}
	
	public ArrayList<UserInformation> getSelectList(){
		int pos = 0;
		mArrSelect = new ArrayList<UserInformation>();
		for(Boolean status:mArrSelectFlag){
			if(status){
				mArrSelect.add(usernformationList.get(pos));
			}
			pos++;
		}
		return mArrSelect;
	}
	
	public String getSelectCompanyIDs(){
		StringBuilder ids=new StringBuilder();
		int pos = 0;
		for(Boolean status:mArrSelectFlag){
			if(status){
				mArrSelect.add(usernformationList.get(pos));
				ids.append(usernformationList.get(pos).getUserID());
				if(pos < getCount()-1)
					ids.append(",");
			}
			pos++;
		}
		return ids.toString();
	}
	
	public int getSelectCount(){
		return mSelectCount;
	}
	
	private void setIconBySelectStatus(boolean status, View v){
		if(status){
			v.findViewById(R.id.company_select_button).setBackgroundResource(R.drawable.one_select_icon);
		}else{
			v.findViewById(R.id.company_select_button).setBackgroundResource(R.drawable.one_unselect_icon);
		}
		
	}
	
	private void changeStatus(int pos, View v){
		if(mArrSelectFlag.get(pos)){
			mSelectCount++;
			setIconBySelectStatus(true, v);
		}else{
			mSelectCount--;
			setIconBySelectStatus(false, v);
		}
		
		if(mSelectCount == getCount()){
			mListener.onClick(true);
		}else{
			mListener.onClick(false);
		}
	}
	
	public void setSelectAllStatus(boolean newStatus){
		int size = mArrSelectFlag.size();
		if(newStatus){
			mSelectCount = size;
		}else{
			mSelectCount = 0;
		}
		for(int i = 0; i < size; i++){
			mArrSelectFlag.set(i, newStatus);
		}
		notifyDataSetChanged();
	}
	
	private void changeSelectStatus(int pos) {
		mArrSelectFlag.set(pos, !mArrSelectFlag.get(pos));
	}
	
	public static final class CompanySelectItem {
		public static TextView tvCompanyName;
		public static ImageButton btnSelect;
	}
}
