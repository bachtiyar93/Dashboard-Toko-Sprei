<?php
require_once('connection.php');
if($_SERVER['REQUEST_METHOD']=="POST"){
  #code
  $response = array();
$id_ktp = $_POST['id_ktp'];
$pendaftar="offline";
$online ="online";
$pulang = date('H:i:s');
$tanggal=date('d');
$sql = "update worker set pendaftar = '".$pendaftar."'where id_ktp='".$id_ktp."'";
$logout = "UPDATE absensi SET waktu_pulang='$pulang' WHERE ktp='$id_ktp' AND tanggal='$tanggal'";
$cek="SELECT * From worker WHERE pendaftar='".$online."' AND id_ktp='".$id_ktp."'";
$result2 = mysqli_query($CON,$sql);
$result=mysqli_fetch_array(mysqli_query($CON,$cek));
if (isset($result)) {
          # code...
          $response['message']='Logout gagal karena koneksi anda';
            echo json_encode($response);
} else {
            #code
            $result2=mysqli_query($CON,$logout);
            $response['value']=2;
            $response['message']='Logout berhasil!';
            echo json_encode($response);
        }
        
}
?>