$start_val = 230;
$end_val = 190;
$val = $start_val;
$velocity = 0;
$acceleration = .006;
while(1) {
    printf(".byte %d\n",$val);
    if($val <= $end_val) {
        exit(0);
    }
    $val = $val - $velocity;
    $velocity = $velocity + $acceleration;
}
