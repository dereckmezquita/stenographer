```bash
Rscript -e "devtools::document()"
Rscript -e "devtools::check()"
Rscript -e "devtools::install()"

Rscript -e "pkgdown::build_site()"
Rscript -e "pkgdown::preview_site()"
```