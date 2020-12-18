package cn.com.antika.fragment;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CustomerBenefit;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.business.CustomerBenefitDetailActivity;
import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;

/**
 *
 */
@SuppressLint("ResourceType")
public class UsedBenefitsFragment extends Fragment{
	private UsedBenefitsFragmentHandler mHandler = new UsedBenefitsFragmentHandler(this);
	private PackageUpdateUtil packageUpdateUtil;
	private UserInfoApplication userinfoApplication;
	private List<CustomerBenefit> customerBenefitsList;
	private LinearLayout  customerBenefitListLinearLayout;
	private LayoutInflater  layoutInflater;
	private Thread requestWebServiceThread;
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreateView(inflater, container, savedInstanceState);
		View benefitsView = inflater.inflate(R.xml.customer_benefits_fragment_layout,container,false);
		customerBenefitListLinearLayout=(LinearLayout)benefitsView.findViewById(R.id.customer_benefits_list_ll);
		userinfoApplication=(UserInfoApplication)getActivity().getApplication();
		return benefitsView;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
		CustomerBenefitOperation cbo=new CustomerBenefitOperation();
		customerBenefitsList=cbo.getCustomerBenefitListData(3,requestWebServiceThread, mHandler, userinfoApplication);
	}

	private static class UsedBenefitsFragmentHandler extends Handler {
		private final UsedBenefitsFragment usedBenefitsFragment;

		private UsedBenefitsFragmentHandler(UsedBenefitsFragment activity) {
			WeakReference<UsedBenefitsFragment> weakReference = new WeakReference<UsedBenefitsFragment>(activity);
			usedBenefitsFragment = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
				case 0:
					DialogUtil.createShortDialog(usedBenefitsFragment.getActivity(), (String) msg.obj);
					break;
				case 1:
					usedBenefitsFragment.initCustomerBenefitListView();
					break;
				case 2:
					DialogUtil.createShortDialog(usedBenefitsFragment.getActivity(), "您的网络貌似不给力，请重试");
					break;
				case Constant.LOGIN_ERROR:
					DialogUtil.createShortDialog(usedBenefitsFragment.getActivity(), usedBenefitsFragment.getString(R.string.login_error_message));
					UserInfoApplication.getInstance().exitForLogin(usedBenefitsFragment.getActivity());
					break;
				case Constant.APP_VERSION_ERROR:
					String downloadFileUrl = Constant.SERVER_URL + usedBenefitsFragment.getString(R.string.download_apk_address);
					FileCache fileCache = new FileCache(usedBenefitsFragment.getActivity());
					usedBenefitsFragment.packageUpdateUtil = new PackageUpdateUtil(usedBenefitsFragment.getActivity(), usedBenefitsFragment.mHandler, fileCache, downloadFileUrl, false, usedBenefitsFragment.userinfoApplication);
					usedBenefitsFragment.packageUpdateUtil.getPackageVersionInfo();
					ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
					serverPackageVersion.setPackageVersion((String) msg.obj);
					usedBenefitsFragment.packageUpdateUtil.mustUpdate(serverPackageVersion);
					break;
				case 5:
					((DownloadInfo) msg.obj).getUpdateDialog().cancel();
					String filename = "cn.com.antika.business.apk";
					File file = usedBenefitsFragment.getActivity().getFileStreamPath(filename);
					file.getName();
					usedBenefitsFragment.packageUpdateUtil.showInstallDialog();
					break;
				case -5:
					((DownloadInfo) msg.obj).getUpdateDialog().cancel();
					break;
				case 7:
					int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
					((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
					break;
				default:
					break;
			}
		}
	}

	private void initCustomerBenefitListView(){
		if(customerBenefitsList.size()>0){
			customerBenefitListLinearLayout.removeAllViews();
			for(int i=0;i<customerBenefitsList.size();i++){
				layoutInflater=LayoutInflater.from(getActivity());
				final CustomerBenefit customerBenefit=customerBenefitsList.get(i);
				View customerBenefitListItem=layoutInflater.inflate(R.xml.customer_benefit_list_item,null);
				TableLayout   benefitTablelayout=(TableLayout)customerBenefitListItem.findViewById(R.id.benefit_tablelayout);
				RelativeLayout benefitRelativeLayout=(RelativeLayout) customerBenefitListItem.findViewById(R.id.benefit_relativelayout);
				TextView benefitNameText = (TextView) customerBenefitListItem.findViewById(R.id.benefit_name);
				TextView benefitRuleText = (TextView) customerBenefitListItem.findViewById(R.id.benefit_rule);
				benefitNameText.setText(customerBenefit.getBenefitName());
				benefitRuleText.setText(customerBenefit.getBenefitRule());
				benefitRelativeLayout.setBackgroundResource(R.drawable.ecard_background_gray);
				benefitTablelayout.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent=new Intent();
						destIntent.setClass(getActivity(),CustomerBenefitDetailActivity.class);
						destIntent.putExtra("benefitID",customerBenefit.getBenefitID());
						getActivity().startActivity(destIntent);
					}
				});
				customerBenefitListLinearLayout.addView(customerBenefitListItem);
			}
		}
	}
}
