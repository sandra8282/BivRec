% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.joint.cdf.R
\name{plot.joint.cdf}
\alias{plot.joint.cdf}
\title{Plot Joint CDF after non-parametric analysis}
\usage{
\method{plot}{joint.cdf}(bivrec.nonparam.result, CI)
}
\arguments{
\item{bivrec.nonparam.result}{List with joint.cdf, formula, data. Passed from biv.rec.np()}

\item{CI}{Confidence level for CI. Passed from biv.rec.np()}
}
\value{
A 3D scatter plot of joint cdf with confidence interval.
}
\description{
This function plots joint cdf for recurrent event data.  Called from biv.rec.np(). No user interface.
}
\keyword{internal}
