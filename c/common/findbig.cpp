using namespace std; 

//#include "StdAfx.h"
#include <stdio.h> 
//#include <stdlib.h> 
#include <string.h> 
#include <iostream> 

 
int GetMostNumberSum(int input[], int length);

//********************************************
//
//********************************************
int GetMostNumberSum(int input[], int length)
{
	if (length <=0) return 0;

	int *src=new int[length];
	int *a1=new int[length]; 
	int *a2=new int[length]; 
	
	//copy array to temp buffer and init memory
	memcpy(src, input, sizeof(int)*length);
	memset(a1, 0, sizeof(int)*length);
	memset(a2, 0, sizeof(int)*length);

	// STEP1: sort the array src[]
	for(int i = 0; i<length-1; i++){
		for(int j=i; j<length-1;j++){ 
			if(src[j]>src[j+1]){
				int temp = src[j];
				src[j]=src[j+1];
				src[j+1] = temp;
			}
		}
	}

	// STEP2: Analyze the sorted array, 
	//    save each different number to array a1
	//    save the appearence time to array a2
	int k=1,j=0; 
	a1[0]=src[0]; 
	a2[0]++; 
	while(k<length){ 
		if(src[k]!=src[k-1]){ 
			j++; 
			a1[j]=src[k];
			a2[j]++;
		} 
		else { 
			a2[j]++; 
		} 
		k++; 
	} 
	
	// STEP3: Find out the max number and times
	int times=0, num=0; 
	for(int i1=0;i1<length;i1++){
		if(times<a2[i1]){ 
			times=a2[i1]; 
			num=i1; 
		} 
	} 	
	int maxnum = a1[num];
	
	//release memory
	delete []src; 
	delete []a1; 
	delete []a2; 

	return maxnum * times; 
}

class TextBlock {
public:
  const char& operator[](size_t position) const   // operator[] for
  { return text[position]; }                           // const objects
  char& operator[](size_t position)               // operator[] for
  { return text[position]; }                           // non-const objects

private:
   std::string text;
};


int main()
{ 
	int a[] ={1,2,3,4,4,5,6,4,6,6,4};
	int N = 12;

	//int a[] ={1};
	//int N = 1;

	int n1 = GetMostNumberSum(a, N);
	printf("%d",n1);
	
	return 0; 
} 
