#include <stdio.h>

#define tokn(A) {#A,A}

enum {
  COMMENT_BEGIN,
  COMMENT_END,
  IDENTIFIER
};

#define backup ungetc(c,stdin);
static char buf[256];

static char parser_buf[256];

void found_token(int t) {

  printf("GOT %d:%s\n",t,buf);
  if(t==COMMENT_BEGIN) {
    strcpy(parser_buf, buf);
  }
}

void try_char(int ch,int token) {
  int c;
  if((c = getchar()) == ch)
    found_token(token);
  else
    backup;
}
char *read_to_char(int t) {
  int i=0;
  while(1) {
    int c=getchar();
    if(c==EOF)
      return buf;
    if(c==t) {
      backup;
      return buf;
    }
    buf[i++]=c;
  }
}

void read_while(int (*f)(int)) {
  int c;
  int i=0;
  while((c=getchar())!=EOF) {
    if(!(*f)(c)) {
      backup;
      found_token(IDENTIFIER);
      return;
    }
    buf[i++]=c;
  }
}
int main() {
  parser_buf[0]=0;
  while(!feof(stdin)) {
    int c=getchar();
    buf[0]=0;
    if(c=='#') read_to_char('\n');
    if(c=='/') try_char('*',COMMENT_BEGIN);
    if(c=='*') try_char('/',COMMENT_END);
    if(isalnum(c)) read_while(isalnum);
  }
}

