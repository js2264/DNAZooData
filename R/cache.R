#' @name DNAZooDataCache
#'
#' @title Manage cache / download files from the DNAZoo data portal
#'
#' @description Managing DNAZoo data downloads via the integrated
#' `BiocFileCache` system.
#'
#' @param ... Arguments passed to internal `.setDNAZooDataCache` function
#'
#' @import BiocFileCache
#' @importFrom HiCExperiment HicFile
#' @importFrom S4Vectors metadata
#' @importFrom tools R_user_dir
#' @importFrom rjson fromJSON
#' @export 
#' @examples
#' bfc <- DNAZooDataCache()
#' bfc
#' BiocFileCache::bfcinfo(bfc)
NULL

#' @return BiocFileCache object
#' @rdname DNAZooDataCache
#' @export

DNAZooDataCache <- function(...) {
    cache <- getOption("DNAZooDataCache", .setDNAZooDataCache(..., verbose = FALSE))
    BiocFileCache::BiocFileCache(cache)
}

.setDNAZooDataCache <- function(
    directory = tools::R_user_dir("DNAZooData", "cache"),
    verbose = TRUE,
    ask = interactive()
) {
    stopifnot(
        is.character(directory), length(directory) == 1L, !is.na(directory)
    )

    if (!dir.exists(directory)) {
        if (ask) {
            qtxt <- sprintf(
                "Create DNAZooData cache at \n    %s? [y/n]: ",
                directory
            )
            answer <- .getAnswer(qtxt, allowed = c("y", "Y", "n", "N"))
            if ("n" == answer)
                stop("'DNAZooData' directory not created.")
        }
        dir.create(directory, recursive = TRUE, showWarnings = FALSE)
    }
    options("DNAZooDataCache" = directory)

    if (verbose)
        message("DNAZooData cache directory set to:\n    ", directory)
    invisible(directory)
}

.getDNAZooData <- function(entry, verbose = FALSE) {
    bfc <- DNAZooDataCache()
    hic_name <- basename(entry$hic_link)
    readme_name <- paste0(basename(dirname(entry$readme_link)), '_', basename(entry$readme_link))
    hic_rid <- bfcquery(bfc, query = hic_name)$rid
    if (!length(hic_rid)) {
        if( verbose ) message( "Fetching Hi-C data from DNAZoo" )
        if (entry$new_assembly_link_status == 200) {
            bfcentry <- bfcadd( 
                bfc, 
                rname = hic_name, 
                fpath = entry$hic_link
            )
            hic_rid <- names(bfcentry)
        }
        else {
            stop("No Hi-C contact matrix available for this species.")
        }
    }
    readme_rid <- bfcquery(bfc, query = readme_name)$rid
    if (!length(readme_rid)) {
        if( verbose ) message( "Fetching Hi-C metadata from DNAZoo" )
        bfcentry <- bfcadd( 
            bfc, 
            rname = readme_name, 
            fpath = entry$readme_link
        )
        readme_rid <- names(bfcentry)
    }
    hic_localpath <- bfcrpath(bfc, rids = c(hic_rid))
    readme_localpath <- bfcrpath(bfc, rids = c(readme_rid))

    ## -- Fetch `.hic` as HicFile
    mdata <- rjson::fromJSON(file = readme_localpath)
    mdata <- mdata[c('organism', 'draftAssembly', 'chromlengthAssembly', 'links', 'credits')]
    mdata$assemblyURL <- ifelse(
        entry$new_assembly_link_status == 200, 
        entry$new_assembly_link, 
        NA
    )
    HiCExperiment::HicFile(
        hic_localpath, 
        metadata = mdata
    )
}
