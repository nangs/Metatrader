//+------------------------------------------------------------------+
//|                                                CsvFileWriter.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include<Files\FileTxt.mqh>
#include <Generic\ArrayList.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CsvFileWriter : public CFileTxt
  {
private:
   CArrayList<string>_columnNames;
   CArrayList<string>_data;

   string CsvEscape(string const value)
     {
      string val=value;
      StringReplace(val,"\"","\"\"");
      if(StringFind(val,",")>-1 || StringFind(val,"\r")>-1 || StringFind(val,"\n")>-1)
        {
         val=StringFormat("\"%s\"",val);
        }
      val = StringTrimLeft(val);
      val = StringTrimRight(val);
      return val;
     };

   //+------------------------------------------------------------------+
   //| Open the file                                                    |
   //+------------------------------------------------------------------+
   int Open(const string file_name,int open_flags,const string delimiter,uint codepage=CP_UTF8)
     {
      //--- check handle
      if(m_handle!=INVALID_HANDLE)
         Close();
      //--- action
      if((open_flags &(FILE_BIN|FILE_CSV))==0)
         open_flags|=FILE_TXT;
      //--- open
      m_handle=FileOpen(file_name,open_flags|m_flags,delimiter,codepage);
      if(m_handle!=INVALID_HANDLE)
        {
         //--- store options of the opened file
         m_flags|=open_flags;
         m_name=file_name;
        }
      //--- result
      return(m_handle);
     };

   bool InitializeData()
     {
      this._data.Clear();
      this._data.TrimExcess();
      int i;
      int ct=this._columnNames.Count();
      string arr[];
      ArrayResize(arr,ct,0);
      for(i=0;i<ct;i++)
        {
         arr[i]="";
        }
      return this._data.AddRange(arr);
     };

   uint WriteHeaderRow()
     {
      if(this.Size()==0 && this._columnNames.Count()>0)
        {
         string arr[];
         this._columnNames.CopyTo(arr,0);
         return this.WriteRow(arr);
        }
      return 0;
     };

public:

   void CsvFileWriter(string filename,bool append=true)
     {
      this.Open(filename,append);
     };
     
   bool IsFileHandleValid()
   {
      return (this.Handle() != INVALID_HANDLE);
   }

   int Open(string filename,bool append=true)
     {
      int handle;
      if(!append)
        {
         handle=this.Open(filename,FILE_WRITE|FILE_TXT,",",CP_UTF8);
        }
      handle=this.Open(filename,FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_WRITE|FILE_TXT,",",CP_UTF8);
      this.Seek(0,SEEK_END);
      return handle;
     };

   uint WriteRow(string &values[])
     {
      int ct=ArraySize(values);
      int i;
      string row;
      for(i=0;i<ct-1;i++)
        {
         row=StringConcatenate(row,(StringFormat("%s,",CsvEscape((string)values[i]))));
        }
      row=StringConcatenate(row,(StringFormat("%s\r\n",CsvEscape((string)values[i]))));

      this.Seek(0,SEEK_END);

      uint out = this.WriteString(row);
      this.Flush();
      return out;
     };

   bool SetColumnNames(string &columnNames[])
     {
      this._columnNames.Clear();
      this._columnNames.TrimExcess();
      if(this._columnNames.AddRange(columnNames))
        {
         return (this.InitializeData() && this.WriteHeaderRow()>0 && this.IsFileHandleValid());
        }
      return false;
     };

   bool SetPendingDataItem(string columnName,string data)
     {
      int i=this._columnNames.IndexOf(columnName);
      return this._data.TrySetValue(i,data);
     };

   bool ClearPendingDataItem(string columnName,string data)
     {
      return this.SetPendingDataItem(columnName,"");
     };

   bool ClearPendingData()
     {
      bool out=true;
      int i;
      int ct=this._data.Count();
      for(i=0;i<ct;i++)
        {
         out=out && this._data.TrySetValue(i,"");
        }
      return out;
     };

   uint WritePendingDataRow()
     {
      if(this._data.Count()>0)
        {
         string arr[];
         this._data.CopyTo(arr,0);
         this.ClearPendingData();
         return this.WriteRow(arr);
        }
      return 0;
     };
  };
//+------------------------------------------------------------------+
