using HS.Framework.Common.Entity;
using Model.Table_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Appointment_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetAppointmentList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAppointmentList(JObject obj)//
        {
            ObjectResult<List<Appointment_Model>> res = new ObjectResult<List<Appointment_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            
            Appointment_Search_Model utilityModel = new Appointment_Search_Model();
            utilityModel = JsonConvert.DeserializeObject<Appointment_Search_Model>(strSafeJson);
            if (string.IsNullOrEmpty(utilityModel.ReserveDate))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            List<Appointment_Model> list = new List<Appointment_Model>();
            utilityModel.CompanyID = this.CompanyID;
            list = Appointment_BLL.Instance.GetAppointmentList(utilityModel);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }
    }
}