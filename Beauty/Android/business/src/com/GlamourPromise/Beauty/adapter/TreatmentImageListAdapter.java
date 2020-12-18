package com.GlamourPromise.Beauty.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.TreatmentImage;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
public class TreatmentImageListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<TreatmentImage> treatmentImageList;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	public TreatmentImageListAdapter(Context context,List<TreatmentImage> treatmentImageList) {
		this.mContext = context;
		this.treatmentImageList =treatmentImageList;
		layoutInflater = LayoutInflater.from(mContext);
		imageLoader = ImageLoader.getInstance();
		displayImageOptions =ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null_big);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return treatmentImageList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return treatmentImageList.get(position);
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
			convertView = layoutInflater.inflate(R.xml.treatment_image_item,null);
			treatmentImageItem.imageView = (ImageView) convertView.findViewById(R.id.treatment_image);
			treatmentImageItem.imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
			convertView.setTag(treatmentImageItem);
		} else {
			treatmentImageItem = (TreatmentImageItem)convertView.getTag();
		}
		
		imageLoader.displayImage(treatmentImageList.get(position).getTreatmentImageURL(),treatmentImageItem.imageView,displayImageOptions);
		return convertView;
	}
	public final class TreatmentImageItem {
		public ImageView imageView;
	}
}
