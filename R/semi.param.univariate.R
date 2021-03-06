  ###########################################################################
  ############## FUNCTIONS FOR REFERENCE BY MAIN - NOT FOR USER #############
  ###########################################################################

#                  o.fun, all PRO and var.est FUNCTIONS                        #
#_______________________________________________________________________________
# Original by Chihyun Lee (August, 2017)                                       #
# Last Modified by Sandra Castro-Pearson (April, 2018)                         #
# Received from Chihyun Lee (January, 2018)                                    #
#_______________________________________________________________________________

r2f.pro.ee1 <- function(n, nparams, di, xmati, gmati, L, expA, subsum, kcount){
    out1 <- .Fortran("xmproee",
                     n=as.integer(n),
                     nparams=as.integer(nparams),
                     di=as.double(di),
                     xmati=as.double(xmati),
                     gmati=as.double(gmati),
                     L=as.double(L),
                     expA=as.double(expA),
                     subsum=as.double(subsum),
                     kcount=as.integer(kcount))

    subsum <- out1$subsum

    return(subsum)
}

r2f.pro.ee2 <- function(n, nparams, di, xmati, ymati, gmati, L, expA, subsum, kcount){
    out2 <- .Fortran("ymproee",
                     n=as.integer(n),
                     nparams=as.integer(nparams),
                     di=as.double(di),
                     xmati=as.double(xmati),
                     ymati=as.double(ymati),
                     gmati=as.double(gmati),
                     L=as.double(L),
                     expA=as.double(expA),
                     subsum=as.double(subsum),
                     kcount=as.integer(kcount))

    subsum <- out2$subsum

    return(subsum)
  }

r2f.pro.var <- function(n, nparams, xmat, ymat, gmatx, gmaty, l1, l2,
                           expAx, expAy, subsumx, subsumy, dx, dy, mstar, mc){
    out <- .Fortran("mprovar",
                    n=as.integer(n),
                    nparams=as.integer(nparams),
                    xmati=as.double(xmat),
                    ymati=as.double(ymat),
                    gmatx=as.double(gmatx),
                    gmaty=as.double(gmaty),
                    l1=as.double(l1),
                    l2=as.double(l2),
                    expAx=as.double(expAx),
                    expAy=as.double(expAy),
                    subsumx=as.double(subsumy),
                    subsumy=as.double(subsumy),
                    dx=as.double(dx),
                    dy=as.double(dy),
                    mstar=as.double(mstar),
                    mc=as.integer(mc))

    subsum1 <- out$subsumx
    subsum2 <- out$subsumy

    return(cbind(subsum1, subsum2))
}

##------symmetric O function
o.fun=function(t,s,L) {log(min(max(t,s),L))-log(L)}

##-----estimation functions

##proposed method
Pro.ee1=function(beta1,mdat) {
  n=mdat$n
  xmat=mdat$xmat
  delta1=mdat$delta1
  g1mat=mdat$g1mat
  l1=mdat$l1
  mstar=mdat$mstar
  amat=mdat$amat

  tmp.out=NULL
  for (i in 1:n) {
    A=(amat)-amat[i]
    expA=exp(A*beta1)
    di <- delta1[i,1:mstar[i]]
    xmati <- xmat[i,1:mstar[i]]
    gmati <- g1mat[i,1:mstar[i]]
    subsum <- r2f.pro.ee1(n, nparams=1, di, xmati, gmati, L=l1, expA, subsum = rep(0,n), kcount=mstar[i])
    #subsum=sapply(expA,function(x)mean(delta1[i,1:mstar[i]]*sapply(xmat[i,1:mstar[i]],function(t)o.fun(t,x*t,l1))/g1mat[i,1:mstar[i]]))
    tmp.out=c(tmp.out,sum(A*subsum))
  }
  out=sum(tmp.out)/(n^2)
  return(out)
}

Pro.uf1=function(beta1,mdat) {
  tmp.out=Pro.ee1(beta1,mdat)
  out=tmp.out%*%tmp.out
  return(out)
}

Pro.uest1=function(int,mdat) {
  res=optimize(Pro.uf1,interval=int,mdat=mdat)
  return(list(par=res$minimum,value=res$objective))
}

Pro.ee2=function(beta2,beta1,mdat) {
  n=mdat$n
  xmat=mdat$xmat
  ymat=mdat$ymat
  delta2=mdat$delta2
  g2mat=mdat$g2mat
  l2=mdat$l2
  mstar=mdat$mstar
  amat=mdat$amat

  tmp.out=NULL
  for (i in 1:n) {
    A=(amat)-amat[i]
    expA1=exp(A*beta1)
    expA2=exp(A*beta2)
    expA=cbind(expA1,expA2)
    di <- delta2[i,1:mstar[i]]
    xmati <- xmat[i,1:mstar[i]]
    ymati <- ymat[i,1:mstar[i]]
    gmati <- g2mat[i,1:mstar[i]]
    subsum <- r2f.pro.ee2(n, nparams=1, di, xmati, ymati, gmati, L=l2, expA, subsum = rep(0,n), kcount=mstar[i])
    # subsum=apply(expA,1,function(x)mean(delta2[i,1:mstar[i]]*apply(cbind(xmat[i,1:mstar[i]],ymat[i,1:mstar[i]]),1,function(t)o.fun(sum(t),x[1]*t[1]+x[2]*t[2],l2))/g2mat[i,1:mstar[i]]))
    tmp.out=c(tmp.out,sum(A*subsum))
  }
  out=sum(tmp.out)/(n^2)
  return(out)
}

Pro.uf2=function(beta2,beta1,mdat) {
  tmp.out=Pro.ee2(beta2,beta1,mdat)
  out=tmp.out%*%tmp.out
  return(out)
}

Pro.uest2=function(int,beta1,mdat) {
  res=optimize(Pro.uf2,interval=int,beta1=beta1,mdat=mdat)
  return(list(par=res$minimum,value=res$objective))
}


##variance estimation
var.est=function(beta1,beta2,mdat) {
  n=mdat$n
  mc=mdat$mc
  xmat=mdat$xmat
  ymat=mdat$ymat
  delta1=mdat$delta1
  delta2=mdat$delta2
  g1mat=mdat$g1mat
  g2mat=mdat$g2mat
  l1=mdat$l1
  l2=mdat$l2
  mstar=mdat$mstar
  amat=mdat$amat

  xi=matrix(0,length(c(beta1,beta2)),length(c(beta1,beta2)))
  gam1=gam21=gam22=rep(0,length(beta1))
  for (i in 1:n) {
    A=(amat)-amat[i]
    expA1=exp(A*beta1)
    expA2=exp(A*beta2)
    expA=cbind(expA1,expA2)

    d1i <- delta1[i,1:mstar[i]]
    d2i <- delta2[i,1:mstar[i]]
    xmati <- xmat[i,1:mstar[i]]
    ymati <- ymat[i,1:mstar[i]]
    gmati1 <- g1mat[i,1:mstar[i]]
    gmati2 <- g2mat[i,1:mstar[i]]

    subsum <- rep(0,n)
    sub1.xi1 <- r2f.pro.ee1(n, nparams=1, di=d1i, xmati, gmati=gmati1, L=l1, expA=expA1, subsum, kcount=mstar[i])
    sub1.xi2 <- r2f.pro.ee2(n, nparams=1, di=d2i, xmati, ymati, gmati=gmati2, L=l2, expA, subsum, kcount=mstar[i])

    #sub1.xi1=sapply(expA1,function(x) mean(delta1[i,1:mstar[i]]*sapply(xmat[i,1:mstar[i]],function(t)o.fun(t,x*t,l1))/g1mat[i,1:mstar[i]]))
    #sub1.xi2=apply(expA,1,function(x) mean(delta2[i,1:mstar[i]]*apply(cbind(xmat[i,1:mstar[i]],ymat[i,1:mstar[i]]),1,function(t)o.fun(sum(t),x[1]*t[1]+x[2]*t[2],l2))/g2mat[i,1:mstar[i]]))

    sub2 <- r2f.mpro.var(n, nparams=1, xmat, ymat, gmatx=g1mat, gmaty=g2mat, l1, l2,
                         expAx=expA1, expAy=expA2, subsumx=subsum, subsumy=subsum, dx=delta1, dy=delta2, mstar, mc)
    sub2.xi1 <- sub2[,1]
    sub2.xi2 <- sub2[,2]

    #sub2.xi1=sub2.xi2=rep(0,n)
    # for (j in 1:n) {
    #   sub2.xi1[j]=mean(delta1[j,1:mstar[j]]*sapply(xmat[j,1:mstar[j]],function(t)o.fun(t,t/expA1[j],l1))/g1mat[j,1:mstar[j]])
    # }
    # for (j in 1:n) {
    #   sub2.xi2[j]=mean(delta2[j,1:mstar[j]]*apply(cbind(xmat[j,1:mstar[j]],ymat[j,1:mstar[j]]),1,function(t)o.fun(sum(t),t[1]/expA1[j]+t[2]/expA2[j],l2))/g2mat[j,1:mstar[j]])
    # }

    tmp.xi1=sum(A*(sub1.xi1-sub2.xi1))/(n^(3/2))
    tmp.xi2=sum(A*(sub1.xi2-sub2.xi2))/(n^(3/2))

    xi=xi+c(tmp.xi1,tmp.xi2)%o%c(tmp.xi1,tmp.xi2)

    Amat=sapply(A,function(x) x%o%x)
    tmp.sub.gam1=apply(cbind(xmat[i,1],expA1*xmat[i,1],l1),1,function(x)(x[1]<=x[2])*(max(x[1],x[2])<=x[3]))
    tmp.sub.gam2=apply(cbind(xmat[i,1]+ymat[i,1],expA1*xmat[i,1]+expA2*ymat[i,1],l2),1,function(x)(x[1]<=x[2])*(max(x[1],x[2])<=x[3]))
    sub.gam1=(Amat)*tmp.sub.gam1*mean(delta1[i,1:mstar[i]]/g1mat[i,1:mstar[i]])
    sub.gam21=(Amat)*tmp.sub.gam2*apply(expA,1,function(x) mean(delta2[i,1:mstar[i]]*(x[1]*xmat[i,1:mstar[i]])/((x[1]*xmat[i,1:mstar[i]]+x[2]*ymat[i,1:mstar[i]])*g2mat[i,1:mstar[i]])))
    sub.gam22=(Amat)*tmp.sub.gam2*apply(expA,1,function(x) mean(delta2[i,1:mstar[i]]*(x[2]*ymat[i,1:mstar[i]])/((x[1]*xmat[i,1:mstar[i]]+x[2]*ymat[i,1:mstar[i]])*g2mat[i,1:mstar[i]])))

    gam1=gam1+sum(sub.gam1)/(n^2)
    gam21=gam21+sum(sub.gam21)/(n^2)
    gam22=gam22+sum(sub.gam22)/(n^2)
  }
  gam1=matrix(gam1,length(beta1),length(beta1))
  gam21=matrix(gam21,length(beta2),length(beta2))
  gam22=matrix(gam22,length(beta2),length(beta2))
  gamm=rbind(cbind(gam1,matrix(0,length(beta1),length(beta2))),cbind(gam21,gam22))

  mat=solve(gamm)%*%xi%*%t(solve(gamm))

  se1=sqrt(diag(mat)/n)[1]
  se2=sqrt(diag(mat)/n)[2]
  return(list(se1=se1,se2=se2))
}

###################################################################
######################## FUNCTION FOR USE ########################
###################################################################
#' A Function for univariate fits using semiparametric regression method on a biv.rec object
#'
#' @description
#' This function fits the semiparametric model given only one covariate. Called from biv.rec.fit(). No user interface.
#' @param new_data An object that has been reformatted for fit using the biv.rec.reformat() function. Passed from biv.rec.fit().
#' @param cov_names A vector with the names of the single covariate. Passed from biv.rec.fit().
#' @param CI Passed from biv.rec.fit().
#' @return A dataframe summarizing covariate effect estimate, SE and CI.
#' @seealso \code{\link{biv.rec.fit}}
#'
#' @importFrom stats na.omit
#' @importFrom stats optim
#' @importFrom stats optimize
#' @importFrom stats qnorm
#' @importFrom stats rbinom
#' @importFrom stats rgamma
#' @importFrom stats rnorm
#' @importFrom stats runif
#'
#' @useDynLib BivRec xmproee ymproee mprovar
#' @keywords internal

#MAIN PROGRAM FOR univariate regression analysis
semi.param.univariate <- function(new_data, cov_names, CI) {

  print(paste("Fitting model with covariate", cov_names))
  pro1 <- Pro.uest1(c(-2,2),new_data)[[1]]
  pro2 <- Pro.uest2(c(-2,2), pro1, new_data)[[1]]

  if (is.null(CI)==TRUE) {
    #return point estimates only
    univ_fits <- data.frame(c(pro1, pro2))
    colnames(univ_fits) <- c("Estimate")
    rownames(univ_fits) <- c(paste("xij", cov_names), paste("yij", cov_names))

  } else {

    print("Estimating standard errors/confidence intervals")
    #estimate covariance matrix and get diagonal then std. errors
    sd_est=var.est(pro1, pro2, new_data)
    univ_fits <- data.frame(c(pro1, pro2), c(sd_est$se1,sd_est$se2))

    #Calculate CI's and put in nice table
    conf.lev = 1 - ((1-CI)/2)
    CIcalc <- t(apply(univ_fits, 1, function (x) c(x[1]+qnorm(1-conf.lev)*x[2], x[1]+qnorm(conf.lev)*x[2])))
    univ_fits <- cbind(univ_fits, CIcalc)
    low.string <- paste((1 - conf.lev), "%", sep="")
    up.string <- paste(conf.lev, "%", sep="")
    colnames(univ_fits) <- c("Estimate", "SE", low.string, up.string)
    rownames(univ_fits) <- c(paste("xij", cov_names), paste("yij", cov_names))

  }

  return(univ_fits)
}


