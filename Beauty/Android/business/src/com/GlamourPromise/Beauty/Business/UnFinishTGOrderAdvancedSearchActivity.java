package com.GlamourPromise.Beauty.Business;

import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.GlamourPromise.Beauty.bean.SearchPersonLocal;

import java.io.Serializable;
import java.util.List;

/*
 *结单的高级筛选
 * */
public class UnFinishTGOrderAdvancedSearchActivity extends BaseActivity implements OnClickListener{
	private  EditText  unfinshTgOrderCustomerEditText,unfinshTgOrderServicePICEditText;
	private  ImageView searchBackBtn;
	private  List<SearchPersonLocal>  customerList,servicePICList;
	private  int       searchCustomerID,searchServicePICID;//选中搜索的顾客ID和服务顾问ID
	private  String    searchCustomerName,searchServicePICName;//选中搜索的顾客姓名和服务顾问姓名
	private  Button    searchResetBtn,searchBtn;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_unfinish_tg_order_advanced_search);
		initView();
	}

	private void initView() {
		unfinshTgOrderCustomerEditText=(EditText)findViewById(R.id.unfinish_tg_order_advanced_customer_edit_text);
		unfinshTgOrderCustomerEditText.setInputType(InputType.TYPE_NULL);
		unfinshTgOrderServicePICEditText=(EditText)findViewById(R.id.unfinish_tg_order_service_pic_edit_text);
		unfinshTgOrderServicePICEditText.setInputType(InputType.TYPE_NULL);
		searchResetBtn=(Button)findViewById(R.id.unfinish_tg_order_advanced_search_reset_btn);
		searchBtn=(Button)findViewById(R.id.unfinish_tg_order_advanced_search_make_sure_btn);
		searchBackBtn=(ImageView)findViewById(R.id.search_back_btn);
		unfinshTgOrderCustomerEditText.setOnClickListener(this);
		unfinshTgOrderServicePICEditText.setOnClickListener(this);
		searchResetBtn.setOnClickListener(this);
		searchBtn.setOnClickListener(this);
		searchBackBtn.setOnClickListener(this);
		Intent intent=getIntent();
		customerList=(List<SearchPersonLocal>)intent.getSerializableExtra("customerList");
		servicePICList=(List<SearchPersonLocal>)intent.getSerializableExtra("servicePICList");
	}
	@Override
	public boolean onKeyUp(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			this.finish();
		}
		return super.onKeyUp(keyCode, event);
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.gc();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode!=RESULT_OK){
			return;
		}
		else{
			int    personID=data.getIntExtra("personId",0);
			String personName=data.getStringExtra("personName");
			//选择顾客成功
			if(requestCode==100){
				setPersonValue(0, personID, personName);
			}
			//选择服务顾问成功
			else if(requestCode==200){
				setPersonValue(1, personID, personName);
			}
		}
	}
	private void  setPersonValue(int  personType,int personID,String personName){
		if(personType==0){
			searchCustomerID=personID;
			searchCustomerName=personName;
			unfinshTgOrderCustomerEditText.setText(personName);
		}
		else if(personType==1){
			searchServicePICID=personID;
			searchServicePICName=personName;
			unfinshTgOrderServicePICEditText.setText(personName);
		}
	}

	@Override
	public void onClick(View view) {
		switch(view.getId()){
		case R.id.unfinish_tg_order_advanced_customer_edit_text:
			Intent destIntent=new Intent(this,ChoosePersonLocalActivity.class);
			Bundle bundle=new Bundle();
			bundle.putSerializable("customerList",(Serializable)customerList);
			destIntent.putExtras(bundle);
			destIntent.putExtra("searchMode",0);
			startActivityForResult(destIntent,100);
			break;
		case R.id.unfinish_tg_order_service_pic_edit_text:
			Intent destIntent2=new Intent(this,ChoosePersonLocalActivity.class);
			Bundle bundle2=new Bundle();
			bundle2.putSerializable("servicePICList",(Serializable)servicePICList);
			destIntent2.putExtras(bundle2);
			destIntent2.putExtra("searchMode",1);
			startActivityForResult(destIntent2,200);
			break;
		case R.id.unfinish_tg_order_advanced_search_reset_btn:
			unfinshTgOrderCustomerEditText.setText("");
			unfinshTgOrderServicePICEditText.setText("");
			searchCustomerID=0;
			searchServicePICID=0;
			break;
		case R.id.unfinish_tg_order_advanced_search_make_sure_btn:
			Intent  reslutData = new Intent();
			reslutData.putExtra("customerID",searchCustomerID);
			reslutData.putExtra("servicePICID",searchServicePICID);
			setResult(RESULT_OK,reslutData);
			this.finish();
			break;
		case R.id.search_back_btn:
			this.finish();
			break;
		}
	}
}
