package cn.com.antika.business;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Switch;
import android.widget.TextView;

import java.lang.ref.WeakReference;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.Contact;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

public class EditServiceOrderContactDetailMainActivity extends BaseActivity
		implements OnClickListener {
	private EditServiceOrderContactDetailMainActivityHandler mHandler = new EditServiceOrderContactDetailMainActivityHandler(this);
	private TextView serviceOrderContactDetailTime;
	private EditText serviceOrderContactDetailRemark;
	private Contact contact;
	private Switch serviceOrderContactDetailStatusSwitch;
	private ImageButton editServiceOrderContactDetailMakeSureBtn;
	private Thread requestWebServiceThread;
	private UserInfoApplication userinfoApplication;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_edit_service_order_contact_detail_main);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		contact = (Contact) getIntent().getSerializableExtra("contact");
		serviceOrderContactDetailTime = (TextView) findViewById(R.id.edit_service_order_contact_detail_time);
		serviceOrderContactDetailRemark = (EditText) findViewById(R.id.edit_service_order_contact_detail_remark_text);
		serviceOrderContactDetailStatusSwitch = (Switch) findViewById(R.id.edit_service_order_contact_detail_status);
		editServiceOrderContactDetailMakeSureBtn = (ImageButton) findViewById(R.id.edit_service_order_contact_detail_make_sure_btn);
		editServiceOrderContactDetailMakeSureBtn.setOnClickListener(this);
		serviceOrderContactDetailTime.setText(contact.getTime());
		int tcontactIsCompleted = contact.getIsCompleted();
		if (tcontactIsCompleted == 1)
			serviceOrderContactDetailStatusSwitch.setChecked(true);
		else if (tcontactIsCompleted == 0)
			serviceOrderContactDetailStatusSwitch.setChecked(false);
		else
			serviceOrderContactDetailStatusSwitch.setChecked(false);
		serviceOrderContactDetailRemark.setText(contact.getRemark());
		userinfoApplication=UserInfoApplication.getInstance();
	}

	private static class EditServiceOrderContactDetailMainActivityHandler extends Handler {
		private final EditServiceOrderContactDetailMainActivity editServiceOrderContactDetailMainActivity;

		private EditServiceOrderContactDetailMainActivityHandler(EditServiceOrderContactDetailMainActivity activity) {
			WeakReference<EditServiceOrderContactDetailMainActivity> weakReference = new WeakReference<EditServiceOrderContactDetailMainActivity>(activity);
			editServiceOrderContactDetailMainActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 1) {
				DialogUtil.createShortDialog(
						editServiceOrderContactDetailMainActivity,
						"联系详情更新成功！");
				Intent destIntent = new Intent(
						editServiceOrderContactDetailMainActivity,
						OrderListActivity.class);
				editServiceOrderContactDetailMainActivity.startActivity(destIntent);
				editServiceOrderContactDetailMainActivity.finish();
			} else if (msg.what == 0) {
				DialogUtil.createShortDialog(
						editServiceOrderContactDetailMainActivity,
						"联系详情更新失败，请重试!");
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(editServiceOrderContactDetailMainActivity,
						"您的网络貌似不给力，请重试");
		}
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.edit_service_order_contact_detail_make_sure_btn:
			/*requestWebServiceThread = new Thread() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					String methodName = "updateContact";
					String endPoint = "order.asmx";
					Map<String, String> paramMap = new HashMap<String, String>();
					paramMap.put("AccountID", String
							.valueOf(userinfoApplication
									.getAccountInfo().getAccountId()));
					paramMap.put("Remark", serviceOrderContactDetailRemark
							.getText().toString());
					paramMap.put("ContactID", String.valueOf(contact.getId()));
					if (serviceOrderContactDetailStatusSwitch.isChecked())
						paramMap.put("Status", "1");
					else if (!serviceOrderContactDetailStatusSwitch.isChecked())
						paramMap.put("Status", "0");
					paramMap.put("ScheduleID",
							String.valueOf(contact.getScheduleID()));
					SoapObject object = WebServiceUtil
							.requestWebServiceWithSSL(endPoint, methodName,
									paramMap);
					if(object==null)
						mHandler.sendEmptyMessage(2);
					else
					{
						SoapObject soapChilds1 = (SoapObject) object.getProperty(0);
						SoapObject soapChilds2 = (SoapObject) soapChilds1.getProperty(0);
						String flag = soapChilds2.getPropertyAsString("Flag");
						if (flag != null && !(("").equals(flag))
								&& ("1").equals(flag.trim()))
							mHandler.sendEmptyMessage(1);
						else
							mHandler.sendEmptyMessage(0);
					}
				}
			};
			requestWebServiceThread.start();*/
			break;
		}

	}
}
