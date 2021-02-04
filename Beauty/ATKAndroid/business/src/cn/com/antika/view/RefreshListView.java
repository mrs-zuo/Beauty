package cn.com.antika.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Date;

import cn.com.antika.business.R;
import cn.com.antika.minterface.RefreshListViewWithWebservice;

@SuppressLint("ResourceType")
public class RefreshListView extends ListView implements OnScrollListener {
    private RefreshListViewHandler mHandler = new RefreshListViewHandler(this);
    private float mDownY;
    private float mMoveY;
    private int mHeaderHeight;
    private int mCurrentScrollState;
    private final static int NONE_PULL_REFRESH = 0; // 正常状态
    private final static int ENTER_PULL_REFRESH = 1; // 进入下拉刷新状态
    private final static int ENTER_RELEAESE_REFRESH = 2; // 进入松手刷新状态
    private final static int EXIT_REFRESH = 3; // 松手后反弹和加载状态
    private int mPullRefreshState = 0; // 记录刷新状态

    private final static int REFRESH_BACKING = 0; // 反弹中
    private final static int REFRESH_BACKED = 1; // 达到刷新界限，反弹结束后
    private final static int REFRESH_RETURN = 2; // 没有达到刷新界限，返回
    private final static int REFRESH_DONE = 3; // 加载数据结束

    private LinearLayout mHeaderLinearLayout = null;
    private TextView mHeaderTextView = null;
    private TextView mHeaderUpdateText = null;
    //private ImageView mHeaderPullDownImageView = null;
    //private ImageView mHeaderReleaseDownImageView = null;
    private ProgressBar mHeaderProgressBar = null;

    private SimpleDateFormat mSimpleDateFormat;

//	private Object mRefreshObject = null;

    public RefreshListView(Context context) {
        this(context, null);
    }

    public RefreshListView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);

    }

    void init(final Context context) {
        mHeaderLinearLayout = (LinearLayout) LayoutInflater.from(context)
                .inflate(R.xml.refresh_list_header, null);
        addHeaderView(mHeaderLinearLayout);
        mHeaderTextView = (TextView) findViewById(R.id.refresh_list_header_text);
        mHeaderUpdateText = (TextView) findViewById(R.id.refresh_list_header_last_update);
        //mHeaderPullDownImageView = (ImageView) findViewById(R.id.refresh_list_header_pull_down);
        //mHeaderReleaseDownImageView = (ImageView) findViewById(R.id.refresh_list_header_release_up);
        mHeaderProgressBar = (ProgressBar) findViewById(R.id.refresh_list_header_progressbar);

        setSelection(1);
        setOnScrollListener(this);
        measureView(mHeaderLinearLayout);
        mHeaderHeight = mHeaderLinearLayout.getMeasuredHeight();
        mSimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        mHeaderUpdateText.setText("上次更新：" + mSimpleDateFormat.format(new Date()));
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mDownY = ev.getY();
                break;
            case MotionEvent.ACTION_MOVE:
                mMoveY = ev.getY();
                if (mMoveY - mDownY > 30
                        && !(mCurrentScrollState == SCROLL_STATE_IDLE)) {
                    mHeaderLinearLayout.setPadding(0, 0, 0, 0);
                }
                if (mPullRefreshState == ENTER_RELEAESE_REFRESH) {
                    mHeaderLinearLayout.setPadding(
                            mHeaderLinearLayout.getPaddingLeft(),
                            (int) ((mMoveY - mDownY) / 3),
                            mHeaderLinearLayout.getPaddingRight(),
                            mHeaderLinearLayout.getPaddingBottom());
                }
                break;
            case MotionEvent.ACTION_UP:
                // when you action up, it will do these:
                // 1. roll back util header topPadding is 0
                // 2. hide the header by setSelection(1)
                if (mPullRefreshState == ENTER_RELEAESE_REFRESH
                        || mPullRefreshState == ENTER_PULL_REFRESH) {
                    new Thread() {
                        public void run() {
                            Message msg;
                            while (mHeaderLinearLayout.getPaddingTop() > 1) {
                                msg = mHandler.obtainMessage();
                                msg.what = REFRESH_BACKING;
                                mHandler.sendMessage(msg);
                                try {
                                    sleep(30);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            }
                            msg = mHandler.obtainMessage();
                            if (mPullRefreshState == ENTER_RELEAESE_REFRESH) {
                                msg.what = REFRESH_BACKED;
                            } else {
                                msg.what = REFRESH_RETURN;
                            }
                            mHandler.sendMessage(msg);
                        }

                        ;
                    }.start();
                }
                break;
        }
        return super.onTouchEvent(ev);
    }

    static int i = 0;

    @Override
    public void onScroll(AbsListView view, int firstVisibleItem,
                         int visibleItemCount, int totalItemCount) {
        if (visibleItemCount == totalItemCount
                && mCurrentScrollState == SCROLL_STATE_IDLE
                && mPullRefreshState == NONE_PULL_REFRESH) {
            mHeaderLinearLayout.setPadding(0, -mHeaderHeight, 0, 0);
        }

        if (mCurrentScrollState == SCROLL_STATE_TOUCH_SCROLL
                && firstVisibleItem == 0
                && (mHeaderLinearLayout.getBottom() >= 0 && mHeaderLinearLayout
                .getBottom() < mHeaderHeight)) {
            // 进入且仅进入下拉刷新状态
            if (mPullRefreshState == NONE_PULL_REFRESH) {
                mPullRefreshState = ENTER_PULL_REFRESH;
            }
        } else if (mCurrentScrollState == SCROLL_STATE_TOUCH_SCROLL
                && firstVisibleItem == 0
                && (mHeaderLinearLayout.getBottom() >= mHeaderHeight)) {
            // 下拉达到界限，进入松手刷新状态
            if (mPullRefreshState == ENTER_PULL_REFRESH
                    || mPullRefreshState == NONE_PULL_REFRESH) {
                mPullRefreshState = ENTER_RELEAESE_REFRESH;
                mDownY = mMoveY; // 为下拉1/3折扣效果记录开始位置
                mHeaderTextView.setText("松手刷新");// 显示松手刷新
                //mHeaderPullDownImageView.setVisibility(View.GONE);// 隐藏"下拉刷新"
                //mHeaderReleaseDownImageView.setVisibility(View.VISIBLE);// 显示向上的箭头
            }
        } else if (mCurrentScrollState == SCROLL_STATE_TOUCH_SCROLL
                && firstVisibleItem != 0) {
            // 不刷新了
            if (mPullRefreshState == ENTER_PULL_REFRESH) {
                mPullRefreshState = NONE_PULL_REFRESH;
            }
        } else if ((mCurrentScrollState == SCROLL_STATE_FLING)
                && firstVisibleItem == 0) {
            // 飞滑状态，不能显示出header，也不能影响正常的飞滑
            // 只在正常情况下才纠正位置
            // 当显示内容比屏幕区域小时 setSelection不起作用
            if (mPullRefreshState == NONE_PULL_REFRESH) {
                setSelection(1);
            }
        }
    }

    @Override
    public void onScrollStateChanged(AbsListView view, int scrollState) {
        mCurrentScrollState = scrollState;
    }

    @Override
    public void setAdapter(ListAdapter adapter) {
        super.setAdapter(adapter);
        setSelection(1);
    }

    private void measureView(View child) {
        ViewGroup.LayoutParams p = child.getLayoutParams();
        if (p == null) {
            p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT);
        }

        int childWidthSpec = ViewGroup.getChildMeasureSpec(0, 0 + 0, p.width);
        int lpHeight = p.height;
        int childHeightSpec;
        if (lpHeight > 0) {
            childHeightSpec = MeasureSpec.makeMeasureSpec(lpHeight,
                    MeasureSpec.EXACTLY);
        } else {
            childHeightSpec = MeasureSpec.makeMeasureSpec(0,
                    MeasureSpec.UNSPECIFIED);
        }
        child.measure(childWidthSpec, childHeightSpec);
    }

    private static class RefreshListViewHandler extends Handler {
        private final RefreshListView refreshListView;

        private RefreshListViewHandler(RefreshListView activity) {
            WeakReference<RefreshListView> weakReference = new WeakReference<RefreshListView>(activity);
            refreshListView = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case REFRESH_BACKING:
                    refreshListView.mHeaderLinearLayout.setPadding(
                            refreshListView.mHeaderLinearLayout.getPaddingLeft(),
                            (int) (refreshListView.mHeaderLinearLayout.getPaddingTop() * 0.75f),
                            refreshListView.mHeaderLinearLayout.getPaddingRight(),
                            refreshListView.mHeaderLinearLayout.getPaddingBottom());
                    break;
                case REFRESH_BACKED:
                    refreshListView.mHeaderTextView.setText("正在加载...");
                    refreshListView.mHeaderProgressBar.setVisibility(View.VISIBLE);
                    //mHeaderPullDownImageView.setVisibility(View.GONE);
                    //mHeaderReleaseDownImageView.setVisibility(View.GONE);
                    refreshListView.mPullRefreshState = EXIT_REFRESH;
                    new Thread() {
                        public void run() {
                            Looper.prepare();
                            if (refreshListView.mRefreshListener != null) {
//							mRefreshObject = mRefreshListener.refreshing();
                                Log.v("mRefreshListener", "mRefreshListener");
                                refreshListView.mRefreshListener.refreshing();
                            }
                            Message msg = refreshListView.mHandler.obtainMessage();
                            msg.what = REFRESH_DONE;
                            refreshListView.mHandler.sendMessage(msg);
                            Looper.loop();
                        }
                    }.start();
                    break;
                case REFRESH_RETURN:
                    refreshListView.mHeaderTextView.setText("下拉刷新");
                    refreshListView.mHeaderProgressBar.setVisibility(View.INVISIBLE);
                    //mHeaderPullDownImageView.setVisibility(View.VISIBLE);
                    //mHeaderReleaseDownImageView.setVisibility(View.GONE);
                    refreshListView.mHeaderLinearLayout.setPadding(
                            refreshListView.mHeaderLinearLayout.getPaddingLeft(), 0,
                            refreshListView.mHeaderLinearLayout.getPaddingRight(),
                            refreshListView.mHeaderLinearLayout.getPaddingBottom());
                    refreshListView.mPullRefreshState = NONE_PULL_REFRESH;
                    refreshListView.setSelection(1);
                    break;
                case REFRESH_DONE:
                    refreshListView.mHeaderTextView.setText("下拉刷新");
                    refreshListView.mHeaderProgressBar.setVisibility(View.INVISIBLE);
                    //mHeaderPullDownImageView.setVisibility(View.VISIBLE);
                    //mHeaderReleaseDownImageView.setVisibility(View.GONE);
                    refreshListView.mHeaderUpdateText.setText("上次更新：" + refreshListView.mSimpleDateFormat.format(new Date()));
                    refreshListView.mHeaderLinearLayout.setPadding(
                            refreshListView.mHeaderLinearLayout.getPaddingLeft(), 0,
                            refreshListView.mHeaderLinearLayout.getPaddingRight(),
                            refreshListView.mHeaderLinearLayout.getPaddingBottom());
                    refreshListView.mPullRefreshState = NONE_PULL_REFRESH;
                    refreshListView.mHeaderLinearLayout.setPadding(0, -refreshListView.mHeaderHeight, 0, 0);
                    refreshListView.setSelection(1);
                    break;
                default:
                    break;
            }
        }
    }

    private RefreshListViewWithWebservice mRefreshListener = null;

    public void setOnRefreshListener(RefreshListViewWithWebservice refreshListener) {
        this.mRefreshListener = refreshListener;
    }
}