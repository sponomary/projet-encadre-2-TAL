for $item in collection("sortieUD-regex_3208")//item
where contains($item/a[8]/text(), 'obj')
let $dep_forme:=$item/a[2]/text()
let $position_source:=$item/a[1]
let $position_cible:=$item/a[7]
let $noeud:=
   if (number($position_cible) < number($position_source)) then (
		$item/preceding-sibling::item[number(a[1])=number($position_cible)]/a[2]/text()
	)
	else (
		$item/following-sibling::item[number(a[1])=number($position_cible)]/a[2]/text()
	)
let $pattern:= string-join(($noeud, $dep_forme)," ")
group by $grp:=$pattern
order by count($pattern) descending
return string-join((count($pattern), " ", $grp))
