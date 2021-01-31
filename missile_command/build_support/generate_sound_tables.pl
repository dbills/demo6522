$start_val = 235;
$end_val = 200;
$val = $start_val;
$velocity = 0;
$acceleration = .05;
while(1) {
    printf(".byte %d\n",$val);
    if($val <= $end_val) {
        exit(0);
    }
    $val = $val - $velocity;
    $velocity = $velocity + $acceleration;
}
