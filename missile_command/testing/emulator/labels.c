#include "include.h"
#include "labels.h"

static struct _labels {
  char *label;
  uint16_t address;
} labels[255];

BOOL load_labels(const char *const file) {
  FILE *const fd = fopen(file, "rb");
  if(!fd) {
    fprintf(stderr, "cannot open %s\n", file);
    perror("Error");
    return FALSE;
  }
  int i = 0;
  while(!feof(fd)) {
    fscanf(fd, "%ms %hx\n", &labels[i].label, &labels[i].address);
    i++;
  }
  return TRUE;
}

uint16_t get_label(const char *const label) {
  uint16_t address;
  if(find_label(label, &address) != -1) {
    return address;
  } else {
    return warn_msg("can't find label");
  }
}

const char *const find_address(const uint16_t address) {
  int i;
  for(i=0;i<countof(labels);i++) {
    if(labels[i].address == address)
      return labels[i].label;
  }
  return NULL;
}

int find_label(const char *const label, uint16_t *const address) {
  int i;
  for(i=0;i<countof(labels);i++) {
    if(labels[i].label && strcmp(labels[i].label, label) == 0) {
      *address = labels[i].address;
      return i;
    }
  }
  *address = 0;
  return -1;
}

void print_label(const char *const label) {
  uint16_t address;
  if(find_label(label, &address) != -1) {
    printf("%s = %hx\n", label, address);
    }
}

