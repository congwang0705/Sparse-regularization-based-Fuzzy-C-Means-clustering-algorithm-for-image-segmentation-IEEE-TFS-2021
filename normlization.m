function Y=normlization(U)
A=sum(U');
B=repmat(A',1,size(U,2));
Y=U./B;