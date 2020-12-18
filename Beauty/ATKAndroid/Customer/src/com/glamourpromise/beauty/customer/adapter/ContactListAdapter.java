package com.glamourpromise.beauty.customer.adapter;

import java.util.List;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.SpannableString;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.ContactListInformation;
import com.glamourpromise.beauty.customer.util.FaceConversionUtil;
import com.squareup.picasso.Picasso;

public class ContactListAdapter extends BaseAdapter {

	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<ContactListInformation> contactList;
	private static SparseArray<Boolean> hasNewMessage;
	@SuppressLint("UseSparseArrays")
	public ContactListAdapter(Context context,
			List<ContactListInformation> contactList) {
		this.mContext = context;
		this.contactList = contactList;
		layoutInflater = LayoutInflater.from(mContext);
		hasNewMessage = new SparseArray<Boolean>();
		for (int i = 0; i < contactList.size(); i++) {
			getHasNewMessage().put(i, false);
		}
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return contactList.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return contactList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub

		ContactListItem contactListItem = null;
		if (convertView == null) {
			contactListItem = new ContactListItem();
			convertView = layoutInflater.inflate(R.xml.contact_list_item, null);
			contactListItem.thumbnailImageView = (ImageView) convertView.findViewById(R.id.contact_account_thumbnail);

			contactListItem.contactNameView = (TextView) convertView.findViewById(R.id.contact_account_name);
			
			contactListItem.lastMessageTimeView = (TextView) convertView.findViewById(R.id.last_message_time);
			
			contactListItem.lastMessageContentView = (TextView) convertView.findViewById(R.id.last_message_content);
			
			contactListItem.newMessageCount = (TextView) convertView.findViewById(R.id.image_new_message_num);

			convertView.setTag(contactListItem);
		} else {
			contactListItem = (ContactListItem) convertView.getTag();
		}
		contactListItem.contactNameView.setText(contactList.get(position).getAccountName());
		contactListItem.lastMessageTimeView.setText(contactList.get(position).getSendTime());
		SpannableString spannableString=FaceConversionUtil.getInstace().getExpressionString(mContext,contactList.get(position).getMessageContent());
		contactListItem.lastMessageContentView.setText(spannableString);
		if(contactList.get(position).getHendImage().equals("")){
			contactListItem.thumbnailImageView.setImageResource(R.drawable.head_image_null);
		}else{
			Picasso.with(mContext.getApplicationContext()).load(contactList.get(position).getHendImage()).error(R.drawable.head_image_null).into(contactListItem.thumbnailImageView);
		}
		if (!contactList.get(position).getNewMeessageCount().equals("0")) {
			contactListItem.newMessageCount.setVisibility(View.VISIBLE);
			contactListItem.newMessageCount.setText(contactList.get(position).getNewMeessageCount());
		}else{
			contactListItem.newMessageCount.setVisibility(View.INVISIBLE);
		}
		return convertView;
	}

	public final class ContactListItem {
		public ImageView thumbnailImageView;
		public TextView newMessageCount;
		public TextView contactNameView;
		public TextView lastMessageTimeView;
		public TextView lastMessageContentView;
	}

	public void setContactList(List<ContactListInformation> contactList) {
		this.contactList = contactList;
	}

	public void removeNewMesssageCount(int position) {
	}

	public static SparseArray<Boolean> getHasNewMessage() {
		return hasNewMessage;
	}
}
