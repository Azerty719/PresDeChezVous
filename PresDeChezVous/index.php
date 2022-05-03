<?php 

require 'vendor/autoload.php';
// Routing


if (isset($_GET['BoutonLink'])){
    $page = $_GET['BoutonLink'];
};


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


// Valeur des boutons
function valueLinkButton($name,$method){
    if ($method == 'GET'){
        if(!empty($_GET[$name])) {
            return $_GET[$name];
        }
    }

}



// Affichage des pages

function renderP($current_page){
    global $twig;
    echo $twig->render($current_page.'.html.twig');
}

switch ($page){
    case 'Accueil':
        renderP('Accueil' , ['Recherche' => valueLinkButton("Recherche",'GET')]);
        break;
    case 'Connexion':
        renderP('Connexion');
        break;
    case 'Contactez-nous':
        renderP('Contactez-nous');
        break;
    case 'Mentions_legales':
        renderP('Mentions_legales');
        break;
    case 'Mon_Compte':
        renderP('Mon_Compte');
        break;
    case 'Recherche':
        renderP('Recherche');
        break;
    case 'Favoris':
        renderP('Favoris');
        break;
}

?>