#!/usr/bin/env python
# coding: utf-8

# In[2]:


#loop from excel for URLs
import requests
import re
import xlwt
import pandas as pd
from bs4 import BeautifulSoup
from openpyxl import load_workbook
import os.path
import threading
import urllib.request
import time

#def format (s):
#    res = s.replace("\n", "")
#    return " ".join(res.split())
workbook=load_workbook(filename='***.xlsx')
sheet=workbook.active
data = pd.read_excel('C:/*.xlsx')
row=[]
# get the urls
urls = data.URL
count=0
# go through every url in the urls
for url in urls:
     

   # if count==30000:
   #     break
    count+=1
    # do the request for this url
    res = requests.get(url)

    # soup-it
    html = res.text
    soup = BeautifulSoup(html, 'lxml')
    table=soup.find('table')
    
    head=soup.find('h1').getText()
    table_rows=table.find('td').getText()
    #if type(table_rows) is list:
    str1='A'+str(count)
    str2='B'+str(count)
    sheet[str1].value=head
    sheet[str2].value=table_rows
workbook.save(filename='rrr.xlsx')
    #s=head+table_rows
   # r=format(s)
   
        #table_rows.insert(0,head)
        #s=listToString(table_rows)
    #row.append(head)
    #row.append(table_rows)
    #print(row)
#L=pd.concat(row) 
#print(L)
    #print(soup.head(1))
    #print(head)
    #print(table_rows.split())
    #" ".join(s.split())
    #print(r)


#df_output={head,table_rows}  
#df_final=pd.DataFrame(df_output)
#print(df_final)  


# In[ ]:




