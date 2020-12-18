package cn.com.antika.business;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AccountInfo;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

import android.os.Bundle;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

public class ReportMainActivity extends BaseActivity implements OnClickListener {
	private View myReportBeforeView;
	private RelativeLayout myReportRelativeLayout;
	private View myReportAfterView;
	private View employeeReportBeforeView;
	private RelativeLayout employeeReportRelativeLayout;
	private View employeeReportAfterView;
	private UserInfoApplication userinfoApplication;
	// 本门店报表
	private ImageButton myBranchReportDownIcon;
	private ImageButton myBranchReportUpIcon;
	//本门店运营状况统计
	private View myBranchTotalBeforeView;
	private RelativeLayout myBranchTotalRelativeLayout;
	private View myBranchReportBeforeView;
	private RelativeLayout myBranchReportRelativeLayout;
	// 本门店报表按周期统计
	private View myBranchReportByDateBeforeView;
	private RelativeLayout myBranchReportByDateRelativeLayout;
	private View myBranchReportByDateAfterView;
	// 本门店累计数据
	private RelativeLayout myBranchReportTotalRelativeLayout;
	private View myBranchReportTotalAfterView;
	//门店数据统计分析
	private RelativeLayout myBranchReportAnalysisRelativeLayout;
	private View           myBranchReportAnalysisAfterView;
	//门店财务总览
	private View           myBranchReportJournalBeforeView;
	private RelativeLayout myBranchReportJournalRelativeLayout;
	//分组报表
	private View            groupReportBeforeView;
	private RelativeLayout  groupReportRelativelayout;
	private View 			groupReportAfterView;
	private Animation       mShowAnimation;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_report_main);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		mShowAnimation=AnimationUtils.loadAnimation(this,R.anim.anim_view_show);
		// 我的报表
		myReportBeforeView = findViewById(R.id.my_report_before_view);
		myReportRelativeLayout = (RelativeLayout) findViewById(R.id.my_report_relativelayout);
		myReportAfterView = findViewById(R.id.my_report_after_view);
		// 员工报表
		employeeReportBeforeView = findViewById(R.id.employee_report_before_view);
		employeeReportRelativeLayout = (RelativeLayout) findViewById(R.id.employee_report_relativelayout);
		employeeReportAfterView = findViewById(R.id.employee_report_after_view);
		//分组报表
		groupReportBeforeView=findViewById(R.id.group_report_before_view);
		groupReportRelativelayout=(RelativeLayout) findViewById(R.id.group_report_relativelayout);
		groupReportRelativelayout.setOnClickListener(this);
		groupReportAfterView=findViewById(R.id.group_report_after_view);
		// 门店报表
		myBranchReportBeforeView = findViewById(R.id.my_branch_report_before_view);
		myBranchReportRelativeLayout = (RelativeLayout) findViewById(R.id.my_branch_report_relativelayout);
		myBranchReportRelativeLayout.setOnClickListener(this);
		// 门店按周期统计报表
		myBranchReportDownIcon = (ImageButton) findViewById(R.id.my_branch_report_down_icon);
		myBranchReportUpIcon = (ImageButton) findViewById(R.id.my_branch_report_up_icon);
		myBranchReportByDateBeforeView = findViewById(R.id.my_branch_report_by_date_before_view);
		myBranchReportByDateRelativeLayout = (RelativeLayout) findViewById(R.id.my_branch_report_by_date_relativelayout);
		myBranchReportByDateAfterView = findViewById(R.id.my_branch_report_by_date_after_view);
		// 门店累计数据
		myBranchReportTotalRelativeLayout = (RelativeLayout) findViewById(R.id.my_branch_report_total_relativelayout);
		myBranchReportTotalAfterView = findViewById(R.id.my_branch_report_total_after_view);
		//门店数据统计分析
		myBranchReportAnalysisRelativeLayout=(RelativeLayout)findViewById(R.id.my_branch_report_analysis_relativelayout);
		myBranchReportAnalysisAfterView=findViewById(R.id.my_branch_report_analysis_after_view);
		//门店财务总览
		myBranchReportJournalBeforeView=findViewById(R.id.my_branch_journal_before_view);
		myBranchReportJournalRelativeLayout=(RelativeLayout)findViewById(R.id.my_branch_journal_relativelayout);
		myBranchReportJournalRelativeLayout.setOnClickListener(this);
		
		myReportRelativeLayout.setOnClickListener(this);
		employeeReportRelativeLayout.setOnClickListener(this);
		//门店状况运营统计
		myBranchTotalBeforeView=findViewById(R.id.my_branch_total_before_view);
		myBranchTotalRelativeLayout=(RelativeLayout) findViewById(R.id.my_branch_total_relativelayout);
		myBranchTotalRelativeLayout.setOnClickListener(this);
		// 本店按周期统计
		myBranchReportByDateRelativeLayout.setOnClickListener(this);
		myBranchReportTotalRelativeLayout.setOnClickListener(this);
		//门店数据统计分析
		myBranchReportAnalysisRelativeLayout.setOnClickListener(this);
		AccountInfo accountInfo = userinfoApplication.getAccountInfo();
		int authMyReportRead = accountInfo.getAuthMyReportRead();
		int authBusinessReportRead = accountInfo.getAuthBusinessReportRead();
		// 查看我的报表权限
		if (authMyReportRead == 0) {
			myReportBeforeView.setVisibility(View.GONE);
			myReportRelativeLayout.setVisibility(View.GONE);
			myReportAfterView.setVisibility(View.GONE);
			employeeReportBeforeView.setVisibility(View.GONE);
			employeeReportRelativeLayout.setVisibility(View.GONE);
			employeeReportAfterView.setVisibility(View.GONE);
		}
		//如果没有查看商家报表的权限，则不能查看门店报表和分组报表
		if (authBusinessReportRead == 0) {
			myBranchReportBeforeView.setVisibility(View.GONE);
			myBranchReportRelativeLayout.setVisibility(View.GONE);
			myBranchReportTotalAfterView.setVisibility(View.GONE);
			myBranchReportByDateBeforeView.setVisibility(View.GONE);
			myBranchReportByDateRelativeLayout.setVisibility(View.GONE);
			myBranchReportByDateAfterView.setVisibility(View.GONE);
			groupReportBeforeView.setVisibility(View.GONE);
			groupReportRelativelayout.setVisibility(View.GONE);
			groupReportAfterView.setVisibility(View.GONE);
			
		}
	}
	@Override
	public void onClick(View view) {
		Intent destIntent = null;
		switch (view.getId()) {
		case R.id.my_report_relativelayout:
			destIntent=new Intent();
			boolean isComissionCalc=userinfoApplication.getAccountInfo().isComissionCalc();
			//判断是否使用系统的提成计算，如果使用 则跳转到我的报表  可查看业绩和提成  不使用的话，则跳转到我的报表详细页面
			if(isComissionCalc){
				destIntent.setClass(this,MyReportMainActivity.class);
			}
			else{
				destIntent = new Intent(this,ReportByDateActivity.class);
				destIntent.putExtra("REPORT_TYPE", Constant.MY_REPORT);
			}
			startActivity(destIntent);
			break;
		case R.id.my_branch_report_by_date_relativelayout:
			destIntent = new Intent(this, ReportByDateActivity.class);
			destIntent.putExtra("REPORT_TYPE", Constant.MY_BRANCH_REPORT);
			startActivity(destIntent);
			break;
		case R.id.employee_report_relativelayout:
			destIntent = new Intent(this, ReportListActivity.class);
			destIntent.putExtra("REPORT_TYPE", Constant.EMPLOYEE_REPORT);
			startActivity(destIntent);
			break;
		case R.id.my_branch_report_total_relativelayout:
			destIntent = new Intent(this, ReportTotalActivity.class);
			destIntent.putExtra("BranchID",userinfoApplication.getAccountInfo().getBranchId());
			startActivity(destIntent);
			break;
		// 点击门店报表 出现按周期统计和累计数据
		case R.id.my_branch_report_relativelayout:
			if (myBranchReportByDateRelativeLayout.getVisibility() == View.VISIBLE) {
				myBranchReportDownIcon.setVisibility(View.VISIBLE);
				myBranchReportUpIcon.setVisibility(View.GONE);
				myBranchReportByDateBeforeView.setVisibility(View.GONE);
				myBranchReportByDateAfterView.setVisibility(View.GONE);
				myBranchReportByDateRelativeLayout.setVisibility(View.GONE);
				myBranchReportTotalRelativeLayout.setVisibility(View.GONE);
				myBranchTotalBeforeView.setVisibility(View.GONE);
				myBranchTotalRelativeLayout.setVisibility(View.GONE);
				myBranchReportAnalysisRelativeLayout.setVisibility(View.GONE);
				myBranchReportAnalysisAfterView.setVisibility(View.GONE);
				myBranchReportJournalBeforeView.setVisibility(View.GONE);
				myBranchReportJournalRelativeLayout.setVisibility(View.GONE);
			} else if (myBranchReportByDateRelativeLayout.getVisibility() == View.GONE) {
				myBranchReportDownIcon.setVisibility(View.GONE);
				myBranchReportUpIcon.setVisibility(View.VISIBLE);
				myBranchReportByDateBeforeView.setVisibility(View.VISIBLE);
				myBranchReportByDateBeforeView.startAnimation(mShowAnimation);
				myBranchReportByDateAfterView.setVisibility(View.VISIBLE);
				myBranchReportByDateAfterView.startAnimation(mShowAnimation);
				myBranchReportByDateRelativeLayout.setVisibility(View.VISIBLE);
				myBranchReportByDateRelativeLayout.startAnimation(mShowAnimation);
				myBranchReportTotalRelativeLayout.setVisibility(View.VISIBLE);
				myBranchReportTotalRelativeLayout.startAnimation(mShowAnimation);
				myBranchTotalBeforeView.setVisibility(View.VISIBLE);
				myBranchTotalBeforeView.startAnimation(mShowAnimation);
				myBranchTotalRelativeLayout.setVisibility(View.VISIBLE);
				myBranchTotalRelativeLayout.startAnimation(mShowAnimation);
				myBranchReportAnalysisRelativeLayout.setVisibility(View.VISIBLE);
				myBranchReportAnalysisRelativeLayout.startAnimation(mShowAnimation);
				myBranchReportAnalysisAfterView.setVisibility(View.VISIBLE);
				myBranchReportJournalBeforeView.setVisibility(View.VISIBLE);
				myBranchReportJournalBeforeView.startAnimation(mShowAnimation);
				myBranchReportJournalRelativeLayout.setVisibility(View.VISIBLE);
				myBranchReportJournalRelativeLayout.startAnimation(mShowAnimation);
			}
			break;
		case R.id.group_report_relativelayout:
			destIntent = new Intent(this,ReportListActivity.class);
			destIntent.putExtra("REPORT_TYPE",Constant.GROUP_REPORT);
			startActivity(destIntent);
			break;
		case R.id.my_branch_total_relativelayout:
			destIntent = new Intent(this,BranchTotalReportActivity.class);
			startActivity(destIntent);
			break;
		case R.id.my_branch_report_analysis_relativelayout:
			destIntent = new Intent(this,BranchStatisticsMainActivity.class);
			startActivity(destIntent);
			break;
		case R.id.my_branch_journal_relativelayout:
			destIntent = new Intent(this,BranchJournalReportActivity.class);
			startActivity(destIntent);
			break;
		}
	}
}
