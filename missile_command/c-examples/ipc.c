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
      fprintf(stderr, "%s is not a named pipe.  Please remove it\n", pipe_name);
      exit(1);
    }
  }
}

void make_command_pipes() {
  make_command_pipe(pipe_input);
  make_command_pipe(pipe_output);
}

static int open_input_pipe() {
  int fd = open(pipe_input, O_RDONLY);
  if(-1 == fd)
    failed_errno("open");
  return fd;
}

static int open_output_pipe() {
  int fd = open(pipe_output, O_WRONLY);
  if(-1 == fd)
    failed_errno("open");
  return fd;
}

void read_command_pipe() {
  int input_fd = open_input_pipe();
  printf("read pipe\n");
  char buf[256];
  ssize_t b_read = 0;
  int i = 0;
  while((b_read = read(input_fd, &buf[i], sizeof(buf) - i)) > 0) {
    printf("b=%d\n", (int)b_read);
    i += b_read;
  }
  buf[i]=0;
  if(-1 == b_read) {
    perror("read");
  }
  close(input_fd);
  printf("GOT %s\n", buf);
  int output_fd = open_output_pipe();
  strcpy(buf,"hello\n");
  write(output_fd, buf, strlen(buf));
  close(output_fd);
}
