#include <stdio.h>

int _failed_errno(const char *const file, const char *const func, const int line, const char *const msg) {
  fprintf(stderr, "%s:%d:0: %s", file, line, func);
  perror(msg);
  return -1;
}
int _failed_errno_1(const char *const file, const char *const func, const int line, const char *const msg, const char *const msg1) {
  fprintf(stderr, "%s:%d:0: %s Error: %s ", file, line, func, msg1);
  perror(msg);
  return -1;
}
