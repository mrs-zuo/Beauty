package cn.com.antika.business;

import android.app.AlertDialog;
import android.app.ProgressDialog;
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

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.Opportunity;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.timer.DialogTimerTask;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

public class EditProgressHistoryActivity extends BaseActivity implements
        OnClickListener {
    private EditProgressHistoryActivityHandler mHandler = new EditProgressHistoryActivityHandler(this);
    private TextView opportunityCreateTime;
    private TextView opportunityProgressName;
    private TextView opportunityDetailProductName;
    private TextView opportunityDetailQuantity;
    private TextView opportunityDetailTotalPrice;
    private ImageButton updateOpportunityProgressBtn;
    private EditText opportunityDetailTotalSalePrice;
    private EditText editProgressDescription;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private int progressHistoryID;
    private int productType;
    private RelativeLayout opportunityTotalSalePriceRelativeLayout;
    private RelativeLayout opportunityTotalPriceRelativeLayout;
    private View tableRowView;
    private ImageButton plusQuantityBtn;
    private ImageButton reduceQuantityBtn;
    private String progressHistoryName;
    private String progressHistoryDescription;
    private String progressHistoryCreateTime;
    private Opportunity opp;
    private double finalUnitPrice = 0;
    private UserInfoApplication userinfoApplication;
    private Timer dialogTimer;
    private int opportunityID;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_edit_progress_history);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class EditProgressHistoryActivityHandler extends Handler {
        private final EditProgressHistoryActivity editProgressHistoryActivity;

        private EditProgressHistoryActivityHandler(EditProgressHistoryActivity activity) {
            WeakReference<EditProgressHistoryActivity> weakReference = new WeakReference<EditProgressHistoryActivity>(activity);
            editProgressHistoryActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (editProgressHistoryActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editProgressHistoryActivity.progressDialog != null) {
                editProgressHistoryActivity.progressDialog.dismiss();
                editProgressHistoryActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(editProgressHistoryActivity, "提示信息", "销售进度编辑成功！");
                alertDialog.show();
                Intent intent = new Intent(editProgressHistoryActivity,
                        OpportunityDetailMainActivity.class);
                intent.putExtra("current_tab", 1);
                intent.putExtra("opportunityID", editProgressHistoryActivity.opp.getOpportunityID());
                intent.putExtra("productType", editProgressHistoryActivity.productType);
                Bundle bundle = new Bundle();
                bundle.putSerializable("opportunity", editProgressHistoryActivity.opp);
                intent.putExtras(bundle);
                editProgressHistoryActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editProgressHistoryActivity.dialogTimer, editProgressHistoryActivity, intent);
                editProgressHistoryActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 0) {
                DialogUtil.createShortDialog(editProgressHistoryActivity,
                        "销售进度编辑失败！");
            } else if (msg.what == 2) {
                editProgressHistoryActivity.opportunityCreateTime.setText(editProgressHistoryActivity.progressHistoryCreateTime);
                editProgressHistoryActivity.opportunityProgressName.setText(editProgressHistoryActivity.progressHistoryName);
                editProgressHistoryActivity.opportunityDetailProductName.setText(editProgressHistoryActivity.opp.getProductName());
                editProgressHistoryActivity.opportunityDetailQuantity.setText(String.valueOf(editProgressHistoryActivity.opp
                        .getQuantity()));
                String formateTotalPrice = NumberFormatUtil.currencyFormat(editProgressHistoryActivity.opp
                        .getTotalPrice());
                editProgressHistoryActivity.opportunityDetailTotalPrice.setText(formateTotalPrice);
                editProgressHistoryActivity.editProgressDescription.setText(editProgressHistoryActivity.progressHistoryDescription);
                if (Float.valueOf(editProgressHistoryActivity.opp.getTotalSalePrice()) == 0
                        || editProgressHistoryActivity.opp.getTotalSalePrice().equals(editProgressHistoryActivity.opp.getTotalPrice())) {
                    editProgressHistoryActivity.tableRowView.setVisibility(View.GONE);
                    editProgressHistoryActivity.opportunityTotalSalePriceRelativeLayout.setVisibility(View.GONE);
                }
                String formateTotalSalePrice = NumberFormatUtil.currencyFormat(editProgressHistoryActivity.opp.getTotalSalePrice());
                editProgressHistoryActivity.opportunityDetailTotalSalePrice.setText(formateTotalSalePrice);
            } else if (msg.what == 3)
                DialogUtil.createShortDialog(editProgressHistoryActivity,
                        "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editProgressHistoryActivity, editProgressHistoryActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editProgressHistoryActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editProgressHistoryActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editProgressHistoryActivity);
                editProgressHistoryActivity.packageUpdateUtil = new PackageUpdateUtil(editProgressHistoryActivity, editProgressHistoryActivity.mHandler, fileCache, downloadFileUrl, false, editProgressHistoryActivity.userinfoApplication);
                editProgressHistoryActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                editProgressHistoryActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = editProgressHistoryActivity.getFileStreamPath(filename);
                file.getName();
                editProgressHistoryActivity.packageUpdateUtil.showInstallDialog();
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
        updateOpportunityProgressBtn = (ImageButton) findViewById(R.id.edit_opportunity__progress_btn);
        updateOpportunityProgressBtn.setOnClickListener(this);
        plusQuantityBtn = (ImageButton) findViewById(R.id.plus_quantity_btn);
        reduceQuantityBtn = (ImageButton) findViewById(R.id.reduce_quantity_btn);
        opportunityDetailTotalSalePrice = (EditText) findViewById(R.id.opportunity_detail_total_sale_price);
        opportunityTotalPriceRelativeLayout = (RelativeLayout) findViewById(R.id.total_price_relativelayout);
        opportunityTotalSalePriceRelativeLayout = (RelativeLayout) findViewById(R.id.total_sale_price_relativelayout);
        tableRowView = findViewById(R.id.tablerow_view);
        opportunityTotalPriceRelativeLayout.setOnClickListener(this);
        plusQuantityBtn.setOnClickListener(this);
        reduceQuantityBtn.setOnClickListener(this);
        progressHistoryID = getIntent().getIntExtra("progressHistoryID", 0);
        opportunityID = getIntent().getIntExtra("opportunityID", 0);
        productType = getIntent().getIntExtra("productType", 0);
        progressHistoryName = getIntent().getStringExtra("progressHistoryName");
        progressHistoryCreateTime = getIntent().getStringExtra("progressHistoryCreateTime");
        opp = (Opportunity) getIntent().getSerializableExtra("opportunity");
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "getProgressDetail";
                String endPoint = "opportunity";
                JSONObject progressDetailJson = new JSONObject();
                try {
                    progressDetailJson.put("ProgressID", progressHistoryID);
                    progressDetailJson.put("ProductType", productType);
                } catch (JSONException e1) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, progressDetailJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e2) {
                    // TODO Auto-generated catch block
                }
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(3);
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
                        JSONObject progressDetail = null;
                        try {
                            progressDetail = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                        }
                        if (progressDetail != null) {
                            opp = new Opportunity();
                            String productName = "";
                            String totalPrice = "0";
                            String totalSalePrice = "0";
                            int quantity = 0;
                            String promotionPrice = "0";
                            int marketingPolicy = 0;
                            double disCount = 0;
                            try {
                                if (progressDetail.has("ProductName"))
                                    productName = progressDetail.getString("ProductName");
                                if (progressDetail.has("TotalOrigPrice"))
                                    totalPrice = progressDetail.getString("TotalOrigPrice");
                                if (progressDetail.has("TotalSalePrice"))
                                    totalSalePrice = progressDetail.getString("TotalSalePrice");
                                if (progressDetail.has("Quantity"))
                                    quantity = progressDetail.getInt("Quantity");
                                if (progressDetail.has("Description"))
                                    progressHistoryDescription = progressDetail.getString("Description");
                                if (progressDetail.has("PromotionPrice"))
                                    promotionPrice = progressDetail.getString("PromotionPrice");
                                if (progressDetail.has("MarketingPolicy"))
                                    marketingPolicy = progressDetail.getInt("MarketingPolicy");
                                if (progressDetail.has("Discount"))
                                    disCount = progressDetail.getDouble("Discount");
                            } catch (JSONException e) {
                            }
                            opp.setOpportunityID(opportunityID);
                            opp.setProductName(productName);
                            opp.setTotalPrice(totalPrice);
                            opp.setTotalSalePrice(totalSalePrice);
                            opp.setQuantity(quantity);
                            opp.setMarketingPolicy(marketingPolicy);
                            opp.setDiscount(disCount);
                        }
                        mHandler.sendEmptyMessage(2);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else
                        mHandler.sendEmptyMessage(3);
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.edit_opportunity__progress_btn:
                progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.show();
                requestWebServiceThread = new Thread() {
                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        String methodName = "updateProgress";
                        String endPoint = "opportunity";
                        JSONObject updateProgress = new JSONObject();
                        try {
                            updateProgress.put("OpportunityID", String.valueOf(opp.getOpportunityID()));
                            updateProgress.put("ProgressID", String.valueOf(progressHistoryID));
                            updateProgress.put("Description", editProgressDescription.getText().toString());
                            updateProgress.put("Quantity", opportunityDetailQuantity.getText().toString());
                            updateProgress.put("TotalPrice", opportunityDetailTotalPrice.getText().toString());
                            if (opportunityDetailTotalSalePrice.getVisibility() == View.VISIBLE) {
                                if (opportunityDetailTotalSalePrice != null && !(("").equals(opportunityDetailTotalSalePrice.getText().toString())))
                                    updateProgress.put("TotalSalePrice", opportunityDetailTotalSalePrice.getText().toString());
                            } else
                                updateProgress.put("TotalSalePrice", -1);
                        } catch (JSONException e) {
                        }
                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, updateProgress.toString(), userinfoApplication);
                        if (serverRequestResult == null || ("").equals(serverRequestResult))
                            mHandler.sendEmptyMessage(3);
                        else {
                            JSONObject resultJson = null;
                            try {
                                resultJson = new JSONObject(serverRequestResult);
                            } catch (JSONException e) {
                                // TODO Auto-generated catch block
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
                            else
                                mHandler.sendEmptyMessage(0);
                        }
                    }
                };
                requestWebServiceThread.start();
                break;
            case R.id.plus_quantity_btn:
                opportunityDetailQuantity
                        .setText(String.valueOf(Integer
                                .parseInt(opportunityDetailQuantity.getText()
                                        .toString()) + 1));
                double afterPlusTotalPrice = (Double.valueOf(opp.getTotalPrice()) / opp
                        .getQuantity())
                        * Integer.parseInt(opportunityDetailQuantity.getText()
                        .toString());
                opportunityDetailTotalPrice.setText(NumberFormatUtil
                        .currencyFormat(String.valueOf(afterPlusTotalPrice)));
                double afterPlusTotalSalePrice = (Double.valueOf(opp
                        .getTotalSalePrice()) / opp.getQuantity())
                        * Integer.parseInt(opportunityDetailQuantity.getText()
                        .toString());
                opportunityDetailTotalSalePrice
                        .setText(NumberFormatUtil.currencyFormat(String
                                .valueOf(afterPlusTotalSalePrice)));
                break;
            case R.id.reduce_quantity_btn:
                if (Integer
                        .parseInt(opportunityDetailQuantity.getText().toString()) <= 1)
                    opportunityDetailQuantity.setText(String.valueOf(1));
                else {
                    opportunityDetailQuantity.setText(String.valueOf(Integer
                            .parseInt(opportunityDetailQuantity.getText()
                                    .toString()) - 1));
                    double afterReduceTotalPrice = (Double.valueOf(opp
                            .getTotalPrice()) / opp.getQuantity())
                            * Integer.parseInt(opportunityDetailQuantity.getText()
                            .toString());
                    opportunityDetailTotalPrice.setText(NumberFormatUtil
                            .currencyFormat(String.valueOf(afterReduceTotalPrice)));
                    double afterReduceTotalSalePrice = (Double.valueOf(opp
                            .getTotalSalePrice()) / opp.getQuantity())
                            * Integer.parseInt(opportunityDetailQuantity
                            .getText().toString());
                    opportunityDetailTotalSalePrice.setText(NumberFormatUtil
                            .currencyFormat(String
                                    .valueOf(afterReduceTotalSalePrice)));
                }
                break;
            case R.id.total_price_relativelayout:
                if (opportunityTotalSalePriceRelativeLayout.getVisibility() == View.VISIBLE
                        && tableRowView.getVisibility() == view.VISIBLE) {
                    tableRowView.setVisibility(View.GONE);
                    opportunityTotalSalePriceRelativeLayout
                            .setVisibility(View.GONE);
                } else {
                    tableRowView.setVisibility(View.VISIBLE);
                    opportunityTotalSalePriceRelativeLayout
                            .setVisibility(View.VISIBLE);

                }
                break;
        }
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
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
