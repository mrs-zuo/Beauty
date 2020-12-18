package com.glamourpromise.beauty.customer.activity;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.json.JSONException;
import org.json.JSONObject;

import android.R.anim;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.PopupWindow.OnDismissListener;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.OrderListAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.net.WebServiceUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class OrderListActivity extends Activity implements OnClickListener {
	// 网路请求
	private Thread requestWebServiceThread;
	private UserInfoApplication userInfo;
	private Handler internetHandler = new Handler();
	private List<OrderBaseInfo> orderList;
	private OrderListAdapter orderListAdapter;
	private ListView   orderListView;
	private String orderStatus = "-1";
	private String productType = "-1";
	private String isPaid = "-1";
	private int lastProductType = -1;
	private int lastOrderStatus = -1;
	private int lastOrderPayStatus = -1;
	private int currentOrderClassify;
	private int currentOrderStatus;
	private int curentOrderPayStatus;
	private UserInfoApplication mApp;
	protected String mCustomerID;
	private   ImageButton backBtn;
	private   PopupWindow orderFilterPopupWindow;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_order_list_new);
		Intent intent = getIntent();
		productType = intent.getStringExtra("OrderClassify");
		orderStatus = intent.getStringExtra("OrderStatus");
		isPaid = intent.getStringExtra("OrderPayStatus");
		lastProductType = Integer.valueOf(productType);
		lastOrderStatus = Integer.valueOf(orderStatus);
		lastOrderPayStatus = Integer.valueOf(isPaid);
		orderListView = (ListView) findViewById(R.id.order_listview);
		backBtn=(ImageButton)findViewById(R.id.btn_main_back);
		backBtn.setOnClickListener(this);
		findViewById(R.id.order_filter).setOnClickListener(this);
		mApp = (UserInfoApplication)getApplication();
		mCustomerID=mApp.getLoginInformation().getCustomerID();
		getOrderList();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	private void getOrderList() {
		getOrderListThread();
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_main_back:
			this.finish();
			break;
		case R.id.order_filter:
			currentOrderClassify = lastProductType;
			currentOrderStatus = lastOrderStatus;
			curentOrderPayStatus = lastOrderPayStatus;
			showPopupWindow(findViewById(R.id.order_list_title));
			break;

		default:
			break;
		}
	}
	private void showPopupWindow(View parentView) {
        if(orderFilterPopupWindow!=null && orderFilterPopupWindow.isShowing()){
        	orderFilterPopupWindow.dismiss();
        	orderFilterPopupWindow=null;
        }
        else{
        	//订单筛选自定义布局
    		LayoutInflater inflater = getLayoutInflater();
    		View orderFilterView = inflater.inflate(R.xml.order_select_dialog, null);
    		final TextView  orderClassifyAll=(TextView)orderFilterView.findViewById(R.id.order_classify_all);
    		final TextView  orderClassifyService=(TextView)orderFilterView.findViewById(R.id.order_classify_service);
    		final TextView  orderClassifyCommodity=(TextView)orderFilterView.findViewById(R.id.order_classify_commodity);
    		if(lastProductType==-1){
    			setCurrentFilterItem(orderClassifyAll);
    			setDefaultFilterItem(orderClassifyService);
    			setDefaultFilterItem(orderClassifyCommodity);
    		}
    		else if(lastProductType==0){
    			setDefaultFilterItem(orderClassifyAll);
    			setCurrentFilterItem(orderClassifyService);
    			setDefaultFilterItem(orderClassifyCommodity);
    		}
    		else if(lastProductType==1){
    			setDefaultFilterItem(orderClassifyAll);
    			setDefaultFilterItem(orderClassifyService);
    			setCurrentFilterItem(orderClassifyCommodity);
    		}
    		orderClassifyAll.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderClassify=-1;
					setCurrentFilterItem(orderClassifyAll);
	    			setDefaultFilterItem(orderClassifyService);
	    			setDefaultFilterItem(orderClassifyCommodity);
				}
			});
    		orderClassifyService.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderClassify=0;
					setDefaultFilterItem(orderClassifyAll);
					setCurrentFilterItem(orderClassifyService);
	    			setDefaultFilterItem(orderClassifyCommodity);
				}
			});
    		orderClassifyCommodity.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderClassify=1;
					setDefaultFilterItem(orderClassifyAll);
					setDefaultFilterItem(orderClassifyService);
					setCurrentFilterItem(orderClassifyCommodity);
				}
			});
    		final TextView  orderStatusAll=(TextView)orderFilterView.findViewById(R.id.order_status_all);
    		final TextView  orderStatusProceed=(TextView)orderFilterView.findViewById(R.id.order_status_proceed);
    		final TextView  orderStatusComplete=(TextView)orderFilterView.findViewById(R.id.order_status_complete);
    		final TextView  orderStatusTerminate=(TextView)orderFilterView.findViewById(R.id.order_status_terminate);
    		final TextView  orderStatusCancel=(TextView)orderFilterView.findViewById(R.id.order_status_cancel);
    		if(lastOrderStatus==-1){
    			setCurrentFilterItem(orderStatusAll);
    			setDefaultFilterItem(orderStatusProceed);
    			setDefaultFilterItem(orderStatusComplete);
    			setDefaultFilterItem(orderStatusTerminate);
    			setDefaultFilterItem(orderStatusCancel);
    		}
    		else if(lastOrderStatus==1){
    			setDefaultFilterItem(orderStatusAll);
    			setCurrentFilterItem(orderStatusProceed);
    			setDefaultFilterItem(orderStatusComplete);
    			setDefaultFilterItem(orderStatusTerminate);
    			setDefaultFilterItem(orderStatusCancel);
    		}
    		else if(lastOrderStatus==2){
    			setDefaultFilterItem(orderStatusAll);
    			setDefaultFilterItem(orderStatusProceed);
    			setCurrentFilterItem(orderStatusComplete);
    			setDefaultFilterItem(orderStatusTerminate);
    			setDefaultFilterItem(orderStatusCancel);
    		}
    		else if(lastOrderStatus==3){
    			setDefaultFilterItem(orderStatusAll);
    			setDefaultFilterItem(orderStatusProceed);
    			setDefaultFilterItem(orderStatusComplete);
    			setDefaultFilterItem(orderStatusTerminate);
    			setCurrentFilterItem(orderStatusCancel);
    		}
    		else if(lastOrderStatus==4){
    			setDefaultFilterItem(orderStatusAll);
    			setDefaultFilterItem(orderStatusProceed);
    			setDefaultFilterItem(orderStatusComplete);
    			setCurrentFilterItem(orderStatusTerminate);
    			setDefaultFilterItem(orderStatusCancel);
    		}
    		orderStatusAll.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderStatus=-1;
					setCurrentFilterItem(orderStatusAll);
	    			setDefaultFilterItem(orderStatusProceed);
	    			setDefaultFilterItem(orderStatusComplete);
	    			setDefaultFilterItem(orderStatusTerminate);
	    			setDefaultFilterItem(orderStatusCancel);
				}
			});
    		orderStatusProceed.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderStatus=1;
					setDefaultFilterItem(orderStatusAll);
					setCurrentFilterItem(orderStatusProceed);
	    			setDefaultFilterItem(orderStatusComplete);
	    			setDefaultFilterItem(orderStatusTerminate);
	    			setDefaultFilterItem(orderStatusCancel);
				}
			});
    		orderStatusComplete.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderStatus=2;
					setDefaultFilterItem(orderStatusAll);
					setDefaultFilterItem(orderStatusProceed);
					setCurrentFilterItem(orderStatusComplete);
	    			setDefaultFilterItem(orderStatusTerminate);
	    			setDefaultFilterItem(orderStatusCancel);
				}
			});
    		orderStatusCancel.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderStatus=3;
					setDefaultFilterItem(orderStatusAll);
					setDefaultFilterItem(orderStatusProceed);
					setDefaultFilterItem(orderStatusComplete);
	    			setDefaultFilterItem(orderStatusTerminate);
	    			setCurrentFilterItem(orderStatusCancel);
				}
			});
    		orderStatusTerminate.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					currentOrderStatus=4;
					setDefaultFilterItem(orderStatusAll);
					setDefaultFilterItem(orderStatusProceed);
					setDefaultFilterItem(orderStatusComplete);
					setCurrentFilterItem(orderStatusTerminate);
					setDefaultFilterItem(orderStatusCancel);
				}
			});
    		
    		
    		final TextView  orderPayStatusAll=(TextView)orderFilterView.findViewById(R.id.order_pay_status_all);
    		final TextView  orderPayStatusUnpaid=(TextView)orderFilterView.findViewById(R.id.order_pay_status_unpaid);
    		final TextView  orderPayStatusPartPay=(TextView)orderFilterView.findViewById(R.id.order_pay_status_part_payment);
    		final TextView  orderPayStatusPaid=(TextView)orderFilterView.findViewById(R.id.order_pay_status_paid);
    		final TextView  orderPayStatusNoNeedPay=(TextView)orderFilterView.findViewById(R.id.order_pay_status_no_need_payment);
    		if(lastOrderPayStatus==-1){
    			setCurrentFilterItem(orderPayStatusAll);
    			setDefaultFilterItem(orderPayStatusUnpaid);
    			setDefaultFilterItem(orderPayStatusPartPay);
    			setDefaultFilterItem(orderPayStatusPaid);
    			setDefaultFilterItem(orderPayStatusNoNeedPay);
    		}
    		else if(lastOrderPayStatus==1){
    			setDefaultFilterItem(orderPayStatusAll);
    			setCurrentFilterItem(orderPayStatusUnpaid);
    			setDefaultFilterItem(orderPayStatusPartPay);
    			setDefaultFilterItem(orderPayStatusPaid);
    			setDefaultFilterItem(orderPayStatusNoNeedPay);
    		}
    		else if(lastOrderPayStatus==2){
    			setDefaultFilterItem(orderPayStatusAll);
    			setDefaultFilterItem(orderPayStatusUnpaid);
    			setCurrentFilterItem(orderPayStatusPartPay);
    			setDefaultFilterItem(orderPayStatusPaid);
    			setDefaultFilterItem(orderPayStatusNoNeedPay);
    		}
    		else if(lastOrderPayStatus==3){
    			setDefaultFilterItem(orderPayStatusAll);
    			setDefaultFilterItem(orderPayStatusUnpaid);
    			setDefaultFilterItem(orderPayStatusPartPay);
    			setCurrentFilterItem(orderPayStatusPaid);
    			setDefaultFilterItem(orderPayStatusNoNeedPay);
    		}
    		else if(lastOrderPayStatus==5){
    			setDefaultFilterItem(orderPayStatusAll);
    			setDefaultFilterItem(orderPayStatusUnpaid);
    			setDefaultFilterItem(orderPayStatusPartPay);
    			setDefaultFilterItem(orderPayStatusPaid);
    			setCurrentFilterItem(orderPayStatusNoNeedPay);
    		}
    		orderPayStatusAll.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					curentOrderPayStatus=-1;
					setCurrentFilterItem(orderPayStatusAll);
	    			setDefaultFilterItem(orderPayStatusUnpaid);
	    			setDefaultFilterItem(orderPayStatusPartPay);
	    			setDefaultFilterItem(orderPayStatusPaid);
	    			setDefaultFilterItem(orderPayStatusNoNeedPay);
				}
			});
    		orderPayStatusUnpaid.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					curentOrderPayStatus=1;
					setDefaultFilterItem(orderPayStatusAll);
					setCurrentFilterItem(orderPayStatusUnpaid);
	    			setDefaultFilterItem(orderPayStatusPartPay);
	    			setDefaultFilterItem(orderPayStatusPaid);
	    			setDefaultFilterItem(orderPayStatusNoNeedPay);
				}
			});
    		orderPayStatusPartPay.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					curentOrderPayStatus=2;
					setDefaultFilterItem(orderPayStatusAll);
					setDefaultFilterItem(orderPayStatusUnpaid);
					setCurrentFilterItem(orderPayStatusPartPay);
	    			setDefaultFilterItem(orderPayStatusPaid);
	    			setDefaultFilterItem(orderPayStatusNoNeedPay);
				}
			});
    		orderPayStatusPaid.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					curentOrderPayStatus=3;
					setDefaultFilterItem(orderPayStatusAll);
					setDefaultFilterItem(orderPayStatusUnpaid);
					setDefaultFilterItem(orderPayStatusPartPay);
					setCurrentFilterItem(orderPayStatusPaid);
	    			setDefaultFilterItem(orderPayStatusNoNeedPay);
				}
			});
    		orderPayStatusNoNeedPay.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					curentOrderPayStatus=5;
					setDefaultFilterItem(orderPayStatusAll);
					setDefaultFilterItem(orderPayStatusUnpaid);
					setDefaultFilterItem(orderPayStatusPartPay);
					setDefaultFilterItem(orderPayStatusPaid);
					setCurrentFilterItem(orderPayStatusNoNeedPay);
				}
			});
    		
    		//确定
    		orderFilterView.findViewById(R.id.order_filter_ok_btn).setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					if(orderFilterPopupWindow!=null && orderFilterPopupWindow.isShowing()){
				        orderFilterPopupWindow.dismiss();
				        orderFilterPopupWindow=null;
				     }
					lastProductType = currentOrderClassify;
					lastOrderStatus = currentOrderStatus;
					lastOrderPayStatus = curentOrderPayStatus;
					getOrderList();
				}
			});
    		//取消
    		orderFilterView.findViewById(R.id.order_filter_cancel_btn).setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View view) {
					// TODO Auto-generated method stub
					 if(orderFilterPopupWindow!=null && orderFilterPopupWindow.isShowing()){
				        	orderFilterPopupWindow.dismiss();
				        	orderFilterPopupWindow=null;
				        }
				}
			});
    		orderFilterPopupWindow= new PopupWindow(orderFilterView,LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, true);
    		orderFilterPopupWindow.setBackgroundDrawable(new BitmapDrawable());
    		//窗体的透明值
    		WindowManager.LayoutParams lp = getWindow().getAttributes();  
    		lp.alpha = 0.9f; 
            getWindow().setAttributes(lp);
        	// 设置好参数之后再show
        	orderFilterPopupWindow.showAsDropDown(parentView);
        	orderFilterPopupWindow.setOnDismissListener(new OnDismissListener() {
				@Override
				public void onDismiss() {
					// TODO Auto-generated method stub
					resetWindow();
				}
			});
        }
    }
	protected void setCurrentFilterItem(TextView currentItem){
		currentItem.setBackgroundResource(R.xml.order_filter_item_shape_corner_round);
		currentItem.setTextColor(getResources().getColor(R.color.white));
	}
	protected void setDefaultFilterItem(TextView defaultItem){
		defaultItem.setBackgroundDrawable(null);
		defaultItem.setTextColor(getResources().getColor(R.color.gray));
	}
	protected void resetWindow(){
		//恢复窗体的透明值
    	WindowManager.LayoutParams lp = getWindow().getAttributes();  
		lp.alpha = 1.0f; 
        getWindow().setAttributes(lp);
	}
	private void getOrderListThread() {
		userInfo = (UserInfoApplication) getApplication();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "Order";
				String endPoint = "GetOrderList";
				JSONObject para = new JSONObject();
				try {
					para.put("BranchID",0);
					para.put("CustomerID",mCustomerID);
					para.put("ProductType", lastProductType);
					para.put("Status", lastOrderStatus);
					para.put("PaymentStatus", lastOrderPayStatus);
					para.put("PageSize", 20000);
					para.put("PageIndex", 1);
				} catch (JSONException e) {
				}
				WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(methodName,endPoint, para.toString());

				HttpResponse serverRequestResult = WebServiceUtil.requestWebApiAction_2(methodName, para.toString(),header, userInfo.getHttpClient());

				WebApiResponse response = new WebApiResponse();
				if (serverRequestResult == null) {
					response.setCode(WebApiResponse.GET_DATA_NULL);
				} else {
					int httpCode = serverRequestResult.getStatusLine().getStatusCode();
					response.setHttpCode(httpCode);
					switch (httpCode) {
					case 200:
						// 解析返回的内容
						String resultString = "";
						StringBuilder builder = new StringBuilder();
						BufferedReader bufferedReader2 = null;
						InputStreamReader inputReader;
						try {
							inputReader = new InputStreamReader(serverRequestResult.getEntity().getContent(), "UTF-8");
							bufferedReader2 = new BufferedReader(inputReader);
							for (String s = bufferedReader2.readLine(); s != null; s = bufferedReader2.readLine()) {
								builder.append(s);
							}
							bufferedReader2.close();
							inputReader.close();
						} catch (IllegalStateException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						resultString = builder.toString();
						response.setByJson(resultString);
						Log.d("resultString", resultString);
						break;
					case 500:
						Log.d("resultString", "500");
						break;
					case 401:
						Log.d("resultString", "4");
						Header responseHeader = serverRequestResult.getFirstHeader("errorMessage");
						String httpErrorMessage = responseHeader.getValue();
						response.setHttpErrorMessage(httpErrorMessage);
						break;

					default:
						break;
					}
				}
				if (response.getHttpCode() == 200) {
					switch (response.getCode()) {
					case WebApiResponse.GET_WEB_DATA_TRUE:
						OrderBaseInfo orderBase = new OrderBaseInfo();
						orderList = new ArrayList<OrderBaseInfo>();
						orderList = orderBase.parseListByJson(response.getStringData());
						internetHandler.post(new Runnable() {
							@Override
							public void run() {
								orderListAdapter = new OrderListAdapter(OrderListActivity.this, orderList);
								orderListView.setAdapter(orderListAdapter);
								
							}
						});
						break;
					case WebApiResponse.GET_WEB_DATA_EXCEPTION:
						break;
					case WebApiResponse.GET_WEB_DATA_FALSE:
						DialogUtil.createShortDialog(OrderListActivity.this,response.getMessage());
						break;
					case WebApiResponse.GET_DATA_NULL:
						break;
					case WebApiResponse.PARSING_ERROR:
						DialogUtil.createShortDialog(OrderListActivity.this,Constant.NET_ERR_PROMPT);
						break;
					default:
						break;
					}
				}
			}
		};
		requestWebServiceThread.start();
	}

	// 销毁线程
	@Override
	public void onPause() {
		super.onPause();
		internetHandler.removeCallbacks(requestWebServiceThread);
	}
	// 销毁线程
	@Override
	public void onDestroy() {
		super.onDestroy();
	}

}
