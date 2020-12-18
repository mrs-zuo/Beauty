package cn.com.antika.bean;
import java.util.List;
import android.view.View;
public class BenefitSpinnerBean {
	private List<CustomerBenefit> customerBenefitList;
	private View      prepareOrderProductView;
	public List<CustomerBenefit> getCustomerBenefitList() {
		return customerBenefitList;
	}
	public void setCustomerBenefitList(List<CustomerBenefit> customerBenefitList) {
		this.customerBenefitList = customerBenefitList;
	}
	public View getPrepareOrderProductView() {
		return prepareOrderProductView;
	}
	public void setPrepareOrderProductView(View prepareOrderProductView) {
		this.prepareOrderProductView = prepareOrderProductView;
	}
}
