#include <iostream>
#include <queue>
#include <malloc.h>
#include <assert.h>
#include <stdio.h>
#include "myHash.h"
#include "node.h"



using namespace std;

#define SIZE 362880
#define CUDA_CHECK_RETURN(value) {											\
	cudaError_t _m_cudaStat = value;										\
	if (_m_cudaStat != cudaSuccess) {										\
		fprintf(stderr, "Error %s at line %d in file %s\n",					\
				cudaGetErrorString(_m_cudaStat), __LINE__, __FILE__);		\
		exit(1);															\
	} }

__global__
void dum(){

}

__device__ bool *frontier;	//Fa
__device__ bool *Ufrontier;	//Fua
__device__ bool *V;	//Xa


//node *visited[SIZE]; //could not create
__device__ node **visited;

__device__ node *initial, *goal;
__device__ int gIndex;


//__device__ bool fin;

//__global__ void initBFS(bool *fin) {
__global__ void initBFS() {

	int index;
	index = initial->getIndex();
	frontier[index] = true; //enQueu
	visited[index] = initial; //mark as visited
	V[index] = true;
	//*fin = false;
}

__device__
void clear() {
	delete[] visited;

	//add......
}

__global__
void createBFS(){
	node *x,*adj;
//	printf("\nin bfs\n");
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
//	int k=5;
//	if(tid < SIZE && tid == gIndex){
//		*l = 64;
//	}
	int index;
//	do{
//		if(tid == 45507)
//			printf("^^^%d:%d",k,frontier[tid]);

		if(tid < SIZE && frontier[tid]){	//deQueue in parallel
//			printf("\nin bfs true\n");
			frontier[tid] = false;
			x = visited[tid];
//			if(k == 3)
//				printf("^^^%d",tid);
//			printf("%d:%s\n",tid,x->state.a);
//
//			if(tid == gIndex){	//Reached Goal
//				*fin = true;
//				*l = x->depth;
//				continue;
//			}else{
				for (int i = UP; i <= RIGHT; ++i) {
					adj = x->move((Move)i);
//					if(tid == 46227)
//						printf("\n%d:",i);
					if(adj == NULL)
						continue;
					index = adj->getIndex();
//					if(tid == 46227)
//						printf("%d",index);
					if(!V[index]){
						x->child[i] = adj;
						x->child[i]->depth = x->depth + 1;
						x->child[i]->parent = x;		//mark path
						visited[index] = x->child[i];	//mark as visited
						Ufrontier[index] = true;			//for each child enQueue and mark
//						if(tid == 46227)
//							printf("*****%d",frontier[index]);
					}else{
						x->child[i] = NULL;
					}

				}	//end for
		}	//end if
		//assert(!fin);
//		__syncthreads();
//		__threadfence_system();

		/*
		 * __synctreads() synchronizes all the threads in a block.
		 * there is no way to synchronize threads across blocks
		 * Inter-block GPU communication via fast barrier synchronization" from 2010 by Xiao and Feng (Virginia Tech) is a nice solution
		 * http://scholar.google.com/scholar?cluster=4900456939806066632
		 *
		 * The usual way to sync all threads in all blocks is to call two separate kernels
		 * The second kernel will not be run until the first has completed
		 *
		 * __threadfence_system()
		 */
//	}while(k--);

	//clear();
}	//end function


__global__
void k2(bool *g_over,int *l){


	int tid = blockIdx.x * blockDim.x + threadIdx.x;
//	printf("\nin k2\n");
	if(tid < SIZE && Ufrontier[tid]){
		frontier[tid] = true;
		V[tid] = true;
		//g_over = true;
//		printf("tid = %d , gindex = %d",tid,gIndex);
		if(tid == gIndex){	//Reached Goal
				*g_over = true;
				*l = visited[tid]->depth;
//				printf("\n in loop");
		}
		Ufrontier[tid] = false;
	}
}

__global__
void clearArray(){
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if(tid < SIZE){
		 frontier[tid] = false;	//Fa
		 Ufrontier[tid] = false;	//Fua
		 visited[tid]=NULL;
		 V[tid] = false;	//Xa


	}
}

__global__
void initialize(){
	initial = new node;
	initial->state.a[0] = '0';
	initial->state.a[1] = '1';
	initial->state.a[2] = '3';
	initial->state.a[3] = '4';
	initial->state.a[4] = '5';
	initial->state.a[5] = '6';
	initial->state.a[6] = '7';
	initial->state.a[7] = '8';
	initial->state.a[8] = '2';
	initial->state.pos = 0;
	initial->depth = 0;


	goal = new node;
	goal->state.a[0] = '5';
	goal->state.a[1] = '4';
	goal->state.a[2] = '3';
	goal->state.a[3] = '7';
	goal->state.a[4] = '8';
	goal->state.a[5] = '6';
	goal->state.a[6] = '1';
	goal->state.a[7] = '0';
	goal->state.a[8] = '2';
	goal->state.pos = 7;
	gIndex = goal->getIndex();


	visited = new node*[SIZE];	//
	frontier = new bool[SIZE];	//Fa
	Ufrontier = new bool[SIZE];	//Fua
	V = new bool[SIZE];	//Xa

}



int main(int argc, char **argv) {
//	time_t t1,t2;
//	time(&t1);
	clock_t t;
	t = clock();

//	cout<<"\n1\n";

	cout<<(float(clock()-t))/CLOCKS_PER_SEC<<endl;
	cudaDeviceProp dev;
	cudaGetDeviceProperties(&dev,0);
	int maxT = dev.maxThreadsPerBlock;
	cout<<(float(clock()-t))/CLOCKS_PER_SEC<<endl;

int number_of_blocks = (SIZE + maxT -1)/maxT;
int threadsPerBlock = maxT;

dum<<<1,1>>>();
	int len,*d_len;
	//len = (int*)malloc(sizeof(int));
	cudaMalloc((void**)&d_len,sizeof(int));
	cout<<(float(clock()-t))/CLOCKS_PER_SEC<<endl;

	initialize<<<1,1>>>();
//	CUDA_CHECK_RETURN(cudaThreadSynchronize());
	cout<<(float(clock()-t))/CLOCKS_PER_SEC<<endl;

	clearArray<<<number_of_blocks, threadsPerBlock>>>();
//	CUDA_CHECK_RETURN(cudaThreadSynchronize());

//bool fin = false,*d_fin;
//cudaMalloc((void**)&d_fin, sizeof(bool));

	initBFS<<<1,1>>>();

//	cout<<"\n2\n";



	cout<<(float(clock()-t))/CLOCKS_PER_SEC<<endl;
t = clock();
//cout<<"\n3\n";
//modification
int k=0;
bool stop = false;
bool *d_over;

cudaMalloc((void**) &d_over,sizeof(bool));
cudaMemcpy(d_over, &stop, sizeof(bool),cudaMemcpyHostToDevice);
//cout<<"\n4\n";
do{
//	stop = false;
//	cudaMemcpy(d_over, &stop, sizeof(bool),cudaMemcpyHostToDevice);

	createBFS<<<number_of_blocks, threadsPerBlock>>>();	//k1
//	CUDA_CHECK_RETURN(cudaDeviceSynchronize());

//	cout<<"\n5\n";
	k2<<<number_of_blocks, threadsPerBlock>>>(d_over,d_len);
//	cout<<"\n6\n";
	//cudaMemcpy( &stop, d_over, sizeof(bool), cudaMemcpyDeviceToHost) ;
	//cout<<d_over;
	CUDA_CHECK_RETURN(cudaMemcpy(&stop,d_over,sizeof(bool),cudaMemcpyDeviceToHost));
//	cout<<"stop = "<<stop<<"\n";


	//CUDA_CHECK_RETURN(cudaMemcpy(&stop,d_over,sizeof(bool),cudaMemcpyDeviceToHost));
//	cout<<"****"<<endl;

	k++;
//	if(k==15)
//	{
//		printf("\nbreak fourcefully\n");
//		break;
//	}
}while(!stop);
	//cout<<(float(clock()-t))/CLOCKS_PER_SEC<<endl;
//	CUDA_CHECK_RETURN(cudaGetLastError());
	//CUDA_CHECK_RETURN(cudaMemcpy(len,d_len,sizeof(int),cudaMemcpyDeviceToHost));

	cudaMemcpy( &len, d_len, sizeof(int), cudaMemcpyDeviceToHost);
	cout<<"\nlen = "<<len<<endl;

//	time(&t2);
//
//	cout<<difftime(t2,t1);
	cout<<(float(clock()-t))/CLOCKS_PER_SEC<<endl;

	cout<<"Kernel executed "<<k<<"times";

//	cudaFree(frontier);
//	cudaFree(Ufrontier);
//	cudaFree(V);

}



