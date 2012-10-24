#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "xtinystack.h"
#include "xgraph.h"


pgraph_t graph_create( lpcstr_t szConfig )
{
	pgraph_t pgraph;
	int tmp;
	int i,k;
	int * pn;

	FILE * fp;
	fp = fopen(szConfig, "r");

	pgraph = (pgraph_t)malloc(sizeof(graph_t));

	fscanf(fp, "%d", &pgraph->vertex_amt);
	pgraph->vertics = (int *)malloc(sizeof(int)*pgraph->vertex_amt);
	pgraph->edges = (int *)malloc(sizeof(int)*pgraph->vertex_amt*pgraph->vertex_amt);
	pgraph->tags = (int *)malloc(sizeof(int)*pgraph->vertex_amt);

	memset(pgraph->vertics, 0, sizeof(int)*pgraph->vertex_amt);

	for(i=0;i<pgraph->vertex_amt;++i)
	{
		for(k=0;k<pgraph->vertex_amt;++k)
		{
			fscanf(fp, "%d", &tmp);
			pn = graph_get_edge_ptr(pgraph, i, k);
			*pn = tmp;
		}
	}

	fclose(fp);

	memset(pgraph->tags, 0, sizeof(int)*pgraph->vertex_amt);
	return pgraph;
}

pgraph_t graph_create( int vertex_amt )
{
	pgraph_t pgraph;
	pgraph = (pgraph_t)malloc(sizeof(graph_t));

	pgraph->vertex_amt = vertex_amt;
	pgraph->vertics = (int *)malloc( sizeof(int) * vertex_amt );
	pgraph->edges = (int *)malloc( sizeof(int) * vertex_amt * vertex_amt );
	pgraph->tags = (int *)malloc( sizeof(int) * vertex_amt );

	graph_init(pgraph);

	return pgraph;
}


void graph_release( pgraph_t pgraph )
{
	if(pgraph!=NULL)
	{
		free(pgraph->edges);
		free(pgraph->tags);
		free(pgraph->vertics);
		free(pgraph);
	}
}


void graph_init(pgraph_t pgraph)
{
	if(pgraph!=NULL)
	{
		memset(pgraph->edges, 0,  sizeof(int) * pgraph->vertex_amt * pgraph->vertex_amt );
		memset(pgraph->tags, 0, sizeof(int)*pgraph->vertex_amt);
		memset(pgraph->vertics, 0, sizeof(int)*pgraph->vertex_amt);
	}
}

void graph_clear( pgraph_t pgraph )
{
	if(pgraph!=NULL)
	{
		memset(pgraph->tags, 0, sizeof(int)*pgraph->vertex_amt);
		memset(pgraph->vertics, 0, sizeof(int)*pgraph->vertex_amt);
	}
}


void graph_print(pgraph_t pgraph)
{
	int i,k;
	printf("#vertices\n");	
	for(i=0;i<pgraph->vertex_amt;++i)
	{
		printf("%d ", pgraph->vertics[i]);
	}
	printf("\n");

	printf("#edges\n");
	for(i=0;i<pgraph->vertex_amt;++i)
	{
		for(k=0;k<pgraph->vertex_amt;++k)
		{
			printf("%d ", *graph_get_edge_ptr(pgraph, i, k));
		}
		printf("\n");
	}
	printf("\n");
}

void graph_ergod_depth_first( pgraph_t pgraph, int vi_start, func_graph_ergod_t pfunc )
{
	ptinystack_t lv_stack;
	int i;
	int gep;
	int gep_last;

	lv_stack = stack_create(MAX_GRAPH_VECTEX_AMT);
	stack_clear(lv_stack);	
	for(i=0;i<pgraph->vertex_amt;++i)
	{
		pgraph->tags[i] = 0;
	}

	gep = vi_start; // begin vertex
	pfunc(pgraph, gep);
	while(1)
	{		
		gep_last = gep;
		gep = graph_find_free_neighbour(pgraph, gep);
		if(gep!=-1)
		{
			stack_push(lv_stack, gep_last);	//找到未访问的节点后再压栈
			pfunc(pgraph, gep);
		}
		else
		{
			if(stack_empty(lv_stack))
			{
				break;
			}
			else
			{
				gep = stack_gettop(lv_stack);
				stack_pop(lv_stack);
			}

		}
	}

	stack_release(lv_stack);
	return;

}

//深度优先遍历, 计算起始点到其他节点的距离
void graph_ergod_for_travel_cost( pgraph_t pgraph, int vi_start )
{
	for(int i=0;i<pgraph->vertex_amt;++i)
	{
		pgraph->vertics[i] = INT_MAX;
	}
	pgraph->vertics[vi_start] = 0;

	graph_ergod_depth_first(pgraph, vi_start, graph_vertex_action_for_travel_cost);
}

void graph_vertex_action_for_travel_cost( pgraph_t pgraph, int n_vi )
{
	pgraph->tags[n_vi] = 1; //mark it has been accessed

	int i, edge_power;
	for(i=0;i<pgraph->vertex_amt;++i)
	{
		edge_power = *graph_get_edge_ptr(pgraph, n_vi, i);
		if(edge_power!=0)
		{
			if( (pgraph->vertics[n_vi]+edge_power) < pgraph->vertics[i] )
			{
				pgraph->vertics[i] = pgraph->vertics[n_vi]+edge_power;
			}	
		}
	}
}



//rts: -1 = fail
int graph_find_free_neighbour( pgraph_t pgraph, int n_vi )
{
	int i, edge;
	for(i=0;i<pgraph->vertex_amt;++i)
	{
		edge = *graph_get_edge_ptr(pgraph, n_vi, i);
		if(edge!=0 && pgraph->tags[i]==0)
		{
			return i;
		}
	}
	return -1;
}



int* graph_get_edge_ptr( pgraph_t pgraph, int si, int di )
{
	if(pgraph==NULL)
		return NULL;

	return &(pgraph->edges[si*pgraph->vertex_amt + di]);
}


//寻找邻居的算子
int graph_get_neighbour( pgraph_t pgraph, int vi_start, int iterator )
{
	if(pgraph==NULL)
		return -1;
	 if(iterator<-1)
		 return -1;

	for(int i=(++iterator); i<pgraph->vertex_amt; ++i)
	{
		int edge_power = *graph_get_edge_ptr(pgraph, vi_start, i);
		if(edge_power!=0)
		{
			return i;
		}
	}

	return -1;
}



int graph_get_nearest_neighbour( pgraph_t pgraph, int vi_start )
{
	if(pgraph==NULL)
		return -1;

	int vi_nearest = -1;
	int power_nearest = -1;
	for(int i=0;i<pgraph->vertex_amt;++i)
	{
		int edge_power = *graph_get_edge_ptr(pgraph, vi_start, i);
		if(edge_power!=0)
		{
			if(vi_nearest==-1 || edge_power<power_nearest)
			{
				vi_nearest = i;
				power_nearest = edge_power;
			}
		}
	}

	return vi_nearest;
}


int graph_get_lowest_value_neighbour(pgraph_t pgraph, int vi)
{
	if(pgraph==NULL)
		return -1;

	int lowest_vi = -1;
	int lowest_value = -1;
	int it = -1;
	while(1)
	{
		it = graph_get_neighbour(pgraph, vi, it);
		if(it==-1)
		{
			break;
		}

		if(lowest_vi==-1 || pgraph->vertics[lowest_vi]<lowest_value)
		{
			lowest_vi = it;
			lowest_value = pgraph->vertics[lowest_vi];
		}
	}

	return lowest_vi;
}

int graph_find_best_path( pgraph_t pgraph, int vi_start, int vi_end, int* pwaypoint, int waypoint_max )
{
	if(pgraph==NULL)
		return -1;

	graph_clear(pgraph);
	graph_ergod_for_travel_cost(pgraph, vi_start);


	int tmp_waypoint[MAX_GRAPH_VECTEX_AMT];
	int len_waypoint = 0;

	tmp_waypoint[len_waypoint++] = vi_end;
	//逆向寻找路点
	int it = vi_end;
	while(it!=vi_start)
	{
		it = graph_get_lowest_value_neighbour(pgraph, it);
		if(it==-1)
		{
			break;
		}

		//记录路点
		tmp_waypoint[len_waypoint++] = it;
	}


	if(tmp_waypoint[len_waypoint-1]!=vi_start)
	{
		//路径不存在
		return -1;
	}

	if(waypoint_max < len_waypoint)
	{
		//返回值缓冲不够
		return -1;
	}


	//将路点逆序
	for(int i=0; i<len_waypoint; ++i)
	{
		pwaypoint[i] = tmp_waypoint[ len_waypoint - i - 1 ];
	}

	return len_waypoint;
}

