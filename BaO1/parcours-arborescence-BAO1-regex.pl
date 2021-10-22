#/usr/bin/perl
<<DOC;
 Votre Nom : Alexandra PONOMAREVA
 FÉVRIER 2021
 Le programme prend en entrée le nom du répertoire-racine contenant les fichiers
 à traiter et le nom de la rubrique à traiter parmi ces fichiers
 $ARGV[0] = nom de l'arborescence RSS
 $ARGV[1] = numéro de la rubrique
 usage : perl script repertoire-a-parcourir rubrique
 exemple d'usage : perl ./BaO1/parcours-arborescence-BAO1-regex.pl 2020 3208
DOC
use strict;
use utf8;
binmode(STDIN,":utf8");
binmode(STDOUT,":utf8");
use Timer::Simple;

#-------------- Début du programme principale ----------------
my $time = Timer::Simple->new(); # instancie un timer commencant à 0.0s
$time->start; # lance le timer
my $repertoire = "$ARGV[0]"; # récupère le nom de l'arborescence (1er paramètre)
my $rubrique = "$ARGV[1]"; # récupère le nom de la rubrique (2ème paramètre)
my $compteur = 0; # initialisation du compteur d'item
my $nb_file = 0; # initialisation du compteur de fichiers
my %dico_titres = (); # crée un tableau de hashage vide
my $nom = "";

# on teste si la rubrique a été passée en paramètre
if(!$rubrique) 
{
	print "*** ERREUR -- il manque l'ID de la rubrique à traiter. ***\n";
	exit;
}

# on assure que le nom du répertoire ne se termine pas par un "/"
$repertoire =~ s/[\/]$//; # "2020", pas "/2020"

#-------- Initialisation des fichiers de sortie --------------
open my $OUT, ">:encoding(utf8)", "./BaO1/sortie-regex_$rubrique.txt";
open my $OUTXML, ">:encoding(utf8)","./BaO1/sortie-regex_$rubrique.xml";
print $OUTXML "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
print $OUTXML "<corpus2020 column=\"$rubrique\">\n";

#--------------- Appel de la fonction principale -------------
&parcoursArborescence($repertoire);

#----------- Fermeture des fichiers de sortie ----------------
print $OUTXML "</corpus2020>\n";
close $OUT;
close $OUTXML;

#-------------- Fin du programme principale-------------------
print "Nombre d'items: $compteur \n";
print "Fichiers traités: ", $nb_file, "\n";
# on affiche temps écoulé depuis le lancement du programme
print "Temps passé: ", $time->elapsed, " secondes\n";
print "Traitement terminé !\n";
exit;

#------------------- Sous-programmes -------------------------
sub parcoursArborescence 
{
    # on récupère le nom du répertoire fourni en argument de la fonction
    my $path = shift(@_);
    # on ouvre le répertoire fourni en argument
    opendir(my $DIRhandle, $path) or die "Can't open $path: $!\n";
    # on lit le répertoire grâce à readdir() qui renvoie une liste du contenu (comme ls en bash)
    my @files = readdir($DIRhandle);
    closedir($DIRhandle);
		foreach my $file (@files) # pour chaque objet de la liste
    {
		    # next permet de passer au prochain élément de la liste si l'élément correspond à la regEx
		    next if $file =~ /^\.\.?$/; # élimine . et .. pour ne pas boucler sur le même rép.
        # on crée le chemin relatif complet vers les objets : "2020"."/"."01" ==> 2020/01"
        $file = $path."/".$file;
        if (-d $file) # s'il s'agit d'un répertoire
        {
				      &parcoursArborescence($file);	# recurse!
			  }
			  if (-f $file) # s'il s'agit d'un fichier, on ne relance par de parcours
        {
            # si le fichier est un fichier XML et correspond bien à la rubrique souhaitée
				    if ($file =~ m/0\,2\-$rubrique.+\.xml$/) 
            {
                $nom = $file;
				        print "Traitement du fichier #", $nb_file++, ": ", $file, "\n";

                # TRAITEMENT DES FICHIERS XML
                # on ouvre le fichier rentré en argument en lecture
                open my $INFILE, "<:encoding(utf8)", $file;
      					# on lit le fichier globalement : on supprime la valeur de $/
      					$/ = undef; # ou $/="";
      					my $ensemble = <$INFILE>;
      					close $INFILE;
                print $OUTXML "<file name=\"$nom\">\n";
                # on parcourt tout l'ensemble pour trouver les balises title et description et on mémorise leur contenu
                # en Perl on peut mettre certains zones en mémoire en les plaçant dans les parenthèses 
      					while ($ensemble =~ m/<item>.*?<title>(.+?)<\/title>.+?<description>(.+?)<\/description>.*?<\/item>/gs) 
                {
						        # $1 : variable speciale en Perl qui recupere le contenu des 1ères ()
						        my $titre = $1; # range les elements dans le tableau @_
						        # $2 : variable speciale en Perl qui recupere le contenu des 2èmes ()
						        my $description=$2;
						        $compteur++; # incrémentation compteur d'item
                    # si la clé n'existe pas, on l'ajoute dans le dico et on traite le titre ==> évite les doublons
						        if (!(exists $dico_titres{$titre})) 
                    {
							          $dico_titres{$titre} = $description;
                        # appel du sous-programme de nettoyage
							          ($titre, $description) = &nettoyage($titre, $description);
							          print $OUT $titre, "\n", $description, "\n\n"; # écriture des réultats en sorties
                        # écriture des résultats en sorties
          							print $OUT "-----------------------------\n";
          							print $OUTXML "<item num=\"$compteur\"><title>\n$titre\n</title><description>\n$description\n</description></item>\n";
						        }
					      }
                print $OUTXML "</file>\n";
				    }
			  }
		}
}
#------------------------------------------------------------
# La procédure pour nettoyer les données extraits
sub nettoyage 
{
    # on vide la liste des arguments
    my $titre = $_[0];
    my $description = $_[1];
  	$titre =~ s/^<!\[CDATA\[//;
  	$titre =~ s/\]\]>$//;
  	$description =~ s/^<!\[CDATA\[//;
  	$description =~ s/\]\]>$//;
    $description =~ s/&lt;.+?&gt;//g; # supprime les succession de balises transcodées $lt; &gt;
    $description =~ s/&amp;/et/g; # remplace les &amp; par et
    $description =~ s/&nbsp;/ /g; # remplace les &nbsp; par des espaces 'normaux'
    $description =~ s/&#38;#39;/'/g; # remplace les apostrophes transcodées &#38;#39;
    $description =~ s/&#38;#34;/"/g; # remplace les guillemets doubles &#38;#34;
    $description =~ s/ / /g; # remplace les espaces insécables par des espaces 'normaux'
    $description =~ s/’/'/g; # remplace des guillemets simples par des apostrophes
    $titre =~ s/&lt;.+?&gt;//g;
    $titre =~ s/&amp;/et/g;
    $titre =~ s/&nbsp;/ /g;
    $titre =~ s/&#38;#39;/'/g;
    $titre =~ s/&#38;#34;/"/g;
    $titre =~ s/$/\./g;
	  $titre =~ s/\.+$/\./g;
    $titre =~ s/ / /g;
    $titre =~ s/’/'/g;
    return $titre, $description; # renvoie le titre et la description nettoyés
  }
#------------------------------------------------------------
