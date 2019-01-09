//IDEA....
#include <iostream>
#include <string>
#include <math.h>
using namespace std;
const unsigned int N=256;		//mod(pow(2,8))=256
const unsigned int MUL=65537;	//16......mod(pow(2,16)+1)=65537.....
const unsigned int ADD=65536;	//16......mod(pow(2,16))=65536.....

string change(unsigned int n,unsigned int k)//.........k....
{
	string result;
	for(int i=0;i<k;i++)
	{
		if((i!=0)&&!(i%4))	result=","+result;
		if(n%2)		result="1"+result;
		else		result="0"+result;
		n/=2;
	}
	return result;
}

void set_key(unsigned int key[],unsigned int z[9][6])//......
{
	int i,j,k,flag=0,t=0;
	unsigned int sum,temp[9][6][16];
	for(i=0;i<9;i++)
	{
		for(j=0;j<6;j++)
		{
			for(k=0;k<16;k++)
				temp[i][j][k]=key[(flag+t++)%128];
			if(!(i==j==0)&&((6*i+j)%8)==7)	flag+=25;
		}
	}
	for(i=0;i<9;i++)
	{
		for(j=0;j<6;j++)
		{
			sum=0;
			for(k=0;k<16;k++)
				if(temp[i][j][k])	sum+=(unsigned int)pow(2,15-k);   /*??????*/
				z[i][j]=sum;
		}
	}

}

void set_m(unsigned int write[],unsigned int x[])//...... 
{
	int i,j;
	unsigned int sum;
	for(i=0;i<64;i+=16)
	{
		sum=0;
		for(j=0;j<16;j++)
			if(write[i+j])	sum+=(unsigned int)pow(2,15-j);   /*????????*/
		x[i/16]=sum;
	}
}

void string_bb(string str,unsigned int result[])//..........
{
	int i,j;
	unsigned int temp;
	for(i=0;i<str.length();i++)
	{
		temp=str[i];
		for(j=7;j>=0;j--)
		{
			if(temp%2)		result[8*i+j]=1;
			else	result[8*i+j]=0;
			temp=temp/2;
		}
	}	
}

#define LOW16(x) ((x)&0xffff)

unsigned int mulInv(unsigned int x)
{  unsigned int  t0,t1;
   unsigned int  q,y;
   if ( x<=1)      return x;
   t1 = 0x10001L/x;
   y  = 0x10001L%x;
   if(y == 1)   return LOW16(1-t1);
   t0 = 1 ;
  do 
  {  q = x/y;
     x %= y;
     t0 += q*t1;
     if( x == 1)   return t0;
     q = y/x;
     y %=x;
     t1 += q*t0;
  }while( y != 1);

  return LOW16(1-t1);
}

int main()
{
	int i,j,t,n;
	unsigned int sum,temp,x[4],z[9][6],y[9][6],result[14],fresult[4],key[128],write[64];
	string m,k,str;
	cout<<"\t\t*****************************\n";
	cout<<"\t\t\tIDEA....";
	cout<<"\n\t\t*****************************\n";
	cout<<"\n........(8.):";cin>>m;  getchar();
	
	string_bb(m,write);//...................write[64]
	cout<<"\n\t\t...m="<<m<<endl<<endl;
	cout<<"m="<<endl;
	for(i=0;i<64;i++)
	{
		cout<<write[i];

		if((i!=0)&&(i%8)==7)	cout<<" ";
		if((i!=0)&&(i%32)==31)	cout<<endl;
	}
	
	k="computersecurity";
	cout<<"\n\t\t...k="<<k<<endl<<endl;
    string_bb(k,key);//...................key[128]
	cout<<"k="<<endl;
	for(i=0;i<128;i++)
	{
		cout<<key[i];
		if((i!=0)&&(i%8)==7)	cout<<" ";
		if((i!=0)&&(i%32)==31)	cout<<endl;	
	}
    
    set_m(write,x);//......x[4]
	cout<<"\n=====>....:\n"<<endl;
	for(i=0;i<4;i+=2)	
    cout<<"x["<<i<<"]="<<x[i]<<"\t"<<change(x[i],16)<<"\t"<<"x["<<i+1<<"]="<<x[i+1]<<"\t"<<change(x[i+1],16)<<endl;

	set_key(key,z);//......z[9][6]
	cout<<"\n=====>....:\n"<<endl;
	for(i=0;i<9;i++)
	{
		for(j=0;j<6;j++)
		{
			cout<<"z["<<i+1<<"]["<<j+1<<"]   "<<change(z[i][j],16)<<"\t";
			if(j%2)	cout<<endl;
		}
		cout<<endl;
	}
	cout<<"*******************************************************************************\n"<<endl;
	
    getchar();
    
  for(n=0;n<2;n++)
   {  if(n==0)   cout<<"...."<<endl;
      else       cout<<"...."<<endl; 
        for(t=0;t<8;t++)
  	  {
		result[0]=(x[0]*z[t][0])%MUL;		//X1..1..........
		result[1]=(x[1]+z[t][1])%ADD;		//X2..2..........
		result[2]=(x[2]+z[t][2])%ADD;		//X3..3..........
		result[3]=(x[3]*z[t][3])%MUL;		//X4..4..........
		result[4]=result[0]^result[2];		//(1).(3).......
		result[5]=result[1]^result[3];		//(2).(4).......
		result[6]=(result[4]*z[t][4])%MUL;	//(5).....5..........
		result[7]=(result[5]+result[6])%ADD;//(6).(7).......
		result[8]=(result[7]*z[t][5])%MUL;	//(8).....6...........
		result[9]=(result[6]+result[8])%ADD;//(7).(9) .......
		result[10]=result[0]^result[8];		//(1).(9).......
		result[11]=result[2]^result[8];		//(3).(9) .......
		result[12]=result[1]^result[9];		//(2).(10) .......
	    result[13]=result[3]^result[9];		//(4).(10) .......
		cout<<"\n     ."<<t+1<<".     "<<endl<<endl;//(4).(10) .......
		for(j=0;j<14;j++)
			cout<<"\tStep"<<j+1<<"\t"<<"result["<<j<<"]="<<result[j]<<"     \t\t"<<change(result[j],16)<<endl;
		cout<<"\nresult[10]="<<result[10]<<" "<<change(result[10],16)<<"\t";
		cout<<"result[12]="<<result[12]<<" "<<change(result[12],16)<<endl;
		cout<<"result[11]="<<result[11]<<" "<<change(result[11],16)<<"\t";
		cout<<"result[13]="<<result[13]<<" "<<change(result[13],16)<<endl;
		cout<<"-------------------------------------------------------------------------------"<<endl;
        getchar();  
		x[0]=result[10];x[1]=result[12];x[2]=result[11];x[3]=result[13];//.......9.....2..3...
		/*
		(14) (4).(10) ....... .......(11).(13).(12).(14).
		.......8.....2..3.....8..............
		(1)  ..1...........
		(2)  ..2...........
		(3)  ..3...........
		(4)  ..4...........
		*/
	}
	fresult[0]=(x[0]*z[t][0])%MUL;//X1..1..........
	fresult[1]=(x[1]+z[t][1])%ADD;//X2..2.. ........
	fresult[2]=(x[2]+z[t][2])%ADD;//X3..3..........
	fresult[3]=(x[3]*z[t][3])%MUL;//X4..4..........
	
	if(n==0) cout<<".....:"<<endl;
    else     cout<<".....:"<<endl;
	cout<<"-->fresult[1]="<<fresult[0]<<" "<<change(fresult[0],16);  printf(" ----%c--%c\n",fresult[0]/N,fresult[0]%N);   
	cout<<"-->fresult[2]="<<fresult[1]<<" "<<change(fresult[1],16);  printf(" ----%c--%c\n",fresult[1]/N,fresult[1]%N);
	cout<<"-->fresult[3]="<<fresult[2]<<" "<<change(fresult[2],16);  printf(" ----%c--%c\n",fresult[2]/N,fresult[2]%N);
	cout<<"-->fresult[4]="<<fresult[3]<<" "<<change(fresult[3],16);  printf(" ----%c--%c\n",fresult[3]/N,fresult[3]%N);
	cout<<"*******************************************************************************"<<endl;
   	
	if(n==0)
   {  getchar();
      x[0]=fresult[0],x[1]=fresult[1],x[2]=fresult[2],x[3]=fresult[3];  /*.........*/
	  for(t=0;t<9;t++)      y[t][0]=mulInv(z[8-t][0]);     /*.....*/ 
	  y[0][1]=ADD-z[8][1];  y[8][1]=ADD-z[0][1];
  	  for(t=1;t<8;t++)      y[t][1]=ADD-z[8-t][1];
	  y[0][2]=ADD-z[8][2];  y[8][2]=ADD-z[0][2];
	  for(t=1;t<8;t++)      y[t][2]=ADD-z[8-t][2];
  	  for(t=0;t<9;t++)      y[t][3]=mulInv(z[8-t][3]);
	  for(t=0;t<8;t++)      y[t][4]=z[7-t][4];
	  for(t=0;t<8;t++)      y[t][5]=z[7-t][5];
	  for(i=0;i<9;i++) 
	    for(j=0;j<6;j++)  z[i][j]=y[i][j];  }
	   
   }  
   
    system("pause");
    return 0;	
}

