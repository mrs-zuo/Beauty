using HS.Framework.Common.Entity;
using Newtonsoft.Json;
using System;

namespace Model.Operation_Model
{
    [Serializable]
    public class ObjectResultSup<T> : BaseResult
    {
        [JsonProperty]
        public T Data { get; set; }

        [JsonProperty]
        public int DataCnt { get; set; }
    }
    
}
