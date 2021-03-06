% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/weightedMethylation.R
\name{cpgWeights}
\alias{cpgWeights}
\title{cpgWeights}
\usage{
cpgWeights(x)
}
\arguments{
  \item{x}{A \code{GRanges} of CpG site positions to
  calculate weighting factors for}
}
\value{
Integer vector of weights in the same order as the supplied
\code{x}
}
\description{
Calculate weights for CpG density weighted means, as used
in Berman BP 2011
}
\author{
Aaron Statham <a.statham@garvan.org.au>
}

