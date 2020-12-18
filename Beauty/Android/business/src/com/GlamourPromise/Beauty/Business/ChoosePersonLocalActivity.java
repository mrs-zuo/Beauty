package com.GlamourPromise.Beauty.Business;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.ChoosePersonLocalListAdapter;
import com.GlamourPromise.Beauty.bean.SearchPersonLocal;

import java.util.List;
/*
 *显示本地的顾客列表和服务顾问列表
 * */
public class ChoosePersonLocalActivity extends BaseActivity implements OnClickListener{
	private  List<SearchPersonLocal> customerList,servicePICList;
	private  int                     searchMode;//0:按照选择顾客搜索   1：按照服务顾问搜索
	private  ListView                personLocalListView;
	private  ChoosePersonLocalListAdapter choosePersonLocalListAdapter;
	private  ImageView                    choosePersonLocalBackBtn;
	private  TextView                     choosePersonLocalTitleText;
	private  Button                       chooseLocalMakeSureBtn;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_choose_person_local);
		initView();
	}

	protected void initView() {
		choosePersonLocalTitleText=(TextView) findViewById(R.id.choose_person_local_title_text);
		Intent intent=getIntent();
		searchMode=intent.getIntExtra("searchMode",-1);
		choosePersonLocalBackBtn=(ImageView) findViewById(R.id.choose_person_local_back_btn);
		choosePersonLocalBackBtn.setOnClickListener(this);
		chooseLocalMakeSureBtn=(Button)findViewById(R.id.choose_local_make_sure_btn);
		chooseLocalMakeSureBtn.setOnClickListener(this);
		personLocalListView=(ListView)findViewById(R.id.choose_person_local_list_view);
		if(searchMode==0){
			choosePersonLocalTitleText.setText("选择顾客");
			customerList=(List<SearchPersonLocal>)intent.getSerializableExtra("customerList");
			choosePersonLocalListAdapter=new ChoosePersonLocalListAdapter(this,customerList,0,"");
		}
		else if(searchMode==1){
			choosePersonLocalTitleText.setText("选择顾问");
			servicePICList=(List<SearchPersonLocal>)intent.getSerializableExtra("servicePICList");
			choosePersonLocalListAdapter=new ChoosePersonLocalListAdapter(this,servicePICList,0,"");
		}	
		personLocalListView.setAdapter(choosePersonLocalListAdapter);
	}
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
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		if(view.getId()==R.id.choose_person_local_back_btn){
			this.finish();
		}
		else if(view.getId()==R.id.choose_local_make_sure_btn){
			Intent reslutData = null;
			int personId = 0;
			String personName = "";
			final List<SearchPersonLocal> selectPersonList = choosePersonLocalListAdapter.checkedPerson;
			if (selectPersonList!= null &&  selectPersonList.size() != 0){
				personId = selectPersonList.get(0).getPersonID();
				personName = selectPersonList.get(0).getPersonName();
				reslutData = new Intent();
				reslutData.putExtra("personId",personId);
				reslutData.putExtra("personName",personName);
			}
			else{
				reslutData = new Intent();
				reslutData.putExtra("personId",0);
				reslutData.putExtra("personName","");
			}
			setResult(RESULT_OK, reslutData);
			finish();
		}
	}

}
