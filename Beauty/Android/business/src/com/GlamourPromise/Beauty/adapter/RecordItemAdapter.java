package com.GlamourPromise.Beauty.adapter;
import java.util.List;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.CustomerRecord;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
public class RecordItemAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context context;
	private List<CustomerRecord> recordList;
	public RecordItemAdapter(Context context, List<CustomerRecord> recordList) {
		this.context = context;
		layoutInflater = (LayoutInflater) this.context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.recordList = recordList;
	}

	@Override
	public int getCount() {
		return recordList.size();
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
		final int pos=position;
		RecordItem recordItem = null;
		if (convertView == null) {
			recordItem = new RecordItem();
			convertView = layoutInflater.inflate(R.xml.record_list_item,
					null);
			recordItem.recordTimeText = (TextView) convertView
					.findViewById(R.id.record_time);
			recordItem.nameView = (TextView) convertView
					.findViewById(R.id.name);
			recordItem.recordProblemText = (TextView) convertView
					.findViewById(R.id.record_problem_text);
			recordItem.recordSuggestionText = (TextView) convertView
					.findViewById(R.id.record_suggestion_text);
			recordItem.labelContent=(TextView) convertView
					.findViewById(R.id.label_content);
			recordItem.recorScanView=(ImageView) convertView
					.findViewById(R.id.visiable_view);
			convertView.setTag(recordItem);
		} else {
			recordItem = (RecordItem)convertView.getTag();
		}
		recordItem.recordTimeText.setText(recordList.get(position).getRecordTime());
		recordItem.recordProblemText.setText(recordList.get(position).getProblem());
		recordItem.recordSuggestionText.setText(recordList.get(position).getSuggestion());
		recordItem.labelContent.setText(recordList.get(position).getLabel());
		StringBuilder tmp = new StringBuilder();
		tmp.append(recordList.get(position).getCustomerName());
		tmp.append("|");
		tmp.append(recordList.get(position).getResponsiblePersonName());
		recordItem.nameView.setText(tmp.toString());
		if(recordList.get(position).getIsVisible().equals("true"))
			recordItem.recorScanView.setBackgroundResource(R.drawable.record_is_visiable);
		else
			recordItem.recorScanView.setBackgroundResource(R.drawable.record_not_visiable);
		return convertView;
	}
	public final class RecordItem {
		public TextView recordTimeText;
		public TextView nameView;
		public TextView recordCustomerText;
		public TextView recordResponsiblePersonText;
		public TextView recordProblemText;
		public TextView recordSuggestionText;
		public TextView recordScanFlag;
		public TextView labelContent;
		public ImageView recorScanView;
	}
}
