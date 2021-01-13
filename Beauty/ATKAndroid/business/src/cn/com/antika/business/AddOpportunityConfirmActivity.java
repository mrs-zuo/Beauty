package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.StepTemplate;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 *选择商机和模本对应界面
 *
 * */
@SuppressLint("ResourceType")
public class AddOpportunityConfirmActivity extends BaseActivity implements OnClickListener {
    private AddOpportunityConfirmActivityHandler mHandler = new AddOpportunityConfirmActivityHandler(this);
    private LinearLayout opportunityStepTemplateListView;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private List<OrderProduct> orderProductList;
    private UserInfoApplication userinfoApplication;
    private LayoutInflater layoutInflater;
    private PackageUpdateUtil packageUpdateUtil;
    private List<StepTemplate> stepTemplateList;//商机模板集合
    private ImageButton addOpportunityConfirmSubmitBtn;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_add_opportunity_confirm);
        // 初始化数据信息
        initData();
    }

    private static class AddOpportunityConfirmActivityHandler extends Handler {
        private final AddOpportunityConfirmActivity addOpportunityConfirmActivity;

        private AddOpportunityConfirmActivityHandler(AddOpportunityConfirmActivity activity) {
            WeakReference<AddOpportunityConfirmActivity> weakReference = new WeakReference<AddOpportunityConfirmActivity>(activity);
            addOpportunityConfirmActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (addOpportunityConfirmActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (addOpportunityConfirmActivity.progressDialog != null) {
                addOpportunityConfirmActivity.progressDialog.dismiss();
                addOpportunityConfirmActivity.progressDialog = null;
            }
            // 建立需求成功
            if (msg.what == 1) {
                Intent intent = new Intent(addOpportunityConfirmActivity, OpportunityListActivity.class);
                if (addOpportunityConfirmActivity.orderProductList != null)
                    addOpportunityConfirmActivity.orderProductList.clear();
                if (addOpportunityConfirmActivity.userinfoApplication != null && addOpportunityConfirmActivity.userinfoApplication.getOrderInfo() != null) {
                    List<OrderProduct> orderProductList = addOpportunityConfirmActivity.userinfoApplication.getOrderInfo().getOrderProductList();
                    if (orderProductList != null)
                        orderProductList.clear();
                    addOpportunityConfirmActivity.userinfoApplication.setOrderInfo(null);
                }
                addOpportunityConfirmActivity.startActivity(intent);
            } else if (msg.what == 0) {
                String message = (String) msg.obj;
                DialogUtil.createMakeSureDialog(addOpportunityConfirmActivity, "提示信息", message);
            } else if (msg.what == -1)
                DialogUtil.createMakeSureDialog(addOpportunityConfirmActivity, "提示信息", "您的网络貌似不给力，请重试！");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(addOpportunityConfirmActivity, addOpportunityConfirmActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(addOpportunityConfirmActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + addOpportunityConfirmActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(addOpportunityConfirmActivity);
                addOpportunityConfirmActivity.packageUpdateUtil = new PackageUpdateUtil(addOpportunityConfirmActivity, addOpportunityConfirmActivity.mHandler, fileCache, downloadFileUrl, false, addOpportunityConfirmActivity.userinfoApplication);
                addOpportunityConfirmActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                addOpportunityConfirmActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = addOpportunityConfirmActivity.getFileStreamPath(filename);
                file.getName();
                addOpportunityConfirmActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (addOpportunityConfirmActivity.requestWebServiceThread != null) {
                addOpportunityConfirmActivity.requestWebServiceThread.interrupt();
                addOpportunityConfirmActivity.requestWebServiceThread = null;
            }
        }
    }

    //初始化界面和数据
    @SuppressWarnings("unchecked")
    private void initData() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        layoutInflater = LayoutInflater.from(this);
        opportunityStepTemplateListView = (LinearLayout) findViewById(R.id.add_opportunity_confirm_list);
        addOpportunityConfirmSubmitBtn = (ImageButton) findViewById(R.id.add_opportunity_confirm_make_sure_btn);
        addOpportunityConfirmSubmitBtn.setOnClickListener(this);
        Intent intent = getIntent();
        orderProductList = (List<OrderProduct>) intent.getSerializableExtra("orderProductList");
        stepTemplateList = (List<StepTemplate>) intent.getSerializableExtra("stepTemplateList");
        String[] stepTemplateArray = new String[stepTemplateList.size()];
        for (int i = 0; i < stepTemplateList.size(); i++) {
            stepTemplateArray[i] = stepTemplateList.get(i).getStepTemplateName();
        }
        for (int i = 0; i < orderProductList.size(); i++) {
            View addOpportunityConfirmListItemView = layoutInflater.inflate(R.xml.add_opportunity_confirm_list_item, null);
            OrderProduct op = orderProductList.get(i);
            TextView addOpportunityConfirmProductNameText = (TextView) addOpportunityConfirmListItemView.findViewById(R.id.add_opportunity_confirm_product_name);
            addOpportunityConfirmProductNameText.setText(op.getProductName());
            Spinner addOpportunityConfirmStepTemplateSpinner = (Spinner) addOpportunityConfirmListItemView.findViewById(R.id.add_opportunity_confirm_step_template_spinner);
            ArrayAdapter<String> stepTemplateArrayAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, stepTemplateArray);
            stepTemplateArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            addOpportunityConfirmStepTemplateSpinner.setAdapter(stepTemplateArrayAdapter);
            opportunityStepTemplateListView.addView(addOpportunityConfirmListItemView);
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        if (view.getId() == R.id.add_opportunity_confirm_make_sure_btn) {
            for (int i = 0; i < orderProductList.size(); i++) {
                int stepTemplatePos = ((Spinner) (opportunityStepTemplateListView.getChildAt(i).findViewById(R.id.add_opportunity_confirm_step_template_spinner))).getSelectedItemPosition();
                orderProductList.get(i).setStepTemplateId(stepTemplateList.get(stepTemplatePos).getStepTemplateID());
            }
            addOpportunity();
        }
    }

    private void addOpportunity() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        final JSONArray opportunityProductArray = new JSONArray();
        for (int i = 0; i < orderProductList.size(); i++) {
            JSONObject opportunityProduct = new JSONObject();
            OrderProduct orderProduct = orderProductList.get(i);
            try {
                opportunityProduct.put("ResponsiblePersonID", orderProduct.getResponsiblePersonID());
            } catch (JSONException e1) {
            }
            try {
                opportunityProduct.put("ProductType", orderProduct.getProductType());
                opportunityProduct.put("Quantity", orderProduct.getQuantity());
                opportunityProduct.put("ProductCode", orderProduct.getProductCode());
                opportunityProduct.put("TotalSalePrice", NumberFormatUtil.currencyFormat(orderProduct.getTotalSalePrice()));
                opportunityProduct.put("TotalOrigPrice", NumberFormatUtil.currencyFormat(String.valueOf(Float.valueOf(orderProduct.getUnitPrice()) * opportunityProduct.getInt("Quantity"))));
                opportunityProduct.put("TotalCalcPrice", NumberFormatUtil.currencyFormat(String.valueOf(Float.valueOf(orderProduct.getPromotionPrice()) * opportunityProduct.getInt("Quantity"))));
                opportunityProduct.put("StepID", orderProduct.getStepTemplateId());
            } catch (JSONException e) {
            }
            opportunityProductArray.put(opportunityProduct);
        }
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "addOpportunity";
                String endPoint = "Opportunity";
                JSONObject prepareOpportunityJson = new JSONObject();
                try {
                    prepareOpportunityJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    prepareOpportunityJson.put("ProductList", opportunityProductArray);
                } catch (JSONException e) {
                }
                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, prepareOpportunityJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e1) {
                    // TODO Auto-generated catch block
                }
                if (serverResultResult == null
                        || serverResultResult.equals(""))
                    mHandler.sendEmptyMessage(-1);
                else {
                    String code = "0";
                    String message = "";
                    try {
                        code = resultJson.getString("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        code = "0";
                    }
                    if (Integer.parseInt(code) == 1) {
                        mHandler.sendEmptyMessage(1);
                    } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(Integer.parseInt(code));
                    else if (Integer.parseInt(code) == -2) {
                        Message msg = new Message();
                        msg.what = 4;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    } else {
                        Message msg = new Message();
                        msg.what = 0;
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
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
    }
}
