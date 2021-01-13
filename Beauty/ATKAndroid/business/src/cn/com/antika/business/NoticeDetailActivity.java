package cn.com.antika.business;

import cn.com.antika.bean.NoticeInfo;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

import android.os.Bundle;
import android.view.Window;
import android.widget.TextView;

public class NoticeDetailActivity extends BaseActivity {
    private NoticeInfo noticeInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_notice_detail);
        noticeInfo = (NoticeInfo) getIntent().getSerializableExtra("NoticeInfo");
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);

        TextView titleView = (TextView) findViewById(R.id.notice_title_text);
        titleView.setText(noticeInfo.getNoticeTitle());

        TextView timeView = (TextView) findViewById(R.id.time_content_text);
        timeView.setText(noticeInfo.getNoticeStartTime() + "~" + noticeInfo.getNoticeEndTime());

        TextView contentView = (TextView) findViewById(R.id.notice_content_text);
        contentView.setText(noticeInfo.getNoticeContent());

    }
}
