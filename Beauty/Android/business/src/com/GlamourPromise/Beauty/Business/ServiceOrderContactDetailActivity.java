package com.GlamourPromise.Beauty.Business;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.Contact;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

public class ServiceOrderContactDetailActivity extends BaseActivity {
    private TextView serviceOrderContactDetailTime;
    private TextView serviceOrderContactDetailStatus;
    private TextView serviceOrderContactDetailRemark;
    private ImageButton serviceOrderContactDetailEditBtn;
    private Contact contact;
    private UserInfoApplication userinfoApplication;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_service_order_contact_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        Intent intent = getIntent();
        contact = (Contact) intent.getSerializableExtra("contact");
        serviceOrderContactDetailTime = (TextView) findViewById(R.id.service_order_contact_detail_time);
        serviceOrderContactDetailStatus = (TextView) findViewById(R.id.service_order_contact_detail_status);
        serviceOrderContactDetailRemark = (TextView) findViewById(R.id.service_order_contact_detail_remark_text);
        serviceOrderContactDetailEditBtn = (ImageButton) findViewById(R.id.service_order_contact_detail_edit_btn);
        serviceOrderContactDetailEditBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                Intent destIntent = new Intent(ServiceOrderContactDetailActivity.this, EditServiceOrderContactDetailMainActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("contact", contact);
                destIntent.putExtras(bundle);
                startActivity(destIntent);
            }
        });
        serviceOrderContactDetailTime.setText(contact.getTime());
        int isCompleted = contact.getIsCompleted();
        if (isCompleted == 1)
            serviceOrderContactDetailStatus.setText("已完成");
        else
            serviceOrderContactDetailStatus.setText("未完成");
        serviceOrderContactDetailRemark.setText(contact.getRemark());
        userinfoApplication = UserInfoApplication.getInstance();
    }
}
