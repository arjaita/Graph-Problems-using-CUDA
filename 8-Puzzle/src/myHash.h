/*
 *	Created on: 25-Mar-2015 5:03PM
 *	Author: RATHIN
 *
 *
 *	fact() function works on integer i.e. up to 12!
 *	getHash() also works on integer
 *
 */
#ifndef MYHASH_H_
#define MYHASH_H_

//#include <iostream>
//#include <cmath>
using namespace std;


__device__ __host__
int fact(int n){
	int x=1;
	for (int i = 1; i <= n; i++) {
		x *= i;
	}
	return x;
}

__device__ __host__
int getHash(int n,int len){
	int h=0, tmp;
	char *num = new char[len];
	//cout<<"sadsdgsdg";

	//convert to char array
	int f=len;
	for (int i = 0; i < len; ++i) {
		f--;
		tmp = (int)powf(10,f);	//gpu version of pow
		num[i] = n/tmp;
		n=n%tmp;
	}

	f=len;
	for (int i = 0; i < len ; ++i) {
		f--;
		if(num[i] > 0)
			h += num[i]*fact(f);
		for (int j = i+1; j < len; ++j) {
			if(num[j] > num[i]){
				num[j]--;
			}
		}
	}
	return h;
}

__device__ __host__
int getHash(char n[],int len){
	int h=0;
//	cout<<1234<<"**///**";
	char *num = new char[len];
	for (int i = 0; i < len; ++i) {
		num[i] = n[i] - '0';
	}

	int f=len;
	for (int i = 0; i < len ; ++i) {
		f--;
		if(num[i] > 0)
			h += num[i]*fact(f);
		for (int j = i+1; j < len; ++j) {
			if(num[j] > num[i]){
				num[j]--;
			}
		}
	}
//	cout<<1234<<"**//**"<<h;
	return h;
}


#endif /* MYHASH_H_ */
