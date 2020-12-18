package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Paint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.bean.ServiceInfo;
import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.NumberFormatUtil;

@SuppressLint("ResourceType")
public class ServiceListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private List<ServiceInfo> serviceInfoList;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	private UserInfoApplication userInfoApplication;
	private Activity mActivity;
	private List<OrderProduct> orderProductList;
	private List<OrderProduct> selectedServiceList;
	private int authMyOrderWrite;
	int fromSource;
	public ServiceListAdapter(Activity activity,List<ServiceInfo> serviceInfoList,int fromSource) {
		this.mActivity = activity;
		this.serviceInfoList = serviceInfoList;
		this.fromSource=fromSource;
		layoutInflater = LayoutInflater.from(mActivity);
		imageLoader = ImageLoader.getInstance();
		displayImageOptions =ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
		userInfoApplication = UserInfoApplication.getInstance();
		OrderInfo orderInfo = userInfoApplication.getOrderInfo();
		if (orderInfo == null)
			orderInfo = new OrderInfo();
		orderProductList = orderInfo.getOrderProductList();
		if (orderProductList == null)
			orderProductList = new ArrayList<OrderProduct>();
		userInfoApplication.setOrderInfo(orderInfo);
		userInfoApplication.getOrderInfo().setOrderProductList(orderProductList);
		if(selectedServiceList==null){
			selectedServiceList=new ArrayList<OrderProduct>();
			for(OrderProduct op:orderProductList){
				if(op.getProductType()==Constant.SERVICE_TYPE)
					selectedServiceList.add(op);
			}
		}
		authMyOrderWrite = userInfoApplication.getAccountInfo().getAuthMyOrderWrite();
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return serviceInfoList.size();
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
		final int pos = position;
		ServiceItem serviceItem = null;
		if (convertView == null) {
			serviceItem = new ServiceItem();
			convertView = layoutInflater.inflate(R.xml.commodity_list_item,null);
			serviceItem.serviceName = (TextView) convertView.findViewById(R.id.item_commodity_name);
			serviceItem.servicePromotionPrice = (TextView) convertView.findViewById(R.id.commodity_promotion_price);
			serviceItem.serviceUnitPrice = (TextView) convertView.findViewById(R.id.commodity_unit_price);
			serviceItem.serviceThumbnail = (ImageView) convertView.findViewById(R.id.commodity_thumbnail);
			serviceItem.serviceDiscountIcon = (ImageView) convertView.findViewById(R.id.commodity_discount_icon);
			serviceItem.favoriteIcon = (ImageView) convertView.findViewById(R.id.stored_icon);
			serviceItem.serviceSelectCheckbox = (ImageButton) convertView.findViewById(R.id.product_select);
			convertView.setTag(serviceItem);
		} else
			serviceItem = (ServiceItem) convertView.getTag();
		if(fromSource==3)
			serviceItem.serviceSelectCheckbox.setVisibility(View.GONE);
		else 
			serviceItem.serviceSelectCheckbox.setVisibility(View.VISIBLE);
		serviceItem.serviceName.setText(serviceInfoList.get(position).getServiceName());
		// 设置收藏
		if (serviceInfoList.get(position).getFavoriteID() > 0)
			serviceItem.favoriteIcon.setVisibility(View.VISIBLE);
		else
			serviceItem.favoriteIcon.setVisibility(View.GONE);

		double promotionPrice = Double.parseDouble(serviceInfoList.get(position).getPromotionPrice());
		double unitPrice = Double.parseDouble(serviceInfoList.get(position).getUnitPrice());
		int marketingPolicy = serviceInfoList.get(position).getMarketingPolicy();
		// 1：按等级打折、
		if (marketingPolicy == 1) {
			if (userInfoApplication.getSelectedCustomerID() != 0
					&& promotionPrice!= 0 && NumberFormatUtil.doubleCompare(promotionPrice, unitPrice)!=0) {
				serviceItem.serviceDiscountIcon.setBackgroundResource(R.drawable.discount);
				serviceItem.serviceDiscountIcon.setVisibility(View.VISIBLE);
				serviceItem.serviceUnitPrice.setVisibility(View.VISIBLE);
				serviceItem.servicePromotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()+ NumberFormatUtil.currencyFormat(String.valueOf(serviceInfoList.get(position).getPromotionPrice())));
				serviceItem.serviceUnitPrice.setText(NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
				serviceItem.serviceUnitPrice.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);
			} else {
				serviceItem.serviceDiscountIcon.setVisibility(View.GONE);
				serviceItem.serviceUnitPrice.setVisibility(View.GONE);
				serviceItem.servicePromotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()
						+ NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
			}
		}
		// 2：促销价
		else if (marketingPolicy == 2) {
			if(NumberFormatUtil.doubleCompare(promotionPrice, unitPrice)!=0){
				serviceItem.servicePromotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()+ NumberFormatUtil.currencyFormat(String.valueOf(promotionPrice)));
				serviceItem.serviceUnitPrice.setVisibility(View.VISIBLE);
				serviceItem.serviceUnitPrice.setText(NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
				serviceItem.serviceUnitPrice.getPaint().setFlags(Paint.STRIKE_THRU_TEXT_FLAG);
				serviceItem.serviceDiscountIcon.setBackgroundResource(R.drawable.promotion);
				serviceItem.serviceDiscountIcon.setVisibility(View.VISIBLE);
			}
			else{
				serviceItem.serviceDiscountIcon.setVisibility(View.GONE);
				serviceItem.serviceUnitPrice.setVisibility(View.GONE);
				serviceItem.servicePromotionPrice.setText(userInfoApplication
						.getAccountInfo().getCurrency()+ NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
			}
			
		}
		// 无优惠政策
		else if (marketingPolicy == 0) {
			serviceItem.serviceDiscountIcon.setVisibility(View.GONE);
			serviceItem.serviceUnitPrice.setVisibility(View.GONE);
			serviceItem.servicePromotionPrice.setText(userInfoApplication.getAccountInfo().getCurrency()+ NumberFormatUtil.currencyFormat(String.valueOf(unitPrice)));
		}
		imageLoader.displayImage(serviceInfoList.get(position).getThumbnail(),serviceItem.serviceThumbnail,displayImageOptions);
		if (userInfoApplication.getAccountInfo().getBranchId() == 0) {
			serviceItem.serviceSelectCheckbox.setVisibility(View.GONE);
		} else if (authMyOrderWrite == 0) {
			serviceItem.serviceSelectCheckbox.setVisibility(View.GONE);
		} else {
			if(fromSource==3)
				serviceItem.serviceSelectCheckbox.setVisibility(View.GONE);
			else
			    serviceItem.serviceSelectCheckbox.setVisibility(View.VISIBLE);
			serviceItem.serviceSelectCheckbox.setBackgroundResource(R.drawable.no_select_btn);
			int hasSelected = 0;
			for (OrderProduct op : orderProductList) {
				if (op.getProductType() == Constant.SERVICE_TYPE && op.getProductID() == serviceInfoList.get(position).getServiceID()) {
					serviceItem.serviceSelectCheckbox.setBackgroundResource(R.drawable.select_btn);
					hasSelected = 1;
				}
			}
			if(serviceInfoList.get(position).getServiceIsChecked()==1)
			{
				serviceItem.serviceSelectCheckbox.setBackgroundResource(R.drawable.select_btn);
				hasSelected = 1;
			}
			final int hs = hasSelected;
			serviceItem.serviceSelectCheckbox.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View view) {
							// TODO Auto-generated method stub
							if (serviceInfoList.get(pos).getServiceIsChecked() == 1
									|| hs == 1) {
								view.setBackgroundResource(R.drawable.no_select_btn);
								serviceInfoList.get(pos).setServiceIsChecked(0);
								Iterator<OrderProduct> iterator = selectedServiceList.iterator();
								while (iterator.hasNext()) {
									OrderProduct op = iterator.next();
									int productID = op.getProductID();
									int productType = op.getProductType();
									if (productID == serviceInfoList.get(pos)
											.getServiceID()
											&& productType == Constant.SERVICE_TYPE)
										iterator.remove();
								}
								Iterator<OrderProduct> orderProductiterator =orderProductList.iterator();
								while (orderProductiterator.hasNext()) {
									OrderProduct op = orderProductiterator.next();
									int productID = op.getProductID();
									int productType = op.getProductType();
									if (productID == serviceInfoList.get(pos)
											.getServiceID()
											&& productType == Constant.SERVICE_TYPE)
										orderProductiterator.remove();
								}
							} else if (serviceInfoList.get(pos).getServiceIsChecked() == 0 || hs == 0) {
								view.setBackgroundResource(R.drawable.select_btn);
								serviceInfoList.get(pos).setServiceIsChecked(1);
								OrderProduct orderProduct = new OrderProduct();
								orderProduct.setProductCode(serviceInfoList.get(pos).getServiceCode());
								orderProduct.setProductID(serviceInfoList.get(pos).getServiceID());
								orderProduct.setProductName(serviceInfoList.get(pos).getServiceName());
								orderProduct.setProductType(0);
								orderProduct.setQuantity(1);
								orderProduct.setUnitPrice(serviceInfoList.get(pos).getUnitPrice());
								orderProduct.setTotalPrice(String.valueOf(Double.valueOf(orderProduct.getUnitPrice())* orderProduct.getQuantity()));
								orderProduct.setPromotionPrice(serviceInfoList.get(pos).getPromotionPrice());
								orderProduct.setMarketingPolicy(serviceInfoList.get(pos).getMarketingPolicy());
								orderProduct.setServiceOrderExpirationDate(serviceInfoList.get(pos).getExpirationDate());
								orderProduct.setResponsiblePersonID(userInfoApplication.getAccountInfo().getAccountId());
								orderProduct.setResponsiblePersonName(userInfoApplication.getAccountInfo().getAccountName());
								orderProduct.setSalesID(0);
								orderProduct.setSalesName("");
								orderProduct.setPast(false);//是否老订单转入
								selectedServiceList.add(orderProduct);
							}
							ServiceListAdapter.this.notifyDataSetChanged();
						}
					});
		}
		return convertView;
	}
    public List<OrderProduct> getSelectedServiceList(){
    	return selectedServiceList;
    }
	public final class ServiceItem {
		public ImageView serviceThumbnail;
		public TextView serviceName;
		public TextView serviceUnitPrice;
		public TextView servicePromotionPrice;
		public ImageView serviceDiscountIcon;
		public ImageView favoriteIcon;
		public ImageButton serviceSelectCheckbox;
	}

}
