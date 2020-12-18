package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.PhotoAlbumDetailInformation;
import com.squareup.picasso.Picasso;

public class PhotoAlbumDetailAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
//	private ImageLoader imageLoader;
	private List<PhotoAlbumDetailInformation> photoAlbumdetailList;
	private static boolean selectStatus;// �Ƿ����ѡ���
	private static int allSelectStatus;

	public PhotoAlbumDetailAdapter(Context context,
			List<PhotoAlbumDetailInformation> photoAlbumdetailList) {
		this.mContext = context;
		this.photoAlbumdetailList = photoAlbumdetailList;
//		this.imageLoader = new ImageLoader(context, 1, false);
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return photoAlbumdetailList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return photoAlbumdetailList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub

		PhotoAlbumItem photoAlbumItem = null;
		if (convertView == null) {
			photoAlbumItem = new PhotoAlbumItem();
			convertView = layoutInflater.inflate(R.xml.photo_album_detail_item,
					null);
			photoAlbumItem.imageView = (ImageView) convertView
					.findViewById(R.id.photo_album);

			photoAlbumItem.imageView
					.setScaleType(ImageView.ScaleType.CENTER_CROP);
			convertView.setTag(photoAlbumItem);
		} else {
			photoAlbumItem = (PhotoAlbumItem) convertView.getTag();
		}
		
		if(photoAlbumdetailList.get(position).getThumbnailImageURL().equals("")){
			photoAlbumItem.imageView.setImageResource(R.drawable.head_image_null);
		}else{
			Picasso.with(mContext).load(photoAlbumdetailList.get(position).getThumbnailImageURL()).error(R.drawable.head_image_null).into(photoAlbumItem.imageView);
		}
		

		return convertView;
	}

	public static void setSelectStatus() {
		if (selectStatus) {
			selectStatus = false;
		} else {
			selectStatus = true;
		}

	}

	public static boolean getSelectStatus() {
		return selectStatus;
	}

	public static void setAllItemSelect() {
		if (allSelectStatus != 1) {
			allSelectStatus = 1;
		} else {
			allSelectStatus = 0;
		}
	}

	public static int getAllSelectStatus() {
		return allSelectStatus;
	}

	public final class PhotoAlbumItem {
		public ImageView imageView;
		public ImageView selectView;
		public TextView textView;
	}
}
