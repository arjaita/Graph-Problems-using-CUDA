/*
 * kernel.h
 *
 *  Created on: May 7, 2015
 *      Author: cuda
 */

#ifndef KERNEL_H_
#define KERNEL_H_

__device__ int rf=0;
__device__ int gf=0;
__device__ bool d_stop=false;

__global__ void
Kernel( Node* g_graph_nodes, int* g_graph_edges, bool* g_graph_mask, bool* g_updating_graph_mask, bool *g_Red_graph_visited,bool *g_Green_graph_visited, bool *g_Red_updating_graph_visited, bool *g_Green_updating_graph_visited, int* g_cost, int no_of_nodes, bool* g_over)
{
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	if( tid<no_of_nodes && g_graph_mask[tid])
	{
//		printf("\n%dT",tid);
		g_graph_mask[tid]=false;
		for(int i=g_graph_nodes[tid].starting; i<(g_graph_nodes[tid].no_of_edges + g_graph_nodes[tid].starting); i++)
		{
			int nid = g_graph_edges[i];
//			printf("\n%dT:%dN",tid,nid);
			if(g_Red_graph_visited[nid] || g_Green_graph_visited[nid])
			{
				if(g_Red_graph_visited[tid] && g_Green_graph_visited[nid])
				{
					rf = g_cost[tid]+1;
					*g_over = true;
					d_stop=true;
				}
				if(g_Green_graph_visited[tid] && g_Red_graph_visited[nid])
				{
					*g_over=true;
					d_stop=true;
				}

			}
			else
			{
				if(g_Green_graph_visited[tid])
					g_Green_updating_graph_visited[nid] = true;
				if(g_Red_graph_visited[tid])
					g_Red_updating_graph_visited[nid] = true;

				g_updating_graph_mask[nid]=true;
				g_cost[nid] = g_cost[tid]+1;
			}

		}
	}
}

__global__ void
Kernel2( bool* g_graph_mask, bool * g_updating_graph_mask, bool * g_Red_graph_visited,bool * g_Green_graph_visited, bool * g_Red_updating_graph_visited, bool * g_Green_updating_graph_visited, bool *g_over, int no_of_nodes,int* g_cost)
{
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	if( tid<no_of_nodes && g_updating_graph_mask[tid] && !d_stop)
	{
		//printf("\n%dT",tid);
		g_graph_mask[tid]=true;
		if(g_Red_updating_graph_visited[tid])
		{
			g_Red_graph_visited[tid] = true;
			rf = g_cost[tid];
			g_Red_updating_graph_visited[tid] = false;
		}
		if(g_Green_updating_graph_visited[tid])
		{
			g_Green_graph_visited[tid] = true;
			gf = g_cost[tid];
			g_Green_updating_graph_visited[tid] = false;
		}
		g_updating_graph_mask[tid]=false;

		if(g_Green_graph_visited[tid] && g_Red_graph_visited[tid])
			*g_over=true;
	}
//	printf("\nlength = %d",rf);
//	printf("\nlength == %d",gf);
}

__global__
void dummy(int *len){
	printf("R%dG%d",rf,gf);
	*len = rf+gf;
}


#endif /* KERNEL_H_ */
