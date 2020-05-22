-- Voici le ficher de configuration de l'addon
-- Ici vous pouvez définir les entités autorisées a entrer dans le coffre
-- Pour ceci ajoutez simplement une ligne a la fin du fichier dans ce format :

-- allowedEnts['nomdelentité'] = poid

-- En pratique : allowedEnts['basic_printer'] = 20

allowedEnts = {}
defaultTrunkSize = 100
customTrunkSize = {}

allowedEnts['basic_printer'] = 10

customTrunkSize['citroenc1tdm'] = -1