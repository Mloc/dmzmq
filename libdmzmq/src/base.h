#ifndef BASE_H
#define BASE_H

#include <stdlib.h>

#define MAX(a,b) ((a) > (b) ? a : b)
#define MIN(a,b) ((a) < (b) ? a : b)

#ifdef _WIN32
    #define DLL_EXPORT __declspec(dllexport)
#else
    #define DLL_EXPORT __attribute__((visibility ("default")))
#endif

#define _STRINGIFY(x) #x
#define STRINGIFY(x) _STRINGIFY(x)
#define DMZMQ_ASSERT(pred)\
if(!(pred))\
{\
    return "ERR:ASSERTFAILED ("__FILE__":"STRINGIFY(__LINE__)" "#pred")";\
}

int array_search_int(const int *haystack, int needle, size_t size);

#endif//BASE_H
