-- Voici le ficher de configuration de l'addon
-- Ici vous pouvez définir les entités autorisées a entrer dans le coffre
-- Pour ceci ajoutez simplement une ligne a la fin du fichier dans ce format :

-- allowedEnts['nomdelentité'] = poid

-- En pratique : allowedEnts['basic_printer'] = 20

-- Vous pouvez aussi définir une taille de coffre personnalisée (-1 pour désactiver le coffre sur ce véhicule) pour chaque véhicule
-- Pour ceci ajoutez en fin de fichier la ligne suivante :

-- customTrunkSize['nomduvehicule'] = taille

-- En pratique : customTrunkSize['citroenc1tdm'] = -1

allowedEnts = {}
defaultTrunkSize = 100
customTrunkSize = {}

