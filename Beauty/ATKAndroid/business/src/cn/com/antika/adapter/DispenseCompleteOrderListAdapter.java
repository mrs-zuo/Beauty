package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.OrderOperationUtil;

/*
 * 待结的订单和存单的适配器
 * */

@SuppressLint("ResourceType")
public class DispenseCompleteOrderListAdapter extends BaseAdapter {
	private LayoutInflater     layoutInflater;
	private Context            mContext;
	private List<OrderInfo>    mOrderList;
	private int                mCurrentItem;// 1:待结单TAB  2:顾客存单TAB
	private UserInfoApplication userInfoApplication;
	private List<OrderProduct> orderProductList;//保存选择需要开新单和小单的全局变量
	private List<OrderInfo>    mUnfinishOrderList;//保存需要结单的订单列表
	private int                authMyOrderWrite,authAllOrderWrite;
	public DispenseCompleteOrderListAdapter(Context context,List<OrderInfo> orderList,int currentItem) {
		this.mContext = context;
		if(mContext!=null)
			layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		mOrderList=orderList;
		mCurrentItem=currentItem;
		userInfoApplication = UserInfoApplication.getInstance();
		OrderInfo orderInfo = userInfoApplication.getOrderInfo();
		if (orderInfo == null)
			orderInfo = new OrderInfo();
		orderProductList = orderInfo.getOrderProductList();
		if (orderProductList == null)
			orderProductList = new ArrayList<OrderProduct>();
		userInfoApplication.setOrderInfo(orderInfo);
		userInfoApplication.getOrderInfo().setOrderProductList(orderProductList);
		mUnfinishOrderList=new ArrayList<OrderInfo>();
		authMyOrderWrite=userInfoApplication.getAccountInfo().getAuthMyOrderWrite();
		authAllOrderWrite=userInfoApplication.getAccountInfo().getAuthAllOrderWrite();
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return mOrderList.size();
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
		final int pos=position;
		DispenseCompleteOrderItem dispenseCompleteOrderItem = null;
		if (convertView == null) {
			dispenseCompleteOrderItem = new DispenseCompleteOrderItem();
			convertView = layoutInflater.inflate(R.xml.dispense_complete_order_list_item,null);
			dispenseCompleteOrderItem.orderProductNameText=(TextView)convertView.findViewById(R.id.dispense_complete_order_product_name_text);
			dispenseCompleteOrderItem.orderTimeText=(TextView)convertView.findViewById(R.id.dispense_complete_order_time);
			dispenseCompleteOrderItem.orderResponsiblePersonText=(TextView)convertView.findViewById(R.id.dispense_complete_order_responsible_person);
			dispenseCompleteOrderItem.orderStatusText=(TextView) convertView.findViewById(R.id.dispense_complete_order_status);
			dispenseCompleteOrderItem.orderExecutingStatusText=(TextView)convertView.findViewById(R.id.dispense_complete_order_executing_status);
			dispenseCompleteOrderItem.orderSelectIcon=(ImageView)convertView.findViewById(R.id.dispense_complete_order_select_icon);
			convertView.setTag(dispenseCompleteOrderItem);
		} else {
			dispenseCompleteOrderItem = (DispenseCompleteOrderItem)convertView.getTag();
		}
		dispenseCompleteOrderItem.orderProductNameText.setText(mOrderList.get(position).getProductName());
		dispenseCompleteOrderItem.orderTimeText.setText(mOrderList.get(position).getOrderTime());
		dispenseCompleteOrderItem.orderResponsiblePersonText.setText(mOrderList.get(position).getResponsiblePersonName());
		int completeCount=mOrderList.get(position).getCompleteCount();
		int totalCount=mOrderList.get(position).getTotalCount();
		if(mCurrentItem==1){
			if(mOrderList.get(position).getProductType()==Constant.SERVICE_TYPE){
				if(totalCount!=0)
					dispenseCompleteOrderItem.orderStatusText.setText("服务1次/"+"共"+totalCount+"次");
				else
					dispenseCompleteOrderItem.orderStatusText.setText("服务1次/"+"不限次");
			}
			else if(mOrderList.get(position).getProductType()==Constant.COMMODITY_TYPE)
				dispenseCompleteOrderItem.orderStatusText.setText("交付"+completeCount+"件/共"+totalCount+"件");
		}
		else if(mCurrentItem==2){
			if(mOrderList.get(position).getProductType()==Constant.SERVICE_TYPE){
				if(totalCount!=0)
					dispenseCompleteOrderItem.orderStatusText.setText("完成"+completeCount+"次/"+"共"+totalCount+"次");
				else
					dispenseCompleteOrderItem.orderStatusText.setText("完成"+completeCount+"次/"+"不限次");
			}
			else if(mOrderList.get(position).getProductType()==Constant.COMMODITY_TYPE){
				dispenseCompleteOrderItem.orderStatusText.setText("已交"+completeCount+"件/共"+totalCount+"件");
			}
		}
		String paymentStatusStr="未知";
		if(mCurrentItem==1){
			int paymentStatus=mOrderList.get(position).getPaymentStatus();
			paymentStatusStr=OrderOperationUtil.getOrderPayemntStatus(paymentStatus);
		}
		else if(mCurrentItem==2){
			int executingCount=mOrderList.get(position).getExecutingCount();
			paymentStatusStr="进行中"+executingCount+"次";
		}
		dispenseCompleteOrderItem.orderExecutingStatusText.setText(paymentStatusStr);
		if(authMyOrderWrite==0){
			dispenseCompleteOrderItem.orderSelectIcon.setVisibility(View.INVISIBLE);
		}
		else{
			dispenseCompleteOrderItem.orderSelectIcon.setBackgroundResource(R.drawable.no_select_btn);
			int hasSelected = 0;
			if(mOrderList.get(position).isSelected()){
				dispenseCompleteOrderItem.orderSelectIcon.setBackgroundResource(R.drawable.select_btn);
				hasSelected = 1;
			}
			if(mCurrentItem==2){
				for (OrderProduct op :orderProductList) {
					if (op.getOldOrderID()==mOrderList.get(position).getOrderID()) {
						dispenseCompleteOrderItem.orderSelectIcon.setBackgroundResource(R.drawable.select_btn);
						hasSelected = 1;
					}
				}
			}
			//选中订单的点击事件
			final int hs = hasSelected;
			dispenseCompleteOrderItem.orderSelectIcon.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View view) {
							int orderResponsibleID=mOrderList.get(pos).getResponsiblePersonID();
							if(authAllOrderWrite==0 && orderResponsibleID!=userInfoApplication.getAccountInfo().getAccountId()){
								DialogUtil.createShortDialog(mContext,"您无权限处理该笔订单");
							}
							else{
								if (mOrderList.get(pos).isSelected() || hs == 1) {
									view.setBackgroundResource(R.drawable.no_select_btn);
									mOrderList.get(pos).setSelected(false);
									mUnfinishOrderList.remove(mOrderList.get(pos));
								} else if (!mOrderList.get(pos).isSelected() || hs == 0) {
									view.setBackgroundResource(R.drawable.select_btn);
									mOrderList.get(pos).setSelected(true);
									mUnfinishOrderList.add(mOrderList.get(pos));
								}
								DispenseCompleteOrderListAdapter.this.notifyDataSetChanged();
							}
						}
					});
		}
		return convertView;
	}
	//获得用户所选的需要结单的订单列表
	public List<OrderInfo> getUnFinshOrderList(){
		return mUnfinishOrderList;
	}
	public final class  DispenseCompleteOrderItem {
		public TextView  orderProductNameText;
		public TextView  orderTimeText;
		public TextView  orderResponsiblePersonText;
		public TextView  orderStatusText;
		public TextView  orderExecutingStatusText;
		public ImageView orderSelectIcon;
	}
}
