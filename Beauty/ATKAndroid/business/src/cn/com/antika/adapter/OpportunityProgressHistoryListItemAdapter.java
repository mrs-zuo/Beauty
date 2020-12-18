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

import cn.com.antika.bean.OpportunityProgressHistory;
import cn.com.antika.business.R;

/*
 * author:zts
 * */

@SuppressLint("ResourceType")
public class OpportunityProgressHistoryListItemAdapter extends BaseAdapter{
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<OpportunityProgressHistory> opportunityProgressHistoryList;
	public OpportunityProgressHistoryListItemAdapter(Context context,List<OpportunityProgressHistory> opportunityProgressHistoryList)
	{
		this.mContext=context;
		this.opportunityProgressHistoryList=opportunityProgressHistoryList;
		layoutInflater=LayoutInflater.from(mContext);
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return opportunityProgressHistoryList.size();
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
		ProgressItem progressItem=null;
		if(convertView==null)
		{
			progressItem=new ProgressItem();
			convertView=layoutInflater.inflate(R.xml.progress_history_list_item,null);
			progressItem.progressName=(TextView)convertView.findViewById(R.id.progress_history_name);
			progressItem.progressDescription=(TextView)convertView.findViewById(R.id.progress_history_description);
			progressItem.progressCreateTime=(TextView)convertView.findViewById(R.id.progress_history_create_time);
			progressItem.progressJoinInImage=(ImageView)convertView.findViewById(R.id.progress_history_join_in);
			convertView.setTag(progressItem);
		}
		else
		{
			progressItem=(ProgressItem)convertView.getTag();
		}
		progressItem.progressName.setText(opportunityProgressHistoryList.get(position).getProgressName());
		progressItem.progressDescription.setText(opportunityProgressHistoryList.get(position).getDescription());
		progressItem.progressCreateTime.setText(opportunityProgressHistoryList.get(position).getCreateTime());
		progressItem.progressJoinInImage.setBackgroundResource(R.drawable.join_in_arrowhead);
		return convertView;
	}
	public final class ProgressItem
	{
		public TextView  progressName;
		public TextView  progressDescription;
		public TextView  progressCreateTime;
		public ImageView progressJoinInImage;
	}
}
