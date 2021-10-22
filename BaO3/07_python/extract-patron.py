#!/usr/bin/python3

# Documentation :
# https://pyconll.readthedocs.io/en/stable/

"""
Alexandra PONOMAREVA (N°22000203)
extract-patron.py

Ce programme contient un programme principal et quatre fonctions.

Il permet de :
    - Lire un fichier txt en entrée contenant une liste de patrons
    - Lire les fichiers connl (1 fichier connl par rubrique)
    - Rechercher à partir du fichier connl les séquences de mots conforme à un patron
    - Enregistrer le résultat dans un fichier txt (1 par rubrique et par patron). Ce fichier contient les deux colonnes suivantes :
            * Nombre d'occurrences pour une séquence de mots
            * La séquence de mots
        
ATTENTION : ce programme se lance à partir du dossier courant.
"""

import pyconll
import os
from datetime import datetime


class Rubrique:
    """
        Objet rubrique qui contient les attributs suivants :
            * num_rubrique : numero de la rubrique
            * path_rubrique : path de la rublique
            * sentences_connl : un objet contenant les sentences du fichier connl

    """
    def __init__(self, num_rubrique, path_rubrique, sentences_connl = None):
        self.__num_rubrique = num_rubrique
        self.__path_rubrique = path_rubrique
        self.__sentences_connl = sentences_connl
        
    def get_num_rubrique(self):
        return self.__num_rubrique

    def get_path_rubrique(self):
        return self.__path_rubrique

    def set_num_rubrique(self, num_rubrique):
        self.__num_rubrique = num_rubrique

    def set_path_rubrique(self, path_rubrique):
        self.__path_rubrique = path_rubrique

    def get_sentences_connl(self):
        if self.__sentences_connl is None: # chargement du fichier si l'objet est none
            self.__sentences_connl= pyconll.load_from_file(self.__path_rubrique) # utilisation de la librairie connl pour charger le corpus
        return self.__sentences_connl

    def set_sentences_connl(self, path_rubrique):
        self.__sentences_connl= sentences_connl



def getDicoConnl(patron, sentences_connl):
    """
        Lecture d'un fichier connl puis comparaison entre les entités et le patron
        afin de constituer un dictionnaire :
            * key : sequence de mots conforme au patron
            * value : nombre d'occurrences dans le fichier connl

        :param list patron: patron à traiter
        :param Object Connl sentences_connl: fichier connl à traiter

        :return: dictionnaire des séquences et nombre d'occurrences
        :rtype: dict
    """
    dico = dict() # initialisation du dictionnaire
    
    for sentence in sentences_connl:
        i = 0

        # lecture des tokens (d'après pyconll, un token correspond à une ligne du fichier)
        for token in sentence:
            # on regarde s'il y a une correspondance du premier élément d'un patron avec une étiquette de la liste
            if patron[0] == token.upos:

                # appel de la fonction de vérification des étiquettes avec le patron
                seq = getSequence(i, patron, sentence)

                # si la sequence est conforme par rapport au patron, on l'ajoute au dictionnaire
                if seq != "":
                    add_dico(dico, seq.lower())
            i = i + 1
    return dico



def getSequence(index, patron, sentence):

    """
        Fonction qui retourne une sequence de mot si elle est conforme à un patron.  "" si non conforme.

        :param int index: Index d'un token 'au premier élément d'un patron
        :param str patron: Patron à respecter
        :param str sentence: objet connl contennant l'ensemble des tokens

        :return: séquence de mot conforme au patron ou "" si non conforme
        :rtype: str
    """

    result = ""
    j = index # copie de l'indice pour ne pas modifier l'indice dans la fonction d'appel

    for etiquette in patron: # Boucle sur l'ensemble des elements du patron
        if(j < len(sentence) and etiquette == sentence[j].upos) : # si on ne dépasse pas la liste des tokens et l'étiquette correspond au patron
            result = result + sentence[j].form + " " # on ajoute le mot à la séquence
            j += 1
        else :
            return "" # non conforme

    return result.strip()


def add_dico(dico, seq):
    """
        Fonction d'ajout au dictionnaire :
            * key : sequence de mots conforme au patron
            * value : Nombre d'occurences dans le fichier connl

        :param dict dico: Dictionnaire
        :param str seq: Sequence de mots à ajouter au dictionnaire
    """
    if seq in dico:
        dico[seq] = dico[seq] + 1 # incremente si la clé existe
    else:
        dico[seq] = 1 # 1 si la key n'existe pas



def enregResult(dico, fileout):
    """
        Fonction d'enregistrement d'un dico (nombre d'occurences et séquence de mots) dans un fichier

        :param list lst: Liste triée par nombre d'occurences
        :param str fileout: Nom du fichier à enregistrer
    """
    # trier le dictionnaire des resultats
    lst = sorted(dico.items(), key=lambda t: t[1],reverse=True) # t[1] car on trie sur value; reverse car trie descendant

    #os.makedirs(os.path.dirname(fileout), exist_ok=True)
    with open(fileout, "w") as file: # ouverture du fichier en écriture
        for value in lst:
            file.write(str(value[1]) + " " + str(value[0]) + "\n") # enregistrement ligne par ligne de la liste


#-----------------------------------------------------------------#
#                       DEBUT DU PROGRAMME                        #
#-----------------------------------------------------------------#
print(str(datetime.now()) + " | Début d'exécution du programme")

lst_rubriques = list() # déclaration de la liste des rubriques à traiter

path = './../../BaO2/'

file_rubrique_3208 = 'sortieUD-regex_3208.txt'
file_rubrique_3210 = 'sortieUD-regex_3210.txt'
file_rubrique_3246 = 'sortieUD-regex_3246.txt'

# création des objets Rubrique et ajout à la liste des rubriques à traiter
lst_rubriques.append(Rubrique('3208', path + file_rubrique_3208))
lst_rubriques.append(Rubrique('3210', path + file_rubrique_3210))
lst_rubriques.append(Rubrique('3246', path + file_rubrique_3246))

try:
    for rubrique in lst_rubriques:
        print(str(datetime.now()) + " | Traitement de la rubrique: " + rubrique.get_num_rubrique())

        with open('patrons.txt', "r") as file: #lecture du fichier des patrons
            for linePatron in file:
                patron = linePatron.strip().split(' ')
                patronStr = linePatron.strip().replace(' ', '-')

                print(str(datetime.now()) + " | Rubrique : " + rubrique.get_num_rubrique() + " | Traitement du patron : " + str(patron))

                #traitement du fichier connl afin de constituer un dictionnaire des resultats
                dico = getDicoConnl(patron, rubrique.get_sentences_connl())

                print(str(datetime.now()) + " | Rubrique : " + rubrique.get_num_rubrique() + " | Nombre de séquences pour le patron " + str(patron) + " : " + str(len(dico)))

                #Enregistrer dans le fichier le resultat
                enregResult(dico, patronStr + "_" + rubrique.get_num_rubrique() + "_py.txt")

    print(str(datetime.now()) + " | Fin d'exécution du programme")
except IOError as erreur:
    # afficher l'erreur
    print(erreur)
    # quitter le programme avec un code d'erreur
    exit(1)