.getAnswer <- function(msg, allowed)
{
    if (interactive()) {
        repeat {
            cat(msg)
            answer <- readLines(n = 1)
            if (answer %in% allowed)
                break
        }
        tolower(answer)
    } else {
        "n"
    }
}

#' @importFrom utils read.delim2

.parseDNAZooMetadata <- function() {
    tab <- system.file('extdata', 'dnazoo.txt', package = 'DNAZooData')
    dat <- utils::read.delim2(tab, sep = '\t', header = FALSE)
    colnames(dat) <- c("species", "readme", "readme_link", "original_assembly", "new_assembly", "new_assembly_link", "new_assembly_link_status", "hic_link")
    return(dat)
}
