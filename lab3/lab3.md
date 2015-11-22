# Inference rules

These rules will be referred to in this lab.

1. If X $$\supseteq$$ Y then X -> Y, or X -> X (reflexive rule)
2. XY |= XZ -> YZ (augmentation rule)
3. X ->  Y, Y -> Z |= X -> Z (transitive rule)
4. X -> YZ |= X -> Y (decomposition rule)
5. X -> Y, X -> Z |= X -> YZ (union or additive rule)
6. X -> Y, WY -> Z |= WX -> Z (pseudotransitive rule)

# Assignments

**1.**

a)

F={{AB->C}; {A->D}}, AB prime

b)

F={{AB->CD}; {C->D}}, AB prime

c)

F={{AB->CD}; {C->A}}, AB prime

**2.**

a)

$$ F={{AB->C}; {A->D}; {D->AE}; {E->F}} $$

Which gives:

A->D, D->AE, E->F (add rule 3)
A->D, D->AE, E->F, A->AE (add rule 4)
A->D, D->AE, E->F, A->AE, A->E (add rule 5)
A->D, D->AE, E->F, A->AE, A->E, A->F (add rule 3)
A->DEF

And:

AB->C

This means that we with A and B can identify all other attributes in the relation. AB is primary key for R.

b)

R(A, B, C, D, E, F), F={{AB->C}; {A->D}; {D->AE}; {E->F}}, AB prime

2NF: The relational model does not have any set of non-prime attributes that is functionally dependent on part of a candidate key. This gives the new relations R1 and R2 from R.

R1(A, B, C), F={{AB->C}}, AB prime
R2(A, D, E, F), F={{A->D}; {D->AE}; {E->F}}, A prime

c)

R1(A, B, C), F={{AB->C}}, AB prime
R2(A, D, E, F), F={{A->D}; {D->AE}; {E->F}}, A prime

3NF: The relational model does not have any set of **non-prime** attributes that is functionally dependent on a set of attributes that **is not a candidate key**.

R1(A, B, C), F{{AB->C}}, AB prime
R2(A, D, E), F={{D->AE}; {A->D}}, D prime
R3(E, F), F={{E->F}}, E prime

d)

R1(A, B, C), F{{AB->C}}, AB prime
R2(A, D, E), F={{D->AE}; {A->D}}, D prime
R3(E, F), F={{E->F}}, E prime

BCNF: In every functional dependency in the relational model, the determinant **is a candidate key**.

R1(A, B, C), F{{AB->C}}, AB prime
R2(A, D, E), F={{D->AE}}, D prime
R3(A, D), F={{A->D}}, A prime
R4(E, F), F={{E->F}}, E prime

**3.**

a)

R1(Title#, Title, BookType, Publisher, Author#), F={{Title#->Title, Book, Publisher, Author#}}, Title# prime
R2(Author#, AuthorName), F={{Author#->AuthorName}} Author# prime
R3(BookType, Price), F={{BookType->Price}}, BookType prime

b)
1NF:
R(Title#, Title, BookType, Publisher, Author#, AuthorName, Price), F={
{Title#->Title, Book, Publisher, Author#};
{Author#->AuthorName};
{BookType->Price}},
Title# Author# prime

2NF:
F={Author#->AuthorName} violates 2NF

R1(Title#, Title, BookType, Publisher, Author#, Price), F={{Title#->Title, Book, Publisher, Author#}; {BookType->Price}}, Title# prime
R2(Author#, AuthorName), F={{Author#->AuthorName}} Author# prime

3NF:
F={BookType->Price} violates 3NF

R1(Title#, Title, BookType, Publisher, Author#), F={{Title#->Title, Book, Publisher, Author#}}, Title# prime
R2(Author#, AuthorName), F={{Author#->AuthorName}} Author# prime
R3(BookType, Price), F={{BookType->Price}}, BookType prime

BCNF:
Every relation has one functional dependency. As such, there is only one determinant, and this determinant is a candidate key.