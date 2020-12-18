package com.glamourpromise.beauty.customer.activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View.OnClickListener;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
public class NoticeDetailActivity extends BaseActivity implements OnClickListener {
	private String strNoticeTitle;
	private String strNoticeTime;
	private String strNoticeContent;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_notice_detail);
		super.setTitle(getString(R.string.title_notice_detail));
		Intent intent = getIntent();
		strNoticeTitle = intent.getStringExtra("NoticeTitle");
		strNoticeTime = intent.getStringExtra("NoticeTime");
		strNoticeContent = intent.getStringExtra("NoticeContent");
		if(savedInstanceState == null){
			initView();
		}
	}
	@Override
	protected void onResume() {
		super.onResume();
	}
	protected void initView() {
		TextView titleView = (TextView) findViewById(R.id.notice_title_text);
		titleView.setText(strNoticeTitle);
		TextView timeView = (TextView) findViewById(R.id.time_content_text);
		timeView.setText(strNoticeTime);
		TextView contentView = (TextView) findViewById(R.id.notice_content_text);
		contentView.setText(strNoticeContent);
	}
}
