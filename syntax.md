# Syntax definition
In the following syntax definition notation, a simple way to denote that an expresion could be something or something, the notation $A\Rightarrow\ B|C$ means that A can be reduced to either B or C, but not the two of them.  

$$
\begin{aligned}
    & \text{program} \Rightarrow sc_1; \ sc_2; \ sc_3; \ \dots ; \ sc_n \quad n \geq 1 \\
    & sc \Rightarrow\ \text{expr} \\
    & \hspace{10mm} \text{defns in expr} \\
    & \hspace{10mm} \text{fun } var \ var_1\ ...\ var_n = \text{expr} \quad n \geq 1 \\
    & \hspace{10mm} \text{fun } var \ var_1\ ...\ var_n = \text{defns in expr} \quad n \geq 1 \\
    & expr \Rightarrow\ expr \ aexpr \\
    & \hspace{10mm} expr_1 \ binop \ expr_2 \\
    & \hspace{10mm} aexpr \\
    & aexpr \Rightarrow\ var \\
    & \hspace{10mm} num \\
    & \hspace{10mm} (\text{expr}) \\
    & defns \Rightarrow\ defn_1; \ ... \ ; \ defn_n \quad n \geq 1 \\
    & defn \Rightarrow\ \text{var} \ var = \text{expr} \\
    & binop \Rightarrow\ + \mid - \mid * \mid / \\
    & var \Rightarrow\ \alpha \ varch_1\ ...\ varch_n \quad n \geq 0 \\
    & \alpha \Rightarrow\ \text{an alphabetic character} \\
    & varch \Rightarrow\ \alpha \mid \text{a digit} \mid \_ \\
\end{aligned}
$$



Something that may or may not come in handy is the file infix2prefix.oz, where the function $Infix2Prefix$ defines transformations so that an infix expression can be transformed to a prefixed form, and removes all the parenthesis. So that, Isolating an expression, it could be transformed to work with it more easily. So that, in this new space after the function, the Syntax rules will be the following:

$$
\begin{align*}
    &\begin{align*}
        expr \Rightarrow\ & expr\ aexpr \\
                            & binop\ expr_1\ expr_2 \\
                            & aexpr
    \end{align*} \\
    &\begin{align*}
        aexpr \Rightarrow\ & var \\
                            & num \\
    \end{align*} \\
\end{align*}
$$  
  
The previous syntax rules are able to parse correctly all mathematical operations. Also, it is able to parse function calls. And using function calls as parameters for binop operations. And nested operaition calls and many more. However, it fails when parsing an expression as a parameter for a function call. For example $foo + 1\ 2$ is the same as evaluating $foo(1+2)$ and it fails to evaluate it. 

To prevent left recursion and problems with implementation, the final implementation should end up using the following syntax (Haven't implemented it yet though)

$$
\begin{align*}
    &\begin{align*}
        expr \Rightarrow\ & aexpr \\
                            & binop\ expr_1\ expr_2 \\
                            & var\ expr_1\ expr_2\ ...\ expr_n\quad n\geq 1
    \end{align*} \\
    &\begin{align*}
        aexpr \Rightarrow\ & var \\
                            & num \\
    \end{align*} \\
\end{align*}
$$
