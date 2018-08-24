echo on

%- Random vectors with length 6 will be created.

%- Two elements with normal distribution:
Cm    = covmat1d_from_cfun( [1:2]', [], 'lin', [1 1;2 1] );
[P,C] = randmvar_add_normal( [], [], [0 2], [1 0.5], Cm );

%- Two elements with uniform distribution:
Cm    = covmat1d_from_cfun( [1:2]', [], 'drc' );
[P,C] = randmvar_add_uniform( P, C, [0 1;-1 1], Cm );

%- Two elements with log-normal distribution:
Cm    = covmat1d_from_cfun( [1:2]', [], 'exp', [1 0.6;2 0.4] );
[P,C] = randmvar_add_lognormal( P, C, [0 1], [0.3 1], Cm );

%- Introduce some cross-correlation between normal and and other elements
Cr = repmat( 0.1:0.1:0.4, 2, 1 );
C(1:2,3:6) = Cr;
C(3:6,1:2) = Cr';


%- Create 1e4 random vectors
X = randmvar( P, C, 1e4 );

%- Transpose X
X = X';

%- Check that basic statistic properties are obtained
[ mean(X(:,1:2))',      std(X(:,1:2))';
  min(X(:,3:4))',       max(X(:,3:4))';
  mean(log(X(:,5:6)))', std(log(X(:,5:6)))' ]

%- Input and obtained correlation matrix
full(C)
corrcoef(X)


%- Histogram for first uniform element
hist(X(:,3),100);


echo off