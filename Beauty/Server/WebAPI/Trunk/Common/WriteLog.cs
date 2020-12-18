using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;

namespace WebAPI.Common
{
    public abstract class WriteLOG
    {
        public static void WriteLog(string line)
        {
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(ConfigurationManager.AppSettings["ImageServer"] + "/" + ConfigurationManager.AppSettings["ImageFolder"] + "temp/" + @"webapi.log", true))
            {
                file.WriteLine(line);
            }
        }
        public static void WriteLog(string fname, string line)
        {
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(ConfigurationManager.AppSettings["ImageServer"] + "/" + ConfigurationManager.AppSettings["ImageFolder"] + "temp/" + fname + @".log", true))
            {
                file.WriteLine(line);
            }
        }
    }
}
