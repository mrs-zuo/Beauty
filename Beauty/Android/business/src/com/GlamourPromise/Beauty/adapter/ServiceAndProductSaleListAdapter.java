package com.GlamourPromise.Beauty.adapter;
import java.util.List;

import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CustomerEcardBalanceChange;
import com.GlamourPromise.Beauty.bean.EcardHistroy;
import com.GlamourPromise.Beauty.bean.ServiceAndProductSales;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class ServiceAndProductSaleListAdapter extends BaseAdapter {
	private LayoutInflater layoutInflater;
	private Context mContext;
	private List<ServiceAndProductSales> serviceAndProductSalesList;
	private int  productType;
	private int  extractItemType;
	public ServiceAndProductSaleListAdapter(Context context,List<ServiceAndProductSales> serviceAndProductSalesList,int productType,int extractItemType) {
		this.mContext = context;
		this.serviceAndProductSalesList=serviceAndProductSalesList;
		layoutInflater = LayoutInflater.from(mContext);
		this.productType=productType;
		this.extractItemType=extractItemType;
	}

	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return serviceAndProductSalesList.size();
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
		ServiceAndProductSalesItem serviceAndProductSalesItem = null;
		if (convertView == null) {
			serviceAndProductSalesItem = new ServiceAndProductSalesItem();
			convertView = layoutInflater.inflate(R.xml.service_and_product_sales_list_item,null);
			serviceAndProductSalesItem.serviceAndProductSalesNameText = (TextView) convertView.findViewById(R.id.service_and_product_name);
			serviceAndProductSalesItem.serviceAndProductSalesQuantityText= (TextView) convertView.findViewById(R.id.service_and_product_name_quantity);
			serviceAndProductSalesItem.serviceAndProductSalesPriceText = (TextView) convertView.findViewById(R.id.service_and_product_name_price);
			convertView.setTag(serviceAndProductSalesItem);
		} else {
			serviceAndProductSalesItem = (ServiceAndProductSalesItem) convertView.getTag();
		}
		String productTypeStr="";
		if(productType==Constant.SERVICE_TYPE){
			if(extractItemType==4) {
				productTypeStr="次";
				serviceAndProductSalesItem.serviceAndProductSalesNameText.setText(serviceAndProductSalesList.get(position).getObjectName());
				serviceAndProductSalesItem.serviceAndProductSalesPriceText.setText(serviceAndProductSalesList.get(position).getQuantity()+productTypeStr+"("+serviceAndProductSalesList.get(position).getQuantityScale()+")");
				serviceAndProductSalesItem.serviceAndProductSalesQuantityText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency()+serviceAndProductSalesList.get(position).getTotalPrice()+"("+serviceAndProductSalesList.get(position).getTotalPriceScale()+")");
			} else {
				productTypeStr="项";
				serviceAndProductSalesItem.serviceAndProductSalesNameText.setText(serviceAndProductSalesList.get(position).getObjectName());
				serviceAndProductSalesItem.serviceAndProductSalesQuantityText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + serviceAndProductSalesList.get(position).getTotalProfitRatePrice());
				serviceAndProductSalesItem.serviceAndProductSalesPriceText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency()+serviceAndProductSalesList.get(position).getTotalPrice());
			}
		}
		else if(productType==Constant.COMMODITY_TYPE) {
			productTypeStr="件";
			serviceAndProductSalesItem.serviceAndProductSalesNameText.setText(serviceAndProductSalesList.get(position).getObjectName());
			serviceAndProductSalesItem.serviceAndProductSalesQuantityText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + serviceAndProductSalesList.get(position).getTotalProfitRatePrice());
			serviceAndProductSalesItem.serviceAndProductSalesPriceText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency()+serviceAndProductSalesList.get(position).getTotalPrice());
		}
		return convertView;
	}

	public final class ServiceAndProductSalesItem {
		public TextView serviceAndProductSalesNameText;
		public TextView serviceAndProductSalesQuantityText;
		public TextView serviceAndProductSalesPriceText;
	}
}
