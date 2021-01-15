package com.GlamourPromise.Beauty.fragment;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Business.CustomerBenefitDetailActivity;
import com.GlamourPromise.Beauty.Business.R;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CustomerBenefit;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.List;

/**
 *
 */
@SuppressLint("ResourceType")
public class UnUsedBenefitsFragment extends Fragment {
    private UnUsedBenefitsFragmentHandler mHandler = new UnUsedBenefitsFragmentHandler(this);
    private PackageUpdateUtil packageUpdateUtil;
    private UserInfoApplication userinfoApplication;
    private List<CustomerBenefit> customerBenefitsList;
    private LinearLayout customerBenefitListLinearLayout;
    private LayoutInflater layoutInflater;
    private Thread requestWebServiceThread;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreateView(inflater, container, savedInstanceState);
        View benefitsView = inflater.inflate(R.xml.customer_benefits_fragment_layout, container, false);
        customerBenefitListLinearLayout = (LinearLayout) benefitsView.findViewById(R.id.customer_benefits_list_ll);
        userinfoApplication = (UserInfoApplication) getActivity().getApplication();
        return benefitsView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
        CustomerBenefitOperation cbo = new CustomerBenefitOperation();
        customerBenefitsList = cbo.getCustomerBenefitListData(1, requestWebServiceThread, mHandler, userinfoApplication);
    }

    private static class UnUsedBenefitsFragmentHandler extends Handler {
        private final UnUsedBenefitsFragment unUsedBenefitsFragment;

        private UnUsedBenefitsFragmentHandler(UnUsedBenefitsFragment activity) {
            WeakReference<UnUsedBenefitsFragment> weakReference = new WeakReference<UnUsedBenefitsFragment>(activity);
            unUsedBenefitsFragment = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            FragmentActivity fragmentActivity = unUsedBenefitsFragment.getActivity();
            if (fragmentActivity == null) {
                return;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(fragmentActivity, (String) msg.obj);
                    break;
                case 1:
                    unUsedBenefitsFragment.initCustomerBenefitListView();
                    break;
                case 2:
                    DialogUtil.createShortDialog(fragmentActivity, "您的网络貌似不给力，请重试");
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(fragmentActivity, unUsedBenefitsFragment.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(fragmentActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + unUsedBenefitsFragment.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(fragmentActivity);
                    unUsedBenefitsFragment.packageUpdateUtil = new PackageUpdateUtil(fragmentActivity, unUsedBenefitsFragment.mHandler, fileCache, downloadFileUrl, false, unUsedBenefitsFragment.userinfoApplication);
                    unUsedBenefitsFragment.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    unUsedBenefitsFragment.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "com.glamourpromise.beauty.business.apk";
                    File file = fragmentActivity.getFileStreamPath(filename);
                    file.getName();
                    unUsedBenefitsFragment.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                case 99:
                    DialogUtil.createShortDialog(fragmentActivity, "服务器异常，请重试");
                    break;
                default:
                    break;
            }
        }
    }

    private void initCustomerBenefitListView() {
        if (customerBenefitsList.size() > 0) {
            customerBenefitListLinearLayout.removeAllViews();
            for (int i = 0; i < customerBenefitsList.size(); i++) {
                layoutInflater = LayoutInflater.from(getActivity());
                final CustomerBenefit customerBenefit = customerBenefitsList.get(i);
                View customerBenefitListItem = layoutInflater.inflate(R.xml.customer_benefit_list_item, null);
                TableLayout benefitTablelayout = (TableLayout) customerBenefitListItem.findViewById(R.id.benefit_tablelayout);
                RelativeLayout benefitRelativeLayout = (RelativeLayout) customerBenefitListItem.findViewById(R.id.benefit_relativelayout);
                TextView benefitNameText = (TextView) customerBenefitListItem.findViewById(R.id.benefit_name);
                TextView benefitRuleText = (TextView) customerBenefitListItem.findViewById(R.id.benefit_rule);
                benefitNameText.setText(customerBenefit.getBenefitName());
                benefitRuleText.setText(customerBenefit.getBenefitRule());
                benefitRelativeLayout.setBackgroundResource(R.drawable.ecard_background_dark_red);
                benefitTablelayout.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        Intent destIntent = new Intent();
                        destIntent.setClass(getActivity(), CustomerBenefitDetailActivity.class);
                        destIntent.putExtra("benefitID", customerBenefit.getBenefitID());
                        getActivity().startActivity(destIntent);
                    }
                });
                customerBenefitListLinearLayout.addView(customerBenefitListItem);
            }
        }
    }
}
