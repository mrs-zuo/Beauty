package com.glamourpromise.beauty.customer.adapter;
import java.util.List;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.RecordTemplate;
import com.glamourpromise.beauty.customer.util.DateUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
public class RecordTemplateListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<RecordTemplate> recordTemplateList;
	public RecordTemplateListAdapter(Context context,List<RecordTemplate> recordTemplateList) {
		this.mContext = context;
		layoutInflater = (LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.recordTemplateList=recordTemplateList;
	}
	@Override
	public int getCount() {
		return recordTemplateList.size();
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
		// TODO Auto-generated method stub
		RecordTemplateItem recordTemplateItem = null;
		if (convertView == null) {
			recordTemplateItem = new RecordTemplateItem();
			convertView = layoutInflater.inflate(R.xml.record_template_list_item, null);
			recordTemplateItem.recordTemplateTitleText = (TextView) convertView.findViewById(R.id.record_template_title_text);
			recordTemplateItem.recordTemplateUpdateTimeText= (TextView) convertView.findViewById(R.id.record_template_update_time_text);
			recordTemplateItem.recordTemplatePersonText = (TextView) convertView.findViewById(R.id.record_template_person_text);
			convertView.setTag(recordTemplateItem);
		} else {
			recordTemplateItem = (RecordTemplateItem)convertView.getTag();
		}
		recordTemplateItem.recordTemplateTitleText.setText(recordTemplateList.get(position).getRecordTemplateTitle());
		recordTemplateItem.recordTemplateUpdateTimeText.setText(DateUtil.getFormateDateByString2(recordTemplateList.get(position).getRecordTemplateUpdateTime()));
		recordTemplateItem.recordTemplatePersonText.setText(recordTemplateList.get(position).getRecordTemplateResponsibleName());
		return convertView;
	}
	public final class RecordTemplateItem {
		public TextView  recordTemplateTitleText;
		public TextView  recordTemplateUpdateTimeText;
		public TextView  recordTemplatePersonText;
	}
}
