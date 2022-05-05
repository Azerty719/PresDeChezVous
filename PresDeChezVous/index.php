<?php 
require 'vendor/autoload.php';
error_reporting(E_ALL);

// Routing

$page = 'Accueil';
if (isset($_GET['p'])) {
    $page = $_GET['p'];
};

// function getAdresseLoc ($Type,$table){
//     $curl = curl_init('https://api-adresse.data.gouv.fr/search/?q=8+bd+du+port&limit=1');
//     $options = [
//     CURLOPT_CAINFO => __DIR__ . DIRECTORY_SEPARATOR .'certificatSSL.cer',
//     CURLOPT_RETURNTRANSFER => true  ];
//     curl_setopt_array($curl,$options);
//     $data = curl_exec($curl);
    
//     if($data === false ){
//         global $page,$Erreur,$msg_erreur;
//         $page = 'Erreur';
//         $msg_erreur = "Désolé, il semble qu'une erreur est apparue lors de la récupération des adresses";
//         $Erreur = curl_error($curl);
    
//     } else {
//         $data = json_decode($data,true);
//         echo var_dump($data['features'][0]['geometry']);

//     };
// }


// Paramètres Twig
$loader = new \Twig\Loader\FilesystemLoader(__DIR__ . '/templates/Pages');
$options = [
    'cache ' => false //__DIR__ . '/tmp'
];
$twig = new \Twig\Environment($loader, $options);


// Valeur des boutons
function ResultSearch(){
    if (isset($_POST['Recherche'])){
        $page = 'Recherche';                #Aller à la page Recherche
        $TableCat = $_POST['Categorie']; #Array
        echo var_dump($TableCat);
        $tableSousCat = $_POST['SousCategorie']; #Array
        $tableType = $_POST['Type'];    #Array
        $Adresse = $_POST['Adresse']; #string
    }
    $req = 'SELECT Distance';
}
ResultSearch();

// Fonction str_contains pas présent dans php 7
if (!function_exists('str_contains')) {
    function str_contains(string $haystack, string $needle): bool
    {
        return '' === $needle || false !== strpos($haystack, $needle);
    }
}

// MYSQL

#Lecture settings.txt connexion à la base. Retourne un tableau avec toutes les valeurs
function RSettings(){
    $A = Array();
    $settings = (file('..\Settings.txt'));
    foreach($settings as $ligne){
        $ligne = trim(str_replace(' ','',$ligne));
        if (str_contains($ligne,':')){
            $ligne = explode(':',$ligne);
            $A[$ligne[0]] = $ligne[1];
        }
    }
    // Si pas du'utilisateur reader
    if (strlen($A['READER']) == 0){
        $A['READER'] = $A['ROOT'];
        $A['PASSWORD_READER'] = $A['PASSWORD_ROOT'];
    }
    return $A;
}

#Gestion des erreurs de connexion
function IsConnect($dbConnect){
    if (mysqli_connect_errno()){
        global $page,$msg_erreur,$Erreur;
        $page = 'Erreur';
        $msg_erreur = "Désolé, il semble qu'une erreur est apparue lors de la connexion à la base de donnéees";
        $Erreur = mysqli_connect_error();
            return false;
    } else {
        $Erreur = [
            'message'=> "Tout se passe bien, comment êtes-vous arrivé sur cette page d'erreur ?",
            'detail' => ''];
        return $dbConnect;
    }
}

#Connexion à la base

function dbConnect($user){
    $A = RSettings();
    @$dbConnect = mysqli_connect( $A['HOST'] , $A[$user] , $A['PASSWORD_'.$user] , $A['DATABASE'] , intval($A['PORT']));
    IsConnect($dbConnect);
    $dbConnect = IsConnect($dbConnect);
    return $dbConnect;
}
function Categories($id,$Lib,$foreign,$table){
    if ($foreign == 'None'){
        $req = "SELECT $id,$Lib FROM `$table`";
    } else{
        $req = "SELECT $id,$Lib,$foreign FROM `$table`";
    }
    $link = dbConnect('READER');
    if ($link ){
        $sql = mysqli_query($link,$req);
        $data = [];
        mysqli_close($link);
        while ($ligne = $sql->fetch_assoc()) {
        $data[$ligne[$Lib]] = $ligne;
    }
    return $data;
    }
}
// Affichage des pages

$Categories =  [
    'Categorie'     => Categories('IdCategorie','LibCategorie','None','Categorie'),
    'SousCategorie' => Categories('IdSousCategorie','LibSousCategorie','IdCategorie','SousCategorie'),
    'Type'          => Categories('IdType','LibType','IdSousCategorie','Type')
];


$ext = '.html.twig';


switch ($page){
    case 'Accueil':
        echo $twig->render('Accueil'.$ext , $Categories );
        break;
    case 'Connexion':
        echo $twig->render('Connexion'.$ext);
        break;
    case 'Contactez-nous':
        echo $twig->render('Contactez-nous'.$ext);
        break;
    case 'Mentions_legales':
        echo $twig->render('Mentions_legales'.$ext);
        break;
    case 'Mon_Compte':
        echo $twig->render('Mon_Compte'.$ext);
        break;
    case 'Recherche':
        echo $twig->render('Recherche'.$ext,$Categories);
        break;
    case 'Favoris':
        echo $twig->render('Favoris'.$ext);
        break;
    case 'Erreur':
        echo $twig->render('Erreur'.$ext , ['Erreur' => $Erreur,
                                            'msg_erreur' => $msg_erreur ]);
}

?>