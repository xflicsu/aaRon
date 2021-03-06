#' findDomains
#'
#' Find DNA methylation domains using the procedure described in Hovestaft 2014
#'
#' @param x \code{GRanges} of methylation count data
#' @param samples \code{data.frame} describing the samples to discover domains for
#' @param minSize Minimum number of basepairs with methylation below \code{cutoff} for a region to be called as a domain
#' @param wsize Window size to take weighted means within across the genome
#' @param step Distance to step windows across the genome by
#' @param cutoff Maximum weighted mean of a window to contribute to a domain
#' @param minCov Minumum sequencing coverage for a CpG site to contribute to the weighted mean calculation
#' @return \code{GRangesList} of domains found in each sample
#' 
#' @importFrom GenomicRanges values values<- seqnames GRangesList reduce width split
#' @importFrom GenomeInfoDb seqlengths
#' @importFrom Repitools genomeBlocks
#' 
#' @export
#'
#' @author Aaron Statham <a.statham@@garvan.org.au>
findDomains <- function(x, samples, minSize=5000, wsize=1000, step=100, cutoff=0.15, minCov=5) {
    stopifnot(all(c("Sample", "C", "cov") %in% colnames(samples)))
    if (!"w" %in% names(values(x))) {
        message("Weights missing from 'x', calculating...")
        x$w <- cpgWeights(x)
    }
	stopifnot(all(!is.na(seqlengths(x))))

	bins <- genomeBlocks(seqlengths(x), width=wsize, spacing=step)

    x.rat <- methRatios(x, samples, minCov)

    # split through chromosomes and mclapply
    bins <- GenomicRanges::split(bins, seqnames(bins))
    x.rat <- GenomicRanges::split(x.rat, seqnames(x.rat))
    w <- split(x$w, as.character(seqnames(x)))
    wm <- unlist(GRangesList(mclapply(names(bins), function(i) {
        message("Processing ", i)
        tmp <- bins[[i]]
        values(tmp) <- weightedMethylation(x.rat[[i]], bins[[i]], w[[i]])
        message(i, " Finished!")
        tmp
    })))
    rm(bins, x.rat, w)
    bins <- unvalue(wm)
    domains <- GRangesList(mclapply(1:ncol(values(wm)), function(i) {
        tmp <- reduce(bins[which(values(wm)[[i]]<cutoff)])
        tmp[width(tmp)>=minSize]
    }))
    names(domains) <- samples$Sample
    domains
}

#' findDMVs
#' 
#' Find DNA methylation valleys using the procedure described in Hovestaft 2014
#' 
#' @param x \code{GRanges} of methylation count data
#' @param samples \code{data.frame} describing the samples to discover DMVs within
#' @param minCov Minumum sequencing coverage for a CpG site to contribute to the weighted mean calculation
#' @return \code{GRangesList} of DMVs found in each sample
#' 
#' @export
#'
#' @author Aaron Statham <a.statham@@garvan.org.au>
findDMVs <- function(x, samples, minCov=5) findDomains(x, samples, minSize=5000, wsize=1000, step=100, cutoff=0.15, minCov=minCov)

#' findPMDs
#' 
#' Find partially domains using the procedure described in Hovestaft 2014
#' 
#' @param x \code{GRanges} of methylation count data
#' @param samples \code{data.frame} describing the samples to discover PMDs within
#' @param minCov Minumum sequencing coverage for a CpG site to contribute to the weighted mean calculation
#' @return \code{GRangesList} of PMDs found in each sample
#' 
#' @export
#'
#' @author Aaron Statham <a.statham@@garvan.org.au>
findPMDs <- function(x, samples, minCov=5) findDomains(x, samples, minSize=100000, wsize=10000, step=100, cutoff=0.6, minCov=minCov)
