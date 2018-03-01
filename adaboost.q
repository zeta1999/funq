\c 20 100
\l funq.q


/ https://cseweb.ucsd.edu/~yfreund/papers/adaboost.ps

f:"pima-indians-diabetes.data"
b:"http://archive.ics.uci.edu/ml/machine-learning-databases/pima-indians-diabetes/"
-1"downloading handwritten pima indians diabetes data set";
.util.download[b;;"";::] f

t:`class xcols flip `preg`plas`pres`skin`test`mass`pedi`age`class!("hhhhheehb";",")0:`$f
-1 .ml.ptree[0] tree:.ml.q45[2;3;::] t;
avg t.class=.ml.dtc[tree] each t / accuracy
-1 "a stump is a single branch tree";
-1 .ml.ptree[0] .ml.stump[::] t;
t:update -1 1 class from t
r:1_ (.01<first@) .ml.adaboost[.ml.stump;.ml.dtc;t]\(0w;();n#1f%n:count t)
avg t.class=signum sum r[;0] * signum r[;1] .ml.dtc/:\: t

show t:`Play xcols (" SSSSS";1#",") 0: `:weather.csv
t:update -1 1 `Yes=Play from t
r:1_  (.0001<first@) .ml.adaboost[.ml.stump;.ml.dtc;t]\(0w;();n#1f%n:count t)
avg t.Play=signum sum 5#r[;0] * signum r[;1] .ml.dtc/:\: t