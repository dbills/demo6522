while(<STDIN>) {
    chop();
    @notes = split /,/;
    foreach(@notes) {
        print "$_\n";
    }
        
}
