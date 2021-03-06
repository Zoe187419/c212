#c212.BB.convergence.diag # Case 2/12 Model c212.BB
# R. Carragher
# Date: 08/05/2015
#
# If the MCMC simulation has been run for more than one chain report the Gelman-Rubin statistic.
# If the MCMC simulation has been run for only one chain report the Geweke diagnostic (Z-score)
#

Id <- "$Id: c212.interim.BB.hier3.lev0.convergence.R,v 1.9 2019/05/05 13:18:12 clb13102 Exp clb13102 $"

c212.interim.BB.indep.convergence.diag <- function(raw, debug_diagnostic = FALSE)
{
	c_base = c212.interim.1a.indep.convergence.diag(raw, debug_diagnostic)

	if (is.null(c_base)) {
		return(NULL)
	}

	# Check which variables we are monitoring
	monitor = raw$monitor
	theta_mon = monitor[monitor$variable == "theta",]$monitor
	pi_mon = monitor[monitor$variable == "pi",]$monitor
	alpha_pi_mon = monitor[monitor$variable == "alpha.pi",]$monitor
	beta_pi_mon = monitor[monitor$variable == "beta.pi",]$monitor

	nchains = raw$chains

	if (alpha_pi_mon == 1 && !("alpha.pi" %in% names(raw))) {
		print("Missing alpha.pi data")
		return(NULL)
	}
	if (beta_pi_mon == 1 && !("beta.pi" %in% names(raw))) {
		print("Missing beta.pi data")
		return(NULL)
	}
	if (pi_mon == 1 && !("pi" %in% names(raw))) {
		print("Missing pi data")
		return(NULL)
	}

	if (raw$sim_type == "MH") {
		if (alpha_pi_mon == 1 && !("alpha.pi_acc" %in% names(raw))) {
			print("Missing beta.pi_acc data")
			return(NULL)
		}
		if (beta_pi_mon == 1 && !("beta.pi_acc" %in% names(raw))) {
			print("Missing beta.pi_acc data")
			return(NULL)
		}
	}
	else {
		if (theta_mon == 1 && !("theta_acc" %in% names(raw))) {
			print("Missing theta_acc data")
			return(NULL)
		}
	}

	pi_conv = data.frame(Interval = character(0), B = character(0), stat = numeric(0), upper_ci = numeric(0), stringsAsFactors=FALSE)
	alpha.pi_conv = data.frame(Interval = character(0), stat = numeric(0), upper_ci = numeric(0), stringsAsFactors=FALSE)
	beta.pi_conv = data.frame(Interval = character(0), stat = numeric(0), upper_ci = numeric(0), stringsAsFactors=FALSE)

	type <- NA

	if (nchains > 1) {
		# Gelman-Rubin Statistics

		type = "Gelman-Rubin"

		for (i in 1:raw$nIntervals) {
			if (pi_mon == 1) {
				for (b in 1:raw$nBodySys[i]) {
					# pi
					g = M_global$GelmanRubin(raw$pi[, i, b, ], nchains)
					row <- data.frame(Interval = raw$Intervals[i], B = raw$B[i, b],
											stat = g$psrf[1], upper_ci =  g$psrf[2], stringsAsFactors=FALSE)
					pi_conv = rbind(pi_conv, row)
				}
			}
		}

		# alpha.pi
		if (alpha_pi_mon == 1) {
			for (i in 1:raw$nIntervals) {
				g = M_global$GelmanRubin(raw$alpha.pi[, i, ], nchains)
				row <- data.frame(Interval = raw$Intervals[i], stat = g$psrf[1], upper_ci =  g$psrf[2], stringsAsFactors=FALSE)
				alpha.pi_conv = rbind(alpha.pi_conv, row)
			}
		}

		# beta.pi
		if (beta_pi_mon == 1) {
			for (i in 1:raw$nIntervals) {
				g = M_global$GelmanRubin(raw$beta.pi[, i, ], nchains)
				row <- data.frame(Interval = raw$Intervals[i], stat = g$psrf[1], upper_ci =  g$psrf[2], stringsAsFactors=FALSE)
				beta.pi_conv = rbind(beta.pi_conv, row)
			}
		}
	}
	else {
		# Geweke Diagnostic

		type = "Geweke"

		for (i in 1:raw$nIntervals) {
			if (pi_mon == 1) {
				for (b in 1:raw$nBodySys[i]) {
					# pi
					g = M_global$Geweke(raw$pi[1, i, b, ])
					row <- data.frame(Interval = raw$Intervals[i], B = raw$B[i, b], stat = g$z, upper_ci = NA, stringsAsFactors=FALSE)
					pi_conv = rbind(pi_conv, row)
				}
			}

			if (alpha_pi_mon == 1) {
				g = M_global$Geweke(raw$alpha.pi[1, i, ])
				row <- data.frame(Interval = raw$Intervals[i], stat = g$z, upper_ci = NA, stringsAsFactors=FALSE)
				alpha.pi_conv = rbind(alpha.pi_conv, row)
			}

			if (beta_pi_mon == 1) {
				g = M_global$Geweke(raw$beta.pi[1, i, ])
				row <- data.frame(Interval = raw$Intervals[i], stat = g$z, upper_ci = NA, stringsAsFactors=FALSE)
				beta.pi_conv = rbind(beta.pi_conv, row)
			}
		}
	}

	theta_acc = data.frame(chain = numeric(0), Interval = character(0), B = character(0),
											AE = character(0), rate = numeric(0), stringsAsFactors=FALSE)
	alpha.pi_acc = data.frame(chain = numeric(0), Interval = character(0), rate = numeric(0), stringsAsFactors=FALSE)
	beta.pi_acc = data.frame(chain = numeric(0), Interval = character(0), rate = numeric(0), stringsAsFactors=FALSE)

	if (theta_mon == 1) {
		for (i in 1:raw$nIntervals) {
			for (b in 1:raw$nBodySys[i]) {
				for (j in 1:raw$nAE[i, b]) {
					for (c in 1:nchains) {
						rate <- raw$theta_acc[c, i, b, j]/raw$iter
						row <- data.frame(chain = c, Interval = raw$Intervals[i], B = raw$B[i, b],
								AE = raw$AE[i, b,j], rate = rate, stringsAsFactors=FALSE)
						theta_acc = rbind(theta_acc, row)
					}
				}
			}
		}
	}

	if (raw$sim_type == "MH") {
		for (i in 1:raw$nIntervals) {
			for (c in 1:nchains) {
				if (alpha_pi_mon == 1) {
					rate <- raw$alpha.pi_acc[c, i]/raw$iter
					row <- data.frame(chain = c, Interval = raw$Intervals[i], rate = rate, stringsAsFactors=FALSE)
					alpha.pi_acc = rbind(alpha.pi_acc, row)
				}
				if (beta_pi_mon == 1) {
					rate <- raw$beta.pi_acc[c, i]/raw$iter
					row <- data.frame(chain = c, Interval = raw$Intervals[i], rate = rate, stringsAsFactors=FALSE)
					beta.pi_acc = rbind(beta.pi_acc, row)
				}
			}
		}
	}
	
	rownames(theta_acc) <- NULL
	rownames(pi_conv) <- NULL
	rownames(alpha.pi_conv) <- NULL
	rownames(beta.pi_conv) <- NULL
	rownames(alpha.pi_acc) <- NULL
	rownames(beta.pi_acc) <- NULL

	c_base$theta_acc = theta_acc

	c_BB = list(pi.conv.diag = pi_conv, alpha.pi.conv.diag = alpha.pi_conv, beta.pi.conv.diag = beta.pi_conv,
		alpha.pi_acc = alpha.pi_acc, beta.pi_acc = beta.pi_acc)

	conv.diag = c(c_base, c_BB)

	attr(conv.diag, "model") = attr(raw, "model")
	return(conv.diag)
}

c212.interim.BB.indep.print.convergence.summary <- function(conv) {

	if (is.null(conv)) {
		print("NULL conv data")
		return(NULL)
	}

	# Check which variables we are monitoring
	monitor = conv$monitor
	theta_mon = monitor[monitor$variable == "theta",]$monitor
	gamma_mon = monitor[monitor$variable == "gamma",]$monitor
	mu.theta_mon = monitor[monitor$variable == "mu.theta",]$monitor
	mu.gamma_mon = monitor[monitor$variable == "mu.gamma",]$monitor
	sigma2.theta_mon = monitor[monitor$variable == "sigma2.theta",]$monitor
	sigma2.gamma_mon = monitor[monitor$variable == "sigma2.gamma",]$monitor
	mu.theta.0_mon = monitor[monitor$variable == "mu.theta.0",]$monitor
	mu.gamma.0_mon = monitor[monitor$variable == "mu.gamma.0",]$monitor
	tau2.theta.0_mon = monitor[monitor$variable == "tau2.theta.0",]$monitor
	tau2.gamma.0_mon = monitor[monitor$variable == "tau2.gamma.0",]$monitor
	pi_mon = monitor[monitor$variable == "pi",]$monitor
	alpha_pi_mon = monitor[monitor$variable == "alpha.pi",]$monitor
	beta_pi_mon = monitor[monitor$variable == "beta.pi",]$monitor

	model = attr(conv, "model")
	if (is.null(model)) {
		print("Convergence model attribute missing")
		return(NULL)
	}

	if (gamma_mon == 1 && !("gamma.conv.diag" %in% names(conv))) {
		print("Missing gamma.conv.diag data")
		return(NULL)
	}
	if (theta_mon == 1 && !("theta.conv.diag" %in% names(conv))) {
		print("Missing theta.conv.diag data")
		return(NULL)
	}
	if (mu.gamma_mon == 1 && !("mu.gamma.conv.diag" %in% names(conv))) {
		print("Missing mu.gamma.conv.diag data")
		return(NULL)
	}
	if (mu.theta_mon == 1 && !("mu.theta.conv.diag" %in% names(conv))) {
		print("Missing mu.theta.conv.diag data")
		return(NULL)
	}
	if (sigma2.gamma_mon == 1 && !("sigma2.gamma.conv.diag" %in% names(conv))) {
		print("Missing sigma2.gamma.conv.diag data")
		return(NULL)
	}

    if (sigma2.theta_mon == 1 && !("sigma2.theta.conv.diag" %in% names(conv))) {
		print("Missing sigma2.theta.conv.diag data")
		return(NULL)
	}
    if (mu.gamma.0_mon == 1 && !("mu.gamma.0.conv.diag" %in% names(conv))) {
		print("Missing mu.gamma.0.conv.diag data")
		return(NULL)
	}
    if (mu.theta.0_mon == 1 && !("mu.theta.0.conv.diag" %in% names(conv))) {
		print("Missing mu.theta.0.conv.diag data")
		return(NULL)
	}
	 if (tau2.gamma.0_mon== 1 && !("tau2.gamma.0.conv.diag" %in% names(conv))) {
		print("Missing tau2.gamma.0.conv.diag data")
		return(NULL)
	}
    if (tau2.theta.0_mon == 1 && !("tau2.theta.0.conv.diag" %in% names(conv))) {
		print("Missing tau2.theta.0.conv.diag data")
		return(NULL)
	}
    if (gamma_mon == 1 && !("gamma_acc" %in% names(conv))) {
		print("Missing gamma_acc data")
		return(NULL)
	}
    if (theta_mon == 1 && !("theta_acc" %in% names(conv))) {
		print("Missing theta_acc data")
		return(NULL)
	}

	if (pi_mon == 1 && !("pi.conv.diag" %in% names(conv))) {
		print("Missing pi.conv.diag data")
		return(NULL)
	}
	if (alpha_pi_mon == 1 && !("alpha.pi.conv.diag" %in% names(conv))) {
		print("Missing alpha.pi.conv.diag data")
		return(NULL)
	}
	if (beta_pi_mon == 1 && !("beta.pi.conv.diag" %in% names(conv))) {
		print("Missing beta.pi.conv.diag data")
		return(NULL)
	}
	if (alpha_pi_mon == 1 && !("alpha.pi_acc" %in% names(conv))) {
		print("Missing alpha.pi_acc data")
		return(NULL)
	}
	if (beta_pi_mon == 1 && !("beta.pi_acc" %in% names(conv))) {
		print("Missing beta.pi_acc data")
			return(NULL)
	}

	cat(sprintf("Summary Convergence Diagnostics:\n"))
	cat(sprintf("================================\n"))

	if (conv$type == "Gelman-Rubin") {
		if (theta_mon == 1) {
			cat(sprintf("theta:\n"))
			cat(sprintf("------\n"))
	
			max_t = head(conv$theta.conv.diag[conv$theta.conv.diag$stat == max(conv$theta.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic (%s %s %s): %0.6f\n", max_t$Interval, max_t$B, max_t$AE, max_t$stat))
			min_t = head(conv$theta.conv.diag[conv$theta.conv.diag$stat == min(conv$theta.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic (%s, %s %s): %0.6f\n", min_t$Interval, min_t$B, min_t$AE, min_t$stat))
	
		}
		if (gamma_mon == 1) {
			cat(sprintf("gamma:\n"))
			cat(sprintf("------\n"))
			max_t = head(conv$gamma.conv.diag[conv$gamma.conv.diag$stat == max(conv$gamma.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic (%s %s %s): %0.6f\n", max_t$Interval, max_t$B, max_t$AE, max_t$stat))
			min_t = head(conv$gamma.conv.diag[conv$gamma.conv.diag$stat == min(conv$gamma.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic (%s %s %s): %0.6f\n", min_t$Interval, min_t$B, min_t$AE, min_t$stat))

		}
		if (mu.gamma_mon == 1) {
			cat(sprintf("mu.gamma:\n"))
			cat(sprintf("---------\n"))
			max_t = head(conv$mu.gamma.conv.diag[conv$mu.gamma.conv.diag$stat
							== max(conv$mu.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic (%s %s): %0.6f\n", max_t$Interval, max_t$B, max_t$stat))
			min_t = head(conv$mu.gamma.conv.diag[conv$mu.gamma.conv.diag$stat
							== min(conv$mu.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic (%s %s): %0.6f\n", min_t$Interval, min_t$B, min_t$stat))

		}
		if (mu.theta_mon == 1) {
			cat(sprintf("mu.theta:\n"))
			cat(sprintf("---------\n"))
			max_t = head(conv$mu.theta.conv.diag[conv$mu.theta.conv.diag$stat
						== max(conv$mu.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic (%s %s): %0.6f\n", max_t$Interval, max_t$B, max_t$stat))
			min_t = head(conv$mu.theta.conv.diag[conv$mu.theta.conv.diag$stat
						== min(conv$mu.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic (%s %s): %0.6f\n", min_t$Interval, min_t$B, min_t$stat))

		}
		if (sigma2.gamma_mon == 1) {
			cat(sprintf("sigma2.gamma:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$sigma2.gamma.conv.diag[conv$sigma2.gamma.conv.diag$stat
					== max(conv$sigma2.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic (%s %s): %0.6f\n", max_t$Interval, max_t$B, max_t$stat))
			min_t = head(conv$sigma2.gamma.conv.diag[conv$sigma2.gamma.conv.diag$stat
					== min(conv$sigma2.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic (%s %s): %0.6f\n", min_t$Interval, min_t$B, min_t$stat))

		}
		if (sigma2.theta_mon == 1) {
			cat(sprintf("sigma2.theta:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$sigma2.theta.conv.diag[conv$sigma2.theta.conv.diag$stat
					== max(conv$sigma2.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic (%s %s): %0.6f\n", max_t$Interval, max_t$B, max_t$stat))
			min_t = head(conv$sigma2.theta.conv.diag[conv$sigma2.theta.conv.diag$stat
					== min(conv$sigma2.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic (%s %s): %0.6f\n", min_t$Interval, min_t$B, min_t$stat))


		}
		if (pi_mon == 1) {
			cat(sprintf("pi:\n"))
			cat(sprintf("---\n"))
			max_t = head(conv$pi.conv.diag[conv$pi.conv.diag$stat
					== max(conv$pi.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic (%s %s): %0.6f\n", max_t$Interval, max_t$B, max_t$stat))
			min_t = head(conv$pi.conv.diag[conv$pi.conv.diag$stat
					== min(conv$pi.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic (%s %s): %0.6f\n", min_t$Interval, min_t$B, min_t$stat))

		}
		if (mu.gamma.0_mon == 1) {
			cat(sprintf("mu.gamma.0:\n"))
			cat(sprintf("-----------\n"))
			max_t = head(conv$mu.gamma.0.conv.diag[conv$mu.gamma.0.conv.diag$stat
										== max(conv$mu.gamma.0.conv.diag$stat), ], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic: (%s) %0.6f\n", max_t$Interval, max_t$stat))
			min_t = head(conv$mu.gamma.0.conv.diag[conv$mu.gamma.0.conv.diag$stat
									== min(conv$mu.gamma.0.conv.diag$stat), ], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic: (%s) %0.6f\n", min_t$Interval, min_t$stat))

		}
		if (mu.theta.0_mon == 1) {
			cat(sprintf("mu.theta.0:\n"))
			cat(sprintf("-----------\n"))
			max_t = head(conv$mu.theta.0.conv.diag[conv$mu.theta.0.conv.diag$stat
									== max(conv$mu.theta.0.conv.diag$stat), ], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic: (%s) %0.6f\n", max_t$Interval, max_t$stat))
			min_t = head(conv$mu.theta.0.conv.diag[conv$mu.theta.0.conv.diag$stat
									== min(conv$mu.theta.0.conv.diag$stat), ], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic: (%s) %0.6f\n", min_t$Interval, min_t$stat))


		}
		if (tau2.gamma.0_mon == 1) {
			cat(sprintf("tau2.gamma.0:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$tau2.gamma.0.conv.diag[conv$tau2.gamma.0.conv.diag$stat
									== max(conv$tau2.gamma.0.conv.diag$stat), ], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic: (%s) %0.6f\n", max_t$Interval, max_t$stat))
			min_t = head(conv$tau2.gamma.0.conv.diag[conv$tau2.gamma.0.conv.diag$stat
									== min(conv$tau2.gamma.0.conv.diag$stat), ], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic: (%s) %0.6f\n", min_t$Interval, min_t$stat))


		}
		if (tau2.theta.0_mon == 1) {
			cat(sprintf("tau2.theta.0:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$tau2.theta.0.conv.diag[conv$tau2.theta.0.conv.diag$stat
										== max(conv$tau2.theta.0.conv.diag$stat), ], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic: (%s) %0.6f\n", max_t$Interval, max_t$stat))
			min_t = head(conv$tau2.theta.0.conv.diag[conv$tau2.theta.0.conv.diag$stat
									== min(conv$tau2.theta.0.conv.diag$stat), ], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic: (%s) %0.6f\n", min_t$Interval, min_t$stat))


		}
		if (alpha_pi_mon == 1) {
			cat(sprintf("alpha.pi:\n"))
			cat(sprintf("----------\n"))
			max_t = head(conv$alpha.pi.conv.diag[conv$alpha.pi.conv.diag$stat
									== max(conv$alpha.pi.conv.diag$stat), ], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic: (%s) %0.6f\n", max_t$Interval, max_t$stat))
			min_t = head(conv$alpha.pi.conv.diag[conv$alpha.pi.conv.diag$stat
									== min(conv$alpha.pi.conv.diag$stat), ], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic: (%s) %0.6f\n", min_t$Interval, min_t$stat))

		}
		if (beta_pi_mon == 1) {
			cat(sprintf("beta.pi:\n"))
			cat(sprintf("--------\n"))
			max_t = head(conv$beta.pi.conv.diag[conv$beta.pi.conv.diag$stat
									== max(conv$beta.pi.conv.diag$stat), ], 1)
			cat(sprintf("Max Gelman-Rubin diagnostic: (%s) %0.6f\n", max_t$Interval, max_t$stat))
			min_t = head(conv$beta.pi.conv.diag[conv$beta.pi.conv.diag$stat
									== min(conv$beta.pi.conv.diag$stat), ], 1)
			cat(sprintf("Min Gelman-Rubin diagnostic: (%s) %0.6f\n", min_t$Interval, min_t$stat))
		}
	}
	else {
		if (theta_mon == 1) {
			cat(sprintf("theta:\n"))
			cat(sprintf("------\n"))

			max_t = head(conv$theta.conv.diag[conv$theta.conv.diag$stat == max(conv$theta.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic (%s %s %s): %0.6f (%s)\n", max_t$Interval, max_t$B, max_t$AE, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$theta.conv.diag[conv$theta.conv.diag$stat == min(conv$theta.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic (%s %s %s): %0.6f (%s)\n", min_t$Interval, min_t$B, min_t$AE, min_t$stat,
												chk_val(min_t$stat)))
	
		}
		if (gamma_mon == 1) {
			cat(sprintf("gamma:\n"))
			cat(sprintf("------\n"))
			max_t = head(conv$gamma.conv.diag[conv$gamma.conv.diag$stat == max(conv$gamma.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic (%s %s %s): %0.6f (%s)\n", max_t$Interval, max_t$B, max_t$AE, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$gamma.conv.diag[conv$gamma.conv.diag$stat == min(conv$gamma.conv.diag$stat),,
						drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic (%s %s %s): %0.6f (%s)\n", min_t$Interval, min_t$B, min_t$AE, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (mu.gamma_mon == 1) {
			cat(sprintf("mu.gamma:\n"))
			cat(sprintf("---------\n"))
			max_t = head(conv$mu.gamma.conv.diag[conv$mu.gamma.conv.diag$stat
							== max(conv$mu.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic (%s %s): %0.6f (%s)\n", max_t$Interval, max_t$B, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$mu.gamma.conv.diag[conv$mu.gamma.conv.diag$stat
							== min(conv$mu.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic (%s %s): %0.6f (%s)\n", min_t$Interval, min_t$B, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (mu.theta_mon == 1) {
			cat(sprintf("mu.theta:\n"))
			cat(sprintf("---------\n"))
			max_t = head(conv$mu.theta.conv.diag[conv$mu.theta.conv.diag$stat
						== max(conv$mu.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic (%s %s): %0.6f (%s)\n", max_t$Interval, max_t$B, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$mu.theta.conv.diag[conv$mu.theta.conv.diag$stat
						== min(conv$mu.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic (%s %s): %0.6f (%s)\n", min_t$Interval, min_t$B, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (sigma2.gamma_mon == 1) {
			cat(sprintf("sigma2.gamma:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$sigma2.gamma.conv.diag[conv$sigma2.gamma.conv.diag$stat
					== max(conv$sigma2.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic (%s %s): %0.6f (%s)\n", max_t$Interval, max_t$B, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$sigma2.gamma.conv.diag[conv$sigma2.gamma.conv.diag$stat
					== min(conv$sigma2.gamma.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic (%s %s): %0.6f (%s)\n", min_t$Interval, min_t$B, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (sigma2.theta_mon == 1) {
			cat(sprintf("sigma2.theta:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$sigma2.theta.conv.diag[conv$sigma2.theta.conv.diag$stat
					== max(conv$sigma2.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic (%s %s): %0.6f (%s)\n", max_t$Interval, max_t$B, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$sigma2.theta.conv.diag[conv$sigma2.theta.conv.diag$stat
					== min(conv$sigma2.theta.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic (%s %s): %0.6f (%s)\n", min_t$Interval, min_t$B, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (pi_mon == 1) {
			cat(sprintf("pi:\n"))
			cat(sprintf("---\n"))
			max_t = head(conv$pi.conv.diag[conv$pi.conv.diag$stat
						== max(conv$pi.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic (%s %s): %0.6f (%s)\n", max_t$Interval, max_t$B, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$pi.conv.diag[conv$pi.conv.diag$stat
						== min(conv$pi.conv.diag$stat),, drop = FALSE], 1)
				cat(sprintf("Min Geweke statistic (%s %s): %0.6f (%s)\n", min_t$Interval, min_t$B, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (mu.gamma.0_mon == 1) {
			cat(sprintf("mu.gamma.0:\n"))
			cat(sprintf("-----------\n"))
			max_t = head(conv$mu.gamma.0.conv.diag[conv$mu.gamma.0.conv.diag$stat
					== max(conv$mu.gamma.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic: (%s) %0.6f (%s)\n", max_t$Interval, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$mu.gamma.0.conv.diag[conv$mu.gamma.0.conv.diag$stat
					== min(conv$mu.gamma.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic: (%s) %0.6f (%s)\n", min_t$Interval, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (mu.theta.0_mon == 1) {
			cat(sprintf("mu.theta.0:\n"))
			cat(sprintf("-----------\n"))
			max_t = head(conv$mu.theta.0.conv.diag[conv$mu.theta.0.conv.diag$stat
					== max(conv$mu.theta.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic: (%s) %0.6f (%s)\n", max_t$Interval, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$mu.theta.0.conv.diag[conv$mu.theta.0.conv.diag$stat
					== min(conv$mu.theta.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic: (%s) %0.6f (%s)\n", min_t$Interval, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (tau2.gamma.0_mon == 1) {
			cat(sprintf("tau2.gamma.0:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$tau2.gamma.0.conv.diag[conv$tau2.gamma.0.conv.diag$stat
					== max(conv$tau2.gamma.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic: (%s) %0.6f (%s)\n", max_t$Interval, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$tau2.gamma.0.conv.diag[conv$tau2.gamma.0.conv.diag$stat
					== min(conv$tau2.gamma.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic: (%s) %0.6f (%s)\n", min_t$Interval, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (tau2.theta.0_mon == 1) {
			cat(sprintf("tau2.theta.0:\n"))
			cat(sprintf("-------------\n"))
			max_t = head(conv$tau2.theta.0.conv.diag[conv$tau2.theta.0.conv.diag$stat
						== max(conv$tau2.theta.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic: (%s) %0.6f (%s)\n", max_t$Interval, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$tau2.theta.0.conv.diag[conv$tau2.theta.0.conv.diag$stat
					== min(conv$tau2.theta.0.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic: (%s) %0.6f (%s)\n", min_t$Interval, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (alpha_pi_mon == 1) {
			cat(sprintf("alpha.pi:\n"))
			cat(sprintf("----------\n"))
			max_t = head(conv$alpha.pi.conv.diag[conv$alpha.pi.conv.diag$stat
					== max(conv$alpha.pi.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic: (%s) %0.6f (%s)\n", max_t$Interval, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$alpha.pi.conv.diag[conv$alpha.pi.conv.diag$stat
					== min(conv$alpha.pi.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic: (%s) %0.6f (%s)\n", min_t$Interval, min_t$stat,
												chk_val(min_t$stat)))

		}
		if (beta_pi_mon == 1) {
			cat(sprintf("beta.pi:\n"))
			cat(sprintf("----------\n"))
			max_t = head(conv$beta.pi.conv.diag[conv$beta.pi.conv.diag$stat
					== max(conv$beta.pi.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Max Geweke statistic: (%s) %0.6f (%s)\n", max_t$Interval, max_t$stat,
												chk_val(max_t$stat)))
			min_t = head(conv$beta.pi.conv.diag[conv$beta.pi.conv.diag$stat
					== min(conv$beta.pi.conv.diag$stat),, drop = FALSE], 1)
			cat(sprintf("Min Geweke statistic: (%s) %0.6f (%s)\n", min_t$Interval, min_t$stat,
												chk_val(min_t$stat)))
		}

	}

	if (conv$sim_type == "MH") {
		cat("\nSampling Acceptance Rates:\n")
		cat("==========================\n")
		if (theta_mon == 1) {
			cat("theta:\n")
			cat("------\n")
			print(sprintf("Min: %0.6f, Max: %0.6f", min(conv$theta_acc$rate),
												max(conv$theta_acc$rate)))
		}
		if (gamma_mon == 1) {
			cat("gamma:\n")
			cat("------\n")
			print(sprintf("Min: %0.6f, Max: %0.6f", min(conv$gamma_acc$rate),
												max(conv$gamma_acc$rate)))
		}

		if (alpha_pi_mon == 1) {
			cat("alpha.pi:\n")
			cat("---------\n")
			print(sprintf("Min: %0.6f, Max: %0.6f", min(conv$alpha.pi_acc$ratec),
                                                max(conv$alpha.pi_acc$ratec)))
		}

		if (beta_pi_mon == 1) {
			cat("beta.pi:\n")
			cat("--------\n")
			print(sprintf("Min: %0.6f, Max: %0.6f", min(conv$beta.pi_acc$rate),
                                                max(conv$beta.pi_acc$rate)))
		}
	}
	else {
			cat("\nSampling Acceptance Rates:\n")
			cat("==========================\n")
			if (theta_mon == 1) {
				cat("theta:\n")
				cat("------\n")
				print(sprintf("Min: %0.6f, Max: %0.6f", min(conv$theta_acc$rate),
												max(conv$theta_acc$rate)))
		}
	}
}
