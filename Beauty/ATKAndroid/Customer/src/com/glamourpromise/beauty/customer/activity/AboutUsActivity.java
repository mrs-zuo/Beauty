package com.glamourpromise.beauty.customer.activity;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;

public class AboutUsActivity extends BaseActivity implements OnClickListener {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_about_us);
		super.setTitle("关于我们");
		TextView versionView = (TextView) findViewById(R.id.software_version);
		String currentVersion = ((UserInfoApplication)getApplication()).getPackageVersion();
		versionView.setText(getString(R.string.software_version) + currentVersion);
		Animation animation = AnimationUtils.loadAnimation(this,R.anim.anim_activity_in);
		findViewById(R.id.content).setAnimation(animation);
		findViewById(R.id.content).startAnimation(animation);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
	}
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
	}
}
