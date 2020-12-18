/**
 * OrderSearchNewActivity.java
 * cn.com.antika.business
 * tim.zhang@bizapper.com
 * 2015年1月28日 上午11:53:42
 * @version V1.0
 */
package cn.com.antika.business;
import org.json.JSONArray;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderListBaseConditionInfo;
import cn.com.antika.util.DialogUtil;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.SearchView;

/*
 * 
 * 订单搜索界面  输入订单号或者服务或者商品名称
 * */
public class OrderSearchActivity extends Activity implements OnClickListener{
	private UserInfoApplication userinfoApplication;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_order_search);
		findViewById(R.id.order_search_back_btn).setOnClickListener(this);
		findViewById(R.id.search_order_btn).setOnClickListener(this);
		userinfoApplication=(UserInfoApplication)getApplication();
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch(view.getId()){
		case R.id.order_search_back_btn:
			this.finish();
			break;
		case R.id.search_order_btn:
			String searchWord=((SearchView)findViewById(R.id.search_order)).getQuery().toString();
			if(searchWord==null || "".equals(searchWord)){
				DialogUtil.createShortDialog(this,"请输入要查询的订单编号或服务商品名称!");
			}
			else{
				OrderListBaseConditionInfo orderListBaseConditionInfo=new OrderListBaseConditionInfo();
				orderListBaseConditionInfo.setAccountID(userinfoApplication.getAccountInfo().getAccountId());
				orderListBaseConditionInfo.setBranchID(userinfoApplication.getAccountInfo().getBranchId());
				int authAllTheBranchOrderRead=userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
				if(authAllTheBranchOrderRead==1)
					orderListBaseConditionInfo.setResponsiblePersonIDs("");
				else if(authAllTheBranchOrderRead==0)
					orderListBaseConditionInfo.setResponsiblePersonIDs(new JSONArray().put(userinfoApplication.getAccountInfo().getAccountId()).toString());
				orderListBaseConditionInfo.setResponsiblePersonName(userinfoApplication.getAccountInfo().getAccountName());
				orderListBaseConditionInfo.setCreateTime("");
				orderListBaseConditionInfo.setPageIndex(1);
				orderListBaseConditionInfo.setPageSize(10);
				orderListBaseConditionInfo.setOrderSource(-1);
				orderListBaseConditionInfo.setProductType(-1);
				orderListBaseConditionInfo.setPaymentStatus(-1);
				orderListBaseConditionInfo.setStatus(-1);
				orderListBaseConditionInfo.setIsBusiness(1);
				orderListBaseConditionInfo.setSearchWord(searchWord);
				Intent data=new Intent();
				data.putExtra("baseCondition",orderListBaseConditionInfo);
				setResult(1,data);
				finish();
			}
			break;
		}
	}
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.gc();
	}
}
