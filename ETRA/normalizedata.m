% normailize data
Y = zeros(size(X));

for i = 1:size(X,1)
    Y(i,[1:9,11:19,21:29]) = X(i,[1:9,11:19,21:29])/ norm(X(1,[1:9,11:19,21:29]));
    Y(i,[10,20,30]) = X(i,[10,20,30])/ norm(X(1,[10,20,30]));
end