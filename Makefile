.PHONY: all
all: pokemon items index.d.ts

.PHONY: pokemon
pokemon: yakkuncom.tsv pokeapi.tsv source/pokeapi-pokedbtokyo.tsv
	poetry run python merge-tsvs.py yakkuncom.tsv pokeapi.tsv source/pokeapi-pokedbtokyo.tsv --out_tsv POKEMON_ALL.tsv --out_json POKEMON_ALL.json

.PHONY: items
items: source/pokeapi-item_names.csv source/pokedbtokyo-item-names.json
	poetry run python merge-items.py source/pokeapi-item_names.csv source/pokedbtokyo-item-names.json --out_tsv ITEM_ALL.tsv --out_json ITEM_ALL.json

.PHONY: test
test:
	pnpm test

yakkuncom.tsv: source/yakkuncom-zukan.html
	echo "national_pokedex_number	id	name_ja	variant" > $@
	cat $< | iconv -f euc-jp -t utf8 | perl -nle 'm#li .*?data-no="([0-9]+)"[^>]+>.*?<a href="/sv/zukan/([^"]+)">.*?</i>(.+?)(?:<span>\((.+?)\)</span>)?</a></li># and print join "\t", $$1, $$2, $$3, $$4' | sort -n >> $@

pokeapi.tsv: source/pokeapi-allpokemons.json
	poetry run python format-pokeapi-allpokemons.py $< > $@

source/pokeapi-allpokemons.json: pokeapi.allpokemons.graphql.postcontent
	curl --fail https://beta.pokeapi.co/graphql/v1beta --data @$< | jq . > $@

source/pokeapi-item_names.csv:
	curl --fail -L https://github.com/PokeAPI/pokeapi/raw/refs/heads/master/data/v2/csv/item_names.csv -o $@

source/pokemondb-pokedex-all.html:
	curl --fail https://pokemondb.net/pokedex/all -o $@

source/yakkuncom-zukan.html:
	curl --fail https://yakkun.com/sv/zukan/ -o $@ -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

source/yakkuncom-item.html:
	curl --fail https://yakkun.com/sv/item.htm -o $@ -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/13.0.0.0 Safari/537.36"

index.d.ts: always
	pnpm run create-dts

.PHONY: always
always:
	