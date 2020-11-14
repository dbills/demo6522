# convert .inc file to .h file
while(<STDIN>) {
    if(/.import (.*)/) {
        @syms = split(',',$1);
        
        foreach $s (@syms) {
            print "sym=$s\n";
        }
    }
}
