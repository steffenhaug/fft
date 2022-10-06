---
title: The Fourier transform and the FFT algorithm
author: Steffen Haug
colorlinks: true
links-as-notes: true
header-includes:
- \usepackage{mathtools}
- \usepackage{xcolor}
- \usepackage{xfrac}
- \usepackage{csquotes}
- \interfootnotelinepenalty=10000
classoption:
- twocolumn
---
\newcommand{\Seq}[1]{\left\{ {#1} \right\}}
\newcommand{\Exp}[1]{e^{#1}}


# Introduction
The _discrete Fourier transform_ (DFT)
    \begin{equation}
    X_k = \sum_{n=0}^{N-1} x_n \Exp{-\frac {2 \pi i} N kn}
    \label{eq:dft}
    \end{equation}
transforms a _sequence_ $\left\{ {x}_n\right\}$ into another sequence $\left\{ {X}_n \right\}$.
Sequences are simply _arrays of numbers_ for our practical purposes, and
in the finite case it might sometimes be sensible to think of them as vectors in $\mathbb F^N$.
Compare it  to the continuous Fourier transform ($\xi \sim k$, $t \sim n$):
    \begin{equation}
    \hat f (\xi) = \int\displaylimits_{\mathbb R} f(t) \Exp{-2 \pi i \xi t } dt
    \end{equation}

Calling the DFT an approximation of the continuous Fourier transform might be a stretch,
but at least it motivates why it looks like it does. Essentially, you can think of $\Seq{x_n}$ as
sampling $f$ at discrete time points. $\Seq{X_n}$ gives you a discrete approximation
of the frequency distribution of $f$ with the integral approximated by a sort of Riemann-sum.

The aim of these notes is to explain _why the hell this works_ in terms of basic linear algebra
with most of the dense mathematical detail hand-waved away, and finally to explain the idea behind
the FFT algorithm.

# Why is this even interesting?
The fourier transformed signal $\hat f$ gives the frequency spectrum of $f$.
In most real engineering applications $f$ is unknown, and we only have discretely sampled sensor data.
Moreover, analytically evaluating an integral is almost always totally infeasible.
A discrete version that is simple to evaluate is therefor useful for many applications:

- Processing signals transmitted via EM-waves (Radio, **Internet**, etc.)
- Maritime industry (Ocean waves, etc.)
- Mechanical vibrations in machines and buildings (Civil engineering)
- Geophysics

And the list goes on! This shows up pretty much in every single branch of real engineering.
Moreover, most of the applications are time-critical, and a lot of the systems are hard real-time
systems. Speed is of the essence!

# Why does this even work?
Or: A crash course in functional analysis.
```
- functions form vector space (Hilbert space) L (integrable, sufficiently smooth blah blah blah).
- integrals of the form int f g dx is an inner product <f, g> in this vector space
- family of periodic functions exp(iwx) for all w is a orthonormal basis of L
- the projection of v onto u is (<v, u> / <u, u>)*u
- exps are normalized: proj of v onto e is simply <v, e>e = int f e dex
- for any frequency w, the component of exp(w) in f is simply <f, exp(w)>
- || Proj_exp f || = <f, exp> = int f exp dx
```

Back to familiar linear algebra: The inner product in L is actually very
reminiscent of the inner product in F^k! (Summing componentwise products).

# The key idea: Decomposing the Fourier transform
Rewrite \eqref{eq:dft} as the sum of a sum over even and a sum over odd indices:
    \begin{equation}
    \begin{aligned}
    & X_k &&= &&\sum_{n=0}^{N/2 - 1} x_{2n} \Exp{-\frac {2 \pi i} N 2n k} \\
    &     &&+ &&\sum_{n=0}^{N/2 - 1} x_{2n+1} {\color{red}\Exp{-\frac {2 \pi i} N (2n+1) k}} \\
    \end{aligned}
    \end{equation}
Factor out one of the exponentials in the odd-indexed sum:
    \begin{equation}
    \begin{aligned}
    & X_k &&=        &&\sum_{n=0}^{N/2 - 1} x_{2n} \Exp{-\frac {2 \pi i} N 2n k} \\
    &     &&+ {\color{red}\Exp{-\frac{2 \pi i} N k}}
                     &&\sum_{n=0}^{N/2 - 1} x_{2n+1} {\color{red}\Exp{-\frac {2 \pi i} N 2n k}}
    \end{aligned}
    \end{equation}
Rewrite using $2 = 1/(1/2)$ to move the 2 into the denominator:
    \begin{equation}
    \begin{aligned}
    & X_k &&=        &&\sum_{n=0}^{{\color{red} N/2} - 1} x_{2n} \Exp{-\frac {2 \pi i} {\color{red} N/2} n k} \\
    &     &&+ {\Exp{-\frac{2 \pi i} N k}}
                     &&\sum_{n=0}^{{\color{red} N/2} - 1} x_{2n+1} {\Exp{-\frac {2 \pi i} {\color{red} N/2} n k}} \\
    \end{aligned}
    \end{equation}
Notice that this is now simply two DFTs of half the length!
    \begin{equation}
    X_k = E_k + \Exp{-\frac{2 \pi i} N k} O_k
    \end{equation}
This enables decomposing a DFT into two smaller DFTs, but by itself this does not improve the
performance of our algorithm.

# Gaining speed: Reusing intermediate results
```
- key idea: DFT symmetrical around roots of unity; we only need to calculate the first half
- Even-indexed sum has the same parity, odd-indexed sum has the opposite parity
- X_k = E + O
- X_-k = E - O
```

# Scaling factors and symbol conventions
there are some practical things anyone using a DFT is likely to stumble across.

radians/s vs Hz. substitution $\omega = 2 \pi \xi$. $\omega$ quite normal in textbooks because
mathematicians like radians.

when you just have an array of samples, the FFT algorithm doesnt actually care what your sample
rate is. what is the relationship between the original sample rate, and the x-axis of the output?

ko
