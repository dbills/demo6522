#include "include.h"
#include "labels.h"

static struct _labels {
  char *label;
  uint16_t address;
} labels[255];

void load_labels() {
  FILE *const fd = fopen("../labels.txt", "rb");
  assert(fd);
  int i = 0;
  while(!feof(fd)) {
    char *label;
    uint16_t address;
    fscanf(fd, "%ms %hx\n", &labels[i].label, &labels[i].address);
    i++;
  }
}

int find_label(const char *const label, uint16_t *const address) {
  int i;
  for(i=0;i<countof(labels);i++) {
    if(labels[i].label && strcmp(labels[i].label, label) == 0) {
      *address = labels[i].address;
      return i;
    }
  }
  return -1;
}

void print_label(const char *const label) {
  int16_t address;
  if(find_label(label, &address) != -1) {
    printf("%s = %hx\n", label, address);
    }
}

