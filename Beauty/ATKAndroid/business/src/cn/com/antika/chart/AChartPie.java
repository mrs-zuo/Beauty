package cn.com.antika.chart;
import org.achartengine.ChartFactory;
import org.achartengine.model.CategorySeries;
import org.achartengine.renderer.DefaultRenderer;
import org.achartengine.renderer.SimpleSeriesRenderer;
import cn.com.antika.util.NumberFormatUtil;
import android.content.Context;
import android.graphics.Color;
import android.view.View;
/*
 * 顾客数据统计饼状图
 * */
public class AChartPie {
	double[]  mValues;
	String[]  mObjectName;
	double    totalValue=0;
	public AChartPie() {
	}
	public AChartPie(String[] objectName,double[] values) {
		this.mObjectName=objectName;
		this.mValues=values;
		for(double value:mValues){
			totalValue+=value;
		}
	}
	public View execute(Context context) {
		int[] colors = new int[] {Color.parseColor("#b60404"), Color.parseColor("#b64704"),Color.parseColor("#b69204"),Color.parseColor("#71b604"),Color.parseColor("#26b604"),Color.parseColor("#04b67d"),
				Color.parseColor("#04b67d"),Color.parseColor("#044fb6"),Color.parseColor("#0408b6"),Color.parseColor("#5c04b6"),Color.parseColor("#a704b6")};
		DefaultRenderer renderer = buildCategoryRenderer(colors);
		CategorySeries categorySeries = new CategorySeries("Vehicles Chart");
		for(int i=0;i<mObjectName.length;i++){
			String percent=NumberFormatUtil.currencyFormat(String.valueOf((mValues[i]/totalValue)*100))+"%";
			categorySeries.add("\t\t"+mObjectName[i]+"("+percent+")\r\n",mValues[i]);
		}
		return ChartFactory.getPieChartView(context,categorySeries,renderer);
	}
	protected DefaultRenderer buildCategoryRenderer(int[] colors) {
		DefaultRenderer renderer = new DefaultRenderer();
		renderer.setBackgroundColor(Color.WHITE);
		renderer.setApplyBackgroundColor(true);
		renderer.setLabelsTextSize(30);
		renderer.setLabelsColor(Color.TRANSPARENT);
		renderer.setChartTitle("消费占比分析图表");
		renderer.setAntialiasing(true);
		renderer.setChartTitleTextSize(40);
		renderer.setLegendTextSize(30);
		renderer.setLegendHeight(20);
		renderer.setFitLegend(true);
		renderer.setPanEnabled(false);
		for(int i=0;i<mObjectName.length;i++){
			SimpleSeriesRenderer ssr = new SimpleSeriesRenderer();
			ssr.setColor(colors[i]);
			renderer.addSeriesRenderer(ssr);
		}
		return renderer;
	}
}
