package com.glamourpromise.beauty.customer.fragment;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.content.LocalBroadcastManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.ChatMessageListActivity;
import com.glamourpromise.beauty.customer.adapter.ContactListAdapter;
import com.glamourpromise.beauty.customer.base.BaseFragment;
import com.glamourpromise.beauty.customer.bean.ContactListInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.FaceConversionUtil;

public class ContactListFragment extends BaseFragment implements OnItemClickListener,IConnectTask {
	public static final String NEW_MESSAGE_BROADCAST_ACTION = "contactListActivityNewChatMesage";
	public static final String NOTIFICATION_FLAG = "FROM_NOTIFICATION";
	private static final String CATEGORY_NAME = "Message";
	private static final String GET_CONTACT_LIST = "getContactListForCustomer";
	private NewRefreshListView contactListView;
	private List<ContactListInformation> contactList;
	private ContactListAdapter contactListAdapter;
	private OnRefreshListener refreshListWithWebService;
	private boolean isRefresh;
	private MessageRecevice messageRecevice;
	private IntentFilter filter;
	//JPush
	public static boolean isForeground = false;
	public static final String MESSAGE_RECEIVED_ACTION = "com.example.jpushdemo.MESSAGE_RECEIVED_ACTION";
	public static final String KEY_TITLE = "title";
	public static final String KEY_MESSAGE = "message";
	public static final String KEY_EXTRAS = "extras";
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		super.onCreateView(inflater, container, savedInstanceState);
		View contactView=inflater.inflate(R.xml.contact_list_fragment,container,false);
		Bundle bundle =getActivity().getIntent().getExtras();
		if(bundle != null && bundle.getString(NOTIFICATION_FLAG, "").equals(NOTIFICATION_FLAG)){
			isnotifictionExit();
		}
		contactListView = (NewRefreshListView)contactView.findViewById(R.id.contact_listview);
		contactListView.setOnItemClickListener(this);
		refreshListWithWebService = new OnRefreshListener() {
			@Override
			public void onRefresh() {
				updateContactList();
			}
		};
		contactListView.setonRefreshListener(refreshListWithWebService);
		isRefresh = false;
		FaceConversionUtil.getInstace().getFileText(getActivity());
		updateContactList();
		isForeground = true;
		if(messageRecevice == null)
			messageRecevice = new MessageRecevice();
		if(filter == null){
			filter = new IntentFilter();
			filter.addAction(NEW_MESSAGE_BROADCAST_ACTION);
		}
		LocalBroadcastManager.getInstance(getActivity()).registerReceiver(messageRecevice, filter);
		return contactView;
	}
	private void isnotifictionExit(){
		SharedPreferences sharedata = getActivity().getSharedPreferences("customerInformation", Context.MODE_PRIVATE);
		String stringCompany = sharedata.getString("companySelectList", "");
		if(stringCompany.equals("")){
			getActivity().finish();
		}
	}

	Handler mhandler = new Handler(Looper.getMainLooper()) {
		public void handleMessage(android.os.Message msg) {
			if (msg.what == 4) {
				updateContactList();
			}
		};
	};
	public void onStop() {
		super.onStop();
		LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(messageRecevice);
	};
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		Intent destIntent = new Intent(getActivity(),ChatMessageListActivity.class);
		ContactListInformation contactItem = contactList.get(position-1);
		destIntent.putExtra("AccountName", contactItem.getAccountName());
		destIntent.putExtra("AccountID", contactItem.getAccountID());
		destIntent.putExtra("thumbnailImageURL", contactItem.getHendImage());
		destIntent.putExtra("flyMessageAuthority", contactItem.getFlyMessageAuthority());
		contactList.get(position-1).setNewMeessageCount("0");
		contactListAdapter.setContactList(contactList);
		contactListAdapter.notifyDataSetChanged();
		startActivity(destIntent);
	}

	protected void updateContactList() {
		if(!isRefresh){
			isRefresh = true;
			super.asyncRefrshView(this);
		}	
	}

	public class MessageRecevice extends BroadcastReceiver {

		@Override
		public void onReceive(Context arg0, Intent arg1) {
			mhandler.obtainMessage(4).sendToTarget();
		}

	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("CompanyID", mCompanyID);
			para.put("BranchID", mBranchID);
			para.put("CustomerID", mCustomerID);
			if (mApp.getScreenWidth() == 720) {
				para.put("ImageWidth", String.valueOf(80));
				para.put("ImageHeight", String.valueOf(80));
			} else if (mApp.getScreenWidth() == 480) {
				para.put("ImageWidth", String.valueOf(66));
				para.put("ImageHeight", String.valueOf(66));
			} else if (mApp.getScreenWidth() == 1080) {
				para.put("ImageWidth", String.valueOf(150));
				para.put("ImageHeight", String.valueOf(150));
			} else {
				para.put("ImageWidth", String.valueOf(80));
				para.put("ImageHeight", String.valueOf(80));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_CONTACT_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_CONTACT_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		isRefresh = false;
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(contactList == null){
					contactList = new ArrayList<ContactListInformation>();
					contactListAdapter = new ContactListAdapter(getActivity(),contactList);
					contactListView.setAdapter(contactListAdapter);
				}
				contactList.clear();
				ArrayList<ContactListInformation> tmp = (ArrayList<ContactListInformation>) response.mData;
				contactList.addAll(tmp);
				contactListView.setAdapter(contactListAdapter);
				contactListView.onRefreshComplete();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getActivity(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getActivity(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
		
	}
	@Override
	public void parseData(WebApiResponse response) {
		ArrayList<ContactListInformation> contactList = ContactListInformation.parseListByJson(response.getStringData());
		response.mData = contactList;
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub	
	}
}
