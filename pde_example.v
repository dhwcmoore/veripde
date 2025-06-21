From Coq.Reals Require Import Reals.

Definition pde_example (x : R) : R := x * x + 2.

Extraction "pde_example.ml" pde_example.