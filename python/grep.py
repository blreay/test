import os,shutil
import re

key='manager'
re_parttern=re.compile(r''+key, re.DOTALL)

#返回含有目标文字的文件名
#filepath='./test/'
filepath='.'

def get_file(filepath):
    filelist=os.listdir(filepath)
    aim_files=[]
    for filename in filelist:
        filename1=os.path.splitext(filename)[1] #获取文件后缀
        if filename1 in ['.py','.txt','.doc','.docx']:
            #匹配

            flag=match_content(filename)
            if flag==True:
                aim_files.append(filename)
                
    return aim_files


def match_content(filename):
    flag=False
    fstr=''
    #只读模式打开并匹配
    fullpath=os.path.join(filepath,filename)
    fp=open(fullpath,'r')
    content=fp.readlines()
    
    for c in content:
        fstr+=c.replace('/n',' ')
    aim=re.findall(re_parttern,fstr)

    #if aim != None:
    if len(aim) != 0:
        print(f'OMG aim={aim}')
        flag=True

    fp.close()
    print(f'file({filename})  flag={flag} aim({aim})')
    return flag

if __name__ =="__main__":
    result=get_file(filepath)
    print(result)
