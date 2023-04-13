function [P, C, dist, J] = spfcm(X, Xbar, k, b, alpha, lambda)
iter = 0;
[N, p] = size(X);
P = randn(N, k);
P = P./(sum(P, 2)*ones(1, k));
J_prev = inf; J = [];
while true
    iter = iter + 1;
    P_old=P;
    t = P.^b;
    C = ((X+alpha*Xbar)'*t)'./(sum(t)'*ones(1, p)*(1+alpha));
    dist = sum(X.*X, 2)*ones(1, k) + (sum(C.*C, 2)*ones(1, N))'-2*X*C'+ alpha*(sum(Xbar.*Xbar, 2)*ones(1, k) + (sum(C.*C, 2)*ones(1, N))'-2*Xbar*C');
    t2 = (1./dist).^(1/(b-1));
    P = t2./(sum(t2, 2)*ones(1, k));
    P(P<=sqrt(lambda))=0;
    P=normlization(P);
    J_cur = sum(sum((P.^b).*dist))+lambda*numel(find(P>0));
    J = [J J_cur];
    if norm(P-P_old, 2) < 1e-5
        break;
    end
   display(sprintf('#iteration: %03d, objective function: %f', iter, J_cur));
   J_prev = J_cur; 
end