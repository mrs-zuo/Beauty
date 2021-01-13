package cn.com.antika.business;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

import java.io.File;
import java.lang.ref.WeakReference;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CustomerRecord;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DateButton;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

public class EditCustomerRecordActivity extends BaseActivity implements
        OnClickListener {
    private EditCustomerRecordActivityHandler mHandler = new EditCustomerRecordActivityHandler(this);
    private EditText recordTimeText;
    private EditText recordProblemText;
    private EditText recordSuggestionText;
    private ImageButton updateCustomerRecordBtn;
    private ImageButton deleteCustomerRecordBtn;
    private RelativeLayout changeCustomerScanStatusLayout;
    private ImageButton customerScanStatusBtn;
    private int customerScanStatus;
    private String customerId = "";
    private CustomerRecord customerRecord = null;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private int userRole;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_edit_customer_record);
        recordTimeText = (EditText) findViewById(R.id.edit_record_time);
        recordProblemText = (EditText) findViewById(R.id.edit_record_problem);
        recordSuggestionText = (EditText) findViewById(R.id.editrecord_suggestion);
        updateCustomerRecordBtn = (ImageButton) findViewById(R.id.edit_customer_record_make_sure_btn);
        deleteCustomerRecordBtn = (ImageButton) findViewById(R.id.delete_customer_record_btn);
        customerScanStatusBtn = (ImageButton) findViewById(R.id.customer_scan_status_image);
        customerScanStatusBtn.setOnClickListener(this);
        changeCustomerScanStatusLayout = (RelativeLayout) findViewById(R.id.change_customer_scan_status_layout);
        changeCustomerScanStatusLayout.setOnClickListener(this);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        Intent intent = getIntent();
        customerRecord = (CustomerRecord) intent
                .getSerializableExtra("customerRecord");
        customerId = intent.getStringExtra("customerId");
        recordTimeText.setText(customerRecord.getRecordTime());
        recordTimeText.setInputType(InputType.TYPE_NULL);
        recordTimeText.setOnClickListener(this);
        recordProblemText.setText(customerRecord.getProblem());
        recordSuggestionText.setText(customerRecord.getSuggestion());
        if (customerRecord.getIsVisible().equals("true")) {
            customerScanStatus = 1;
            customerScanStatusBtn
                    .setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
        } else {
            customerScanStatus = 0;
            customerScanStatusBtn
                    .setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
        }

        updateCustomerRecordBtn.setOnClickListener(this);
        deleteCustomerRecordBtn.setOnClickListener(this);
        userRole = getIntent().getIntExtra("userRole", userRole);
        userinfoApplication = UserInfoApplication.getInstance();
    }

    private static class EditCustomerRecordActivityHandler extends Handler {
        private final EditCustomerRecordActivity editCustomerRecordActivity;

        private EditCustomerRecordActivityHandler(EditCustomerRecordActivity activity) {
            WeakReference<EditCustomerRecordActivity> weakReference = new WeakReference<EditCustomerRecordActivity>(activity);
            editCustomerRecordActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (editCustomerRecordActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editCustomerRecordActivity.progressDialog != null) {
                editCustomerRecordActivity.progressDialog.dismiss();
                editCustomerRecordActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                Intent intent = new Intent(editCustomerRecordActivity,
                        CustomerRecordActivity.class);
                intent.putExtra("USER_ROLE", editCustomerRecordActivity.userRole);
                intent.putExtra("customerId", editCustomerRecordActivity.customerId);
                editCustomerRecordActivity.startActivity(intent);
                editCustomerRecordActivity.finish();
            } else if (msg.what == 0)
                DialogUtil.createMakeSureDialog(
                        editCustomerRecordActivity, "提示信息", "操作失败，请重试");
            else if (msg.what == 2)
                DialogUtil.createShortDialog(editCustomerRecordActivity,
                        "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editCustomerRecordActivity, editCustomerRecordActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editCustomerRecordActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editCustomerRecordActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editCustomerRecordActivity);
                editCustomerRecordActivity.packageUpdateUtil = new PackageUpdateUtil(editCustomerRecordActivity, editCustomerRecordActivity.mHandler, fileCache, downloadFileUrl, false, editCustomerRecordActivity.userinfoApplication);
                editCustomerRecordActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                editCustomerRecordActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = editCustomerRecordActivity.getFileStreamPath(filename);
                file.getName();
                editCustomerRecordActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (editCustomerRecordActivity.requestWebServiceThread != null) {
                editCustomerRecordActivity.requestWebServiceThread.interrupt();
                editCustomerRecordActivity.requestWebServiceThread = null;
            }
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        progressDialog = new ProgressDialog(this,
                R.style.CustomerProgressDialog);
        if (view.getId() == R.id.change_customer_scan_status_layout
                || view.getId() == R.id.customer_scan_status_image) {
            if (customerScanStatus == 1) {
                customerScanStatus = 0;
                customerScanStatusBtn
                        .setBackgroundResource(R.drawable.customer_scan_record_status_gray_icon);
            } else {
                customerScanStatus = 1;
                customerScanStatusBtn
                        .setBackgroundResource(R.drawable.customer_scan_record_status_blue_icon);
            }
        } else if (view.getId() == R.id.edit_customer_record_make_sure_btn) {
            if (recordProblemText == null
                    || recordProblemText.getText().toString().equals(""))
                DialogUtil.createMakeSureDialog(this, "提示信息", "请输入咨询信息");
            else {
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.show();
				/*requestWebServiceThread = new Thread() {
					@Override
					public void run() {
						// TODO Auto-generated method stub
						String methodName = "updateRecord";
						String endPoint = "Record.asmx";
						Map<String, String> paramMap = new HashMap<String, String>();
						Intent intent = getIntent();
						String customerIdStr = intent
								.getStringExtra("customerId");
						paramMap.put("CustomerID", customerIdStr);
						paramMap.put("RecordID",
								String.valueOf(customerRecord.getRecordId()));
						paramMap.put("AccountID", String
								.valueOf(userinfoApplication.getAccountInfo()
										.getAccountId()));
						paramMap.put("RecordTime", recordTimeText.getText()
								.toString());
						paramMap.put("Problem", recordProblemText.getText()
								.toString());
						paramMap.put("Suggestion", recordSuggestionText
								.getText().toString());
						paramMap.put("IsVisible",
								String.valueOf(customerScanStatus));
						SoapObject object = WebServiceUtil
								.requestWebServiceWithSSL(endPoint, methodName,
										paramMap);
						if (object == null)
							mHandler.sendEmptyMessage(2);
						else {
							SoapObject soapChilds1 = (SoapObject) object
									.getProperty(0);
							SoapObject soapChilds2 = (SoapObject) soapChilds1
									.getProperty(0);
							String flag = soapChilds2.getProperty("Flag")
									.toString();
							if (null != flag && ("1").equals(flag))
								mHandler.sendEmptyMessage(1);

							else
								mHandler.sendEmptyMessage(0);
						}
					}
				};
				requestWebServiceThread.start();*/
            }
        } else if (view.getId() == R.id.delete_customer_record_btn) {
            Dialog dialog = new AlertDialog.Builder(this,
                    R.style.CustomerAlertDialog)
                    .setTitle(getString(R.string.delete_dialog_title))
                    .setMessage(R.string.delete_customer_record)
                    .setPositiveButton(getString(R.string.delete_confirm),
                            new DialogInterface.OnClickListener() {

                                @Override
                                public void onClick(DialogInterface dialog,
                                                    int which) {
                                    dialog.dismiss();
                                    // TODO Auto-generated method stub
									/*progressDialog.setMessage(getString(R.string.please_wait));
									progressDialog.show();
									requestWebServiceThread = new Thread() {
										@Override
										public void run() {
											// TODO Auto-generated method stub
											String methodName = "deleteRecord";
											String endPoint = "Record.asmx";
											Map<String, String> paramMap = new HashMap<String, String>();
											paramMap.put("RecordID", String
													.valueOf(customerRecord
															.getRecordId()));
											paramMap.put(
													"AccountID",
													String.valueOf(userinfoApplication
															.getAccountInfo()
															.getAccountId()));
											SoapObject object = WebServiceUtil
													.requestWebServiceWithSSL(
															endPoint,
															methodName,
															paramMap);
											if (object == null)
												mHandler.sendEmptyMessage(2);
											else {
												SoapObject soapChilds1 = (SoapObject) object
														.getProperty(0);
												SoapObject soapChilds2 = (SoapObject) soapChilds1
														.getProperty(0);
												String flag = soapChilds2
														.getProperty("Flag")
														.toString();
												if (null != flag
														&& ("1").equals(flag)) {
													mHandler.sendEmptyMessage(1);
												} else {
													mHandler.sendEmptyMessage(0);
												}
											}
										}
									};
									requestWebServiceThread.start();*/

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

        } else if (view.getId() == R.id.edit_record_time) {
            DateButton dateButton = new DateButton(this, (EditText) view,
                    Constant.DATE_DIALOG_SHOW_TYPE_DEFAULT, null);
            dateButton.datePickerDialog();
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
