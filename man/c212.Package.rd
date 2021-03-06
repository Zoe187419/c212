\name{c212-package}
\alias{c212-package}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Methods for the Detection of Safety Signals in Randomised Controlled Trials using Groupings.}
\description{
This package implements a number of methods for the detection of safety signals in Clinical Trials based on
groupings of adverse events by body-system or system organ class.
The methods include an implementation of the Three-Level Hierarchical model for
Clinical Trial Adverse Event Incidence Data of Berry and Berry (2004)
and an implementation of the same model without the Point Mass (Model 1a from Xia et al (2011)), extended Bayesian hierarchical methods
based on system organ class or body-system groupings for interim analyses.
The package also implements a number of methods for error control when testing multiple hypotheses, specifically control of the False
Discovery Rate (FDR). The FDR control methods implemented are the Benjamini-Hochberg procedure, the Double False Discovery Rate, the Group
Benjamini-Hochberg and subset Benjamini-Hochberg methods. Also included are the Bonferroni correction and the unadjusted testing procedure.}

\details{
The methods implemented use assumed groupings of adverse events by body-system or system organ class to 
detect differences in the occurrence of adverse events on trial arms. Methods based on Bayesian Hierarchical
models and  direct error controlling procedures are provided.

The basic (Bayesian) hierarchical models are described in Berry and Berry (2004), Xia et al (2011) (Model 1a) and
Berry et al (2010). These methods are extended for interim analyses.

The direct error controlling methods are designed to control the number of Type-I errors at an acceptable level
without compromising the power. If the Familywise Error Rate (FWER) is defined as the probability of making
one or more Type-I errors when analysing multiple hypotheses (the “family”), then an alternative to controlling the FWER is to control the
False Discovery Rate (FDR) - the expected proportion of false discoveries (Type-I errors) to the total number of discoveries. 
Essentially control of the FDR assumes that when many of the tested hypotheses are rejected it may be preferable to control the proportion
of errors rather than the probability of making even one error. This is expected to lead to a gain in power. 
Further FDR controlling methods which use the information available in groupings of hypotheses have been developed (Double False Discovery
Rate (Mehrotra and Adewale (2012)), Group Benjamini-Hochberg (Hu, Zhao and Zhou (2010))).
For the methods contained in this package control of the False Discovery Rate has been established for independent test statistics and some forms of positive dependency (positive regression dependency), apart from the case of the Group Benjamini-Hochberg procedure where the control is asymptotic. Further details can be found in the references.

}
\author{
R. Carragher<raymond.carragher@strath.ac.uk; rcarragh@gmail.com>
}

\references{
S. M. Berry and D. A. Berry (2004). Accounting for multiplicities in assessing drug safety: a three-
level hierarchical mixture model.
Biometrics, 60(2):418-26.

H. Amy Xia, Haijun Ma, and Bradley P. Carlin (2011). Bayesian hierarchical modelling for
detecting safety signals in clinical trials. Journal of Biopharmaceutical Statistics, 21(5):1006–
1029.

Scott M. Berry, Bradley P. Carlin, J. Jack Lee, and Peter M¨ller (2010). Bayesian adaptive
methods for clinical trials. CRC Press.

Benjamini, Yoav and Hochberg, Yosef, (1995).
   Controlling the False Discovery Rate: A Practical and Powerful Approach to Multiple Testing.
   Journal of the Royal Statistical Society. Series B (Methodological), 57(1):289-300.

D. V. Mehrotra and J. F. Heyse (2004). Use of the false discovery rate for evaluating clinical
safety data. Stat Methods Med Res, 13(3):227–38, 2004.

Mehrotra, D. V. and Adewale, A. J. (2012). Flagging clinical adverse experiences: reducing false discoveries without materially compromising power for detecting true signals. Stat Med, 31(18):1918-30.

Hu, J. X. and Zhao, H. and Zhou, H. H. (2010). False Discovery Rate Control With Groups. J Am Stat Assoc, 105(491):1215-1227.

Y. Benjamini, A. M. Krieger, and D. Yekutieli (2006). Adaptive linear step-up procedures that
control the false discovery rate. Biometrika, 93(3):491–507.

Benjamini Y, Hochberg Y. (2000). On the Adaptive Control of the False Discovery Rate in Multiple Testing
With Independent Statistics. Journal of Educational and Behavioral Statistics, 25(1):60–83.

Yekutieli, Daniel (2008). False discovery rate control for non-positively regression dependent test statistics. Journal of Statistical Planning and Inference, 138(2):405-415.

Matthews, John N. S. (2006) Introduction to Randomized Controlled Clinical Trials, Second Edition. Chapman & Hall/CRC Texts in Statistical Science.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{FDR}
\keyword{False Discovery Rate}
\keyword{GBH}
\keyword{Group Benjamini-Hochberg}
\keyword{DFDR}
\keyword{Double False Discovery Rate}
\keyword{ssBH}
\keyword{Subset Benjamin-Hochberg}
\keyword{Bayesian Hierarchy}
\keyword{Adverse Event}
\keyword{Berry}
\keyword{Interim analysis}
\keyword{Body-system}
\keyword{System organ class}
\keyword{c212-package}
