<?php

$HOST = 'localhost';
$USER = 'swes8332_app';
$PASS = 'NMOi115DVRC2';
$DB = 'swes8332_app';

if (mysqli_connect_errno()){
    echo "Koneksi database gagal : " . mysqli_connect_error();
}else {
    $CON = mysqli_connect($HOST,$USER,$PASS,$DB);
}

?>
