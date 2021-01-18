package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BenefitPerson;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.RechargeDetail;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/*
 * 充值或者转出详情
 * */
@SuppressLint("ResourceType")
public class RechargeDetailActivity extends BaseActivity {
    private RechargeDetailActivityHandler mHandler = new RechargeDetailActivityHandler(this);
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private LayoutInflater layoutInflater;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_recharge_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        layoutInflater = LayoutInflater.from(this);
        initView();
    }

    private static class RechargeDetailActivityHandler extends Handler {
        private final RechargeDetailActivity rechargeDetailActivity;

        private RechargeDetailActivityHandler(RechargeDetailActivity activity) {
            WeakReference<RechargeDetailActivity> weakReference = new WeakReference<RechargeDetailActivity>(activity);
            rechargeDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (rechargeDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (rechargeDetailActivity.progressDialog != null) {
                rechargeDetailActivity.progressDialog.dismiss();
                rechargeDetailActivity.progressDialog = null;
            }
            if (rechargeDetailActivity.requestWebServiceThread != null) {
                rechargeDetailActivity.requestWebServiceThread.interrupt();
                rechargeDetailActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                RechargeDetail rechargeDetail = (RechargeDetail) msg.obj;
                TableLayout rechargeDetailTablelayout = (TableLayout) rechargeDetailActivity.findViewById(R.id.recharge_detail_tablelayout);
                ((TextView) rechargeDetailActivity.findViewById(R.id.recharge_detail_date_text)).setText(rechargeDetail.getRechargeDate());
                ((TextView) rechargeDetailActivity.findViewById(R.id.recharge_detail_operator_text)).setText(rechargeDetail.getRechargeOperator());
                ((TextView) rechargeDetailActivity.findViewById(R.id.recharge_detail_amount_text)).setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(rechargeDetail.getRechargeAmont()));
                ((TextView) rechargeDetailActivity.findViewById(R.id.recharge_detail_type_text)).setText(rechargeDetail.getRechargeModel());
                ((TextView) rechargeDetailActivity.findViewById(R.id.recharge_detail_balance_text)).setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(rechargeDetail.getRechargeBalance()));
                List<BenefitPerson> rechargeProfit = rechargeDetail.getRechargeProfit();
                if (rechargeProfit == null || rechargeProfit.size() == 0)
                    ((TextView) rechargeDetailActivity.findViewById(R.id.recharge_detail_benefit_person_text)).setText("无");
                else {
                    for (int j = 0; j < rechargeProfit.size(); j++) {
                        BenefitPerson bp = rechargeProfit.get(j);
                        View benefitPersonItemView = rechargeDetailActivity.layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
                        if (j != 0) {
                            benefitPersonItemView.findViewById(R.id.benefit_person_before_divide_view).setVisibility(View.GONE);
                        }
                        TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                        benefitPersonNameText.setText(bp.getAccountName());
                        TextView benefitPersonPercentText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                        benefitPersonPercentText.setText(bp.getProfitPct());
                        rechargeDetailTablelayout.addView(benefitPersonItemView, rechargeDetailTablelayout.getChildCount() - 3);
                    }
                }
                String rechargeDetailRemark = rechargeDetail.getRechargeRemark();
                if (rechargeDetailRemark == null || ("").equals(rechargeDetailRemark)) {
                    rechargeDetailActivity.findViewById(R.id.recharge_detail_remark_title_divide_view).setVisibility(View.GONE);
                    rechargeDetailActivity.findViewById(R.id.recharge_detail_remark_title_relativelayout).setVisibility(View.GONE);
                    rechargeDetailActivity.findViewById(R.id.recharge_detail_remark_divide_view).setVisibility(View.GONE);
                    rechargeDetailActivity.findViewById(R.id.recharge_detail_remark_relativelayout).setVisibility(View.GONE);
                } else {
                    ((TextView) rechargeDetailActivity.findViewById(R.id.recharge_detail_remark_text)).setText(rechargeDetailRemark);
                }
            } else if (msg.what == 0) {
                DialogUtil.createMakeSureDialog(rechargeDetailActivity, "提示信息", "您的网络貌似不给力，请检查网络设置！");
            } else if (msg.what == 2) {
                String message = (String) msg.obj;
                DialogUtil.createMakeSureDialog(rechargeDetailActivity, "提示信息", message);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(rechargeDetailActivity, rechargeDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(rechargeDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + rechargeDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(rechargeDetailActivity);
                rechargeDetailActivity.packageUpdateUtil = new PackageUpdateUtil(rechargeDetailActivity, rechargeDetailActivity.mHandler, fileCache, downloadFileUrl, false, UserInfoApplication.getInstance());
                rechargeDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                rechargeDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = rechargeDetailActivity.getFileStreamPath(filename);
                file.getName();
                rechargeDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    private void initView() {
        Intent intent = getIntent();
        final int balanceID = intent.getIntExtra("balanceID", 0);
        int rechargeMode = intent.getIntExtra("rechargeMode", 0);
        //转出
        if (rechargeMode == 5) {
            ((TextView) findViewById(R.id.recharge_detail_title_text)).setText("转出详情");
            ((TextView) findViewById(R.id.recharge_detail_date_title_text)).setText("转出时间");
            ((TextView) findViewById(R.id.recharge_detail_amount_title_text)).setText("转出金额");
            findViewById(R.id.recharge_detail_type_before_view).setVisibility(View.GONE);
            ((RelativeLayout) findViewById(R.id.recharge_detail_type_relativelayout)).setVisibility(View.GONE);
        }
        //退款
        else if (rechargeMode == 6) {
            ((TextView) findViewById(R.id.recharge_detail_title_text)).setText("退款详情");
            ((TextView) findViewById(R.id.recharge_detail_date_title_text)).setText("退款时间");
            ((TextView) findViewById(R.id.recharge_detail_amount_title_text)).setText("退款金额");
            findViewById(R.id.recharge_detail_type_before_view).setVisibility(View.GONE);
            ((RelativeLayout) findViewById(R.id.recharge_detail_type_relativelayout)).setVisibility(View.GONE);
        }
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "getBalanceDetail";
                String endPoint = "ecard";
                JSONObject paymentRecordDetailParamJson = new JSONObject();
                try {
                    paymentRecordDetailParamJson.put("ID", balanceID);
                } catch (JSONException e) {
                    // TODO Auto-generated catch block
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, paymentRecordDetailParamJson.toString(), UserInfoApplication.getInstance());
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e2) {
                    // TODO Auto-generated catch block
                }
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(0);
                else {
                    String code = "0";
                    String message = "";
                    RechargeDetail rechargeDetail = null;
                    try {
                        code = resultJson.getString("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        code = "0";
                    }
                    if (Integer.parseInt(code) == 1) {
                        JSONObject rechargeDetailJson = null;
                        try {
                            rechargeDetailJson = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                        }
                        if (rechargeDetailJson != null) {
                            try {
                                rechargeDetail = new RechargeDetail();
                                String rechargeDate = "";
                                String rechargeOperator = "";
                                String rechargeAmont = "";
                                String rechargeModel = "";
                                String rechargeBalance = "";//e卡余额
                                String rechargeRemark = "";//充值备注
                                if (rechargeDetailJson.has("CreateTime"))
                                    rechargeDate = rechargeDetailJson.getString("CreateTime");
                                if (rechargeDetailJson.has("Operator"))
                                    rechargeOperator = rechargeDetailJson.getString("Operator");
                                if (rechargeDetailJson.has("Mode"))
                                    rechargeModel = rechargeDetailJson.getString("Mode");
                                if (rechargeDetailJson.has("Amount"))
                                    rechargeAmont = String.valueOf(Double.valueOf(rechargeDetailJson.getString("Amount")));
                                if (rechargeDetailJson.has("Balance"))
                                    rechargeBalance = String.valueOf(Double.valueOf(rechargeDetailJson.getString("Balance")));
                                List<BenefitPerson> benefitPersonList = new ArrayList<BenefitPerson>();
                                if (rechargeDetailJson.has("ProfitList") && !rechargeDetailJson.isNull("ProfitList")) {
                                    JSONArray profitArray = rechargeDetailJson.getJSONArray("ProfitList");
                                    for (int j = 0; j < profitArray.length(); j++) {
                                        JSONObject benefitPersonJson = profitArray.getJSONObject(j);
                                        BenefitPerson bp = new BenefitPerson();
                                        bp.setAccountID(benefitPersonJson.getInt("AccountID"));
                                        bp.setAccountName(benefitPersonJson.getString("AccountName"));
                                        bp.setProfitPct(NumberFormatUtil.currencyFormat(String.valueOf(benefitPersonJson.getDouble("ProfitPct") * 100)));
                                        benefitPersonList.add(bp);
                                    }
                                }
                                if (rechargeDetailJson.has("Remark"))
                                    rechargeRemark = rechargeDetailJson.getString("Remark");
                                rechargeDetail.setRechargeDate(rechargeDate);
                                rechargeDetail.setRechargeAmont(rechargeAmont);
                                rechargeDetail.setRechargeBalance(rechargeBalance);
                                rechargeDetail.setRechargeOperator(rechargeOperator);
                                rechargeDetail.setRechargeRemark(rechargeRemark);
                                rechargeDetail.setRechargeModel(rechargeModel);
                                rechargeDetail.setRechargeProfit(benefitPersonList);
                            } catch (NumberFormatException e) {
                                // TODO Auto-generated catch block
                            } catch (JSONException e) {
                            }

                        }
                        Message msg = new Message();
                        msg.what = 1;
                        msg.obj = rechargeDetail;
                        mHandler.sendMessage(msg);
                    } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(Integer.parseInt(code));
                    else {
                        Message msg = new Message();
                        msg.what = 2;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }

                }
            }
        };
        requestWebServiceThread.start();

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
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
