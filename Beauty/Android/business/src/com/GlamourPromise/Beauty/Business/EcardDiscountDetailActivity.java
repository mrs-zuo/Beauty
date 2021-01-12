package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DiscountDetail;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/*
 * e卡打折详情
 * */
@SuppressLint("ResourceType")
public class EcardDiscountDetailActivity extends BaseActivity {
    private EcardDiscountDetailActivityHandler mHandler = new EcardDiscountDetailActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private LayoutInflater layoutInflater;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_ecard_discount_detail);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class EcardDiscountDetailActivityHandler extends Handler {
        private final EcardDiscountDetailActivity ecardDiscountDetailActivity;

        private EcardDiscountDetailActivityHandler(EcardDiscountDetailActivity activity) {
            WeakReference<EcardDiscountDetailActivity> weakReference = new WeakReference<EcardDiscountDetailActivity>(activity);
            ecardDiscountDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (ecardDiscountDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (ecardDiscountDetailActivity.progressDialog != null) {
                ecardDiscountDetailActivity.progressDialog.dismiss();
                ecardDiscountDetailActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                List<DiscountDetail> discountDetailList = (List<DiscountDetail>) msg.obj;
                if (discountDetailList != null && discountDetailList.size() > 0) {
                    TableLayout discountDetailTableLayout = (TableLayout) ecardDiscountDetailActivity.findViewById(R.id.ecard_discount_tablelayout);
                    for (int i = 0; i < discountDetailList.size(); i++) {
                        DiscountDetail discountDetail = discountDetailList.get(i);
                        View discountDetailItemView = ecardDiscountDetailActivity.layoutInflater.inflate(R.xml.discount_detail_list_item, null);
                        TextView discountNameText = (TextView) discountDetailItemView.findViewById(R.id.discount_name_text);
                        TextView discountRateText = (TextView) discountDetailItemView.findViewById(R.id.discount_rate_text);
                        View discountDetaiDivideView = discountDetailItemView.findViewById(R.id.discount_detail_item_divide_view);
                        if (i == discountDetailList.size() - 1)
                            discountDetaiDivideView.setVisibility(View.GONE);
                        discountNameText.setText(discountDetail.getDiscountDetailName());
                        discountRateText.setText(NumberFormatUtil.currencyFormat(discountDetail.getDiscountRate()));
                        discountDetailTableLayout.addView(discountDetailItemView);
                    }
                }
            } else if (msg.what == 0)
                DialogUtil.createShortDialog(ecardDiscountDetailActivity,
                        "您的网络貌似不给力，请重试");
            else if (msg.what == 2)
                DialogUtil.createShortDialog(ecardDiscountDetailActivity,
                        (String) msg.obj);
            if (ecardDiscountDetailActivity.requestWebServiceThread != null) {
                ecardDiscountDetailActivity.requestWebServiceThread.interrupt();
                ecardDiscountDetailActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        String ecardLevelName = getIntent().getStringExtra("levelName");
        ((TextView) findViewById(R.id.discount_detail_level_name_text)).setText(ecardLevelName);
        layoutInflater = LayoutInflater.from(this);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebService();
    }

    protected void requestWebService() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getDiscountListForWebService";
                String endPoint = "level.asmx";
                JSONObject discountDetailParamJson = new JSONObject();
                try {
                    discountDetailParamJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                } catch (JSONException e2) {
                    // TODO Auto-generated catch block
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, discountDetailParamJson.toString(), userinfoApplication);
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
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        List<DiscountDetail> discountDetailList = new ArrayList<DiscountDetail>();
                        JSONArray discountDetailArray = null;
                        try {
                            discountDetailArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (discountDetailArray != null) {
                            for (int i = 0; i < discountDetailArray.length(); i++) {
                                JSONObject discountDetailJson = null;
                                try {
                                    discountDetailJson = (JSONObject) discountDetailArray
                                            .get(i);
                                } catch (JSONException e1) {
                                }
                                String discountName = "";
                                float discount = 0;
                                try {
                                    if (discountDetailJson.has("DiscountName")) {
                                        discountName = discountDetailJson.getString("DiscountName");
                                    }
                                    if (discountDetailJson.has("Discount")) {
                                        discount = Float.valueOf(discountDetailJson.getString("Discount"));
                                    }

                                } catch (JSONException e) {
                                }
                                DiscountDetail discountDetail = new DiscountDetail();
                                discountDetail.setDiscountDetailName(discountName);
                                discountDetail.setDiscountRate(String.valueOf(discount));
                                discountDetailList.add(discountDetail);
                            }
                        }
                        Message msg = new Message();
                        msg.what = 1;
                        msg.obj = discountDetailList;
                        mHandler.sendMessage(msg);
                    } else {
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
