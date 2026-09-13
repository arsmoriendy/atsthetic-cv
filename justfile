compile:
    mkdir -p dist && typst compile main.typ dist/cv.pdf && typst compile with-image.typ dist/cv-with-image.pdf

watch:
    typst watch main.typ dist/cv.pdf

watch-image:
    typst watch with-image.typ dist/cv-with-image.pdf
