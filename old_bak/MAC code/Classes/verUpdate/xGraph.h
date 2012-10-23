/*
图的数据结构, 图的遍历算法, 图的最短路径算法
*/

#ifndef _XGRAPH_H_
#define _XGRAPH_H_

#define MAX_GRAPH_VECTEX_AMT (0x1000)

typedef const char* lpcstr_t;

typedef struct {
	int vertex_amt;
	int* vertics;
	int* edges;
	int* tags;
}graph_t, *pgraph_t;

typedef void (*func_graph_ergod_t)(pgraph_t, int);

pgraph_t graph_create( lpcstr_t szConfig );
pgraph_t graph_create( int vertex_amt );
void graph_release( pgraph_t pgraph );
void graph_init( pgraph_t pgraph );
void graph_clear( pgraph_t pgraph );

//获取图的边指针
int* graph_get_edge_ptr( pgraph_t pgraph, int si, int di );
//获取节点的一个邻居
int graph_get_neighbour( pgraph_t pgraph, int vi_start, int iterator );
//获取路径最短的邻居
int graph_get_nearest_neighbour( pgraph_t pgraph, int vi_start );
//深度优先遍历
void graph_ergod_depth_first( pgraph_t pgraph, int vi_start, func_graph_ergod_t pfunc );



void graph_print( pgraph_t pgraph );
//寻找一个未访问过的邻居
int graph_find_free_neighbour( pgraph_t pgraph, int n_vi );
//寻找最优路径
int graph_find_best_path( pgraph_t pgraph, int vi_start, int vi_end, int* pvi, int vi_max );
int graph_get_lowest_value_neighbour(pgraph_t pgraph, int vi);
//计算周游代价的遍历
void graph_ergod_for_travel_cost( pgraph_t pgraph, int vi_start );
//周游代价计算时, 对顶点的操作
void graph_vertex_action_for_travel_cost( pgraph_t pgraph, int n_vi );

#endif //_XGRAPH_H_