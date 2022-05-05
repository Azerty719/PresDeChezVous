<?php 

require 'vendor/autoload.php';
error_reporting(E_ALL);

// Routing

if (isset($_POST['Categorie'])){
    echo var_dump($_POST['Categorie']) ;
}
global $page;
$page = 'Accueil';
if (isset($_GET['p'])) {
    $page = $_GET['p'];
};

// Paramètres Twig
$loader = new \Twig\Loader\FilesystemLoader(__DIR__ . '/templates/Pages');
$options = [
    'cache ' => false //__DIR__ . '/tmp'
];

$twig = new \Twig\Environment($loader, $options);


// // Valeur des boutons
// function valueLinkButton($name,$method){
//     if ($method == 'GET'){
//     }
// }

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
        global $page,$error_msg;
        $page = 'Erreur_connexion_BDD';
        $error_msg = mysqli_connect_error();
    } else {
        $error_msg = "Tout se passe bien, comment êtes-vous arrivé sur cette page d'erreur ?";
    }
}

#Connexion à la base
function dbConnectRoot(){
    $A = RSettings();
    @$dbconnexionRoot = mysqli_connect( $A['HOST'] , $A['ROOT'] , $A['PASSWORD_ROOT'] , $A['DATABASE'] , intval($A['PORT']));
    IsConnect($dbconnexionRoot);
    return $dbconnexionRoot;
} 
function dbConnectReader(){
    $A = RSettings();
    @$dbConnexionReader =  mysqli_connect( $A['HOST'] , $A['READER'] , $A['PASSWORD_READER'] , $A['DATABASE'] , intval($A['PORT']));
    IsConnect($dbConnexionReader);
    return $dbConnexionReader;
};

function Categories($id,$Lib,$foreign,$table){
    if ($foreign == 'None'){
        $req = "SELECT $id,$Lib FROM `$table`";
    } else{
        $req = "SELECT $id,$Lib,$foreign FROM `$table`";
    }
    
    $link = dbConnectReader();
    $sql = mysqli_query($link,$req);
    $data = [];
    mysqli_close($link);
    while ($ligne = $sql->fetch_assoc()) {
        $data[$ligne[$Lib]] = $ligne;
    }
    return $data;
}

// Affichage des pages

$ext = '.html.twig';

switch ($page){
    case 'Accueil':
        echo $twig->render('Accueil'.$ext , $Categories =  [
                                                'Categorie'     => Categories('IdCategorie','LibCategorie','None','Categorie'),
                                                'SousCategorie' => Categories('IdSousCategorie','LibSousCategorie','IdCategorie','SousCategorie'),
                                                'Type'          => Categories('IdType','LibType','IdSousCategorie','Type')
                                            ]
                                        );
        break;
    case 'Connexion':
        echo $twig->render('Connexion'.$ext);
        break;
    case 'Contactez-nous':
        echo $twig->render('Contactez-nous'.$ext);
        break;
    case 'Mentions_legales':
        echo $twig->render('Mentions-légales'.$ext);
        break;
    case 'Mon_Compte':
        echo $twig->render('Mon_Compte'.$ext);
        break;
    case 'Recherche':
        echo $twig->render('Recherche'.$ext);
        break;
    case 'Favoris':
        echo $twig->render('Favoris'.$ext);
        break;
    case 'Erreur_connexion_BDD':
        echo $twig->render('Erreur_connexion_BDD'.$ext , ['error_msg' => $error_msg]);
}

?>