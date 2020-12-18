package com.glamourpromise.beauty.customer.activity;

import android.os.Bundle;
import android.view.Window;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.ContactInformation;

public class ServiceOrderContactDetailActivity extends BaseActivity {
	ContactInformation contactInforamtion;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_service_order_contact_detail);

		contactInforamtion = (ContactInformation) getIntent()
				.getSerializableExtra("ContactItem");

		initView();
	}

	private void initView() {
		TextView contactTime = (TextView) findViewById(R.id.contact_time);
		contactTime.setText(contactInforamtion.getTime());

		TextView contactStatus = (TextView) findViewById(R.id.contact_status);
		if (contactInforamtion.getIsComplete().equals("0")) {
			contactStatus.setText("δ���");
		} else if (contactInforamtion.getIsComplete().equals("1")) {
			contactStatus.setText("�����");
		}

		if (!contactInforamtion.getRemark().equals("")) {
			TextView remark = (TextView) findViewById(R.id.contact_remark);
			remark.setText(contactInforamtion.getRemark());
		}
	}
}
