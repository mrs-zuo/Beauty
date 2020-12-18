package com.glamourpromise.beauty.customer.activity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CustomerCardInfo;
import com.glamourpromise.beauty.customer.bean.ECardInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EcardListActivity extends BaseActivity implements OnClickListener,IConnectTask {
	private static final String ECARD_CATEGORY = "ECard";
	private static final String GET_CUSTOMERCARD_LIST = "getCustomerCardList";
	private static final String GET_CARDINFO = "GetCardInfo";
	private static final int GET_CUSTOMER_CARD_LIST_FLAG = 1;
	private static final int GET_CARDINFO_FLAG = 2;
	private int taskFlag;
	private List<CustomerCardInfo> cardList = new ArrayList<CustomerCardInfo>();
	private ECardInformation ecardInformation = new ECardInformation();
	private CustomerCardInfo customerCardInfo = new CustomerCardInfo();
	private String mUserCardNo = "";
	private Button ecardPaymentInfoBtn;
	private Intent intent;
	private Bundle mBundle;
	private LinearLayout ecardListLinearLayout;
	private LayoutInflater layoutInflater;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_ecard_choose_list);
		super.setTitle(getString(R.string.title_ecard_list));
		ecardPaymentInfoBtn = (Button) findViewById(R.id.ecard_payment_information);
		ecardListLinearLayout=(LinearLayout) findViewById(R.id.ecard_list_linearlayout);
		intent = new Intent();
		mBundle = new Bundle();
	}

	@Override
	protected void onResume() {
		super.onResume();
		taskFlag = GET_CUSTOMER_CARD_LIST_FLAG;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		String categoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if (taskFlag == GET_CUSTOMER_CARD_LIST_FLAG) {
			categoryName = ECARD_CATEGORY;
			methodName = GET_CUSTOMERCARD_LIST;
			try {
				para.put("CustomerID",Integer.parseInt(mCustomerID));

			} catch (JSONException e) {
				e.printStackTrace();
			}
		}

		else if (taskFlag == GET_CARDINFO_FLAG) {
			categoryName = ECARD_CATEGORY;
			methodName = GET_CARDINFO;
			try {
				para.put("CustomerID", mCustomerID);
				para.put("UserCardNo", mUserCardNo);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(categoryName, methodName,para.toString(), header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if (taskFlag == GET_CUSTOMER_CARD_LIST_FLAG) {
					cardList = customerCardInfo.parseListByJson(response.getStringData());
					setEcardDetailList(cardList);
				} else if (taskFlag == GET_CARDINFO_FLAG) {
					ecardInformation.parseByJson(response.getStringData());
					mBundle.putSerializable("EcardInformation",(Serializable)ecardInformation);
					intent.putExtras(mBundle);
					intent.setClass(EcardListActivity.this,EcardDetailActivity.class);
					startActivity(intent);
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}

	private void setEcardDetailList(final List<CustomerCardInfo> cardDetailList) {
		if(cardDetailList.size()>0){
			ecardListLinearLayout.removeAllViews();
			for(int i=0;i<cardDetailList.size();i++){
				final int ecardIndex=i;
				layoutInflater=LayoutInflater.from(this);
				View customerEcardListItem=layoutInflater.inflate(R.xml.ecard_list_item,null);
				TextView customerEcardIsDefault=(TextView)customerEcardListItem.findViewById(R.id.customer_ecard_is_default);
				TextView customerEcardNameText = (TextView) customerEcardListItem.findViewById(R.id.customer_ecard_name);
				TextView customerEcardBalanceText=(TextView) customerEcardListItem.findViewById(R.id.customer_ecard_balance);
				TextView customerEcardNo=(TextView) customerEcardListItem.findViewById(R.id.customer_ecardno);
				RelativeLayout ecardRelativeLayout=(RelativeLayout) customerEcardListItem.findViewById(R.id.ecard_relativelayout);
				final int userCardType=cardDetailList.get(i).getCardTypeID();
				customerEcardNameText.setText(cardDetailList.get(i).getCardName());
				/*if(userCardType==4){
					ecardRelativeLayout.setBackgroundResource(R.drawable.ecard_background_dark_red);
				}*/
				if(userCardType!=4){
					if(userCardType!=2)
						customerEcardBalanceText.setText(NumberFormatUtil.StringFormatToString(this,cardDetailList.get(ecardIndex).getBalance()));
					else
						customerEcardBalanceText.setText(cardDetailList.get(ecardIndex).getBalance());
				}
				else if(userCardType==4){
					customerEcardBalanceText.setText("");
				}
				boolean isDefault=cardDetailList.get(i).getIsDefault();
				if(isDefault)
					customerEcardIsDefault.setVisibility(View.VISIBLE);
				else
					customerEcardIsDefault.setVisibility(View.GONE);
				String userCardNo=cardDetailList.get(i).getUserCardNo();
				if(userCardNo!=null && !"".equals(userCardNo)){
					customerEcardNo.setText("No."+cardDetailList.get(i).getUserCardNo());
				}
				ecardRelativeLayout.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						//如果不是福利包  则跳转到卡详细页
						if(userCardType!=4){
							mUserCardNo = cardDetailList.get(ecardIndex).getUserCardNo();
							intent.putExtra("isDefault",cardDetailList.get(ecardIndex).getIsDefault());
							taskFlag = GET_CARDINFO_FLAG;
							EcardListActivity.super.asyncRefrshView(EcardListActivity.this);
						}
						//如果是福利包，则跳转到福利包页面
						else{
							Intent destIntent=new Intent();
							destIntent.setClass(EcardListActivity.this,CustomerBenefitsActivity.class);
							startActivity(destIntent);
						}
						
					}
				});
				ecardListLinearLayout.addView(customerEcardListItem);
			}
		}
		ecardPaymentInfoBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent historyIntent = new Intent();
				Bundle historyBundle = new Bundle();
				historyBundle.putSerializable("CardList", (Serializable) cardList);
				historyIntent.putExtras(historyBundle);
				historyIntent.setClass(EcardListActivity.this,EcardHistoryListActivity.class);
				startActivity(historyIntent);
			}

		});
	}

}
