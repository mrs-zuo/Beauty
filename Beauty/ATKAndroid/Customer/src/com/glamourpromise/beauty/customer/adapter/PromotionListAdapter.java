package com.glamourpromise.beauty.customer.adapter;

import java.util.List;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.PromotionInformation;
import com.squareup.picasso.Picasso;

public class PromotionListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<PromotionInformation> promotionInformationListMap;

	public PromotionListAdapter(Context context, List<PromotionInformation> promotionInformationList) {
		this.mContext = context;
		this.promotionInformationListMap = promotionInformationList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		return promotionInformationListMap.size();
	}

	@Override
	public Object getItem(int position) {
		return null;
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		PromotionItem promotionItem = null;
		if (convertView == null) {
			promotionItem = new PromotionItem();
			convertView = layoutInflater.inflate(R.xml.promotion_list_item, null);
			promotionItem.promotionImage = (ImageView) convertView.findViewById(R.id.promotion_image);
			LayoutParams layoutParams=promotionItem.promotionImage.getLayoutParams();
			layoutParams.width=300;
			layoutParams.height=224;
			promotionItem.promotionImage.setLayoutParams(layoutParams);
			promotionItem.promotionTitle = (TextView) convertView.findViewById(R.id.promotion_title);
			promotionItem.promotionDescription=(TextView)convertView.findViewById(R.id.promotion_description);
			promotionItem.promotionTime=(TextView)convertView.findViewById(R.id.promotion_time);
			convertView.setTag(promotionItem);
		} else {
			promotionItem = (PromotionItem)convertView.getTag();
		}
		String url = promotionInformationListMap.get(position).getPromotionImageURL();
		promotionItem.promotionImage.setScaleType(ScaleType.CENTER);
		if (!url.equals("")) {
			Picasso.with(mContext).load(url).error(R.drawable.beauty_default_customer).into(promotionItem.promotionImage);
		} else {
			promotionItem.promotionImage.setImageResource(R.drawable.beauty_default_customer);
		}
		promotionItem.promotionTitle.setText(promotionInformationListMap.get(position).getPromotionTitle());
		promotionItem.promotionDescription.setText(promotionInformationListMap.get(position).getPromotionContent());
		promotionItem.promotionTime.setText(promotionInformationListMap.get(position).getPromotionTime());
		return convertView;
	}

	public final class   PromotionItem{
		public ImageView promotionImage;
		public TextView  promotionTitle;
		public TextView  promotionDescription;
		public TextView  promotionTime;
	}

}
