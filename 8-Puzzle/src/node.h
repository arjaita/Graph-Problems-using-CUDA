/*
 * node.h
 *
 *  Created on: 25-Mar-2015
 *      Author: cuda
 */

#ifndef NODE_H_
#define NODE_H_

#include <iostream>
#include <string>
#include "myHash.h"
using namespace std;

#define DIM 3
#define CHILD 4
#define LEN 10

enum Move{UP, DOWN, LEFT, RIGHT};

class State{
	public:
//		int a[DIM][DIM];
		char a[LEN];
		int pos;
	public:
		__device__ __host__
		State(){
//			a = new int[3][3];
			pos = -1;
			a[LEN-1] = '\0';
		}

		__device__ __host__
		void swap(int p){
			int x=pos;
			int y=pos+p;
			char tmp = a[x];
			a[x] = a[y];
			a[y] = tmp;
			pos = y;
		}
};

class node {

	//public: static int count; //not supported
	public:
		State state;
		node *parent;
		node **child;
		int depth;
	public:
		__device__ __host__
		node(){
			depth = 0;
			parent = NULL;
			child = new node*[CHILD];
//			count++;
		}
		__device__ __host__
		node(node *x){
			depth = 0;
//			child = new node*[4];
			child = new node*[CHILD];
			parent = NULL;
			for (int i = 0; i < LEN; ++i) {
				this->state.a[i] = x->state.a[i];
			}
			this->state.pos = x->state.pos;
//			count++;
		}

		__device__ __host__
		~node(){
			delete[] child;
		}
		__device__ __host__
		node* move(Move m){
			int i,j;
			i=this->state.pos/3;
			j=this->state.pos%3;
			node *x = NULL;
			switch(m){
				case UP:
					if(i==0)
						return NULL;
					x = new node(this);
					x->state.swap(-3);
					x->parent = this;
					return x;
				case DOWN:
					if(i==2)
						return NULL;
					x = new node(this);
					x->state.swap(3);
					x->parent = this;
					return x;
				case LEFT:
					if(j==0)
						return NULL;
					x = new node(this);
					x->state.swap(-1);
					x->parent = this;
					return x;
				case RIGHT:
					if(j==2)
						return NULL;
					x = new node(this);
					x->state.swap(1);
					x->parent = this;
					return x;

				default: return NULL;
			}
		}

		node* createChild(){
			for (int i = UP; i <= RIGHT; ++i) {
				child[i] = move((Move)i);
				child[i]->parent = this;
			}
			return this;
		}

		void show(){
			if(this == NULL){
				cout<<"null"<<endl;
				return;
			}
			for (int i = 0; i < LEN; ++i) {
				cout<<state.a[i];
				//if(i%DIM == 2)
					//cout<<endl;
			}
			cout<<endl;
		}

		string getCode(){
			return string(state.a);
		}

		__device__ __host__
		int getIndex(){
			return getHash(state.a,LEN-1);
		}

};
//int node::count;


#endif /* NODE_H_ */
