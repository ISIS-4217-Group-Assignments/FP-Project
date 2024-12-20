# Syntax definition

In the following syntax definition notation, a simple way to denote that an expression could be something or something, the notation $A \Rightarrow B \mid C$ means that $A$ can be reduced to either $B$ or $C$, but not both.

$$
\begin{aligned}
    & program \Rightarrow sc_1; \ sc_2; \ sc_3; \ \dots ; \ sc_n \quad n \geq 1 \\
    & sc \Rightarrow\ \text{expr} \\
    & \hspace{10mm} \text{defns in expr} \\
    & \hspace{10mm} \text{fun } var \ var_1 \ \dots \ var_n = \text{expr} \quad n \geq 1 \\
    & \hspace{10mm} \text{fun } var \ var_1 \ \dots \ var_n = \text{defns in expr} \quad n \geq 1 \\
    & expr \Rightarrow\ expr \ aexpr \\
    & \hspace{10mm} expr_{1} \ binop \ expr_{2} \\
    & \hspace{10mm} aexpr \\
    & aexpr \Rightarrow\ var \\
    & \hspace{10mm} num \\
    & \hspace{10mm} (\text{expr}) \\
    & defns \Rightarrow\ defn_1; \ \dots ; \ defn_n \quad n \geq 1 \\
    & defn \Rightarrow\ \text{var} \ var = \text{expr} \\
    & binop \Rightarrow\ + \mid - \mid * \mid / \\
    & var \Rightarrow\ \alpha \ varch_1 \ \dots \ varch_n \quad n \geq 0 \\
    & \alpha \Rightarrow\ [a-zA-Z] \\
    & varch \Rightarrow\ \alpha \mid [0-9] \mid \textunderscore \\
\end{aligned}
$$


Something that may or may not come in handy is the file `infix2prefix.oz`, where the function `Infix2Prefix` defines transformations so that an infix expression can be transformed into a prefixed form, and removes all the parentheses. This helps isolate an expression so that it can be worked with more easily. In this new space after the function, the syntax rules will be the following:

$$
\begin{aligned}
    & expr \Rightarrow\ expr\ aexpr \\
    & \hspace{10mm} binop\ expr_1\ expr_2 \\
    & \hspace{10mm} aexpr \\
    & aexpr \Rightarrow\ var \\
    & \hspace{10mm} num \\
\end{aligned}
$$  

The previous syntax rules are able to parse correctly all mathematical operations. It can also parse function calls and even function calls as parameters for binop operations. However, it fails when parsing an expression as a parameter for a function call. For example, `foo + 1 2` should be the same as evaluating `foo(1 + 2)`, but it fails to evaluate this.

To prevent left recursion and problems with implementation, the final implementation should use the following syntax (haven't implemented it yet though):

$$
\begin{aligned}
    & expr \Rightarrow\ aexpr \\
    & \hspace{10mm} binop\ expr_1\ expr_2 \\
    & \hspace{10mm} var\ expr_1\ expr_2\ ...\ expr_n \quad n \geq 1 \\
    & aexpr \Rightarrow\ var \\
    & \hspace{10mm} num \\
\end{aligned}
$$
