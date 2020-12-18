package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.HashMap;
import java.util.List;

import cn.com.antika.bean.FlymessageDetail;

import cn.com.antika.util.FaceConversionUtil;
import cn.com.antika.util.HSClickSpan;
import cn.com.antika.util.ImageLoaderUtil;

import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class FlyMessageDetailListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private ImageLoader imageLoader;
	private List<FlymessageDetail> flyMessageDetailList;
	private String thereUserHeadImageURL;
	private String hereUserHeadImageURL;
	private static HashMap<Integer, String> sendOrReceviceFlag;
	private Boolean sendNewMessageFlag;
	private DisplayImageOptions displayImageOptions;
	public FlyMessageDetailListAdapter(Context context,
			List<FlymessageDetail> flyMessageDetailList,
			String thereUserHeadImageURL, String hereUserHeadImageURL,
			HashMap<Integer, String> sendOrReceviceFlag) {
		this.mContext = context;
		this.flyMessageDetailList = flyMessageDetailList;
		this.thereUserHeadImageURL = thereUserHeadImageURL;
		this.hereUserHeadImageURL = hereUserHeadImageURL;
		this.imageLoader = ImageLoader.getInstance();
		displayImageOptions= ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		layoutInflater = LayoutInflater.from(mContext);
		this.sendOrReceviceFlag = sendOrReceviceFlag;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return flyMessageDetailList.size();
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
		final FlyMessageDetailItem flyMessageDetailItem = new FlyMessageDetailItem();
		if (flyMessageDetailList.get(position).getSendOrReceiveFlag() == 0)
			convertView = layoutInflater.inflate(R.xml.chat_to_item, null);
		else
			convertView = layoutInflater.inflate(R.xml.chat_from_item, null);
		flyMessageDetailItem.headImageView = (ImageView) convertView.findViewById(R.id.thumbnail_image);
		flyMessageDetailItem.messageContentView = (TextView) convertView.findViewById(R.id.message_content);
		flyMessageDetailItem.sendTimeView = (TextView) convertView.findViewById(R.id.send_time);
		convertView.setTag(flyMessageDetailItem);
		if (flyMessageDetailList.get(position).getSendOrReceiveFlag()==1) {
			imageLoader.displayImage(hereUserHeadImageURL,flyMessageDetailItem.headImageView,displayImageOptions);
		} else {
			imageLoader.displayImage(thereUserHeadImageURL,flyMessageDetailItem.headImageView,displayImageOptions);
		}
		SpannableString spannableString= FaceConversionUtil.getInstace().getExpressionString(mContext,flyMessageDetailList.get(position).getMessageContent());
		ClickableSpan clickSpan=new HSClickSpan(flyMessageDetailItem.messageContentView,mContext);
		spannableString.setSpan(clickSpan,0,spannableString.length(),Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		flyMessageDetailItem.messageContentView.setText(spannableString);
		flyMessageDetailItem.messageContentView.setAutoLinkMask(Linkify.WEB_URLS);
		flyMessageDetailItem.messageContentView.setMovementMethod(LinkMovementMethod.getInstance());
		flyMessageDetailItem.sendTimeView.setText(flyMessageDetailList.get(position).getSendTime());
		return convertView;
	}

	public final class FlyMessageDetailItem {
		TextView sendTimeView;
		TextView messageContentView;
		ImageView headImageView;
	}

	public void setMessageList(List<FlymessageDetail> flyMessageDetailList) {
		this.flyMessageDetailList = flyMessageDetailList;
	}

	public static HashMap<Integer, String> getSendOrReceiveFlag() {
		return sendOrReceviceFlag;
	}
}
