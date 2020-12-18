package com.GlamourPromise.Beauty.adapter;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.bean.RecordTemplate;
import com.GlamourPromise.Beauty.util.DateUtil;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
public class RecordTemplateListAdapter extends BaseAdapter implements OnClickListener {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<RecordTemplate> recordTemplateList;
	private boolean              isChoose;//是否是选择模板列表页
	private Callback mCallback;
    public interface Callback {
         public void click(View v);
    }
	public RecordTemplateListAdapter(Context context, List<RecordTemplate> recordTemplateList,boolean isChoose,Callback callback) {
		this.mContext = context;
		layoutInflater = (LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.recordTemplateList=recordTemplateList;
		this.isChoose=isChoose;
		mCallback = callback;
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
			recordTemplateItem.recordTemplateIsVisibleIcon = (ImageView) convertView.findViewById(R.id.record_template_is_visible_icon);
			recordTemplateItem.recordTemplateIsEditableIcon=(ImageView)convertView.findViewById(R.id.record_template_is_editable_icon);
			recordTemplateItem.recordTemplateJoinInIcon=(ImageView) convertView.findViewById(R.id.record_template_join_in);
			recordTemplateItem.recordTemplateDelbutton=(ImageButton) convertView.findViewById(R.id.record_template_del_button);
			recordTemplateItem.recordTemplateIsVisibleIconD = (ImageView) convertView.findViewById(R.id.record_template_is_visible_icon_d);
			recordTemplateItem.recordTemplateIsEditableIconD=(ImageView)convertView.findViewById(R.id.record_template_is_editable_icon_d);
			convertView.setTag(recordTemplateItem);
		} else {
			recordTemplateItem = (RecordTemplateItem)convertView.getTag();
		}
		String tempStr="";
		if(recordTemplateList.get(position).isTemp())
			tempStr="[草稿]";
		recordTemplateItem.recordTemplateTitleText.setText(tempStr+recordTemplateList.get(position).getRecordTemplateTitle());
		recordTemplateItem.recordTemplateUpdateTimeText.setText(DateUtil.getFormateDateByString2(recordTemplateList.get(position).getRecordTemplateUpdateTime()));
		if(!isChoose){
			recordTemplateItem.recordTemplateJoinInIcon.setVisibility(View.GONE);
			recordTemplateItem.recordTemplatePersonText.setVisibility(View.VISIBLE);
			recordTemplateItem.recordTemplateDelbutton.setVisibility(View.VISIBLE);
			recordTemplateItem.recordTemplateIsVisibleIcon.setVisibility(View.GONE);
			recordTemplateItem.recordTemplateIsEditableIcon.setVisibility(View.GONE);
			recordTemplateItem.recordTemplatePersonText.setText(recordTemplateList.get(position).getRecordTemplateCustomerName()+"|"+recordTemplateList.get(position).getRecordTemplateResponsibleName());
		}
		else if(isChoose){
			recordTemplateItem.recordTemplateJoinInIcon.setVisibility(View.VISIBLE);
			recordTemplateItem.recordTemplatePersonText.setVisibility(View.GONE);
			recordTemplateItem.recordTemplateDelbutton.setVisibility(View.GONE);
			recordTemplateItem.recordTemplateIsVisibleIconD.setVisibility(View.GONE);
			recordTemplateItem.recordTemplateIsEditableIconD.setVisibility(View.GONE);
		}
		boolean recordTemplateIsVisible=recordTemplateList.get(position).isRecordTemplateIsVisible();
		boolean recordTemplateIsEditable=recordTemplateList.get(position).isRecordTemplateIsEditable();
		//模板对客户是否可见
		if(recordTemplateIsVisible) {
			recordTemplateItem.recordTemplateIsVisibleIcon.setBackgroundResource(R.drawable.record_template_is_visible);
		    recordTemplateItem.recordTemplateIsVisibleIconD.setBackgroundResource(R.drawable.record_template_is_visible);
		} else if(!recordTemplateIsVisible) {
			recordTemplateItem.recordTemplateIsVisibleIcon.setBackgroundResource(R.drawable.record_template_is_not_visible);
		    recordTemplateItem.recordTemplateIsVisibleIconD.setBackgroundResource(R.drawable.record_template_is_not_visible);
		}
		if(recordTemplateIsEditable) {
			recordTemplateItem.recordTemplateIsEditableIcon.setBackgroundResource(R.drawable.record_template_is_editable);
			recordTemplateItem.recordTemplateIsEditableIconD.setBackgroundResource(R.drawable.record_template_is_editable);
		    recordTemplateItem.recordTemplateDelbutton.setBackgroundResource(R.drawable.del60);
		    recordTemplateItem.recordTemplateDelbutton.setOnClickListener(this);
		    recordTemplateItem.recordTemplateDelbutton.setTag(position);
		} else if(!recordTemplateIsEditable) {
			recordTemplateItem.recordTemplateIsEditableIcon.setBackgroundResource(R.drawable.record_template_is_not_editable);
			recordTemplateItem.recordTemplateIsEditableIconD.setBackgroundResource(R.drawable.record_template_is_not_editable);
		    recordTemplateItem.recordTemplateDelbutton.setBackgroundResource(R.drawable.nodel60);
		}
		return convertView;

	}
	public final class RecordTemplateItem {
		public ImageButton recordTemplateDelbutton;
		public ImageView recordTemplateIsVisibleIconD;
		public ImageView recordTemplateIsEditableIconD;
		public TextView  recordTemplateTitleText;
		public TextView  recordTemplateUpdateTimeText;
		public TextView  recordTemplatePersonText;
		public ImageView recordTemplateIsVisibleIcon;
		public ImageView recordTemplateIsEditableIcon;
		public ImageView recordTemplateJoinInIcon;
	}
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		mCallback.click(v);
	}
}
