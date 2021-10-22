#!/usr/bin/python3

# Documentation :
# https://pyconll.readthedocs.io/en/stable/

"""
Alexandra PONOMAREVA (N°22000203)
extract-relation.py

Ce programme contient un programme principal et trois fonctions.

Il permet de :
    - Lire un fichier txt en entrée contenant une liste de relation
    - Lire les fichiers connl (1 fichier connl par rubrique)
    - Rechercher à partir du fichier connl les relations entre les objets
    - Enregistrer le résultat dans un fichier .txt (1 par rubrique et par relation). Ce fichier contient les deux colonnes suivantes :
            * Nombre d'occurences pour une relation
            * Relation de mots

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

def getDicoRelations(relation, sentences_connl):
    """
        Lecture d'un fichier connl puis recherche des relations entre objets et le nombre de d'occurrences
        afin de constituer un dictionnaire :
            * key : relation de mots
            * value : Nombre d'occurence dans le fichier connl

        :param str relation: relation à traiter
        :param Object Connl sentences_connl: fichier connl à traiter

        :return: Dictionnaire des relations et nombre d'occurrences
        :rtype: dict
    """
    dico = dict() # initialisation du dictionnaire

    for sentence in sentences_connl:
        #lecture des tokens (un token correspond à une ligne du fichier.)
        for token in sentence:
            if (token.deprel == relation) : # s'il s'agit d'un objet
                
                seq = sentence[str(token.head)].form + " " + token.form # on concatène les mots constituant la relation
  
                # On ajoute la relation au dictionnaire
                add_dico(dico,seq.lower())

    return dico

def add_dico(dico, rel):
    """
        Fonction d'ajout au dictionnaire :
            * key : relation à enregistrer
            * value : Nombre d'occurence dans le fichier connl

        :param dict dico: Dictionnaire
        :param str rel: relation de mots à ajouter au dictionnaire
    """
    if rel in dico:
        dico[rel] = dico[rel] + 1 # incremente si la key existe
    else:
        dico[rel] = 1 # 1 si la key n'existe pas

def enregResult(lst, fileout):
    """
        Fonction d'enregistrement d'une liste (nombre d'occurences et relation) dans un fichier

        :param list lst: Liste triée par nombre d'occurences
        :param str fileout: Nom du fichier à enregistrer
    """
    # trier le dictionnaire des resultats
    lst = sorted(dico.items(), key=lambda t: t[1],reverse=True) # t[1] car on trie sur value; reverse car trie descendant
    
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

        with open('relations.txt', "r") as file: #lecture du fichier des relations
            for lineRelation in file:
                relation = lineRelation.strip()

                print(str(datetime.now()) + " | Rubrique : " + rubrique.get_num_rubrique() + " | Traitement de la relation : " + relation)

                #traitement du fichier connl afin de constituer un dictionnaire des resultats
                dico = getDicoRelations(relation, rubrique.get_sentences_connl())

                print(str(datetime.now()) + " | Rubrique : " + rubrique.get_num_rubrique() + " | Nombre de séquences pour la relation " + relation + " : " + str(len(dico)))

                #Enregistrer dans le fichier le resultat
                enregResult(dico, relation + "_" + rubrique.get_num_rubrique() + "_py.txt")

    print(str(datetime.now()) + " | Fin d'exécution du programme")
except IOError as erreur:
    # afficher l'erreur
    print(erreur)
    # quitter le programme avec un code d'erreur
    exit(1)