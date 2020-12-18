using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using WebAPI.Filter;
using WebAPI.Handlers;

namespace WebAPI
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services

            // Web API routes
            config.MapHttpAttributeRoutes();
            config.Filters.Add(new GlobalExceptionFilter());
            config.MessageHandlers.Add(new HttpHandler());
            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "{controller}/{action}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
