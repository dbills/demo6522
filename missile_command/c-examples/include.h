#include <stdio.h>
#include <endian.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include "errors.h"

#define countof(A) (sizeof(A)/sizeof(A[0]))
#define failed_errno(MSG) _failed_errno(__FILE__, __func__, __LINE__ , MSG);
#define failed_errno_1(MSG, MSG1) _failed_errno_1(__FILE__, __func__, __LINE__, MSG, MSG1);

