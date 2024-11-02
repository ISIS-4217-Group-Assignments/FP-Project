# Syntax definition
In the following syntax definition notation, a simple way to denote that an expresion could be something or something, the notation $A\Rightarrow\ B|C$ means that A can be reduced to either B or C, but not the two of them.  


$$
\begin{align*}
    &\begin{align*}
        program \Rightarrow sc_1;\ sc_2;\ sc_3;\ ...\ sc_n\quad n \geq 1
    \end{align*} \\
    &\begin{align*}
        sc \Rightarrow\  & expr \\
                            &\text{fun}\ var\  var_1\ ...\ var_n = expr \quad n \geq 1 \\
                            &\text{fun}\ var\ var_1\ ...\ var_n = defns\ \text{in}\ expr\quad n \geq 1 \\
    \end{align*} \\
    &\begin{align*}
        expr \Rightarrow\ & expr\ aexpr \\
                            & expr_1\ binop\ expr_2 \\
                            & aexpr
    \end{align*} \\
    &\begin{align*}
        aexpr \Rightarrow\ & var \\
                            & num \\
                            & \text{(}\ expr\ \text{)}
    \end{align*} \\
    &\begin{align*}
        defns \Rightarrow\ & defn_1;\ ...\  ;\ defn_n\quad n\geq 1 \\
    \end{align*} \\
    &\begin{align*}
        defn \Rightarrow\ & var = expr
    \end{align*} \\
    &\begin{align*}
        binop \Rightarrow\ & \text{+}\ |\ \text{-}\ |\ \text{*}\ |\ \text{/} \\
    \end{align*} \\
    &\begin{align*}
        var \Rightarrow\ & alpha\ varch_1\ ...\ varch_n\quad n\geq 0 \\
    \end{align*} \\
    &\begin{align*}
        alpha \Rightarrow\ & \text{an alphabetic character} \\
    \end{align*} \\
    &\begin{align*}
        varch \Rightarrow\ & alpha\ |\ \text{a digit}\ |\ \text{\_}
    \end{align*}
\end{align*}
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