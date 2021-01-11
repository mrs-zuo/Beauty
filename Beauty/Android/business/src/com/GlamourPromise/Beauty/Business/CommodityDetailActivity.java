package com.GlamourPromise.Beauty.Business;

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

import com.GlamourPromise.Beauty.adapter.ViewPagerAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CommodityInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.OrigianlImageView;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

@SuppressLint("ResourceType")
public class CommodityDetailActivity extends BaseActivity implements
        OnClickListener {
    private CommodityDetailActivityHandler mHandler = new CommodityDetailActivityHandler(this);
    private long commodityCode;
    private String resAcvitityname;
    private LayoutInflater mLayoutInflater;
    private Thread requestWebServiceThread;
    private CommodityInfo commodityInfo;
    private List<View> mViewList = new ArrayList<View>();
    private View childView;
    private ViewPager viewPager;
    private ViewPagerAdapter PagerAdapter;
    private ImageView arrowRight;
    private ImageView arrowLeft;
    private int imageCount;
    private ImageLoader imageLoader;
    private DisplayImageOptions displayImageOptions;
    private LinearLayout commodityImageShowLinearlayout;
    private UserInfoApplication userinfoApplication;
    private String categoryID, categoryName;
    // 商品详情
    private TextView commodityDetailNameText;
    private TextView commodityDetailCommoditySpecificationText;
    private TextView commodityDetailCommodityUnitPriceText;
    private TextView commodityDetailCommodityIntroudctionText;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_commodity_detail);
        Intent intent = getIntent();
        commodityCode = intent.getLongExtra("commodityCode", 0);
        resAcvitityname = intent.getStringExtra("resAcvitityname");
        mLayoutInflater = getLayoutInflater();
        arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
        arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
        commodityImageShowLinearlayout = (LinearLayout) findViewById(R.id.commdidty_image_show_linearlayout);
        commodityDetailNameText = (TextView) findViewById(R.id.commodity_detail_name_text);
        commodityDetailCommoditySpecificationText = (TextView) findViewById(R.id.commodity_detail_commodity_specification_text);
        commodityDetailCommodityUnitPriceText = (TextView) findViewById(R.id.commodity_detail_commodity_unit_price_text);
        commodityDetailCommodityIntroudctionText = (TextView) findViewById(R.id.commodity_detail_commodity_introduction_text);
        categoryID = intent.getStringExtra("CategoryID");
        categoryName = intent.getStringExtra("CategoryName");
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class CommodityDetailActivityHandler extends Handler {
        private final CommodityDetailActivity commodityDetailActivity;

        private CommodityDetailActivityHandler(CommodityDetailActivity activity) {
            WeakReference<CommodityDetailActivity> weakReference = new WeakReference<CommodityDetailActivity>(activity);
            commodityDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (commodityDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 1) {
                commodityDetailActivity.CreateCommodityNameTableRow();
                commodityDetailActivity.CreateCommodityPriceTableRow();
                commodityDetailActivity.CreateCommodityStockQuantity();
                if (commodityDetailActivity.imageCount == 0)
                    commodityDetailActivity.commodityImageShowLinearlayout.setVisibility(View.GONE);
                else
                    commodityDetailActivity.CreateCommodityImageView();
                if (commodityDetailActivity.commodityInfo.getDescribe() != "") {
                    commodityDetailActivity.createCommodityIntroudction();
                }
                commodityDetailActivity.setFavoriteStatus(commodityDetailActivity.commodityInfo.getFavoriteID());
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(commodityDetailActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == 3)
                DialogUtil.createShortDialog(commodityDetailActivity, msg.obj.toString());
            else if (msg.what == 4) {
                DialogUtil.createShortDialog(commodityDetailActivity, msg.obj.toString());
                commodityDetailActivity.setFavoriteStatus(commodityDetailActivity.commodityInfo.getFavoriteID());
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(commodityDetailActivity, commodityDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(commodityDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + commodityDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(commodityDetailActivity);
                commodityDetailActivity.packageUpdateUtil = new PackageUpdateUtil(commodityDetailActivity, commodityDetailActivity.mHandler, fileCache, downloadFileUrl, false, commodityDetailActivity.userinfoApplication);
                commodityDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                commodityDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = commodityDetailActivity.getFileStreamPath(filename);
                file.getName();
                commodityDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (commodityDetailActivity.requestWebServiceThread != null) {
                commodityDetailActivity.requestWebServiceThread.interrupt();
                commodityDetailActivity.requestWebServiceThread = null;
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

    private void CreateCommodityImageView() {
        if (null != commodityInfo.getThumbnailUrl() && !(("").equals(commodityInfo.getThumbnailUrl()))) {
            String[] imageUrlArray = commodityInfo.getThumbnailUrl().trim().split(",");
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
                        new OrigianlImageView(CommodityDetailActivity.this, companyImage, originalImageUrl).showOrigianlImage();
                    }
                });
                imageLoader.displayImage(imageUrlArray[i], companyImage, displayImageOptions);
                mViewList.add(childView);
            }
        }
        createCommodityViewPager(mViewList);
    }

    // 显示商品名称和规格
    private void CreateCommodityNameTableRow() {
        commodityDetailNameText.setText(commodityInfo.getCommodityName());
        commodityDetailCommoditySpecificationText.setText(commodityInfo.getSpecification());
    }

    // 显示商品的单价和优惠价
    private void CreateCommodityPriceTableRow() {
        String formatUnitPrice = NumberFormatUtil.currencyFormat(commodityInfo.getUnitPrice());
        commodityDetailCommodityUnitPriceText.setText(userinfoApplication.getAccountInfo().getCurrency() + formatUnitPrice);
    }

    private void CreateCommodityStockQuantity() {
        //库存类型
        int stockCalcType = commodityInfo.getStockCalcType();
        TextView stockCalcTypeText = (TextView) findViewById(R.id.commodity_detail_commodity_stock_calc_type_text);
        switch (stockCalcType) {
            case 1:
                stockCalcTypeText.setText("(普通库存)");
                break;
            case 2:
                stockCalcTypeText.setText("(不计库存)");
                break;
            case 3:
                stockCalcTypeText.setText("(超卖库存)");
                break;
            default:
                stockCalcTypeText.setText("");
                break;
        }
        ((View) findViewById(R.id.commodity_detail_commodity_stock_quantity_divide_view))
                .setVisibility(View.VISIBLE);
        ((RelativeLayout) findViewById(R.id.commodity_detail_commodity_stock_quantity_relativelayout))
                .setVisibility(View.VISIBLE);
        ((TextView) findViewById(R.id.commodity_detail_commodity_stock_quantity_text))
                .setText(commodityInfo.getStockQuantity());
    }

    private void createCommodityIntroudction() {
        TableLayout commodityDescribtiontableLayout = (TableLayout) findViewById(R.id.commodity_introduction);
        if (commodityInfo.getDescribe() != null && !("").equals(commodityInfo.getDescribe())) {
            commodityDescribtiontableLayout.setVisibility(View.VISIBLE);
            commodityDetailCommodityIntroudctionText.setText(commodityInfo.getDescribe());
        }
    }

    private void createCommodityViewPager(List<View> mViewList) {
        imageCount = mViewList.size();
        arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
        if (imageCount == 1) {
            arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
        } else {
            arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
        }
        viewPager = (ViewPager) findViewById(R.id.commodity_image_viewpager);
        PagerAdapter = new com.GlamourPromise.Beauty.adapter.ViewPagerAdapter(
                mViewList);
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
                    arrowRight
                            .setBackgroundResource(R.drawable.arrow_right_gray);
                } else {
                    arrowRight
                            .setBackgroundResource(R.drawable.arrow_right_red);
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
                String methodName = "getCommodityDetailByCommodityCode";
                String endPoint = "commodity";
                JSONObject commodityDetailJsonParam = new JSONObject();
                try {
                    commodityDetailJsonParam.put("ProductCode", String.valueOf(commodityCode));
                    commodityDetailJsonParam.put("ImageWidth", userinfoApplication.getScreenWidth());
                    commodityDetailJsonParam.put("ImageHeight", (userinfoApplication.getScreenWidth()) * 0.75);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, commodityDetailJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                    } catch (JSONException e) {
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
                        JSONObject commodityDetail = null;
                        try {
                            commodityDetail = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                        }
                        if (commodityDetail != null) {
                            commodityInfo = new CommodityInfo();
                            long commodityCode = 0;
                            String commodityName = "";
                            String commodityDescribe = "";
                            String commodityPromotionPrice = "-1";
                            String specification = "";
                            String unitPrice = "0";
                            int stockCalcType = 0;
                            int favoriteID = 0;
                            StringBuffer commodityImageUrl = new StringBuffer();
                            try {
                                if (commodityDetail.has("CommodityCode") && !commodityDetail.isNull("CommodityCode"))
                                    commodityCode = commodityDetail.getLong("CommodityCode");
                                if (commodityDetail.has("CommodityName") && !commodityDetail.isNull("CommodityName"))
                                    commodityName = commodityDetail.getString("CommodityName");
                                if (commodityDetail.has("Describe") && !commodityDetail.isNull("Describe"))
                                    commodityDescribe = commodityDetail.getString("Describe");
                                if (commodityDetail.has("PromotionPrice") && !commodityDetail.isNull("PromotionPrice"))
                                    commodityPromotionPrice = commodityDetail.getString("PromotionPrice");
                                if (commodityDetail.has("Specification") && !commodityDetail.isNull("Specification"))
                                    specification = commodityDetail.getString("Specification");
                                if (commodityDetail.has("UnitPrice") && !commodityDetail.isNull("UnitPrice"))
                                    unitPrice = commodityDetail.getString("UnitPrice");
                                if (commodityDetail.has("ImageCount") && !commodityDetail.isNull("ImageCount"))
                                    imageCount = commodityDetail.getInt("ImageCount");
                                //库存类型  1.普通库存  2.不计库存  3.超卖库存
                                if (commodityDetail.has("StockCalcType") && !commodityDetail.isNull("StockCalcType"))
                                    stockCalcType = commodityDetail.getInt("StockCalcType");

                                if (commodityDetail.has("StockQuantity") && !commodityDetail.isNull("StockQuantity"))
                                    commodityInfo.setStockQuantity(commodityDetail.getString("StockQuantity"));
                                else
                                    commodityInfo.setStockQuantity("-1");// 无限库存
                                if (commodityDetail.has("FavoriteID") && !commodityDetail.isNull("FavoriteID"))
                                    favoriteID = commodityDetail.getInt("FavoriteID");

                                if (imageCount > 0) {
                                    if (!commodityDetail.isNull("CommodityImage")) {
                                        JSONArray commodityImageJson = commodityDetail.getJSONArray("CommodityImage");
                                        for (int j = 0; j < commodityImageJson.length(); j++) {
                                            commodityImageUrl.append(commodityImageJson.get(j) + ",");
                                        }
                                    }
                                }
                            } catch (JSONException e) {
                            }
                            commodityInfo.setCommodityCode(commodityCode);
                            commodityInfo.setCommodityName(commodityName);
                            commodityInfo.setDescribe(commodityDescribe);
                            commodityInfo.setPromotionPrice(commodityPromotionPrice);
                            commodityInfo.setThumbnailUrl(commodityImageUrl.toString());
                            commodityInfo.setSpecification(specification);
                            commodityInfo.setUnitPrice(unitPrice);
                            commodityInfo.setStockCalcType(stockCalcType);
                            commodityInfo.setFavoriteID(favoriteID);
                            mHandler.sendEmptyMessage(1);
                        }
                    } else
                        mHandler.sendEmptyMessage(code);
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
                    addFavoriteJsonParam.put("ProductType", Constant.COMMODITY_TYPE);// 服务
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
                        commodityInfo.setFavoriteID(favoriteID);
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
                                                commodityInfo.setFavoriteID(0);
                                                mHandler.obtainMessage(4, returnMessage).sendToTarget();
                                                ;
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
                destIntent = new Intent(this, CommodityListActivity.class);
                destIntent.putExtra("CategoryID", categoryID);
                destIntent.putExtra("CategoryName", categoryName);
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
                addFavorite(String.valueOf(commodityCode));
                break;
            case R.id.cancel_favorite_button:
                delFavorite(String.valueOf(commodityInfo.getFavoriteID()));
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
            mHandler = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }

}
