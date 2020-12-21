package com.GlamourPromise.Beauty.adapter;
import java.util.List;
import java.util.Map;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.StringUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.jivesoftware.smack.util.StringUtils;

@SuppressLint({"NewApi", "ResourceType"})
public class RightMenuAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<Map<String, Object>> menuMap;
	private String selectedCustomerHeadImageUrl, selectedCustomerName;
	private UserInfoApplication userInfoApplication;
	private List<OrderProduct> orderProductList;

	public RightMenuAdapter(Context context, List<Map<String, Object>> menuMap) {
		this.mContext = context;
		this.menuMap = menuMap;
		layoutInflater = LayoutInflater.from(mContext);
		userInfoApplication = UserInfoApplication.getInstance();
		selectedCustomerHeadImageUrl = userInfoApplication
				.getSelectedCustomerHeadImageURL();
		selectedCustomerName = userInfoApplication.getSelectedCustomerName();
		if (selectedCustomerHeadImageUrl == null
				|| selectedCustomerName == null) {
			selectedCustomerHeadImageUrl = "";
			selectedCustomerName = "";
		}
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return menuMap.size();
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

	public void setCustomerInfo(String customerHeadImageUrl,
			String selectedCustomerName) {
		this.selectedCustomerHeadImageUrl = customerHeadImageUrl;
		this.selectedCustomerName = selectedCustomerName;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup viewGroup) {
		// TODO Auto-generated method stub
		MenuItem menuItem = null;
		if (convertView == null) {
			menuItem = new MenuItem();
			convertView = layoutInflater.inflate(R.xml.right_menu_list_item,null);
			menuItem.menuIcon = (ImageView) convertView.findViewById(R.id.right_menu_image);
			menuItem.menuText = (TextView) convertView.findViewById(R.id.right_menu_text);
			menuItem.serviceCommodityNumber = (TextView) convertView.findViewById(R.id.service_commodity_number);
			menuItem.getCustomerByQRCode = (ImageButton) convertView.findViewById(R.id.customer_by_qrcode);
			convertView.setTag(menuItem);
		} else {
			menuItem = (MenuItem) convertView.getTag();
		}
		int menuIcon = (Integer) (menuMap.get(position).get("menu_icon"));
		menuItem.menuText.setText((String) menuMap.get(position).get("menu_text"));
		String menuText = (String) menuMap.get(position).get("menu_text");
		menuItem.menuIcon.setBackgroundResource(menuIcon);
		if(userInfoApplication.getSelectedCustomerID()!=0){
			if (menuText != null && menuText.equals(userInfoApplication.getSelectedCustomerName())) {
				ImageLoader imageLoader =ImageLoader.getInstance();
				DisplayImageOptions displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
				imageLoader.displayImage(selectedCustomerHeadImageUrl,menuItem.menuIcon,displayImageOptions);
				RelativeLayout.LayoutParams menuIconlayoutParams = null;
				int screenWidth = userInfoApplication.getScreenWidth();
				if (screenWidth == 480) {
					menuItem.menuText.setTextSize(TypedValue.COMPLEX_UNIT_SP,16);
					menuIconlayoutParams = new RelativeLayout.LayoutParams(40,40);
					menuIconlayoutParams.leftMargin = 50;
				} else if (screenWidth == 540) {
					menuItem.menuText.setTextSize(TypedValue.COMPLEX_UNIT_SP,16);
					menuIconlayoutParams = new RelativeLayout.LayoutParams(50,50);
					menuIconlayoutParams.leftMargin = 60;
				} else if (screenWidth == 720) {
					menuItem.menuText.setTextSize(TypedValue.COMPLEX_UNIT_SP,16);
					menuIconlayoutParams = new RelativeLayout.LayoutParams(60,60);
					menuIconlayoutParams.leftMargin = 70;
				} else if (screenWidth == 1080) {
					menuItem.menuText.setTextSize(TypedValue.COMPLEX_UNIT_SP,16);
					menuIconlayoutParams = new RelativeLayout.LayoutParams(70,70);
					menuIconlayoutParams.leftMargin = 80;
				} else if (screenWidth == 1536) {
					menuItem.menuText.setTextSize(TypedValue.COMPLEX_UNIT_SP,22);
					menuIconlayoutParams = new RelativeLayout.LayoutParams(100,100);
					menuIconlayoutParams.leftMargin = 110;
				} else {
					menuItem.menuText.setTextSize(TypedValue.COMPLEX_UNIT_SP,16);
					menuIconlayoutParams = new RelativeLayout.LayoutParams(60,60);
					menuIconlayoutParams.leftMargin = 70;
				}
				menuIconlayoutParams.addRule(RelativeLayout.CENTER_VERTICAL);
				menuItem.menuIcon.setLayoutParams(menuIconlayoutParams);
			}
		}
		return convertView;
	}

	public final class MenuItem {
		public ImageView menuIcon;
		public TextView menuText;
		public TextView serviceCommodityNumber;
		public ImageButton getCustomerByQRCode;
	}
}
