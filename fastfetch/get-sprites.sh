#!/usr/bin/env bash
# Пиксельные спрайты покемонов (github.com/PokeAPI/sprites) для приветствия fastfetch.
# Обрезка краёв и увеличение x6 без сглаживания (-filter point), чтобы пиксели были чёткими.
# Добавить персонажа: [номер в покедексе]=имя в список P.
D=~/.local/share/fastfetch/sprites; RAW=$(mktemp -d); trap "rm -rf $RAW" EXIT; mkdir -p $D
declare -A P=([1]=bulbasaur [4]=charmander [7]=squirtle [25]=pikachu [39]=jigglypuff [52]=meowth [54]=psyduck [94]=gengar [129]=magikarp [131]=lapras [133]=eevee [143]=snorlax [147]=dratini [149]=dragonite [150]=mewtwo [151]=mew [152]=chikorita [155]=cyndaquil [158]=totodile [175]=togepi [196]=espeon [197]=umbreon [249]=lugia [251]=celebi [258]=mudkip [282]=gardevoir [384]=rayquaza [393]=piplup [445]=garchomp [448]=lucario [470]=leafeon [471]=glaceon [700]=sylveon [778]=mimikyu [658]=greninja)
ok=0; for id in "${!P[@]}"; do n=${P[$id]}
  curl -fsSL "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png" -o $RAW/$n.png && \
  magick $RAW/$n.png -trim +repage -filter point -resize 600% $D/$n.png && ok=$((ok+1))
done; echo "готово: $ok"; ls $D | tr '\n' ' '
