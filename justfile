generate-assets: (generate-asset "main") (generate-asset "with-image")

generate-asset file:
    typst compile --pages 1 --ppi 250 ./template/{{ file }}.typ ./assets/{{ file }}.png

package:
    mkdir -p dist
    cp -r ./typst.toml ./template/ ./assets/ ./LICENSE ./README.md dist
