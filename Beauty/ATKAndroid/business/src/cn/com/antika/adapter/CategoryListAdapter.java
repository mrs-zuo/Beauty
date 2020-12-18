package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

import cn.com.antika.bean.CategoryInfo;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class CategoryListAdapter extends BaseAdapter {

	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<CategoryInfo> categoryList;
	private View[]             views;
	public CategoryListAdapter(Context context, List<CategoryInfo> categoryList) {
		this.mContext = context;
		this.categoryList = categoryList;
		layoutInflater = LayoutInflater.from(mContext);
		views=new View[categoryList.size()];
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
		CategoryItem categoryItem = null;
		if (views[position] == null) {
			categoryItem = new CategoryItem();
			views[position] = layoutInflater.inflate(R.xml.category_list_item,null);
			categoryItem.commodityClassificationIcon = (ImageView) views[position]
					.findViewById(R.id.commodity_classification_icon);
			categoryItem.categoryName = (TextView) views[position]
					.findViewById(R.id.category_name);
			categoryItem.categoryCount = (TextView) views[position]
					.findViewById(R.id.category_count);
			categoryItem.arrowHead = (ImageView) views[position]
					.findViewById(R.id.arrowhead);
			views[position].setTag(categoryItem);
		} else
			categoryItem = (CategoryItem) views[position].getTag();
		if(categoryList.size() == 1){
			if(position == 0)
			{
				categoryItem.commodityClassificationIcon
						.setBackgroundResource(R.drawable.commodity_main_classification_icon);
				categoryItem.arrowHeadTwo = (ImageView) views[position]
						.findViewById(R.id.arrowhead_two);
				categoryItem.arrowHeadTwo
						.setBackgroundResource(R.drawable.join_in_arrowhead);
				categoryItem.arrowHead
						.setBackgroundResource(R.drawable.join_in_arrowhead);
				if(mContext.getClass().getName().equals("cn.com.antika.business.ServiceActivity"))
					categoryItem.categoryName.setText("全部服务");
				else if(mContext.getClass().getName().equals("cn.com.antika.business.CommodityCategoryActivity"))
					categoryItem.categoryName.setText("全部商品");
				/*categoryItem.categoryCount.setText("("
						+ categoryList.get(0).getTotalCommodityCount() + ")");*/
			}
		}else{
			if (position != 0) {
				categoryItem.arrowHead
						.setBackgroundResource(R.drawable.join_in_arrowhead);
				categoryItem.commodityClassificationIcon
						.setBackgroundResource(R.drawable.commodity_classification_icon);
				categoryItem.categoryName.setText(categoryList.get(position).getCategoryName());
				/*categoryItem.categoryCount.setText(" ("
						+ categoryList.get(position).getCommodityCount() + ")");*/
			} else {
				categoryItem.commodityClassificationIcon
						.setBackgroundResource(R.drawable.commodity_main_classification_icon);
				categoryItem.arrowHeadTwo = (ImageView) views[position]
						.findViewById(R.id.arrowhead_two);
				categoryItem.arrowHeadTwo
						.setBackgroundResource(R.drawable.join_in_arrowhead);
				categoryItem.arrowHead
						.setBackgroundResource(R.drawable.join_in_arrowhead);
				if (!categoryList.get(position+1).getParentCategoryName()
						.equals("anyType{}"))
					categoryItem.categoryName.setText(categoryList.get(position+1)
						.getParentCategoryName());
				else
					categoryItem.categoryName.setText("");
				/*categoryItem.categoryCount
						.setText("("
								+ categoryList.get(position+1)
										.getTotalCommodityCount() + ")");*/
			}

		}
		
		return views[position];
	}

	public final class CategoryItem {
		public ImageView commodityClassificationIcon;
		public TextView categoryName;
		public TextView categoryCount;
		public ImageView arrowHead;
		public ImageView arrowHeadTwo;
	}
}
