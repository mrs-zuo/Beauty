using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web;

namespace ClientApi.Handlers
{
    public class HttpHandler: DelegatingHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            var content=request.Content.ReadAsStringAsync().Result;
            return base.SendAsync(request, cancellationToken);
        }
    }
}