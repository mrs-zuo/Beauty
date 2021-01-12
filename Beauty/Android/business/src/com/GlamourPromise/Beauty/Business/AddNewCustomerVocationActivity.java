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
import com.GlamourPromise.Beauty.util.DateUtil;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Timer;

@SuppressLint("ResourceType")
public class AddNewCustomerVocationActivity extends BaseActivity implements OnClickListener {
    private AddNewCustomerVocationActivityHandler mHandler = new AddNewCustomerVocationActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private List<CustomerVocation> customerVocationList;
    private Timer dialogTimer;
    private PackageUpdateUtil packageUpdateUtil;
    private TextView editCustomerVocationAnswerTitleText;
    private ScrollView editCustomerVocationScrollView;
    private LayoutInflater layoutInflater;
    private int mCurrentIndex;
    private Button preBtn, nextBtn, pageInfoBtn, jumpBtn, submitBtn, cancelBtn;
    private JSONObject addAnswerJson;
    private RecordTemplate recordTemplate;
    private List<CustomerVocationEditAnswer> customerVocationEditAnswerList;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_add_new_customer_vocation);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class AddNewCustomerVocationActivityHandler extends Handler {
        private final AddNewCustomerVocationActivity addNewCustomerVocationActivity;

        private AddNewCustomerVocationActivityHandler(AddNewCustomerVocationActivity activity) {
            WeakReference<AddNewCustomerVocationActivity> weakReference = new WeakReference<AddNewCustomerVocationActivity>(activity);
            addNewCustomerVocationActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (addNewCustomerVocationActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (addNewCustomerVocationActivity.progressDialog != null) {
                addNewCustomerVocationActivity.progressDialog.dismiss();
                addNewCustomerVocationActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(addNewCustomerVocationActivity, "提示信息", "专业信息编辑成功！");
                alertDialog.show();
                addNewCustomerVocationActivity.removeRecordTemplate();
                Intent destIntent = new Intent(addNewCustomerVocationActivity, CustomerInfoActivity.class);
                destIntent.putExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
                destIntent.putExtra("current_tab", 3);
                addNewCustomerVocationActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, addNewCustomerVocationActivity.dialogTimer, addNewCustomerVocationActivity, destIntent);
                addNewCustomerVocationActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 0) {
                DialogUtil.createMakeSureDialog(addNewCustomerVocationActivity, "提示信息", "编辑出错，请重试！");
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(addNewCustomerVocationActivity, "您的网络貌似不给力，请重试");
                //获取某一套模板下的题目成功
            else if (msg.what == 3) {
                addNewCustomerVocationActivity.setCurrentVocation(0);
                addNewCustomerVocationActivity.customerVocationList.get(0).setAnswered(true);
                List<RecordTemplate> customerRecordTemplateList = addNewCustomerVocationActivity.userinfoApplication.getCustomerRecordTemplateTempList();
                if (customerRecordTemplateList == null) {
                    customerRecordTemplateList = new ArrayList<RecordTemplate>();
                }
                if (!addNewCustomerVocationActivity.recordTemplate.isTemp()) {
                    customerRecordTemplateList.add(addNewCustomerVocationActivity.recordTemplate);
                    addNewCustomerVocationActivity.userinfoApplication.setCustomerRecordTemplateTempList(customerRecordTemplateList);
                } else if (addNewCustomerVocationActivity.recordTemplate.isTemp()) {
                    Iterator<RecordTemplate> it = customerRecordTemplateList.iterator();
                    while (it.hasNext()) {
                        RecordTemplate rt = it.next();
                        if (rt.getRecordTemplateID() == addNewCustomerVocationActivity.recordTemplate.getRecordTemplateID() && rt.getCustomerID() == addNewCustomerVocationActivity.recordTemplate.getCustomerID()) {
                            it.remove();
                        }
                    }
                    customerRecordTemplateList.add(addNewCustomerVocationActivity.recordTemplate);
                    addNewCustomerVocationActivity.userinfoApplication.setCustomerRecordTemplateTempList(customerRecordTemplateList);
                }
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(addNewCustomerVocationActivity, addNewCustomerVocationActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(addNewCustomerVocationActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + addNewCustomerVocationActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(addNewCustomerVocationActivity);
                addNewCustomerVocationActivity.packageUpdateUtil = new PackageUpdateUtil(addNewCustomerVocationActivity, addNewCustomerVocationActivity.mHandler, fileCache, downloadFileUrl, false, addNewCustomerVocationActivity.userinfoApplication);
                addNewCustomerVocationActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                addNewCustomerVocationActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            // 包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = addNewCustomerVocationActivity.getFileStreamPath(filename);
                file.getName();
                addNewCustomerVocationActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (addNewCustomerVocationActivity.requestWebServiceThread != null) {
                addNewCustomerVocationActivity.requestWebServiceThread.interrupt();
                addNewCustomerVocationActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        layoutInflater = LayoutInflater.from(this);
        editCustomerVocationAnswerTitleText = (TextView) findViewById(R.id.edit_customer_vocation_title_text);
        editCustomerVocationScrollView = (ScrollView) findViewById(R.id.edit_customer_vocation_scorll_view);
        preBtn = (Button) findViewById(R.id.previous_btn);
        pageInfoBtn = (Button) findViewById(R.id.page_info_btn);
        nextBtn = (Button) findViewById(R.id.next_btn);
        jumpBtn = (Button) findViewById(R.id.jump_btn);
        submitBtn = (Button) findViewById(R.id.submit_btn);
        cancelBtn = (Button) findViewById(R.id.cancel_btn);
        preBtn.setOnClickListener(this);
        nextBtn.setOnClickListener(this);
        jumpBtn.setOnClickListener(this);
        submitBtn.setOnClickListener(this);
        cancelBtn.setOnClickListener(this);
        Intent intent = getIntent();
        recordTemplate = (RecordTemplate) intent.getSerializableExtra("recordTemplate");
        recordTemplate.setCustomerID(userinfoApplication.getSelectedCustomerID());
        recordTemplate.setRecordTemplateResponsibleName(userinfoApplication.getAccountInfo().getAccountName());
        recordTemplate.setRecordTemplateCustomerName(userinfoApplication.getSelectedCustomerName());
        recordTemplate.setRecordTemplateUpdateTime(DateUtil.getNowFormateDate());
        //将试卷内容保存到Json对象中，以便于提交
        addAnswerJson = new JSONObject();
        try {
            addAnswerJson.put("PaperID", recordTemplate.getRecordTemplateID());
            addAnswerJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
            addAnswerJson.put("IsVisible", recordTemplate.isRecordTemplateIsVisible());
        } catch (JSONException e) {
        }
        editCustomerVocationAnswerTitleText.setText(recordTemplate.getRecordTemplateTitle());
        if (!recordTemplate.isTemp()) {
            progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
            progressDialog.show();
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    String methodName = "GetPaperDetail";
                    String endPoint = "Paper";
                    JSONObject getPaperJson = new JSONObject();
                    try {
                        getPaperJson.put("PaperID", recordTemplate.getRecordTemplateID());
                    } catch (JSONException e) {
                    }
                    String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getPaperJson.toString(), userinfoApplication);
                    if (serverRequestResult == null || serverRequestResult.equals(""))
                        mHandler.sendEmptyMessage(2);
                    else {
                        JSONObject resultJson = null;
                        try {
                            resultJson = new JSONObject(serverRequestResult);
                        } catch (JSONException e2) {
                        }
                        int code = 0;
                        try {
                            code = resultJson.getInt("Code");
                        } catch (JSONException e) {
                            code = 0;
                        }
                        if (code == 1) {
                            JSONArray pagerDetailJsonArray = null;
                            try {
                                pagerDetailJsonArray = resultJson.getJSONArray("Data");
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            if (pagerDetailJsonArray != null) {
                                customerVocationList = new ArrayList<CustomerVocation>();
                                for (int i = 0; i < pagerDetailJsonArray.length(); i++) {
                                    JSONObject paperDetailJson = null;
                                    try {
                                        paperDetailJson = (JSONObject) pagerDetailJsonArray.get(i);
                                    } catch (JSONException e1) {
                                    }
                                    int questionID = 0;
                                    String questionName = "";
                                    int questionType = 0;
                                    String questionContent = "";
                                    String questionDescription = "";
                                    int answerID = 0;
                                    String answerContent = "";
                                    try {
                                        if (paperDetailJson.has("QuestionID")) {
                                            questionID = paperDetailJson.getInt("QuestionID");
                                        }
                                        if (paperDetailJson.has("QuestionName")) {
                                            questionName = paperDetailJson.getString("QuestionName");
                                        }
                                        if (paperDetailJson.has("QuestionType")) {
                                            questionType = paperDetailJson.getInt("QuestionType");
                                        }
                                        if (paperDetailJson.has("QuestionContent")) {
                                            questionContent = paperDetailJson.getString("QuestionContent");
                                        }
                                        if (paperDetailJson.has("QuestionDescription")) {
                                            questionDescription = paperDetailJson.getString("QuestionDescription");
                                        }
                                        if (paperDetailJson.has("AnswerID")) {
                                            answerID = paperDetailJson.getInt("AnswerID");
                                        }
                                        if (paperDetailJson.has("AnswerContent"))
                                            answerContent = paperDetailJson.getString("AnswerContent");
                                    } catch (JSONException e) {

                                    }
                                    CustomerVocation cv = new CustomerVocation();
                                    cv.setQuestionId(questionID);
                                    cv.setQuestionType(questionType);
                                    cv.setQuestionName(questionName);
                                    cv.setQuestionDescription(questionDescription);
                                    String[] answerContentarray = questionContent.split("\\|");
                                    List<CustomerVocationEditAnswer> cveaList = new ArrayList<CustomerVocationEditAnswer>();
                                    for (int j = 0; j < answerContentarray.length; j++) {
                                        CustomerVocationEditAnswer cvea = new CustomerVocationEditAnswer();
                                        cvea.setAnswerContent(answerContentarray[j]);
                                        int isAnswer = 0;
                                        cvea.setIsAnswer(isAnswer);
                                        cveaList.add(cvea);
                                    }
                                    cv.setCustomerVocationEditAnswer(cveaList);
                                    customerVocationList.add(cv);
                                    recordTemplate.setCustomerVocationList(customerVocationList);
                                }
                            }
                            mHandler.sendEmptyMessage(3);
                        } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                            mHandler.sendEmptyMessage(code);
                        else
                            mHandler.sendEmptyMessage(2);
                    }
                }
            };
            requestWebServiceThread.start();
        } else {
            customerVocationList = recordTemplate.getCustomerVocationList();
            mHandler.sendEmptyMessage(3);
        }
    }

    //设置当前题目的视图
    private void setCurrentVocation(int currentIndex) {
        editCustomerVocationScrollView.removeAllViews();
        mCurrentIndex = currentIndex;
        pageInfoBtn.setText((mCurrentIndex + 1) + "/" + customerVocationList.size());
        CustomerVocation customerVocation = customerVocationList.get(currentIndex);
        customerVocationEditAnswerList = customerVocation.getCustomerVocationEditAnswer();
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
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    // TODO Auto-generated method stub

                }

                @Override
                public void beforeTextChanged(CharSequence s, int start, int count,
                                              int after) {
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
                    vocationItemCheckBox.setBackgroundResource(R.drawable.no_select_btn);
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
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            //提交
            case R.id.submit_btn:
                progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
                progressDialog.setMessage(getString(R.string.please_wait));
                progressDialog.show();
                JSONArray answerArray = new JSONArray();
                //获得回答过的所有题目的答案
                for (CustomerVocation cv : customerVocationList) {
                    if (cv.isAnswered()) {
                        JSONObject answerJson = new JSONObject();
                        try {
                            answerJson.put("QuestionID", cv.getQuestionId());
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        StringBuffer answerContent = new StringBuffer();
                        List<CustomerVocationEditAnswer> cveList = cv.getCustomerVocationEditAnswer();
                        if (cv.getQuestionType() == 0) {
                            answerContent.append(cveList.get(0).getAnswerContent());
                        } else if (cv.getQuestionType() == 1 || cv.getQuestionType() == 2) {
                            for (CustomerVocationEditAnswer cve : cveList) {
                                answerContent.append(cve.getIsAnswer() + "|");
                            }
                        }
                        try {
                            answerJson.put("AnswerContent", answerContent.toString());
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        answerArray.put(answerJson);
                    }
                }
                try {
                    addAnswerJson.put("AnswerList", answerArray);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                requestWebServiceThread = new Thread() {
                    @Override
                    public void run() {
                        String methodName = "AddAnswer";
                        String endPoint = "Paper";
                        String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addAnswerJson.toString(), userinfoApplication);
                        JSONObject resultJson = null;
                        try {
                            resultJson = new JSONObject(serverResultResult);
                        } catch (JSONException e1) {
                        }
                        if (serverResultResult == null || serverResultResult.equals(""))
                            mHandler.sendEmptyMessage(2);
                        else {
                            String code = "0";
                            try {
                                code = resultJson.getString("Code");
                            } catch (JSONException e) {
                                code = "0";
                            }
                            if (Integer.parseInt(code) == 1) {
                                mHandler.sendEmptyMessage(1);
                            } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                                mHandler.sendEmptyMessage(Integer.parseInt(code));
                            else
                                mHandler.sendEmptyMessage(0);
                        }
                    }
                };
                requestWebServiceThread.start();
                break;
            //上一题
            case R.id.previous_btn:
                if (mCurrentIndex >= 1)
                    setCurrentVocation(mCurrentIndex - 1);
                else
                    DialogUtil.createShortDialog(this, "这是第一题了");
                break;
            //下一题
            case R.id.next_btn:
                if (mCurrentIndex < customerVocationList.size() - 1) {
                    //设置上一题及当前的题目是已回答过的
                    customerVocationList.get(mCurrentIndex).setAnswered(true);
                    customerVocationList.get(mCurrentIndex + 1).setAnswered(true);
                    setCurrentVocation(mCurrentIndex + 1);
                } else
                    DialogUtil.createShortDialog(this, "这是最后一题了");
                break;
            //跳过
            case R.id.jump_btn:
                int questionType = customerVocationList.get(mCurrentIndex).getQuestionType();
                if (mCurrentIndex < customerVocationList.size() - 1) {
                    List<CustomerVocationEditAnswer> customerVocationEditAnswerList = customerVocationList.get(mCurrentIndex).getCustomerVocationEditAnswer();
                    if (questionType == 0) {
                        customerVocationEditAnswerList.get(0).setAnswerContent("");
                    } else if (questionType == 1 || questionType == 2) {
                        for (CustomerVocationEditAnswer cvea : customerVocationEditAnswerList) {
                            cvea.setIsAnswer(0);
                        }
                    }
                    customerVocationList.get(mCurrentIndex).setAnswered(false);
                    customerVocationList.get(mCurrentIndex + 1).setAnswered(true);
                    setCurrentVocation(mCurrentIndex + 1);
                } else {
                    DialogUtil.createShortDialog(this, "这是最后一题了");
                }
                break;
            //取消
            case R.id.cancel_btn:
                AlertDialog cancelConfirmDialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                        .setTitle(getString(R.string.confirm_cancel_edit_vocation))
                        .setPositiveButton(getString(R.string.confirm),
                                new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface arg0, int arg1) {
                                        removeRecordTemplate();
                                        AddNewCustomerVocationActivity.this.finish();
                                    }
                                })
                        .setNegativeButton(getString(R.string.cancel), null).show();
                cancelConfirmDialog.setCancelable(false);
                break;
        }
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
                                    removeRecordTemplate();
                                    AddNewCustomerVocationActivity.this.finish();
                                }
                            })
                    .setNegativeButton(getString(R.string.cancel), null).show();
            cancelConfirmDialog.setCancelable(false);
        }
        return super.onKeyDown(keyCode, event);
    }

    //移除已经成功提交或者取消的模板草稿
    protected void removeRecordTemplate() {
        List<RecordTemplate> recordTemplateTmpList = userinfoApplication.getCustomerRecordTemplateTempList();
        Iterator<RecordTemplate> iterator = recordTemplateTmpList.iterator();
        while (iterator.hasNext()) {
            RecordTemplate rt = iterator.next();
            int customerID = rt.getCustomerID();
            int paperID = rt.getRecordTemplateID();
            if (paperID == recordTemplate.getRecordTemplateID() && customerID == recordTemplate.getCustomerID())
                iterator.remove();
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
