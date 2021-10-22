#!/usr/bin/perl
<<DOC;
 Votre Nom : Alexandra PONOMAREVA
 Mars 2021
 Programme d'extraction de patron sur sortie UDPipe
 $ARGV[0] = fichier udpipe à utiliser
 $ARGV[1] = fichier des patrons
 Usage : perl extraction.pl fichier_etiquete.txt fichier_patrons.txt
 Exemple d'usage : perl BaO3/01_extract-patron_perl/extract_patron.pl BaO2/sortieUD-regex_3208.txt BaO3/01_extract-patron_perl/patrons.txt
DOC
use utf8;
use Timer::Simple;
binmode STDOUT,":utf8";
#----------------------------------
# on instancie un timer commencant à 0.0s par défaut
my $time = Timer::Simple->new();
# on lance le timer$t->start;
$time->start;
#----------------------------------
# ouverture des fichiers en lecture
open my $fichier_patrons, "<:encoding(utf8)", "$ARGV[1]" or die ("Problème sur ouverture du fichier des patrons.");
#----------------------------------
# on stocke les patrons dans une liste
my @patrons = <$fichier_patrons>;
close $fichier_patrons;
# on instancie deux listes vides
my @pos = ();
my @token = ();
#----------------------------------
# pour chaque patron de la liste des patrons
foreach my $suitedepos (@patrons) 
{
	open my $entree, "<:encoding(utf8)", "$ARGV[0]" or die ("Problème sur ouverture du fichier UDPipe.");
	my %dict = ();
	# on enlève les caractères de saut de ligne
	$suitedepos =~  s/\r?\n//g;
	#----------------------------------
	print "Traitement du patron : $suitedepos\n";
	# lecture du fichier ligne à ligne
	while (my $ligne = <$entree>) 
	{	
		# on passe à la ligne suivante si la ligne commence par '#' ou par '\d-\d'
		next if $ligne =~ m/^#|^\d+-\d+/;
		# on enlève les caractères de saute de ligne
		$ligne =~ s/\r?\n//g;
		# si la ligne n'egale pas à une chaîne vide
		if ($ligne ne "") 
		{
			# on prend chaque ligne et on la tronçonne sur la tabulation
			# chaque ligne est assimilée à une liste
			my @ligne = split(/\t/, $ligne);
			# on ajoute les données de la colonne 2
			push @token, $ligne[1];
			# on ajoute les données de la colonne 4 
			push @pos, $ligne[3];
		}
		else 
		{
			my $long = 0;
			# on calcule la longeur du patron
			while ($suitedepos =~ / /g) 
			{
				$long++
			}
			my $i = 0;
			# on regarde s'il y a une correspondance de l'élément d'un patron
			# avec une étiquette de la liste
			foreach my $element (@pos) 
			{
				# l'indice de l'élément où on est
				$i++;
				if ($suitedepos =~ /^$element/) # commence par /^$element/
				{
					# print "presence de $element, je cherche toute la séquence 
					# de $i et ensuite sur $long caractères\n";
					my $suite = "";		
					for ($j=$i-1; $j<=$long+$i-1; $j++) 
					{
						$suite=$suite.$pos[$j]." "
					}
					if ($suite =~ /$suitedepos/) 
					{
						# on repère un élémént de la liste
						my $extract = join(" ", @token[$i-1..$j-1]);
						# on le mets dans le hash
						$dict{lc($extract)}++;
					}
				}
			}
			# on vide nos listes en les réinitialisant
			@pos = ();
			@token = ();
		}
	}
    #----------------------------------
	$suitedepos =~ tr/ /-/; # remplacement des espace par des - dans le patron
	my @spl = split(/[_.]/, $ARGV[0]); # split sur _- et . pour recuperer le numero de la rubrique (3208 ...)
	my @path = split("/", $ARGV[1]);
	my $filename = $path[0] . '/' . $path[1]. '/' . $suitedepos . '_'. $spl[1] . '_pl.txt'; # constitution du nom du fichier
	open my $sortie_patrons, ">:encoding(utf8)", "$filename" or die ("Problème lors de l'ouverture du fichier en écriture.");
	foreach my $occ (sort {$dict{$b}<=>$dict{$a}} (keys %dict)) # on sort et tri le résultat extrait
	{
		print($sortie_patrons "$dict{$occ} $occ\n");
	}
	close $sortie_patrons; # fermeture du fichier
}
#----------------------------------
# on stoppe le timer
$time->stop;
# temps écoulé depuis le lancement du programme
print "Temps passé: ", $time->elapsed, " secondes\n";
print "Extraction terminée !\n";
exit;