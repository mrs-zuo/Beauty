package com.GlamourPromise.Beauty.chart;
import java.util.ArrayList;  
import java.util.Arrays;
import java.util.List;  
import org.achartengine.ChartFactory;  
import org.achartengine.chart.BarChart.Type;  
import org.achartengine.model.CategorySeries;  
import org.achartengine.model.XYMultipleSeriesDataset;  
import org.achartengine.renderer.SimpleSeriesRenderer;  
import org.achartengine.renderer.XYMultipleSeriesRenderer;
import android.content.Context;  
import android.graphics.Color;  
import android.graphics.Paint.Align;  
import android.view.View; 
/*
 * 顾客数据统计柱状图
 * */
public class BarChartView { 
    private static int margins[] = new int[] { 70, 70, 70, 70 };  
    private static String[] titles = new String[] { "", "" };  
    private List<double[]> values = new ArrayList<double[]>();  
    private static int[] colors = new int[] {Color.parseColor("#016cad"), Color.GREEN };  
    private XYMultipleSeriesRenderer renderer;  
    private Context mContext;  
    private String mTitle;  
    private List<String> option;  
    private boolean isSingleView = false;  
    private double[] objectCount,objectAmount,mTempArray;
    public BarChartView(Context context, boolean isSingleView) {  
        this.mContext = context;  
        this.isSingleView = isSingleView;  
        this.renderer = new XYMultipleSeriesRenderer();  
  
    }  
    //objectCount  到店次数  objectAmount //消费总额
    public void initData(double[] objectCount, double[] objectAmount, List<String> option, String title) {  
        this.values.add(objectCount);  
        if (!isSingleView) {  
            this.values.add(objectAmount);  
        }  
        this.mTitle = title;  
        this.option = option;  
        this.objectCount=objectCount;
        this.objectAmount=objectAmount;
        mTempArray=new double[this.objectCount.length];
        for(int j=0;j<objectCount.length;j++){
        	mTempArray[j]=this.objectCount[j];
        }
    }  
  
    public View getBarChartView() {  
        buildBarRenderer();
        Arrays.sort(mTempArray);
        double maxObjectCount=mTempArray[(mTempArray.length - 1)];
        setChartSettings(renderer, mTitle, "", "", 0,6,0,maxObjectCount,Color.BLACK, Color.parseColor("#016cad"));  
        renderer.getSeriesRendererAt(0).setDisplayChartValues(true);  
        if(!isSingleView){  
             renderer.getSeriesRendererAt(1).setDisplayChartValues(true);  
        }  
        int size =  option.size();  
        for (int i = 0; i < size; i++) {  
            renderer.addXTextLabel(i,option.get(i));  
        }  
        renderer.setMargins(margins);  
        renderer.setMarginsColor(0x00ffffff);  
        renderer.setPanEnabled(true, false);  
        renderer.setPanLimits(new double[] {0,mTempArray.length + 1,0,maxObjectCount});
        renderer.setZoomEnabled(false,false);  
        renderer.setZoomRate(1.0f); 
        renderer.setInScroll(false);  
        renderer.setBackgroundColor(0x00ffffff);  
        renderer.setApplyBackgroundColor(false); 
        renderer.setShowLegend(false);
        View view = ChartFactory.getBarChartView(mContext,buildBarDataset(titles, values),renderer,Type.DEFAULT);
        view.setBackgroundColor(0x00ffffff);  
        return view;  
    }  
  
    private XYMultipleSeriesDataset buildBarDataset(String[] titles, List<double[]> values) {  
        XYMultipleSeriesDataset dataset = new XYMultipleSeriesDataset();  
        int length = isSingleView ? (titles.length - 1) : titles.length;  
        for (int i = 0; i < length; i++) {  
            CategorySeries series = new CategorySeries(titles[i]);  
            double[] v = values.get(i);  
            int seriesLength = v.length;  
            for (int k = 0; k < seriesLength; k++) {  
                series.add(v[k]);  
            }  
            dataset.addSeries(series.toXYSeries());  
        }  
        return dataset;  
    }  
  
    protected void setChartSettings(XYMultipleSeriesRenderer renderer, String title, String xTitle, String yTitle,  
            double xMin, double xMax, double yMin, double yMax, int axesColor, int labelsColor) {  
        renderer.setChartTitle(title);  
        renderer.setXTitle(xTitle);  
        renderer.setYTitle(yTitle);  
        renderer.setXAxisMin(xMin);  
        renderer.setXAxisMax(xMax);  
        renderer.setYAxisMin(yMin);  
        renderer.setYAxisMax(yMax);  
        renderer.setAxesColor(axesColor);  
        renderer.setLabelsColor(labelsColor);  
        renderer.setXLabels(0);  
        renderer.setYLabels(10);  
        renderer.setYLabelsAlign(Align.RIGHT);  
        renderer.setXLabelsAlign(Align.CENTER);  
        renderer.setXLabelsColor(Color.parseColor("#000000"));
        renderer.setYLabelsColor(0,Color.parseColor("#000000")); 
    }  
    
    protected void buildBarRenderer() {  
        if (null == renderer) {  
            return;  
        }  
        renderer.setBarWidth(80);  
        renderer.setBarSpacing(10);  
        renderer.setAxisTitleTextSize(30);  
        renderer.setChartTitleTextSize(40);
        renderer.setLabelsTextSize(25);  
        renderer.setLegendTextSize(30);  
        int length = isSingleView ? (colors.length - 1) : colors.length;  
        for (int i = 0; i < length; i++) {  
            SimpleSeriesRenderer ssr = new SimpleSeriesRenderer();  
            ssr.setChartValuesTextAlign(Align.RIGHT);  
            ssr.setChartValuesTextSize(25);  
            ssr.setDisplayChartValues(true);  
            ssr.setColor(colors[i]);  
            renderer.addSeriesRenderer(ssr);  
        }  
    }  
}  
