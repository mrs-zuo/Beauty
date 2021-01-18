package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ScrollView;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CustomerVocation;
import com.GlamourPromise.Beauty.bean.CustomerVocationEditAnswer;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.RecordTemplate;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.timer.DialogTimerTask;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.List;
import java.util.Timer;

@SuppressLint("ResourceType")
public class EditCustomerVocationActivity extends BaseActivity implements
        OnClickListener {
    private EditCustomerVocationActivityHandler mHandler = new EditCustomerVocationActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private CustomerVocation customerVocation;
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    private List<CustomerVocationEditAnswer> customerVocationEditAnswerList;
    private TextView editCustomerVocationAnswerTitleText;
    private LayoutInflater layoutInflater;
    private ScrollView editCustomerVocationScrollView;
    private Button submitBtn, cancelBtn;
    private RecordTemplate recordTemplate;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_edit_customer_vocation);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class EditCustomerVocationActivityHandler extends Handler {
        private final EditCustomerVocationActivity editCustomerVocationActivity;

        private EditCustomerVocationActivityHandler(EditCustomerVocationActivity activity) {
            WeakReference<EditCustomerVocationActivity> weakReference = new WeakReference<EditCustomerVocationActivity>(activity);
            editCustomerVocationActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (editCustomerVocationActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (editCustomerVocationActivity.progressDialog != null) {
                editCustomerVocationActivity.progressDialog.dismiss();
                editCustomerVocationActivity.progressDialog = null;
            }
            if (editCustomerVocationActivity.requestWebServiceThread != null) {
                editCustomerVocationActivity.requestWebServiceThread.interrupt();
                editCustomerVocationActivity.requestWebServiceThread = null;
            }
            if (msg.what == 1) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(editCustomerVocationActivity, "提示信息", "专业信息编辑成功！");
                alertDialog.show();
                Intent destIntent = new Intent(editCustomerVocationActivity, CustomerRecordActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("recordTemplate", editCustomerVocationActivity.recordTemplate);
                destIntent.putExtras(bundle);
                editCustomerVocationActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, editCustomerVocationActivity.dialogTimer, editCustomerVocationActivity, destIntent);
                editCustomerVocationActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 0) {
                DialogUtil.createMakeSureDialog(editCustomerVocationActivity, "提示信息", "编辑出错，请重试！");
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(editCustomerVocationActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(editCustomerVocationActivity, editCustomerVocationActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(editCustomerVocationActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + editCustomerVocationActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(editCustomerVocationActivity);
                editCustomerVocationActivity.packageUpdateUtil = new PackageUpdateUtil(editCustomerVocationActivity, editCustomerVocationActivity.mHandler, fileCache, downloadFileUrl, false, editCustomerVocationActivity.userinfoApplication);
                editCustomerVocationActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                editCustomerVocationActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            // 包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = editCustomerVocationActivity.getFileStreamPath(filename);
                file.getName();
                editCustomerVocationActivity.packageUpdateUtil.showInstallDialog();
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
        Intent intent = getIntent();
        recordTemplate = (RecordTemplate) intent.getSerializableExtra("recordTemplate");
        editCustomerVocationAnswerTitleText = (TextView) findViewById(R.id.edit_customer_vocation_title_text);
        editCustomerVocationAnswerTitleText.setText(recordTemplate.getRecordTemplateTitle());
        editCustomerVocationScrollView = (ScrollView) findViewById(R.id.edit_customer_vocation_scorll_view);
        submitBtn = (Button) findViewById(R.id.submit_btn);
        cancelBtn = (Button) findViewById(R.id.cancel_btn);
        submitBtn.setOnClickListener(this);
        cancelBtn.setOnClickListener(this);
        customerVocation = (CustomerVocation) intent.getSerializableExtra("question");
        customerVocationEditAnswerList = (List<CustomerVocationEditAnswer>) intent.getSerializableExtra("answer");
        // 设置当前的需要编辑的问题视图
        setCurrentVocation();
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        if (view.getId() == R.id.submit_btn) {
            progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
            progressDialog.show();
            final JSONObject editAnswerJson = new JSONObject();
            try {
                editAnswerJson.put("QuestionID", customerVocation.getQuestionId());
                editAnswerJson.put("GroupID", recordTemplate.getGroupID());
                editAnswerJson.put("AnswerID", customerVocation.getAnswerId());
            } catch (JSONException e) {
            }
            // 获得回答过的所有题目的答案
            StringBuffer answerContent = new StringBuffer();
            if (customerVocation.getQuestionType() == 0) {
                answerContent.append(customerVocationEditAnswerList.get(0)
                        .getAnswerContent());
            } else if (customerVocation.getQuestionType() == 1
                    || customerVocation.getQuestionType() == 2) {
                for (CustomerVocationEditAnswer cve : customerVocationEditAnswerList) {
                    answerContent.append(cve.getIsAnswer() + "|");
                }
            }
            try {
                editAnswerJson.put("AnswerContent", answerContent.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            }
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    String methodName = "EditAnswer";
                    String endPoint = "Paper";
                    String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, editAnswerJson.toString(), userinfoApplication);
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverResultResult);
                    } catch (JSONException e1) {
                    }
                    if (serverResultResult == null || serverResultResult.equals(""))
                        mHandler.sendEmptyMessage(2);
                    else {
                        int code = 0;
                        try {
                            code = resultJson.getInt("Code");
                        } catch (JSONException e) {
                            code = 0;
                        }
                        if (code == 1) {
                            mHandler.sendEmptyMessage(1);
                        } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                            mHandler.sendEmptyMessage(code);
                        else
                            mHandler.sendEmptyMessage(0);
                    }
                }
            };
            requestWebServiceThread.start();
        } else if (view.getId() == R.id.cancel_btn) {
            AlertDialog cancelConfirmDialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                    .setTitle(getString(R.string.confirm_cancel_edit_vocation))
                    .setPositiveButton(getString(R.string.confirm),
                            new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface arg0, int arg1) {
                                    EditCustomerVocationActivity.this.finish();
                                }
                            })
                    .setNegativeButton(getString(R.string.cancel), null).show();
            cancelConfirmDialog.setCancelable(false);
        }
    }

    private void setCurrentVocation() {
        editCustomerVocationScrollView.removeAllViews();
        int questionType = customerVocation.getQuestionType();
        final View editVocationLayout = layoutInflater.inflate(R.xml.edit_vocation_list_item, null);
        final TableLayout editVocationListItemTable = (TableLayout) editVocationLayout.findViewById(R.id.customer_vocation_list_item_table);
        TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
        lp.topMargin = 20;
        lp.leftMargin = 10;
        lp.rightMargin = 10;
        editVocationListItemTable.setLayoutParams(lp);
        TextView vocationQuestionName = (TextView) editVocationLayout.findViewById(R.id.edit_vocation_question_name);
        String questionDescription = customerVocation.getQuestionDescription();
        if (questionDescription != null && !questionDescription.equals("")) {
            TextView vocationQuestionDescription = (TextView) editVocationLayout.findViewById(R.id.edit_vocation_question_description);
            vocationQuestionDescription.setText(customerVocation.getQuestionDescription());
        } else {
            editVocationLayout.findViewById(R.id.question_description_divide_view).setVisibility(View.GONE);
            editVocationLayout.findViewById(R.id.question_description_relativelayout).setVisibility(View.GONE);
        }
        String questionTypeString = "";
        // 问题类型为文本类型的
        if (questionType == 0) {
            questionTypeString = "【文本】";
            View editVocationAnswerItem = layoutInflater.inflate(R.xml.vocation_item_type_text, null);
            EditText vocationItemText = (EditText) editVocationAnswerItem.findViewById(R.id.vocation_item_text);
            vocationItemText.setText(customerVocationEditAnswerList.get(0).getAnswerContent());
            vocationItemText.addTextChangedListener(new TextWatcher() {

                @Override
                public void onTextChanged(CharSequence s, int start,
                                          int before, int count) {
                    // TODO Auto-generated method stub

                }

                @Override
                public void beforeTextChanged(CharSequence s, int start,
                                              int count, int after) {
                    // TODO Auto-generated method stub

                }

                @Override
                public void afterTextChanged(Editable s) {
                    // TODO Auto-generated method stub
                    if (s.toString() != null && !s.toString().equals(""))
                        customerVocationEditAnswerList.get(0).setAnswerContent(s.toString());
                    else
                        customerVocationEditAnswerList.get(0).setAnswerContent("");
                }
            });
            editVocationListItemTable.addView(editVocationAnswerItem);
        }
        // 问题类型为单项选择的
        else if (questionType == 1) {
            questionTypeString = "【单选】";
            for (int i = 0; i < customerVocationEditAnswerList.size(); i++) {
                final int pos = i;
                final CustomerVocationEditAnswer cve = customerVocationEditAnswerList.get(i);
                View editVocationAnswerItem = layoutInflater.inflate(R.xml.vocation_item_type_check, null);
                editVocationAnswerItem.setTag(i);
                TextView vocationItemText = (TextView) editVocationAnswerItem.findViewById(R.id.vocation_item_check_text);
                final ImageView vocationItemCheckBox = (ImageView) editVocationAnswerItem.findViewById(R.id.vocation_item_check_image);
                if (cve.getIsAnswer() == 0)
                    vocationItemCheckBox.setBackgroundResource(R.drawable.no_select_btn);
                else if (cve.getIsAnswer() == 1)
                    vocationItemCheckBox.setBackgroundResource(R.drawable.select_btn);
                vocationItemCheckBox.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        // TODO Auto-generated method stub
                        if (cve.getIsAnswer() == 0) {
                            //将不是当前位置的标识为不选中状态
                            for (int j = 0; j < editVocationListItemTable.getChildCount(); j++) {
                                if (editVocationListItemTable.getChildAt(j).getTag() != null && ((Integer) editVocationListItemTable.getChildAt(j).getTag()) != pos) {
                                    editVocationListItemTable.getChildAt(j).findViewById(R.id.vocation_item_check_image).setBackgroundResource(R.drawable.no_select_btn);
                                    customerVocationEditAnswerList.get(pos).setIsAnswer(0);
                                }
                            }
                            for (int a = 0; a < customerVocationEditAnswerList.size(); a++) {
                                if (a != pos)
                                    customerVocationEditAnswerList.get(a).setIsAnswer(0);
                                else {
                                    customerVocationEditAnswerList.get(a).setIsAnswer(1);
                                }
                            }
                            vocationItemCheckBox.setBackgroundResource(R.drawable.select_btn);
                        } else if (cve.getIsAnswer() == 1) {
                            cve.setIsAnswer(0);
                            vocationItemCheckBox.setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                });
                vocationItemText.setText(cve.getAnswerContent());
                editVocationListItemTable.addView(editVocationAnswerItem);
            }
        }
        // 问题类型为多项选择的
        else if (questionType == 2) {
            questionTypeString = "【多选】";
            for (int i = 0; i < customerVocationEditAnswerList.size(); i++) {
                final CustomerVocationEditAnswer cve = customerVocationEditAnswerList.get(i);
                View editVocationAnswerItem = layoutInflater.inflate(R.xml.vocation_item_type_check, null);
                TextView vocationItemText = (TextView) editVocationAnswerItem.findViewById(R.id.vocation_item_check_text);
                final ImageView vocationItemCheckBox = (ImageView) editVocationAnswerItem.findViewById(R.id.vocation_item_check_image);
                if (cve.getIsAnswer() == 0)
                    vocationItemCheckBox
                            .setBackgroundResource(R.drawable.no_select_btn);
                else if (cve.getIsAnswer() == 1)
                    vocationItemCheckBox.setBackgroundResource(R.drawable.select_btn);
                View vocationItemDivideView = editVocationAnswerItem.findViewById(R.id.vocation_item_check_divide_view);
                vocationItemCheckBox.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        // TODO Auto-generated method stub
                        if (cve.getIsAnswer() == 0) {
                            cve.setIsAnswer(1);
                            vocationItemCheckBox.setBackgroundResource(R.drawable.select_btn);
                        } else if (cve.getIsAnswer() == 1) {
                            cve.setIsAnswer(0);
                            vocationItemCheckBox.setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                });
                if (i == customerVocationEditAnswerList.size() - 1)
                    vocationItemDivideView.setVisibility(View.GONE);
                vocationItemText.setText(cve.getAnswerContent());
                editVocationListItemTable.addView(editVocationAnswerItem);
            }
        }
        vocationQuestionName.setText(questionTypeString + customerVocation.getQuestionName());
        editCustomerVocationScrollView.addView(editVocationLayout);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            AlertDialog cancelConfirmDialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                    .setTitle(getString(R.string.confirm_cancel_edit_vocation))
                    .setPositiveButton(getString(R.string.confirm),
                            new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface arg0, int arg1) {
                                    Intent destIntent = new Intent(EditCustomerVocationActivity.this, CustomerRecordActivity.class);
                                    Bundle bundle = new Bundle();
                                    bundle.putSerializable("recordTemplate", recordTemplate);
                                    destIntent.putExtras(bundle);
                                    startActivity(destIntent);
                                    EditCustomerVocationActivity.this.finish();
                                }
                            })
                    .setNegativeButton(getString(R.string.cancel), null).show();
            cancelConfirmDialog.setCancelable(false);
        }
        return super.onKeyDown(keyCode, event);
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
