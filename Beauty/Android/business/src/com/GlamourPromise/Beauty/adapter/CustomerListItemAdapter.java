package com.GlamourPromise.Beauty.adapter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Business.CustomerServicingActivity;
import com.GlamourPromise.Beauty.Business.CustomerUnpaidOrderActivity;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.Customer;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.util.AssortPinyinList;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.LanguageComparator_CN;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.Iterator;
import java.util.List;

@SuppressLint("ResourceType")
public class CustomerListItemAdapter extends BaseExpandableListAdapter {
	private CustomerListItemAdapterHandler adapterMhandler = new CustomerListItemAdapterHandler(this);
	private static final String TAG = CustomerListItemAdapter.class.getName();
	private static class ViewHolderGroup {
		private TextView customerGroupNameText;
	}
	private static class ViewHolderChild {
		private TextView customerNameText;
		private TextView customerLoginMobileText;
		private TextView comeTimeText;
		private ImageView customerHeadImage;
	}
	private LayoutInflater layoutInflater;
	private Activity activity;
	private List<Customer> customerList;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	private int selectedPosition = -1;
	private UserInfoApplication userInfoApplication;
	private int      mFromSource;
	private Thread requestWebServiceThread;
	private List<OrderInfo> mConvertOrderList;
	// 中文排序对象
	private LanguageComparator_CN cnSort = new LanguageComparator_CN();
	private AssortPinyinList assort = new AssortPinyinList();
	public CustomerListItemAdapter(Activity activity,List<Customer> customerList,int fromSource,List<OrderInfo> convertOrderList) {
		this.activity = activity;
		layoutInflater = (LayoutInflater)this.activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		imageLoader = ImageLoader.getInstance();
		displayImageOptions = new DisplayImageOptions.Builder().showImageForEmptyUri(R.drawable.head_image_null).showImageOnFail(R.drawable.head_image_null).cacheInMemory(true).cacheOnDisc(true).build();
		this.customerList = customerList;
		userInfoApplication=UserInfoApplication.getInstance();
		mFromSource=fromSource;
		mConvertOrderList=convertOrderList;
		sort();
	}

	private static class CustomerListItemAdapterHandler extends Handler {
		private final CustomerListItemAdapter customerListItemAdapter;

		private CustomerListItemAdapterHandler(CustomerListItemAdapter activity) {
			WeakReference<CustomerListItemAdapter> weakReference = new WeakReference<CustomerListItemAdapter>(activity);
			customerListItemAdapter = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 2)
				DialogUtil.createShortDialog(customerListItemAdapter.activity, "您的网络貌似不给力，请检查网络设置");
			else if (msg.what == 3)
				DialogUtil.createShortDialog(customerListItemAdapter.activity, msg.obj.toString());
				//顾客转换订单成功
			else if (msg.what == 4) {
				DialogUtil.createShortDialog(customerListItemAdapter.activity, msg.obj.toString());
				customerListItemAdapter.activity.startActivity(new Intent(customerListItemAdapter.activity, CustomerUnpaidOrderActivity.class));
			}
			if (customerListItemAdapter.requestWebServiceThread != null) {
				customerListItemAdapter.requestWebServiceThread.interrupt();
				customerListItemAdapter.requestWebServiceThread = null;
			}
		}
	}

	//排序
	private void sort() {
		for (Customer customer:customerList) {
			assort.getHashList().add(customer);
		}
		//根据首字母进行排序
		assort.getHashList().sortKeyComparator(cnSort);
	}
	public Object getChild(int group, int child) {
		// TODO Auto-generated method stub
		return assort.getHashList().getValueIndex(group, child);
	}

	public long getChildId(int group, int child) {
		// TODO Auto-generated method stub
		return child;
	}

	public View getChildView(int group, int child, boolean arg2, View contentView, ViewGroup arg4) {
		// // 将所有顾客的选中状态设置为否
		// if (this.selectedPosition == -1) {
		// Log.i(TAG, "将所有顾客的选中状态设置为否:" + customerList.size());
		// for (Customer customer : customerList) {
		// customer.setIsSelected(0);
		// }
		// }
		ViewHolderChild viewHolderChild;
		// Log.i(TAG, "getChildView:contentView:" + contentView);
		if (contentView == null) {
			contentView = layoutInflater.inflate(R.xml.customer_list_item, null);
			viewHolderChild = new ViewHolderChild();
			viewHolderChild.customerNameText = (TextView) contentView.findViewById(R.id.customer_name);
			viewHolderChild.customerLoginMobileText = (TextView) contentView.findViewById(R.id.customer_login_mobile);
			viewHolderChild.comeTimeText = (TextView) contentView.findViewById(R.id.come_time_text);
			viewHolderChild.customerHeadImage = (ImageView) contentView.findViewById(R.id.customer_headImage);
			contentView.setTag(viewHolderChild);
		} else {
			viewHolderChild = (ViewHolderChild) contentView.getTag();
		}

		final Customer customer = assort.getHashList().getValueIndex(group, child);
		// 将当前顾客的选中状态设置为否
		if (this.selectedPosition == -1) {
			customer.setIsSelected(0);
		}
		viewHolderChild.customerNameText.setText(customer.getCustomerName());
		viewHolderChild.customerLoginMobileText.setText(customer.getLoginMobile());
		viewHolderChild.comeTimeText.setText(customer.getComeTime());
		imageLoader.displayImage(customer.getHeadImageUrl(), viewHolderChild.customerHeadImage, displayImageOptions);
		contentView.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				if(customer.getIsSelected()==0)
				{
					customer.setIsSelected(1);
					Iterator<Customer> iterator=customerList.iterator();
					while(iterator.hasNext())
					{
						Customer nextCustomer=iterator.next();
						if(nextCustomer.getCustomerId()!=customer.getCustomerId())
							nextCustomer.setIsSelected(0);
					}
					//如果选择的顾客是切换了别的顾客
					if(customer.getCustomerId()!=userInfoApplication.getSelectedCustomerID()){
						OrderInfo orderInfo = userInfoApplication.getOrderInfo();
						//清空待开列表数据
						List<OrderProduct> orderProductList=null;
						if(orderInfo!=null)
							orderProductList = orderInfo.getOrderProductList();
						if (orderProductList != null && orderProductList.size()>0){
							orderProductList.clear();
							userInfoApplication.setOrderInfo(orderInfo);
							userInfoApplication.getOrderInfo().setOrderProductList(orderProductList);
						}
					}
					userInfoApplication.setSelectedCustomerID(customer.getCustomerId());
					userInfoApplication.setSelectedCustomerHeadImageURL(customer.getHeadImageUrl());
					userInfoApplication.setSelectedCustomerName(customer.getCustomerName());
					userInfoApplication.setSelectedCustomerLoginMobile(customer.getLoginMobile());
					userInfoApplication.setCustomerEcardBblanceValue(customer.getCustomerEcardBalanceValue());
					userInfoApplication.setSelectedIsMyCustomer(customer.getIsMyCustomer());
				}
				if(mFromSource!=3)
					activity.startActivity(new Intent(activity,CustomerServicingActivity.class));
				else{
					Dialog dialog = new AlertDialog.Builder(activity,
							R.style.CustomerAlertDialog)
							.setTitle(activity.getString(R.string.delete_dialog_title))
							.setMessage(R.string.convert_cutsomer_order_message)
							.setPositiveButton(activity.getString(R.string.delete_confirm),
									new DialogInterface.OnClickListener() {

										@Override
										public void onClick(DialogInterface dialog,int which) {
											dialog.dismiss();
											requestWebServiceThread = new Thread() {
												@Override
												public void run() {
													// TODO Auto-generated method stub
													String methodName = "UpdateOrderCustomerID";
													String endPoint = "Order";
													JSONObject updateOrderCustomerIDJsonParam=new JSONObject();
													JSONArray  convertOrderJsonArray=new JSONArray();
													for(OrderInfo oi:mConvertOrderList){
														JSONObject orderJson=new JSONObject();
														try {
															orderJson.put("OrderID",oi.getOrderID());
															orderJson.put("OrderObjectID",oi.getOrderObejctID());
															orderJson.put("ProductType",oi.getProductType());
															orderJson.put("CustomerID",userInfoApplication.getSelectedCustomerID());
														} catch (JSONException e) {
														}
														convertOrderJsonArray.put(orderJson);
													}
													try {
														updateOrderCustomerIDJsonParam.put("List",convertOrderJsonArray);
													} catch (JSONException e) {
													}
													String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,updateOrderCustomerIDJsonParam.toString(),userInfoApplication);
													if (serverRequestResult == null || serverRequestResult.equals(""))
														adapterMhandler.sendEmptyMessage(2);
													else {
														int code=0;
														JSONObject delFavoriteJson=null;
														try {
															delFavoriteJson=new JSONObject(serverRequestResult);
															code=delFavoriteJson.getInt("Code");
														} catch (JSONException e) {
														}
														String returnMessage="";
														if (code==1) {
																try {
																	returnMessage=delFavoriteJson.getString("Message");
																} catch (JSONException e) {
																	returnMessage="";
																}
															adapterMhandler.obtainMessage(4,returnMessage).sendToTarget();
														} else{
															try {
																returnMessage=delFavoriteJson.getString("Message");
															} catch (JSONException e) {
																returnMessage="";
															}
															adapterMhandler.obtainMessage(3, returnMessage).sendToTarget();
														}
													}
												}
											};
											requestWebServiceThread.start();
										}
									})
							.setNegativeButton(activity.getString(R.string.delete_cancel),
									new DialogInterface.OnClickListener() {

										@Override
										public void onClick(DialogInterface dialog,
												int which) {
											// TODO Auto-generated method stub
											dialog.dismiss();
											dialog = null;
										}
									}).create();
					dialog.show();
					dialog.setCancelable(false);
				}
			}
		});
		
		return contentView;
	}

	public int getChildrenCount(int group) {
		// TODO Auto-generated method stub
		return assort.getHashList().getValueListIndex(group).size();
	}

	public Object getGroup(int group) {
		// TODO Auto-generated method stub
		return assort.getHashList().getValueListIndex(group);
	}

	public int getGroupCount() {
		// TODO Auto-generated method stub
		return assort.getHashList().size();
	}

	public long getGroupId(int group) {
		// TODO Auto-generated method stub
		return group;
	}

	public View getGroupView(int group, boolean arg1, View contentView, ViewGroup arg3) {
		ViewHolderGroup viewHolderGroup;
		// Log.i(TAG, "getChildView:contentView:" + contentView);
		if (contentView == null) {
			contentView = layoutInflater.inflate(R.xml.customer_group_item, null);
			contentView.setClickable(true);
			viewHolderGroup = new ViewHolderGroup();
			viewHolderGroup.customerGroupNameText = (TextView) contentView.findViewById(R.id.customer_group_name);
			contentView.setTag(viewHolderGroup);
		} else {
			viewHolderGroup = (ViewHolderGroup) contentView.getTag();
		}
		viewHolderGroup.customerGroupNameText
				.setText(assort.getFirstChar(assort.getHashList().getValueIndex(group, 0).getCustomerName()));
		return contentView;
	}
	public boolean hasStableIds() {
		// TODO Auto-generated method stub
		return true;
	}
	public boolean isChildSelectable(int arg0, int arg1) {
		// TODO Auto-generated method stub
		return true;
	}
	public void setSelectedPosition(int selectedPosition) {
		this.selectedPosition = selectedPosition;
	}
	public final class CustomerGroupItem {
		public TextView customerGroupNameText;
	}
	public final class CustomerItem {
		public ImageView customerHeadImage;
		public TextView customerNameText;
		public TextView customerLoginMobile;
	}
	public AssortPinyinList getAssort() {
		return assort;
	}
}
