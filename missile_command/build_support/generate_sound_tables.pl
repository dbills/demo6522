$start_val = 250;
$end_val = 210;
$val = $start_val;
$velocity = 0;
$acceleration = .004;
while(1) {
    printf(".byte %d\n",$val);
    if($val <= $end_val) {
        exit(0);
    }
    $val = $val - $velocity;
    $velocity = $velocity + $acceleration;
}
