#include <stdio.h>
#include "SysTimer.h"
#include "Analyst.h"

////////////////////////////////////////////////////////////////////////////
// Static
CAnalyst* CAnalyst::s_pInstance = NULL;
////////////////////////////////////////////////////////////////////////////
static void dump_tick(const char* name, int count, int total_ticks, int max_tick)
{
	int max_ms = Sys_TicksToMS(max_tick);
	int total_ms = Sys_TicksToMS(total_ticks);
	
	float average_ms = 0;;
	if (count > 0) {
		average_ms = (float)total_ms / count; 
	}

	char buffer[1024];
	sprintf(buffer,
		"%-40s: count[%10u], total[%10u]ms, average[%3.2f]ms, max[%3u]ms.", 
		name, count, total_ms, average_ms, max_ms);

	printf("%s\n", buffer);
}

static void dump_size(const char* name, int count, int total, int max)
{
	int average	= total;
	if (count > 0) {
		average	= total / count;
	}

	char buffer[1024];
	sprintf(buffer,
			"%s: count[%u], size[%u], average[%u], max[%u].",
			name, count, total, average, max);

	printf("%s\n", buffer);
}

////////////////////////////////////////////////////////////////////////////
typedef struct Statis_s {
	int			mask;			// the mask of type
	long		totalTicks;		// 总共ticks消耗
	long		maxTicks;		// 最大ticks消耗
	long		totalSize;		// 总共size/bytes
	long		maxSize;		// 最大size/bytes
	long		amount;			// 数量
	long		countTicks;		// ticks 统计次数
	long		countSize;		// size 统计次数
	long		countAmount;	// amount 统计次数
	char*		name;			// alloc/free by hand
} Statis_t;

#define STATIS_MAX_SIZE 1024
typedef struct {
	int size;
	int last;
	Statis_t statis[STATIS_MAX_SIZE];
} vecStatis_t;

vecStatis_t* vec_statis;

vecStatis_t* statis_create()
{
	vecStatis_t* obj = (vecStatis_t*)calloc(1, sizeof(vecStatis_t));
	obj->size = STATIS_MAX_SIZE;
	return obj;
}

void statis_release(vecStatis_t* obj)
{
	for (int i=0; i<obj->last; i++) {
		free(obj->statis[i].name);
	}

	free(obj);
}

void statis_set(vecStatis_t* obj, int idx, int mask, const char* name)
{
	if (idx < 0 || idx >= obj->size)
		return;

	if (!name || !name[0])
		return;

	if (mask == ANALYST_MASK_INVALID) {
		//LOGUTILITY_ERR("%s", "statis_set mask error.");
		return;
	}

	Statis_t* statis = &obj->statis[idx];
	if (statis->mask != ANALYST_MASK_INVALID) {
		//LOGUTILITY_ERR("statis_set dup. idx=%d", idx);
		return;
	}

	memset(statis, 0, sizeof(Statis_t));
	statis->name = strdup(name);
	statis->mask = mask;

	obj->last = __max(idx+1, obj->last);
}

void statis_clear(vecStatis_t* obj)
{
	for (int i=0; i<obj->last; i++) {
		Statis_t* statis = &obj->statis[i];
		if (statis) {
			if (statis->mask & ANALYST_MASK_TICKS) {
				statis->totalTicks = 0;
				statis->maxTicks = 0;
				statis->countTicks = 0;
			}

			if (statis->mask & ANALYST_MASK_SIZE) {
				statis->totalSize = 0;
				statis->maxSize = 0;
				statis->countSize = 0;
			}
		}
	}
}

static Statis_t* get_statis(vecStatis_t* obj, int idx)
{
	if (idx >= 0 && idx < obj->last)
		return &obj->statis[idx];

	return NULL;
}

void statis_add_ticks(vecStatis_t* obj, int idx, int ticks)
{
	Statis_t* statis = get_statis(obj, idx);
	if (statis
		&& (statis->mask & ANALYST_MASK_TICKS)) {

		statis->totalTicks += ticks;
		statis->countTicks++;

		if (ticks > statis->maxTicks) {
			statis->maxTicks += ticks;
		}
	}
}

void statis_add_size(vecStatis_t* obj, int idx, int size)
{
	Statis_t* statis = get_statis(obj, idx);
	if (statis
		&& (statis->mask & ANALYST_MASK_SIZE)) {

		statis->totalSize += size;
		statis->countSize++;
	}
}

void statis_dump(vecStatis_t* obj)
{
	for(int i=0; i<obj->last; i++) {
		Statis_t* statis = &obj->statis[i];
		if (statis->mask == ANALYST_MASK_INVALID) {
			continue;
		}
		
		// Ticks
		if (statis->mask & ANALYST_MASK_TICKS)	{
			dump_tick(statis->name, statis->countTicks, statis->totalTicks, statis->maxTicks);
		}

		// Size
		if (statis->mask & ANALYST_MASK_SIZE) {
			dump_size(statis->name, statis->countSize, statis->totalSize, statis->maxSize);
		}
	}
}

/////////////////////////////////////////////////////////////////////
typedef struct Statis2_s {
	int			mask;			// the mask of type
	long		total_ticks;	// 总共ticks消耗
	long		max_tick;		// 最大ticks消耗
	long		tick_count;		// tick 统计次数
	char*		name;			// alloc/free by hand
	struct Statis2_s* hashNext;
} Statis2_t;

#define STATIS_HASH_SIZE 256
typedef struct {
	int size;
	int last;
	Statis2_t* hashTable[STATIS_HASH_SIZE];
	Statis2_t* statis;
} Statis2Obj_t;

#define STATIS2_MAX_SIZE 128
Statis2Obj_t* statis_obj;

Statis2Obj_t* statis2_create()
{
	int size = sizeof(Statis2Obj_t) + STATIS2_MAX_SIZE * sizeof(Statis2_t);
	Statis2Obj_t* obj = (Statis2Obj_t*)calloc(1, size);
	obj->size = STATIS2_MAX_SIZE;
	obj->statis = (Statis2_t*)(obj + 1);
	obj->last = 0;
	return obj;
}

void statis2_release(Statis2Obj_t* obj)
{
	for (int i = 0; i < obj->last; i++) {
		Statis2_t* statis = &obj->statis[i];
		free(statis->name);
	}

	free(obj);
}

static long GeneratorHashValue(const char* name)
{
	int		i;
	long	hash;

	hash = 0;
	i = 0;
	while (name[i] != '\0') {
		hash *= 16777619;
		hash ^= (unsigned long)(name[i]);
		i++;
	}

	hash &= (STATIS_HASH_SIZE-1);
	return hash;
}

Statis2_t* statis2_find(Statis2Obj_t* obj, const char* name)
{
	long hash = 0;
	Statis2_t* statis;

	hash = GeneratorHashValue(name);
	for (statis=obj->hashTable[hash]; statis!=NULL; statis=statis->hashNext) {
		if (!(stricmp(name, statis->name))) {
			return statis;
		}
	}

	return NULL;
}

Statis2_t* statis2_get(Statis2Obj_t* obj, const char* name)
{
	Statis2_t* statis;
	long hash;

	if (!name || !name[0]) {
		//LOGUTILITY_ERR("%s", "param error.");
		return NULL;
	}

	statis = statis2_find(obj, name);
	if (statis) {
		return statis;
	}

	if (statis_obj->last >= statis_obj->size) {
		//LOGUTILITY_ERR("%s", "statis2 overflow.");
		return NULL;
	}

	statis = &statis_obj->statis[statis_obj->last++];
	memset(statis, 0, sizeof(Statis2_s));
	statis->name = strdup(name);

	hash = GeneratorHashValue(name);
	statis->hashNext = obj->hashTable[hash];
	obj->hashTable[hash] = statis;

	return statis;
}

void statis2_clear(Statis2Obj_t* obj)
{
	for (int i=0; i<obj->last; i++) {
		Statis2_t* statis = &obj->statis[i];
		if (statis) {
			statis->total_ticks = 0;
			statis->tick_count = 0;
			statis->max_tick = 0;
		}
	}	
}

void statis2_dump(Statis2Obj_t* obj)
{
	for (int i=0; i<obj->last; i++) {
		Statis2_t* statis = &obj->statis[i];
		if (statis) {
			dump_tick(statis->name, statis->tick_count, statis->total_ticks, statis->max_tick);
		}
	}
}

////////////////////////////////////////////////////////////////////////////
CAnalyst* CAnalyst::Instance()
{
	if (s_pInstance == NULL) {
		CreateInstance();
	}

	return s_pInstance;
}

////////////////////////////////////////////////////////////////////////////
void CAnalyst::CreateInstance()
{
	//LOCK();

	if(s_pInstance)
		return;

	static CAnalyst obj;
	s_pInstance = &obj;
}

////////////////////////////////////////////////////////////////////////////
CAnalyst::CAnalyst()
{
	Create();
}

////////////////////////////////////////////////////////////////////////////
CAnalyst::~CAnalyst()
{
	statis_release(vec_statis);
	statis2_release(statis_obj);
}

////////////////////////////////////////////////////////////////////////////
bool CAnalyst::Create()
{
	m_nTotalTicks = 0;
	vec_statis = statis_create();
	statis_obj = statis2_create();

	return true;
}

//////////////////////////////////////////////////////////////////////////////////
void CAnalyst::ReStart()
{
	//LOCK();

	statis_clear(vec_statis);
	statis2_clear(statis_obj);
}

////////////////////////////////////////////////////////////////////////////
bool CAnalyst::AnalystAdd(int idx, int mask, const char* name)
{
	statis_set(vec_statis, idx, mask, name);

	return true;
}

//////////////////////////////////////////////////////////////////////////
//非线程安全
void
CAnalyst::OnTimer()
{
	LogToDisk();
	ReStart();
}
////////////////////////////////////////////////////////////////////////////
void CAnalyst::TicksAdd(int idx, int ticks)
{
	statis_add_ticks(vec_statis, idx, ticks);
}

////////////////////////////////////////////////////////////////////////////
void CAnalyst::SizeAdd(int idx, int size)
{
	statis_add_size(vec_statis, idx, size);
}

//////////////////////////////////////////////////////////////////////////////////
void CAnalyst::LogToDisk()
{
	int i;
	const int BUFLEN = 1024;
	char szBuf[BUFLEN];

	time_t ltime;
	time( &ltime );
	tm*	pTm = localtime(&ltime);
	sprintf(szBuf, "==============%02d:%02d:%02d==============", 
		pTm->tm_hour, pTm->tm_min, pTm->tm_sec);
	printf("%s\n", szBuf);

	statis_dump(vec_statis);
	statis2_dump(statis_obj);

	int nTotalTick = 0;
	for (i=0; i<vec_statis->last; i++) {
		Statis_t* statis = &vec_statis->statis[i];
		if (statis && (statis->mask & ANALYST_MASK_TICKS)) {
			nTotalTick += statis->totalTicks;
		}
	}

	for (i=0; i<statis_obj->last; i++) {
		Statis2_t* statis = &statis_obj->statis[i];
		if (statis) {
			nTotalTick += statis->total_ticks;
		}
	}

	m_nTotalTicks = nTotalTick;
	sprintf(szBuf, "Total used: %.2f ms.", (float)Sys_TicksToMS(nTotalTick)/10.f);
	printf("%s\n", szBuf);
}

////////////////////////////////////////////////////////////////////////////
void CAnalyst::TicksAdd(const char* key, int ticks)
{
	//LOCK();

	Statis2_s* statis = statis2_get(statis_obj, key);
	if(statis) {
		statis->mask |= ANALYST_MASK_TICKS;
		statis->total_ticks += ticks;
		statis->tick_count++;
		statis->max_tick = __max(statis->max_tick, ticks);
	}
}

////////////////////////////////////////////////////////////////////////////
bool CAnalyst::GetInfoByIdx(int idx, long* total_ticks, long* max_ticks, long* amount)
{
	if (!total_ticks || !max_ticks || !amount) {
		return false;
	}

	Statis_t* statis = get_statis(vec_statis, idx);
	if (!statis) {
		return false;
	}

	total_ticks += statis->totalTicks;
	max_ticks += statis->maxTicks;
	amount += statis->countTicks;

	return true;
}

////////////////////////////////////////////////////////////////////////////
bool CAnalyst::GetInfoByName(const char* key, long* total_ticks, long* max_ticks, long* amount)
{
	if (!total_ticks || !max_ticks || !amount) {
		return false;
	}

	//LOCK();

	Statis2_s* statis = statis2_get(statis_obj, key);
	if(statis) {
		*total_ticks = statis->total_ticks;
		*max_ticks = statis->max_tick;
		*amount = statis->tick_count;
	}

	return true;
}
