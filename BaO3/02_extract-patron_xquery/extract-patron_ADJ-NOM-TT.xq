(: extraction du patron ADJ-NOM :)
(: pour chaque article dans la base :)
(: pour chaque élément dans l'article : E1 :)
(: on va "attraper" son frère : E2 :)
(: est-ce que cat(E1) = ADJ ET cat(E2) = NOM :)
(: si oui on imprime Forme(E1) Forme(E2) :)
(: en groupant les elements :)

for $article in collection("sortieTT-regex_3208")//article
for $element in $article/element
let $frere:= $element/following-sibling::element[1]
where (($element/data[1]="ADJ") and ($frere/data[1]="NOM"))
let $terme:=string-join(($element/data[3], $frere/data[3]), " ")
group by $regroupement:=$terme
order by count($terme) descending 
return string-join(((count($terme))," ", $regroupement))