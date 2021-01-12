package com.GlamourPromise.Beauty.Business;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.Opportunity;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Timer;

public class EditOpportunityProgressActivity extends BaseActivity implements
        OnClickListener {
    private EditOpportunityProgressActivityHandler mHandler = new EditOpportunityProgressActivityHandler(this);
    private TextView opportunityCreateTime;
    private TextView opportunityProgressName;
    private TextView opportunityDetailProductName;
    private TextView opportunityDetailQuantity;
    private TextView opportunityDetailTotalPrice;
    private EditText opportunityDetailTotalSalePrice;
    private ImageButton editOpportunityProgressBtn;
    private ImageButton plusQuantityBtn;
    private ImageButton reduceQuantityBtn;
    private EditText editProgressDescription;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private int progressID = -1;
    private Opportunity opportunity;
    private RelativeLayout opportunityTotalSalePriceRelativeLayout;
    private RelativeLayout opportunityTotalPriceRelativeLayout;
    private View tableRowView;
    private UserInfoApplication userinfoApplication;
    private int maxProgress;
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_edit_opportunity_progress);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class EditOpportunityProgressActivityHandler extends Handler {
        private final EditOpportunityProgressActivity editOpportunityProgressActivity;

        private EditOpportunityProgressActivityHandler(EditOpportunityProgressActivity activity) {
            WeakReference<EditOpportunityProgressActivity> weakReference = new WeakReference<EditOpportunityProgressActivity>(activity);
            editOpportunityProgressActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (editOpportunityProgressActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editOpportunityProgressActivity.progressDialog != null) {
                editOpportunityProgressActivity.progressDialog.dismiss();
                editOpportunityProgressActivity.progressDialog = null;
            }
            if (editOpportunityProgressActivity.requestWebServiceThread != null) {
                editOpportunityProgressActivity.requestWebServiceThread.interrupt();
                editOpportunityProgressActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(editOpportunityProgressActivity, "提示信息", "销售进度编辑成功！");
                alertDialog.show();
                Intent intent = new Intent(editOpportunityProgressActivity, OpportunityDetailMainActivity.class);
                intent.putExtra("current_tab", 1);
                intent.putExtra("opportunityID", editOpportunityProgressActivity.opportunity.getOpportunityID());
                intent.putExtra("productType", editOpportunityProgressActivity.opportunity.getProductType());
                intent.putExtra("opportunityCustomerName", editOpportunityProgressActivity.opportunity.getCustomerName());
                intent.putExtra("opportunityResponsiblePersonName", editOpportunityProgressActivity.opportunity.getResponsiblePersonName());
                Bundle bundle = new Bundle();
                bundle.putSerializable("opportunity", editOpportunityProgressActivity.opportunity);
                intent.putExtras(bundle);
                editOpportunityProgressActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editOpportunityProgressActivity.dialogTimer, editOpportunityProgressActivity, intent);
                editOpportunityProgressActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 0) {
                DialogUtil.createShortDialog(editOpportunityProgressActivity, "销售进度编辑失败！");
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(editOpportunityProgressActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editOpportunityProgressActivity, editOpportunityProgressActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editOpportunityProgressActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editOpportunityProgressActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editOpportunityProgressActivity);
                editOpportunityProgressActivity.packageUpdateUtil = new PackageUpdateUtil(editOpportunityProgressActivity, editOpportunityProgressActivity.mHandler, fileCache, downloadFileUrl, false, editOpportunityProgressActivity.userinfoApplication);
                editOpportunityProgressActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                editOpportunityProgressActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = editOpportunityProgressActivity.getFileStreamPath(filename);
                file.getName();
                editOpportunityProgressActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        opportunityCreateTime = (TextView) findViewById(R.id.opportunity_progress_create_time);
        opportunityProgressName = (TextView) findViewById(R.id.opportunity_progress_name);
        opportunityDetailProductName = (TextView) findViewById(R.id.opportunity_detail_product_name);
        opportunityDetailQuantity = (TextView) findViewById(R.id.opportunity_detail_quantity);
        opportunityDetailTotalPrice = (TextView) findViewById(R.id.opportunity_detail_total_price);
        ((TextView) findViewById(R.id.opportunity_detail_total_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
        ((TextView) findViewById(R.id.opportunity_detail_total_sale_price_currency)).setText(userinfoApplication.getAccountInfo().getCurrency());
        editProgressDescription = (EditText) findViewById(R.id.edit_progress_description);
        editOpportunityProgressBtn = (ImageButton) findViewById(R.id.edit_opportunity__progress_btn);
        plusQuantityBtn = (ImageButton) findViewById(R.id.plus_quantity_btn);
        reduceQuantityBtn = (ImageButton) findViewById(R.id.reduce_quantity_btn);
        opportunityDetailTotalSalePrice = (EditText) findViewById(R.id.opportunity_detail_total_sale_price);
        opportunityTotalPriceRelativeLayout = (RelativeLayout) findViewById(R.id.total_price_relativelayout);
        opportunityTotalSalePriceRelativeLayout = (RelativeLayout) findViewById(R.id.opportunity_detail_total_sale_price_relativelayout);
        tableRowView = findViewById(R.id.tablerow_view);
        opportunityTotalPriceRelativeLayout.setOnClickListener(this);
        editOpportunityProgressBtn.setOnClickListener(this);
        plusQuantityBtn.setOnClickListener(this);
        reduceQuantityBtn.setOnClickListener(this);
        opportunity = (Opportunity) getIntent().getSerializableExtra("opportunity");
        if (Float.valueOf(opportunity.getTotalSalePrice()) == 0
                || opportunity.getTotalSalePrice().equals(
                opportunity.getTotalPrice())) {
            tableRowView.setVisibility(View.GONE);
            opportunityTotalSalePriceRelativeLayout.setVisibility(View.GONE);
        }
        progressID = (getIntent().getIntExtra("progressID", -2)) + 1;
        maxProgress = getIntent().getIntExtra("maxProgress", 0);
        String progressName = getIntent().getStringExtra("progressName");
        opportunityCreateTime.setText(new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date()));
        opportunityProgressName.setText(progressName);
        opportunityDetailProductName.setText(opportunity.getProductName());
        opportunityDetailQuantity.setText(String.valueOf(opportunity.getQuantity()));
        String formateTotalPrice = NumberFormatUtil.currencyFormat(opportunity.getTotalPrice());
        opportunityDetailTotalPrice.setText(formateTotalPrice);
        if (opportunity.getTotalPrice() != opportunity.getTotalSalePrice()) {
            String formateTotalSalePrice = NumberFormatUtil.currencyFormat(opportunity.getTotalSalePrice());
            opportunityDetailTotalSalePrice.setText(formateTotalSalePrice);
        } else
            opportunityDetailTotalSalePrice.setText(String.valueOf(0));
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.edit_opportunity__progress_btn:
                if (maxProgress != 0 && maxProgress == progressID) {
                    // 如果是该账户没有编辑订单的权限，或者需求失效时，则没有是否转成订单的提示
                    if (userinfoApplication.getAccountInfo().getAuthMyOrderWrite() == 0 || userinfoApplication.getAccountInfo().getBranchId() != opportunity.getBranchID() || !opportunity.isAvailable()) {
                        progressDialog = new ProgressDialog(EditOpportunityProgressActivity.this, R.style.CustomerProgressDialog);
                        progressDialog.setMessage(getString(R.string.please_wait));
                        progressDialog.show();
                        requestWebServiceThread = new Thread() {
                            @Override
                            public void run() {
                                String methodName = "addProgress";
                                String endPoint = "opportunity";
                                JSONObject addProgress = new JSONObject();
                                try {
                                    addProgress.put("Description", editProgressDescription.getText().toString());
                                    addProgress.put("Quantity", opportunityDetailQuantity.getText().toString());
                                    if (opportunityDetailTotalSalePrice != null && !(("").equals(opportunityDetailTotalSalePrice.getText().toString())))
                                        addProgress.put("TotalSalePrice", opportunityDetailTotalSalePrice.getText().toString());
                                    else
                                        addProgress.put("TotalSalePrice", -1);
                                    addProgress.put("ProductCode", opportunity.getProductCode());
                                    addProgress.put("ProductType", opportunity.getProductType());
                                    addProgress.put("OpportunityID", opportunity.getOpportunityID());
                                    addProgress.put("CustomerID", opportunity.getCustomerID());
                                    addProgress.put("Progress", String.valueOf(progressID));
                                } catch (JSONException e) {
                                }
                                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addProgress.toString(), userinfoApplication);
                                if (serverRequestResult == null || ("").equals(serverRequestResult))
                                    mHandler.sendEmptyMessage(2);
                                else {
                                    JSONObject resultJson = null;
                                    try {
                                        resultJson = new JSONObject(serverRequestResult);
                                    } catch (JSONException e2) {
                                    }
                                    int code = 0;
                                    String message = "";
                                    try {
                                        code = resultJson.getInt("Code");
                                        message = resultJson.getString("Message");
                                    } catch (JSONException e) {
                                        code = 0;
                                    }
                                    if (code == 1) {
                                        mHandler.sendEmptyMessage(1);
                                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                        mHandler.sendEmptyMessage(code);
                                    else {
                                        mHandler.sendEmptyMessage(0);
                                    }
                                }
                            }
                        };
                        requestWebServiceThread.start();
                    }
                    // 如果是分店账号，则有是否转成订单的提示
                    else if (userinfoApplication.getAccountInfo().getBranchId() != 0) {
                        Dialog dialog = new AlertDialog.Builder(this,
                                R.style.CustomerAlertDialog)
                                .setTitle(getString(R.string.delete_dialog_title))
                                .setMessage(R.string.is_opportunity_dispatch_order)
                                .setPositiveButton(getString(R.string.yes),
                                        new DialogInterface.OnClickListener() {

                                            @Override
                                            public void onClick(
                                                    DialogInterface dialog,
                                                    int which) {
                                                dialog.dismiss();
                                                Intent destIntent = new Intent(
                                                        EditOpportunityProgressActivity.this,
                                                        PrepareOrderActivity.class);
                                                ArrayList<OrderProduct> orderProductList = new ArrayList<OrderProduct>();
                                                OrderProduct orderProduct = new OrderProduct();
                                                orderProduct
                                                        .setProductCode(opportunity
                                                                .getProductCode());
                                                orderProduct
                                                        .setProductID(opportunity
                                                                .getProductID());
                                                orderProduct
                                                        .setProductName(opportunity
                                                                .getProductName());
                                                orderProduct
                                                        .setProductType(opportunity
                                                                .getProductType());
                                                orderProduct.setQuantity(Integer
                                                        .parseInt(opportunityDetailQuantity
                                                                .getText()
                                                                .toString()));
                                                orderProduct
                                                        .setCustomerID(opportunity
                                                                .getCustomerID());
                                                orderProduct
                                                        .setOpportunityID(opportunity
                                                                .getOpportunityID());
                                                orderProduct
                                                        .setTotalPrice(opportunityDetailTotalPrice.getText().toString());
                                                orderProduct.setTotalSalePrice(opportunityDetailTotalSalePrice.getText().toString());
                                                orderProduct.setUnitPrice(String.valueOf(Double
                                                        .valueOf(opportunityDetailTotalPrice
                                                                .getText()
                                                                .toString())
                                                        / orderProduct
                                                        .getQuantity()));
                                                orderProduct
                                                        .setCustomerName(opportunity
                                                                .getCustomerName());
                                                orderProduct
                                                        .setResponsiblePersonID(opportunity
                                                                .getResponsiblePersonID());
                                                orderProduct.setResponsiblePersonName(opportunity.getResponsiblePersonName());
                                                orderProduct.setSalesID(0);
                                                orderProduct.setSalesName("");
                                                orderProduct.setPast(false);//是否老订单转入
                                                //如果是服务订单 传递服务有效期
                                                if (opportunity.getProductType() == Constant.SERVICE_TYPE)
                                                    orderProduct.setServiceOrderExpirationDate(opportunity.getExpirationDate());
                                                orderProductList.add(orderProduct);
                                                Bundle bundle = new Bundle();
                                                bundle.putSerializable("ORDER_LIST", orderProductList);
                                                destIntent.putExtra("FROM_SOURCE", "OPPORTUNITY");
                                                destIntent.putExtras(bundle);
                                                startActivity(destIntent);
                                            }
                                        })
                                .setNegativeButton(getString(R.string.no),
                                        new DialogInterface.OnClickListener() {

                                            @Override
                                            public void onClick(
                                                    DialogInterface dialog,
                                                    int which) {
                                                // TODO Auto-generated method stub
                                                dialog.dismiss();
                                                dialog = null;
                                                progressDialog = new ProgressDialog(EditOpportunityProgressActivity.this, R.style.CustomerProgressDialog);
                                                progressDialog.setMessage(getString(R.string.please_wait));
                                                progressDialog.show();
                                                requestWebServiceThread = new Thread() {
                                                    @Override
                                                    public void run() {
                                                        String methodName = "addProgress";
                                                        String endPoint = "opportunity";
                                                        JSONObject addProgress = new JSONObject();
                                                        try {
                                                            addProgress
                                                                    .put("Description",
                                                                            editProgressDescription
                                                                                    .getText()
                                                                                    .toString());
                                                            addProgress
                                                                    .put("Quantity",
                                                                            opportunityDetailQuantity
                                                                                    .getText()
                                                                                    .toString());
                                                            if (opportunityDetailTotalSalePrice != null
                                                                    && !(("")
                                                                    .equals(opportunityDetailTotalSalePrice
                                                                            .getText()
                                                                            .toString())))
                                                                addProgress
                                                                        .put("TotalSalePrice",
                                                                                opportunityDetailTotalSalePrice
                                                                                        .getText()
                                                                                        .toString());
                                                            else
                                                                addProgress
                                                                        .put("TotalSalePrice",
                                                                                -1);
                                                            addProgress
                                                                    .put("ProductCode",
                                                                            opportunity
                                                                                    .getProductCode());
                                                            addProgress
                                                                    .put("ProductType",
                                                                            opportunity
                                                                                    .getProductType());
                                                            addProgress
                                                                    .put("OpportunityID",
                                                                            opportunity
                                                                                    .getOpportunityID());
                                                            addProgress
                                                                    .put("CustomerID",
                                                                            opportunity
                                                                                    .getCustomerID());
                                                            addProgress
                                                                    .put("Progress",
                                                                            String.valueOf(progressID));

                                                        } catch (JSONException e) {
                                                        }
                                                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addProgress.toString(), userinfoApplication);
                                                        if (serverRequestResult == null
                                                                || ("").equals(serverRequestResult))
                                                            mHandler.sendEmptyMessage(2);
                                                        else {
                                                            JSONObject resultJson = null;
                                                            try {
                                                                resultJson = new JSONObject(
                                                                        serverRequestResult);
                                                            } catch (JSONException e2) {
                                                            }

                                                            int code = 0;
                                                            String message = "";
                                                            try {
                                                                code = resultJson.getInt("Code");
                                                                message = resultJson.getString("Message");
                                                            } catch (JSONException e) {
                                                                code = 0;
                                                            }
                                                            if (code == 1) {
                                                                mHandler.sendEmptyMessage(1);
                                                            } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                                                mHandler.sendEmptyMessage(code);
                                                            else {
                                                                mHandler.sendEmptyMessage(0);
                                                            }
                                                        }
                                                    }
                                                };
                                                requestWebServiceThread.start();
                                            }
                                        }).create();
                        dialog.show();
                        dialog.setCancelable(false);
                    }
                } else {
                    progressDialog = new ProgressDialog(EditOpportunityProgressActivity.this, R.style.CustomerProgressDialog);
                    progressDialog.setMessage(getString(R.string.please_wait));
                    progressDialog.show();
                    requestWebServiceThread = new Thread() {
                        @Override
                        public void run() {
                            String methodName = "addProgress";
                            String endPoint = "opportunity";
                            JSONObject addProgress = new JSONObject();
                            try {
                                addProgress.put("Description", editProgressDescription.getText().toString());
                                addProgress.put("Quantity", opportunityDetailQuantity.getText().toString());
                                if (opportunityDetailTotalSalePrice.getVisibility() == View.VISIBLE) {
                                    if (opportunityDetailTotalSalePrice != null && !(("").equals(opportunityDetailTotalSalePrice.getText().toString())))
                                        addProgress.put("TotalSalePrice", opportunityDetailTotalSalePrice.getText().toString());
                                } else
                                    addProgress.put("TotalSalePrice", -1);
                                addProgress.put("ProductCode", opportunity.getProductCode());
                                addProgress.put("ProductType", opportunity.getProductType());
                                addProgress.put("OpportunityID", opportunity.getOpportunityID());
                                addProgress.put("CustomerID", opportunity.getCustomerID());
                                addProgress.put("Progress", String.valueOf(progressID));
                            } catch (JSONException e) {
                            }
                            String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addProgress.toString(), userinfoApplication);
                            if (serverRequestResult == null
                                    || ("").equals(serverRequestResult))
                                mHandler.sendEmptyMessage(2);
                            else {
                                JSONObject resultJson = null;
                                try {
                                    resultJson = new JSONObject(serverRequestResult);
                                } catch (JSONException e2) {
                                    // TODO Auto-generated catch block
                                }

                                int code = 0;
                                String message = "";
                                try {
                                    code = resultJson.getInt("Code");
                                    message = resultJson.getString("Message");
                                } catch (JSONException e) {
                                    // TODO Auto-generated catch block
                                    code = 0;
                                }
                                if (code == 1) {
                                    mHandler.sendEmptyMessage(1);
                                } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                                    mHandler.sendEmptyMessage(code);
                                else {
                                    mHandler.sendEmptyMessage(0);
                                }
                            }
                        }
                    };
                    requestWebServiceThread.start();
                }
                break;
            case R.id.plus_quantity_btn:
                opportunityDetailQuantity
                        .setText(String.valueOf(Integer
                                .parseInt(opportunityDetailQuantity.getText()
                                        .toString()) + 1));
                double afterPlusTotalPrice = (Double.valueOf(opportunity
                        .getTotalPrice()) / opportunity.getQuantity())
                        * Integer.parseInt(opportunityDetailQuantity.getText()
                        .toString());
                opportunityDetailTotalPrice.setText(NumberFormatUtil
                        .currencyFormat(String.valueOf(afterPlusTotalPrice)));
                double afterPlusTotalSalePrice = (Double.valueOf(opportunity
                        .getTotalSalePrice()) / opportunity.getQuantity())
                        * Integer.parseInt(opportunityDetailQuantity.getText()
                        .toString());
                opportunityDetailTotalSalePrice.setText(NumberFormatUtil
                        .currencyFormat(String.valueOf(afterPlusTotalSalePrice)));

                break;
            case R.id.reduce_quantity_btn:
                if (Integer
                        .parseInt(opportunityDetailQuantity.getText().toString()) <= 1)
                    opportunityDetailQuantity.setText(String.valueOf(1));
                else {
                    opportunityDetailQuantity.setText(String.valueOf(Integer
                            .parseInt(opportunityDetailQuantity.getText()
                                    .toString()) - 1));
                    double afterReduceTotalPrice = (Double.valueOf(opportunity
                            .getTotalPrice()) / opportunity.getQuantity())
                            * Integer.parseInt(opportunityDetailQuantity.getText()
                            .toString());
                    opportunityDetailTotalPrice.setText(NumberFormatUtil
                            .currencyFormat(String.valueOf(afterReduceTotalPrice)));

                    double afterReduceTotalSalePrice = (Double.valueOf(opportunity
                            .getTotalSalePrice()) / opportunity.getQuantity())
                            * Integer.parseInt(opportunityDetailQuantity.getText()
                            .toString());
                    opportunityDetailTotalSalePrice.setText(String
                            .valueOf(NumberFormatUtil.currencyFormat(String
                                    .valueOf(afterReduceTotalSalePrice))));
                }
                break;
            case R.id.total_price_relativelayout:
                if (opportunityTotalSalePriceRelativeLayout.getVisibility() == View.VISIBLE && tableRowView.getVisibility() == view.VISIBLE) {
                    tableRowView.setVisibility(View.GONE);
                    opportunityTotalSalePriceRelativeLayout.setVisibility(View.GONE);
                } else {
                    tableRowView.setVisibility(View.VISIBLE);
                    opportunityTotalSalePriceRelativeLayout.setVisibility(View.VISIBLE);
                }
                break;
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
