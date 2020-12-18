package com.GlamourPromise.Beauty.adapter;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.Treatment;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import android.app.AlertDialog;
import android.content.Context;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class ServicingInfoListAdapter extends BaseAdapter{
	private LayoutInflater  layoutInflater;
	private Context         mContext;
	private List<OrderInfo> servicingInfoList;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	private Thread              requestWebServiceThread;
	private UserInfoApplication mUserinfoApplication;
	private AlertDialog         alertDialog;
	public ServicingInfoListAdapter(Context context,List<OrderInfo> servicingInfoList,UserInfoApplication userInfoApplication)
	{
		this.mContext=context;
		this.servicingInfoList=servicingInfoList;
		layoutInflater=LayoutInflater.from(mContext);
		imageLoader = ImageLoader.getInstance();
		displayImageOptions = new DisplayImageOptions.Builder().showImageForEmptyUri(R.drawable.head_image_null).showImageOnFail(R.drawable.head_image_null).cacheInMemory(true).cacheOnDisc(true).build();
		this.mUserinfoApplication=userInfoApplication;
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return servicingInfoList.size();
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
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		ServicingInfoItem servicingInfoItem=null;
		if(convertView==null)
		{
			servicingInfoItem=new ServicingInfoItem();
			convertView=layoutInflater.inflate(R.xml.servicing_info_list_item,null);
			servicingInfoItem.customerHeadImage=(ImageView)convertView.findViewById(R.id.servicing_customer_headImage);
			servicingInfoItem.customerNameText=(TextView)convertView.findViewById(R.id.servicing_customer_name);
			servicingInfoItem.serviceNameText=(TextView) convertView.findViewById(R.id.servicing_service_name);
			servicingInfoItem.serviceDateTimeText=(TextView) convertView.findViewById(R.id.servicing_service_date_time);
			servicingInfoItem.serviceResponsiblePersonText=(TextView) convertView.findViewById(R.id.servicing_service_responsible_person);
			servicingInfoItem.serviceStatusText=(TextView)convertView.findViewById(R.id.servicing_service_status);
			servicingInfoItem.serviceIsDesignatedIcon=(ImageView)convertView.findViewById(R.id.servicing_service_is_designated_icon);
			convertView.setTag(servicingInfoItem);
		}
		else{
			servicingInfoItem=(ServicingInfoItem)convertView.getTag();
		}
		imageLoader.displayImage(servicingInfoList.get(position).getCustomerHeadImageUrl(),servicingInfoItem.customerHeadImage,displayImageOptions);
		servicingInfoItem.customerNameText.setText(servicingInfoList.get(position).getCustomerName());
		servicingInfoItem.serviceNameText.setText(servicingInfoList.get(position).getProductName());
		servicingInfoItem.serviceDateTimeText.setText(servicingInfoList.get(position).getOrderTime());
		servicingInfoItem.serviceResponsiblePersonText.setText(servicingInfoList.get(position).getResponsiblePersonName());
		if(servicingInfoList.get(position).isDesignated())
			servicingInfoItem.serviceIsDesignatedIcon.setVisibility(View.VISIBLE);
		else
			servicingInfoItem.serviceIsDesignatedIcon.setVisibility(View.GONE);
		int tgStatus=servicingInfoList.get(position).getUnfinshTgStatus();
		String tgStatusString = "未知状态";
		switch (tgStatus) {
		case 1:
			tgStatusString = "┅ 进行中";
			break;
		case 2:
			tgStatusString = "已完成";
			break;
		case 3:
			tgStatusString = "已取消";
			break;
		case 4:
			tgStatusString = "已终止";
			break;
		case 5:
			tgStatusString = "?待确认";
			break;
		}
		servicingInfoItem.serviceStatusText.setText(tgStatusString);
		if(tgStatus==1)
			servicingInfoItem.serviceStatusText.setTextColor(mContext.getResources().getColor(R.color.tg_executing_status_text_color));
		else if(tgStatus==5)
			servicingInfoItem.serviceStatusText.setTextColor(mContext.getResources().getColor(R.color.tg_unconfirm_status_text_color));
		return convertView;
	}
	public List<OrderInfo> getServicingList(){
		return servicingInfoList;
	}
	
	public final class ServicingInfoItem
	{
		public ImageView  customerHeadImage;
		public TextView   customerNameText;
		public TextView   serviceNameText;
		public TextView   serviceDateTimeText;
		public TextView   serviceResponsiblePersonText;
		public ImageView  serviceIsDesignatedIcon;
		public TextView   serviceStatusText;
	}
}
