package com.GlamourPromise.Beauty.adapter;

import java.util.ArrayList;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.LabelInfo;
import com.GlamourPromise.Beauty.view.LabelView;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class LabelGridViewAdapter  extends BaseAdapter{
	private LayoutInflater layoutInflater;
	private ArrayList<LabelInfo> mLabelInfoList;
	private Context mContext;
	
	public LabelGridViewAdapter(Context context, ArrayList<LabelInfo> labelInfoList){
		mLabelInfoList = labelInfoList;
		mContext = context;
		layoutInflater = LayoutInflater.from(mContext);
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mLabelInfoList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return mLabelInfoList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		
		LabelItem photoAlbumItem = null;
		if(convertView==null)
		{
			photoAlbumItem = new LabelItem();
			convertView = layoutInflater.inflate(R.xml.label_view, viewGroup,false);
			photoAlbumItem.labelView = (LabelView) convertView.findViewById(R.id.label_content); 
			convertView.setTag(photoAlbumItem);
		}
		else
		{
			photoAlbumItem=(LabelItem) convertView.getTag(); 
		}

		photoAlbumItem.labelView.setLabelContent(mLabelInfoList.get(position).getLabelName());
		return convertView;
	}
	public final class LabelItem
	{
		public LabelView labelView;
	}
}
