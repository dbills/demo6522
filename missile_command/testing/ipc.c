#include "include.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

static const char *const pipe_input = "/tmp/fake6502.stdin";
static const char *const pipe_output = "/tmp/fake6502.stdout";

static void make_command_pipe(const char *const pipe_name) {
  struct stat buf;
  if(-1 == stat(pipe_name, &buf)) {
    if(errno == ENOENT) {
      if(0 != mkfifo(pipe_name, S_IRUSR | S_IWUSR))
        failed_errno_1("mkfifo", pipe_name);
    } else
      failed_errno_1("stat", pipe_name);
  } else {
    if((buf.st_mode & S_IFMT) != S_IFIFO) {
      fprintf(stderr, "%s is not a named pipe.  Please remove it.\n", pipe_name);
      exit(1);
    }
  }
}

void make_command_pipes() {
  make_command_pipe(pipe_input);
  make_command_pipe(pipe_output);
}

static int open_input_pipe() {
  const int fd = open(pipe_input, O_RDONLY);
  if(-1 == fd)
    failed_errno("open");
  return fd;
}

static int open_output_pipe() {
  const int fd = open(pipe_output, O_WRONLY);
  if(-1 == fd)
    failed_errno("open");
  return fd;
}

void write_response_pipe(const char *const msg) {
  const int size = strlen(msg);
  const int output_fd = open_output_pipe();
  const int rtn = write(output_fd, msg, size);
  close(output_fd);
  if(-1 == rtn)
    warn_errno("write");
  else if(rtn != size) {
    fprintf(stderr, "%s incomplete write\n", __func__);
  } 
}

// RETURNS: "" or null terminated message
char *read_command_pipe() {
  const int input_fd = open_input_pipe();
  static char buf[256];
  const int szbuf = sizeof(buf) - 1;
  ssize_t b_read = 0;
  int i = 0;
  while((b_read = read(input_fd, &buf[i], szbuf - i)) > 0) {
    i += b_read;
  }
  close(input_fd);
  buf[i] = 0;
  if(-1 == b_read) {
    perror("read");
  }
  return buf;
}
