using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.Common
{
    public class SqlCommon
    {
        public static String copySqlSpell(string tableName, string strField, int id)
        {
            StringBuilder strSql = new StringBuilder();
            strSql.Append(" Insert Into HISTORY_");
            strSql.Append(tableName);
            strSql.Append(" select * from ");
            strSql.Append(tableName);
            if (strField != "")
            {

                strSql.Append(" where ");
                strSql.Append(strField);
                strSql.Append(" = ");
                strSql.Append(id.ToString());
            }
            return strSql.ToString();
        }
        /// <summary>
        /// 获取一张TABLE所有的字段名，类型，是否为空，长度（1为获取，0为不获取）
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="type"></param>
        /// <param name="isnullable"></param>
        /// <param name="length"></param>
        /// <returns></returns>
        public static String getTableList(string tableName, int type, int isnullable, int length)
        {
            StringBuilder strSql = new StringBuilder();
            strSql.Append(" SELECT T1.name Name ");
            if (type == 1)
            {
                strSql.Append(" , ");
                strSql.Append(" T2.name Type ");
            }
            if (isnullable == 1)
            {
                strSql.Append(" , ");
                strSql.Append(" T1.isnullable ");
            }
            if (length == 1)
            {
                strSql.Append(" , ");
                strSql.Append(" T1.length ");
            }
            strSql.Append(" FROM syscolumns T1, systypes T2 ");
            strSql.Append(" WHERE T1.xusertype = T2.xusertype ");
            strSql.Append(" AND T1.id = object_id('");
            strSql.Append(tableName);
            strSql.Append("')");

            return strSql.ToString();

        }

        /// <summary>
        /// 递归方法
        /// </summary>
        /// <param name="strTable">抽出的表名</param>
        /// <param name="strMainId">主要ID，下级ID</param>
        /// <param name="strParentId">上级ID，父类ID</param>
        /// <param name="strNeed">需要用到的抽出项目</param>
        /// <param name="boolInclude">是否包括条件本身数据 True:包括;False不包括;</param>
        /// <param name="whereId">条件的ID</param>
        /// <returns></returns>

        public static string sqlRecursive(string strTable, string strMainId, string strParentId, string strNeed, bool boolInclude, int whereId, bool available)
        {
            string[] array = strNeed.Split(new[] { "," }, StringSplitOptions.RemoveEmptyEntries);
            StringBuilder strSql = new StringBuilder();
            strSql.Append(" with SubQuery( ");
            strSql.Append(strMainId);
            strSql.Append(" , ");
            strSql.Append(strParentId);
            if (strNeed != "")
            {
                strSql.Append(" , ");
                strSql.Append(strNeed);
            }
            strSql.Append(" ,Level) ");
            strSql.Append("  as (  ");
            strSql.Append(" select ");
            strSql.Append(strMainId);
            strSql.Append(" , ");
            strSql.Append(strParentId);
            if (strNeed != "")
            {
                strSql.Append(" , ");
                strSql.Append(strNeed);
            }
            strSql.Append(" ,1 as Level from ");
            strSql.Append(strTable);
            strSql.Append(" where ");
            if (boolInclude == true)
            {
                strSql.Append(strMainId);
            }
            else
            {
                strSql.Append(strParentId);
            }
            strSql.Append(" = ");
            strSql.Append(whereId.ToString());
            strSql.Append(" union all ");
            strSql.Append(" select ");
            strSql.Append(" T1.");
            strSql.Append(strMainId);
            strSql.Append(" ,");
            strSql.Append(" T1.");
            strSql.Append(strParentId);
            for (int i = 0; i < array.Length; i++)
            {
                strSql.Append(" ,");
                strSql.Append(" T1.");
                strSql.Append(array[i]);
            }
            strSql.Append(" ,T2.Level+1 AS Level ");
            strSql.Append(" from ");
            strSql.Append(strTable);
            strSql.Append(" T1 ");
            strSql.Append(" inner join ");
            strSql.Append(" SubQuery T2 ");
            strSql.Append(" on ");
            strSql.Append(" T1.");
            strSql.Append(strParentId);
            strSql.Append(" = ");
            strSql.Append(" T2. ");
            strSql.Append(strMainId);
            if (available)
            {
                strSql.Append(" and T1.Available = 1");
            }
            strSql.Append(") ");
            return strSql.ToString();
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="cycleType">0:日 1：月 2：季 3：年 4：自定义</param>
        /// <param name="startTime"></param>
        /// <param name="endtime"></param>
        /// <param name="strCompare"></param>
        /// <returns></returns>
        public static string getSqlWhereData(int cycleType, string startTime, string endtime, string strCompare)
        {
            string sqlAppend = "";
            switch (cycleType)
            {
                case 0:
                    sqlAppend = " AND DATEDIFF(dd, " + strCompare + ",getdate()) = 0";
                    break;
                case 1:
                    sqlAppend = " AND DATEPART(yy, " + strCompare + ") = DATEPART(YY,GETDATE()) AND DATEPART(MM, " + strCompare + ")=DATEPART(MM,GETDATE()) ";
                    break;
                case 2:
                    sqlAppend = " AND DATEPART(q, " + strCompare + ") = DATEPART(qq, GETDATE()) and DATEPART(yy, " + strCompare + ") = DATEPART(yy,GETDATE() ) ";
                    break;
                case 3:
                    sqlAppend = " AND DATEPART(yy, " + strCompare + ") =DATEPART(YY,GETDATE()) ";
                    break;
                case 4:
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                    sqlAppend = " AND " + strCompare + " BETWEEN '" + startTime + "' AND '" + endtime + "' ";
                    break;
                default:
                    break;
            }
            return sqlAppend;
        }



        /// <summary>
        /// 
        /// </summary>
        /// <param name="cycleType">0:日 1：月 2：季 3：年 4：自定义</param>
        /// <param name="startTime"></param>
        /// <param name="endtime"></param>
        /// <param name="strCompare"></param>
        /// <returns></returns>
        public static DateTime getStartTime(int cycleType, string startTime)
        {
            string sqlAppend = "";
            DateTime dt = DateTime.Now.ToLocalTime();
            switch (cycleType)
            {
                case 0:
                    sqlAppend = dt.ToString("yyyy-MM-dd 00:00:00");
                    break;
                case 1:
                    sqlAppend = dt.ToString("yyyy-MM-01 00:00:00");
                    break;
                case 2:
                    if (dt.Month >= 1 && dt.Month <= 3)
                    {
                        sqlAppend = dt.ToString("yyyy-01-01 00:00:00");
                    }
                    else if (dt.Month >= 4 && dt.Month <= 6)
                    {
                        sqlAppend = dt.ToString("yyyy-04-01 00:00:00");
                    }
                    else if (dt.Month >= 7 && dt.Month <= 9)
                    {
                        sqlAppend = dt.ToString("yyyy-07-01 00:00:00");
                    }
                    else if (dt.Month >= 10 && dt.Month <= 12)
                    {
                        sqlAppend = dt.ToString("yyyy-10-01 00:00:00");
                    }
                    break;
                case 3:
                    sqlAppend = dt.ToString("yyyy-01-01 00:00:00");
                    break;
                case 4:
                    startTime += " 0:00:00";
                    sqlAppend = startTime;
                    break;
                default:
                    break;
            }
            return Convert.ToDateTime(sqlAppend);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="cycleType">0:日 1：月 2：季 3：年 4：自定义</param>
        /// <param name="startTime"></param>
        /// <param name="endtime"></param>
        /// <param name="strCompare"></param>
        /// <returns></returns>
        public static string getSqlWhereData_1_7_2(int cycleType, string startTime, string endtime, string strCompare)
        {
            string sqlAppend = "";
            switch (cycleType)
            {
                case 0:
                    sqlAppend = " AND DATEDIFF(dd, " + strCompare + ",getdate()) = 0";
                    break;
                case 1:
                    sqlAppend = " AND DATEPART(yy, " + strCompare + ") = DATEPART(YY,GETDATE()) AND DATEPART(MM, " + strCompare + ")=DATEPART(MM,GETDATE()) ";
                    break;
                case 2:
                    sqlAppend = " AND DATEPART(q, " + strCompare + ") = DATEPART(qq, GETDATE()) and DATEPART(yy, " + strCompare + ") = DATEPART(yy,GETDATE() ) ";
                    break;
                case 3:
                    sqlAppend = " AND DATEPART(yy, " + strCompare + ") =DATEPART(YY,GETDATE()) ";
                    break;
                case 4:
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                    sqlAppend = " AND " + strCompare + " BETWEEN '" + startTime + "' AND '" + endtime + "' ";
                    break;
                default:
                    break;
            }
            return sqlAppend;
        }
    }
}
