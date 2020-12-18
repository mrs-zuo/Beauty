package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.UnconfirmAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.UnfinishTGListInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.presenter.LeftMenuPresenter;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class UnconfirmActivity extends BaseActivity implements IConnectTask {
	private static final String CATEGORY_NAME = "Order";
	private static final String GET_UNFINISH_TG_LIST = "GetUnconfirmTreatGroup";
	private static final String CONFIRM_TREAT_GROUP = "ConfirmTreatGroup";
	private static final int GET_UNFINISH_TG_LIST_FLAG = 1;
	private static final int CONFIRM_TREAT_GROUP_FLAG = 2;
	private int taskFlag;
	private ListView unconfirmListView;
	private UnconfirmAdapter unconfirmListAdapter;
	private ListItemClick listItemClick;
	private int currentSelectCount;
	private List<UnfinishTGListInfo> confirmList;
	private List<UnfinishTGListInfo> unfinishOrderList = new ArrayList<UnfinishTGListInfo>();
	private UnfinishTGListInfo executingOrderInfo = new UnfinishTGListInfo();
	private JSONArray mNeedConfirmOrder;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_unconfirm_list);
		super.setTitle(getString(R.string.title_unconfirm));
		initView();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
		taskFlag = GET_UNFINISH_TG_LIST_FLAG;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	private void initView() {
		confirmList = new ArrayList<UnfinishTGListInfo>();
		currentSelectCount = 0;
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		unconfirmListView = (ListView) findViewById(R.id.unconfirm_list);
		// 确认按钮
		findViewById(R.id.confirm_btn).setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (currentSelectCount > 0)
					orderConfirm();
				else
					DialogUtil.createShortDialog(UnconfirmActivity.this,"请选择需要确认的订单！");
			}
		});
		listItemClick = new ListItemClick() {
			@Override
			public void onClick(View item, View widget, int position, int which) {
				// TODO Auto-generated method stub
			}
			@Override
			public void allOrderSelectProcess(int currentSelectCount) {
				// TODO Auto-generated method stub
				UnconfirmActivity.this.currentSelectCount = currentSelectCount;
			}
		};

		taskFlag = GET_UNFINISH_TG_LIST_FLAG;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	private void orderConfirm() {
		AlertDialog paymentDialog = new AlertDialog.Builder(this)
				.setTitle("是否确认？")
				.setPositiveButton(this.getString(R.string.confirm),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface arg0, int arg1) {
								mNeedConfirmOrder = new JSONArray();
								JSONObject item;
								try {
									for (int i = 0; i < unconfirmListAdapter
											.getItemSelectFlag().size(); i++) {
										if (unconfirmListAdapter.getItemSelectFlag().get(i)) {
											confirmList.add(unfinishOrderList.get(i));// 保存将要提交的订单
											item = new JSONObject();
											item.put("OrderType", unfinishOrderList.get(i).getProductType());
											item.put("OrderID",unfinishOrderList.get(i).getOrderID());
											item.put("OrderObjectID",unfinishOrderList.get(i).getOrderObjectID());
											item.put("GroupNo",unfinishOrderList.get(i).getGroupNo());
											mNeedConfirmOrder.put(item);
										}
									}
								} catch (JSONException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
								if (confirmList.size() > 0) {
									taskFlag = CONFIRM_TREAT_GROUP_FLAG;
									asyncRefrshView(UnconfirmActivity.this);
								}
							}
						})
				.setNegativeButton(this.getString(R.string.cancel), null)
				.show();
		paymentDialog.setCancelable(false);
	}

	public interface ListItemClick {
		void onClick(View item, View widget, int position, int which);
		void allOrderSelectProcess(int currentSelectCount);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		String methodName = "";
		if (taskFlag == GET_UNFINISH_TG_LIST_FLAG) {
			methodName = GET_UNFINISH_TG_LIST;
			try {
				para.put("Type",-1);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else if (taskFlag == CONFIRM_TREAT_GROUP_FLAG) {
			methodName = CONFIRM_TREAT_GROUP;
			try {
				para.put("CustomerID", mCustomerID);
				para.put("TGDetailList", mNeedConfirmOrder);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, methodName,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if (taskFlag == GET_UNFINISH_TG_LIST_FLAG) {
					unfinishOrderList = executingOrderInfo.parseListByJson(response.getStringData());
					unconfirmListAdapter = new UnconfirmAdapter(UnconfirmActivity.this, unfinishOrderList,listItemClick);
					unconfirmListView.setAdapter(unconfirmListAdapter);
				}
				else if (taskFlag == CONFIRM_TREAT_GROUP_FLAG) {
					DialogUtil.createShortDialog(UnconfirmActivity.this,"订单确认成功！");
					LeftMenuPresenter.getInstace(mApp).addUnComfirmOrderCount(-confirmList.size());
					unfinishOrderList.removeAll(confirmList);
					confirmList.clear();// 将确认的订单全部清除
					unconfirmListAdapter = new UnconfirmAdapter(UnconfirmActivity.this, unfinishOrderList,listItemClick);
					unconfirmListView.setAdapter(unconfirmListAdapter);
					if (unfinishOrderList.size() == 0) {
						currentSelectCount = 0;
					}
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				if (taskFlag == CONFIRM_TREAT_GROUP_FLAG) {
					confirmList.clear();// 将确认的订单全部清除
				}
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),
						Constant.NET_ERR_PROMPT);
				if (taskFlag == CONFIRM_TREAT_GROUP_FLAG) {
					confirmList.clear();// 将确认的订单全部清除
				}
				break;
			default:
				break;
			}
		}

		super.dismissProgressDialog();
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub

	}
}
