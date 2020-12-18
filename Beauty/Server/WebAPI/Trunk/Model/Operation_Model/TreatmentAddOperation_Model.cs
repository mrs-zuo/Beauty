﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class TreatmentAddOperation_Model
    {
        public int CompanyID { get; set; }
        public int OrderID { get; set; }
        public int CourseID { get; set; }
        public int CustomerID { get; set; }
        public int CreatorID { get; set; }
        public bool IsDesignated { get; set; }
        public string SubServiceIDs { get; set; }

        public DateTime CreateTime { get; set; }
        public bool Reminded { get; set; }
        public int Status { get; set; }

        public int BranchID { get; set; }
    }

    [Serializable]
    public class CompleteTGOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int CustomerID { get; set; }
        public int UpdaterID { get; set; }
        public string SignImg { get; set; }
        public string ImageFormat { get; set; }
        public DateTime UpdateTime { get; set; }

        public List<CompleteTGDetailOperation_Model> TGDetailList { get; set; }
    }

    [Serializable]
    public class CompleteTGDetailOperation_Model
    {
        public int OrderType { get; set; }
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public long GroupNo { get; set; }
    }
}
