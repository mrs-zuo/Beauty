package com.glamourpromise.beauty.customer.adapter;
import java.util.List;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.RecordImage;
import com.squareup.picasso.Picasso;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
public class EditTgPhotoAlbumListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context      mContext;
	private List<RecordImage> recordImageList;
	public EditTgPhotoAlbumListAdapter(Context context,List<RecordImage> recordImageList) {
		this.mContext = context;
		this.recordImageList =recordImageList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return recordImageList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return recordImageList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		TreatmentImageItem treatmentImageItem = null;
		if (convertView == null) {
			treatmentImageItem = new TreatmentImageItem();
			convertView = layoutInflater.inflate(R.xml.edit_tg_image_item,null);
			treatmentImageItem.imageView = (ImageView) convertView.findViewById(R.id.tg_treatment_image);
			treatmentImageItem.imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
			treatmentImageItem.imageTag=(TextView)convertView.findViewById(R.id.tg_treatment_image_tag);
			convertView.setTag(treatmentImageItem);
		} else {
			treatmentImageItem = (TreatmentImageItem)convertView.getTag();
		}
		if(position!=recordImageList.size()-1){
			if(recordImageList.get(position).getRecordImageUrl().equals("")){
				treatmentImageItem.imageView.setImageResource(R.drawable.head_image_null);
			}else{
				Picasso.with(mContext.getApplicationContext()).load(recordImageList.get(position).getRecordImageUrl()).error(R.drawable.head_image_null).into(treatmentImageItem.imageView);
			}
		}
		else{
			treatmentImageItem.imageView.setBackgroundResource(R.drawable.add_new_photo);
		}
		treatmentImageItem.imageTag.setText(recordImageList.get(position).getRecordImageTag());
		return convertView;
	}
	public final class TreatmentImageItem {
		public ImageView imageView;
		public TextView  imageTag;
	}
}
