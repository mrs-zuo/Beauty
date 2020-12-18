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
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.squareup.picasso.Picasso;

public class RecommendListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<ServiceInformation> recommendList;
	public RecommendListAdapter(Context context,List<ServiceInformation> recommendList) {
		this.mContext = context;
		this.recommendList = recommendList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return recommendList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return recommendList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		RecommendItem recommendItem = null;
		if (convertView == null) {
			recommendItem = new RecommendItem();
			convertView = layoutInflater.inflate(R.xml.recommend_item,null);
			recommendItem.imageView = (ImageView) convertView.findViewById(R.id.recommend_image);
			recommendItem.imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
			recommendItem.nameText=(TextView)convertView.findViewById(R.id.recommend_name);
			convertView.setTag(recommendItem);
		} else {
			recommendItem = (RecommendItem)convertView.getTag();
		}
		
		if(recommendList.get(position).getThumbnail().equals("")){
			recommendItem.imageView.setBackgroundResource(R.drawable.new_beauty_default_recommend);
		}else{
			Picasso.with(mContext).load(recommendList.get(position).getThumbnail()).into(recommendItem.imageView);
		}
		recommendItem.nameText.setText(recommendList.get(position).getName());
		return convertView;
	}
	public final class RecommendItem {
		public ImageView imageView;
		public TextView  nameText;
	}
}
