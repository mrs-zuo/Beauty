package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.AppointmentListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AppointmentConditionInfo;
import com.GlamourPromise.Beauty.bean.AppointmentInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.XListView;
import com.GlamourPromise.Beauty.view.XListView.IXListViewListener;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Date;

public class AppointmentListActivity extends BaseActivity implements OnClickListener, OnItemClickListener, IXListViewListener {
    private AppointmentListActivityHandler handler = new AppointmentListActivityHandler(this);
    ImageButton activityAppointmentCustomerSearchNewBtn, activityAppointmentCreateBtn;
    private ProgressDialog progressDialog;
    private Boolean isRefresh = false;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private UserInfoApplication userinfoApplication;
    private AppointmentConditionInfo appointmentConditionInfo;
    int status[];
    ArrayList<AppointmentInfo> appointmentInfoList;
    private AppointmentListAdapter appointmentListAdapter;
    private XListView appointmentInfoView;
    private int pageIndex;
    private int appointmentInfoListFlag;// 1:取最初的数据；2：取最新的数据；3：取老数据
    private int pageCount = 1;// 全部页数
    String fromSource;
    private TextView activityAppointmentCustomerListTitleText;
    boolean isSearchOnLoadMore = false;
    boolean isSearchOnRefresh = false;
    int customerID = 0;
    private String customerName;
    private int source = 0;
    private static final int CUSTOMER_SERVICE = 1;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AppointmentListActivityHandler extends Handler {
        private final AppointmentListActivity appointmentListActivity;

        private AppointmentListActivityHandler(AppointmentListActivity activity) {
            WeakReference<AppointmentListActivity> weakReference = new WeakReference<AppointmentListActivity>(activity);
            appointmentListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (appointmentListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (appointmentListActivity.progressDialog != null) {
                appointmentListActivity.progressDialog.dismiss();
                appointmentListActivity.progressDialog = null;
            }
            if (appointmentListActivity.requestWebServiceThread != null) {
                appointmentListActivity.requestWebServiceThread.interrupt();
                appointmentListActivity.requestWebServiceThread = null;
            }
            appointmentListActivity.isRefresh = false;
            switch (msg.what) {
                case 1:
                    @SuppressWarnings("unchecked")
                    ArrayList<AppointmentInfo> tmpList = (ArrayList<AppointmentInfo>) msg.obj;
                    appointmentListActivity.pageCount = msg.arg2;
                    // 有老数据时，当前页数加一
                    if (tmpList.size() > 0) {
                        //设置订单列表页数信息
                        appointmentListActivity.pageIndex += 1;
                    }
                    if (appointmentListActivity.appointmentInfoListFlag == 1 || appointmentListActivity.appointmentInfoListFlag == 2) {
                        appointmentListActivity.appointmentInfoList.clear();
                        appointmentListActivity.appointmentInfoList.addAll(tmpList);
                    } else if (appointmentListActivity.appointmentInfoListFlag == 3 && tmpList != null && tmpList.size() > 0) {
                        appointmentListActivity.appointmentInfoList.addAll(appointmentListActivity.appointmentInfoList.size(), tmpList);
                    } else if (appointmentListActivity.appointmentInfoListFlag == 3 && (tmpList == null || tmpList.size() == 0)) {
                        appointmentListActivity.appointmentInfoView.hideFooterView();
                        DialogUtil.createShortDialog(appointmentListActivity, "没有更早的预约！");
                    }
                    appointmentListActivity.appointmentListAdapter.notifyDataSetChanged();
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(appointmentListActivity, appointmentListActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(appointmentListActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + appointmentListActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(appointmentListActivity);
                    appointmentListActivity.packageUpdateUtil = new PackageUpdateUtil(appointmentListActivity, appointmentListActivity.handler, fileCache, downloadFileUrl, false, appointmentListActivity.userinfoApplication);
                    appointmentListActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    appointmentListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "com.glamourpromise.beauty.business.apk";
                    File file = appointmentListActivity.getFileStreamPath(filename);
                    file.getName();
                    appointmentListActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                default:
                    if (appointmentListActivity.appointmentInfoListFlag == 1 || appointmentListActivity.appointmentInfoListFlag == 2) {
                        appointmentListActivity.appointmentInfoList.clear();
                        appointmentListActivity.appointmentListAdapter.notifyDataSetChanged();
                    }
                    DialogUtil.createShortDialog(appointmentListActivity, "您的网络貌似不给力，请重试");
                    break;
            }
            appointmentListActivity.onLoad();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_appointment_customer_list);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        Intent intent = getIntent();
        fromSource = intent.getStringExtra("FROM_SOURCE");
        customerID = intent.getIntExtra("customerID", 0);
        source = intent.getIntExtra("SOURCE", 0);
        if (source == CUSTOMER_SERVICE) {
            customerName = intent.getStringExtra("customerName");
        }
        appointmentInfoView = (XListView) findViewById(R.id.activity_appointment_customer_list_view);
        activityAppointmentCustomerSearchNewBtn = (ImageButton) findViewById(R.id.activity_appointment_customer_search_new_btn);
        activityAppointmentCreateBtn = (ImageButton) findViewById(R.id.activity_appointment_create_btn);
        activityAppointmentCustomerListTitleText = (TextView) findViewById(R.id.activity_appointment_customer_list_title_text);
        activityAppointmentCustomerSearchNewBtn.setOnClickListener(this);
        activityAppointmentCreateBtn.setVisibility(View.VISIBLE);
        int authMyOrderWrite = userinfoApplication.getAccountInfo().getAuthMyOrderWrite();
        if (authMyOrderWrite == 1)
            activityAppointmentCreateBtn.setOnClickListener(this);
        else
            activityAppointmentCreateBtn.setVisibility(View.GONE);
        appointmentInfoView.setOnItemClickListener(this);
        appointmentInfoView.setXListViewListener(this);
        appointmentInfoView.setPullLoadEnable(true);
        appointmentInfoList = new ArrayList<AppointmentInfo>();
        appointmentListAdapter = new AppointmentListAdapter(AppointmentListActivity.this, appointmentInfoList, fromSource);
        appointmentInfoView.setAdapter(appointmentListAdapter);
        appointmentInfoList.clear();
        activityAppointmentCustomerListTitleText.setText("预约");
        initPageIndex();
        refreshList(1, false);

    }

    private void refreshList(int flag, boolean isSelect) {
        // 上一次取数据任务还没有完成，不在调用后台
        if (isRefresh)
            return;
        // 取老数据时，已经取完数据不在调用后台
        if (flag == 3 && (pageIndex > pageCount || appointmentInfoList.size() < 10)) {
            DialogUtil.createShortDialog(this, "没有更早的预约！");
            onLoad();
            appointmentInfoView.hideFooterView();
            return;
        } else {
            appointmentInfoView.setPullLoadEnable(true);
        }
        isRefresh = true;
        appointmentInfoListFlag = flag;
        if (flag == 1) {
            if (progressDialog == null) {
                progressDialog = new ProgressDialog(AppointmentListActivity.this, R.style.CustomerProgressDialog);
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.setCancelable(false);
            }
            progressDialog.show();
        }
        int currentPageIndex = 1;
        if (appointmentInfoListFlag == 3) {
            currentPageIndex = pageIndex;
            if (currentPageIndex >= 1)
                appointmentConditionInfo.setTaskScdlStartTime(appointmentInfoList.get(appointmentInfoList.size() - 1).getTaskScdlStartTime());
        } else if (appointmentInfoListFlag == 2) {
            initPageIndex();
        }
        if (!isSelect) {
            appointmentConditionInfo = new AppointmentConditionInfo();
            appointmentConditionInfo.setBranchID(userinfoApplication.getAccountInfo().getBranchId());
            if (source == CUSTOMER_SERVICE) {
                appointmentConditionInfo.setCustomerID(customerID);
            }
            appointmentConditionInfo.setPageSize(10);
            status = new int[]{1, 2};
            //查看所有订单或者预约的权限  如果ResponsiblePersonIDs为空  则读取本店所有的预约  如果不为空 则查看指定的ResponsiblePersonIDs的预约
            int authAllOrderRead = userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
            if (authAllOrderRead == 1)
                appointmentConditionInfo.setResponsiblePersonIDs("[]");
            else
                appointmentConditionInfo.setResponsiblePersonIDs("[" + userinfoApplication.getAccountInfo().getAccountId() + "]");
            appointmentConditionInfo.setStatus(status);
            appointmentConditionInfo.setTaskType(1);
        }
        appointmentConditionInfo.setPageIndex(currentPageIndex);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetScheduleList";
                String endPoint = "Task";
                JSONArray statusArray = new JSONArray();
                JSONObject appointmentJson = new JSONObject();
                if (appointmentConditionInfo.getStatus().length > 0) {
                    status = appointmentConditionInfo.getStatus();
                    for (int i = 0; i < appointmentConditionInfo.getStatus().length; i++) {
                        statusArray.put(status[i]);
                    }
                }
                try {
                    appointmentJson.put("BranchID", appointmentConditionInfo.getBranchID());
                    appointmentJson.put("FilterByTimeFlag", appointmentConditionInfo.getFilterByTimeFlag());
                    appointmentJson.put("PageIndex", appointmentConditionInfo.getPageIndex());
                    appointmentJson.put("PageSize", appointmentConditionInfo.getPageSize());
                    appointmentJson.put("TaskScdlStartTime", appointmentConditionInfo.getTaskScdlStartTime());
                    JSONArray taskTypeArray = new JSONArray();
                    taskTypeArray.put(1);
                    appointmentJson.put("TaskType", taskTypeArray);
                    appointmentJson.put("Status", statusArray);
                    if (appointmentConditionInfo.getResponsiblePersonIDs().length() > 0) {
                        JSONArray responsiblePersonIDsArray = new JSONArray(appointmentConditionInfo.getResponsiblePersonIDs());
                        if (responsiblePersonIDsArray.length() > 0) {
                            appointmentJson.put("ResponsiblePersonIDs", responsiblePersonIDsArray);
                        }
                    }
                    appointmentJson.put("CustomerID", appointmentConditionInfo.getCustomerID());
                    appointmentJson.put("StartTime", appointmentConditionInfo.getStartTime());
                    appointmentJson.put("EndTime", appointmentConditionInfo.getEndTime());
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, appointmentJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                Message msg = handler.obtainMessage();
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e) {
                }

                if (serverResultResult == null || serverResultResult.equals(""))
                    handler.sendEmptyMessage(-1);
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
                        ArrayList<AppointmentInfo> appointmentList = new ArrayList<AppointmentInfo>();
                        JSONObject appointmentObject = null;
                        try {
                            appointmentObject = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {

                        }
                        if (appointmentObject != null) {
                            try {

                                if (appointmentObject.has("RecordCount")) {
                                    msg.arg1 = appointmentObject.getInt("RecordCount");
                                }
                                if (appointmentObject.has("PageCount")) {
                                    msg.arg2 = appointmentObject.getInt("PageCount");
                                }
                                if (appointmentObject.has("TaskList") && !appointmentObject.isNull("TaskList")) {
                                    JSONArray taskListaArray = new JSONArray();
                                    taskListaArray = appointmentObject.getJSONArray("TaskList");
                                    if (taskListaArray.length() > 0) {
                                        for (int i = 0; i < taskListaArray.length(); i++) {
                                            JSONObject taskjson = null;
                                            taskjson = (JSONObject) taskListaArray.get(i);
                                            AppointmentInfo appointmentInfo = new AppointmentInfo();
                                            if (taskjson.has("ResponsiblePersonName")) {
                                                appointmentInfo.setResponsiblePersonName(taskjson.getString("ResponsiblePersonName"));
                                            }
                                            if (taskjson.has("CustomerName")) {
                                                appointmentInfo.setCustomerName(taskjson.getString("CustomerName"));
                                            }
                                            if (taskjson.has("TaskName")) {
                                                appointmentInfo.setTaskName(taskjson.getString("TaskName"));
                                            }
                                            if (taskjson.has("TaskID")) {
                                                appointmentInfo.setTaskID(taskjson.getLong("TaskID"));
                                            }
                                            if (taskjson.has("TaskStatus") && taskjson.has("TaskStatus")) {
                                                appointmentInfo.setTaskStatus(taskjson.getInt("TaskStatus"));
                                            }
                                            if (taskjson.has("TaskType") && taskjson.has("TaskType")) {
                                                appointmentInfo.setTaskType(taskjson.getInt("TaskType"));
                                            }
                                            if (taskjson.has("TaskScdlStartTime") && taskjson.has("TaskScdlStartTime")) {
                                                appointmentInfo.setTaskScdlStartTime(taskjson.getString("TaskScdlStartTime"));
                                            }
                                            if (taskjson.has("ResponsiblePersonID") && taskjson.has("ResponsiblePersonID")) {
                                                appointmentInfo.setResponsiblePersonID(taskjson.getInt("ResponsiblePersonID"));
                                            }
                                            if (taskjson.has("ResponsiblePersonMobile") && taskjson.has("ResponsiblePersonMobile")) {
                                                appointmentInfo.setResponsiblePersonMobile(taskjson.getString("ResponsiblePersonMobile"));
                                            }
                                            if (taskjson.has("BranchName") && taskjson.has("BranchName")) {
                                                appointmentInfo.setBranchName(taskjson.getString("BranchName"));
                                            }
                                            appointmentList.add(appointmentInfo);
                                        }
                                    }
                                }
                            } catch (JSONException e) {
                            }
                        }
                        msg.obj = appointmentList;
                        msg.what = 1;
                        handler.sendMessage(msg);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        handler.sendEmptyMessage(code);
                    else {
                        msg.what = 0;
                        msg.obj = message;
                        handler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }


    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        appointmentInfoView.setPullLoadEnable(true);
        appointmentInfoList.clear();
        onRefresh();
    }

    private void initPageIndex() {
        pageIndex = 1;
    }

    @SuppressWarnings("deprecation")
    private void onLoad() {
        appointmentInfoView.stopRefresh();
        appointmentInfoView.stopLoadMore();
        appointmentInfoView.setRefreshTime(new Date().toLocaleString());
    }

    @Override
    public void onRefresh() {
        isSearchOnLoadMore = true;
        isSearchOnRefresh = true;
        source = 0;
        refreshList(2, isSearchOnRefresh);

    }

    @Override
    public void onLoadMore() {
        if (isSearchOnRefresh) {
            if (isSearchOnLoadMore)
                refreshList(3, true);
            else
                refreshList(3, false);
        } else {
            if (isSearchOnLoadMore)
                refreshList(3, false);
            else
                refreshList(3, true);
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        if (position != 0) {
            Intent intent = null;
            if (appointmentInfoList != null && appointmentInfoList.size() != 0) {
                AppointmentInfo appointmentInfo = appointmentInfoList.get(position - 1);
                if (appointmentInfo.getTaskType() == 2) {
                    intent = new Intent(this, AppointmentTaskDetailActivity.class);
                } else {
                    intent = new Intent(this, AppointmentDetailActivity.class);
                }
                Bundle bu = new Bundle();
                bu.putLong("taskID", appointmentInfo.getTaskID());
                intent.putExtras(bu);
                intent.putExtra("taskStatus", appointmentInfo.getTaskStatus());
                startActivityForResult(intent, 3);
            }
        }
    }

    @Override
    public void onClick(View v) {
        Intent intent;
        Bundle bundle;
        switch (v.getId()) {
            case R.id.activity_appointment_create_btn:
                intent = new Intent(this, AppointmentCreateActivity.class);
                if (source == CUSTOMER_SERVICE) {
                    intent.putExtra("customerID", customerID);
                    intent.putExtra("customerName", customerName);
                    intent.putExtra("FROM_SOURCE", CUSTOMER_SERVICE);
                }
                bundle = new Bundle();
                bundle.putSerializable("appointmentConditionInfo", appointmentConditionInfo);
                intent.putExtras(bundle);
                startActivityForResult(intent, 2);
                break;
            case R.id.activity_appointment_customer_search_new_btn:
                intent = new Intent(this, AppointmentSearchNewActivity.class);
                bundle = new Bundle();
                bundle.putSerializable("appointmentConditionInfo", appointmentConditionInfo);
                intent.putExtras(bundle);
                startActivityForResult(intent, 1);
                break;
        }

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 选择员工成功返回
        if (resultCode == RESULT_OK) {
            if (requestCode == 1) {
                appointmentConditionInfo = (AppointmentConditionInfo) data.getSerializableExtra("appointmentConditionInfo");
                initPageIndex();
                isSearchOnRefresh = true;
                isSearchOnLoadMore = true;
                refreshList(1, isSearchOnRefresh);
            } else if (requestCode == 2) {
                appointmentConditionInfo = (AppointmentConditionInfo) data.getSerializableExtra("appointmentConditionInfo");
                initPageIndex();
                isSearchOnRefresh = true;
                isSearchOnLoadMore = true;
                refreshList(1, isSearchOnRefresh);
            } else if (requestCode == 3) {
                initPageIndex();
                isSearchOnRefresh = false;
                isSearchOnLoadMore = true;
                refreshList(1, true);
            }
        }
    }

    @Override
    protected void onRestart() {
        super.onRestart();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exit = true;
        if (handler != null) {
            handler.removeCallbacksAndMessages(null);
            // handler = null;
        }
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
        if (appointmentInfoList != null) {
            appointmentInfoList.clear();
            appointmentInfoList = null;
        }
    }

}
