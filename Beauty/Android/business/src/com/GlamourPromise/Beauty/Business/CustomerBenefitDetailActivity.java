package com.GlamourPromise.Beauty.Business;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Window;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.CustomerBenefit;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.fragment.CustomerBenefitOperation;
import com.GlamourPromise.Beauty.util.DateUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.List;

public class CustomerBenefitDetailActivity extends BaseActivity {
    private CustomerBenefitDetailActivityHandler mHandler = new CustomerBenefitDetailActivityHandler(this);
    private PackageUpdateUtil packageUpdateUtil;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private CustomerBenefit customerBenefit;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_benefit_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = (UserInfoApplication) getApplication();
        String benefitID = getIntent().getStringExtra("benefitID");
        CustomerBenefitOperation cbo = new CustomerBenefitOperation();
        customerBenefit = cbo.getCustomerBenefitDetailData(benefitID, requestWebServiceThread, mHandler, userinfoApplication);
    }

    private static class CustomerBenefitDetailActivityHandler extends Handler {
        private final CustomerBenefitDetailActivity customerBenefitDetailActivity;

        private CustomerBenefitDetailActivityHandler(CustomerBenefitDetailActivity activity) {
            WeakReference<CustomerBenefitDetailActivity> weakReference = new WeakReference<CustomerBenefitDetailActivity>(activity);
            customerBenefitDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (customerBenefitDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 1) {
                ((TextView) customerBenefitDetailActivity.findViewById(R.id.customer_benefit_detail_name_text)).setText(customerBenefitDetailActivity.customerBenefit.getBenefitName());
                ((TextView) customerBenefitDetailActivity.findViewById(R.id.customer_benefit_detail_date_text)).setText(DateUtil.getFormateDateByString(customerBenefitDetailActivity.customerBenefit.getGrantDate()) + "\t至\t" + DateUtil.getFormateDateByString(customerBenefitDetailActivity.customerBenefit.getValidDate()));
                ((TextView) customerBenefitDetailActivity.findViewById(R.id.customer_benefit_detail_rule_content_text)).setText(customerBenefitDetailActivity.customerBenefit.getBenefitRule());
                ((TextView) customerBenefitDetailActivity.findViewById(R.id.customer_benefit_detail_description_content_text)).setText(customerBenefitDetailActivity.customerBenefit.getBenefitDescription());
                List<BranchInfo> branchList = customerBenefitDetailActivity.customerBenefit.getBranchList();
                StringBuffer branchNameString = new StringBuffer();
                if (branchList != null && branchList.size() > 0) {
                    for (int i = 0; i < branchList.size(); i++) {
                        if (i == branchList.size() - 1) {
                            branchNameString.append(branchList.get(i).getName());
                        } else {
                            branchNameString.append(branchList.get(i).getName() + "\r\n");
                        }
                    }
                }
                ((TextView) customerBenefitDetailActivity.findViewById(R.id.customer_benefit_detail_branch_content_text)).setText(branchNameString.toString());
            } else if (msg.what == 2) {
                DialogUtil.createShortDialog(customerBenefitDetailActivity, "您的网络貌似不给力，请重试");
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerBenefitDetailActivity, customerBenefitDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerBenefitDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerBenefitDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerBenefitDetailActivity);
                customerBenefitDetailActivity.packageUpdateUtil = new PackageUpdateUtil(customerBenefitDetailActivity, customerBenefitDetailActivity.mHandler, fileCache, downloadFileUrl, false, customerBenefitDetailActivity.userinfoApplication);
                customerBenefitDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerBenefitDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = customerBenefitDetailActivity.getFileStreamPath(filename);
                file.getName();
                customerBenefitDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 99) {
                DialogUtil.createShortDialog(customerBenefitDetailActivity, "服务器异常，请重试");
            } else {
                DialogUtil.createShortDialog(customerBenefitDetailActivity, (String) msg.obj);
            }
            if (customerBenefitDetailActivity.requestWebServiceThread != null) {
                customerBenefitDetailActivity.requestWebServiceThread.interrupt();
                customerBenefitDetailActivity.requestWebServiceThread = null;
            }
        }
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
