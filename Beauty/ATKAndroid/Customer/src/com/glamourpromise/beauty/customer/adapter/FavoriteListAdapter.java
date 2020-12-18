package com.glamourpromise.beauty.customer.adapter;

import java.util.List;
import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.FavoriteInfo;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.squareup.picasso.Picasso;
public class FavoriteListAdapter extends BaseAdapter {
	private Activity           mContext;
	private List<FavoriteInfo> mFavoriteList;
	private LayoutInflater     layoutInflater;
	public FavoriteListAdapter(Activity context, List<FavoriteInfo> favoriteList){
		mContext = context;
		mFavoriteList = favoriteList;
		layoutInflater = LayoutInflater.from(mContext);
	}
	@Override
	public int getCount() {
		return mFavoriteList.size();
	}

	@Override
	public Object getItem(int arg0) {
		return null;
	}

	@Override
	public long getItemId(int arg0) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		FavoriteItem favoriteItem = null;
		if (convertView == null) {
			favoriteItem = new FavoriteItem();
			convertView = layoutInflater.inflate(R.xml.commodity_list_item,null);
			favoriteItem.favoriteThumbnail =(ImageView) convertView.findViewById(R.id.commodity_thumbnail); 
			favoriteItem.productName	=(TextView) convertView.findViewById(R.id.commodity_name);
			favoriteItem.productUnitPrice = (TextView) convertView.findViewById(R.id.commodity_promotion_price);
			convertView.setTag(favoriteItem);
		} else
			favoriteItem = (FavoriteItem) convertView.getTag();
		int productType=mFavoriteList.get(position).getProductType();
		if(productType==0)
			favoriteItem.productName.setText(mFavoriteList.get(position).getProductName());
		else if(productType==1)
			favoriteItem.productName.setText(mFavoriteList.get(position).getProductName()+"\t"+mFavoriteList.get(position).getSpecification());
		if(mFavoriteList.get(position).getImageURL().equals("")){
			favoriteItem.favoriteThumbnail.setImageResource(R.drawable.beauty_default_customer);
		}else{
			Picasso.with(mContext.getApplicationContext()).load(mFavoriteList.get(position).getImageURL()).error(R.drawable.beauty_default_customer).into(favoriteItem.favoriteThumbnail);
		}
		favoriteItem.productUnitPrice.setText(NumberFormatUtil.StringFormatToString(mContext,mFavoriteList.get(position).getUnitPrice()));
		return convertView;
	}
	public final class FavoriteItem{
		public ImageView favoriteThumbnail;
		public TextView productName;
		public TextView productUnitPrice;
	}
}
