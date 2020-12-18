package com.GlamourPromise.Beauty.Business;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import android.os.Bundle;
import android.view.Window;
import android.webkit.WebView;

public class ThirdPartPayHelpActivity extends BaseActivity {
	private WebView    thirdPartPayHelpWebView;
	private int        paymentMode;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_wei_xin_pay_help);
		initView();
	}
	private  void initView(){
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		thirdPartPayHelpWebView=(WebView) findViewById(R.id.wei_xin_pay_help_webview);	
		paymentMode=getIntent().getIntExtra("paymentMode",Constant.PAYMENT_MODE_WEIXIN);
		if(paymentMode==Constant.PAYMENT_MODE_WEIXIN)
			thirdPartPayHelpWebView.loadUrl("http://kf.qq.com/touch/faq/151210NZzmuY151210ZRj2y2.html");
		else if(paymentMode==Constant.PAYMENT_MODE_ALI)
			thirdPartPayHelpWebView.loadUrl("https://cschannel.alipay.com/mobile/helpDetail.htm?help_id=419480");
	}
}
