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
import com.glamourpromise.beauty.customer.bean.CategoryInformation;
public  class CategoryListAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private List<CategoryInformation> categoryList;
	public CategoryListAdapter(Context context,List<CategoryInformation> categoryList)
	{
		this.categoryList=categoryList;
		layoutInflater=LayoutInflater.from(context);
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return categoryList.size();
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
		CategoryItem categoryItem=null;
		if(convertView==null){
			categoryItem=new CategoryItem();
			convertView=layoutInflater.inflate(R.xml.category_list_item,null);
			categoryItem.commodityClassificationIcon=(ImageView)convertView.findViewById(R.id.commodity_classification_icon);
			categoryItem.categoryName=(TextView)convertView.findViewById(R.id.category_name);
			categoryItem.arrowHead = (ImageView) convertView.findViewById(R.id.arrowhead);
			convertView.setTag(categoryItem);
		}
		else{
			categoryItem=(CategoryItem)convertView.getTag();
		}
		if(categoryList.size() == 1){
			if(position == 0){
				categoryItem.commodityClassificationIcon.setBackgroundResource(R.drawable.commodity_main_classification_icon);
				categoryItem.arrowHead.setBackgroundResource(R.drawable.join_in_arrowhead_gray);
				categoryItem.categoryName.setText(categoryList.get(position).getParentCategoryName());
				categoryItem.arrowHead.setVisibility(View.VISIBLE);
			}
		}
		else{
			int pos = position + 1;
			if(position == 0)
			{
				categoryItem.commodityClassificationIcon.setBackgroundResource(R.drawable.commodity_main_classification_icon);
				categoryItem.arrowHead.setBackgroundResource(R.drawable.join_in_arrowhead_gray);
				if(!categoryList.get(pos).getParentCategoryName().equals(""))
					categoryItem.categoryName.setText(categoryList.get(pos).getParentCategoryName());
				else
					categoryItem.categoryName.setText("");
				categoryItem.arrowHead.setVisibility(View.VISIBLE);
				
			}
			else
			{
				categoryItem.arrowHead.setBackgroundResource(R.drawable.join_in_arrowhead_gray);
				categoryItem.commodityClassificationIcon.setBackgroundResource(R.drawable.commodity_classification_icon);
				categoryItem.categoryName.setText(categoryList.get(position).getCategoryName());				
				categoryItem.arrowHead.setVisibility(View.GONE);
			}
		}
		return convertView;
	}
	public void clearList(){
		categoryList.clear();
		notifyDataSetChanged();
	}
	
	public final class CategoryItem
	{
		public ImageView commodityClassificationIcon;
		public TextView  categoryName;
		public TextView  childCount;
		public ImageView arrowHead;
		public ImageView arrowHeadTwo;
	}
	
}
