package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.ViewPagerAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CommodityInfo;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.ServiceInfo;
import cn.com.antika.bean.SubService;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.OrigianlImageView;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class ServiceDetailActivity extends BaseActivity implements OnClickListener {
    private ServiceDetailActivityHandler mHandler = new ServiceDetailActivityHandler(this);
    private long serviceCode;
    private LayoutInflater mLayoutInflater;
    private Thread requestWebServiceThread;
    private ServiceInfo serviceInfo;
    private List<View> mViewList = new ArrayList<View>();
    private View childView, seviceDetailServiceFrquencyDivideView;
    private ViewPager viewPager;
    private ViewPagerAdapter PagerAdapter;
    private ImageView arrowRight, arrowLeft;
    private int imageCount;
    private ImageLoader imageLoader;
    private LinearLayout serviceImageShowLinearlayout;
    private UserInfoApplication userinfoApplication;
    private String categoryID, categroyName, resAcvitityname;
    private RelativeLayout serviceDetailServiceFrquencyRelativeLayout;
    private TextView serviceDetailServiceFrquencyText, serviceDetailServiceUnitPriceText, serviceDetailServiceIntroudctionText, serviceDetailNameText, serviceDetailServiceTimeText;
    private PackageUpdateUtil packageUpdateUtil;
    private DisplayImageOptions displayImageOptions;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_service_detail);
        Intent intent = getIntent();
        serviceCode = intent.getLongExtra("serviceCode", 0);
        resAcvitityname = intent.getStringExtra("resAcvitityname");
        mLayoutInflater = getLayoutInflater();
        new ArrayList<CommodityInfo>();
        arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
        arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
        serviceImageShowLinearlayout = (LinearLayout) findViewById(R.id.service_image_show_linearlayout);
        serviceDetailNameText = (TextView) findViewById(R.id.service_detail_name_text);
        serviceDetailServiceTimeText = (TextView) findViewById(R.id.service_detail_service_time_text);
        seviceDetailServiceFrquencyDivideView = findViewById(R.id.service_detail_service_frquency_divide_view);
        serviceDetailServiceFrquencyRelativeLayout = (RelativeLayout) findViewById(R.id.service_detail_service_frquency_relativelayout);
        serviceDetailServiceFrquencyText = (TextView) findViewById(R.id.service_detail_service_frquency_text);
        serviceDetailServiceUnitPriceText = (TextView) findViewById(R.id.service_detail_service_unit_price_text);
        serviceDetailServiceIntroudctionText = (TextView) findViewById(R.id.service_detail_service_introduction_text);
        categoryID = intent.getStringExtra("CategoryID");
        categroyName = intent.getStringExtra("CategoryName");
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class ServiceDetailActivityHandler extends Handler {
        private final ServiceDetailActivity serviceDetailActivity;

        private ServiceDetailActivityHandler(ServiceDetailActivity activity) {
            WeakReference<ServiceDetailActivity> weakReference = new WeakReference<ServiceDetailActivity>(activity);
            serviceDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (serviceDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 1) {
                if (serviceDetailActivity.imageCount == 0)
                    serviceDetailActivity.serviceImageShowLinearlayout.setVisibility(View.GONE);
                else
                    serviceDetailActivity.CreateServiceImageView();
                if (serviceDetailActivity.serviceInfo.getServiceDescribe() != null && !(("").equals(serviceDetailActivity.serviceInfo.getServiceDescribe()))) {
                    serviceDetailActivity.CreateServiceIntroudction();
                }
                serviceDetailActivity.setFavoriteStatus(serviceDetailActivity.serviceInfo.getFavoriteID());
                serviceDetailActivity.CreateServiceNameTableRow();
                serviceDetailActivity.CreateServicePriceTableRow();
            } else if (msg.what == 0)
                DialogUtil.createShortDialog(serviceDetailActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == 3)
                DialogUtil.createShortDialog(serviceDetailActivity, msg.obj.toString());
            else if (msg.what == 4) {
                DialogUtil.createShortDialog(serviceDetailActivity,
                        msg.obj.toString());
                serviceDetailActivity.setFavoriteStatus(serviceDetailActivity.serviceInfo.getFavoriteID());
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(serviceDetailActivity, serviceDetailActivity.getString(R.string.login_error_message));
                serviceDetailActivity.userinfoApplication.exitForLogin(serviceDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + serviceDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(serviceDetailActivity);
                serviceDetailActivity.packageUpdateUtil = new PackageUpdateUtil(serviceDetailActivity, serviceDetailActivity.mHandler, fileCache, downloadFileUrl, false, serviceDetailActivity.userinfoApplication);
                serviceDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                serviceDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = serviceDetailActivity.getFileStreamPath(filename);
                file.getName();
                serviceDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (serviceDetailActivity.requestWebServiceThread != null) {
                serviceDetailActivity.requestWebServiceThread.interrupt();
                serviceDetailActivity.requestWebServiceThread = null;
            }
        }
    }

    private void setFavoriteStatus(int favoriteID) {
        if (favoriteID > 0) {
            ((Button) findViewById(R.id.cancel_favorite_button)).setVisibility(View.VISIBLE);
            ((Button) findViewById(R.id.cancel_favorite_button)).setOnClickListener(this);
            ((Button) findViewById(R.id.add_favorite_button)).setVisibility(View.GONE);

        } else {
            ((Button) findViewById(R.id.add_favorite_button)).setVisibility(View.VISIBLE);
            ((Button) findViewById(R.id.add_favorite_button)).setOnClickListener(this);
            ((Button) findViewById(R.id.cancel_favorite_button)).setVisibility(View.GONE);
        }
    }

    private void CreateServiceImageView() {
        if (null != serviceInfo.getThumbnail() && !(("").equals(serviceInfo.getThumbnail()))) {
            String[] imageUrlArray = serviceInfo.getThumbnail().trim().split(",");
            for (int i = 0; i < imageUrlArray.length; i++) {
                childView = mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
                final ImageView companyImage = (ImageView) childView.findViewById(R.id.company_image);
                companyImage.setScaleType(ScaleType.CENTER);
                final String imageURL = imageUrlArray[i];
                companyImage.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        String originalImageUrl = imageURL.split("&")[0];
                        new OrigianlImageView(ServiceDetailActivity.this, companyImage, originalImageUrl).showOrigianlImage();
                    }
                });
                imageLoader.displayImage(imageUrlArray[i], companyImage, displayImageOptions);
                mViewList.add(childView);
            }
        }
        createServiceViewPager(mViewList);
    }

    // 显示服务详细的名称和次数 时间
    private void CreateServiceNameTableRow() {
        serviceDetailNameText.setText(serviceInfo.getServiceName());
        // 如果有子服务，则显示子服务的名称 和 服务时间列表
        if (serviceInfo.isHasSubService()) {
            TableLayout serviceNameTable = (TableLayout) findViewById(R.id.service_name);
            for (SubService subService : serviceInfo.getSubServiceList()) {
                View subServiceView = mLayoutInflater.inflate(R.xml.sub_service_list_item, null);
                TextView subServiceNameView = (TextView) subServiceView.findViewById(R.id.sub_service_name);
                TextView subServiceTimeView = (TextView) subServiceView.findViewById(R.id.sub_service_spend_time);
                subServiceNameView.setText(subService.getSubServiceName());
                subServiceTimeView.setText(subService.getSubServiceSpendTime() + "分钟");
                serviceNameTable.addView(subServiceView);
            }
        } else {
            findViewById(R.id.service_detail_service_time_divide_view).setVisibility(View.VISIBLE);
            findViewById(R.id.service_detail_service_time_relativelayout).setVisibility(View.VISIBLE);
            serviceDetailServiceTimeText.setText(serviceInfo.getServiceSpendTime() + getResources().getString(R.string.time_str));
            if (serviceInfo.getServiceCourseFrequency() != 0) {
                seviceDetailServiceFrquencyDivideView.setVisibility(View.VISIBLE);
                serviceDetailServiceFrquencyRelativeLayout.setVisibility(View.VISIBLE);
                serviceDetailServiceFrquencyText.setText(serviceInfo.getServiceCourseFrequency() + "次");
            }
        }

    }

    // 显示服务详情的单价和优惠价
    private void CreateServicePriceTableRow() {
        String formatUnitPrice = NumberFormatUtil.currencyFormat(serviceInfo
                .getUnitPrice());
        serviceDetailServiceUnitPriceText.setText(userinfoApplication
                .getAccountInfo().getCurrency() + formatUnitPrice);
    }

    // 显示服务详情的介绍
    private void CreateServiceIntroudction() {
        TableLayout serviceIntroducetableLayout = (TableLayout) findViewById(R.id.service_introduction);
        if (serviceInfo.getServiceDescribe() != null && !("").equals(serviceInfo.getServiceDescribe())) {
            serviceIntroducetableLayout.setVisibility(View.VISIBLE);
            serviceDetailServiceIntroudctionText.setText(serviceInfo.getServiceDescribe());
        }
    }

    // 显示服务详情的大图
    private void createServiceViewPager(List<View> mViewList) {
        imageCount = mViewList.size();
        arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
        if (imageCount == 1) {
            arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
        } else {
            arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
        }
        viewPager = (ViewPager) findViewById(R.id.commodity_image_viewpager);
        PagerAdapter = new ViewPagerAdapter(mViewList);
        viewPager.setAdapter(PagerAdapter);
        viewPager.setOnPageChangeListener(new OnPageChangeListener() {

            @Override
            public void onPageSelected(int position) {
                if (position == 0) {
                    arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
                } else {
                    arrowLeft.setBackgroundResource(R.drawable.arrow_left_red);
                }
                if (position == imageCount - 1) {
                    arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
                } else {
                    arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
                }
            }

            @Override
            public void onPageScrolled(int arg0, float arg1, int arg2) {
                // TODO Auto-generated method stub

            }

            @Override
            public void onPageScrollStateChanged(int arg0) {
                // TODO Auto-generated method stub

            }
        });

    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "getServiceDetailByServiceCode_2_1";
                String endPoint = "service";
                JSONObject serviceDetailJson = new JSONObject();
                try {
                    serviceDetailJson.put("ProductCode", serviceCode);
                    serviceDetailJson.put("ImageWidth", userinfoApplication.getScreenWidth());
                    serviceDetailJson.put("ImageHeight", (userinfoApplication.getScreenWidth()) * 0.75);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, serviceDetailJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
                }
                if (serverRequestResult == null || serverRequestResult.equals(""))
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
                        JSONObject serviceDetail = null;
                        try {
                            serviceDetail = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                        }
                        if (serviceDetail != null) {
                            serviceInfo = new ServiceInfo();
                            long serviceCode = 0;
                            String serviceName = "";
                            String courseFrequency = "";
                            int serviceSpendTime = 0;
                            String serviceDescribe = "";
                            String promotionPrice = "-1";
                            String unitPrice = "0";
                            int favoriteID = 0;
                            int marketingPolicy = 0;
                            boolean hasSubService = false;
                            List<SubService> subServiceList = null;
                            try {
                                if (serviceDetail.has("ServiceCode"))
                                    serviceCode = serviceDetail.getLong("ServiceCode");
                                if (serviceDetail.has("ServiceName"))
                                    serviceName = serviceDetail.getString("ServiceName");
                                if (serviceDetail.has("CourseFrequency"))
                                    courseFrequency = serviceDetail.getString("CourseFrequency");
                                if (serviceDetail.has("SpendTime"))
                                    serviceSpendTime = serviceDetail.getInt("SpendTime");
                                if (serviceDetail.has("Describe"))
                                    serviceDescribe = serviceDetail.getString("Describe");
                                if (serviceDetail.has("PromotionPrice"))
                                    promotionPrice = serviceDetail.getString("PromotionPrice");
                                if (serviceDetail.has("UnitPrice"))
                                    unitPrice = serviceDetail.getString("UnitPrice");
                                if (serviceDetail.has("FavoriteID"))
                                    favoriteID = serviceDetail.getInt("FavoriteID");
                                if (serviceDetail.has("MarketingPolicy"))
                                    marketingPolicy = serviceDetail.getInt("MarketingPolicy");
                                if (serviceDetail.has("HasSubServices"))
                                    hasSubService = serviceDetail.getBoolean("HasSubServices");
                                imageCount = serviceDetail.getInt("ImageCount");
                                StringBuffer serviceImageUrl = new StringBuffer();
                                if (!serviceDetail.isNull("ServiceImage")) {
                                    JSONArray serviceImageJson = serviceDetail.getJSONArray("ServiceImage");
                                    for (int j = 0; j < serviceImageJson
                                            .length(); j++) {
                                        serviceImageUrl.append(serviceImageJson
                                                .get(j) + ",");
                                    }
                                }
                                serviceInfo.setThumbnail(serviceImageUrl.toString());
                                //如果有子服务
                                if (hasSubService) {
                                    if (serviceDetail.has("SubServices")) {
                                        JSONArray subServiceJsonArray = serviceDetail
                                                .getJSONArray("SubServices");
                                        subServiceList = new ArrayList<SubService>();
                                        for (int i = 0; i < subServiceJsonArray
                                                .length(); i++) {
                                            JSONObject subServiceObject = subServiceJsonArray.getJSONObject(i);
                                            SubService subService = new SubService();
                                            String subServiceName = "";
                                            if (subServiceObject.has("SubServiceName"))
                                                subServiceName = subServiceObject.getString("SubServiceName");
                                            int subServiceSpendTime = 0;
                                            if (subServiceObject.has("SpendTime"))
                                                subServiceSpendTime = subServiceObject.getInt("SpendTime");
                                            subService.setSubServiceName(subServiceName);
                                            subService.setSubServiceSpendTime(subServiceSpendTime);
                                            subServiceList.add(subService);
                                        }
                                    }
                                }
                            } catch (JSONException e) {
                                // TODO Auto-generated catch block
                                e.printStackTrace();
                            }
                            serviceInfo.setServiceCode(serviceCode);
                            serviceInfo.setServiceName(serviceName);
                            serviceInfo.setServiceCourseFrequency(Integer.valueOf(courseFrequency));
                            serviceInfo.setServiceSpendTime(serviceSpendTime);
                            serviceInfo.setServiceDescribe(serviceDescribe);
                            serviceInfo.setPromotionPrice(promotionPrice);
                            serviceInfo.setUnitPrice(unitPrice);
                            serviceInfo.setMarketingPolicy(marketingPolicy);
                            serviceInfo.setFavoriteID(favoriteID);
                            serviceInfo.setHasSubService(hasSubService);
                            serviceInfo.setSubServiceList(subServiceList);
                        }
                        mHandler.sendEmptyMessage(1);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.obj = message;
                        msg.what = 3;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();

    }

    private void addFavorite(String productCode) {
        final String mProductCode = productCode;
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "addFavorite";
                String endPoint = "account";
                JSONObject addFavoriteJsonParam = new JSONObject();
                try {
                    addFavoriteJsonParam.put("ProductType", Constant.SERVICE_TYPE);// 服务
                    addFavoriteJsonParam.put("ProductCode", mProductCode);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addFavoriteJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject addFavoriteJson = null;
                    JSONObject favoriteJson = null;
                    try {
                        addFavoriteJson = new JSONObject(serverRequestResult);
                        code = addFavoriteJson.getInt("Code");
                        favoriteJson = addFavoriteJson.getJSONObject("Data");
                    } catch (JSONException e) {
                    }
                    String returnMessage = "";
                    if (code == 1) {
                        int favoriteID = 0;
                        if (favoriteJson.has("FavoriteID")) {
                            try {
                                favoriteID = favoriteJson.getInt("FavoriteID");
                                returnMessage = addFavoriteJson.getString("Message");
                            } catch (JSONException e) {
                                favoriteID = 0;
                                returnMessage = "";
                            }
                        }
                        serviceInfo.setFavoriteID(favoriteID);
                        mHandler.obtainMessage(4, returnMessage).sendToTarget();
                        ;
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        try {
                            returnMessage = addFavoriteJson.getString("Message");
                        } catch (JSONException e) {
                            returnMessage = "";
                        }
                        mHandler.obtainMessage(3, returnMessage).sendToTarget();
                    }

                }
            }
        };
        requestWebServiceThread.start();

    }

    private void delFavorite(String favoriteID) {
        final String mFavoriteID = favoriteID;
        Dialog dialog = new AlertDialog.Builder(this,
                R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.delete_favorite_message)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                // TODO Auto-generated method stub
                                requestWebServiceThread = new Thread() {
                                    @Override
                                    public void run() {
                                        // TODO Auto-generated method stub
                                        String methodName = "delFavorite";
                                        String endPoint = "account";
                                        JSONObject delFavoriteJsonParam = new JSONObject();
                                        try {
                                            delFavoriteJsonParam.put("FavoriteID", mFavoriteID);
                                        } catch (JSONException e) {
                                        }
                                        String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, delFavoriteJsonParam.toString(), userinfoApplication);
                                        if (serverRequestResult == null || serverRequestResult.equals(""))
                                            mHandler.sendEmptyMessage(2);
                                        else {

                                            int code = 0;
                                            JSONObject delFavoriteJson = null;
                                            try {
                                                delFavoriteJson = new JSONObject(serverRequestResult);
                                                code = delFavoriteJson.getInt("Code");
                                            } catch (JSONException e) {
                                            }
                                            String returnMessage = "";
                                            if (code == 1) {
                                                if (delFavoriteJson.has("Message")) {
                                                    try {
                                                        returnMessage = delFavoriteJson.getString("Message");
                                                    } catch (JSONException e) {
                                                        returnMessage = "";
                                                    }
                                                }
                                                serviceInfo.setFavoriteID(0);
                                                mHandler.obtainMessage(4, returnMessage).sendToTarget();
                                            } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                                                mHandler.sendEmptyMessage(code);
                                            else {
                                                try {
                                                    returnMessage = delFavoriteJson.getString("Message");
                                                } catch (JSONException e) {
                                                    returnMessage = "";
                                                }
                                                mHandler.obtainMessage(3, returnMessage).sendToTarget();
                                            }
                                        }
                                    }
                                };
                                requestWebServiceThread.start();
                            }
                        })
                .setNegativeButton(getString(R.string.delete_cancel),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                // TODO Auto-generated method stub
                                dialog.dismiss();
                                dialog = null;
                            }
                        }).create();
        dialog.show();
        dialog.setCancelable(false);

    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            Intent destIntent = null;
            if (resAcvitityname.equals("FavoriteListActivity")) {
                destIntent = new Intent(this, CustomerServicingActivity.class);
                destIntent.putExtra("currentItem", 3);
            } else if (resAcvitityname.equals("HomePageActivity")) {
                destIntent = new Intent(this, HomePageActivity.class);
            } else {
                destIntent = new Intent(this, ServiceListActivity.class);
                destIntent.putExtra("CategoryID", categoryID);
                destIntent.putExtra("CategoryName", categroyName);
            }
            startActivity(destIntent);
            this.finish();
            System.gc();
        }
        return super.onKeyUp(keyCode, event);
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.add_favorite_button:
                addFavorite(String.valueOf(serviceCode));
                break;
            case R.id.cancel_favorite_button:
                delFavorite(String.valueOf(serviceInfo.getFavoriteID()));
                break;
            default:
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
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
