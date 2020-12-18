package com.glamourpromise.beauty.customer.activity;

import java.util.List;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.ListView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.FindPasswordCompanySelectAdapter;
import com.glamourpromise.beauty.customer.adapter.FindPasswordCompanySelectAdapter.onButtonClickListener;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.UserInformation;

public class FindPasswordCompanySelectActivity extends BaseActivity implements OnClickListener {
	private ListView companySelectView;
	private ImageButton mBtnSelectAll;
	private List<UserInformation> companyList;
	private FindPasswordCompanySelectAdapter mAdapter;
	private String mLonginMobile;

	@SuppressWarnings("unchecked")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_find_password_company_select);
		super.setTitle(getString(R.string.title_company_select_list));
		companyList = (List<UserInformation>) getIntent().getSerializableExtra("companyList");
		mLonginMobile = getIntent().getStringExtra("LoginMobile");
		companySelectView = (ListView) findViewById(R.id.company_list);
		onButtonClickListener listener = new onButtonClickListener() {
			
			@Override
			public void onClick(boolean isAllselected) {
				// TODO Auto-generated method stub
				changeSelectAllButtonStatus(isAllselected);
			}
		};
		mAdapter = new FindPasswordCompanySelectAdapter(this,companyList, listener);
		companySelectView.setAdapter(mAdapter);
		findViewById(R.id.cancel).setOnClickListener(this);
		findViewById(R.id.confirm).setOnClickListener(this);
		mBtnSelectAll = (ImageButton) findViewById(R.id.select_all_button);
		mBtnSelectAll.setOnClickListener(this);
		//隐藏右侧的home键
		super.hideHome();
	}
	
	private void changeSelectAllButtonStatus(boolean isAllselected){
		if(isAllselected){
			mBtnSelectAll.setBackgroundResource(R.drawable.all_select_icon);
		}else{
			mBtnSelectAll.setBackgroundResource(R.drawable.all_unselect_icon);
		}
	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		switch (resultCode) { // resultCode为回传的标记
		case RESULT_OK:
			this.finish();
			break;
		default:
			break;
		}
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.cancel:
			this.finish();
			break;
		case R.id.select_all_button:
			int count = mAdapter.getSelectCount();
			//已经全选时，再次点击则改变为不选择
			if(count == mAdapter.getCount()){
				mAdapter.setSelectAllStatus(false);
				changeSelectAllButtonStatus(false);
			}else{
				mAdapter.setSelectAllStatus(true);
				changeSelectAllButtonStatus(true);
			}
			
			break;
		case R.id.confirm:
			int selectCount = mAdapter.getSelectCount();
			if(selectCount == 0){
				
			}else{
				String strSelectIDs = mAdapter.getSelectCompanyIDs();
				Intent destIntent = new Intent(this,FindPasswordUpdatePasswordActivity.class);
				destIntent.putExtra("customerID", strSelectIDs);
				destIntent.putExtra("LoginMobile", mLonginMobile);
				destIntent.putExtra("isAbleBack", "true");// 判断是否能返回
				startActivityForResult(destIntent, 0);
			}
			break;
		default:
			break;
		}
	}
}
