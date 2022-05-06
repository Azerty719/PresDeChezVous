<?php 
require 'vendor/autoload.php';
error_reporting(E_ALL);

// Routing

$page = 'Accueil';
if (isset($_GET['p'])) {
    $page = $_GET['p'];
};


function ExecAPI($url){
    $curl = curl_init($url);
    $options = [
        CURLOPT_CAINFO => __DIR__ . DIRECTORY_SEPARATOR .'certificatSSL.cer',
        CURLOPT_RETURNTRANSFER => true  ];
        curl_setopt_array($curl,$options);
        $data = curl_exec($curl);
    if($data === false ){
        global $page,$Erreur,$msg_erreur;
        $page = 'Erreur';
        $msg_erreur = "Désolé, il semble qu'une erreur est apparue lors de la récupération des adresses";
        $Erreur = curl_error($curl);
    } else {
        $data = json_decode($data,true);
        return $data;
    }
}
$adresse = 'https://api-adresse.data.gouv.fr/search/?q=8+allee+aimee+de+la+rochefoucauld&limit=1';

// echo count(ExecAPI($adresse)['features']);
// echo var_dump(ExecAPI($adresse)['features'][0]);



// Paramètres Twig
$loader = new \Twig\Loader\FilesystemLoader(__DIR__ . '/templates/Pages');
$options = [
    'cache ' => false //__DIR__ . '/tmp'
];
$twig = new \Twig\Environment($loader, $options);


// Valeur des boutons
function ResultSearch(){
    if (!isset($_POST['Recherche'])){
        global $page,$Erreur,$msg_erreur;
        $page = 'Erreur';
        $msg_erreur = "Désolé, il semble qu'une erreur est apparue lors de la récupération du formulaire de recherche";
        $Erreur = '$_POST["Recherche"]'. 'non défini';
        return ;
    }
    if ( !isset($_POST['Type']) or !isset($_POST['SousCategorie']) or !isset($_POST['Categorie']) ){
        return "Aucun résultat (peut être que vous n'avez sélectionné aucun type d'équipement ?)";
    }

    $Adresse = $_POST['Adresse'];  #string
    $Adresse = str_replace(' ','+',$Adresse);                       #On recupère le premier résultat
    $url = 'https://api-adresse.data.gouv.fr/search/?q='.$Adresse.'&limit=1'; 
    $data = ExecAPI($url);
    if (count($data['features']) == 0 ){
        return "Désolé, il semble qu'aucun lieu de corresponde à votre adresse";
    }
    $X = $data['features'][0]['properties']['x'];
    $Y = $data['features'][0]['properties']['y'];
    $context = $data['features'][0]['properties']['context']; #string CodeDepartement, Departement, Region 
    $listcontext = (explode(',',$context)); #Liste du string
    $region =  trim(end($listcontext),' '); #Prend region et enleve premier espace
    
    $CategoriesCheck = [
        'IdCategorie'      => $_POST['Categorie'], #Array
        'IdSousCategorie'  => $_POST['SousCategorie'],
        'IdType'           => $_POST['Type'] 
        ] ; 
    $CategorieCheck32 = [];
    foreach ($CategoriesCheck as $key => $value) {
        
    }

    $Distance = "DistanceXY(UTMX, $X ,UTMY, $Y )";
    $req = "SELECT $Distance as Distance , LibType FROM equipement";
    $req.= " INNER JOIN commune USING(CodeCommune)";
    $req.= " INNER JOIN departement USING(CodeDepartement)";
    $req.= " INNER JOIN region USING(CodeRegion)";
    $req.= " INNER JOIN coordonnees USING(IdLocalisation)";
    $req.= " INNER JOIN type USING(IdType)";
    $req.= " INNER JOIN souscategorie USING(IdSousCategorie)";
    $req.= " INNER JOIN categorie USING(categorie)";
    $req.= " WHERE LibRegion = '$region' $Distance < 10000";

    foreach ($CategoriesCheck['IdType'] as $Type) {
        $Type32 = base_convert($Type,10,32);
    }
    $req.= "ORDER BY $Distance ASC;";
    echo $req;
    qiiesfq
    pseiei
}
// ResultSearch();

echo substr('abcd',1,2);


// Fonction str_contains pas présent dans php 7
function str_contains(string $haystack, string $needle): bool
{
    return '' === $needle || false !== strpos($haystack, $needle);
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