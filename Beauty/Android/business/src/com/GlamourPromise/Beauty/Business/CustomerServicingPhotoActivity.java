package com.GlamourPromise.Beauty.Business;

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
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.TreatmentImageListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.Treatment;
import com.GlamourPromise.Beauty.bean.TreatmentImage;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DateUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.OrigianlImageView;
import com.GlamourPromise.Beauty.view.TreatmentImageGridView;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

@SuppressLint("ResourceType")
public class CustomerServicingPhotoActivity extends BaseActivity {
    private CustomerServicingPhotoActivityHandler mHandler = new CustomerServicingPhotoActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private List<Treatment> treatmentList;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private LinearLayout photoListLinearLayout;
    private LayoutInflater layoutInflater;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_servicing_photo);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class CustomerServicingPhotoActivityHandler extends Handler {
        private final CustomerServicingPhotoActivity customerServicingPhotoActivity;

        private CustomerServicingPhotoActivityHandler(CustomerServicingPhotoActivity activity) {
            WeakReference<CustomerServicingPhotoActivity> weakReference = new WeakReference<CustomerServicingPhotoActivity>(activity);
            customerServicingPhotoActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (customerServicingPhotoActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerServicingPhotoActivity.progressDialog != null) {
                customerServicingPhotoActivity.progressDialog.dismiss();
                customerServicingPhotoActivity.progressDialog = null;
            }
            if (customerServicingPhotoActivity.requestWebServiceThread != null) {
                customerServicingPhotoActivity.requestWebServiceThread.interrupt();
                customerServicingPhotoActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                //初始化照片的视图
                if (customerServicingPhotoActivity.treatmentList != null && customerServicingPhotoActivity.treatmentList.size() > 0) {
                    customerServicingPhotoActivity.photoListLinearLayout.removeAllViews();
                    for (final Treatment treatment : customerServicingPhotoActivity.treatmentList) {
                        View treatmentDetailView = customerServicingPhotoActivity.layoutInflater.inflate(R.xml.customer_servicing_photo_item, null);
                        TextView startTime = (TextView) treatmentDetailView.findViewById(R.id.start_time);
                        startTime.setText(DateUtil.getFormateDateByString(treatment.getStartTime()));
                        TextView serviceName = (TextView) treatmentDetailView.findViewById(R.id.tg_service_name);
                        serviceName.setText(treatment.getSubServiceName());
                        treatmentDetailView.findViewById(R.id.tg_detail_rl).setOnClickListener(new OnClickListener() {

                            @Override
                            public void onClick(View view) {
                                // TODO Auto-generated method stub
                                OrderInfo orderInfo = new OrderInfo();
                                orderInfo.setOrderObejctID(treatment.getOrderObjectID());
                                orderInfo.setProductType(0);
                                Bundle bundle = new Bundle();
                                bundle.putSerializable("orderInfo", orderInfo);
                                Intent destIntent = new Intent(customerServicingPhotoActivity, OrderDetailActivity.class);
                                destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                                destIntent.putExtra("FromOrderList", true);
                                destIntent.putExtras(bundle);
                                customerServicingPhotoActivity.startActivity(destIntent);
                            }
                        });
                        final TreatmentImageGridView treatmentImageGridView = (TreatmentImageGridView) treatmentDetailView.findViewById(R.id.treatment_image_list);

                        treatmentImageGridView.setOnItemClickListener(new OnItemClickListener() {

                            @Override
                            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
                                // TODO Auto-generated method stub
                                String originalImageUrl = treatment.getTreatmentImageList().get(arg2).getTreatmentImageURL().split("&")[0];
                                new OrigianlImageView(customerServicingPhotoActivity, treatmentImageGridView, originalImageUrl).showOrigianlImage();
                            }
                        });
                        TreatmentImageListAdapter treatmentImageListAdapter = new TreatmentImageListAdapter(customerServicingPhotoActivity.getApplicationContext(), treatment.getTreatmentImageList());
                        treatmentImageGridView.setAdapter(treatmentImageListAdapter);
                        customerServicingPhotoActivity.photoListLinearLayout.addView(treatmentDetailView);
                    }
                }
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(customerServicingPhotoActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerServicingPhotoActivity, customerServicingPhotoActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerServicingPhotoActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerServicingPhotoActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerServicingPhotoActivity);
                customerServicingPhotoActivity.packageUpdateUtil = new PackageUpdateUtil(customerServicingPhotoActivity, customerServicingPhotoActivity.mHandler, fileCache, downloadFileUrl, false, customerServicingPhotoActivity.userinfoApplication);
                customerServicingPhotoActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerServicingPhotoActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = customerServicingPhotoActivity.getFileStreamPath(filename);
                file.getName();
                customerServicingPhotoActivity.packageUpdateUtil.showInstallDialog();
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
        layoutInflater = LayoutInflater.from(this);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        photoListLinearLayout = (LinearLayout) findViewById(R.id.customer_servicing_photo_ll);
        requestWebService();
    }

    private void requestWebService() {
        treatmentList = new ArrayList<Treatment>();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "GetAllServiceEffectByCustomerID";
                String endPoint = "Image";
                JSONObject getPhotoListJsonParam = new JSONObject();
                try {
                    getPhotoListJsonParam.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getPhotoListJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    JSONArray treatmentJsonArray = null;
                    int code = 0;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        try {
                            treatmentJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        for (int i = 0; i < treatmentJsonArray.length(); i++) {
                            JSONObject treatmentJson = null;
                            try {
                                treatmentJson = treatmentJsonArray.getJSONObject(i);
                            } catch (JSONException e) {
                            }
                            String groupNo = "";
                            String startTime = "";
                            String serviceName = "";
                            int orderObjectID = 0;
                            List<TreatmentImage> treatmentImageList = null;
                            try {
                                if (treatmentJson.has("GroupNo") && !treatmentJson.isNull("GroupNo"))
                                    groupNo = treatmentJson.getString("GroupNo");
                                if (treatmentJson.has("TGStartTime") && !treatmentJson.isNull("TGStartTime"))
                                    startTime = treatmentJson.getString("TGStartTime");
                                if (treatmentJson.has("ServiceName") && !treatmentJson.isNull("ServiceName"))
                                    serviceName = treatmentJson.getString("ServiceName");
                                if (treatmentJson.has("OrderObjectID") && !treatmentJson.isNull("OrderObjectID"))
                                    orderObjectID = treatmentJson.getInt("OrderObjectID");
                                if (treatmentJson.has("ImageEffect") && !treatmentJson.isNull("ImageEffect")) {
                                    treatmentImageList = new ArrayList<TreatmentImage>();
                                    JSONArray imageJsonArray = treatmentJson.getJSONArray("ImageEffect");
                                    for (int j = 0; j < imageJsonArray.length(); j++) {
                                        TreatmentImage treatmentImage = new TreatmentImage();
                                        treatmentImage.setTreatmentImageURL(imageJsonArray.getJSONObject(j).getString("ThumbnailURL"));
                                        treatmentImageList.add(treatmentImage);
                                    }
                                }
                            } catch (JSONException e) {
                            }
                            Treatment treatment = new Treatment();
                            treatment.setTreatmentCode(groupNo);
                            treatment.setStartTime(startTime);
                            treatment.setSubServiceName(serviceName);
                            treatment.setOrderObjectID(orderObjectID);
                            treatment.setTreatmentImageList(treatmentImageList);
                            treatmentList.add(treatment);
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
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

    @Override
    protected void onRestart() {
        // TODO Auto-generated method stub
        super.onRestart();
        requestWebService();
    }
}
