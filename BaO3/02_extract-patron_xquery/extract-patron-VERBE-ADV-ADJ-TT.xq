(: extraction du patron VER-ADV-ADJ :)
(: pour chaque article dans la base :)
(: pour chaque élément dans l'article : E1 :)
(: on va "attraper" son frère : E2 :)
(: on va "attraper" son dexième frère : E3 :)
(: est-ce que cat(E1) = VER ET cat(E2) = ADV ET cat(E3) = ADJ :)
(: si oui on imprime Forme(E1) Forme(E2) Forme(E3) :)
(: on groupe les elements :)

for $article in collection("sortieTT-regex_3208")//article
for $element in $article/element
let $frere:= $element/following-sibling::element[1]
let $next_frere:= $frere/following-sibling::element[1]
where ((contains($element/data[1], "VER") and ($frere/data[1]="ADV")) and ($next_frere/data[1]="ADJ"))
let $terme:=string-join(($element/data[3], $frere/data[3], $next_frere/data[3]), " ")
group by $regroupement:=$terme
order by count($terme) descending 
return string-join(((count($terme))," ", $regroupement))