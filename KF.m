function [xp,Vp,xf,Vf,cL] = KF(I,A,Q,C,R,y,q,Channel,nC,nS,t,xprev,Vprev)
% Bank of Kalman filters

if t == 1
  xp = xprev;
  Vp = Vprev;
else
  xp = A*xprev;                         % predict state
  Vp = A*Vprev*A' + Q;                  % update state covariance matrix
end

% prediction error
if Channel(t)
    e = zeros(nC,1);
else
    e = y(q(t),t) - C*xp;
end

% update state estimate
S = diag(C*Vp*C') + R; % innovation covariance
K = (Vp*C')./S';       % Kalman gain
xf = xp + K.*e';

% update state covariance matrix
InS = eye(nS);
for c = 1:nC
    I.Vf(:,:,c,t) = (InS - K(:,c)*C(c,:))*Vp;
end
xp = repmat(xp,1,nC);

% context log likelihood
I.cL(:,t) = log(1./sqrt(2*pi*S)) - 0.5*(e./sqrt(S)).^2;


    [I.xp(:,:,t),I.Vp(:,:,t),I.xf(:,:,t),I.Vf(:,:,:,t),I.cL(:,t)] = KF(A,Q,C,R,y,q,Channel,nC,nS,t,xprev,Vprev);
    [I.cPost(:,t),I.xm(:,t),I.Vm(:,:,t),I.yp(q(t),t)] = ADF(C,I.Phi,nC,nS,q,I.cL,t,I.xf,I.xp,I.Vf);
    [I.S,I.Phi] = EM(I.S,I.Phi,I.cPost,nC,nQ,q(t),eta,t);
