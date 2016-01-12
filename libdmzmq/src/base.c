// base support functions

#include "base.h"

int array_search_int(const int *haystack, int needle, size_t size)
{
    int i;
    for(i = 0; i < size; i++)
    {
        if(haystack[i] == needle)
        {
            return 1;
        }
    }
    return 0;
}
