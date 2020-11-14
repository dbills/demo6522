open(FH, '<' , $ARGV[0]) || die("failed to open $ARGV[0]\n");
while(<FH>) {
    if(/^([a-zA-Z_]+)\.o:/) {
        $module_list_file = $1.".lst";
        push(@modules, $module_list_file);
    } elsif(/CODE +Offs=([0-9A-F]{6})/) {
        $module_offset{$module_list_file} = $1;
    } elsif(/^CODE +([0-9A-F]{6})/) {
        $origin = hex($1);
    }
}
close(FH);
foreach $k (@modules) {
    open(FH, '<', $k) || die("failed to open $k");
    while(<FH>) {
        if(/^([0-9A-F]{6})r(.*)$/) {
            $absolute_address = hex($module_offset{$k}) + hex($1) + $origin;
            printf("%06x%s\n",$absolute_address, $2);
        }
    }
    close(FH);
}
