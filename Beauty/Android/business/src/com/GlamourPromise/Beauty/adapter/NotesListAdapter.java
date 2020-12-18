package com.GlamourPromise.Beauty.adapter;

import java.util.ArrayList;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.NoteInfo;

import android.app.Activity;
import android.content.Context;
import android.text.TextPaint;
import android.text.TextUtils.TruncateAt;
import android.util.Log;
import android.util.TypedValue;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class NotesListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private ArrayList<NoteInfo> mNotesList;
	private ArrayList<Boolean> isShowFullContentFlagList;
	private TextPaint fontPaint;
	private int screenWith;

	public NotesListAdapter(Context context, ArrayList<NoteInfo> notesList) {
		this.mContext = context;
		this.mNotesList = notesList;
		layoutInflater = LayoutInflater.from(mContext);
		float fontScale = mContext.getResources().getDisplayMetrics().scaledDensity;
		fontPaint = new TextPaint();
		fontPaint.setTextSize((18 * fontScale + 0.5f));
		screenWith = ((UserInfoApplication)((Activity) mContext).getApplication()).getScreenWidth();
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mNotesList.size();
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void notifyDataSetChanged() {
		setIsShowFullContentFlagList();
		super.notifyDataSetChanged();
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		NoteItem NoteItem = null;
		final int pos = position;
		if (convertView == null) {
			NoteItem = new NoteItem();
			convertView = layoutInflater.inflate(R.xml.notepad_list_item, null);
			NoteItem.isShowFullContentFlag = (ImageView) convertView.findViewById(R.id.is_show_full_content_flag);
			NoteItem.createName = (TextView) convertView.findViewById(R.id.note_item_responsible_creator_name);
			NoteItem.customerName=(TextView)convertView.findViewById(R.id.note_item_customer_name);
			NoteItem.createTime = (TextView) convertView.findViewById(R.id.note_item_create_time);
			NoteItem.noteContent = (TextView) convertView.findViewById(R.id.note_content);
			NoteItem.noteLabel = (TextView) convertView.findViewById(R.id.note_label);
			convertView.setTag(NoteItem);
		} else {
			NoteItem = (NoteItem) convertView.getTag();
		}
		NoteItem.createName.setText(mNotesList.get(position).getCreateName());
		NoteItem.customerName.setText(mNotesList.get(position).getCustomerName());
		NoteItem.createTime.setText(mNotesList.get(position).getCreateTime());
		NoteItem.noteContent.setText(mNotesList.get(position).getContent());
		
		NoteItem.noteLabel.setText(mNotesList.get(position).getLabel());
		changeContentLines(NoteItem.noteContent,NoteItem.isShowFullContentFlag, position, false);
		final TextView noteContent = NoteItem.noteContent;
		final ImageView isShowFullContentFlag = NoteItem.isShowFullContentFlag;
		final int finalPosition = position;
		
		NoteItem.isShowFullContentFlag.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						changeContentLines(noteContent, isShowFullContentFlag,
								finalPosition, true);
					}
				});
		/*NoteItem.noteContent.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				changeContentLines(noteContent, isShowFullContentFlag,finalPosition, true);
			}
		});*/

		int lines = (int) (fontPaint.measureText(mNotesList.get(position).getContent()) / (screenWith - 32));
		int moudleLines=(int) (fontPaint.measureText(mNotesList.get(position).getContent()) % (screenWith - 32));
		if (lines+1 >3 && moudleLines>0) {
			NoteItem.isShowFullContentFlag.setVisibility(View.VISIBLE);
		} else {
			NoteItem.isShowFullContentFlag.setVisibility(View.GONE);
		}

		return convertView;
	}

	private void changeContentLines(TextView NoteContent,
			ImageView pointFlagView, int position, Boolean isNeedChange) {
		if (isShowFullContentFlagList.get(position)) {
			NoteContent.setEllipsize(null); // 展开
			NoteContent.setSingleLine(false);
			pointFlagView.setBackgroundResource(R.drawable.report_main_up_icon);
		} else {
			NoteContent.setEllipsize(TruncateAt.END); // 收缩
			NoteContent.setMaxLines(3);
			pointFlagView.setBackgroundResource(R.drawable.report_main_down_icon);
		}
		if (isNeedChange) {
			isShowFullContentFlagList.set(position,!isShowFullContentFlagList.get(position));
		}
	}

	private void setIsShowFullContentFlagList() {
		isShowFullContentFlagList = new ArrayList<Boolean>();
		for (int i = 0; i < mNotesList.size(); i++) {
			isShowFullContentFlagList.add(i, false);
		}
	}

	public final class NoteItem {
		public ImageView isShowFullContentFlag;
		public TextView createName;
		public TextView customerName;
		public TextView createTime;
		public TextView noteContent;
		public TextView noteLabel;
	}
}
