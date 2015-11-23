% TDDD37 Lab 3
% Hans-Filip Elo; Alvin Stockhaus
% 2015-11-22

# Inference rules

These rules will be referred to in this lab.

1. Reflexive rule: If  $$ X \supseteq Y then X \rightarrow  Y, or X \rightarrow  X $$
2. Augmentation rule:  $$ XY |= XZ \rightarrow  YZ $$
3. Transitive rule  $$ X \rightarrow   Y, Y \rightarrow  Z |= X \rightarrow  Z $$
4. Decomposition rule:  $$ X \rightarrow  YZ |= X \rightarrow  Y $$
5. Additive rule:  $$ X \rightarrow  Y, X \rightarrow  Z |= X \rightarrow  YZ $$
6. Pseudotransitive rule:  $$ X \rightarrow  Y, WY \rightarrow  Z |= WX \rightarrow  Z $$

# Assignments

## 1.

**a)**  $$ F=\{\{AB\rightarrow C\}; \{A\rightarrow D\}\} $$ , AB prime

**b)**  $$ F=\{\{AB\rightarrow CD\}; \{C\rightarrow D\}\} $$ , AB prime

**c)**  $$ F=\{\{AB\rightarrow CD\}; \{C\rightarrow A\}\} $$ , AB prime

## 2.

**a)**

 $$ F=\{\{AB\rightarrow C\}; \{A\rightarrow D\}; \{D\rightarrow AE\}; \{E\rightarrow F\}\} $$

Which gives:

 $$ A\rightarrow D, D\rightarrow AE, E\rightarrow F $$  (add rule 3)

 $$ A\rightarrow D, D\rightarrow AE, E\rightarrow F, A\rightarrow AE $$  (add rule 4)

 $$ A\rightarrow D, D\rightarrow AE, E\rightarrow F, A\rightarrow AE, A\rightarrow E $$  (add rule 5)

 $$ A\rightarrow D, D\rightarrow AE, E\rightarrow F, A\rightarrow AE, A\rightarrow E, A\rightarrow F $$  (add rule 3)

 $$ A\rightarrow DEF $$

And:

 $$ AB\rightarrow C $$

This means that we with A and B can identify all other attributes in the relation. AB is primary key for R.

**b)**

R(A, B, C, D, E, F),  $$ F=\{\{AB\rightarrow C\}; \{A\rightarrow D\}; \{D\rightarrow AE\}; \{E\rightarrow F\}\} $$ , AB prime

**2NF:** The relational model does not have any set of **non-prime** attributes that is functionally dependent on **part of a candidate key**. This gives the new relations R1 and R2 from R.

R1(A, B, C),  $$ F=\{\{AB\rightarrow C\}\} $$ , AB prime

R2(A, D, E, F),  $$ F=\{\{A\rightarrow D\}; \{D\rightarrow AE\}; \{E\rightarrow F\}\} $$ , A prime

**c)**

R1(A, B, C),  $$ F=\{\{AB\rightarrow C\}\} $$ , AB prime

R2(A, D, E, F),  $$ F=\{\{A\rightarrow D\}; \{D\rightarrow AE\}; \{E\rightarrow F\}\} $$ , A prime

**3NF:** The relational model does not have any set of **non-prime** attributes that is functionally dependent on a set of attributes that **is not a candidate key**.

R1(A, B, C),  $$ F=\{\{AB\rightarrow C\}\} $$ , AB prime

R2(A, D, E),  $$ F=\{\{D\rightarrow AE\}; \{A\rightarrow D\}\} $$ , D prime

R3(E, F),  $$ F=\{\{E\rightarrow F\}\} $$ , E prime

**d)**

R1(A, B, C),  $$ F=\{\{AB\rightarrow C\}\} $$ , AB prime

R2(A, D, E),  $$ F=\{\{D\rightarrow AE\}; \{A\rightarrow D\}\} $$  D prime

R3(E, F),  $$ F=\{\{E\rightarrow F\}\} $$  E prime

BCNF: In every functional dependency in the relational model, the determinant **is a candidate key**.

R1(A, B, C),  $$ F=\{\{AB\rightarrow C\}\} $$  AB prime

R2(A, D, E),  $$ F=\{\{D\rightarrow AE\}\} $$  D prime

R3(A, D),  $$ F=\{\{A\rightarrow D\}\} $$  A prime

R4(E, F),  $$ F=\{\{E\rightarrow F\}\} $$  E prime

\newpage

## 3.

**a)**

R1(TitleNr, Title, BookType, Publisher, AuthorNr),  $$ F=\{\{TitleNr\rightarrow Title, Book, Publisher, AuthorNr\}\}  $$  $$  TitleNr prime

R2(AuthorNr, AuthorName),  $$ F=\{\{AuthorNr\rightarrow AuthorName\}\} $$  AuthorNr prime

R3(BookType, Price),  $$ F=\{\{BookType\rightarrow Price\}\} $$  BookType prime

**b)**

**1NF:**

R(TitleNr, Title, BookType, Publisher, AuthorNr, AuthorName, Price),  $$ F=\{\\
\{TitleNr\rightarrow Title, Book, Publisher, AuthorNr\};\\
\{AuthorNr\rightarrow AuthorName\};\\
\{BookType\rightarrow Price\}\\\} $$ ,
TitleNr and AuthorNr prime

**2NF:**

 $$ F=\{AuthorNr\rightarrow AuthorName\} $$  violates 2NF

R1(TitleNr, Title, BookType, Publisher, AuthorNr, Price),  $$ F=\{\{TitleNr\rightarrow Title, Book, Publisher, AuthorNr\}; \{BookType\rightarrow Price\}\} $$ , TitleNr prime

R2(AuthorNr, AuthorName),  $$ F=\{\{AuthorNr\rightarrow AuthorName\}\} $$ , AuthorNr prime

**3NF:**

 $$ F=\{BookType\rightarrow Price\} $$  violates 3NF

R1(TitleNr, Title, BookType, Publisher, AuthorNr),  $$ F=\{\{TitleNr\rightarrow Title, Book, Publisher, AuthorNr\}\} $$ , TitleNr prime

R2(AuthorNr, AuthorName),  $$ F=\{\{AuthorNr\rightarrow AuthorName\}\} $$ , AuthorNr prime

R3(BookType, Price),  $$ F=\{\{BookType\rightarrow Price\}\} $$ , BookType prime

**BCNF:**

Every relation has one functional dependency. As such, there is only one determinant, and this determinant is a candidate key.
