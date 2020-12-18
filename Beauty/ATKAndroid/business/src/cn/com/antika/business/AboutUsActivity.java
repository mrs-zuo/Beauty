package cn.com.antika.business;

import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import android.os.Bundle;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.view.Window;
import android.widget.TextView;


public class AboutUsActivity extends BaseActivity{
	private  TextView  softwareVersionText;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_about_us);
		BusinessLeftImageButton bussinessLeftMenuBtn=(BusinessLeftImageButton)findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn=(BusinessRightImageButton)findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		softwareVersionText=(TextView)findViewById(R.id.software_version);
		PackageManager pm = getPackageManager();
		PackageInfo pi = null;
		try {
			pi = pm.getPackageInfo(getPackageName(), 0);
		} catch (NameNotFoundException e) {
			
		}
		String version = pi.versionName;
		softwareVersionText.setText("软件版本:V"+version);
	}
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.gc();
	}
}
