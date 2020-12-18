package com.glamourpromise.beauty.customer.adapter;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.res.Resources.Theme;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ClickableSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.ChatMessageInformation;
import com.glamourpromise.beauty.customer.custom.view.CircleImageView;
import com.glamourpromise.beauty.customer.util.FaceConversionUtil;
import com.glamourpromise.beauty.customer.util.HSClickSpan;
import com.squareup.picasso.Picasso;

public class ChatListAdapter extends BaseAdapter {
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<ChatMessageInformation> chatMessageList;
	private String thumbnailImageURL;
	private String hereUserThumbnailImageURL;
	private List<View> chatViewList; //保存消息的view 
	public ChatListAdapter(Context context,List<ChatMessageInformation> chatMessageList, String thumbnailImageURL, String hereUserThumbnailImageURL)
	{
		this.mContext=context;
		this.chatMessageList=chatMessageList;
		if(thumbnailImageURL == null)
			thumbnailImageURL = "";
		else
			this.thumbnailImageURL = thumbnailImageURL;
		if(hereUserThumbnailImageURL == null )
			this.hereUserThumbnailImageURL = "";
		else
			this.hereUserThumbnailImageURL = hereUserThumbnailImageURL;
		if(this.hereUserThumbnailImageURL==null)
			this.hereUserThumbnailImageURL="";
		layoutInflater=LayoutInflater.from(mContext);
		chatViewList = new ArrayList<View>();
	}
	@Override
	public int getCount() {
		return chatMessageList.size();
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
		ChatListItem chatListItem=null;		
		chatListItem=new ChatListItem();

		if(chatMessageList.get(position).getSendOrReceiveFlag().equals("0")){
			convertView=layoutInflater.inflate(R.xml.chat_there_item,null);
		}
		else{
			convertView=layoutInflater.inflate(R.xml.chat_here_item,null);
		}
		chatViewList.add(convertView);
		
		chatListItem.thumbnailImageView=(CircleImageView)convertView.findViewById(R.id.thumbnail_image);
		chatListItem.messageContentView=(TextView)convertView.findViewById(R.id.message_content);
		chatListItem.sendTimeView=(TextView)convertView.findViewById(R.id.send_time);
		convertView.setTag(chatListItem);
		
		if(chatMessageList.get(position).getSendOrReceiveFlag().equals("0"))
		{
			if(thumbnailImageURL==null || thumbnailImageURL.equals(""))
				chatListItem.thumbnailImageView.setImageResource(R.drawable.head_image_null);
			else
				Picasso.with(mContext).load(thumbnailImageURL).error(R.drawable.head_image_null).into(chatListItem.thumbnailImageView);
		}
		else if(chatMessageList.get(position).getSendOrReceiveFlag().equals("1"))
		{
			if(hereUserThumbnailImageURL==null || hereUserThumbnailImageURL.equals(""))
				chatListItem.thumbnailImageView.setImageResource(R.drawable.head_image_null);
			else
				Picasso.with(mContext).load(hereUserThumbnailImageURL).error(R.drawable.head_image_null).into(chatListItem.thumbnailImageView);
		}else{
			chatListItem.thumbnailImageView.setImageResource(R.drawable.head_image_null);
		}
		SpannableString spannableString=FaceConversionUtil.getInstace().getExpressionString(mContext,chatMessageList.get(position).getMessageContent());
		ClickableSpan clickSpan=new HSClickSpan(chatListItem.messageContentView,mContext,1);
		spannableString.setSpan(clickSpan,0,chatMessageList.get(position).getMessageContent().length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
		chatListItem.messageContentView.setText(spannableString);
		chatListItem.sendTimeView.setText(chatMessageList.get(position).getSendTime());
		if(chatMessageList.get(position).getIsNewMessage().equals("1")){
			ProgressBar pb = (ProgressBar)convertView.findViewById(R.id.pb);
			pb.setVisibility(View.VISIBLE);
		}
		
		if(chatMessageList.get(position).getIsSendSuccess().equals("0")){
			ImageView sendMessageErrorView = (ImageView)convertView.findViewById(R.id.send_message_error);
			sendMessageErrorView.setVisibility(View.VISIBLE);
		}
		return convertView;
	}
	
	public final class ChatListItem{
		TextView sendTimeView;
		TextView messageContentView;
		ImageView thumbnailImageView;
	}
}
