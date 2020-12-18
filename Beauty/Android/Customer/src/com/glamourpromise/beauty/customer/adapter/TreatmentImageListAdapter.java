package com.glamourpromise.beauty.customer.adapter;
import java.util.List;
import com.glamourpromise.beauty.customer.R;
import com.squareup.picasso.Picasso;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
public class TreatmentImageListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<String> treatmentImageList;
	public TreatmentImageListAdapter(Context context,List<String> treatmentImageList) {
		this.mContext = context;
		this.treatmentImageList =treatmentImageList;
		layoutInflater = LayoutInflater.from(mContext);
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
		if(treatmentImageList.get(position).equals("")){
			treatmentImageItem.imageView.setImageResource(R.drawable.head_image_null);
		}else{
			Picasso.with(mContext.getApplicationContext()).load(treatmentImageList.get(position)).error(R.drawable.head_image_null).into(treatmentImageItem.imageView);
		}
		return convertView;
	}
	public final class TreatmentImageItem {
		public ImageView imageView;
	}
}
