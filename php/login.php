<?php
require_once('connection.php');
if($_SERVER['REQUEST_METHOD']=="POST"){

#code
$phone =$_POST["phone"];
$pass = md5($_POST['password']);
$token = $_POST['token'];
$status=1;

//query Pengambilan data login
$ambil = 'SELECT * FROM `app_login` WHERE `phone`="'.$phone.'" AND `password`="'.$pass.'"';
$eksekusiPengambilanData=mysqli_fetch_array(mysqli_query($CON,$ambil));
$id=(int)$eksekusiPengambilanData['id'];


//query update token dan status
$sql = 'UPDATE `app_token` SET token ="'.$token.'", status="'.$status.'" WHERE id="'.$id.'"';
$onlinekan = mysqli_query($CON, $sql);

//jika usernamenya ada jabatannya admin lakukan cek absen
if (isset($eksekusiPengambilanData)) {
			if ($onlinekan){
				$response['value']=1;
				$response['id']=$id;
				$response['message']='Selamat Datang '.$phone.'';
				echo json_encode($response);
			}else {
				$response['value']=0;
				$response['id']=$id;
				$response['message']='Gagal lakukan online';
				echo json_encode($response);
				mysqli_close($CON);
			}
          }else {
            #code
            $response['value']=0;
            $response['id']=0;
            $response['message']='Username atau Password Salah! '.$pass.'';
			echo json_encode($response);
			mysqli_close($CON);

		  }
		      //kirim json
			  $response = array();
}
mysqli_close($CON);
?>