#include <stdio.h>
#include <stdlib.h>

void _warn_errno(const char *const file, const char *const func, const int line, const char *const msg) {
  fprintf(stderr, "%s:%d:0: %s Warning:", file, line, func);
  perror(msg);
}
int _failed_errno(const char *const file, const char *const func, const int line, const char *const msg) {
  fprintf(stderr, "%s:%d:0: %s Error:", file, line, func);
  perror(msg);
  exit(1);
}
int _failed_errno_1(const char *const file, const char *const func, const int line, const char *const msg, const char *const msg1) {
  fprintf(stderr, "%s:%d:0: %s Error: %s ", file, line, func, msg1);
  perror(msg);
  exit(1);
}
