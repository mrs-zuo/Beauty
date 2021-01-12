package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.ReportDetailListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ReportListBean;
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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class ReportDetailListActivity extends BaseActivity {
    private ReportDetailListActivityHandler mHandler = new ReportDetailListActivityHandler(this);
    private TextView reportDetailListTitleText, reportDetailTotalCountText, reportDetailListByOtherStartTimeText, reportDetailListByOtherEndTimeText;
    private ListView reportDetailListView;
    private int reportType;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private int cycleType, objectType, objectID, orderType, productType, extractItemType, statementCategoryID;
    private List<ReportListBean> reportListBeanList;
    private UserInfoApplication userinfoApplication;
    // 其他日期查询
    private RelativeLayout reportDetailListByOtherRelativelayout;
    private String startTime, endTime;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_report_detail_list);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        reportDetailListTitleText = (TextView) findViewById(R.id.report_detail_list_title_text);
        reportDetailListView = (ListView) findViewById(R.id.report_detail_list);
        reportDetailTotalCountText = (TextView) findViewById(R.id.report_detail_count_text);
        reportDetailListByOtherRelativelayout = (RelativeLayout) findViewById(R.id.report_detail_list_by_other_relativelayout);
        reportDetailListByOtherStartTimeText = (TextView) findViewById(R.id.report_detail_list_by_other_start_date);
        reportDetailListByOtherEndTimeText = (TextView) findViewById(R.id.report_detail_list_by_other_end_date);
        Intent intent = getIntent();
        reportType = intent.getIntExtra("REPORT_TYPE", 0);
        cycleType = intent.getIntExtra("CYCLE_TYPE", 0);
        orderType = intent.getIntExtra("ORDER_TYPE", 0);
        productType = intent.getIntExtra("PRODUCT_TYPE", 0);
        extractItemType = intent.getIntExtra("EXTRACT_ITEM_TYPE", 0);
        statementCategoryID = intent.getIntExtra("CATEGORY_ID", 0);
        if (reportType == Constant.ALL_BRANCH_REPORT || reportType == Constant.EMPLOYEE_REPORT || reportType == Constant.GROUP_REPORT)
            objectID = intent.getIntExtra("OBJECT_ID", 0);
        if (reportType == Constant.MY_REPORT) {
            objectType = 0;
        } else if (reportType == Constant.MY_BRANCH_REPORT) {
            objectType = 1;
        } else if (reportType == Constant.COMPANY_REPORT) {
            objectType = 2;
        } else if (reportType == Constant.EMPLOYEE_REPORT) {
            objectType = 0;
        } else if (reportType == Constant.ALL_BRANCH_REPORT) {
            objectType = 1;
        } else if (reportType == Constant.GROUP_REPORT) {
            objectType = 3;
        }
        String dateTypeStr = "";
        if (cycleType == 0)
            dateTypeStr = "(日)";
        else if (cycleType == 1)
            dateTypeStr = "(月)";
        else if (cycleType == 2)
            dateTypeStr = "(季)";
        else if (cycleType == 3)
            dateTypeStr = "(年)";
        else if (cycleType == 4) {
            startTime = intent.getStringExtra("START_TIME");
            endTime = intent.getStringExtra("END_TIME");
            reportDetailListByOtherRelativelayout.setVisibility(View.VISIBLE);
            reportDetailListByOtherStartTimeText.setText(convertStringToDate(startTime));
            reportDetailListByOtherEndTimeText.setText(convertStringToDate(endTime));
        }
        //服务销售分析
        if (productType == 0) {
            if (extractItemType == 0) {
                if (orderType == 1)
                    reportDetailListTitleText.setText("服务销售额" + dateTypeStr);
                else if (orderType == 0)
                    reportDetailListTitleText.setText("服务消费额" + dateTypeStr);
            } else if (extractItemType == 1) {
                reportDetailListTitleText.setText("服务销售量" + dateTypeStr);
            } else if (extractItemType == 2) {
                reportDetailListTitleText.setText("服务次数" + dateTypeStr);
            } else if (extractItemType == 5) {
                reportDetailListTitleText.setText("服务操作" + dateTypeStr);
            }
        }
        //商品销售分析
        else if (productType == 1) {
            if (extractItemType == 0) {
                if (orderType == 1)
                    reportDetailListTitleText.setText("商品销售额" + dateTypeStr);
                else if (orderType == 0)
                    reportDetailListTitleText.setText("商品消费额" + dateTypeStr);
            } else if (extractItemType == 1) {
                reportDetailListTitleText.setText("商品销售量" + dateTypeStr);
            }
        }
        requestWebService(cycleType, objectType);
    }

    private static class ReportDetailListActivityHandler extends Handler {
        private final ReportDetailListActivity reportDetailListActivity;

        private ReportDetailListActivityHandler(ReportDetailListActivity activity) {
            WeakReference<ReportDetailListActivity> weakReference = new WeakReference<ReportDetailListActivity>(activity);
            reportDetailListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (reportDetailListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (reportDetailListActivity.progressDialog != null) {
                reportDetailListActivity.progressDialog.dismiss();
                reportDetailListActivity.progressDialog = null;
            }
            if (message.what == 1) {
                double reportTotalCount = 0;
                if (reportDetailListActivity.extractItemType == 0) {
                    double totalCount = 0;
                    for (ReportListBean rlb : reportDetailListActivity.reportListBeanList) {
                        totalCount = totalCount
                                + Double.valueOf(rlb.getSalesAmount());
                    }
                    reportTotalCount = totalCount;
                    reportDetailListActivity.reportDetailTotalCountText.setText(reportDetailListActivity.userinfoApplication.getAccountInfo().getCurrency()
                            + NumberFormatUtil.currencyFormat(String
                            .valueOf(totalCount)));
                } else if (reportDetailListActivity.extractItemType == 1 && reportDetailListActivity.productType == 0) {
                    int totalCount = 0;
                    for (ReportListBean rlb : reportDetailListActivity.reportListBeanList) {
                        totalCount = totalCount
                                + Integer.parseInt(rlb.getSalesAmount());
                    }
                    reportTotalCount = totalCount;
                    reportDetailListActivity.reportDetailTotalCountText.setText(Integer.parseInt(String
                            .valueOf(totalCount)) + "项");
                } else if (reportDetailListActivity.extractItemType == 1 && reportDetailListActivity.productType == 1) {
                    int totalCount = 0;
                    for (ReportListBean rlb : reportDetailListActivity.reportListBeanList) {
                        totalCount = totalCount
                                + Integer.parseInt(rlb.getSalesAmount());
                    }
                    reportTotalCount = totalCount;
                    reportDetailListActivity.reportDetailTotalCountText.setText(Integer.parseInt(String
                            .valueOf(totalCount)) + "件");
                }
                // 服务次数
                else if (reportDetailListActivity.extractItemType == 2) {
                    int totalCount = 0;
                    for (ReportListBean rlb : reportDetailListActivity.reportListBeanList) {
                        totalCount = totalCount
                                + Integer.parseInt(rlb.getSalesAmount());
                    }
                    reportTotalCount = totalCount;
                    reportDetailListActivity.reportDetailTotalCountText.setText(Integer.parseInt(String
                            .valueOf(totalCount)) + "次");
                }
                //服务操作顾客消费分析
                else if (reportDetailListActivity.extractItemType == 5) {
                    double totalCount = 0;
                    for (ReportListBean rlb : reportDetailListActivity.reportListBeanList) {
                        totalCount = totalCount
                                + Double.valueOf(rlb.getSalesAmount());
                    }
                    reportTotalCount = totalCount;
                    reportDetailListActivity.reportDetailTotalCountText.setText(reportDetailListActivity.userinfoApplication.getAccountInfo().getCurrency()
                            + NumberFormatUtil.currencyFormat(String
                            .valueOf(totalCount)));
                }
                reportDetailListActivity.reportDetailListView.setAdapter(new ReportDetailListAdapter(reportDetailListActivity, reportDetailListActivity.reportListBeanList, reportDetailListActivity.extractItemType, reportDetailListActivity.productType, reportTotalCount));
            } else if (message.what == 2)
                DialogUtil.createShortDialog(reportDetailListActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(reportDetailListActivity, reportDetailListActivity.getString(R.string.login_error_message));
                reportDetailListActivity.userinfoApplication.exitForLogin(reportDetailListActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + reportDetailListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(reportDetailListActivity);
                reportDetailListActivity.packageUpdateUtil = new PackageUpdateUtil(reportDetailListActivity, reportDetailListActivity.mHandler, fileCache, downloadFileUrl, false, reportDetailListActivity.userinfoApplication);
                reportDetailListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                reportDetailListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = reportDetailListActivity.getFileStreamPath(filename);
                file.getName();
                reportDetailListActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (reportDetailListActivity.requestWebServiceThread != null) {
                reportDetailListActivity.requestWebServiceThread.interrupt();
                reportDetailListActivity.requestWebServiceThread = null;
            }
        }
    }

    private void requestWebService(int cycleType, int objectType) {
        final int ct = cycleType;
        final int ot = objectType;
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        if (cycleType != 4) {
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    String methodName = "getReportDetail_1_7_2";
                    String endPoint = "report";
                    JSONObject reportDetailJson = new JSONObject();
                    try {
                        if (reportType == Constant.ALL_BRANCH_REPORT)
                            reportDetailJson.put("BranchID", objectID);
                        else
                            reportDetailJson.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                        if (reportType == Constant.EMPLOYEE_REPORT || reportType == Constant.GROUP_REPORT) {
                            reportDetailJson.put("AccountID", objectID);
                        } else
                            reportDetailJson.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                        reportDetailJson.put("CycleType", ct);
                        reportDetailJson.put("ObjectType", ot);
                        reportDetailJson.put("OrderType", orderType);
                        reportDetailJson.put("ProductType", productType);
                        reportDetailJson.put("ExtractItemType", extractItemType);
                        reportDetailJson.put("SortType", 1);
                        reportDetailJson.put("StatementCategoryID", statementCategoryID);
                    } catch (JSONException e) {
                    }
                    String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, reportDetailJson.toString(), userinfoApplication);
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                    } catch (JSONException e2) {
                        // TODO Auto-generated catch block
                    }
                    if (serverRequestResult == null || serverRequestResult.equals(""))
                        mHandler.sendEmptyMessage(2);
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
                            JSONArray branchArray = null;
                            try {
                                if (extractItemType != 2)
                                    branchArray = resultJson.getJSONObject("Data").getJSONObject("ProductDetail").getJSONArray("ProductDetail");
                                else if (extractItemType == 2)
                                    branchArray = resultJson.getJSONObject("Data").getJSONArray("TreatmentTimesDetail");
                            } catch (JSONException e) {
                            }
                            reportListBeanList = new ArrayList<ReportListBean>();
                            if (branchArray != null) {
                                for (int i = 0; i < branchArray.length(); i++) {
                                    ReportListBean rlb = new ReportListBean();
                                    JSONObject branchJson = null;
                                    try {
                                        branchJson = (JSONObject) branchArray.get(i);
                                    } catch (JSONException e) {

                                    }
                                    String objectName = "";
                                    String salesAmount = "0";
                                    try {
                                        if (branchJson.has("ObjectName") && !branchJson.isNull("ObjectName"))
                                            objectName = branchJson.getString("ObjectName");
                                        if (extractItemType != 2) {
                                            if (branchJson.has("TotalPrice") && !branchJson.isNull("TotalPrice"))
                                                salesAmount = branchJson.getString("TotalPrice");
                                        } else if (extractItemType == 2) {
                                            if (branchJson.has("Total") && !branchJson.isNull("Total"))
                                                salesAmount = branchJson.getString("Total");
                                        }

                                    } catch (JSONException e) {
                                    }
                                    rlb.setObjectName(objectName);
                                    rlb.setSalesAmount(salesAmount);
                                    reportListBeanList.add(rlb);
                                }
                            }
                            mHandler.sendEmptyMessage(1);
                        } else
                            mHandler.sendEmptyMessage(code);
                    }
                }
            };
        } else if (cycleType == 4) {
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    String methodName = "getReportDetail_1_7_2";
                    String endPoint = "report";
                    JSONObject reportDetailJson = new JSONObject();
                    try {
                        if (reportType == Constant.ALL_BRANCH_REPORT)
                            reportDetailJson.put("BranchID", objectID);
                        else
                            reportDetailJson.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                        if (reportType == Constant.EMPLOYEE_REPORT) {
                            reportDetailJson.put("AccountID", objectID);
                        } else
                            reportDetailJson.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                        reportDetailJson.put("CycleType", ct);
                        reportDetailJson.put("ObjectType", ot);
                        reportDetailJson.put("OrderType", orderType);
                        reportDetailJson.put("ProductType", productType);
                        reportDetailJson.put("ExtractItemType", extractItemType);
                        reportDetailJson.put("SortType", 1);
                        reportDetailJson.put("StatementCategoryID", statementCategoryID);
                        reportDetailJson.put("StartTime", startTime);
                        reportDetailJson.put("EndTime", endTime);
                    } catch (JSONException e) {
                    }
                    String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, reportDetailJson.toString(), userinfoApplication);
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                    } catch (JSONException e) {
                    }
                    if (serverRequestResult == null || serverRequestResult.equals(""))
                        mHandler.sendEmptyMessage(2);
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
                            JSONArray branchArray = null;
                            try {
                                if (extractItemType != 2)
                                    branchArray = resultJson.getJSONObject("Data").getJSONObject("ProductDetail").getJSONArray("ProductDetail");
                                else if (extractItemType == 2)
                                    branchArray = resultJson.getJSONObject("Data").getJSONArray("TreatmentTimesDetail");
                            } catch (JSONException e) {
                            }
                            reportListBeanList = new ArrayList<ReportListBean>();
                            if (branchArray != null) {
                                for (int i = 0; i < branchArray.length(); i++) {
                                    ReportListBean rlb = new ReportListBean();
                                    JSONObject branchJson = null;
                                    try {
                                        branchJson = branchArray.getJSONObject(i);
                                    } catch (JSONException e1) {
                                    }
                                    String objectName = "";
                                    String salesAmount = "0";
                                    try {
                                        if (branchJson.has("ObjectName") && !branchJson.isNull("ObjectName"))
                                            objectName = branchJson.getString("ObjectName");
                                        if (extractItemType != 2) {
                                            if (branchJson.has("TotalPrice") && !branchJson.isNull("TotalPrice"))
                                                salesAmount = branchJson.getString("TotalPrice");
                                        } else if (extractItemType == 2) {
                                            if (branchJson.has("Total") && !branchJson.isNull("Total"))
                                                salesAmount = branchJson.getString("Total");
                                        }
                                    } catch (JSONException e) {
                                    }
                                    rlb.setObjectName(objectName);
                                    rlb.setSalesAmount(salesAmount);
                                    reportListBeanList.add(rlb);
                                }
                            }
                            mHandler.sendEmptyMessage(1);
                        } else
                            mHandler.sendEmptyMessage(code);
                    }
                }
            };
        }
        requestWebServiceThread.start();
    }

    private String convertStringToDate(String dateSource) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Calendar calendar = Calendar.getInstance();
        Date date = null;
        try {
            date = simpleDateFormat.parse(dateSource);
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            date = null;
        }
        if (date != null) {
            calendar.setTime(date);
        }
        return calendar.get(Calendar.YEAR) + "年" + (calendar.get(Calendar.MONTH) + 1) + "月" + calendar.get(Calendar.DAY_OF_MONTH) + "日";
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
