package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.PhotoAlbumListInformation;
import com.squareup.picasso.Picasso;

public class ImageListAdapter extends BaseAdapter{
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<PhotoAlbumListInformation> photoAlbumList;
	private List<Boolean> selectStatusList = new ArrayList<Boolean>();
	public ImageListAdapter(Context context, List<PhotoAlbumListInformation> photoAlbumList)
	{
		this.mContext = context;
		this.photoAlbumList = photoAlbumList;
		layoutInflater=LayoutInflater.from(mContext);
		
		for(int i = 0; i < photoAlbumList.size(); i++)
		{
			selectStatusList.add(false);
		}
	}
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return photoAlbumList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return photoAlbumList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		PhotoAlbumItem photoAlbumItem = null;
		if(convertView==null)
		{
			photoAlbumItem = new PhotoAlbumItem();
			convertView = layoutInflater.inflate(R.xml.photo_album_list_item, null); 
			photoAlbumItem.textView = (TextView) convertView.findViewById(R.id.photo_time); 
			
			photoAlbumItem.imageView = (ImageView) convertView.findViewById(R.id.photo_album); 
			photoAlbumItem.imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
			convertView.setTag(photoAlbumItem);
		}
		else
		{
			photoAlbumItem=(PhotoAlbumItem) convertView.getTag(); 
		}
		
		String url = photoAlbumList.get(position).getImageURL();
		if(!url.equals("")){
			Picasso.with(mContext).load(url).error(R.drawable.head_image_null).into(photoAlbumItem.imageView);
		}else{
			photoAlbumItem.imageView.setImageResource(R.drawable.head_image_null);
		}

		photoAlbumItem.textView.setText(photoAlbumList.get(position).getTime());
		return convertView;
	}

	public final class PhotoAlbumItem
	{
		public ImageView imageView;
		public TextView textView;
	}
}
