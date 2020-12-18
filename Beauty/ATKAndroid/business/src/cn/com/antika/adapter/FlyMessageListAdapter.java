package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.text.SpannableString;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.FlyMessage;

import cn.com.antika.util.FaceConversionUtil;
import cn.com.antika.util.ImageLoaderUtil;

import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class FlyMessageListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<FlyMessage> flyMessageList;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	public FlyMessageListAdapter(Context context,List<FlyMessage> flyMessageList) {
		this.mContext = context;
		this.flyMessageList = flyMessageList;
		layoutInflater = LayoutInflater.from(mContext);
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return flyMessageList.size();
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
		FlyMessageItem flyMessageItem = null;
		if (convertView == null) {
			flyMessageItem = new FlyMessageItem();
			convertView = layoutInflater.inflate(R.xml.fly_message_list_item,null);
			flyMessageItem.headImageImage = (ImageView) convertView.findViewById(R.id.fly_message_head_image);
			flyMessageItem.flyMessageNewCount=(ImageButton)convertView.findViewById(R.id.fly_message_new_message_count);
			flyMessageItem.customerNameText = (TextView) convertView.findViewById(R.id.fly_message_customer_name);
			flyMessageItem.lastMessageContentText = (TextView) convertView.findViewById(R.id.fly_message_last_content);
			flyMessageItem.sendTimeText = (TextView) convertView.findViewById(R.id.fly_message_send_time);
			convertView.setTag(flyMessageItem);
		} else {
			flyMessageItem = (FlyMessageItem) convertView.getTag();
		}
		imageLoader.displayImage(flyMessageList.get(position).getHeadImageUrl(),flyMessageItem.headImageImage,displayImageOptions);
		flyMessageItem.customerNameText.setText(flyMessageList.get(position).getCustomerName());
		SpannableString spannableString=FaceConversionUtil.getInstace().getExpressionString(mContext,flyMessageList.get(position).getLastMessageContent());
		flyMessageItem.lastMessageContentText.setText(spannableString);
		flyMessageItem.sendTimeText.setText(flyMessageList.get(position).getLastSendTime());
		int newMessageCount=flyMessageList.get(position).getNewMessageCount();
		if(newMessageCount!=0){
			Bitmap bitmapNewMessageCount = ((BitmapDrawable)mContext.getResources().getDrawable(R.drawable.remind_number1)).getBitmap();
			if(newMessageCount<100)
				bitmapNewMessageCount = generatorFlyMessageNewCountIcon(bitmapNewMessageCount,String.valueOf(newMessageCount));
			else
				bitmapNewMessageCount = generatorFlyMessageNewCountIcon(bitmapNewMessageCount,"N");
			flyMessageItem.flyMessageNewCount.setVisibility(View.VISIBLE);
			flyMessageItem.flyMessageNewCount.setImageBitmap(bitmapNewMessageCount);
		}else 
			flyMessageItem.flyMessageNewCount.setVisibility(View.GONE);
		return convertView;
	}

	public final class FlyMessageItem {
		public ImageView headImageImage;
		public ImageButton flyMessageNewCount;
		public TextView customerNameText;
		public TextView lastMessageContentText;
		public TextView sendTimeText;
	}

	private Bitmap generatorFlyMessageNewCountIcon(Bitmap icon, String newMessageCount) {
		Bitmap flyMessageNewCountIcon = Bitmap.createBitmap(icon.getWidth(),
				icon.getHeight(), Config.ARGB_8888);
		Canvas canvas = new Canvas(flyMessageNewCountIcon);
		Paint iconPaint = new Paint();
		iconPaint.setDither(true);
		iconPaint.setFilterBitmap(true);
		Rect src = new Rect(0, 5, icon.getWidth(), icon.getHeight());
		Rect dst = new Rect(0, 5, icon.getWidth(), icon.getHeight());
		canvas.drawBitmap(icon, src, dst, iconPaint);
		Paint countPaint = new Paint(Paint.ANTI_ALIAS_FLAG
				| Paint.DEV_KERN_TEXT_FLAG);
		countPaint.setColor(Color.WHITE);
		if(UserInfoApplication.getInstance().getScreenWidth()==1536)
			countPaint.setTextSize(35f);
		else
			countPaint.setTextSize(20f);
		countPaint.setTypeface(Typeface.DEFAULT_BOLD);
		if (newMessageCount.length()==1) {
			canvas.drawText(String.valueOf(newMessageCount), icon.getHeight() / 2,
					icon.getWidth() / 2, countPaint);
		} else {
			canvas.drawText(String.valueOf(newMessageCount), icon.getHeight() / 2,
					icon.getWidth() / 3, countPaint);
		}

		return flyMessageNewCountIcon;
	}
}
