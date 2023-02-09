# -- Extract species listed in DNA Zoo
base_url <- "https://dnazoo.s3.wasabisys.com"
dnazooS3 <- aws.s3::get_bucket('dnazoo', max = Inf)
dnazoo <- tibble::as_tibble(dnazooS3) |> 
    dplyr::filter(
        Key != './README.json', 
        Key != './.DS_Store', 
        !grepl("_not_shared", Key), 
    )
readmes <- grep('README.json', dnazoo$Key, value = TRUE)
readmes <- readmes[!readmes %in% c("./README.json")]
readmes <- readmes[!grepl("_not_shared/", readmes)]
df <- tibble::tibble(
    species = dirname(readmes), 
    readme = unname(readmes), 
    readme_link = file.path(base_url, readme)
)

# -- Get local readmes
dir.create('data', showWarnings = FALSE)
local_readmes <- paste0('data/', df$species, '_README.json')
purrr::imap(df$readme_link, ~download.file(.x, local_readmes[.y]))
rm_species <- which(!file.exists(local_readmes))
df <- df[-rm_species,]
local_readmes <- local_readmes[-rm_species]

# -- Get original assembly IF
df$original_assembly <- purrr::imap(local_readmes, ~ tryCatch({
    rjson::fromJSON(file = .x)$draftAssembly$name
}, error = function(e) {NA}, warning = function(e) {NA})) |> unlist()

# -- New assembly
df$new_assembly <- purrr::imap(local_readmes, ~ tryCatch({
    rjson::fromJSON(file = .x)$chromlengthAssembly$name
}, error = function(e) {NA}, warning = function(e) {NA})) |> unlist()
df$new_assembly_link <- file.path(
    base_url, 
    df$species, 
    paste0(df$new_assembly, '.fasta.gz')
)
df$new_assembly_link_status <- unlist(purrr::map(df$new_assembly_link, ~{
    print(.x)
    httr::status_code(
        tryCatch(httr::HEAD(.x), error = function(e) 0, warning = function(e) 0)
    )
}))

# -- HiC files
hic_link_attempt <- file.path(base_url, df$species, paste0(df$new_assembly, '.hic'))
hic_link_attempt_status <- unlist(purrr::map(hic_link_attempt, ~{
    print(.x)
    httr::status_code(
        tryCatch(httr::HEAD(.x), error = function(e) 0, warning = function(e) 0)
    )
}))
hic_link <- purrr::imap(local_readmes, ~ tryCatch({
    file.path(base_url, df$species[.y], rjson::fromJSON(file = .x)$links$cMap$name)
}, error = function(e) {NA}, warning = function(e) {NA})) |> unlist()
hic_link_status <- unlist(purrr::map(hic_link, ~{
    print(.x)
    httr::status_code(
        tryCatch(httr::HEAD(.x), error = function(e) 0, warning = function(e) 0)
    )
}))
df$hic_link <- dplyr::case_when(
    hic_link_attempt_status == 200 ~ hic_link_attempt, 
    hic_link_status == 200 ~ hic_link, 
    TRUE ~ NA
)

# -- Save table
write.table(df, file = 'inst/extdata/dnazoo.txt', sep = '\t', row.names = FALSE, col.names = FALSE)