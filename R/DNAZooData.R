#' @title DNAZooData
#' @name DNAZooData
#'
#' @description Fetches files from the DNAZoo data portal and caches them using 
#'   the BiocFileCache system. 
#' @param species Any species processed by the DNA Zoo 
#' (check https://www.dnazoo.org/assemblies) for a browser-based 
#' explorer.
#' 
#' @return `DNAZooData()` returns a HicFile object, which can then be 
#' imported in memory using `HiCExperiment::import()`. 
#' Metadata also points to a URL to directly fetch the genome assembly 
#' corrected by the DNA Zoo consortium.
#' @export
#' 
#' @examples
#' ###################################
#' ## Importing DNAZoo `.hic` files ##
#' ###################################
#' 
#' head(DNAZooData())
#' hf <- DNAZooData(species = 'Anolis_carolinensis')
#' hf
#' 
NULL 

#' @export

DNAZooData <- function(species = NULL) {
    dat <- .parseDNAZooMetadata()
    ## -- If no species: return all metadata
    if (is.null(species)) return(dat)
    ## -- If not matching species: return warning
    entry <- dat[dat$species == species, ]
    if (nrow(entry) == 0) {
        stop('Unknown `species`.\n  ', 
            'Please check which species IDs are available \n  ', 
            'from DNAZoo consortium in the data frame returned by DNAZooData().'
        )
    }
    res <- .getDNAZooData(entry, verbose = TRUE)
    return(res)
}
