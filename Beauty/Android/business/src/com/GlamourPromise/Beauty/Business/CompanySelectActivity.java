package com.GlamourPromise.Beauty.Business;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ExpandableListView;
import android.widget.ExpandableListView.OnChildClickListener;
import android.widget.ExpandableListView.OnGroupClickListener;
import android.widget.ImageButton;

import com.GlamourPromise.Beauty.adapter.CompanySelectAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AccountInfo;
import com.GlamourPromise.Beauty.bean.BranchInfo;

import java.util.ArrayList;

public class CompanySelectActivity extends BaseActivity implements
        OnChildClickListener {
    private ArrayList<AccountInfo> accountInfoList;
    private ArrayList<ArrayList<BranchInfo>> branchInfoList;
    private String loginMobile;
    private CompanySelectAdapter companySelectAdapter;
    private ExpandableListView companySelectListView;
    private ImageButton backButton;
    private UserInfoApplication userInfoApplication;
    private String fromActivityName = "";

    @SuppressWarnings("unchecked")
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_company_select);
        fromActivityName = getIntent().getStringExtra("SRC_ACTIVITY");
        accountInfoList = (ArrayList<AccountInfo>) getIntent().getSerializableExtra("AccountInfoList");
        branchInfoList = (ArrayList<ArrayList<BranchInfo>>) getIntent().getSerializableExtra("BranchInfoList");
        loginMobile = getIntent().getStringExtra("LoginMobile");
        userInfoApplication = (UserInfoApplication) getApplication();
        companySelectListView = (ExpandableListView) findViewById(R.id.company_list);
        companySelectAdapter = new CompanySelectAdapter(this, accountInfoList, branchInfoList);
        // 屏蔽收缩事件
        companySelectListView.setOnGroupClickListener(new OnGroupClickListener() {
            @Override
            public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
                return true;
            }
        });
        companySelectListView.setAdapter(companySelectAdapter);
        // 屏蔽默认的箭头图标
        companySelectListView.setGroupIndicator(null);
        int groupCount = companySelectListView.getCount();
        for (int i = 0; i < groupCount; i++) {
            companySelectListView.expandGroup(i);
        }
        companySelectListView.setOnChildClickListener(this);
        backButton = (ImageButton) findViewById(R.id.btn_main_back_menu);
        backButton.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View arg0) {
                // userInfoApplication.exit(CompanySelectActivity.this);
                if (fromActivityName.equals(SettingActivity.TAG)) {
                    Intent intent = new Intent(CompanySelectActivity.this, HomePageActivity.class);
                    startActivity(intent);
                } else if (fromActivityName.equals(LoginActivity.TAG)) {

                }
                CompanySelectActivity.this.finish();
            }
        });
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (fromActivityName.equals(SettingActivity.TAG)) {
                Intent intent = new Intent(CompanySelectActivity.this, HomePageActivity.class);
                startActivity(intent);
            } else if (fromActivityName.equals(LoginActivity.TAG)) {

            }
            CompanySelectActivity.this.finish();
        }
        return super.onKeyUp(keyCode, event);
    }

    @Override
    public boolean onChildClick(ExpandableListView arg0, View arg1, int arg2,
                                int arg3, long arg4) {
        // TODO Auto-generated method stub
        userInfoApplication.setAccountInfoPosition(arg2, arg3);
        accountInfoList.get(arg2).setLoginMobile(loginMobile);
        accountInfoList.get(arg2).setBranchId(Integer.valueOf(branchInfoList.get(arg2).get(arg3).getId()));
        Intent intent = new Intent(this, HomePageActivity.class);
        intent.putExtra("AccountInfo", accountInfoList.get(arg2));
        intent.putExtra("IsNormalLogin", false);
        userInfoApplication.setSelectedCustomerID(0);
        userInfoApplication.setSelectedCustomerName("");
        userInfoApplication.setSelectedCustomerHeadImageURL("");
        userInfoApplication.setSelectedCustomerLoginMobile("");
        userInfoApplication.setOrderInfo(null);
        userInfoApplication.setAccountNewMessageCount(0);
        userInfoApplication.setAccountNewRemindCount(0);
        userInfoApplication.setNeedUpdateLoginInfo(true);
        startActivity(intent);
        finish();
        return true;
    }
}
