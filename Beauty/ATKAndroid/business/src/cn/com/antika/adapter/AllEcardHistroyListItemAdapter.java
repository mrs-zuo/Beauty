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

import cn.com.antika.bean.AllEcardHistroy;
import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class AllEcardHistroyListItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<AllEcardHistroy> allEcardHistroyList;
	public AllEcardHistroyListItemAdapter(Context context,List<AllEcardHistroy> allEcardHistroyList) {
		this.mContext = context;
		this.allEcardHistroyList = allEcardHistroyList;
		layoutInflater = LayoutInflater.from(mContext);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return allEcardHistroyList.size();
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
		AllEcardHistroyItem allEcardHistroyItem = null;
		if (convertView == null) {
			allEcardHistroyItem = new AllEcardHistroyItem();
			convertView = layoutInflater.inflate(R.xml.all_ecard_history_list_item,null);
			allEcardHistroyItem.allEcardHistroyActionNameText = (TextView) convertView.findViewById(R.id.all_ecard_histroy_action_name);
			allEcardHistroyItem.allEcardHistroyTimeText = (TextView) convertView.findViewById(R.id.all_ecard_histroy_time);
			allEcardHistroyItem.allEcardHistroyJoinIn=(ImageView) convertView.findViewById(R.id.all_ecard_histroy_arrowhead);
			convertView.setTag(allEcardHistroyItem);
		} else {
			allEcardHistroyItem = (AllEcardHistroyItem) convertView.getTag();
		}
		allEcardHistroyItem.allEcardHistroyActionNameText.setText(allEcardHistroyList.get(position).getChangeTypeName());
		allEcardHistroyItem.allEcardHistroyTimeText.setText(allEcardHistroyList.get(position).getCreateTime());
		return convertView;
	}

	public final class AllEcardHistroyItem {
		public TextView allEcardHistroyActionNameText;
		public TextView allEcardHistroyTimeText;
		public ImageView allEcardHistroyJoinIn;
	}
}
