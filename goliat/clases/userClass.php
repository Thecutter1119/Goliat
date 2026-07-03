<?php
class userClass
{
/* User Login */
public function userLogin($userID,$password)
{
try{
$db = getDB();
$hash_password =  $password; //Password encryption 
$stmt = $db->prepare("SELECT id_usuario FROM tab_usuario WHERE (id_usuario=:userID) AND contrasena=:hash_password"); 
$stmt->bindParam("userID", $userID,PDO::PARAM_STR) ;
$stmt->bindParam("hash_password", $hash_password,PDO::PARAM_STR) ;
$stmt->execute();
$count=$stmt->rowCount();
$data=$stmt->fetch(PDO::FETCH_OBJ);
$db = null;
if($count)
{
$_SESSION['id_usuario']=$data->id_usuario; // Storing user session value
return true;
}
else
{
return false;
} 
}
catch(PDOException $e) {
echo '{"error":{"text":'. $e->getMessage() .'}}';
}
}
}
?>