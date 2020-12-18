package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.app.Activity;
import android.graphics.Paint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.CommodityInformation;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.squareup.picasso.Picasso;

public class CommodityListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Activity mContext;
	private List<CommodityInformation> commodityList;
	private String tmpDiscountPrice;
	private String tmpUnitPrice;

	public CommodityListAdapter(Activity context, List<CommodityInformation> commodityList) {
		this.mContext = context;
		this.commodityList = commodityList;
		layoutInflater = LayoutInflater.from(mContext);																					
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return commodityList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		CommodityItem commodityItem = null;
		if (convertView == null) {
			commodityItem = new CommodityItem();
			convertView = layoutInflater.inflate(R.xml.commodity_list_item,null);
			commodityItem.commodityName = (TextView) convertView
					.findViewById(R.id.commodity_name);
			commodityItem.commodityUnitPrice = (TextView) convertView
					.findViewById(R.id.commodity_unit_price);
			commodityItem.commodityPromotionPrice = (TextView) convertView
					.findViewById(R.id.commodity_promotion_price);
			commodityItem.commodityThumbnail = (ImageView) convertView
					.findViewById(R.id.commodity_thumbnail);
			commodityItem.newCommodityIcon = (ImageView) convertView
					.findViewById(R.id.new_commodity_icon);
			commodityItem.recomendedIcon = (ImageView) convertView
					.findViewById(R.id.recommended_commodity_icon);
			commodityItem.disCountIcon = (ImageView) convertView
					.findViewById(R.id.commodity_discount_icon);

			convertView.setTag(commodityItem);
		} else {
			commodityItem = (CommodityItem) convertView.getTag();
		}
		
		commodityItem.commodityName.setText(commodityList.get(position).getName() + commodityList.get(position).getSpecification());

		if (!commodityList.get(position).getThumbnail().equals("")) {
			Picasso.with(mContext).load(commodityList.get(position).getThumbnail()).error(R.drawable.commodity_image_null).into(commodityItem.commodityThumbnail);
		} else {
			commodityItem.commodityThumbnail.setImageResource(R.drawable.beauty_default_customer);
		}
		// 设置折扣价
		tmpDiscountPrice = commodityList.get(position).getDiscountPrice();
		tmpUnitPrice = commodityList.get(position).getUnitPrice();
		//当折扣价为0、与原价相同时，属于没有折扣
		if(commodityList.get(position).getMarketingPolicy() == 0 || tmpDiscountPrice.equals("0.00") || (tmpDiscountPrice.equals(tmpUnitPrice))){
			//没有折扣
			commodityItem.commodityUnitPrice.setVisibility(View.GONE);
			commodityItem.commodityPromotionPrice.setText(NumberFormatUtil.StringFormatToString(mContext, tmpUnitPrice));
		}else{
			//有折扣
			commodityItem.commodityUnitPrice.setVisibility(View.VISIBLE);
			commodityItem.commodityUnitPrice.setText(tmpUnitPrice);
			commodityItem.commodityUnitPrice.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);
			commodityItem.commodityPromotionPrice.setText(NumberFormatUtil.StringFormatToString(mContext, tmpDiscountPrice));
		}
	
		
		if (commodityList.get(position).getMarketingPolicy() == 0 || tmpDiscountPrice.equals("0.00") || (tmpDiscountPrice.equals(tmpUnitPrice))) {
			//没有折扣
			commodityItem.disCountIcon.setVisibility(View.GONE);
		} else if (commodityList.get(position).getMarketingPolicy() == 1) {
			// 按折扣率打折
			commodityItem.disCountIcon.setVisibility(View.VISIBLE);
			commodityItem.disCountIcon.setBackgroundResource(R.drawable.discount);
		} else if (commodityList.get(position).getMarketingPolicy()==2){
			commodityItem.disCountIcon.setVisibility(View.VISIBLE);
			commodityItem.disCountIcon.setBackgroundResource(R.drawable.promotion);
		}
		

		/*if (commodityList.get(position).isNew()) {
			commodityItem.newCommodityIcon.setVisibility(View.VISIBLE);
		} else {
			commodityItem.newCommodityIcon.setVisibility(View.GONE);
		}
		
		if (commodityList.get(position).isRecommended()) {
			commodityItem.recomendedIcon.setVisibility(View.VISIBLE);
		} else {
			commodityItem.recomendedIcon.setVisibility(View.GONE);
		}*/
		return convertView;
	}

	public final class CommodityItem {
		public ImageView commodityThumbnail;
		public TextView commodityName;
		public TextView commodityUnitPrice;
		public TextView commodityPromotionPrice;
		public ImageView newCommodityIcon;
		public ImageView recomendedIcon;
		public ImageView disCountIcon;
	}

}
