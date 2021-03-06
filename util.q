\d .util

/ data loading utilities

/ load (f)ile if it exists and return success boolean
loadf:{[f]if[()~key f;:0b];system "l ",1_string f;1b}

unzip:$["w"=first string .z.o;"7z.exe x -y -aos";"unzip -n"]
gunzip:$["w"=first string .z.o;"7z.exe x -y -aos";"gunzip -f -N -v"]
untar:"tar -xzvf"               / tar is now in windows 10 system32

/ (b)ase url, (f)ile, (e)xtension, (u)ncompress (f)unction
download:{[b;f;e;uf]
 if[0h=type f;:.z.s[b;;e;uf] each f];
 if[l~key l:`$":",f;:l];                          / local file exists
 if[()~key z:`$":",f,e;z 1: .Q.hg`$":",0N!b,f,e]; / download
 if[count uf;system 0N!uf," ",f,e];               / uncompress
 l}

/ load http://yann.lecun.com/exdb/mnist/ dataset
mnist:{
 d:first (1#4;1#"i") 1: 4_(h:4*1+x 3)#x;
 x:d#$[0>i:x[2]-0x0b;::;first ((2 4 4 8;"hief")@\:i,()) 1:] h _x;
 x}

/ load http://etlcdb.db.aist.go.jp/etlcdb/data/ETL9B dataset
etl9b:{(2 1 1 4 504, 64#1;"hxxs*",64#" ") 1: x}

/ general utilities

/ throw verbose exception if x <> y
assert:{if[not x~y;'`$"expecting '",(-3!x),"' but found '",(-3!y),"'"]}

/ generate a range of values between y and z with step-size x
rng:{y+x*til 1+floor 1e-14+(z-y)%x}

/ round y to nearest x
rnd:{x*"j"$y%x}

/ allocate y into x bins
nbin:{(x-1)&floor x*.5^y%max y-:min y}

/ divide range (s;e) into n buckets
nrng:{[n;s;e]s+til[1+n]*(e-s)%n}

/ table x cross y
tcross:{value flip ([]x) cross ([]y)}

/ return memory (used;allocated;max)
/ returned in units specified by x (0:B;1:KB;2:MB;3:GB;...)
mem:{(3#system"w")%x (1024*)/ 1}

/ given a dictionary who's values are indices representing result of the
/ group operator, return the original ungrouped list.  generate the
/ dictionary key if only the indices are provided
ugrp:{
 if[not type x;:.z.s til[count x]!x];
 x:(key[x] where count each value x)iasc raze x;
 x}

/ append a total row and (c)olumn to (t)able
totals:{[c;t]
 t[key[t]0N]:sum value t;
 t:t,'flip (1#c)!enlist sum each value t;
 t}

/ surround a (s)tring or list of stings with a box of (c)haracters
box:{[c;s]
 if[type s;s:enlist s];
 m:max count each s;
 h:enlist (m+2*1+count c)#c;
 s:(c," "),/:(m$/:s),\:(" ",c);
 s:h,s,h;
 s}

/ use (w)eights to randomly partition (x)
part:{[w;x]x (floor sums n*prev[0f;w%sum w]) _ 0N?n:count x}

/ one-hot encode vector, (symbol columns of) table or (non-key symbol
/ columns of) keyed table x.
onehot:{
 if[98h>t:type x;:u!x=/:u:distinct x];       / vector
 if[99h=t;:key[x]!.z.s value x];             / keyed table
 D:.z.s each x c:where 11h=type each flip x; / list of dictionaries
 D:string[c] {(`$(x,"_"),/:string key y)!value y}' D; / rename uniquely
 x:c _ x,' flip raze D;                               / append to table
 x}

/ confusion matrix
cm:{
 n:count u:asc distinct x,y;
 m:./[(n;n)#0;flip (u?y;u?x);1+];
 t:([]x:u)!flip (`$string u)!m;
 t}

/ heckbert's axis label algorithm

/ use heckbert's values to (r)ou(nd) or floor (x) to the nearest nice number
nicenum:{[rnd;x]
 s:`s#$[rnd;0 1.5 3 7!1 2 5 10f;(0f,1e-15+1 2 5f)!1 2 5 10f];
 x:f * s x%f:10 xexp floor 10 xlog x;
 x}

/ given requested (n)umber of labels and the (m)i(n) and (m)a(x) values, use
/ heckbert's algorithm to generate a series of nice numbers
heckbert:{[n;mn;mx]
 r:nicenum[0b] mx-mn;           / range of values
 s:nicenum[1b] r%n-1;           / step size
 mn:s*floor mn%s;               / new min
 mx:s*ceiling mx%s;             / new max
 l:rng[s;mn;mx];                / labels
 l}

/ plotting utilities

/ cut m x n matrix X into (x;y;z) where x and y are the indices for X
/ and z is the value stored in X[x;y] - result used to plot heatmaps
hmap:{[X]@[;0;`s#]tcross[til count X;reverse til count X 0],enlist raze X}

/ using (a)ggregation (f)unction, plot (X) using (c)haracters limited to
/ (w)idth and (h)eight. X can be x, (x;y), or (x;y;z)
plot:{[w;h;c;af;X]
 if[type X;X:enlist X];               / promote vector to matrix
 if[1=count X;X:(til count X 0;X 0)]; / turn ,x into (x;y)
 if[2=count X;X,:count[X 0]#1];       / turn (x;y) into (x;y;z)
 if[not `s=attr X 0;c:1_c];           / remove space unless heatmap
 l:heckbert[h div 2].(min;max)@\:X 1; / generate labels
 x:-1_nrng[w] . (min;max)@\:X 0;      / compute x axis
 y:-1_nrng[h] . (first;last)@\:l;     / compute y axis
 Z:(y;x) bin' "f"$X 1 0;              / allocate (x;y) to (w;h) bins
 Z:af each X[2]group flip Z;          / aggregating overlapping z
 Z:c nbin[count c;0f^Z];              / map values to characters
 p:./[(h;w)#" ";key Z;:;value Z];     / plot points
 k:@[count[y]#0n;0|y bin l;:;l];      / generate key
 p:reverse k!p;                       / generate plot
 p}

c10:" .-:=+x#%@"                         / 10 characters
c16:" .-:=+*xoXO#$&%@"                   / 16 characters
c68:" .'`^,:;Il!i><~+_-?][}{1)(|/tfjrxn" / 68 characters
c68,:"uvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"

plt:plot[19;10;c10;avg]         / default plot function

/ generate unicode sparkline
spark:raze("c"$226 150,/:129+til 8)nbin[8]::

/ image manipulation utilities

/ remove gamma compression
gexpand:{?[x>0.0405;((.055+x)%1.055) xexp 2.4;x%12.92]}
/ add gamma compression
gcompress:{?[x>.0031308;-.055+1.055*x xexp 1%2.4;x*12.92]}

/ convert rgb to grayscale
grayscale:.2126 .7152 .0722 wsum

/ create netpbm formatted strings for bitmap, grayscale and rgb
pbm:{[b;x]
 s:($[b;"P4";"P1"];-3!count'[(x;x 0)]);
 s,:$[b;enlist"c"$raze((0b sv 8#)each 8 cut raze::)each flip x;" "0:"b"$x];
 s}
pgm:{[b;m;x]
 if[b;if[any 255<m,max over x;'`limit]] / binary version has 255 max
 s:($[b;"P5";"P2"];-3!count'[(x;x 0)];string m);
 s,:$[b;enlist "c"$raze flip x;" "0:"h"$x];
 s}
ppm:{[b;m;x]
 if[b;if[any 255<m,max over x;'`limit]] / binary version has 255 max
 s:($[b;"P6";"P3"];-3!count'[(x;x 0)];string m);
 s,:$[b;enlist "c"$2 raze/flip x;" "0:raze flip each "h"$x];
 s}

/ text utilities

/ remove byte order mark if it exists
rbom:{$["\357\273\277"~3#x[0];@[x;0;3_];x]}

/ clean (s)tring of non ascii characters
cleanstr:{[s]
 s:ssr[s;"\342\200[\234\235]";"\""]; / replace double quotes
 s:ssr[s;"\342\200[\231\230]";"'"];  / replace single quotes
 s:ssr[s;"\342\200\246";"..."];      / replace ellipses
 s:ssr[s;"\342\200\223";"--"];       / replace endash
 s:ssr[s;"\342\200\224";"---"];      / replace emdash
 s:ssr[s;"\302\222";"'"];            / replace single quotes
 s:ssr[s;"\302\243";"$"];            / replace pound symbol with $
 s:ssr[s;"\302\241";"!"];            / replace !
 s:ssr[s;"\303\206";"AE"];              / replace AE
 s:ssr[s;"\303[\210\211\212\213]";"E"]; / replace E
 s:ssr[s;"\303[\231\232\233\234]";"U"]; / replace U
 s:ssr[s;"\303\246";"ae"];              / replace ae
 s:ssr[s;"\303[\250\251\252\253]";"e"]; / replace e
 s:ssr[s;"\303[\271\272\273\274]";"u"]; / replace u
 s:ssr[s;"&lt;";"<"];                / replace <
 s:ssr[s;"&gt;";">"];                / replace >
 s:ssr[s;"&amp;";"&"];               / replace &
 s}

/ strip (s)tring of puntuation marks
stripstr:{[s]
 s:ssr[s;"[][\n\\/()<>@#$%^&*=_+.,;:!?-]";" "]; / replace with white space
 s:ssr[s;"['\"0-9]";""];            / delete altogether
 s}
