package com.GlamourPromise.Beauty.Business;

import android.os.Bundle;
import android.view.Window;
import android.webkit.WebView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;


public class MemorySpaceActivity extends BaseActivity {
    private WebView memorySpaceWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_memory_space);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        memorySpaceWebView = (WebView) findViewById(R.id.image_space_usage);
        //WebSettings websetting=imageSpaceWebView.getSettings();
        //自适应屏幕
        memorySpaceWebView.getSettings().setUseWideViewPort(true);
        memorySpaceWebView.getSettings().setLoadWithOverviewMode(true);
        //websetting.setSupportZoom(true);
        //websetting.setBuiltInZoomControls(true);
        memorySpaceWebView.loadUrl("http://192.168.0.13/MemorySpaceView.aspx?companyid=" + UserInfoApplication.getInstance().getAccountInfo().getCompanyId());
        //memorySpaceWebView.loadUrl("http://192.168.0.13/MemorySpaceView.aspx?companyid=17");
    }
}
